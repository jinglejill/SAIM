//
//  SalesCustomMadeAddCustomMadeViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/2/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomUITextView.h"
#import "CustomMade.h"
@interface SalesCustomMadeAddCustomMadeViewController : UITableViewController<UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate>
{
    UILabel *lblSize;
//    UISegmentedControl *sgmSize;
    UITextField *txtSize;
    UITextField *txtToe;
    UITextField *txtBody;
    UITextField *txtAccessory;
    CustomUITextView *txtRemark;
}

@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnCancel;
@property (strong, nonatomic) UIPickerView *txtPicker;
@property (strong, nonatomic) CustomMade *customMade;

- (IBAction)unwindToCustomMade:(UIStoryboardSegue *)segue;
@end
