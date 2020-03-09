//
//  ProductCategory2ViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 1/10/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"


@interface ProductCategory2ViewController : UITableViewController<HomeModelProtocol>
@property (strong, nonatomic) IBOutlet UITableView *tableViewList;
- (IBAction)unwindToProductCategory2:(UIStoryboardSegue *)segue;
- (IBAction)addItem:(id)sender;
- (IBAction)doneButtonClicked:(id)sender;

@end
