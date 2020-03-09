//
//  EventViewController.m
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/24/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "EventViewController.h"
#import "AddEditEventViewController.h"
#import "Event.h"
#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"
#import "Utility.h"
#import "UserAccountEvent.h"
#import "FixedCostViewController.h"



#import "SharedProduct.h"
#import "SharedEvent.h"
#import "SharedUserAccountEvent.h"


#import "SharedPushSync.h"
#import "PushSync.h"

#define orangeColor         [UIColor colorWithRed:253/255.0 green:182/255.0 blue:103/255.0 alpha:1]
#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]

@interface EventViewController (){
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSMutableArray *_eventList;
    Event *_event;
    NSString *_strEventID;
    NSArray *_eventListNowAndFutureAsc;
    NSArray *_eventListPastDesc;
    NSMutableArray *_eventInSection;
}
@end

@implementation EventViewController
@synthesize currentAction;
-(void)updateSharedDataAfterInsert
{
    [_eventList addObject:_event];
    
    
    NSArray *arrOfEventList = [Event SplitEventNowAndFutureAndPast:_eventList];
    _eventListNowAndFutureAsc = arrOfEventList[0];
    _eventListPastDesc = arrOfEventList[1];
    
    
    [self setData];
    [self.tableView reloadData];
}
- (IBAction)unwindToEventList:(UIStoryboardSegue *)segue
{
    AddEditEventViewController *source = [segue sourceViewController];
    _event = source.event;
    currentAction = source.currentAction;
    
    if (_event != nil) {
        
        if(currentAction == add)
        {
            _event.modifiedUser = [Utility modifiedUser];
            [_homeModel insertItems:dbEvent withData:_event];
            [self loadingOverlayView];
            //            [self updateSharedDataAfterInsert];
        }
        else if(currentAction == edit)
        {
            [_homeModel updateItems:dbEvent withData:_event];
            //update shareevent
            for(Event *event in [SharedEvent sharedEvent].eventList)
            {
                if(event.eventID == _event.eventID)
                {
                    event.location = _event.location;
                    //                    event.periodFrom = [Utility formatDateForDisplay:_event.periodFrom];
                    //                    event.periodTo = [Utility formatDateForDisplay:_event.periodTo];
                    event.periodFrom = _event.periodFrom;
                    event.periodTo = _event.periodTo;
                    event.remark = _event.remark;
                    event.productSalesSetID = _event.productSalesSetID;
                    event.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                    event.modifiedUser = [Utility modifiedUser];
                    break;
                }
            }
            
            _eventList = [SharedEvent sharedEvent].eventList;
            [self setData];
            [self.tableView reloadData];
        }
    }
    else
    {
        self.navigationController.toolbarHidden = NO;
    }
}
- (void)setData
{
    NSArray *arrOfEventList = [Event SplitEventNowAndFutureAndPast:_eventList];
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
    _eventList = [SharedEvent sharedEvent].eventList;
    NSArray *arrOfEventList = [Event SplitEventNowAndFutureAndPast:_eventList];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
}
- (void)selectAddEditRow
{
    if(currentAction == add)
    {
        NSInteger maxEventID = -1;
        NSInteger row = 0;
        NSInteger addEditRow = row;
        for(Event *event in _eventList)
        {
            if(event.eventID > maxEventID)
            {
                maxEventID = event.eventID;
                addEditRow = row;
            }
            row = row +1;
        }
        NSIndexPath *path = [NSIndexPath indexPathForRow:addEditRow inSection:0];
        [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

-(void)itemsInsertedWithReturnData:(NSMutableArray *)data
{
    [self removeOverlayViews];
    [Utility addToSharedDataList:data];
    [self loadViewProcess];
}

-(void)itemsDeleted
{
    
}
-(void)itemsUpdated
{
}

#pragma mark - Table view data source
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    [headerView setBackgroundColor:tBlueColor];
    
    
    UILabel *titleLabel = [ [UILabel alloc] initWithFrame:CGRectMake(8, 0, 300, 20)];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
    titleLabel.text = _eventInSection[section][0];
    titleLabel.textColor = [UIColor whiteColor];
    [headerView addSubview:titleLabel];
    
    return headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [_eventInSection count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return  [_eventInSection[section][1] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = @"reuseIdentifier";
    MGSwipeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell){
        cell = [[MGSwipeTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier: cellIdentifier];
    }
    
    NSMutableArray *eventList = _eventInSection[indexPath.section][1];
    Event *event = eventList[indexPath.row];
    cell.textLabel.text = event.location;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", [Utility formatDateForDisplay:event.periodFrom],[Utility formatDateForDisplay:event.periodTo]];
    cell.detailTextLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
    cell.rightButtons = [self createRightButtons:3 withData:event section:indexPath.section];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(NSArray *) createRightButtons: (int) number withData:(Event *)event section:(NSInteger) section
{
    NSMutableArray * result = [NSMutableArray array];
    NSString* titles[3] = {@"Delete", @"Edit", @"Cost"};
    UIColor * colors[3] = {[UIColor redColor], [UIColor lightGrayColor], tBlueColor};
    for (int i = 0; i < number; ++i)
    {
        MGSwipeButton * button = [MGSwipeButton buttonWithTitle:titles[i] backgroundColor:colors[i] callback:^BOOL(MGSwipeTableCell * sender){
            if (i==0)
            {
                NSLog(@"delete event");
                _event = event;
                if([self eventIsBeingUsed])
                {
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning: cannot delete"
                                                                                   message:@"This event is being used"
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {}];
                    
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                else
                {
                    int j=0;
                    for(Event *item in _eventList)
                    {
                        if([item isEqual:event])
                        {
                            break;
                        }
                        j++;
                    }
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:0];
                    MGSwipeTableCell *cell = (MGSwipeTableCell*)[self.tableView cellForRowAtIndexPath:indexPath];
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                                   message:nil
                                                                            preferredStyle:UIAlertControllerStyleActionSheet];
                    [alert addAction:
                     [UIAlertAction actionWithTitle:@"Delete event"
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction *action) {
                                                currentAction = delete;
                                                [_homeModel deleteItems:dbEvent withData:event];
                                                
                                                
                                                
                                                //delete from sharedevent
                                                for(Event *item in _eventList)
                                                {
                                                    if(item.eventID == _event.eventID)
                                                    {
                                                        [_eventList removeObject:item];
                                                        break;
                                                    }
                                                }
                                                [self loadViewProcess];
                                                //                                                 NSArray *arrOfEventList = [Event SplitEventNowAndFutureAndPast:_eventList];
                                                //                                                 _eventListNowAndFutureAsc = arrOfEventList[0];
                                                //                                                 _eventListPastDesc = arrOfEventList[1];
                                                //                                                 [self.tableView reloadData];
                                            }]];
                    [alert addAction:
                     [UIAlertAction actionWithTitle:@"Cancel"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction *action) {}]];
                    
                    
                    ///////////////ipad
                    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
                    {
                        [alert setModalPresentationStyle:UIModalPresentationPopover];
                        
                        UIPopoverPresentationController *popPresenter = [alert
                                                                         popoverPresentationController];
                        //                        CGRect frame = cell.imageView.bounds;
                        //                        frame.origin.y = frame.origin.y-15;
                        popPresenter.sourceView = cell;
                        popPresenter.sourceRect = cell.bounds;
                        //        popPresenter.barButtonItem = _barButtonIpad;
                    }
                    ///////////////
                    [self presentViewController:alert animated:YES completion:nil];
                }
                
            }
            else if(i == 1)
            {
                NSLog(@"edit event");
                NSString * storyboardName = @"Main";
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                AddEditEventViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"AddEditEventViewController"];
                vc.event = event;
                [self.navigationController pushViewController:vc animated:YES];
            }
            else if(i == 2)
            {
                NSLog(@"set event cost");
                NSString * storyboardName = @"Main";
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                FixedCostViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"FixCostViewController"];
                vc.event = event;
                [self.navigationController pushViewController:vc animated:YES];
            }
            BOOL autoHide = i != 0;
            return autoHide; //Don't autohide in delete button to improve delete expansion animation
        }];
        [result addObject:button];
    }
    return result;
}
-(BOOL)eventIsBeingUsed
{
    //check user account event, product
    NSString *strEventID = [NSString stringWithFormat:@"%ld",_event.eventID];
    
    
    {
        NSMutableArray *userAccountEventList = [SharedUserAccountEvent sharedUserAccountEvent].userAccountEventList;
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_eventID = %ld",strEventID];
        NSArray *filterData = [userAccountEventList filteredArrayUsingPredicate:predicate1];
        if([filterData count] > 0)
        {
            return YES;
        }
    }
    {
        NSMutableArray *productList = [SharedProduct sharedProduct].productList;
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_eventID = %ld",strEventID];
        NSArray *filterData = [productList filteredArrayUsingPredicate:predicate1];
        if([filterData count] > 0)
        {
            return YES;
        }
    }
    
    return NO;
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


