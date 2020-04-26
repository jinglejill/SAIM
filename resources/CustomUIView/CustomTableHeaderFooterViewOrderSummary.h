//
//  CustomTableHeaderFooterViewOrderSummary.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 16/3/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomTableHeaderFooterViewOrderSummary : UITableViewHeaderFooterView
@property (strong, nonatomic) IBOutlet UILabel *lblTotal;
@property (strong, nonatomic) IBOutlet UILabel *lblShippingFee;
@property (strong, nonatomic) IBOutlet UILabel *lblDiscount;
@property (strong, nonatomic) IBOutlet UILabel *lblRedeemedPointValue;
@property (strong, nonatomic) IBOutlet UILabel *lblAfterDiscount;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lblRedeemedPointValueLabelHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lblRedeemedPointValueHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lblRedeemedPointValueTop;
@property (strong, nonatomic) IBOutlet UIButton *btnRemoveRedeemedValue;

@end

NS_ASSUME_NONNULL_END
