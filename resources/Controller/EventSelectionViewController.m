//
//  EventInventoryMainViewController.m
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 8/9/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "EventSelectionViewController.h"
#import "EventInventoryScanViewController.h"
#import "UserMenuViewController.h"
#import "Utility.h"
#import "Event.h"
#import "SharedSelectedEvent.h"
#import "Login.h"
#import "UserAccountEvent.h"
#import "UserAccount.h"
#import "UserMenuViewController.h"
#import "SharedUserAccountEvent.h"
#import "SharedPushSync.h"
#import "PushSync.h"

#define orangeColor         [UIColor colorWithRed:253/255.0 green:182/255.0 blue:103/255.0 alpha:1]
#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]

@interface EventSelectionViewController (){
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSArray *_userAccountEventForUsernameList;
    Event *_event;
    NSIndexPath *_checkedIndexPath;
    NSArray *_eventListNowAndFutureAsc;
    NSArray *_eventListPastDesc;
    NSArray *_userAccountEventList;
    NSMutableArray *_eventInSection;
    BOOL _menuExtra;
}
@end

@implementation EventSelectionViewController
@synthesize username;
@synthesize btnMenuExtra;

- (IBAction)menuExtraClicked:(id)sender {
    _menuExtra = YES;
    [self performSegueWithIdentifier:@"segUserMenu" sender:self];
}

- (IBAction)unwindToEventSelection:(UIStoryboardSegue *)segue
{
    
}

- (void)loadView
{
    [super loadView];
    
    // Create new HomeModel object and assign it to _homeModel variable
    _homeModel = [[HomeModel alloc] init];
    _homeModel.delegate = self;
    
    {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);
    }

    
    [self loadViewProcess];
}

- (void)loadViewProcess
{
    if(![Utility getMenuExtra])
    {
        [self.navigationItem setRightBarButtonItem:nil];
    }
    
    _userAccountEventList = [SharedUserAccountEvent sharedUserAccountEvent].userAccountEventList;
    for(UserAccountEvent *item in _userAccountEventList)//add event info and username in userAccountEventList เพื่อเอาไป filter ด้วย username
    {
        Event *event = [Utility getEvent:[item.eventID integerValue]];
        item.location = event.location;
        item.remark = event.remark;
        item.periodFrom = event.periodFrom;
        item.periodTo = event.periodTo;
        item.productSalesSetID = event.productSalesSetID;
        item.eventModifiedDate = event.modifiedDate;
        
        
        item.username = [Utility getUsername:item.userAccountID];
    }
    
    
    
    
    
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_username = %@",username];
    _userAccountEventForUsernameList = [_userAccountEventList filteredArrayUsingPredicate:predicate1];
    NSMutableArray *userEventList = [[NSMutableArray alloc]init];
    for(UserAccountEvent *item in _userAccountEventForUsernameList)
    {
        Event *event = [Event getEvent:[item.eventID integerValue]];
        [userEventList addObject:event];
    }
    
    
    NSArray *arrOfEventList = [Event SplitEventNowAndFutureAndPast:userEventList];
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
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [SharedSelectedEvent sharedSelectedEvent].event = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"segUnwindToSignInVC"])
    {
        Login *login = [[Login alloc]init];
        login.username = [Utility modifiedUser];
        login.status = @"0";
        login.deviceToken = [Utility deviceToken];
        [_homeModel insertItems:dbLogin withData:login];
        [Utility setModifiedUser:@""];
    }
    else if([[segue identifier] isEqualToString:@"segUserMenu"])
    {
        UserMenuViewController *vc = [segue destinationViewController];
        vc.menuExtra = _menuExtra;
    }
    //usermenu
}

- (void)itemsInserted
{
}

-(void)setData
{
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_username = %@",username];
    _userAccountEventForUsernameList = [_userAccountEventList filteredArrayUsingPredicate:predicate1];
    NSMutableArray *eventList = [[NSMutableArray alloc]init];
    for(UserAccountEvent *item in _userAccountEventForUsernameList)
    {
        Event *event = [[Event alloc]init];
        event.eventID = [item.eventID integerValue];
        event.location = item.location;
        event.remark = item.remark;
        event.productSalesSetID = item.productSalesSetID;
        event.modifiedDate = item.modifiedDate;
        event.modifiedUser = item.modifiedUser;
        event.periodFrom = item.periodFrom;
        event.periodTo = item.periodTo;
        [eventList addObject:event];
    }
    
    
    NSArray *arrOfEventList = [Event SplitEventNowAndFutureAndPast:eventList];
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

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    [headerView setBackgroundColor:tBlueColor];
    
    
    UILabel *titleLabel = [ [UILabel alloc] initWithFrame:CGRectMake(8, 0, 300, 20)];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
    titleLabel.text = _eventInSection[section][0];//_sectionName[section];
    titleLabel.textColor = [UIColor whiteColor];
    [headerView addSubview:titleLabel];
    
    return headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [_eventInSection count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  [_eventInSection[section][1] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"reuseIdentifier";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }

    NSMutableArray *eventList = _eventInSection[indexPath.section][1];
    Event *event = eventList[indexPath.row];
    cell.textLabel.text = event.location;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", [Utility formatDateForDisplay:event.periodFrom],[Utility formatDateForDisplay:event.periodTo]];
    cell.detailTextLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *eventList = _eventInSection[indexPath.section][1];
    Event *event = eventList[indexPath.row];
    [SharedSelectedEvent sharedSelectedEvent].event = event;
    _menuExtra = NO;
    [self performSegueWithIdentifier:@"segUserMenu" sender:self];
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
}@end
