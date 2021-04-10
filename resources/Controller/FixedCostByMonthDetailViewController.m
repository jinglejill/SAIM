//
//  FixedCostByMonthDetailViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 23/3/2564 BE.
//  Copyright © 2564 BE Thidaporn Kijkamjai. All rights reserved.
//

#import "FixedCostByMonthDetailViewController.h"
#import "CustomTableViewCellText.h"
#import "CustomTableViewCellSaveCancel.h"
#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"
#import "YearMonthCost.h"


@interface FixedCostByMonthDetailViewController ()
{
    UITableView *_tbvYearMonthCost;
    YearMonthCost *_yearMonthCost;
    
    UIView *_vwDimBackground;    
    NSMutableArray *_yearMonthCostList;
}
@end

@implementation FixedCostByMonthDetailViewController
static NSString * const reuseIdentifierSaveCancel = @"CustomTableViewCellSaveCancel";
static NSString * const reuseIdentifierText = @"CustomTableViewCellText";
@synthesize tbvData;
@synthesize yearMonth;

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag == 100)
    {
        _yearMonthCost.costLabel = textField.text;
    }
    else if(textField.tag == 101)
    {
        _yearMonthCost.cost = [Utility floatValue:textField.text];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tapGesture];
    [tapGesture setCancelsTouchesInView:NO];
    
    
    _yearMonthCost = [[YearMonthCost alloc]init];
    tbvData.delegate = self;
    tbvData.dataSource = self;
    
    
    float tbvYearMonthCostWidth = self.view.frame.size.width;
    float tbvYearMonthCostHeight = 44*2+30;
    CGRect tbvYearMonthFrame = CGRectMake((self.view.frame.size.width-tbvYearMonthCostWidth)/2, (self.view.frame.size.height-tbvYearMonthCostHeight)/2, tbvYearMonthCostWidth, tbvYearMonthCostHeight);
    
    _tbvYearMonthCost = [[UITableView alloc]initWithFrame:tbvYearMonthFrame style:UITableViewStylePlain];
    _tbvYearMonthCost.delegate = self;
    _tbvYearMonthCost.dataSource = self;
    _tbvYearMonthCost.scrollEnabled = NO;
    
    {
        UINib *nib = [UINib nibWithNibName:reuseIdentifierText bundle:nil];
        [_tbvYearMonthCost registerNib:nib forCellReuseIdentifier:reuseIdentifierText];
    }
    {
        UINib *nib = [UINib nibWithNibName:reuseIdentifierSaveCancel bundle:nil];
        [_tbvYearMonthCost registerNib:nib forCellReuseIdentifier:reuseIdentifierSaveCancel];
    }
    
    //add dropshadow
    [self addDropShadow:_tbvYearMonthCost];
    
    
    _vwDimBackground = [[UIView alloc]initWithFrame:self.view.frame];
    _vwDimBackground.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    
    
    [self.homeModel downloadItems:dbYearMonthCost condition:yearMonth];
}

-(void)itemsDownloaded:(NSArray *)items
{
    _yearMonthCostList = items[0];
    [tbvData reloadData];
}

- (IBAction)addYearMonthCost:(id)sender
{
    [self showYearMonthCostView:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if(tableView == tbvData)
    {
        return 1;
    }
    else if(tableView == _tbvYearMonthCost)
    {
        return 1;
    }

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == tbvData)
    {
        return [_yearMonthCostList count];
    }
    else if(tableView == _tbvYearMonthCost)
    {
        return 3;
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
        
        YearMonthCost *yearMonthCost = _yearMonthCostList[indexPath.row];
        cell.textLabel.text = yearMonthCost.costLabel;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [Utility formatFloat:yearMonthCost.cost withMinFraction:0 andMaxFraction:2]];
        
        cell.rightButtons = [self createRightButtons:2 withData:yearMonthCost];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    else if(tableView == _tbvYearMonthCost)
    {
        if(indexPath.item == 0)
        {
            CustomTableViewCellText *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierText];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.txtValue.text = _yearMonthCost.costLabel;
            cell.txtValue.tag = 100;
            cell.txtValue.delegate = self;
            cell.txtValue.keyboardType = UIKeyboardTypeDefault;
            cell.txtValue.placeholder = @"Cost label";
            cell.txtValue.enabled = _yearMonthCost.costLabelID == 0;
            
            return cell;
        }
        else if(indexPath.item == 1)
        {
            CustomTableViewCellText *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierText];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.txtValue.text = [NSString stringWithFormat:@"%@", [Utility formatFloat:_yearMonthCost.cost withMinFraction:0 andMaxFraction:2]];
            cell.txtValue.tag = 101;
            cell.txtValue.delegate = self;
            cell.txtValue.keyboardType = UIKeyboardTypeNumberPad;
            cell.txtValue.placeholder = @"Cost";
            cell.txtValue.enabled = YES;
            
            return cell;
        }
        else if(indexPath.item == 2)
        {
            CustomTableViewCellSaveCancel *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierSaveCancel];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            
            cell.btnSave.tag = tableView.tag;
            [cell.btnSave addTarget:self action:@selector(saveYearMonthCost:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnCancel addTarget:self action:@selector(cancelYearMonthCost:) forControlEvents:UIControlEventTouchUpInside];
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
    else if(tableView == _tbvYearMonthCost)
    {
        return 44;
    }
    return 0;
}

-(NSArray *) createRightButtons: (int) number withData:(YearMonthCost *)yearMonthCost
{
    NSMutableArray * result = [NSMutableArray array];
    NSString* titles[2] = {@"Delete", @"Edit"};
    UIColor * colors[2] = {[UIColor redColor], [UIColor greenColor]};
    for (int i = 0; i < number; ++i)
    {
        MGSwipeButton * button = [MGSwipeButton buttonWithTitle:titles[i] backgroundColor:colors[i] callback:^BOOL(MGSwipeTableCell * sender){
            if (i==0)
            {
                NSLog(@"delete yearMonthCost");
                _yearMonthCost.yearMonthCostID = yearMonthCost.yearMonthCostID;
                _yearMonthCost.yearMonth = yearMonthCost.yearMonth;
                _yearMonthCost.costLabel = yearMonthCost.costLabel;
                _yearMonthCost.cost = yearMonthCost.cost;
                _yearMonthCost.costLabelID = yearMonthCost.costLabelID;
                [self.homeModel deleteItems:dbYearMonthCost withData:yearMonthCost];
            }
            else if(i == 1)
            {
                NSLog(@"edit yearmonthCost");
                [self showYearMonthCostView:yearMonthCost];
            }
            
//            BOOL autoHide = i != 0;
//            return autoHide; //Don't autohide in delete button to improve delete expansion animation
            return YES;
        }];
        [result addObject:button];
    }
    return result;
}

- (void)showYearMonthCostView:(YearMonthCost *)yearMonthCost
{
    if(yearMonthCost)
    {
        _yearMonthCost.yearMonthCostID = yearMonthCost.yearMonthCostID;
        _yearMonthCost.yearMonth = yearMonthCost.yearMonth;
        _yearMonthCost.costLabel = yearMonthCost.costLabel;
        _yearMonthCost.cost = yearMonthCost.cost;
        _yearMonthCost.costLabelID = yearMonthCost.costLabelID;
    }
    else
    {
        _yearMonthCost.yearMonthCostID = 0;
        _yearMonthCost.yearMonth = yearMonth.yearMonth;
        _yearMonthCost.costLabel = @"";
        _yearMonthCost.cost = 0;
        _yearMonthCost.costLabelID = 0;
    }
    
    
    [_tbvYearMonthCost reloadData];
    
    
    _tbvYearMonthCost.alpha = 0.0;
    [self.view addSubview:_vwDimBackground];
    [self.view addSubview:_tbvYearMonthCost];
    [UIView animateWithDuration:0.2 animations:^{
        _tbvYearMonthCost.alpha = 1.0;
    }];
}

-(void)saveYearMonthCost:(id)sender
{
    //validate yearMonthCost
    if([Utility isStringEmpty:_yearMonthCost.costLabel])
    {
        [self alertMessage:@"Please input cost label" title:@"Warning"];
        return;
    }
    
    if(_yearMonthCost.yearMonthCostID == 0)
    {
        //insert
        [self.homeModel insertItems:dbYearMonthCost withData:_yearMonthCost];
    }
    else
    {
        //update
        [self.homeModel updateItems:dbYearMonthCost withData:_yearMonthCost];
    }
}

-(void)cancelYearMonthCost:(id)sender
{
    [_tbvYearMonthCost removeFromSuperview];
    [_vwDimBackground removeFromSuperview];
}

-(void)itemsInsertedWithReturnData:(NSArray *)data
{
    NSMutableArray *yearMonthCostList = data[0];
    YearMonthCost *yearMonthCost = yearMonthCostList[0];
    
    [_yearMonthCostList addObject:yearMonthCost];
    [tbvData reloadData];
    [_tbvYearMonthCost removeFromSuperview];
    [_vwDimBackground removeFromSuperview];
}

-(void)itemsUpdatedWithReturnData:(NSArray *)data
{
    NSMutableArray *yearMonthCostList = data[0];
    YearMonthCost *updatedYearMonthCost = yearMonthCostList[0];
    
    YearMonthCost *yearMonthCost = [self getYearMonthCost:updatedYearMonthCost.yearMonthCostID];
    yearMonthCost.costLabel = updatedYearMonthCost.costLabel;
    yearMonthCost.cost = updatedYearMonthCost.cost;
    [tbvData reloadData];
    [_tbvYearMonthCost removeFromSuperview];
    [_vwDimBackground removeFromSuperview];
}

-(void)itemsDeletedWithReturnData:(NSArray *)data
{
    NSMutableArray *yearMonthCostList = data[0];
    YearMonthCost *updatedYearMonthCost = yearMonthCostList[0];
    
    YearMonthCost *yearMonthCost = [self getYearMonthCost:updatedYearMonthCost.yearMonthCostID];
    [_yearMonthCostList removeObject:yearMonthCost];
    [tbvData reloadData];
}


-(YearMonthCost *)getYearMonthCost:(NSInteger) yearMonthCostID
{
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_yearMonthCostID = %d",yearMonthCostID];
    NSArray *filterArray = [_yearMonthCostList filteredArrayUsingPredicate:predicate1];
    
    if([filterArray count] > 0)
    {
        return filterArray[0];
    }
    return nil;
}
@end
