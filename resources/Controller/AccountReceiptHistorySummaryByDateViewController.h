//
//  AccountReceiptHistorySummaryByDateViewController.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 3/7/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"

@interface AccountReceiptHistorySummaryByDateViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,HomeModelProtocol,UITextFieldDelegate,UIPickerViewDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *colViewData;
@property (strong, nonatomic) IBOutlet UITextField *txtDateFrom;
@property (strong, nonatomic) IBOutlet UITextField *txtDateTo;
@property (strong, nonatomic) IBOutlet UIDatePicker *dtPicker;
- (IBAction)viewPDF:(id)sender;
- (IBAction)datePickerChanged:(id)sender;
@end
