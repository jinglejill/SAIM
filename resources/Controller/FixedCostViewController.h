//
//  FixCostViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/24/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"
#import "Event.h"


@interface FixedCostViewController : UITableViewController<HomeModelProtocol>
{
    UITextField *txtRent;
    UITextField *txtTransportation;
    UITextField *txtStaff;
    UITextField *txtOther;
    
}
@property (strong, nonatomic) IBOutlet UITableView *tableViewFixedCost;
@property (strong, nonatomic) Event *event;
- (IBAction)unwindToFixedCost:(UIStoryboardSegue *)segue;
- (IBAction)addLabel:(id)sender;
- (IBAction)doneButtonClicked:(id)sender;
@end
