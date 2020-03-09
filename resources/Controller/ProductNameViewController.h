//
//  ProductNameViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 3/5/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"

@interface ProductNameViewController : UITableViewController<HomeModelProtocol,UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableViewList;
- (IBAction)unwindToProductName:(UIStoryboardSegue *)segue;
- (IBAction)addItem:(id)sender;
- (IBAction)doneButtonClicked:(id)sender;

@property (strong, nonatomic) NSString *productCategory2;
@property (strong, nonatomic) NSString *productCategory1;

@end
