//
//  ChangePasswordViewController.h
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/9/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Homemodel.h"


@interface ChangePasswordViewController : UIViewController<HomeModelProtocol,UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *txtRegisteredEmail;
@property (strong, nonatomic) IBOutlet UITextField *txtOldPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtNewPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtReEnterNewPassword;
@property (strong, nonatomic) IBOutlet UIButton *btnSave;
//@property (strong, nonatomic) IBOutlet UILabel *lblStatus;
- (IBAction)testShowSettingDeviceToken:(id)sender;


@end
