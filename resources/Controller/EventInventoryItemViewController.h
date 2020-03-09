//
//  EventInventoryItemViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 9/7/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

//#import "ViewController.h"
#import <UIKit/UIKit.h>
#import "HomeModel.h"
//#import "EventInventoryItemPageViewController.h"

@interface EventInventoryItemViewController : UIViewController<HomeModelProtocol,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) IBOutlet UICollectionView *colViewProductItem;
@property (strong, nonatomic) IBOutlet UILabel *lblLocation;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;


@property (strong, nonatomic) IBOutlet UILabel *lblProductCategory2;
@property (assign, nonatomic) NSInteger index;
@property (strong, nonatomic) NSMutableArray *arrProductCategory2;
@property (strong, nonatomic) NSArray *arrProductEvent;
//@property (strong, nonatomic) EventInventoryItemPageViewController *pageViewController;


//- (IBAction)deleteAllButtonClicked:(id)sender;



@end
