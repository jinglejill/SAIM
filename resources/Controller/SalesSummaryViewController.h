//
//  SalesSummaryViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/20/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SalesSummaryViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) IBOutlet UICollectionView *colViewSummaryTable;
- (IBAction)backButtonClicked:(id)sender;

@end
