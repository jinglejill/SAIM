//
//  MasterListViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 9/1/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"
enum masterType
{
    productCategory2,
    productCategory1,
    eventSource,
    eventDestination,
    chooseEvent,
    userAccount
};
@interface MasterListViewController : UITableViewController<HomeModelProtocol,UISearchBarDelegate>
@property (strong,nonatomic) NSMutableDictionary *selectedItem;
@property (nonatomic) NSInteger masterType;
@property (strong,nonatomic) NSString *strProductCategory2;


@property (strong, nonatomic) IBOutlet UIView *searchView;
@property (nonatomic,strong) NSArray        *dataSource;
@property (nonatomic,strong) NSMutableArray        *dataSourceForSearchResult;
@property (nonatomic)        BOOL           searchBarActive;
@property (nonatomic)        float          searchBarBoundsY;
@property (nonatomic,strong) UISearchBar        *searchBar;

@end
