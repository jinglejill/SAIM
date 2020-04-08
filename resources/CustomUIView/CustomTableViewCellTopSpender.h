//
//  CustomTableViewCellTopSpender.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 31/3/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomTableViewCellTopSpender : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lblTelephone;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblSales;
@property (strong, nonatomic) IBOutlet UILabel *lblOrders;
@property (strong, nonatomic) IBOutlet UILabel *lblTelLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lblTelLabelWidth;

@end

NS_ASSUME_NONNULL_END
