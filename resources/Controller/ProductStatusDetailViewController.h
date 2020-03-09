//
//  ProductStatusDetailViewController.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 8/25/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

//#import "ViewController.h"
#import "HomeModel.h"

@interface ProductStatusDetailViewController : UIViewController<HomeModelProtocol,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) IBOutlet UICollectionView *colViewProductItem;
@property (strong, nonatomic) NSMutableArray *productDetailList;


- (IBAction)unwindToProductStatusDetail:(UIStoryboardSegue *)segue;

@end
