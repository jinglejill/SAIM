//
//  ChangePasscodeViewController.h
//  SAIM_UPDATING
//
//  Created by Thidaporn Kijkamjai on 4/30/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Homemodel.h"


@interface ChangePasscodeViewController : UIViewController<HomeModelProtocol,UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *txtRegisteredEmail;
@property (strong, nonatomic) IBOutlet UITextField *txtOldPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtNewPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtReEnterNewPassword;
@property (strong, nonatomic) IBOutlet UIButton *btnSave;
- (IBAction)resetPasscode:(id)sender;

@end
