//
//  MainInventoryTableCollectionViewController.h
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 8/3/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"

@interface MainInventorySummaryViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,HomeModelProtocol>
@property (strong, nonatomic) IBOutlet UICollectionView *colViewSummaryTable;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnAllOrRemaining;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segConInitial;
- (IBAction)allOrRemaining:(id)sender;
- (IBAction)segConInitialDidChanged:(id)sender;

@end
