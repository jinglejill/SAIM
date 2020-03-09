//
//  CustomTableViewCellReceiptProductItem.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 5/3/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomTableViewCellReceiptProductItem : UITableViewCell
@property (strong, nonatomic) IBOutlet UIButton *btnProduct;
@property (strong, nonatomic) IBOutlet UILabel *lblPrice;

@end

NS_ASSUME_NONNULL_END
