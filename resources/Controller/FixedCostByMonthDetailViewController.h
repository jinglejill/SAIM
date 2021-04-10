//
//  FixedCostByMonthDetailViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 23/3/2564 BE.
//  Copyright © 2564 BE Thidaporn Kijkamjai. All rights reserved.
//

#import "CustomViewController.h"
#import "YearMonth.h"

NS_ASSUME_NONNULL_BEGIN

@interface FixedCostByMonthDetailViewController : CustomViewController
@property (weak, nonatomic) IBOutlet UITableView *tbvData;
@property (weak, nonatomic) YearMonth *yearMonth;
- (IBAction)addYearMonthCost:(id)sender;
@end

NS_ASSUME_NONNULL_END
