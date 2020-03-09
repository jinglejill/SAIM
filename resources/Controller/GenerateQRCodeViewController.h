//
//  GenerateQRCodeViewController.h
//  SAIM_UPDATING
//
//  Created by Thidaporn Kijkamjai on 6/25/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Homemodel.h"

@interface GenerateQRCodeViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,HomeModelProtocol,UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *colViewSummaryTable;
@property (strong, nonatomic) IBOutlet UITextField *txtManufacturingDate;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePickerPeriod;

@property (strong, nonatomic) IBOutlet UILabel *lblProductCategory2;
@property (assign, nonatomic) NSInteger index;
@property (strong, nonatomic) NSArray *arrProductCategory2;
@property (strong, nonatomic) NSArray *arrProductEvent;
@property (strong, nonatomic) NSString *strMFD;
@property (strong, nonatomic) NSMutableDictionary *dicSectionAndItemToTag;
@property (strong, nonatomic) NSMutableDictionary *dicGenerateQRCode;
@property (strong, nonatomic) NSMutableArray *productNameTableList;


//- (IBAction)generateQRCode:(id)sender;
- (IBAction)dateAction:(id)sender;
- (IBAction)unwindToGenerateQRCode:(UIStoryboardSegue *)segue;
- (id)findFirstResponder:(UIView *)view;
@end
