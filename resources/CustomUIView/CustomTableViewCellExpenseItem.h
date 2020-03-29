//
//  CustomTableViewCellExpenseItem.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/3/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomTableViewCellExpenseItem : UITableViewCell
@property (strong, nonatomic) IBOutlet UIButton *btnOftenUse1;
@property (strong, nonatomic) IBOutlet UIButton *btnOftenUse2;
@property (strong, nonatomic) IBOutlet UIButton *btnOftenUse3;
@property (strong, nonatomic) IBOutlet UITextField *txtName;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *btnOftenUse1Width;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *btnOftenUse2Width;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *btnOftenUse3Width;

@end

NS_ASSUME_NONNULL_END
