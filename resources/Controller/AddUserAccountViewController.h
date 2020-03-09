//
//  AddUserAccountViewController.h
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/27/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <UIKit/UIKit.h>
//#import "UserAccountViewController.h"
#import "UserAccount.h"

@interface AddUserAccountViewController : UIViewController<MFMailComposeViewControllerDelegate,UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *txtEmailAddress;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UIButton *btnAutoGeneratePassword;

@property (strong, nonatomic) IBOutlet UIButton *btnSave;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnBack;
@property (strong, nonatomic) IBOutlet UILabel *lblStatus;
@property (strong,nonatomic) UserAccount *userAccount;

@end
