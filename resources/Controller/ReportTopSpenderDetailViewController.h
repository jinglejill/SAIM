//
//  ReportTopSpenderDetailViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 31/3/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import "CustomViewController.h"
#import "TopSpender.h"

NS_ASSUME_NONNULL_BEGIN

@interface ReportTopSpenderDetailViewController : CustomViewController
@property (strong, nonatomic) IBOutlet UITableView *tbvData;
@property (strong, nonatomic) UITextField *txtStartDate;
@property (strong, nonatomic) UITextField *txtEndDate;
@property (strong, nonatomic) UISegmentedControl *segConPeriod;
@property (strong, nonatomic) TopSpender *selectedTopSpender;
- (IBAction)unwindToReportTopSpenderDetail:(UIStoryboardSegue *)segue;
@end

NS_ASSUME_NONNULL_END
