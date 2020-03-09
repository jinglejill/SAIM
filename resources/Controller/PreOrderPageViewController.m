//
//  PreOrderPageViewController.m
//  SAIM_UPDATING
//
//  Created by Thidaporn Kijkamjai on 4/10/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "PreOrderPageViewController.h"
#import "PreOrderViewController.h"
#import "Product.h"
#import "SharedProduct.h"
#import "ProductWithQuantity.h"
#import "Utility.h"
#import "ProductName.h"


@interface PreOrderPageViewController ()
{
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSArray *_arrProductWithQuantity;
    NSMutableArray *_mutArrProductWithQuantity;
    NSMutableArray *_arrProductCategory2;
}
@end

@implementation PreOrderPageViewController
- (void)loadView
{
    [super loadView];
    
    {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);        
    }
        
    
    [self loadViewProcess];
}

- (void)loadViewProcess
{
}

- (PreOrderViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    PreOrderViewController * initialViewController = [storyboard instantiateViewControllerWithIdentifier:@"PreOrderViewController"];
    initialViewController.index = index;
    initialViewController.arrProductCategory2 = _arrProductCategory2;
    initialViewController.mutArrProductWithQuantity = _mutArrProductWithQuantity;
    
    
    return initialViewController;
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(PreOrderViewController *)viewController index];
    
    if (index == 0) {
        return nil;
    }
    
    // Decrease the index by 1 to return
    index--;
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(PreOrderViewController *)viewController index];
    
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
-(void)queryProductWithQuantity
{
    //query data
    //เรียงลำดับ, สร้าง dictionary ใส่ value คือจำนวน key คือ productidgroup
    
    
    NSMutableArray *productList = [SharedProduct sharedProduct].productList;
    for(Product *item in productList)
    {
        item.productIDGroup = [Utility getProductIDGroup:item];
    }
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_eventID" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_status" ascending:YES];
    NSSortDescriptor *sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:@"_productIDGroup" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2,sortDescriptor3, nil];
    NSArray *productSort = [productList sortedArrayUsingDescriptors:sortDescriptors];
    
    NSMutableArray *groupHead = [[NSMutableArray alloc]init];
    NSMutableArray *groupCount = [[NSMutableArray alloc]init];
    NSInteger countData = 0;
    BOOL firstItem = YES;
    Product *previousProduct = [[Product alloc]init];
    for(Product *item in productSort)
    {
        if(!((item.eventID == previousProduct.eventID) &&
             [item.status isEqualToString:previousProduct.status] &&
             [item.productIDGroup isEqualToString:previousProduct.productIDGroup]))
        {
            previousProduct = item;
            [groupHead addObject:item];
            if(!firstItem)
            {
                [groupCount addObject:[NSString stringWithFormat:@"%ld",(long)countData]];
            }
            else
            {
                firstItem = NO;
            }
            
            countData = 1;
        }
        else
        {
            countData += 1;
        }
    }
    [groupCount addObject:[NSString stringWithFormat:@"%ld",(long)countData]];
    
    
    _mutArrProductWithQuantity = [[NSMutableArray alloc]init];
    for(int i=0; i<[groupHead count]; i++)
    {
        Product *product = groupHead[i];
        NSString *strEventID = [NSString stringWithFormat:@"%ld",product.eventID];
        NSString *quantity = groupCount[i];
        NSString *productNameGroup = [NSString stringWithFormat:@"%@%@%@",product.productCategory2,product.productCategory1,product.productName];
        ProductWithQuantity *productWithQuantity = [[ProductWithQuantity alloc]init];
        productWithQuantity.productName = [ProductName getNameWithProductNameGroup:productNameGroup];
        productWithQuantity.color = [Utility getColorName:product.color];
        productWithQuantity.size = product.size;
        productWithQuantity.quantity = quantity;
        productWithQuantity.productIDGroup = product.productIDGroup;
        productWithQuantity.eventID = strEventID;
        productWithQuantity.status = product.status;
        productWithQuantity.productCategory2 = product.productCategory2;
        
        [_mutArrProductWithQuantity addObject:productWithQuantity];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self queryProductWithQuantity];
    NSString *strEventID = [Utility getUserDefaultPreOrderEventID];
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_eventID = %@ and _status = %@",strEventID,@"I"];
    _arrProductWithQuantity = [_mutArrProductWithQuantity filteredArrayUsingPredicate:predicate1];
    
    
    NSSet *uniqueProductCategory2 = [NSSet setWithArray:[_arrProductWithQuantity valueForKey:@"productCategory2"]];
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
    PreOrderViewController * initialViewController = [storyboard instantiateViewControllerWithIdentifier:@"PreOrderViewController"];
    initialViewController.index = 0;
    initialViewController.arrProductCategory2 = _arrProductCategory2;
    initialViewController.mutArrProductWithQuantity = _mutArrProductWithQuantity;
    
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
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
@end
