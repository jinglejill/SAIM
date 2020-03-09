//
//  EventViewController.h
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/24/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"

@interface EventViewController : UITableViewController<HomeModelProtocol>
@property (nonatomic) enum enumAction currentAction;

- (IBAction)unwindToEventList:(UIStoryboardSegue *)segue;

@end
