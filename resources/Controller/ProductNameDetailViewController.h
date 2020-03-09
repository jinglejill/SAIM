//
//  ProductNameDetailViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 3/12/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"
#import "ProductName.h"


@interface ProductNameDetailViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,HomeModelProtocol>
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnEdit;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnCancel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnSelect;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnSelectAll;
@property (strong, nonatomic) IBOutlet UICollectionView *colViewItem;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

- (IBAction)unwindToProductSales:(UIStoryboardSegue *)segue;
- (IBAction)cancelAction:(id)sender;
- (IBAction)selectAction:(id)sender;
- (IBAction)editAction:(id)sender;
- (IBAction)selectAllAction:(id)sender;

@property (strong, nonatomic) NSString *productSalesSetID;
@property (strong, nonatomic) ProductName *selectedProductName;
@property (strong, nonatomic) NSMutableArray *selectedColorList;
@property (strong, nonatomic) NSMutableArray *selectedSizeList;
@end
