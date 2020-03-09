//
//  SizeViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 1/17/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"

@interface ProductSizeViewController : UITableViewController<HomeModelProtocol>
@property (strong, nonatomic) IBOutlet UITableView *tableViewList;
- (IBAction)unwindToColor:(UIStoryboardSegue *)segue;
- (IBAction)addItem:(id)sender;
- (IBAction)doneButtonClicked:(id)sender;

- (IBAction)sortItem:(id)sender;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnCancelButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnDoneButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnSortButton;

@end
