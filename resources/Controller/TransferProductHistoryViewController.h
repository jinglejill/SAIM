//
//  TransferProductHistoryViewController.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 4/7/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import "HomeModel.h"


@interface TransferProductHistoryViewController : UIViewController
<HomeModelProtocol,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
- (IBAction)unwindToTransferProductHistory:(UIStoryboardSegue *)segue;
@property (strong, nonatomic) IBOutlet UICollectionView *colViewItem;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end
