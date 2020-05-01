//
//  PreOrderAddPreOrder2ViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 15/4/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import "CustomViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PreOrderAddPreOrder2ViewController : CustomViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,HomeModelProtocol,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *colViewSummaryTable;
@property (strong, nonatomic) IBOutlet UILabel *lblProductCategory2;
@property (strong, nonatomic) IBOutlet UILabel *lblLocation;
@property (strong, nonatomic) IBOutlet UITextField *txtLocation;
@property (strong, nonatomic) IBOutlet UIPickerView *txtPicker;

@property (assign, nonatomic) NSInteger index;
@property (strong, nonatomic) NSString *productIDGroup;
@property (strong, nonatomic) NSMutableArray *productCategory2List;
@property (strong, nonatomic) NSMutableArray *productNameList;
@property (strong, nonatomic) NSMutableArray *productNameColorList;
@property (strong, nonatomic) NSMutableArray *productNameSizeList;
@property (strong, nonatomic) NSMutableArray *productList;
@property (strong, nonatomic) NSMutableArray *colorList;
@property (strong, nonatomic) NSMutableArray *productSizeList;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segConInitial;
- (IBAction)segConInitialDidChanged:(id)sender;
@end

NS_ASSUME_NONNULL_END
