//
//  ColorViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 1/15/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"

@interface ColorViewController : UITableViewController<HomeModelProtocol>
@property (strong, nonatomic) IBOutlet UITableView *tableViewList;
- (IBAction)unwindToColor:(UIStoryboardSegue *)segue;
- (IBAction)addItem:(id)sender;
- (IBAction)doneButtonClicked:(id)sender;


@end
