//
//  EventInventorySummaryPageViewController.m
//  SAIM_UPDATING
//
//  Created by Thidaporn Kijkamjai on 4/10/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "EventInventorySummaryPageViewController.h"
#import "SharedProduct.h"
#import "SharedProductSize.h"
#import "SharedProductName.h"
#import "SharedProductCategory2.h"
#import "SharedProductCategory1.h"
#import "SharedColor.h"

#import "Product.h"
#import "ProductWithQuantity.h"
#import "Utility.h"
#import "SharedSelectedEvent.h"
#import "EventInventorySummaryViewController.h"
#import "ProductName.h"


@interface EventInventorySummaryPageViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
//    NSArray *_productWithQuantity;
//    NSMutableArray *_mutArrProductWithQuantity;
//    NSMutableArray *_arrProductCategory2;
    
    NSMutableArray *productCategory2List;
    NSMutableArray *productNameList;
    NSMutableArray *productNameColorList;
    NSMutableArray *productNameSizeList;
    NSMutableArray *productList;
    NSMutableArray *colorList;
    NSMutableArray *productSizeList;
    BOOL secondLoad;
}
@end

@implementation EventInventorySummaryPageViewController
@synthesize btnAllOrRemaining;


- (void)loadView
{
    [super loadView];
    
    {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);        
    }
    btnAllOrRemaining.title = @"All";
}

- (EventInventorySummaryViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    EventInventorySummaryViewController * initialViewController = [storyboard instantiateViewControllerWithIdentifier:@"EventInventorySummaryViewController"];
    initialViewController.index = index;
    initialViewController.productCategory2List = productCategory2List;
    initialViewController.productNameList = productNameList;
    initialViewController.productNameColorList = productNameColorList;
    initialViewController.productNameSizeList = productNameSizeList;
    initialViewController.productList = productList;
    initialViewController.colorList = colorList;
    initialViewController.productSizeList = productSizeList;
    
    return initialViewController;
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(EventInventorySummaryViewController *)viewController index];
    
    if (index == 0) {
        return nil;
    }
    
    // Decrease the index by 1 to return
    index--;
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(EventInventorySummaryViewController *)viewController index];
    
    index++;
    
    if (index == [productCategory2List count]) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    NSLog(@"number of item in page indicator:%ld",[productCategory2List count]);
    return [productCategory2List count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return 0;
}

//-(void)queryProductWithQuantity
//{
//    //query data
//    //    _productWithQuantity = [SharedProductWithQuantity sharedProductWithQuantity].productWithQuantityList;
//    //เปลี่บยน status p->i, เรียงลำดับ, สร้าง dictionary ใส่ value คือจำนวน key คือ productidgroup
//    
//    
//    NSMutableArray *productList = [SharedProduct sharedProduct].productList;
//    NSMutableArray *productForQuantityList = [[NSMutableArray alloc]init];
//    if([btnAllOrRemaining.title isEqualToString:@"Remaining"])
//    {
//        for(Product *item in productList)
//        {
//            Product *product = [item copy];
//            product.productIDGroup = [Utility getProductIDGroup:item];
//            
//            if([item.status isEqualToString:@"P"])
//            {
//                product.status = @"I";
//            }
//            [productForQuantityList addObject:product];
//        }
//    }
//    else if([btnAllOrRemaining.title isEqualToString:@"All"])
//    {
//        for(Product *item in productList)
//        {
//            item.productIDGroup = [Utility getProductIDGroup:item];
//        }
//        productForQuantityList = productList;
//    }
//    
//    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_eventID" ascending:YES];
//    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_status" ascending:YES];
//    NSSortDescriptor *sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:@"_productIDGroup" ascending:YES];
//    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2,sortDescriptor3, nil];
//    NSArray *productSort = [productForQuantityList sortedArrayUsingDescriptors:sortDescriptors];
//    
//    NSMutableArray *groupHead = [[NSMutableArray alloc]init];
//    NSMutableArray *groupCount = [[NSMutableArray alloc]init];
//    NSInteger countData = 0;
//    BOOL firstItem = YES;
//    Product *previousProduct = [[Product alloc]init];
//    for(Product *item in productSort)
//    {
//        if(!((item.eventID == previousProduct.eventID) &&
//             [item.status isEqualToString:previousProduct.status] &&
//             [item.productIDGroup isEqualToString:previousProduct.productIDGroup]))
//        {
//            previousProduct = item;
//            [groupHead addObject:item];
//            if(!firstItem)
//            {
//                [groupCount addObject:[NSString stringWithFormat:@"%ld",(long)countData]];
//            }
//            else
//            {
//                firstItem = NO;
//            }
//            
//            countData = 1;
//        }
//        else
//        {
//            countData += 1;
//        }
//    }
//    [groupCount addObject:[NSString stringWithFormat:@"%ld",(long)countData]];
//    
//    
//    _mutArrProductWithQuantity = [[NSMutableArray alloc]init];
//    for(int i=0; i<[groupHead count]; i++)
//    {
//        Product *product = groupHead[i];
//        NSString *strEventID = [NSString stringWithFormat:@"%ld",product.eventID];
//        
//        NSString *quantity = groupCount[i];
//        NSString *productNameGroup = [NSString stringWithFormat:@"%@%@%@",product.productCategory2,product.productCategory1,product.productName];
//        ProductWithQuantity *productWithQuantity = [[ProductWithQuantity alloc]init];
//        productWithQuantity.productName = [ProductName getNameWithProductNameGroup:productNameGroup];
//        productWithQuantity.color = [Utility getColorName:product.color];
//        productWithQuantity.size = product.size;
//        productWithQuantity.quantity = quantity;
//        productWithQuantity.productIDGroup = product.productIDGroup;
//        productWithQuantity.eventID = strEventID;
//        productWithQuantity.status = product.status;
//        productWithQuantity.productCategory2 = product.productCategory2;
//        
//        [_mutArrProductWithQuantity addObject:productWithQuantity];
//    }
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //hide button check
    _btnCheck.tintColor = UIColor.clearColor;
    _btnCheck.enabled = NO;
    
    
//    [self pagingProcess];
    [self loadingOverlayView];
    _homeModel = [[HomeModel alloc] init];
    _homeModel.delegate = self;
    
    NSString *strEventID = [NSString stringWithFormat:@"%ld",[SharedSelectedEvent sharedSelectedEvent].event.eventID];
    [_homeModel downloadItems:dbMainInventorySummary condition:@[strEventID,@"0"]];
}

- (void)itemsDownloaded:(NSArray *)items
{
    [self removeOverlayViews];
    int i=0;
    productCategory2List = items[i++];
    productNameList = items[i++];
    productNameColorList = items[i++];
    productNameSizeList = items[i++];
    productList = items[i++];
    colorList = items[i++];
    productSizeList = items[i++];

    [self pagingProcess];
}

- (void)pagingProcess
{
//    [self queryProductWithQuantity];
//    NSString *strEventID = [NSString stringWithFormat:@"%ld",[SharedSelectedEvent sharedSelectedEvent].event.eventID];
//    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_eventID = %@ and _status = %@",strEventID,@"I"];
//    _productWithQuantity = [_mutArrProductWithQuantity filteredArrayUsingPredicate:predicate1];
//    
//    
//    NSSet *uniqueProductCategory2 = [NSSet setWithArray:[_productWithQuantity valueForKey:@"productCategory2"]];
//    NSArray *arrProductCategory2 = [uniqueProductCategory2 allObjects];
//    _arrProductCategory2 = [arrProductCategory2 mutableCopy];
//    
//    
//    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"" ascending:YES];//order by productcategory2 code
//    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
//    NSArray *sortArray = [_arrProductCategory2 sortedArrayUsingDescriptors:sortDescriptors];
//    _arrProductCategory2 = [sortArray mutableCopy];
    
    
    
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
    EventInventorySummaryViewController * initialViewController = [storyboard instantiateViewControllerWithIdentifier:@"EventInventorySummaryViewController"];
    initialViewController.index = 0;
    initialViewController.productCategory2List = productCategory2List;
    initialViewController.productNameList = productNameList;
    initialViewController.productNameColorList = productNameColorList;
    initialViewController.productNameSizeList = productNameSizeList;
    initialViewController.productList = productList;
    initialViewController.colorList = colorList;
    initialViewController.productSizeList = productSizeList;
    
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
//    NSLog(@"subview before add count:%ld",[self.view.subviews count]);
    if(secondLoad)
    {
        [self.view.subviews[[self.view.subviews count]-1] removeFromSuperview];
    }
    [[self view] addSubview:[self.pageController view]];
//    NSLog(@"subview after add count:%ld",[self.view.subviews count]);
    [self.pageController didMoveToParentViewController:self];
}

- (IBAction)compareInventory:(id)sender
{
    [self performSegueWithIdentifier:@"segCompareInventory" sender:self];
}

- (IBAction)allOrRemaining:(id)sender
{
//    if([btnAllOrRemaining.title isEqualToString:@"All"])
//    {
//        btnAllOrRemaining.title = @"Remaining";
//        [self pagingProcess];
//    }
//    else if([btnAllOrRemaining.title isEqualToString:@"Remaining"])
//    {
//        btnAllOrRemaining.title = @"All";
//        [self pagingProcess];
//    }
    if([btnAllOrRemaining.title isEqualToString:@"All"])
    {
        secondLoad = YES;
        btnAllOrRemaining.title = @"Remaining";
        [self loadingOverlayView];
        NSString *strEventID = [NSString stringWithFormat:@"%ld",[SharedSelectedEvent sharedSelectedEvent].event.eventID];
        [_homeModel downloadItems:dbMainInventorySummary condition:@[strEventID,@"1"]];
    
    }
    else if([btnAllOrRemaining.title isEqualToString:@"Remaining"])
    {
        secondLoad = YES;
        btnAllOrRemaining.title = @"All";
        [self loadingOverlayView];
        NSString *strEventID = [NSString stringWithFormat:@"%ld",[SharedSelectedEvent sharedSelectedEvent].event.eventID];
        [_homeModel downloadItems:dbMainInventorySummary condition:@[strEventID,@"0"]];
        
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
@end
