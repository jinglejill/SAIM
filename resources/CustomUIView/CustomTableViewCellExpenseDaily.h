//
//  CustomTableViewCellExpenseDaily.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/3/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomTableViewCellExpenseDaily : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lblItem;

@property (strong, nonatomic) IBOutlet UILabel *lblAmount;
@end

NS_ASSUME_NONNULL_END
