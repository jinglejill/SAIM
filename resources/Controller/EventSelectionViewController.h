//
//  EventInventoryMainViewController.h
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 8/9/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"

@interface EventSelectionViewController : UITableViewController<HomeModelProtocol>
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnMenuExtra;
- (IBAction)menuExtraClicked:(id)sender;

- (IBAction)unwindToEventSelection:(UIStoryboardSegue *)segue;
@end
