//
//  SalesDetailViewController.h
//  SAIM_UPDATING
//
//  Created by Thidaporn Kijkamjai on 5/26/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"


@interface SalesDetailViewController : UIViewController<HomeModelProtocol,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) IBOutlet UICollectionView *colViewProductItem;
@property (nonatomic) NSInteger postCustomerID;
@property (strong, nonatomic) NSString *telephone;


- (IBAction)unwindToSalesDetail:(UIStoryboardSegue *)segue;

@end
