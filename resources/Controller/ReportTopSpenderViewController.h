//
//  ReportTopSpenderViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 31/3/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import "CustomViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ReportTopSpenderViewController : CustomViewController

@property (strong, nonatomic) IBOutlet UITextField *txtStartDate;
@property (strong, nonatomic) IBOutlet UITextField *txtEndDate;
@property (strong, nonatomic) IBOutlet UIDatePicker *dtPicker;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segConPeriod;
@property (strong, nonatomic) IBOutlet UITableView *tbvData;
@property (strong, nonatomic) IBOutlet UILabel *lblTelephoneCount;
- (IBAction)segConPeriodValueChanged:(id)sender;
- (IBAction)datePickerChanged:(id)sender;
@end

NS_ASSUME_NONNULL_END
