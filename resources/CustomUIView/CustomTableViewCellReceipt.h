//
//  CustomTableViewCellReceipt.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 4/3/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomTableViewCellReceipt : UITableViewCell
@property (strong, nonatomic) IBOutlet UIButton *btnReceipt;
@property (strong, nonatomic) IBOutlet UILabel *lblReceipt;
@property (strong, nonatomic) IBOutlet UIButton *btnPostCustomer;
@property (strong, nonatomic) IBOutlet UIButton *btnDelete;
@property (strong, nonatomic) IBOutlet UILabel *lblCash;
@property (strong, nonatomic) IBOutlet UILabel *lblCredit;
@property (strong, nonatomic) IBOutlet UILabel *lblTransfer;
@property (strong, nonatomic) IBOutlet UILabel *lblTotal;
@property (strong, nonatomic) IBOutlet UILabel *lblShippingFee;
@property (strong, nonatomic) IBOutlet UILabel *lblDiscount;
@property (strong, nonatomic) IBOutlet UILabel *lblAfterDiscount;
@property (strong, nonatomic) IBOutlet UILabel *lblDiscountReason;
@property (strong, nonatomic) IBOutlet UITextField *txtRemark;
@property (strong, nonatomic) IBOutlet UILabel *lblDiscountLabel;
@property (strong, nonatomic) IBOutlet UITableView *tbvData;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tbvDataHeight;
@property (strong, nonatomic) IBOutlet UILabel *lblReceiptLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lblReceiptLabelWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lblDiscountReasonHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *btnDeleteWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *btnDeteteTrailing;
@property (strong, nonatomic) IBOutlet UILabel *lblEventLabel;
@property (strong, nonatomic) IBOutlet UILabel *lblEvent;
@property (strong, nonatomic) IBOutlet UILabel *lblRedeemedValue;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lblRedeemedValueTop;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lblRedeemedValueHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lblRedeemedValueLabelHeight;
@property (strong, nonatomic) IBOutlet UILabel *lblEarnedPointDot;

@end

NS_ASSUME_NONNULL_END
