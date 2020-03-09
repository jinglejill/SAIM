//
//  PasscodeViewController.h
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/9/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"


@interface PasscodeViewController : UIViewController<UITextFieldDelegate,HomeModelProtocol>
@property (strong, nonatomic) IBOutlet UITextField *txtPasscode;
@property (strong, nonatomic) IBOutlet UIButton *btnAccess;
@property (strong, nonatomic) IBOutlet UILabel *lblStatus;
@end
