//
//  EventStockSummaryViewController.h
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 8/10/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"
#import "Event.h"

@interface EventInventorySummaryViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,HomeModelProtocol>
@property (strong, nonatomic) IBOutlet UICollectionView *colViewSummaryTable;
@property (strong, nonatomic) IBOutlet UILabel *lblLocation;
@property (strong, nonatomic) IBOutlet UILabel *lblProductCategory2;
@property (assign, nonatomic) NSInteger index;
//@property (strong, nonatomic) NSMutableArray *arrProductCategory2;
//@property (strong, nonatomic) NSMutableArray *mutArrProductWithQuantity;
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
