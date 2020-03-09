//
//  UserAccountEventViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 9/10/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "UserAccountEventViewController.h"
#import "Utility.h"
#import "MasterListViewController.h"
#import "Event.h"
#import "UserAccountEvent.h"
#import "SharedEvent.h"
#import "SharedUserAccount.h"
#import "SharedUserAccountEvent.h"
#import "SharedPushSync.h"
#import "PushSync.h"

#define orangeColor         [UIColor colorWithRed:253/255.0 green:182/255.0 blue:103/255.0 alpha:1]
#define tBlueColor         [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]

@interface UserAccountEventViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSInteger _userAccountID;
    NSString *_username;
    NSArray *_eventList;
    NSMutableArray *_selectedAssignedEvent;
    NSMutableArray *_userAccountEventList;
    NSArray *_eventListNowAndFutureAsc;
    NSArray *_eventListPastDesc;
    NSArray *_previousEventListNowAndFutureAsc;
    NSArray *_previousEventListPastDesc;
    NSArray *_previousSelectedIndexPaths;
    NSMutableArray *_eventInSection;
}
@end

@implementation UserAccountEventViewController

- (IBAction)unwindToUserAccountEvent:(UIStoryboardSegue *)segue
{
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
            
            if(source.masterType == userAccount)
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text = selectedValue;
                _userAccountID = [selectedKey integerValue];
                _username = selectedValue;
            }
            

            _userAccountEventList = [SharedUserAccountEvent sharedUserAccountEvent].userAccountEventList;
            {
                _eventList = [SharedEvent sharedEvent].eventList;
                {
                    NSArray *arrOfEventList = [Event SplitEventNowAndFutureAndPast:_eventList];
                    _eventListNowAndFutureAsc = arrOfEventList[0];
                    _eventListPastDesc = arrOfEventList[1];
                    
                    _eventInSection = [[NSMutableArray alloc]init];
                    if([_eventListNowAndFutureAsc count]>0)
                    {
                        [_eventInSection addObject:@[@"Event: Ongoing",_eventListNowAndFutureAsc]];
                    }
                    if([_eventListPastDesc count]>0)
                    {
                        [_eventInSection addObject:@[@"Event: Past",_eventListPastDesc]];
                    }

                    [self.tableView reloadData];
                    [self selectEventAfterDownload];
                }
            }
        }
    }
}

-(void)selectEventAfterDownload
{
    //deselect all event
    for(int i=0; i<[_eventInSection count]; i++)
    {
        NSMutableArray *eventList = _eventInSection[i][1];
        for(int j=0; j<[eventList count]; j++)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i+1];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }

    //select responsible event
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_userAccountID = %ld",_userAccountID];
    NSArray *filterArray = [_userAccountEventList filteredArrayUsingPredicate:predicate1];
    
    
    BOOL found = NO;
    for(UserAccountEvent *item in filterArray)
    {
        for(int i=0; i<[_eventInSection count]; i++)
        {
            NSMutableArray *eventList = _eventInSection[i][1];
            for(int j=0; j<[eventList count]; j++)
            {
                Event *event = eventList[j];
                if(event.eventID == [item.eventID integerValue])
                {
                    found = YES;
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i+1];
                    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                    break;
                }
            }
            if(found)
            {
                found = NO;
                break;
            }
        }
    }
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
    
    
    _selectedAssignedEvent = [[NSMutableArray alloc]init];
    _username = @"";
    
    
    [self loadViewProcess];
}

- (void)loadViewProcess
{
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    [self.tableView setEditing:YES animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL allowEdit = NO;
    if(indexPath.section == 1 || indexPath.section == 2)
    {
        allowEdit = YES;
    }
    return allowEdit;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1+[_eventInSection count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)return 1;
    else{ return [_eventInSection[section-1][1] count];}
//    return section == 0?1:section == 1?[_eventListNowAndFutureAsc count]:[_eventListPastDesc count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }

    
    NSInteger section = indexPath.section;
    if(section == 0)
    {
        switch (indexPath.row) {
            case 0:
            {
                cell.textLabel.text = @"User account";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.detailTextLabel.text = _username;
            }
            break;
        }
    }
    else
    {
        NSMutableArray *eventList = _eventInSection[indexPath.section-1][1];
        Event *event = eventList[indexPath.row];
        cell.detailTextLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
        cell.textLabel.text = event.location;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", [Utility formatDateForDisplay:event.periodFrom],[Utility formatDateForDisplay:event.periodTo]];
    }
    return cell;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIColor *color = tBlueColor;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    [headerView setBackgroundColor:color];
    
    
    UILabel *titleLabel = [ [UILabel alloc] initWithFrame:CGRectMake(8, 0, 300, 20)];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
    titleLabel.text = section == 0?@"User account":_eventInSection[section-1][0];//_sectionName[section];
    titleLabel.textColor = [UIColor whiteColor];
    [headerView addSubview:titleLabel];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //case 0 go to pro cat 2 list
    //case 1 go to pro cat 1 list
    NSInteger section = indexPath.section;
    if(section == 0)
    {
        switch (indexPath.row) {
            case 0:
            {
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                _eventListNowAndFutureAsc = @[];
                _eventListPastDesc = @[];
                [_eventInSection removeAllObjects];
                [tableView reloadData];
                [self performSegueWithIdentifier:@"segMasterUserAccount" sender:self];
            }
            break;
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"segMasterUserAccount"])
    {
        MasterListViewController *vc = segue.destinationViewController;
        vc.masterType = userAccount;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (IBAction)saveUserAccountEvent:(id)sender
{
    //validate user account selected
    //update useraccountevent
    if(!_userAccountID)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"User account missing"
                                                                       message:@"Please select user account"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action){}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
        
    
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    if([selectedRows count] == 0)
    {
        UserAccountEvent *userAccountEvent = [[UserAccountEvent alloc]init];
        userAccountEvent.userAccountID = _userAccountID;
        [_homeModel deleteItems:dbUserAccountEvent withData:userAccountEvent];
        
        
        //update shareduseraccountevent
        NSMutableArray *removeItems = [[NSMutableArray alloc]init];
        for(UserAccountEvent *item in _userAccountEventList)
        {
            if(item.userAccountID == _userAccountID)
            {
                [removeItems addObject:item];
            }
        }
        [_userAccountEventList removeObjectsInArray:removeItems];
        
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                       message:@"Assign event to user account success"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        NSInteger userAccountEventID = [Utility getNextID:tblUserAccountEvent];
        //update shared
        //remove
        NSMutableArray *removeItems = [[NSMutableArray alloc]init];
        for(UserAccountEvent *item in _userAccountEventList)
        {
            if(item.userAccountID == _userAccountID)
            {
                [removeItems addObject:item];
            }
        }
        [_userAccountEventList removeObjectsInArray:removeItems];
        
        //insert
        NSMutableArray *userAccountEventEditList = [[NSMutableArray alloc]init];
        for(NSIndexPath *item in selectedRows)
        {
            UserAccountEvent *userAccountEvent = [[UserAccountEvent alloc]init];
            NSMutableArray *eventList = _eventInSection[item.section-1][1];
            Event *event = eventList[item.row];
            NSString *strEventID = [NSString stringWithFormat:@"%ld",event.eventID];
            userAccountEvent.userAccountEventID = userAccountEventID;
            userAccountEvent.userAccountID = _userAccountID;
            userAccountEvent.eventID = strEventID;
            
            
            [_userAccountEventList addObject:userAccountEvent];
            [userAccountEventEditList addObject:userAccountEvent];
            userAccountEventID++;
        }
        //delete then insert
        [_homeModel insertItems:dbUserAccountEventDeleteThenMultipleInsert withData:userAccountEventEditList];
        
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                       message:@"Assign event to user account success"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
- (void)itemsInserted
{
}
- (void)itemsDeleted
{
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
