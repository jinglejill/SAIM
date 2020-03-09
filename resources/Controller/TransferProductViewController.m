//
//  TransferProductViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 9/7/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "TransferProductViewController.h"
#import "MasterListViewController.h"
#import "Utility.h"
#import "ProductWithQuantity.h"
#import "ProductSource.h"
#import "SharedProduct.h"
#import "SharedPushSync.h"
#import "PushSync.h"


@interface TransferProductViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSString *_strEventIDSource;
    NSString *_strEventIDDestination;
}
@end

@implementation TransferProductViewController

- (IBAction)unwindToTransferProduct:(UIStoryboardSegue *)segue
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
            
            
            if(source.masterType == eventSource)
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text = selectedValue;
                _strEventIDSource = selectedKey;
            }
            else if(source.masterType == eventDestination)
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                [self.tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text = selectedValue;
                _strEventIDDestination = selectedKey;
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
    
    
    [self loadViewProcess];
}

- (void)loadViewProcess
{
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.000001f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = @"Event source";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        case 1:
        {
            cell.textLabel.text = @"Event destination";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //case 0 go to pro cat 2 list
    //case 1 go to pro cat 1 list
    switch (indexPath.row) {
        case 0:
        {
            [self performSegueWithIdentifier:@"segEventSource" sender:self];
        }
            break;
        case 1:
        {
            [self performSegueWithIdentifier:@"segEventDestination" sender:self];
        }
            break;
        default:
        {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
            break;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"segEventSource"])
    {
        MasterListViewController *vc = segue.destinationViewController;
        vc.masterType = eventSource;
    }
    else if([[segue identifier] isEqualToString:@"segEventDestination"])
    {
        MasterListViewController *vc = segue.destinationViewController;
        vc.masterType = eventDestination;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    return indexPath.row == 6?132:44;
        return 44;
}

- (IBAction)transferProduct:(id)sender {
    if(![self validateData])
    {
        return;
    }
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Confirm"
                                                                   message:@"Confirm transfer product"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:
     [UIAlertAction actionWithTitle:@"No"
                              style:UIAlertActionStyleCancel
                            handler:^(UIAlertAction *action) {}]];
    
    [alert addAction:
     [UIAlertAction actionWithTitle:@"Yes"
                              style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction *action) {
                                NSArray *eventSourceAndDestination = @[_strEventIDSource,_strEventIDDestination];
                                
                                [_homeModel updateItems:dbProductEventID withData:eventSourceAndDestination];
                                [self updateSharedData];
                                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                                               message:@"Transfer success"
                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                                
                                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                                      handler:^(UIAlertAction * action) {
                                                                                          [self.navigationController popViewControllerAnimated:YES];
                                                                                      }];
                                
                                [alert addAction:defaultAction];
                                
                                [self presentViewController:alert animated:YES completion:nil];
                            }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)updateSharedData
{
    //update sharedproduct
    for(Product *item in [SharedProduct sharedProduct].productList)
    {
        if((item.eventID == [_strEventIDSource integerValue]) && [item.status isEqualToString:@"I"])
        {
            item.eventID = [_strEventIDDestination integerValue];
            item.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
            item.modifiedUser = [Utility modifiedUser];
        }
    }
}
- (void)itemsUpdated
{ 
}

- (BOOL)validateData
{
    if(_strEventIDSource == nil)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Missing"
                                                                       message:@"Please fill in event source"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
    }
    if(_strEventIDDestination == nil)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Missing"
                                                                       message:@"Please fill in event destination"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
    }
    if(_strEventIDSource == _strEventIDDestination)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invalid"
                                                                       message:@"Destination is the same as event."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
    }

    return YES;
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
