//
//  CompareInventoryHistoryViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/3/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"


@interface CompareInventoryHistoryViewController : UIViewController
<HomeModelProtocol,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
- (IBAction)unwindToCompareInventoryHistory:(UIStoryboardSegue *)segue;
@property (strong, nonatomic) IBOutlet UICollectionView *colViewItem;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end
