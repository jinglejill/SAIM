//
//  FixCostViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/24/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "FixedCostViewController.h"
#import "HomeModel.h"
#import "Utility.h"
#import "ProductCost.h"
#import "EventCost.h"
#import "CustomUITableViewCell2.h"
#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"

#import "SharedEventCost.h"
#import "SharedPushSync.h"
#import "PushSync.h"

#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]
@interface FixedCostViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSMutableArray *_eventCostList;
    NSMutableArray *_eventCostDefaultList;
    NSMutableArray *_eventCostNewList;
    NSString *_strEventID;
}
@end

@implementation FixedCostViewController
@synthesize event;
@synthesize tableViewFixedCost;

- (IBAction)unwindToFixedCost:(UIStoryboardSegue *)segue
{

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register cell classes
    [tableViewFixedCost registerClass:[MGSwipeTableCell class] forCellReuseIdentifier:@"FixedCost"];
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
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);
    }
    
    
    
    _eventCostDefaultList = [[NSMutableArray alloc]init];
    _eventCostNewList = [[NSMutableArray alloc]init];
    _strEventID = [NSString stringWithFormat:@"%ld",event.eventID];
    
    
    [self loadViewProcess];
}

- (void)loadViewProcess
{
    _eventCostList = [SharedEventCost sharedEventCost].eventCostList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_eventID = %@",_strEventID];
    NSArray *filterArray = [_eventCostList filteredArrayUsingPredicate:predicate1];
    _eventCostList = [filterArray mutableCopy];
    
    {
        EventCost *eventCost = [[EventCost alloc]init];
        eventCost.eventID = _strEventID;
        eventCost.costLabelID = @"1";
        eventCost.costLabel = @"";
        eventCost.cost = [self getCost:@"1"];
        [_eventCostDefaultList addObject:eventCost];
    }
    {
        EventCost *eventCost = [[EventCost alloc]init];
        eventCost.eventID = _strEventID;
        eventCost.costLabelID = @"2";
        eventCost.costLabel = @"";
        eventCost.cost = [self getCost:@"2"];
        [_eventCostDefaultList addObject:eventCost];
    }
    {
        EventCost *eventCost = [[EventCost alloc]init];
        eventCost.eventID = _strEventID;
        eventCost.costLabelID = @"3";
        eventCost.costLabel = @"";
        eventCost.cost = [self getCost:@"3"];
        [_eventCostDefaultList addObject:eventCost];
    }
    {
        EventCost *eventCost = [[EventCost alloc]init];
        eventCost.eventID = _strEventID;
        eventCost.costLabelID = @"4";
        eventCost.costLabel = @"";
        eventCost.cost = [self getCost:@"4"];
        [_eventCostDefaultList addObject:eventCost];
    }
    
    
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"_costLabelID != %@ && _costLabelID != %@ && _costLabelID != %@ && _costLabelID != %@",@"1",@"2",@"3",@"4"];
    NSArray *filterArray2 = [_eventCostList filteredArrayUsingPredicate:predicate2];
    _eventCostNewList = [filterArray2 mutableCopy];
    
    
    [tableViewFixedCost reloadData];
}

-(NSString *)getCost:(NSString *) costLabelID
{
    for(EventCost *item in _eventCostList)
    {
        if([item.costLabelID isEqualToString:costLabelID])
        {
            return item.cost;
        }
    }
    return @"0";
}

enum enumFixedCost
{
    fixedCostRent,
    fixedCostTransportation,
    fixedCostStaff,
    fixedCostOther
};

#pragma mark - UITableViewDataSource

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.000001f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0?[_eventCostDefaultList count]:[_eventCostNewList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MGSwipeTableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"FixedCost"];
    if (cell == nil) {
        cell = [[MGSwipeTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"FixedCost"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    if ([cell.costLabel isDescendantOfView:cell]) {
        [cell.costLabel removeFromSuperview];
    }
    if ([cell.textNewLabel isDescendantOfView:cell]) {
        [cell.textNewLabel removeFromSuperview];
    }
    

    if(section == 0)
    {
        EventCost *eventCost = _eventCostDefaultList[row];
        switch (indexPath.row) {
            case fixedCostRent:
            {
                cell.costLabel.text = @"Rent";
                [cell.costLabel setTextColor:tBlueColor];
                [cell addSubview:cell.costLabel];
                
                //data from load or edit
                cell.textField.text = eventCost.cost;
            }
                break;
            case fixedCostTransportation:
            {
                cell.costLabel.text = @"Transportation";
                [cell.costLabel setTextColor:tBlueColor];
                [cell addSubview:cell.costLabel];
                
                //data from load or edit
                cell.textField.text = eventCost.cost;
            }
                break;
            case fixedCostStaff:
            {
                cell.costLabel.text = @"Staff";
                [cell.costLabel setTextColor:tBlueColor];
                [cell addSubview:cell.costLabel];
                
                //data from load or edit
                cell.textField.text = eventCost.cost;
            }
                break;
            case fixedCostOther:
            {
                cell.costLabel.text = @"Other";
                [cell.costLabel setTextColor:tBlueColor];
                [cell addSubview:cell.costLabel];
                
                //data from load or edit
                cell.textField.text = eventCost.cost;
            }
                break;
            default:
                break;
        }
    }
    else if(section == 1)
    {
        EventCost *eventCost = _eventCostNewList[row];
        
        cell.textNewLabel.text = eventCost.costLabel;
        cell.textNewLabel.placeholder = @"New label";
        [cell.contentView addSubview:cell.textNewLabel];
        [cell.textNewLabel setTextColor:tBlueColor];
        
        //data from load or edit
        cell.textField.text = eventCost.cost;        
        cell.rightButtons = [self createRightButtons:1 indexPath:indexPath];// withData:event section:indexPath.section];
    }
    
    return cell;
}

-(NSArray *) createRightButtons: (int) number indexPath:(NSIndexPath*)indexPath// withData:(Event *)event section:(NSInteger) section
{
    NSMutableArray * result = [NSMutableArray array];
    NSString* titles[1] = {@"Delete"};
    UIColor * colors[1] = {[UIColor redColor]};
    for (int i = 0; i < number; ++i)
    {
        MGSwipeButton * button = [MGSwipeButton buttonWithTitle:titles[i] backgroundColor:colors[i] callback:^BOOL(MGSwipeTableCell * sender){
            if (i==0)
            {
                NSLog(@"delete cost");
                
            
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                               message:nil
                                                                        preferredStyle:UIAlertControllerStyleActionSheet];
                [alert addAction:
                 [UIAlertAction actionWithTitle:@"Delete cost"
                                          style:UIAlertActionStyleDestructive
                                        handler:^(UIAlertAction *action) {
                                            
                                            [self updateDefaultAndAddNewData];
                                            
                                            
                                            [_eventCostNewList removeObjectAtIndex:indexPath.row];
                                            
                                            
                                            //reload table
                                            [tableViewFixedCost reloadData];
                                                                                    
                                        }]];
                [alert addAction:
                 [UIAlertAction actionWithTitle:@"Cancel"
                                          style:UIAlertActionStyleCancel
                                        handler:^(UIAlertAction *action) {}]];
                
                [self presentViewController:alert animated:YES completion:nil];
            }
            
            BOOL autoHide = i != 0;
            return autoHide; //Don't autohide in delete button to improve delete expansion animation
        }];
        [result addObject:button];
    }
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark - Life Cycle method
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return YES;
}

- (BOOL)validateData
{
    return YES;
}

-(void)updateDefaultAndAddNewData
{
    //update data in defaultLabelList
    for(int i=0; i<[_eventCostDefaultList count]; i++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        MGSwipeTableCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        EventCost *eventCost = _eventCostDefaultList[i];
        if(cell != nil)
        {
            eventCost.cost = [cell.textField.text isEqualToString:@""]?@"0":cell.textField.text;
            eventCost.costLabel = @"";
        }
    }
    
    //add current data to temp
    //remove all newLabelList
    //add temp data to newlabellist
    NSMutableArray *eventCostNewList = [[NSMutableArray alloc]init];
    for(int i=0; i<[_eventCostNewList count]; i++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:1];
        MGSwipeTableCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//        [cell.textNewLabel setKeyboardType:UIKeyboardTypeDefault];
        EventCost *eventCost = [[EventCost alloc]init];
        if(cell != nil)
        {
            eventCost.eventID = _strEventID;
            eventCost.costLabelID = @"0";
            eventCost.costLabel = cell.textNewLabel.text;
            eventCost.cost = [cell.textField.text isEqualToString:@""]?@"0":cell.textField.text;
        }
        [eventCostNewList addObject:eventCost];
    }
    [_eventCostNewList removeAllObjects];
    [_eventCostNewList addObjectsFromArray:eventCostNewList];
}

- (IBAction)addLabel:(id)sender {
    
    [self updateDefaultAndAddNewData];
    
    
    //add new row
    //reload table
    EventCost *eventCost = [[EventCost alloc]init];
    eventCost.eventID = _strEventID;
    eventCost.costLabelID = @"0";
    eventCost.costLabel = @"";
    eventCost.cost = @"0";
    [_eventCostNewList addObject:eventCost];
    
    [tableViewFixedCost reloadData];
}

- (IBAction)doneButtonClicked:(id)sender {
    
    [self updateDefaultAndAddNewData];
    
    //prepare data for insert (check label="", cost="")
    NSInteger nextID = [Utility getNextID:tblEventCost];
    _eventCostList = [[NSMutableArray alloc]init];
    for(int i=0; i<[_eventCostDefaultList count]; i++)
    {
        EventCost *eventCost = _eventCostDefaultList[i];
        if(![[Utility trimString:eventCost.cost] isEqualToString:@""] && [eventCost.cost intValue] != 0)
        {
            eventCost.eventCostID = nextID++;
            eventCost.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
            eventCost.modifiedUser = [Utility modifiedUser];
            [_eventCostList addObject:eventCost];
        }
    }
    for(int i=0; i<[_eventCostNewList count]; i++)
    {
        EventCost *eventCost = _eventCostNewList[i];
        if(![[Utility trimString:eventCost.cost] isEqualToString:@""] && [eventCost.cost intValue] != 0 && ![[Utility trimString:eventCost.costLabel] isEqualToString:@""])
        {
            eventCost.eventCostID = nextID++;
            eventCost.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
            eventCost.modifiedUser = [Utility modifiedUser];
            [_eventCostList addObject:eventCost];
        }
    }

    
    [_homeModel insertItems:dbEventCost withData:_eventCostList];
    [self updateSharedDataAfterInsert];
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
- (void)updateSharedDataAfterDelete
{
    NSMutableArray *eventCostList = [SharedEventCost sharedEventCost].eventCostList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_eventID = %@",_strEventID];
    NSArray *filterArray = [_eventCostList filteredArrayUsingPredicate:predicate1];
    [eventCostList removeObjectsInArray:filterArray];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)updateSharedDataAfterInsert
{
    //update shared eventcostlist(remove and insert new)
    NSMutableArray *eventCostList = [SharedEventCost sharedEventCost].eventCostList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_eventID = %@",_strEventID];
    NSArray *filterArray = [eventCostList filteredArrayUsingPredicate:predicate1];
    [eventCostList removeObjectsInArray:filterArray];
    
    [eventCostList addObjectsFromArray:_eventCostList];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)itemsInserted
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
