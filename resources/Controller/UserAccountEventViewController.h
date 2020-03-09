//
//  UserAccountEventViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 9/10/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"

@interface UserAccountEventViewController : UITableViewController<HomeModelProtocol>
- (IBAction)unwindToUserAccountEvent:(UIStoryboardSegue *)segue;
- (IBAction)saveUserAccountEvent:(id)sender;

@end
