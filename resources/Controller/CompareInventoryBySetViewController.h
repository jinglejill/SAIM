//
//  CompareInventoryBySetViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/3/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"

@interface CompareInventoryBySetViewController : UIViewController
<HomeModelProtocol,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
- (IBAction)unwindToCompareInventoryBySet:(UIStoryboardSegue *)segue;
@property (strong, nonatomic) IBOutlet UICollectionView *colViewProductItem;
@property (strong, nonatomic) IBOutlet UILabel *lblLocation;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSString *runningSetNo;
@property (strong, nonatomic) NSString *eventName;

@end
