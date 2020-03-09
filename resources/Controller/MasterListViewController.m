//
//  MasterListViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 9/1/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "MasterListViewController.h"
#import "ProductCategory2.h"
#import "ProductCategory1.h"
#import "Event.h"
#import "SharedSelectedEvent.h"
#import "SharedEvent.h"
#import "SharedUserAccount.h"
#import "Utility.h"
#import "UserAccount.h"
#import "SharedProductCategory2.h"
#import "SharedProductCategory1.h"
#import "SharedProductSales.h"
#import "ProductSales.h"
#import "ProductName.h"


#define orangeColor         [UIColor colorWithRed:253/255.0 green:182/255.0 blue:103/255.0 alpha:1]
#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]

@interface MasterListViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSArray *_masterList;
    NSArray *_eventList;
    NSArray *_userAccountList;
    NSArray *_eventListNowAndFutureAsc;
    NSArray *_eventListPastDesc;
    NSMutableArray *_productCategory2List;
    NSMutableArray *_productCategory1List;
    NSMutableArray *_eventInSection;
    NSArray *_sectionTitle;
}
@end

@implementation MasterListViewController
@synthesize selectedItem;
@synthesize masterType;
@synthesize strProductCategory2;
@synthesize searchView;


- (void)loadView
{
    [super loadView];
    
    _homeModel = [[HomeModel alloc] init];
    _homeModel.delegate = self;
    
    {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);
    }
    
    
    selectedItem = [[NSMutableDictionary alloc]init];
    _sectionTitle = @[@"Product category 2",@"Product category 1",@"",@"",@"",@"User account"];
    
    
    [self addSearchBar];
    [self loadViewProcess];
}

- (void)loadViewProcess
{
    switch (masterType) {
        case productCategory2:
        {
            self.title = @"Product Category 2";
            
            
            if([[Utility trimString:_searchBar.text] isEqualToString:@""])
            {
                //get productsales where productname.code = '00'
                //get unique productcat2
                NSMutableArray *productSalesList = [SharedProductSales sharedProductSales].productSalesList;
                for(ProductSales *item in productSalesList)
                {
                    ProductName *productName = [ProductName getProductName:item.productNameID];
                    item.productCategory2 = productName.productCategory2;
                    item.productCategory1 = productName.productCategory1;
                    item.productName = productName.code;
                }
                NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productName = %@",@"00"];
                NSArray *filterArray = [productSalesList filteredArrayUsingPredicate:predicate1];
                NSSet *uniqueProductCategory2 = [NSSet setWithArray:[filterArray valueForKey:@"productCategory2"]];
                NSArray *arrProductCategory2 = [uniqueProductCategory2 allObjects];
                _productCategory2List = [[NSMutableArray alloc]init];
                for(NSString *code in arrProductCategory2)
                {
                    [_productCategory2List addObject:[Utility getProductCategory2:code]];
                }
                
                
                //sort
                NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_name" ascending:YES];
                NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
                NSArray *sortArray = [_productCategory2List sortedArrayUsingDescriptors:sortDescriptors];
                _productCategory2List = [sortArray mutableCopy];
                
                
                
                _masterList = _productCategory2List;
            }
            
            [self.tableView reloadData];

        }
            break;
        case productCategory1:
        {
            self.title = @"Product Category 1";
            
            if([[Utility trimString:_searchBar.text] isEqualToString:@""])
            {
                //get productsales where productname.code = '00'
                //get unique productcat1
                NSMutableArray *productSalesList = [SharedProductSales sharedProductSales].productSalesList;
                for(ProductSales *item in productSalesList)
                {
                    ProductName *productName = [ProductName getProductName:item.productNameID];
                    item.productCategory2 = productName.productCategory2;
                    item.productCategory1 = productName.productCategory1;
                    item.productName = productName.code;
                }
                NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productName = %@ and _productCategory2 = %@",@"00",strProductCategory2];
                NSArray *filterArray = [productSalesList filteredArrayUsingPredicate:predicate1];
                NSSet *uniqueProductCategory1 = [NSSet setWithArray:[filterArray valueForKey:@"productCategory1"]];
                NSArray *arrProductCategory1 = [uniqueProductCategory1 allObjects];
                _productCategory1List = [[NSMutableArray alloc]init];
                for(NSString *code in arrProductCategory1)
                {
                    [_productCategory1List addObject:[Utility getProductCategory1:code productCategory2:strProductCategory2]];
                }
                
                
                //sort
                NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_name" ascending:YES];
                NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
                NSArray *sortArray = [_productCategory1List sortedArrayUsingDescriptors:sortDescriptors];
                _productCategory1List = [sortArray mutableCopy];
                
                
                
                _masterList = _productCategory1List;
            }
            
            [self.tableView reloadData];
        }
            break;
        case eventSource:
        {
            self.title = @"Event source";
            if([[Utility trimString:_searchBar.text] isEqualToString:@""])
            {
                _masterList = [SharedEvent sharedEvent].eventList;
            }
            

            NSArray *arrOfEventList = [Event SplitEventNowAndFutureAndPast:_masterList];
            _eventListNowAndFutureAsc = arrOfEventList[0];
            _eventListPastDesc = arrOfEventList[1];
            
            _eventInSection = [[NSMutableArray alloc]init];
            if([_eventListNowAndFutureAsc count]>0)
            {
                [_eventInSection addObject:@[@"Ongoing",_eventListNowAndFutureAsc]];
            }
            if([_eventListPastDesc count]>0)
            {
                [_eventInSection addObject:@[@"Past",_eventListPastDesc]];
            }
            [self.tableView reloadData];
        }
            break;
        case eventDestination:
        {
            self.title = @"Event destination";
            if([[Utility trimString:_searchBar.text] isEqualToString:@""])
            {
                _masterList = [SharedEvent sharedEvent].eventList;
            }
            
            
            NSArray *arrOfEventList = [Event SplitEventNowAndFutureAndPast:_masterList];
            _eventListNowAndFutureAsc = arrOfEventList[0];
            _eventListPastDesc = arrOfEventList[1];
            
            _eventInSection = [[NSMutableArray alloc]init];
            if([_eventListNowAndFutureAsc count]>0)
            {
                [_eventInSection addObject:@[@"Ongoing",_eventListNowAndFutureAsc]];
            }
            if([_eventListPastDesc count]>0)
            {
                [_eventInSection addObject:@[@"Past",_eventListPastDesc]];
            }
            [self.tableView reloadData];
        }
            break;
        case chooseEvent:
        {
            self.title = @"Choose event";
            if([[Utility trimString:_searchBar.text] isEqualToString:@""])
            {
                _masterList = [SharedEvent sharedEvent].eventList;
            }
            
            
            NSArray *arrOfEventList = [Event SplitEventNowAndFutureAndPast:_masterList];
            _eventListNowAndFutureAsc = arrOfEventList[0];
            _eventListPastDesc = arrOfEventList[1];
            
            _eventInSection = [[NSMutableArray alloc]init];
            if([_eventListNowAndFutureAsc count]>0)
            {
                [_eventInSection addObject:@[@"Ongoing",_eventListNowAndFutureAsc]];
            }
            if([_eventListPastDesc count]>0)
            {
                [_eventInSection addObject:@[@"Past",_eventListPastDesc]];
            }
            [self.tableView reloadData];
            
        }
            break;
        case userAccount:
        {
            self.title = @"User account";
            if([[Utility trimString:_searchBar.text] isEqualToString:@""])
            {
                _masterList = [SharedUserAccount sharedUserAccount].userAccountList;
            }
//            _userAccountList = [SharedUserAccount sharedUserAccount].userAccountList;
//            _masterList = _userAccountList;
            [self.tableView reloadData];

        }
            break;

        default:
            break;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(masterType == userAccount)
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
    }
}

#pragma mark - Table view data source

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView;
    if(masterType == eventSource || masterType == eventDestination || masterType == chooseEvent)
    {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
        [headerView setBackgroundColor:tBlueColor];
        
        
        UILabel *titleLabel = [ [UILabel alloc] initWithFrame:CGRectMake(8, 0, 300, 20)];
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
        titleLabel.text = _eventInSection[section][0];
        titleLabel.textColor = [UIColor whiteColor];
        [headerView addSubview:titleLabel];
        
        return headerView;
    }
    else
    {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
        [headerView setBackgroundColor:tBlueColor];
        
        UILabel *titleLabel = [ [UILabel alloc] initWithFrame:CGRectMake(8, 0, 300, 20)];
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
        titleLabel.text = _sectionTitle[masterType];
        titleLabel.textColor = [UIColor whiteColor];
        [headerView addSubview:titleLabel];
        
        return headerView;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if(masterType == eventSource || masterType == eventDestination || masterType == chooseEvent)
    {
        return [_eventInSection count];
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger rowCount;
    if(masterType == eventSource || masterType == eventDestination || masterType == chooseEvent)
    {
        rowCount = [_eventInSection[section][1] count];
    }
    else
    {
        rowCount = [_masterList count];
    }
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Retrieve cell
    NSString *cellIdentifier = @"reuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier: cellIdentifier];
    }
    switch (masterType) {
        case productCategory2:
        {
            ProductCategory2 *productCategory2 = _masterList[indexPath.row];
            cell.textLabel.text = productCategory2.name;
        }
            break;
        case productCategory1:
        {
            ProductCategory1 *productCategory1 = _masterList[indexPath.row];
            cell.textLabel.text = productCategory1.name;
        }
            break;
        case eventSource:
        {
            NSMutableArray *eventList = _eventInSection[indexPath.section][1];
            Event *eventSource = eventList[indexPath.row];
            cell.textLabel.text = eventSource.location;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", [Utility formatDateForDisplay:eventSource.periodFrom],[Utility formatDateForDisplay:eventSource.periodTo]];
            cell.detailTextLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
        }
            break;
        case eventDestination:
        {
            NSMutableArray *eventList = _eventInSection[indexPath.section][1];
            Event *eventDestination = eventList[indexPath.row];
            cell.textLabel.text = eventDestination.location;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", [Utility formatDateForDisplay:eventDestination.periodFrom],[Utility formatDateForDisplay:eventDestination.periodTo]];
            cell.detailTextLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
        }
            break;
        case chooseEvent:
        {
            NSMutableArray *eventList = _eventInSection[indexPath.section][1];
            Event *event = eventList[indexPath.row];
            cell.textLabel.text = event.location;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", [Utility formatDateForDisplay:event.periodFrom],[Utility formatDateForDisplay:event.periodTo]];
            cell.detailTextLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
        }
            break;
        case userAccount:
        {
            UserAccount *userAccount = _masterList[indexPath.row];
            cell.textLabel.text = userAccount.username;
        }
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (masterType) {
        case productCategory2:
        {
            ProductCategory2 *productCategory2 = _masterList[indexPath.row];
            [selectedItem setValue:productCategory2.name forKey:productCategory2.code];
            [self performSegueWithIdentifier:@"segUnwindToCustomMade" sender:self];
        }
            break;
        case productCategory1:
        {
            ProductCategory1 *productCategory1 = _masterList[indexPath.row];
            [selectedItem setValue:productCategory1.name forKey:productCategory1.code];
            [self performSegueWithIdentifier:@"segUnwindToCustomMade" sender:self];
        }
            break;
        case eventSource:
        {
            NSMutableArray *eventList = _eventInSection[indexPath.section][1];
            Event *eventSource = eventList[indexPath.row];
            NSString *strEventID = [NSString stringWithFormat:@"%ld",eventSource.eventID];
            [selectedItem setValue:eventSource.location forKey:strEventID];
            [self performSegueWithIdentifier:@"segUnwindToTransferProduct" sender:self];
        }
            break;
        case eventDestination:
        {
            NSMutableArray *eventList = _eventInSection[indexPath.section][1];
            Event *eventDestination = eventList[indexPath.row];
            NSString *strEventID = [NSString stringWithFormat:@"%ld",eventDestination.eventID];
            [selectedItem setValue:eventDestination.location forKey:strEventID];
            [self performSegueWithIdentifier:@"segUnwindToTransferProduct" sender:self];
        }
            break;
        case chooseEvent:
        {
            NSMutableArray *eventList = _eventInSection[indexPath.section][1];
            Event *event = eventList[indexPath.row];
            NSString *strEventID = [NSString stringWithFormat:@"%ld",event.eventID];
            [selectedItem setValue:event.location forKey:strEventID];
            [SharedSelectedEvent sharedSelectedEvent].event = event;
            [self performSegueWithIdentifier:@"segUnwindToAdminMenu" sender:self];
        }
            break;
        case userAccount:
        {
            UserAccount *userAccount = _masterList[indexPath.row];
            [selectedItem setValue:userAccount.username forKey:[NSString stringWithFormat:@"%ld",userAccount.userAccountID]];
            [self performSegueWithIdentifier:@"segUnwindToUserAccountEvent" sender:self];
        }
            break;
        default:
            break;
    }
}

-(void) loadingOverlayView
{
    [indicator startAnimating];
    indicator.layer.zPosition = 1;
    indicator.alpha = 1;
    
    
    // and just add them to navigationbar view
    [self.navigationController.view addSubview:overlayView];
    [self.navigationController.view addSubview:indicator];
}

-(void) removeOverlayViews{
    UIView *view = overlayView;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         view.alpha = 0.0;
                         indicator.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         dispatch_async(dispatch_get_main_queue(),^ {
                             [view removeFromSuperview];
                             [indicator stopAnimating];
                             [indicator removeFromSuperview];
                         } );
                     }
     ];
}

-(void)addSearchBar{
    if (!self.searchBar) {
        self.searchBarBoundsY = 0;
        self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0,self.searchBarBoundsY, [UIScreen mainScreen].bounds.size.width, 44)];
        self.searchBar.searchBarStyle       = UISearchBarStyleMinimal;
        self.searchBar.tintColor            = [UIColor grayColor];
        self.searchBar.barTintColor         = [UIColor grayColor];
        self.searchBar.delegate             = self;
        self.searchBar.placeholder          = @"search text";
        
        
        [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor grayColor]];
    }
    
    if (![self.searchBar isDescendantOfView:searchView]) {
        [searchView addSubview:self.searchBar];
    }
}
#pragma mark - search
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
    switch (masterType) {
        case productCategory2:
        {
            NSPredicate *resultPredicate   = [NSPredicate predicateWithFormat:@"_name contains[c] %@", searchText];
            _masterList = [[_productCategory2List filteredArrayUsingPredicate:resultPredicate] mutableCopy];
        }
            break;
        case productCategory1:
        {
            NSPredicate *resultPredicate   = [NSPredicate predicateWithFormat:@"_name contains[c] %@", searchText];
            _masterList = [[_productCategory1List filteredArrayUsingPredicate:resultPredicate] mutableCopy];
        }
            break;
        case eventSource:
        case eventDestination:
        case chooseEvent:
        {
            NSPredicate *resultPredicate   = [NSPredicate predicateWithFormat:@"_location contains[c] %@", searchText];
            _masterList = [[[SharedEvent sharedEvent].eventList filteredArrayUsingPredicate:resultPredicate] mutableCopy];
        }
            break;
        case userAccount:
        {
            NSPredicate *resultPredicate   = [NSPredicate predicateWithFormat:@"_username contains[c] %@", searchText];
            _masterList = [[[SharedUserAccount sharedUserAccount].userAccountList filteredArrayUsingPredicate:resultPredicate] mutableCopy];
        }
            break;
        default:
            break;
    }
    
//    self.dataSourceForSearchResult = [PostCustomer getPostCustomerSortByModifiedDate:self.dataSourceForSearchResult];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    // user did type something, check our datasource for text that looks the same
//    txtTelephone.text = [Utility insertDash:searchText];
    if (searchText.length>0)
    {
        // search and reload data source
        self.searchBarActive = YES;
        [self filterContentForSearchText:[Utility removeDashAndSpaceAndParenthesis:searchText] scope:@""];
        [self loadViewProcess];
    }
    else{
        // if text length == 0
        // we will consider the searchbar is not active
        //        self.searchBarActive = NO;
        
        [self cancelSearching];
        [self loadViewProcess];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self cancelSearching];    
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    self.searchBarActive = YES;
    [self.view endEditing:YES];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    // we used here to set self.searchBarActive = YES
    // but we'll not do that any more... it made problems
    // it's better to set self.searchBarActive = YES when user typed something
    [self.searchBar setShowsCancelButton:YES animated:YES];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    // this method is being called when search btn in the keyboard tapped
    // we set searchBarActive = NO
    // but no need to reloadCollectionView
    //    self.searchBarActive = NO;
    
    [self.searchBar setShowsCancelButton:NO animated:YES];
}
-(void)cancelSearching{
    self.searchBarActive = NO;
    [self.searchBar resignFirstResponder];
    self.searchBar.text  = @"";
}

@end
