//
//  AccountInventoryAddViewController.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 2/1/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"


@interface AccountInventoryAddViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,HomeModelProtocol,UITextFieldDelegate,UIPickerViewDelegate, UIPickerViewDataSource>
@property (strong, nonatomic) IBOutlet UICollectionView *colViewData;
@property (strong, nonatomic) IBOutlet UITextField *txtDateIn;
@property (strong, nonatomic) IBOutlet UIDatePicker *dtPicker;
@property (strong, nonatomic) IBOutlet UITextField *txtMainCategory;
@property (strong, nonatomic) IBOutlet UIPickerView *txtPicker;

- (IBAction)datePickerChanged:(id)sender;
- (IBAction)addInventory:(id)sender;
@end
