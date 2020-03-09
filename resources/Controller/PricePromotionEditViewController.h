//
//  PricePromotionEditViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/29/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"

@interface PricePromotionEditViewController : UITableViewController<HomeModelProtocol>
{
    UITextField *txtPricePromotion;
    
}

@property (strong, nonatomic) NSString *strPricePromotion;
@property (strong, nonatomic) NSMutableArray *arrProductSalesID;
@property (strong, nonatomic) NSArray *productSalesList;
@property (nonatomic) BOOL edit;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnDone;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnCancel;
@end
