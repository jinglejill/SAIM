//
//  CustomTableViewCellReceiptShort.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 5/3/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomTableViewCellReceiptShort : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lblProduct;
@property (strong, nonatomic) IBOutlet UILabel *lblColor;
@property (strong, nonatomic) IBOutlet UILabel *lblSize;
@property (strong, nonatomic) IBOutlet UILabel *lblCash;
@property (strong, nonatomic) IBOutlet UILabel *lblCredit;
@property (strong, nonatomic) IBOutlet UILabel *lblTransfer;

@end

NS_ASSUME_NONNULL_END
