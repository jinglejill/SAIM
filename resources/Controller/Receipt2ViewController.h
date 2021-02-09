//
//  Receipt2ViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 16/3/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import "CustomViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface Receipt2ViewController : CustomViewController<UIPickerViewDelegate, UIPickerViewDataSource>
- (IBAction)unwindToReceipt2:(UIStoryboardSegue *)segue;
@property (strong, nonatomic) IBOutlet UITableView *tbvPay;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnBack;
@property (strong, nonatomic) IBOutlet UIPickerView *pvReplaceReasonCode;


- (IBAction)backButtonClicked:(id)sender;
@end

NS_ASSUME_NONNULL_END
