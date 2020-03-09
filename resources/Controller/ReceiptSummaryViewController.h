//
//  ReceiptSummaryViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/3/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"
#import "CustomCollectionViewFlowLayout.h"

@interface ReceiptSummaryViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,HomeModelProtocol,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UICollectionView *colViewSummaryTable;
@property (strong, nonatomic) IBOutlet UILabel *lblLocation;
@property (strong, nonatomic) IBOutlet UILabel *lblDate;
@property (strong, nonatomic) IBOutlet UIButton *btnChangeDate;
@property (strong, nonatomic) IBOutlet UIDatePicker *dtPicker;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnShortOrDetail;
@property (nonatomic, retain) IBOutlet UITableView *customMadeView;
@property (nonatomic, retain) IBOutlet UITableView *cashAllocationView;
@property (nonatomic, retain) IBOutlet UITableView *preOrderEventIDHistoryView;
@property (nonatomic, retain) IBOutlet UIView *titleAndCloseButtonView;




- (IBAction)changeDate:(id)sender;
- (IBAction)datePickerChanged:(id)sender;
- (IBAction)shortOrDetail:(id)sender;
- (IBAction)unwindToReceiptSummary:(UIStoryboardSegue *)segue;
@end
