//
//  UserAccountViewController.m
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/9/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//
#import <MessageUI/MessageUI.h> 
#import <MessageUI/MFMailComposeViewController.h>
#import "UserAccountViewController.h"
#import "AddUserAccountViewController.h"
#import "UserAccount.h"
#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"
#import "Utility.h"
#import "UserAccountEvent.h"
#import "SharedUserAccount.h"
#import "SharedUserAccountEvent.h"
#import "SharedPushSync.h"
#import "PushSync.h"
#import "KeychainWrapper.h"


@interface UserAccountViewController (){
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    UserAccount *_userAccount;
    NSMutableArray *_userAccountList;
    NSInteger sendMailStatus;
}
@end
@implementation UserAccountViewController
@synthesize currentAction;
@synthesize btnAdd;

- (IBAction)unwindToUserAccount:(UIStoryboardSegue *)segue {
    AddUserAccountViewController *source = [segue sourceViewController];
    _userAccount = source.userAccount;
    UserAccount *userAccount = [_userAccount copy];
    
    
    NSString *password = _userAccount.password;
    NSUInteger fieldHash = [password hash];
    NSString *fieldString = [KeychainWrapper securedSHA256DigestHashForPIN:fieldHash];
    userAccount.password = fieldString;
    userAccount.modifiedUser = [Utility modifiedUser];
    if (_userAccount) {
        [_homeModel insertItems:dbUserAccount withData:userAccount];
        
        
        //update shareduseraccount
        [[SharedUserAccount sharedUserAccount].userAccountList addObject:userAccount];
        currentAction = add;
        [self setData];
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    //validate username must be email
    if([sender isEqual:btnAdd]){
        if(![self validateData])
        {
            return NO;
        }
    }
    return YES;
}
- (BOOL)validateData
{
    //location not empty
    if([_userAccountList count] == [[Utility setting:vAllowUserCount] intValue])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Not allow"
                                                                       message:[NSString stringWithFormat:@"User limit: %@",[Utility setting:vAllowUserCount]]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    return YES;
    
}
- (void)loadView
{
    [super loadView];
    
    _homeModel = [[HomeModel alloc] init];
    _homeModel.delegate = self;
    
    {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);
    }
    
    
    currentAction = list;
    
    
    [self loadViewProcess];
}

- (void)loadViewProcess
{
    _userAccountList = [SharedUserAccount sharedUserAccount].userAccountList;
    [self setData];    
}

-(void)setData
{
    NSArray *descriptor = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"_username" ascending:YES]];
    NSArray *sortedArray = [_userAccountList sortedArrayUsingDescriptors:descriptor];
    _userAccountList =[sortedArray mutableCopy];
    
    
    [self.tableView reloadData];
    
    
    switch (currentAction) {
        case list:{
            break;
        }
        case add:{
            NSString *subject = [Utility msg:emailSubjectAdd];
            NSString *body = [NSString stringWithFormat:[Utility msg:emailBodyAdd],_userAccount.username, _userAccount.password];
            [self sendEmail:_userAccount.username withSubject:subject andBody:body];
            sendMailStatus = 1;
            break;
        }
        case edit:
        {
            NSString *subject = [Utility msg:emailSubjectReset];
            NSString *body = [NSString stringWithFormat:[Utility msg:emailBodyReset],_userAccount.username, _userAccount.password];
            [self sendEmail:_userAccount.username withSubject:subject andBody:body];
            sendMailStatus = 1;
            break;
        }
        case delete:{
            break;
        }
        default:
        break;
    }
}

-(void)itemsInserted
{

}

-(void)itemsDeleted
{

}

-(void)itemsUpdated
{

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _userAccountList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Retrieve cell
    NSString *cellIdentifier = @"reuseIdentifier";
    MGSwipeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
        cell = [[MGSwipeTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: cellIdentifier];
    
    // Get the location to be shown
    UserAccount *userAccount = _userAccountList[indexPath.row];
    
    // Get references to labels of cell
    cell.textLabel.text = [NSString stringWithFormat:@"%@",userAccount.username];
    cell.detailTextLabel.text = @"";
    cell.rightButtons = [self createRightButtons:2 withData:userAccount];
    
    return cell;
}

-(NSArray *) createRightButtons: (int) number withData:(UserAccount *)userAccount
{
    
    NSMutableArray * result = [NSMutableArray array];
    NSString* titles[2] = {@"Delete", @"Reset"};
    UIColor * colors[2] = {[UIColor redColor], [UIColor lightGrayColor]};
    for (int i = 0; i < number; ++i)
    {
        MGSwipeButton * button = [MGSwipeButton buttonWithTitle:titles[i] backgroundColor:colors[i] callback:^BOOL(MGSwipeTableCell * sender){
            if (i==0)
            {
                NSLog(@"delete user account");
//                _userAccount = userAccount;
                if([self userAccountIsBeingUsed])
                {
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning: cannot delete"
                                                                                   message:@"This user account is being used"
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {}];
                    
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                else
                {
                    int j=0;
                    for(UserAccount *item in _userAccountList)
                    {
                        if([item isEqual:userAccount])
                        {
                            break;
                        }
                        j++;
                    }
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:0];
                    MGSwipeTableCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                    
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                                   message:nil
                                                                            preferredStyle:UIAlertControllerStyleActionSheet];
                    [alert addAction:
                     [UIAlertAction actionWithTitle:@"Delete user account"
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction *action) {
                                                
                                                [_homeModel deleteItems:dbUserAccount withData:userAccount];
                                                
                                                
                                                //update shareduseraccount
                                                [[SharedUserAccount sharedUserAccount].userAccountList removeObject:userAccount];
                                                currentAction = delete;
                                                [self setData];
                                                
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
            else
            {
                NSLog(@"reset password");
                
                
                NSString *newPassword = [Utility randomStringWithLength:6];
                NSUInteger fieldHash = [newPassword hash];
                NSString *fieldString = [KeychainWrapper securedSHA256DigestHashForPIN:fieldHash];
                
                
                
                userAccount.password = fieldString;
                userAccount.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                userAccount.modifiedUser = [Utility modifiedUser];
//                _userAccount = userAccount;
                
                [_homeModel updateItems:dbUserAccount withData:userAccount];
                
                
                _userAccount = [userAccount copy];
                _userAccount.password = newPassword;
                currentAction = edit;
                [self setData];
            }
            BOOL autoHide = i != 0;
            return autoHide; //Don't autohide in delete button to improve delete expansion animation
        }];
        [result addObject:button];
    }
    return result;
}
-(BOOL)userAccountIsBeingUsed
{
    //check user account event
    {
        NSMutableArray *userAccountEventList = [SharedUserAccountEvent sharedUserAccountEvent].userAccountEventList;
        for(UserAccountEvent *item in userAccountEventList)
        {
            item.username = [Utility getUsername:item.userAccountID];
        }
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_username = %@",_userAccount.username];
        NSArray *filterData = [userAccountEventList filteredArrayUsingPredicate:predicate1];
        if([filterData count] > 0)
        {
            return YES;
        }
    }
    
    return NO;
}
-(void)sendEmail:(NSString *)toAddress withSubject:(NSString *)subject andBody:(NSString *)body
{
    MFMailComposeViewController *mcvc = [[MFMailComposeViewController alloc] init];
    mcvc.mailComposeDelegate = self;
    [mcvc setToRecipients:[NSArray arrayWithObjects:toAddress,nil]];
    [mcvc setSubject:subject];
    [mcvc setMessageBody:body isHTML:YES];
    if ([MFMailComposeViewController canSendMail])
    {
        [self presentViewController:mcvc animated:YES completion:nil];
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(sendMailStatus == 1)
    {
        [self selectAddEditRow];
        sendMailStatus =0;
    }
}

- (void)selectAddEditRow
{
    if(currentAction == add)
    {
        NSDate *maxDate = [Utility setDateWithYear:2015 month:01 day:01];
        NSInteger row = 0;
        NSInteger addEditRow = row;
        for(UserAccount *userAccount in _userAccountList)
        {
            NSDate *modifiedDate = [Utility stringToDate:userAccount.modifiedDate fromFormat:[Utility setting:vFormatDateTimeDB]];
            NSComparisonResult result = [maxDate compare:modifiedDate];
            if(result == NSOrderedAscending)
            {
                maxDate = modifiedDate;
                addEditRow = row;
            }
            row = row +1;
        }
        NSIndexPath *path = [NSIndexPath indexPathForRow:addEditRow inSection:0];
        [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    else if(currentAction == edit)
    {
        NSString *editedUsername = _userAccount.username;
        NSInteger row = 0;
        NSInteger addEditRow = row;
        for(UserAccount *userAccount in _userAccountList)
        {
            if([userAccount.username isEqualToString:editedUsername])
            {
                addEditRow = row;
                break;
            }
            row = row +1;
        }
        NSIndexPath *path = [NSIndexPath indexPathForRow:addEditRow inSection:0];
        [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
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
