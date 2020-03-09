//
//  TransferProductDetailViewController.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 4/7/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransferHistory.h"
#import "HomeModel.h"

@interface TransferProductDetailViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,HomeModelProtocol,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
@property (strong, nonatomic) IBOutlet UICollectionView *colViewData;
@property (strong, nonatomic) IBOutlet UILabel *lblLocation;
@property (strong, nonatomic) TransferHistory *selectedTransferHistory;
@property (strong, nonatomic) IBOutlet UITextField *txtMainCategory;
@property (strong, nonatomic) IBOutlet UIPickerView *txtPicker;

@end
