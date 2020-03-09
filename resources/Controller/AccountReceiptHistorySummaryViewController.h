//
//  AccountReceiptHistorySummaryViewController.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 3/6/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"
#import "AccountReceipt.h"


@interface AccountReceiptHistorySummaryViewController : UIViewController<HomeModelProtocol,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) AccountReceipt *accountReceiptHistory;
@property (strong, nonatomic) IBOutlet UICollectionView *colViewData;

@end
