//
//  ExpenseDailyViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/3/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"

NS_ASSUME_NONNULL_BEGIN
 
@interface ExpenseDailyViewController : CustomViewController
@property (strong, nonatomic) IBOutlet UITableView *tbvData;
@property (nonatomic) NSInteger eventID;
@property (strong, nonatomic) NSString *inputDate;
@property (strong, nonatomic) NSMutableArray *expenseDailyList;
- (IBAction)addExpense:(id)sender;
- (IBAction)backButtonClicked:(id)sender;

@end

NS_ASSUME_NONNULL_END
