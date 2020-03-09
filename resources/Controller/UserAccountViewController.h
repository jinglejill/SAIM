//
//  UserAccountViewController.h
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/9/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <UIKit/UIKit.h>
#import "HomeModel.h"

@interface UserAccountViewController : UITableViewController<HomeModelProtocol,MFMailComposeViewControllerDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnAdd;
@property (nonatomic) enum enumAction currentAction;

- (IBAction)unwindToUserAccount:(UIStoryboardSegue *)segue;

//- (IBAction)addUser:(id)sender;


@end
