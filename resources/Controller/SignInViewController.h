//
//  SignInViewController.h
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/29/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserAccount.h"
#import "HomeModel.h"


@interface SignInViewController : UIViewController<UITextFieldDelegate,HomeModelProtocol>
@property (strong, nonatomic) IBOutlet UITextField *txtEmailAddress;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UIButton *btnSignIn;
@property (strong, nonatomic) IBOutlet UIButton *btnForgotPassword;
@property (strong, nonatomic) IBOutlet UIButton *btnChangePassword;
@property (strong, nonatomic) IBOutlet UILabel *lblStatus;

//@property (strong,nonatomic) UserAccount *userAccount;

- (IBAction)unwindToSignIn:(UIStoryboardSegue *)segue;
@end
