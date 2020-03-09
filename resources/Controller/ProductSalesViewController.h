//
//  ProductSalesViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/26/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"

@interface ProductSalesViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,HomeModelProtocol>
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnEdit;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnCancel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnSelect;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnSelectAll;
@property (strong, nonatomic) IBOutlet UICollectionView *colViewItem;
- (IBAction)unwindToProductSales:(UIStoryboardSegue *)segue;
- (IBAction)cancelAction:(id)sender;
- (IBAction)selectAction:(id)sender;
- (IBAction)editAction:(id)sender;
- (IBAction)selectAllAction:(id)sender;
@property (strong, nonatomic) NSString *productSalesSetID;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@end
