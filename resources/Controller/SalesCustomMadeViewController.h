//
//  SalesCustomMadeViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 8/30/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomUITextView.h"
#import "CustomMade.h"

@interface SalesCustomMadeViewController : UITableViewController<UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate>
{
    UILabel *lblSize;
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
