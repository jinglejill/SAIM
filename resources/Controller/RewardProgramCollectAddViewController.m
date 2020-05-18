//
//  RewardProgramCollectAddViewController.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 4/20/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import "RewardProgramCollectAddViewController.h"
#import "Utility.h"
#import "RewardProgram.h"


@interface RewardProgramCollectAddViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
}
@end

@implementation RewardProgramCollectAddViewController
@synthesize selectedRewardProgram;
@synthesize btnDelete;

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if([textField isEqual:txtSalesSpent] || [textField isEqual:txtReceivePoint])
    {
        if([textField.text isEqualToString:@""])
        {
            textField.text = @"0";
        }
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField;
{
    if([textField isEqual:txtDateStart])
    {
        NSString *strDate = textField.text;
        NSDate *datePeriod = [Utility stringToDate:strDate fromFormat:@"yyyy-MM-dd"];
        [dtPicker setDate:datePeriod];
    }
    else if([textField isEqual:txtDateEnd])
    {
        NSString *strDate = textField.text;
        NSDate *datePeriod = [Utility stringToDate:strDate fromFormat:@"yyyy-MM-dd"];
        [dtPicker setDate:datePeriod];
    }
}

- (IBAction)datePickerChanged:(id)sender
{
    if([txtDateStart isFirstResponder])
    {
        txtDateStart.text = [Utility dateToString:dtPicker.date toFormat:@"yyyy-MM-dd"];
    }
    else if([txtDateEnd isFirstResponder])
    {
        txtDateEnd.text = [Utility dateToString:dtPicker.date toFormat:@"yyyy-MM-dd"];
    }
}

- (IBAction)doneButtonClicked:(id)sender
{
    NSString *strDateFrom = [Utility formatDate:txtDateStart.text fromFormat:@"yyyy-MM-dd" toFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDateTo = [Utility formatDate:txtDateEnd.text fromFormat:@"yyyy-MM-dd" toFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    
    if(selectedRewardProgram)
    {
        RewardProgram *rewardProgram = [RewardProgram getRewardProgram:selectedRewardProgram.rewardProgramID];
        if(rewardProgram)
        {
            rewardProgram.dateStart = strDateFrom;
            rewardProgram.dateEnd = strDateTo;
            rewardProgram.salesSpent = [txtSalesSpent.text integerValue];
            rewardProgram.receivePoint = [txtReceivePoint.text integerValue];
            [_homeModel updateItems:dbRewardProgram withData:selectedRewardProgram];
        }
        else
        {
            selectedRewardProgram.dateStart = strDateFrom;
            selectedRewardProgram.dateEnd = strDateTo;
            selectedRewardProgram.salesSpent = [txtSalesSpent.text integerValue];
            selectedRewardProgram.receivePoint = [txtReceivePoint.text integerValue];
            [_homeModel updateItems:dbRewardProgram withData:selectedRewardProgram];
            
            [RewardProgram addRewardProgram:selectedRewardProgram];
        }
    }
    else
    {
        RewardProgram *rewardProgram = [[RewardProgram alloc]initWithRewardProgramID:[Utility getNextID:tblRewardProgram] type:1 dateStart:strDateFrom dateEnd:strDateTo salesSpent:[txtSalesSpent.text integerValue] receivePoint:[txtReceivePoint.text integerValue] pointSpent:0 discountType:0 discountAmount:0 modifiedDate:[Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"]];
        [_homeModel insertItems:dbRewardProgram withData:rewardProgram];
        
        [RewardProgram addRewardProgram:rewardProgram];
    }
    [self performSegueWithIdentifier:@"segUnwindToRewardProgramSetup" sender:self];
}

- (IBAction)deleteButtonClicked:(id)sender
{
    [_homeModel deleteItems:dbRewardProgram withData:selectedRewardProgram];
    [RewardProgram deleteRewardProgram:selectedRewardProgram];
    [self performSegueWithIdentifier:@"segUnwindToRewardProgramSetup" sender:self];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.000001f;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    switch (indexPath.row) {
        case 0:
            [cell addSubview:txtDateStart];
            break;
        case 1:
            [cell addSubview:txtDateEnd];
            break;
        case 2:
            [cell addSubview:txtSalesSpent];
            break;
        case 3:
            [cell addSubview:txtReceivePoint];
            break;
    }
    
    
    return cell;
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
    
    
    
    float controlWidth = self.tableView.bounds.size.width - 15*2;//minus left, right margin
    float controlXOrigin = 15;
    float controlYOrigin = (44 - 25)/2;//table row height minus control height and set vertical center
    
    txtDateStart = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, 25)];
    txtDateStart.placeholder = @"Date start";
    txtDateStart.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
    
    
    txtDateEnd = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, 25)];
    txtDateEnd.placeholder = @"Date end";
    txtDateEnd.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
    
    
    txtSalesSpent = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, 25)];
    txtSalesSpent.placeholder = @"Sales spent";
    txtSalesSpent.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtSalesSpent.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
    [txtSalesSpent setKeyboardType:UIKeyboardTypeNumberPad];
    
    
    txtReceivePoint = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, 25)];
    txtReceivePoint.placeholder = @"Receive point";
    txtReceivePoint.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtReceivePoint.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
    [txtReceivePoint setKeyboardType:UIKeyboardTypeNumberPad];
    
    
    dtPicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [dtPicker setDatePickerMode:UIDatePickerModeDate];
    [dtPicker addTarget:self action:@selector(datePickerChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    
    [dtPicker removeFromSuperview];
    txtDateStart.inputView = dtPicker;
    txtDateStart.delegate = self;
    txtDateStart.text = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd"];//set to current date
    
    
    txtDateEnd.inputView = dtPicker;
    txtDateEnd.delegate = self;
    txtDateEnd.text = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd"];//set to current date
    
    
    
    if(!selectedRewardProgram)
    {
        [btnDelete removeFromSuperview];
    }
    else
    {
        txtDateStart.text = [Utility formatDate:selectedRewardProgram.dateStart fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd"];
        txtDateEnd.text = [Utility formatDate:selectedRewardProgram.dateEnd fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd"];
        txtSalesSpent.text = [NSString stringWithFormat:@"%ld",selectedRewardProgram.salesSpent];
        txtReceivePoint.text = [NSString stringWithFormat:@"%ld",selectedRewardProgram.receivePoint];
    }
    [self loadViewProcess];
}

- (void)loadViewProcess
{
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

-(void)itemsDownloaded:(NSArray *)items
{
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
