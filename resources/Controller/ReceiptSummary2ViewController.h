//
//  ReceiptSummary2ViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/3/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"
#import "CustomCollectionViewFlowLayout.h"
#import "CustomViewController.h"

@interface ReceiptSummary2ViewController : CustomViewController<UIPickerViewDelegate,UIPickerViewDataSource>
@property (strong, nonatomic) IBOutlet UICollectionView *colViewSummaryTable;
@property (strong, nonatomic) IBOutlet UILabel *lblLocation;
@property (strong, nonatomic) IBOutlet UILabel *lblDate;
@property (strong, nonatomic) IBOutlet UIButton *btnChangeDate;
@property (strong, nonatomic) IBOutlet UIDatePicker *dtPicker;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnShortOrDetail;
@property (nonatomic, retain) IBOutlet UITableView *customMadeView;
@property (nonatomic, retain) IBOutlet UITableView *preOrderEventIDHistoryView;
@property (nonatomic, retain) IBOutlet UIView *titleAndCloseButtonView;
@property (strong, nonatomic) IBOutlet UITableView *tbvData;

@property (strong, nonatomic) IBOutlet UITextField *txtInitialChanges;
@property (strong, nonatomic) IBOutlet UITextField *txtDeposit;
@property (strong, nonatomic) IBOutlet UILabel *lblCashAndChanges;
@property (strong, nonatomic) IBOutlet UILabel *lblTotalDiscount;
@property (strong, nonatomic) IBOutlet UILabel *lblTotalCash;
@property (strong, nonatomic) IBOutlet UILabel *lblTotalCredit;
@property (strong, nonatomic) IBOutlet UILabel *lblTotalTransfer;
@property (strong, nonatomic) IBOutlet UILabel *lblTotalAmount;

@property (strong, nonatomic) IBOutlet UILabel *lblSalesPerChange;
@property (strong, nonatomic) IBOutlet UIButton *btnExpense;
@property (strong, nonatomic) IBOutlet UIPickerView *pvDeleteReasonCode;

- (IBAction)expenseButtonClicked:(id)sender;

- (IBAction)changeDate:(id)sender;
- (IBAction)datePickerChanged:(id)sender;
- (IBAction)shortOrDetail:(id)sender;
- (IBAction)unwindToReceiptSummary2:(UIStoryboardSegue *)segue;
@end
