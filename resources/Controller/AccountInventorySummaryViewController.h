//
//  AccountInventorySummaryViewController.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 2/4/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"


@interface AccountInventorySummaryViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,HomeModelProtocol,UITextFieldDelegate,UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *colViewData;
@property (strong, nonatomic) IBOutlet UITextField *txtRequiredSales;
@property (strong, nonatomic) IBOutlet UILabel *lblCurrentAccumSales;
- (IBAction)viewSwitched:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *txtDateFrom;
@property (strong, nonatomic) IBOutlet UITextField *txtDateTo;
@property (strong, nonatomic) IBOutlet UIDatePicker *dtPicker;
- (IBAction)datePickerChanged:(id)sender;
- (IBAction)viewPDF:(id)sender;

- (IBAction)unwindToAccountInventorySummary:(UIStoryboardSegue *)segue;

@end
