//
//  ForgotPasswordViewController.h
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/9/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"

@interface ForgotPasswordViewController : UIViewController<HomeModelProtocol,UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *txtRegisteredEmail;
@property (strong, nonatomic) IBOutlet UIButton *btnSendEmail;
@property (strong, nonatomic) IBOutlet UILabel *lblStatus;

@end
