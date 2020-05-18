//
//  CompareInventoryPageViewController.m
//  SAIM_UPDATING
//
//  Created by Thidaporn Kijkamjai on 4/10/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "CompareInventoryPageViewController.h"
#import "CompareInventoryViewController.h"
#import "Utility.h"
#import "SharedSelectedEvent.h"
#import "CompareInventoryHistory.h"
#import "CompareInventory.h"
#import "ComparingScanViewController.h"


#import "SharedProduct.h"
#import "SharedCompareInventoryHistory.h"
#import "SharedCompareInventory.h"
#import "SharedPushSync.h"
#import "PushSync.h"


@interface CompareInventoryPageViewController ()
{
    NSMutableArray *_mutArrCompareInventory;
    NSMutableArray *_arrProductCategory2;
    NSMutableArray *_compareInventoryList;
    Event *_event;
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSString *_runningSetNo;
    NSInteger pageIndex;
    NSString *_strNextID;
}
@end

@implementation CompareInventoryPageViewController

- (IBAction)unwindToCompareInventoryPage:(UIStoryboardSegue *)segue
{
    
    _compareInventoryList = [SharedCompareInventory sharedCompareInventory].compareInventoryList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_runningSetNo = %@",_runningSetNo];
    NSArray *filterArray = [_compareInventoryList filteredArrayUsingPredicate:predicate1];
    _compareInventoryList = [filterArray mutableCopy];
    
    
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    CompareInventoryViewController * initialViewController = [storyboard instantiateViewControllerWithIdentifier:@"CompareInventoryViewController"];
    initialViewController.index = pageIndex;
    [self prepareData];
    initialViewController.arrProductCategory2 = _arrProductCategory2;
    initialViewController.runningSetNo = _runningSetNo;
    
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (CompareInventoryViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    CompareInventoryViewController * initialViewController = [storyboard instantiateViewControllerWithIdentifier:@"CompareInventoryViewController"];
    initialViewController.index = index;
    initialViewController.arrProductCategory2 = _arrProductCategory2;
    initialViewController.runningSetNo = _runningSetNo;
    pageIndex = index;
    
    
    return initialViewController;
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(CompareInventoryViewController *)viewController index];
    
    if (index == 0) {
        return nil;
    }
    
    // Decrease the index by 1 to return
    index--;
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(CompareInventoryViewController *)viewController index];
    
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

- (void)loadView
{
    [super loadView];
    
    // Create new HomeModel object and assign it to _homeModel variable
    _homeModel = [[HomeModel alloc] init];
    _homeModel.delegate = self;
    
    {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);
    }

    
    _event = [Event getSelectedEvent];
    _compareInventoryList = [[NSMutableArray alloc]init];
    
    
    //insert to compareinventory
    [self loadingOverlayView];
    NSString *strEventID = [NSString stringWithFormat:@"%ld",_event.eventID];
    _strNextID = [NSString stringWithFormat:@"%ld",[Utility getNextID:tblCompareInventoryHistory]];
    [_homeModel insertItems:dbCompareInventory withData:@[strEventID,_strNextID]];
    [self updateSharedData];
    [self prepareData];
    
    
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageController.dataSource = self;
    [[self.pageController view] setFrame:[[self view] bounds]];
    
    NSArray *subviews = self.pageController.view.subviews;
    UIPageControl *thisControl = nil;
    for (int i=0; i<[subviews count]; i++)
    {
        if ([[subviews objectAtIndex:i] isKindOfClass:[UIPageControl class]]) {
            thisControl = (UIPageControl *)[subviews objectAtIndex:i];
        }
    }
    
    
    thisControl.pageIndicatorTintColor = [UIColor purpleColor];
    thisControl.currentPageIndicatorTintColor = [UIColor magentaColor];
    
    
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    CompareInventoryViewController * initialViewController = [storyboard instantiateViewControllerWithIdentifier:@"CompareInventoryViewController"];
    initialViewController.index = 0;
    initialViewController.arrProductCategory2 = _arrProductCategory2;
    initialViewController.runningSetNo = _runningSetNo;
    
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
    
    [self loadViewProcess];
}

- (void)loadViewProcess
{
    
}

- (void)itemsInserted
{
}

- (void)updateSharedData
{
    _runningSetNo = _strNextID;
    
    
    //insert sharedcompareinventoryhistory
    NSMutableArray *compareInventoryHistoryList = [SharedCompareInventoryHistory sharedCompareInventoryHistory].compareInventoryHistoryList;
    
    
    NSString *strEventID = [NSString stringWithFormat:@"%ld",(long)_event.eventID];
    CompareInventoryHistory *compareInventoryHistory = [[CompareInventoryHistory alloc]init];
    compareInventoryHistory.compareInventoryHistoryID = [_strNextID integerValue];
    compareInventoryHistory.eventID = strEventID;
    compareInventoryHistory.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
    compareInventoryHistory.modifiedUser = [Utility modifiedUser];
    [compareInventoryHistoryList addObject:compareInventoryHistory];
    
    
    
    NSMutableArray *productList = [SharedProduct sharedProduct].productList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_eventID = %ld and _status = %@",[SharedSelectedEvent sharedSelectedEvent].event.eventID,@"I"];
    NSArray *arrFilter = [productList filteredArrayUsingPredicate:predicate1];
    for(Product *item in arrFilter)
    {
        CompareInventory *compareInventory = [[CompareInventory alloc]init];
        compareInventory.runningSetNo = _strNextID;
        compareInventory.productID = item.productID;
        compareInventory.productCode = [Utility getProductCode:item];
        compareInventory.compareStatus = @"N";
        compareInventory.productCategory2 = item.productCategory2;
        

        compareInventory.productCategory2Code = item.productCategory2;
        compareInventory.productCategory1Code = item.productCategory1;
        compareInventory.productNameCode = item.productName;
        compareInventory.colorCode = item.color;
        compareInventory.sizeCode = item.size;
        compareInventory.manufacturingDate = item.manufacturingDate;
        [_compareInventoryList addObject:compareInventory];
    }
    
    //insert sharedcompareinventory
    [[SharedCompareInventory sharedCompareInventory].compareInventoryList addObjectsFromArray:_compareInventoryList];
    [self removeOverlayViews];
}
-(void)prepareData
{
    {
        NSSet *uniqueProductCategory2 = [NSSet setWithArray:[_compareInventoryList valueForKey:@"productCategory2"]];
        NSArray *arrProductCategory2 = [uniqueProductCategory2 allObjects];
        _arrProductCategory2 = [arrProductCategory2 mutableCopy];
        
        
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"" ascending:YES];//order by productcategory2 code
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
        NSArray *sortArray = [_arrProductCategory2 sortedArrayUsingDescriptors:sortDescriptors];
        _arrProductCategory2 = [sortArray mutableCopy];
    }
}
-(void)itemsDownloaded:(NSArray *)items
{
    {
        PushSync *pushSync = [[PushSync alloc]init];
        pushSync.deviceToken = [Utility deviceToken];
        [_homeModel updateItems:dbPushSyncUpdateByDeviceToken withData:pushSync];
    }
    
    
    [Utility itemsDownloaded:items];
    [self removeOverlayViews];
    [self loadViewProcess];
}
- (void)itemsFail
{
    [self removeOverlayViews];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[Utility getConnectionLostTitle]
                                                                   message:[Utility getConnectionLostMessage]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [self loadingOverlayView];
                                                              [_homeModel downloadItems:dbMaster];
                                                          }];
    
    [alert addAction:defaultAction];
    dispatch_async(dispatch_get_main_queue(),^ {
        [self presentViewController:alert animated:YES completion:nil];
    } );
}
- (void)itemsUpdated
{
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqual:@"segComparingScan"])
    {
        ComparingScanViewController *vc = [segue destinationViewController];
        vc.runningSetNo = _runningSetNo;
    }
    else
    {
        NSLog(@"prepareforsegue compareinventory");
        CompareInventoryViewController *vc = segue.destinationViewController;
        vc.index = 0;
        vc.arrProductCategory2 = _arrProductCategory2;
        vc.runningSetNo = _runningSetNo;
    }
}

-(void)removeOverlayViewConnectionFail
{
    [self removeOverlayViews];
    [self connectionFail];
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

- (void) connectionFail
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[Utility subjectNoConnection]
                                                                   message:[Utility detailNoConnection]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              //                                                              exit(0);
                                                          }];
    
    [alert addAction:defaultAction];
    dispatch_async(dispatch_get_main_queue(),^ {
        [self presentViewController:alert animated:YES completion:nil];
    } );
}
@end
