//
//  InventorySourceViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 8/28/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"

@interface InventorySourceViewController : UIViewController<HomeModelProtocol,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) IBOutlet UICollectionView *colViewProductSource;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@end
