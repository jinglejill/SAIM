//
//  PreOrderViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/1/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"

@interface PreOrderViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,HomeModelProtocol,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *colViewSummaryTable;


@property (strong, nonatomic) IBOutlet UILabel *lblProductCategory2;
@property (assign, nonatomic) NSInteger index;
@property (strong, nonatomic) NSMutableArray *arrProductCategory2;
@property (strong, nonatomic) NSMutableArray *mutArrProductWithQuantity;


@property (strong, nonatomic) IBOutlet UILabel *lblLocation;
@property (strong, nonatomic) IBOutlet UITextField *txtLocation;
@property (strong, nonatomic) IBOutlet UIPickerView *txtPicker;
@end
