//
//  AdminMenuViewController.m
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/29/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "AdminMenuViewController.h"
#import "UserAccountViewController.h"
#import "EventViewController.h"
#import "Utility.h"
#import "MasterListViewController.h"
#import "APLSectionInfo.h"
#import "APLSectionHeaderView.h"
#import "ProductCategory2SelectionViewController.h"
#import "RootViewController.h"
#import "Login.h"
#import <stdlib.h>
#import "Product.h"
#import "ProductPostedViewController.h"
#import "ProductPosted2ViewController.h"
#import "ExportSalesViewController.h"



#import "PushSync.h"


#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]
enum enumAdminMenu
{
    //Product setup
    menuProductCategory2,
    menuProductCategory1,
    menuColor,
    menuProductSize,
    menuProduct,
    menuGenerateQRCode,
    
    //User and event mngt
    menuUserAccount,
    menuEvent,
    menuUserAccountEvent,

    //Inventory mngt
    menuMainInventorySummary,
    menuMainInventoryItem,
//    menuInventorySource,
    menuMainInventoryScan,
    menuTransferProduct,
    menuTransferProductHistory,
//    menuCompareInventoryHistory,
//    menuProductLocationAndStatus,
    menuProductDeleteScan,
    menuProductDeleteHistory,
    
    //Post
    menuCustomMadeIn,
    menuCustomMadeOut,
//    menuProductPost,
//    menuProductPosted,
    menuProductPostNew,
    menuProductPostedNew,
    
    //Sales mngt
    menuSearchSalesTelephone,
    menuProductSalesSet,
    menuProductCost,
    menuMemberAndPoint,
    menuRewardProgramSetup,
    menuSalesSummary,
    menuSalesByZone,
    menuSalesByChannel,
    menuExportSales,
    
    //Account
    menuAccountInventoryAdd,
    menuAccoutnInventoryAddedList,
    menuAccountInventorySummary,
    menuAccountReceiptHistory,
    menuAccountReceiptHistoryPdfList,
    
    //Production
    menuProductionOrderAdd,
    menuProductionOrderAddedList,
    
    //event
    menuEventInventorySummary,
    menuEventInventoryItem,
    menuEventInventoryScan,
    menuEventProductDeleteScan,
    menuEventChartSales,
    menuEventSalesSummary,
    menuEventExportSales,
    
    //setting
    menuDropbox
};

@interface AdminMenuViewController ()
{
    NSString *_selectedEventID;
    NSString *_selectedEventLocation;
    NSArray *_menuSectionProductSetup;
    NSArray *_menuSectionUserAndEvent;
    NSArray *_menuSectionInventory;
    NSArray *_menuSectionSales;
    NSArray *_menuSectionPost;
    NSArray *_menuSectionAccount;
    NSArray *_menuSectionProduction;
    NSArray *_menuSectionEvent;
    NSArray *_menuSectionSetting;
    NSArray *_sectionNameList;
    NSMutableArray *_menuInSectionList;
    
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    RootViewController *rootViewController;
    NSString *relinkUserId;
    NSString *_generateSalesfileName;
    int _countRetry;
}
@end

#pragma mark -

#define DEFAULT_ROW_HEIGHT 88
#define HEADER_HEIGHT 48

static NSString *SectionHeaderViewIdentifier = @"SectionHeaderViewIdentifier";

//extern NSString *kDBRootAppFolder;


@implementation AdminMenuViewController
- (IBAction)unwindToAdminMenu:(UIStoryboardSegue *)segue {

    MasterListViewController *source = [segue sourceViewController];
    if ([source respondsToSelector:NSSelectorFromString(@"selectedItem")])
    {
        NSDictionary *selectedItem = source.selectedItem;
        
        if ([selectedItem count] > 0) {
            
            NSString *selectedValue;
            NSString *selectedKey;
            for(id key in selectedItem){
                    
                selectedKey = key;
                selectedValue = [selectedItem objectForKey:key];
            }
            
            if(source.masterType == chooseEvent)
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:7];
                [self.tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text = selectedValue;
                _selectedEventID = selectedKey;
                _selectedEventLocation = selectedValue;
            }
        }
    }
}

- (void)itemsInserted
{
}

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
    
    
    _selectedEventID = @"";
    _selectedEventLocation = @"";
    self.navigationController.toolbarHidden = YES;
    
    
    _sectionNameList = @[@"PRODUCT SETUP",
                         @"USER AND EVENT",
                         @"INVENTORY",
                         @"POST",
                         @"SALES AND COST",
                         @"ACCOUNT",
                         @"PRODUCTION",
                         @"EVENT",
                         @"SETTING"];
    _menuSectionProductSetup = @[@"Main category",
                                 @"Sub category",
                                 @"Color",
                                 @"Size",
                                 @"Product",
                                 @"Generate QR code"
                                 ];
    _menuSectionUserAndEvent = @[@"User account management",
                                 @"Event management",
                                 @"Responsibility management"];
    _menuSectionInventory = @[@"Main inventory summary",
                              @"Main inventory item",
//                              @"Inventory source",
                              @"Main inventory scan",
                              @"Transfer product",
                              @"Transfer product history",
//                              @"Compare inventory history",
//                              @"Product status scan",
                              @"Product delete scan",
                              @"Product delete history"];
    _menuSectionPost = @[@"Custom-made in",
                         @"Custom-made out",
//                         @"To post product",
//                         @"Posted product",
                         @"To post product new",
                         @"Posted product new"];
    _menuSectionSales = @[@"Search sales (telephone)",
                          @"Price offer set",
                          @"Product cost",
                          @"Member and point",
                          @"Reward program setup",
                          @"Sales summary",
                          @"Sales by zone",
                          @"Sales by channel",
                          @"Export sales"
                          ];
    _menuSectionAccount = @[@"Account Inventory Add",
                            @"Account Inventory Added List",
                            @"Account Inventory Summary",
                            @"Account Receipt History",
                            @"Account Receipt History Pdf"
                            ];
    _menuSectionProduction = @[@"Production Order Add",
                            @"Production Order Added List"
                            ];
    _menuSectionEvent = @[@"Event",
                          @"Event inventory summary",
                          @"Event inventory item",
                          @"Event inventory scan",
                          @"Event product delete scan",
                          @"Event chart sales",
                          @"Event sales summary",
                          @"Event export sales"];
    _menuSectionSetting = @[@"Dropbox"];
    
    _menuInSectionList = [[NSMutableArray alloc]init];
    [_menuInSectionList addObject:_menuSectionProductSetup];
    [_menuInSectionList addObject:_menuSectionUserAndEvent];
    [_menuInSectionList addObject:_menuSectionInventory];
    [_menuInSectionList addObject:_menuSectionPost];
    [_menuInSectionList addObject:_menuSectionSales];
    [_menuInSectionList addObject:_menuSectionAccount];
    [_menuInSectionList addObject:_menuSectionProduction];
    [_menuInSectionList addObject:_menuSectionEvent];
    [_menuInSectionList addObject:_menuSectionSetting];
    
    NSMutableArray *infoArray = [[NSMutableArray alloc] init];
    for(int i=0; i<[_sectionNameList count]; i++)
    {
        APLSectionInfo *sectionInfo = [[APLSectionInfo alloc] init];
        sectionInfo.sectionName = _sectionNameList[i];
        sectionInfo.open = NO;
        sectionInfo.menuInSection = _menuInSectionList[i];
        
        NSNumber *defaultRowHeight = @(DEFAULT_ROW_HEIGHT);
        NSInteger countOfMenu = [sectionInfo.menuInSection count];
        for (NSInteger i = 0; i < countOfMenu; i++)
        {
            [sectionInfo insertObject:defaultRowHeight inRowHeightsAtIndex:i];
        }
        [infoArray addObject:sectionInfo];
    }
    self.sectionInfoArray = infoArray;
    
    
    //communicate dropbox
    [self communicateDropbox];
    [self loadViewProcess];
}

- (void)loadViewProcess
{
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
    
    [self refreshDropboxMenu];
}

- (void)refreshDropboxMenu
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:8];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if ([[DBSession sharedSession] isLinked]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ [Log out]",_menuSectionSetting[indexPath.item]];
    }
    else
    {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ [Log in]",_menuSectionSetting[indexPath.item]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //uncomment to hide back button
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
    self.openSectionIndex = NSNotFound;
    
    // Set up default values.
    self.tableView.sectionHeaderHeight = HEADER_HEIGHT;
    
    
    UINib *sectionHeaderNib = [UINib nibWithNibName:@"SectionHeaderView" bundle:nil];
    [self.tableView registerNib:sectionHeaderNib forHeaderFooterViewReuseIdentifier:SectionHeaderViewIdentifier];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger item = indexPath.item;
    
    static NSString *CellIdentifier = @"reuseIdentifier";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    if(section == 0)
    {
        cell.textLabel.text = _menuSectionProductSetup[item];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.text = @"";
    }
    else if(section == 1)
    {
        cell.textLabel.text = _menuSectionUserAndEvent[item];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.text = @"";
    }
    else if(section == 2)
    {
        cell.textLabel.text = _menuSectionInventory[item];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.text = @"";
    }
    else if(section == 3)
    {
        cell.textLabel.text = _menuSectionPost[item];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.text = @"";
    }
    else if(section == 4)
    {
        cell.textLabel.text = _menuSectionSales[item];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.text = @"";
    }
    else if(section == 5)
    {
        cell.textLabel.text = _menuSectionAccount[item];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.text = @"";
    }
    else if(section == 6)
    {
        cell.textLabel.text = _menuSectionProduction[item];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.text = @"";
    }
    else if(section == 7 && item == 0)
    {
        cell.textLabel.text = @"Event";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = _selectedEventLocation;
    }
    else if(section == 7 && item != 0)
    {
        cell.textLabel.text = _menuSectionEvent[item];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.text = @"";
    }
    else if(section == 8)
    {
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.text = @"";
        
        if ([[DBSession sharedSession] isLinked]) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@ [Log out]",_menuSectionSetting[item]];
        }
        else
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%@ [Log in]",_menuSectionSetting[item]];
        }
    }

    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    APLSectionHeaderView *sectionHeaderView = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:SectionHeaderViewIdentifier];
    
    APLSectionInfo *sectionInfo = (self.sectionInfoArray)[section];
    sectionInfo.headerView = sectionHeaderView;
    
    sectionHeaderView.titleLabel.text = sectionInfo.sectionName;
    sectionHeaderView.section = section;
    sectionHeaderView.delegate = self;
    
    return sectionHeaderView;
}

#pragma mark - SectionHeaderViewDelegate

- (void)sectionHeaderView:(APLSectionHeaderView *)sectionHeaderView sectionOpened:(NSInteger)sectionOpened {
    
    APLSectionInfo *sectionInfo = (self.sectionInfoArray)[sectionOpened];
    
    sectionInfo.open = YES;
    
    /*
     Create an array containing the index paths of the rows to insert: These correspond to the rows for each quotation in the current section.
     */
    NSInteger countOfRowsToInsert = [sectionInfo.menuInSection count];
    NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < countOfRowsToInsert; i++) {
        [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:sectionOpened]];
    }
    
    /*
     Create an array containing the index paths of the rows to delete: These correspond to the rows for each quotation in the previously-open section, if there was one.
     */
    NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
    
    NSInteger previousOpenSectionIndex = self.openSectionIndex;
    if (previousOpenSectionIndex != NSNotFound) {
        
        APLSectionInfo *previousOpenSection = (self.sectionInfoArray)[previousOpenSectionIndex];
        previousOpenSection.open = NO;
        [previousOpenSection.headerView toggleOpenWithUserAction:NO];
        NSInteger countOfRowsToDelete = [previousOpenSection.menuInSection count];
        for (NSInteger i = 0; i < countOfRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:previousOpenSectionIndex]];
        }
    }
    
    // style the animation so that there's a smooth flow in either direction
    UITableViewRowAnimation insertAnimation;
    UITableViewRowAnimation deleteAnimation;
    if (previousOpenSectionIndex == NSNotFound || sectionOpened < previousOpenSectionIndex) {
        insertAnimation = UITableViewRowAnimationTop;
        deleteAnimation = UITableViewRowAnimationBottom;
    }
    else {
        insertAnimation = UITableViewRowAnimationBottom;
        deleteAnimation = UITableViewRowAnimationTop;
    }
    
    // apply the updates
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:insertAnimation];
    [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:deleteAnimation];
    [self.tableView endUpdates];
    
    self.openSectionIndex = sectionOpened;
}

- (void)sectionHeaderView:(APLSectionHeaderView *)sectionHeaderView sectionClosed:(NSInteger)sectionClosed {
    
    /*
     Create an array of the index paths of the rows in the section that was closed, then delete those rows from the table view.
     */
    APLSectionInfo *sectionInfo = (self.sectionInfoArray)[sectionClosed];
    
    sectionInfo.open = NO;
    NSInteger countOfRowsToDelete = [self.tableView numberOfRowsInSection:sectionClosed];
    
    if (countOfRowsToDelete > 0) {
        NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < countOfRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:sectionClosed]];
        }
        [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationTop];
    }
    self.openSectionIndex = NSNotFound;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segUserAccount"])
    {
        UserAccountViewController *vc = segue.destinationViewController;
        vc.currentAction = list;
    }
    else if ([[segue identifier] isEqualToString:@"segEvent"])
    {
        EventViewController *vc = segue.destinationViewController;
        vc.currentAction = list;
    }
    else if([[segue identifier] isEqualToString:@"segChooseEvent"])
    {
        MasterListViewController *vc = segue.destinationViewController;
        vc.masterType = chooseEvent;
    }
    else if([[segue identifier] isEqualToString:@"segChooseProductCategory2FromProductCategory1"])
    {
        ProductCategory2SelectionViewController *vc = segue.destinationViewController;
        vc.fromMenu = 0;
    }
    else if([[segue identifier] isEqualToString:@"segChooseProductCategory2FromProduct"])
    {
        ProductCategory2SelectionViewController *vc = segue.destinationViewController;
        vc.fromMenu = 1;
    }
    else if([[segue identifier] isEqualToString:@"segUnwindToSignInVC"])
    {
        Login *login = [[Login alloc]init];
        login.username = [Utility modifiedUser];
        login.status = @"0";
        login.deviceToken = [Utility deviceToken];
        [_homeModel insertItems:dbLogin withData:login];
        [Utility setModifiedUser:@""];
    }
    else if([[segue identifier] isEqualToString:@"segProductPosted"])
    {
        ProductPostedViewController *vc = segue.destinationViewController;
        vc.fromUserMenu = NO;
    }
    else if([[segue identifier] isEqualToString:@"segProductPostedNew"])
    {
        ProductPosted2ViewController *vc = segue.destinationViewController;
        vc.fromUserMenu = NO;
    }
    else if([[segue identifier] isEqualToString:@"segExportSales"])
    {
        ExportSalesViewController *vc = segue.destinationViewController;
        vc.fromMenu = 0;
    }
    else if([[segue identifier] isEqualToString:@"segExportSalesEvent"])
    {
        ExportSalesViewController *vc = segue.destinationViewController;
        vc.fromMenu = 1;
    }
    else if([[segue identifier] isEqualToString:@"segSalesByZone"])
    {
        ExportSalesViewController *vc = segue.destinationViewController;
        vc.fromMenu = 2;
    }
    else if([[segue identifier] isEqualToString:@"segSalesByChannel"])
    {
        ExportSalesViewController *vc = segue.destinationViewController;
        vc.fromMenu = 3;
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [_sectionNameList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    APLSectionInfo *sectionInfo = (self.sectionInfoArray)[section];
    NSInteger numMenuInSection = [sectionInfo.menuInSection count];
    
    return sectionInfo.open ? numMenuInSection : 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger item = indexPath.item;
    
    if(section == 0)
    {
        switch (item) {
            case menuProductCategory2:
                [self performSegueWithIdentifier:@"segProductCategory2" sender:self];
                break;
            case menuProductCategory1:
                [self performSegueWithIdentifier:@"segChooseProductCategory2FromProductCategory1" sender:self];
                break;
            case menuColor:
                [self performSegueWithIdentifier:@"segColor" sender:self];
                break;
            case menuProductSize:
                [self performSegueWithIdentifier:@"segSize" sender:self];
                break;
            case menuProduct:
                [self performSegueWithIdentifier:@"segChooseProductCategory" sender:self];
                break;
            case menuGenerateQRCode:
                [self performSegueWithIdentifier:@"segGenerateQRCodePage" sender:self];
                break;
            default:
                break;
        }
    }
    else if(section == 1)
    {
        switch (item+[_menuSectionProductSetup count]) {
            case menuUserAccount:
                [self performSegueWithIdentifier:@"segUserAccount" sender:self];
                break;
            case menuEvent:
                [self performSegueWithIdentifier:@"segEvent" sender:self];
                break;
            case menuUserAccountEvent:
                [self performSegueWithIdentifier:@"segUserAccountEvent" sender:self];
                break;
            default:
                break;
        }
    }
    else if(section == 2)
    {
        switch (item+[_menuSectionProductSetup count]+[_menuSectionUserAndEvent count]) {
            case menuMainInventorySummary:
                [self performSegueWithIdentifier:@"segMainInventorySummary" sender:self];
                break;
            case menuMainInventoryItem:
                [self performSegueWithIdentifier:@"segMainInventoryItem" sender:self];
                break;
//            case menuInventorySource:
//                [self performSegueWithIdentifier:@"segInventorySource" sender:self];
//                break;
            case menuMainInventoryScan:
            {
                NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
                [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
                [self performSegueWithIdentifier:@"segMainInventoryScan" sender:self];
            }
                break;
            case menuTransferProduct:
                [self performSegueWithIdentifier:@"segTransferProduct" sender:self];
                break;
            case menuTransferProductHistory:
                [self performSegueWithIdentifier:@"segTransferProductHistory" sender:self];
                break;
//            case menuCompareInventoryHistory:
//                [self performSegueWithIdentifier:@"segCompareInventoryHistory" sender:self];
//                break;
//            case menuProductLocationAndStatus:
//            {
//                NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
//                [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
//                [self performSegueWithIdentifier:@"segProductLocationAndStatusScan" sender:self];
//            }
//                break;
            case menuProductDeleteScan:
            {
                NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
                [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
                [self performSegueWithIdentifier:@"segProductDeleteScan" sender:self];
            }
                break;
            case menuProductDeleteHistory:
            {
                NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
                [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
                [self performSegueWithIdentifier:@"segProductDeleteHistory" sender:self];
            }
                break;
            default:
                break;
        }
    }
    else if(section == 3)
    {
        switch (item+[_menuSectionProductSetup count]+[_menuSectionUserAndEvent count]+[_menuSectionInventory count]) {
            case menuCustomMadeIn:
            {
                [self performSegueWithIdentifier:@"segCustomMadeIn" sender:self];
            }
                break;
            case menuCustomMadeOut:
            {
                [self performSegueWithIdentifier:@"segCustomMadeOut" sender:self];
            }
                break;
//            case menuProductPost:
//            {
//                [self performSegueWithIdentifier:@"segProductPost" sender:self];
//            }
//                break;
//            case menuProductPosted:
//            {
//                //print current date
//                NSDate *today = [NSDate date];
//                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//                [dateFormat setDateFormat:@"hh:mm:ss"];
//                NSString *dateString = [dateFormat stringFromDate:today];
//                NSLog(@"click posted time: %@", dateString);
//                [self performSegueWithIdentifier:@"segProductPosted" sender:self];
//            }
//                break;
            case menuProductPostNew:
                {
                    [self performSegueWithIdentifier:@"segProductPost2" sender:self];
                }
                    break;
            case menuProductPostedNew:
            {
                //print current date
                NSDate *today = [NSDate date];
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"hh:mm:ss"];
                NSString *dateString = [dateFormat stringFromDate:today];
                NSLog(@"click posted time: %@", dateString);
                [self performSegueWithIdentifier:@"segProductPostedNew" sender:self];
            }
                break;
            default:
                break;
        }
    }
    else if(section == 4)
    {
        switch (item+[_menuSectionProductSetup count]+[_menuSectionUserAndEvent count]+[_menuSectionInventory count]+[_menuSectionPost count]) {
            case menuSearchSalesTelephone:
                [self performSegueWithIdentifier:@"segSearchSalesTelephone" sender:self];
                break;
            case menuProductSalesSet:
                [self performSegueWithIdentifier:@"segProductSalesSet" sender:self];
                break;                
            case menuProductCost:
                [self performSegueWithIdentifier:@"segProductCost" sender:self];
                break;
            case menuMemberAndPoint:
                [self performSegueWithIdentifier:@"segMemberAndPoint" sender:self];
                break;
            case menuRewardProgramSetup:
                [self performSegueWithIdentifier:@"segRewardProgramSetup" sender:self];
                break;
            case menuSalesSummary:
            {
                NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
                [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
                [self performSegueWithIdentifier:@"segSalesSummary" sender:self];
            }
                break;
            case menuSalesByZone:
            {                
                [self performSegueWithIdentifier:@"segSalesByZone" sender:self];
            }
                break;
            case menuSalesByChannel:
            {
                [self performSegueWithIdentifier:@"segSalesByChannel" sender:self];
            }
                break;
            case menuExportSales:
                [self performSegueWithIdentifier:@"segExportSales" sender:self];
                break;            
            default:
                break;
        }
    }
    else if(section == 5)
    {
        switch (item+[_menuSectionProductSetup count]+[_menuSectionUserAndEvent count]+[_menuSectionInventory count]+[_menuSectionPost count]+[_menuSectionSales count]) {
            case menuAccountInventoryAdd:
                [self performSegueWithIdentifier:@"segAccountInventoryAdd" sender:self];
                break;
            case menuAccoutnInventoryAddedList:
                [self performSegueWithIdentifier:@"segAccountInventoryAddedList" sender:self];
                break;
            case menuAccountInventorySummary:
                [self performSegueWithIdentifier:@"segAccountInventorySummary" sender:self];
                break;
            case menuAccountReceiptHistory:
                [self performSegueWithIdentifier:@"segAccountReceiptHistorySummaryByDate" sender:self];
                break;
            case menuAccountReceiptHistoryPdfList:
                [self performSegueWithIdentifier:@"segAccountReceiptHistoryPdfList" sender:self];
                break;
            default:
                break;
        }
    }
    else if(section == 6)
    {
        switch (item+[_menuSectionProductSetup count]+[_menuSectionUserAndEvent count]+[_menuSectionInventory count]+[_menuSectionPost count]+[_menuSectionSales count]+[_menuSectionAccount count]) {
            case menuProductionOrderAdd:
                [self performSegueWithIdentifier:@"segProductionOrderAdd" sender:self];
                break;
            case menuProductionOrderAddedList:
                [self performSegueWithIdentifier:@"segProductionOrderAddedList" sender:self];
                break;            
            default:
                break;
        }
    }
    else if(section == 7)
    {
        if(item == 0)
        {
            [self performSegueWithIdentifier:@"segChooseEvent" sender:self];
        }
        else
        {
            if([_selectedEventID isEqualToString:@""])
            {
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Event missing" message:@"Please choose event" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action){}];
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
                return;
            }
            else
            {
                switch (item+[_menuSectionProductSetup count]+[_menuSectionUserAndEvent count]+[_menuSectionInventory count]+[_menuSectionPost count]+[_menuSectionSales count]+[_menuSectionAccount count]+[_menuSectionProduction count]-1) {
                    case menuEventInventorySummary:
                        [self performSegueWithIdentifier:@"segEventInventorySummaryPage" sender:self];
                        break;
                    case menuEventInventoryItem:
                        [self performSegueWithIdentifier:@"segEventInventoryItemPage" sender:self];
                        break;
                    case menuEventInventoryScan:
                    {
                        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
                        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
                        [self performSegueWithIdentifier:@"segEventInventoryScan" sender:self];
                    }
                        break;
                    case menuEventProductDeleteScan:
                    {
                        [self performSegueWithIdentifier:@"segEventProductDeleteScan" sender:self];
                    }
                        break;
                    case menuEventChartSales:
                    {
//                        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
//                        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
                        [self performSegueWithIdentifier:@"segEventChartSales" sender:self];
                    }
                        break;
                    case menuEventSalesSummary:
                    {
                        [self performSegueWithIdentifier:@"segEventSalesSummary" sender:self];
                    }
                        break;
                    case menuEventExportSales:
                    {
                        [self performSegueWithIdentifier:@"segExportSalesEvent" sender:self];
                    }
                        break;
                    default:
                        break;
                }
            }
        }
    }
    else if(section == 8)
    {
        switch (item+[_menuSectionProductSetup count]+[_menuSectionUserAndEvent count]+[_menuSectionInventory count]+[_menuSectionPost count]+[_menuSectionSales count]+[_menuSectionAccount count]+[_menuSectionProduction count]+[_menuSectionEvent count]-1) {// -1 due to section 6 have menu-1 (first row not menu)
            case menuDropbox:
            {
                if ([[DBSession sharedSession] isLinked]) {
                    //do log out from dropbox
                    [[DBSession sharedSession] unlinkAll];
                    NSLog(@"unlink dropbox");
                    
                    //refresh dropbox menu
                    [self refreshDropboxMenu];
                }
                else
                {
                    [self.navigationController pushViewController:[[RootViewController alloc] initWithNibName: @"RootViewController" bundle: nil] animated:YES];
                }
            }
                break;
            default:
                break;
        }
    }
}

- (void)communicateDropbox
{
    // Set these variables before launching the app
    NSString *appKey = [Utility getAppKey];
    NSString *appSecret = [Utility getAppSecret];
    NSString *root = kDBRootAppFolder; // Should be set to either kDBRootAppFolder or kDBRootDropbox
    // You can determine if you have App folder access or Full Dropbox along with your consumer key/secret
    // from https://dropbox.com/developers/apps
    
    // Look below where the DBSession is created to understand how to use DBSession in your app
    
    NSString* errorMsg = nil;
    if ([appKey rangeOfCharacterFromSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]].location != NSNotFound) {
        errorMsg = @"Make sure you set the app key correctly in DBRouletteAppDelegate.m";
    } else if ([appSecret rangeOfCharacterFromSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]].location != NSNotFound) {
        errorMsg = @"Make sure you set the app secret correctly in DBRouletteAppDelegate.m";
    } else if ([root length] == 0) {
        errorMsg = @"Set your root to use either App Folder of full Dropbox";
    } else {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
        NSData *plistData = [NSData dataWithContentsOfFile:plistPath];
        
        
        
        NSDictionary *loadedPlist = (NSDictionary *)[NSPropertyListSerialization propertyListWithData:plistData options:NSPropertyListMutableContainersAndLeaves format:NULL error:NULL];
        
        
        NSString *scheme = [[[[loadedPlist objectForKey:@"CFBundleURLTypes"] objectAtIndex:0] objectForKey:@"CFBundleURLSchemes"] objectAtIndex:0];
        if ([scheme isEqual:@"db-APP_KEY"]) {
            errorMsg = @"Set your URL scheme correctly in DBRoulette-Info.plist";
        }
    }
    
    DBSession *session =
    [[DBSession alloc] initWithAppKey:appKey appSecret:appSecret root:root];
    session.delegate = self; // DBSessionDelegate methods allow you to handle re-authenticating
    [DBSession setSharedSession:session];
    
    
    [DBRequest setNetworkRequestDelegate:self];
    
    if (errorMsg != nil) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error Configuring Session"
                                                                       message:errorMsg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


#pragma mark -
#pragma mark DBSessionDelegate methods

- (void)sessionDidReceiveAuthorizationFailure:(DBSession*)session userId:(NSString *)userId {
    relinkUserId = userId;
  
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Dropbox Session Ended"
                                                                   message:@"Do you want to relink?"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:
     [UIAlertAction actionWithTitle:@"Relink"
                              style:UIAlertActionStyleDestructive
                            handler:^(UIAlertAction *action) {
                                [[DBSession sharedSession] linkUserId:relinkUserId fromController:rootViewController];
                                relinkUserId = nil;
                            }]];
    [alert addAction:
     [UIAlertAction actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleCancel
                            handler:^(UIAlertAction *action) {
                                relinkUserId = nil;
                            }]];

    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -
#pragma mark DBNetworkRequestDelegate methods

static int outstandingRequests;

- (void)networkRequestStarted {
    outstandingRequests++;
    if (outstandingRequests == 1) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}

- (void)networkRequestStopped {
    outstandingRequests--;
    if (outstandingRequests == 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}


- (void)setWorking:(BOOL)isWorking {
    if (working == isWorking) return;
    working = isWorking;
    
    if (working) {
        [activityIndicator startAnimating];
    } else {
        [activityIndicator stopAnimating];
    }
    nextButton.enabled = !working;
}


#pragma mark DBRestClientDelegate methods

- (DBRestClient*)restClient {
    if (restClient == nil) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath
          metadata:(DBMetadata*)metadata
{
    NSLog(@"upload to dropbox successful");
}
- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
    //parse the error data for the file name
    NSString *fullErrorData = [NSString stringWithFormat:@"%@",error];
    NSString *answer;
    NSString *message;
    
    if ([fullErrorData containsString:@"FileBase"]) {
        NSRange range = [fullErrorData rangeOfString:@"FileBase"];
        NSRange newRange = {range.location,21};//the known length
        answer = [fullErrorData substringWithRange:newRange];
        
        message = [NSString stringWithFormat: @"The upload for file %@ failed. The remnants will be automatically deleted. You may receive an error message about the deletion - dismiss it.", answer];
    } else {
        message = @"Could not determine the file upload that failed.";
    }
    [self setWorking:NO];
    
}

-(void)itemsDownloaded:(NSArray *)items
{
    {
        PushSync *pushSync = [[PushSync alloc]init];
        pushSync.deviceToken = [Utility deviceToken];
        [_homeModel updateItems:dbPushSyncUpdateByDeviceToken withData:pushSync];
    }
    
    
    [Utility itemsDownloaded:items];
    [self removeOverlayViews];
    [self loadViewProcess];
}
- (void)itemsFail
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[Utility getConnectionLostTitle]
                                                                   message:[Utility getConnectionLostMessage]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [self loadingOverlayView];
                                                              [_homeModel downloadItems:dbMaster];
                                                          }];
    
    [alert addAction:defaultAction];
    dispatch_async(dispatch_get_main_queue(),^ {
        [self presentViewController:alert animated:YES completion:nil];
    } );
}
- (void)itemsUpdated
{
    
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

- (void) connectionFail
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[Utility subjectNoConnection]
                                                                   message:[Utility detailNoConnection]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              //                                                              exit(0);
                                                          }];
    
    [alert addAction:defaultAction];
    dispatch_async(dispatch_get_main_queue(),^ {
        [self presentViewController:alert animated:YES completion:nil];
    } );
}

@end
