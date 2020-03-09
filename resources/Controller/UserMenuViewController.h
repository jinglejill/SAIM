//
//  UserMenuViewController.h
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/23/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "HomeModel.h"


@interface UserMenuViewController : UITableViewController<HomeModelProtocol>
- (IBAction)unwindToUserMenu:(UIStoryboardSegue *)segue;
@property (nonatomic) BOOL menuExtra;
@end
