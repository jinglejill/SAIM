//
//  AccountReceiptHistoryViewController.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 2/12/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"


@interface AccountReceiptHistoryViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,HomeModelProtocol,UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *colViewData;
@property (strong, nonatomic) IBOutlet UITextField *txtAccountReceiptHistoryDate;
@property (strong, nonatomic) IBOutlet UIDatePicker *dtPicker;

- (IBAction)datePickerChanged:(id)sender;

@end
