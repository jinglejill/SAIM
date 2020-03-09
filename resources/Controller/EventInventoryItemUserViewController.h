//
//  EventInventoryItemUserViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 9/15/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"

@interface EventInventoryItemUserViewController : UIViewController<HomeModelProtocol,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) IBOutlet UICollectionView *colViewProductItem;
@property (strong, nonatomic) IBOutlet UILabel *lblLocation;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;


@property (strong, nonatomic) IBOutlet UILabel *lblProductCategory2;
@property (assign, nonatomic) NSInteger index;
@property (strong, nonatomic) NSMutableArray *arrProductCategory2;
@property (strong, nonatomic) NSArray *arrProductEvent;

@end
