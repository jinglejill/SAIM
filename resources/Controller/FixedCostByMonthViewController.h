//
//  FixedCostByMonthViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 18/3/2564 BE.
//  Copyright © 2564 BE Thidaporn Kijkamjai. All rights reserved.
//

#import "CustomViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FixedCostByMonthViewController : CustomViewController
@property (weak, nonatomic) IBOutlet UITableView *tbvData;
- (IBAction)unwindToFixedCostByMonth:(UIStoryboardSegue *)segue;
- (IBAction)addYearMonth:(id)sender;

@end

NS_ASSUME_NONNULL_END
