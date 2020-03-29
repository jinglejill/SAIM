//
//  CustomTableViewCellDiscount.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 17/3/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomTableViewCellDiscount : UITableViewCell
@property (strong, nonatomic) IBOutlet UITextField *txtDiscount;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segConBahtPercent;

@end

NS_ASSUME_NONNULL_END
