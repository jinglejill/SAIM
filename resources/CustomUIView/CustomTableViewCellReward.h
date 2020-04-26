//
//  CustomTableViewCellReward.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 18/4/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomTableViewCellReward : UITableViewCell
@property (strong, nonatomic) IBOutlet UITextField *txtTelephoneNo;
@property (strong, nonatomic) IBOutlet UIButton *btnPost;
@property (strong, nonatomic) IBOutlet UILabel *lblResult;
@property (strong, nonatomic) IBOutlet UIButton *btnRegister;
@property (strong, nonatomic) IBOutlet UIButton *btnRedeem;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *btnRegisterLeading;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *btnRegisterWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *btnRedeemLeading;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *btnRedeemWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lblResultWidth;

@end

NS_ASSUME_NONNULL_END
