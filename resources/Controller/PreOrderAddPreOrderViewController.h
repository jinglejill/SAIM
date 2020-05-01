//
//  PreOrderAddPreOrderViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/5/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"
#import "Product.h"
@interface PreOrderAddPreOrderViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,HomeModelProtocol,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *colViewSummaryTable;
@property (strong, nonatomic) IBOutlet UILabel *lblProductCategory2;
@property (strong, nonatomic) IBOutlet UILabel *lblLocation;
@property (strong, nonatomic) IBOutlet UITextField *txtLocation;
@property (strong, nonatomic) IBOutlet UIPickerView *txtPicker;


@property (assign, nonatomic) NSInteger index;
@property (strong, nonatomic) Product *product;
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
