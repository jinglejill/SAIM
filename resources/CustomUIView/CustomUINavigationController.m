//
//  CustomUINavigationController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/20/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "CustomUINavigationController.h"
#import "AdminMenuViewController.h"
#import "SalesSummaryViewController.h"
#import "ChartTabBarController.h"
#import "ChartSalesByItemViewController.h"
#import "ChartSalesByZoneViewController.h"
#import "ReceiptSummary2ViewController.h"
#import "ComparingScanViewController.h"
#import "EventInventoryScanViewController.h"
#import "EventProductDeleteScanViewController.h"
#import "MainInventoryScanViewController.h"
#import "PreOrderScanPostViewController.h"
#import "PreOrderScanUnpostViewController.h"
#import "PreOrderScanViewController.h"
#import "ProductDeleteScanViewController.h"
#import "SalesScanAddScanViewController.h"
#import "SalesScanViewController.h"
#import "TrackingNoScanViewController.h"



#define tYellow          [UIColor colorWithRed:251/255.0 green:188/255.0 blue:5/255.0 alpha:1]
//#define tTheme          [UIColor colorWithRed:196/255.0 green:164/255.0 blue:168/255.0 alpha:1]
#define tTheme          [UIColor colorWithRed:230/255.0 green:171/255.0 blue:188/255.0 alpha:1]

@interface CustomUINavigationController ()

@end
extern BOOL globalRotateFromSeg;
@implementation CustomUINavigationController
- (void)loadView
{
    [super loadView];
    UIColor *color = tTheme;
    self.navigationBar.barTintColor = color;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown | UIInterfaceOrientationMaskLandscape);
}
- (BOOL)shouldAutorotate {
    id currentViewController = self.topViewController;
    
    if ([currentViewController isKindOfClass:[SalesSummaryViewController class]] && !globalRotateFromSeg)
    {
        globalRotateFromSeg = NO;
        return NO;
    }
    else if ([currentViewController isKindOfClass:[ChartTabBarController class]] && !globalRotateFromSeg)
    {
        globalRotateFromSeg = NO;
        return NO;
    }
    else if ([currentViewController isKindOfClass:[ChartSalesByItemViewController class]] && !globalRotateFromSeg)
    {
        globalRotateFromSeg = NO;
        return NO;
    }
    else if ([currentViewController isKindOfClass:[ChartSalesByZoneViewController class]] && !globalRotateFromSeg)
    {
        globalRotateFromSeg = NO;
        return NO;
    }
    else if ([currentViewController isKindOfClass:[ReceiptSummary2ViewController class]])
        return NO;
    
    else if ([currentViewController isKindOfClass:[ComparingScanViewController class]])
        return NO;
    else if ([currentViewController isKindOfClass:[EventInventoryScanViewController class]])
        return NO;
    else if ([currentViewController isKindOfClass:[EventProductDeleteScanViewController class]])
        return NO;
    else if ([currentViewController isKindOfClass:[MainInventoryScanViewController class]])
        return NO;
    else if ([currentViewController isKindOfClass:[PreOrderScanPostViewController class]])
        return NO;
    else if ([currentViewController isKindOfClass:[PreOrderScanUnpostViewController class]])
        return NO;
    else if ([currentViewController isKindOfClass:[PreOrderScanViewController class]])
        return NO;
    else if ([currentViewController isKindOfClass:[ProductDeleteScanViewController class]])
        return NO;
    else if ([currentViewController isKindOfClass:[SalesScanAddScanViewController class]])
        return NO;
    else if ([currentViewController isKindOfClass:[SalesScanViewController class]])
        return NO;
    else if ([currentViewController isKindOfClass:[TrackingNoScanViewController class]])
        return NO;
    
    
    
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
