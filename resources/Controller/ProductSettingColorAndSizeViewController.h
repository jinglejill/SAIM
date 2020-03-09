//
//  ProductSettingColorAndSizeViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 3/8/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"
#import "ProductName.h"

@interface ProductSettingColorAndSizeViewController : UITableViewController<HomeModelProtocol>
- (IBAction)unwindToProductSettingColorAndSize:(UIStoryboardSegue *)segue;
//- (IBAction)saveUserAccountEvent:(id)sender;
- (IBAction)doneButtonClicked:(id)sender;
@property (strong, nonatomic) ProductName *productName;
- (IBAction)backButtonClicked:(id)sender;

@end
