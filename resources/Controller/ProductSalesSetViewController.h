//
//  ProductSalesSetViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/23/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"
#import "CustomUITableViewController.h"

@interface ProductSalesSetViewController : UITableViewController<HomeModelProtocol,UITextFieldDelegate>
- (IBAction)unwindToEventPrice:(UIStoryboardSegue *)segue;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnCopy;
@property (nonatomic) BOOL fromEventMenu;
@property (strong, nonatomic) NSString *productSalesSetID;

- (IBAction)copyProductSalesSet:(id)sender;



@end
