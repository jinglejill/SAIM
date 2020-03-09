//
//  RewardProgramCollectAddViewController.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 4/20/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"
#import "RewardProgram.h"


@interface RewardProgramCollectAddViewController : UITableViewController<HomeModelProtocol,UITextFieldDelegate,UIPickerViewDelegate>
{
    UITextField *txtDateStart;
    UITextField *txtDateEnd;
    UITextField *txtSalesSpent;
    UITextField *txtReceivePoint;
    UIDatePicker *dtPicker;
}
@property (strong, nonatomic) IBOutlet UIButton *btnDelete;
@property (strong, nonatomic) RewardProgram *selectedRewardProgram;
- (IBAction)doneButtonClicked:(id)sender;
- (IBAction)deleteButtonClicked:(id)sender;

@end
