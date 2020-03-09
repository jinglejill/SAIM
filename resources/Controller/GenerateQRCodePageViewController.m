//
//  GenerateQRCodePageViewController.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 9/2/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "GenerateQRCodePageViewController.h"
#import "GenerateQRCodeViewController.h"

#import "Event.h"
#import "ProductCategory2.h"
#import "SharedGenerateQRCodePage.h"
#import "SharedProduct.h"
#import "SharedProductSales.h"
#import "ProductSales.h"
#import "ProductName.h"
#import "ProductSize.h"
#import "Color.h"
#import "PrintQRCodeViewController.h"
#import "Utility.h"
#import "EmailQRCode.h"


@interface GenerateQRCodePageViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSArray *_arrProductEvent;
    NSArray *_arrProductCategory2;
    NSInteger _currentPage;
    NSMutableArray *_mutArrQRCodeQuantity;
}
@end

@implementation GenerateQRCodePageViewController
@synthesize pageController;
@synthesize btnGenerateQR;
@synthesize btnDownload;
@synthesize fromUserMenu;


- (IBAction)unwindToGenerateQRCodePage:(UIStoryboardSegue *)segue
{
    NSString *strCurrentIndex = [NSString stringWithFormat:@"%ld",_currentPage];
    NSMutableDictionary *dicGenerateQRCodePage = [SharedGenerateQRCodePage sharedGenerateQRCodePage].dicGenerateQRCodePage;
    NSArray *arrQrCodeValue = [dicGenerateQRCodePage valueForKey:strCurrentIndex];
    if(arrQrCodeValue)
    {
        GenerateQRCodeViewController *currentVC = [self viewControllerAtIndex:_currentPage];
        currentVC.dicSectionAndItemToTag = arrQrCodeValue[0];
        currentVC.dicGenerateQRCode = arrQrCodeValue[1];
        currentVC.productNameTableList = arrQrCodeValue[2];
    }
}

- (IBAction)generateQRCode:(id)sender
{
    GenerateQRCodeViewController *currentVC = [self.pageController viewControllers][0];
    id responder = [currentVC findFirstResponder:currentVC.view];
    if(responder)
    {
        [responder resignFirstResponder];
    }
    
    
    NSMutableDictionary *dicGenerateQRCodePage = [SharedGenerateQRCodePage sharedGenerateQRCodePage].dicGenerateQRCodePage;
    if([dicGenerateQRCodePage count] == 0)
    {
        return;
    }

    
    
    [_mutArrQRCodeQuantity removeAllObjects];
    for(NSString *key in dicGenerateQRCodePage)
    {
        NSArray *arrQrCodeValue = [dicGenerateQRCodePage valueForKey:key];
        //        if(arrQrCodeValue)
        {
            NSMutableDictionary *dicSectionAndItemToTag = arrQrCodeValue[0];
            NSMutableDictionary *dicGenerateQRCode = arrQrCodeValue[1];
            NSMutableArray *productNameTableList = arrQrCodeValue[2];
            
            for(id key in dicGenerateQRCode)
            {
                NSString *quantity = [dicGenerateQRCode valueForKey:key];
                NSArray *arrSectionAndItem = [dicSectionAndItemToTag allKeysForObject:key];
                
                NSString *sectionAndItem = arrSectionAndItem[0];
                NSArray *arrPartSectionAndItem = [sectionAndItem componentsSeparatedByString:@";"];
                
                NSInteger section = [[arrPartSectionAndItem objectAtIndex: 0] integerValue];
                NSInteger item = [[arrPartSectionAndItem objectAtIndex: 1] integerValue];
                
                
                NSArray *productNameTable = productNameTableList[section];
                ProductName *productName = productNameTable[0];
                NSArray *colorList = productNameTable[1];
                NSArray *sizeList = productNameTable[2];
                NSInteger sizeNum = [sizeList count];
                
                Color *color = colorList[(item/(sizeNum+1))-1];
                ProductSize *productSize = sizeList[(item%(sizeNum+1))-1];
                
                [_mutArrQRCodeQuantity addObject:@[productName,color,productSize,quantity]];
            }
        }
    }
    [self performSegueWithIdentifier:@"segPrintQRCode" sender:self];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segPrintQRCode"])
    {
        GenerateQRCodeViewController *currentVC = [self.pageController viewControllers][0];
//        GenerateQRCodeViewController *currentVC = [self viewControllerAtIndex:_currentPage];
        PrintQRCodeViewController *vc = segue.destinationViewController;
        vc.mutArrQRCodeQuantity = _mutArrQRCodeQuantity;
        vc.strManufacturingDate = currentVC.txtManufacturingDate.text;
    }
}

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
    
    
    if(fromUserMenu)
    {
        [self.navigationItem setRightBarButtonItem:nil];
        [self.navigationItem setRightBarButtonItems:@[btnDownload]];
    }
        
    
    _mutArrQRCodeQuantity = [[NSMutableArray alloc]init];
    [self loadViewProcess];
}

-(void)loadViewProcess
{
    
}
- (GenerateQRCodeViewController *)viewControllerAtIndex:(NSUInteger)index
{
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    GenerateQRCodeViewController * initialViewController = [storyboard instantiateViewControllerWithIdentifier:@"GenerateQRCodeViewController"];
    initialViewController.index = index;
    initialViewController.arrProductCategory2 = _arrProductCategory2;
    initialViewController.arrProductEvent = _arrProductEvent;
    _currentPage = index;
    
    
    return initialViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(GenerateQRCodeViewController *)viewController index];
    
    if (index == 0) {
        return nil;
    }
    
    // Decrease the index by 1 to return
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(GenerateQRCodeViewController *)viewController index];
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

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    GenerateQRCodeViewController *previousVC = (GenerateQRCodeViewController*)(previousViewControllers[[previousViewControllers count]-1]);
    GenerateQRCodeViewController *currentVC = [pageViewController viewControllers][0];
    
    if(previousVC.strMFD)
    {
        currentVC.txtManufacturingDate.text = previousVC.strMFD;
    }
    NSMutableDictionary *dicGenerateQRCodePage = [SharedGenerateQRCodePage sharedGenerateQRCodePage].dicGenerateQRCodePage;
    NSString *strCurrentIndex = [NSString stringWithFormat:@"%ld",currentVC.index];
    NSArray *arrQrCodeValue = [dicGenerateQRCodePage valueForKey:strCurrentIndex];
    if(arrQrCodeValue)
    {
        currentVC.dicSectionAndItemToTag = arrQrCodeValue[0];
        currentVC.dicGenerateQRCode = arrQrCodeValue[1];
    }
    
    [currentVC.colViewSummaryTable reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    
    NSMutableArray *productSalesList = [SharedProductSales sharedProductSales].productSalesList;
    for(ProductSales *item in productSalesList)
    {
        ProductName *productName = [ProductName getProductName:item.productNameID];
        item.productCategory2 = productName.productCategory2;
    }
    NSSet *uniqueProductCategory2 = [NSSet setWithArray:[productSalesList valueForKey:@"productCategory2"]];
    _arrProductCategory2 = [uniqueProductCategory2 allObjects];

    NSMutableArray *productCategory2List = [[NSMutableArray alloc]init];
    for(NSString *item in _arrProductCategory2)
    {
        ProductCategory2 *productCategory2 = [Utility getProductCategory2:item];
        [productCategory2List addObject:productCategory2];
    }
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"orderNo" ascending:YES];//order by orderNo
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortArray = [productCategory2List sortedArrayUsingDescriptors:sortDescriptors];
    
    NSMutableArray *arrProductCategory2Code = [[NSMutableArray alloc]init];
    for(ProductCategory2 *item in sortArray)
    {
        [arrProductCategory2Code addObject:item.code];
    }
    _arrProductCategory2 = arrProductCategory2Code;

    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageController.dataSource = self;
    self.pageController.delegate = self;
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
    GenerateQRCodeViewController * initialViewController = [storyboard instantiateViewControllerWithIdentifier:@"GenerateQRCodeViewController"];
    initialViewController.index = 0;
    _currentPage = 0;
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
    
    static NSInteger previousPage = 0;
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    if (previousPage != page) {
        // Page has changed, do your thing!
        
        // ...
        // Finally, update previous page
        previousPage = page;
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

- (IBAction)backButtonClicked:(id)sender {
    [[SharedGenerateQRCodePage sharedGenerateQRCodePage].dicGenerateQRCodePage removeAllObjects];
//    [SharedGenerateQRCodePage sharedGenerateQRCodePage].dicGenerateQRCodePage = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)emailQRCode:(id)sender
{
    GenerateQRCodeViewController *currentVC = [self.pageController viewControllers][0];
    id responder = [currentVC findFirstResponder:currentVC.view];
    if(responder)
    {
        [responder resignFirstResponder];
    }
    
    
    NSMutableDictionary *dicGenerateQRCodePage = [SharedGenerateQRCodePage sharedGenerateQRCodePage].dicGenerateQRCodePage;
    if([dicGenerateQRCodePage count] == 0)
    {
        return;
    }
    
    
    
    NSMutableArray *emailQRCodeList = [[NSMutableArray alloc]init];
    
    for(NSString *key in dicGenerateQRCodePage)
    {
        NSArray *arrQrCodeValue = [dicGenerateQRCodePage valueForKey:key];
        //        if(arrQrCodeValue)
        {
            NSMutableDictionary *dicSectionAndItemToTag = arrQrCodeValue[0];
            NSMutableDictionary *dicGenerateQRCode = arrQrCodeValue[1];
            NSMutableArray *productNameTableList = arrQrCodeValue[2];
            
            for(id key in dicGenerateQRCode)
            {
                NSString *quantity = [dicGenerateQRCode valueForKey:key];
                NSArray *arrSectionAndItem = [dicSectionAndItemToTag allKeysForObject:key];
                
                NSString *sectionAndItem = arrSectionAndItem[0];
                NSArray *arrPartSectionAndItem = [sectionAndItem componentsSeparatedByString:@";"];
                
                NSInteger section = [[arrPartSectionAndItem objectAtIndex: 0] integerValue];
                NSInteger item = [[arrPartSectionAndItem objectAtIndex: 1] integerValue];
                
                
                NSArray *productNameTable = productNameTableList[section];
                ProductName *productName = productNameTable[0];
                NSArray *colorList = productNameTable[1];
                NSArray *sizeList = productNameTable[2];
                NSInteger sizeNum = [sizeList count];
                
                Color *color = colorList[(item/(sizeNum+1))-1];
                ProductSize *productSize = sizeList[(item%(sizeNum+1))-1];
                ProductSales *productSales = [ProductSales getProductSalesFromProductNameID:productName.productNameID color:color.code size:productSize.code productSalesSetID:@"0"];
                GenerateQRCodeViewController *currentVC = [self.pageController viewControllers][0];
                NSString *mfd = [Utility formatDate:currentVC.txtManufacturingDate.text fromFormat:@"dd/MM/yyyy" toFormat:@"yyyyMMdd"];
                NSString *codeWithoutNo = [NSString stringWithFormat:@"%@%@%@%@%@%@",productName.productCategory2,productName.productCategory1,productName.code,color.code,productSize.code,mfd];
                EmailQRCode *emailQRCode = [[EmailQRCode alloc]init];
                emailQRCode.code = codeWithoutNo;
                emailQRCode.productName = productName.name;
                emailQRCode.color = color.name;
                emailQRCode.size = productSize.sizeLabel;
                emailQRCode.price = productSales.price;
                emailQRCode.qty = quantity;
                [emailQRCodeList addObject:emailQRCode];
            }
        }
    }
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_productName" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_color" ascending:YES];
    NSSortDescriptor *sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:@"_size" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2,sortDescriptor3, nil];
    
    NSArray *sortArray = [emailQRCodeList sortedArrayUsingDescriptors:sortDescriptors];
//    NSString *fileName = [NSString stringWithFormat:@"%@QRCode%@.xls",[Utility setting:vBrand],[Utility currentDateTimeStringForDB]];
    NSString *strCurrentDate = [Utility dateToString:[Utility GMTDate:[NSDate date]] toFormat:@"yyyyMMdd_HHmmss"];
    NSString *fileName = [NSString stringWithFormat:@"%@QRCode%@.xls",[Utility setting:vBrand],strCurrentDate];
    NSString *downloadLink = [NSString stringWithFormat:@"%@/%@",[Utility domainName],fileName];
    [_homeModel updateItems:dbEmailQRCode withData:@[fileName,sortArray]];
    
    
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Download link"
                                                                   message:downloadLink
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Copy link" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
                                    {
                                        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                        pasteboard.string = downloadLink;
                                        
                                        
                                        
                                    }];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)itemsUpdated
{
    
}
@end
