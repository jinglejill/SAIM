//
//  AddEditEventViewController.h
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/27/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//
//reality
//really
//realty
#import <UIKit/UIKit.h>
#import "Event.h"
#import "HomeModel.h"

@interface AddEditEventViewController : UIViewController<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *txtLocation;
@property (strong, nonatomic) IBOutlet UITextField *txtRemark;

@property (strong, nonatomic) IBOutlet UITextField *txtPeriodFrom;
@property (strong, nonatomic) IBOutlet UITextField *txtPeriodTo;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePickerPeriod;
@property (strong, nonatomic) IBOutlet UIButton *btnSave;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnBack;
@property (strong, nonatomic) IBOutlet UITextField *txtProductSalesSet;
@property (strong, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *remarkWidth;
@property (weak, nonatomic) IBOutlet UIButton *btnLocked;

@property (strong,nonatomic) Event *event;
@property (nonatomic) enum enumAction currentAction;

- (IBAction)dateAction:(id)sender;
- (IBAction)unwindToAddEditEvent:(UIStoryboardSegue *)segue;
@end
