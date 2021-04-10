//
//  FixedCostByMonthViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 18/3/2564 BE.
//  Copyright © 2564 BE Thidaporn Kijkamjai. All rights reserved.
//

#import "FixedCostByMonthViewController.h"
#import "FixedCostByMonthDetailViewController.h"
#import "CustomTableViewCellText.h"
#import "CustomTableViewCellSaveCancel.h"
#import "YearMonth.h"
#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"
#import "Message.h"

@interface FixedCostByMonthViewController ()
{
    UITableView *_tbvYearMonth;
    YearMonth *_yearMonth;
    
    UIView *_vwDimBackground;
    NSInteger _page;
    NSMutableArray *_yearMonthList;
}
@end

@implementation FixedCostByMonthViewController
static NSString * const reuseIdentifierSaveCancel = @"CustomTableViewCellSaveCancel";
static NSString * const reuseIdentifierText = @"CustomTableViewCellText";

@synthesize tbvData;

- (IBAction)unwindToFixedCostByMonth:(UIStoryboardSegue *)segue
{
   
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag == 100)
    {
        _yearMonth.yearMonth = textField.text;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tapGesture];
    [tapGesture setCancelsTouchesInView:NO];
    
    
    _yearMonth = [[YearMonth alloc]init];
    tbvData.delegate = self;
    tbvData.dataSource = self;
    
    
    float tbvYearMonthWidth = self.view.frame.size.width;
    float tbvYearMonthHeight = 44*2+30;
    CGRect tbvYearMonthFrame = CGRectMake((self.view.frame.size.width-tbvYearMonthWidth)/2, (self.view.frame.size.height-tbvYearMonthHeight)/2, tbvYearMonthWidth, tbvYearMonthHeight);
    
    _tbvYearMonth = [[UITableView alloc]initWithFrame:tbvYearMonthFrame style:UITableViewStylePlain];
    _tbvYearMonth.delegate = self;
    _tbvYearMonth.dataSource = self;
    _tbvYearMonth.scrollEnabled = NO;
    
    {
        UINib *nib = [UINib nibWithNibName:reuseIdentifierText bundle:nil];
        [_tbvYearMonth registerNib:nib forCellReuseIdentifier:reuseIdentifierText];
    }
    {
        UINib *nib = [UINib nibWithNibName:reuseIdentifierSaveCancel bundle:nil];
        [_tbvYearMonth registerNib:nib forCellReuseIdentifier:reuseIdentifierSaveCancel];
    }
    
    //add dropshadow
    [self addDropShadow:_tbvYearMonth];
    
    
    _vwDimBackground = [[UIView alloc]initWithFrame:self.view.frame];
    _vwDimBackground.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    
    
    _page = 1;
    [self.homeModel downloadItems:dbYearMonth condition:@(_page)];
}

- (IBAction)addYearMonth:(id)sender
{
    _yearMonth.yearMonthID = 0;
    _yearMonth.yearMonth = @"";
    
    [self showYearMonthView:_yearMonth.yearMonth];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if(tableView == tbvData)
    {
        return 1;
    }
    else if(tableView == _tbvYearMonth)
    {
        return 1;
    }
    

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == tbvData)
    {
        return [_yearMonthList count];
    }
    else if(tableView == _tbvYearMonth)
    {
        return 2;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == tbvData)
    {
        NSString *cellIdentifier = @"reuseIdentifier";
        MGSwipeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!cell){
            cell = [[MGSwipeTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier: cellIdentifier];
        }
        
        YearMonth *yearMonth = _yearMonthList[indexPath.row];
        cell.textLabel.text = yearMonth.yearMonth;
        cell.rightButtons = [self createRightButtons:2 withData:yearMonth];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    else if(tableView == _tbvYearMonth)
    {
        if(indexPath.item == 0)
        {
            CustomTableViewCellText *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierText];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.txtValue.text = _yearMonth.yearMonth;
            cell.txtValue.tag = 100;
            cell.txtValue.delegate = self;
            cell.txtValue.keyboardType = UIKeyboardTypeNumberPad;
            cell.txtValue.placeholder = @"Year-month";
            
            return cell;
        }
        else if(indexPath.item == 1)
        {
            CustomTableViewCellSaveCancel *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierSaveCancel];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            
            cell.btnSave.tag = tableView.tag;
            [cell.btnSave addTarget:self action:@selector(saveYearMonth:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnCancel addTarget:self action:@selector(cancelYearMonth:) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == tbvData)
    {
        return 44;
    }
    else if(tableView == _tbvYearMonth)
    {
        return 44;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    if(tableView == tbvData)
    {
        sectionName = nil;
    }
    else if(tableView == _tbvYearMonth)
    {
        sectionName = NSLocalizedString(@"Year-month", @"Year-month");
    }
    return sectionName;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == tbvData)
    {
        NSLog(@"%ld",(long)indexPath.item);
        YearMonth *yearMonth = _yearMonthList[indexPath.item];
        _yearMonth.yearMonthID = yearMonth.yearMonthID;
        _yearMonth.yearMonth = yearMonth.yearMonth;
        [self performSegueWithIdentifier:@"segFixedCostByMonthDetail" sender:self];        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqual:@"segFixedCostByMonthDetail"])
    {
        FixedCostByMonthDetailViewController *vc = [segue destinationViewController];
        vc.yearMonth = _yearMonth;
    }
}

- (void)showYearMonthView:(NSString *)yearMonthText
{
    _yearMonth.yearMonth = yearMonthText;
    
    [_tbvYearMonth reloadData];
    
    
    _tbvYearMonth.alpha = 0.0;
    [self.view addSubview:_vwDimBackground];
    [self.view addSubview:_tbvYearMonth];
    [UIView animateWithDuration:0.2 animations:^{
        _tbvYearMonth.alpha = 1.0;
    }];
}

-(void)saveYearMonth:(id)sender
{
    //validate yearMonthText
    if([Utility isStringEmpty:_yearMonth.yearMonth])
    {
        [self alertMessage:@"Please input year-month" title:@"Warning"];
        return;
    }
    
    if(_yearMonth.yearMonthID == 0)
    {
        //insert
        [self.homeModel insertItems:dbYearMonth withData:_yearMonth];
    }
    else
    {
        //update
        [self.homeModel updateItems:dbYearMonth withData:_yearMonth];
    }
}

-(void)cancelYearMonth:(id)sender
{
    [_tbvYearMonth removeFromSuperview];
    [_vwDimBackground removeFromSuperview];
}

-(void)itemsInsertedWithReturnData:(NSArray *)data
{
    if([data count] > 1)
    {
        NSMutableArray *messageList = data[1];
        InAppMessage *message = messageList[0];
        [self alertMessage:message.message title:@"Warning"];
        return;
    }
    else
    {
        NSMutableArray *yearMonthList = data[0];
        YearMonth *yearMonth = yearMonthList[0];
        [_yearMonthList insertObject:yearMonth atIndex:0];
        [tbvData reloadData];
        [_tbvYearMonth removeFromSuperview];
        [_vwDimBackground removeFromSuperview];
    }
}

-(void)itemsUpdatedWithReturnData:(NSArray *)data
{
    if([data count] > 1)
    {
        NSMutableArray *messageList = data[1];
        InAppMessage *message = messageList[0];
        [self alertMessage:message.message title:@"Warning"];
        return;
    }
    else
    {
        NSMutableArray *yearMonthList = data[0];
        YearMonth *updatedYearMonth = yearMonthList[0];
        
        YearMonth *yearMonth = [self getYearMonth:updatedYearMonth.yearMonthID];
        yearMonth.yearMonth = updatedYearMonth.yearMonth;
        
        [tbvData reloadData];
        [_tbvYearMonth removeFromSuperview];
        [_vwDimBackground removeFromSuperview];
    }
}

-(void)itemsDeletedWithReturnData:(NSArray *)data
{
    if([data count] > 1)
    {
//        NSMutableArray *messageList = data[1];
//        InAppMessage *message = messageList[0];
        
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:
         [UIAlertAction actionWithTitle:@"Confirm delete?"//message.message
                                  style:UIAlertActionStyleDestructive
                                handler:^(UIAlertAction *action)
        {
            [self.homeModel deleteItems:dbYearMonth withData:_yearMonth];

        }]];
        
        
        [alert addAction:
         [UIAlertAction actionWithTitle:@"Cancel"
                                  style:UIAlertActionStyleCancel
                                handler:^(UIAlertAction *action)
        {
            
        }]];


       
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        NSMutableArray *yearMonthList = data[0];
        YearMonth *deletedYearMonth = yearMonthList[0];
        
        YearMonth *yearMonth = [self getYearMonth:deletedYearMonth.yearMonthID];
        [_yearMonthList removeObject:yearMonth];
        
        [tbvData reloadData];
    }
}

-(void)itemsDownloaded:(NSArray *)items
{
    _yearMonthList = items[0];
    [tbvData reloadData];
}

-(YearMonth *)getYearMonth:(NSInteger) yearMonthID
{
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_yearMonthID = %d",yearMonthID];
    NSArray *filterArray = [_yearMonthList filteredArrayUsingPredicate:predicate1];
    
    if([filterArray count] > 0)
    {
        return filterArray[0];
    }
    return nil;
}

-(NSArray *) createRightButtons: (int) number withData:(YearMonth *)yearMonth
{
    NSMutableArray * result = [NSMutableArray array];
    NSString* titles[2] = {@"Delete", @"Edit"};
    UIColor * colors[2] = {[UIColor redColor], [UIColor greenColor]};
    for (int i = 0; i < number; ++i)
    {
        MGSwipeButton * button = [MGSwipeButton buttonWithTitle:titles[i] backgroundColor:colors[i] callback:^BOOL(MGSwipeTableCell * sender){
            if (i==0)
            {
                NSLog(@"delete yearMonth");
                _yearMonth.yearMonthID = yearMonth.yearMonthID;
                _yearMonth.yearMonth = yearMonth.yearMonth;
                [self.homeModel deleteItems:dbYearMonthConfirm withData:yearMonth];
            }
            else if(i == 1)
            {
                NSLog(@"edit yearmonth");
                _yearMonth.yearMonthID = yearMonth.yearMonthID;
                _yearMonth.yearMonth = yearMonth.yearMonth;
                [self showYearMonthView:_yearMonth.yearMonth];
            }
            
//            BOOL autoHide = i != 0;
//            return autoHide; //Don't autohide in delete button to improve delete expansion animation
            return YES;
        }];
        [result addObject:button];
    }
    return result;
}
@end
