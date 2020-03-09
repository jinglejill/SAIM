//
//  EventInventoryItemPageViewController.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 8/29/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "EventInventoryItemPageViewController.h"
#import "Utility.h"
#import "SharedSelectedEvent.h"

#import "SharedProduct.h"
#import "SharedProductSize.h"
#import "SharedProductName.h"
#import "SharedProductCategory2.h"
#import "SharedProductCategory1.h"
#import "SharedColor.h"
#import "EventInventoryItemViewController.h"


@interface EventInventoryItemPageViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSArray *_arrProductEvent;
    NSMutableArray *_arrProductCategory2;
    NSInteger _currentPage;
}
@end


@implementation EventInventoryItemPageViewController
@synthesize btnAllOrRemaining;


- (void)loadView {
    [super loadView];
    _homeModel = [[HomeModel alloc] init];
    _homeModel.delegate = self;
    
    {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);        
    }
    btnAllOrRemaining.title = @"All";
        
    
    [self loadViewProcess];
}

-(void)loadViewProcess
{
    
}
- (EventInventoryItemViewController *)viewControllerAtIndex:(NSUInteger)index
{
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    EventInventoryItemViewController * initialViewController = [storyboard instantiateViewControllerWithIdentifier:@"EventInventoryItemViewController"];
    initialViewController.index = index;
    initialViewController.arrProductCategory2 = _arrProductCategory2;
    initialViewController.arrProductEvent = _arrProductEvent;
    _currentPage = index;

    
    return initialViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(EventInventoryItemViewController *)viewController index];
    
    if (index == 0) {
        return nil;
    }
    
    // Decrease the index by 1 to return
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(EventInventoryItemViewController *)viewController index];
    index++;
    if (index == [_arrProductCategory2 count]) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return [_arrProductCategory2 count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return 0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self pagingProcess:0];
    [self loadingOverlayView];
    [_homeModel downloadItems:dbMainInventory];
}

- (void)itemsDownloaded:(NSArray *)items
{
    [self removeOverlayViews];
    int i=0;
    

    [SharedProductName sharedProductName].productNameList = items[i++];
    [SharedColor sharedColor].colorList = items[i++];
    [SharedProductCategory2 sharedProductCategory2].productCategory2List = items[i++];
    [SharedProductCategory1 sharedProductCategory1].productCategory1List = items[i++];
    [SharedProductSize sharedProductSize].productSizeList = items[i++];
    [SharedProduct sharedProduct].productList = items[i++];

    [self pagingProcess:0];
}

-(void)pagingProcess:(NSInteger)currentPage
{
    NSMutableArray *productList = [SharedProduct sharedProduct].productList;
    NSMutableArray *productAllOrRemainingList = [[NSMutableArray alloc]init];
    if([btnAllOrRemaining.title isEqualToString:@"Remaining"])
    {
        for(Product *item in productList)
        {
            Product *product = [item copy];
            product.productIDGroup = [Utility getProductIDGroup:item];
            
            if([item.status isEqualToString:@"P"])
            {
                product.status = @"I";
            }
            [productAllOrRemainingList addObject:product];
        }
    }
    else if([btnAllOrRemaining.title isEqualToString:@"All"])
    {
        for(Product *item in productList)
        {
            item.productIDGroup = [Utility getProductIDGroup:item];
        }
        productAllOrRemainingList = productList;
    }
    
    NSInteger eventID = [Event getSelectedEvent].eventID;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_eventID = %ld and _status = %@",eventID,@"I"];
    _arrProductEvent = [productAllOrRemainingList filteredArrayUsingPredicate:predicate1];
    
    
    NSSet *uniqueProductCategory2 = [NSSet setWithArray:[_arrProductEvent valueForKey:@"productCategory2"]];
    NSArray *arrProductCategory2 = [uniqueProductCategory2 allObjects];
    _arrProductCategory2 = [arrProductCategory2 mutableCopy];
    
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"" ascending:YES];//order by productcategory2 code
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortArray = [_arrProductCategory2 sortedArrayUsingDescriptors:sortDescriptors];
    _arrProductCategory2 = [sortArray mutableCopy];
    
    
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageController.dataSource = self;
    [[self.pageController view] setFrame:[[self view] bounds]];
    
    NSArray *subviews = self.pageController.view.subviews;
    UIPageControl *thisControl = nil;
    for (int i=0; i<[subviews count]; i++) {
        if ([[subviews objectAtIndex:i] isKindOfClass:[UIPageControl class]]) {
            thisControl = (UIPageControl *)[subviews objectAtIndex:i];
        }
    }
    
    
    thisControl.pageIndicatorTintColor = [UIColor purpleColor];
    thisControl.currentPageIndicatorTintColor = [UIColor magentaColor];
    
    
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    EventInventoryItemViewController * initialViewController = [storyboard instantiateViewControllerWithIdentifier:@"EventInventoryItemViewController"];
    initialViewController.index = currentPage;
    _currentPage = currentPage;
    initialViewController.arrProductCategory2 = _arrProductCategory2;
    initialViewController.arrProductEvent = _arrProductEvent;
    
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_currentPage == 0 && scrollView.contentOffset.x < scrollView.bounds.size.width) {
        scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0);
    } else if (_currentPage == [_arrProductCategory2 count]-1 && scrollView.contentOffset.x > scrollView.bounds.size.width) {
        scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0);
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (_currentPage == 0 && scrollView.contentOffset.x <= scrollView.bounds.size.width) {
        *targetContentOffset = CGPointMake(scrollView.bounds.size.width, 0);
    } else if (_currentPage == [_arrProductCategory2 count]-1 && scrollView.contentOffset.x >= scrollView.bounds.size.width) {
        *targetContentOffset = CGPointMake(scrollView.bounds.size.width, 0);
    }
}

-(void) loadingOverlayView
{
    [indicator startAnimating];
    indicator.layer.zPosition = 1;
    indicator.alpha = 1;
    
    
    // and just add them to navigationbar view
    [self.navigationController.view addSubview:overlayView];
    [self.navigationController.view addSubview:indicator];
}

-(void) removeOverlayViews{
    UIView *view = overlayView;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         view.alpha = 0.0;
                         indicator.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         dispatch_async(dispatch_get_main_queue(),^ {
                             [view removeFromSuperview];
                             [indicator stopAnimating];
                             [indicator removeFromSuperview];
                         } );
                         
                     }
     ];
}

- (IBAction)deleteAllProductInEvent:(id)sender
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:
     [UIAlertAction actionWithTitle:@"Delete all product in event"
                              style:UIAlertActionStyleDestructive
                            handler:^(UIAlertAction *action) {
                                
                                [self loadingOverlayView];
                                NSInteger eventID = [Event getSelectedEvent].eventID;
                                NSString *strEventID = [NSString stringWithFormat:@"%ld",eventID];
                                [_homeModel updateItems:dbProductDeleteFromEvent withData:strEventID];
                                
//                                //update shared product
//                                NSMutableArray *productList = [SharedProduct sharedProduct].productList;
//                                for(Product *item in productList)
//                                {
//                                    if([item.status isEqualToString:@"I"] && (item.eventID == eventID))
//                                    {
//                                        item.eventID = 0;
//                                        item.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
//                                        item.modifiedUser = [Utility modifiedUser];
//                                    }
//                                }
                                
                                
//                                [self viewDidLoad];
                            
                            }]];
    
    [alert addAction:
     [UIAlertAction actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleCancel
                            handler:^(UIAlertAction *action) {}]];
    
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)itemsUpdated
{
    [self removeOverlayViews];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                   message:@"Delete items in the event successful"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
    {
        [self viewDidLoad];
    }];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)allOrRemaining:(id)sender
{
    if([btnAllOrRemaining.title isEqualToString:@"All"])
    {
        btnAllOrRemaining.title = @"Remaining";
        [self pagingProcess:_currentPage];
    }
    else if([btnAllOrRemaining.title isEqualToString:@"Remaining"])
    {
        btnAllOrRemaining.title = @"All";
        [self pagingProcess:_currentPage];
    }
}
@end
