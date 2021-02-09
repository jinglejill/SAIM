//
//  ExpenseDailyViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/3/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import "ExpenseDailyViewController.h"
#import "CustomTableViewCellExpenseDaily.h"
#import "CustomTableViewCellExpenseItem.h"
#import "CustomTableViewCellExpenseAmount.h"
#import "ExpenseDaily.h"
#import "OftenUse.h"
#import <QuartzCore/QuartzCore.h>

#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]
@interface ExpenseDailyViewController()
{
    NSArray *_oftenUseList;
    UITableView *_tbvExpenseAdd;
    UIButton * _btnSave;
    UIButton * _btnCancel;
    ExpenseDaily *_expenseDaily;
    ExpenseDaily *_expenseDailyDelete;
    UIView *_vwDimBackground;
}
@end

static NSString * const reuseIdentifierExpenseDaily = @"CustomTableViewCellExpenseDaily";
static NSString * const reuseIdentifierExpenseItem = @"CustomTableViewCellExpenseItem";
static NSString * const reuseIdentifierExpenseAmount = @"CustomTableViewCellExpenseAmount";
@implementation ExpenseDailyViewController
@synthesize tbvData;
@synthesize eventID;
@synthesize inputDate;
@synthesize expenseDailyList;

- (void)viewDidLoad
{
    [super viewDidLoad];

    _vwDimBackground = [[UIView alloc]initWithFrame:self.view.frame];
    _vwDimBackground.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    
    
    //Register table
    tbvData.delegate = self;
    tbvData.dataSource = self;
    tbvData.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    {
        UINib *nib = [UINib nibWithNibName:reuseIdentifierExpenseDaily bundle:nil];
        [tbvData registerNib:nib forCellReuseIdentifier:reuseIdentifierExpenseDaily];
    }

   
    //tbvExpenseAdd *********
    float tbvExpenseAddWidth = self.view.frame.size.width;
    float tbvExpenseAddHeight = 44*2+78;
    CGRect tbvExpenseAddFrame = CGRectMake((self.view.frame.size.width-tbvExpenseAddWidth)/2, (self.view.frame.size.height-tbvExpenseAddHeight)/2, tbvExpenseAddWidth, tbvExpenseAddHeight);
    
    
    _tbvExpenseAdd = [[UITableView alloc]initWithFrame:tbvExpenseAddFrame style:UITableViewStylePlain];
    _tbvExpenseAdd.delegate = self;
    _tbvExpenseAdd.dataSource = self;
    
    {
        UINib *nib = [UINib nibWithNibName:reuseIdentifierExpenseItem bundle:nil];
        [_tbvExpenseAdd registerNib:nib forCellReuseIdentifier:reuseIdentifierExpenseItem];
    }
    {
        UINib *nib = [UINib nibWithNibName:reuseIdentifierExpenseAmount bundle:nil];
        [_tbvExpenseAdd registerNib:nib forCellReuseIdentifier:reuseIdentifierExpenseAmount];
    }
    //add dropshadow
    {
        _tbvExpenseAdd.layer.shadowRadius  = 1.5f;
        _tbvExpenseAdd.layer.shadowColor   = [UIColor colorWithRed:176.f/255.f green:199.f/255.f blue:226.f/255.f alpha:1.f].CGColor;
        _tbvExpenseAdd.layer.shadowOffset  = CGSizeMake(0.0f, 0.0f);
        _tbvExpenseAdd.layer.shadowOpacity = 0.9f;
        _tbvExpenseAdd.layer.masksToBounds = NO;

        UIEdgeInsets shadowInsets     = UIEdgeInsetsMake(0, 0, -1.5f, 0);
        UIBezierPath *shadowPath      = [UIBezierPath bezierPathWithRect:UIEdgeInsetsInsetRect(_tbvExpenseAdd.bounds, shadowInsets)];
        _tbvExpenseAdd.layer.shadowPath    = shadowPath.CGPath;
    }
    //************************************
    
    
    //Save, cancel button
    {
        float controlHeight = 25;
        float controlXOrigin = 16;
        float controlYOrigin = 3+(44-controlHeight)/2;
        
        float  saveWidth = 44;
         _btnSave = [UIButton buttonWithType:UIButtonTypeRoundedRect];
         _btnSave.frame = CGRectMake(controlXOrigin, controlYOrigin,  saveWidth, controlHeight);
        [ _btnSave setTitle:@"Save" forState:UIControlStateNormal];
        [ _btnSave setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
         _btnSave.titleLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Medium" size:14];
        [ _btnSave addTarget:self action:@selector(saveExpense:) forControlEvents:UIControlEventTouchUpInside];
         _btnSave.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        
         _btnCancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
         _btnCancel.frame = CGRectMake(controlXOrigin+ saveWidth, controlYOrigin,  saveWidth, controlHeight);
        [ _btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
        [ _btnCancel setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
         _btnCancel.titleLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Medium" size:14];
        [ _btnCancel addTarget:self action:@selector(cancelExpense:) forControlEvents:UIControlEventTouchUpInside];
         _btnCancel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    
    
    _expenseDaily = [[ExpenseDaily alloc]init];
    _expenseDaily.inputDate = inputDate;
    _expenseDaily.eventID = [NSString stringWithFormat:@"%ld", eventID];
    
    ExpenseDaily *expenseDaily = [[ExpenseDaily alloc]init];
    expenseDaily.inputDate = inputDate;
    expenseDaily.eventID = [NSString stringWithFormat:@"%ld", eventID];
    [self loadingOverlayView];
    [self.homeModel downloadItems:dbExpenseDaily condition:expenseDaily];
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tapGesture];
    [tapGesture setCancelsTouchesInView:NO];
}

-(void)itemsDownloaded:(NSArray *)items
{
    [self removeOverlayViews];
    
    expenseDailyList = items[0];
    _oftenUseList = items[1];
    
    [tbvData reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == _tbvExpenseAdd)
    {
        return 3;
    }
    else if(tableView == tbvData)
    {
        return [expenseDailyList count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _tbvExpenseAdd)
    {
        if(indexPath.item == 0)
        {
            CustomTableViewCellExpenseItem *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierExpenseItem];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.txtName.tag = 0;
            cell.txtName.delegate = self;
            
            
            
            OftenUse *oftenUse = _oftenUseList[0];
            //btnOftenUse1
            {
                [cell.btnOftenUse1 setTitle:oftenUse.oftenUse1 forState:UIControlStateNormal];
                [cell.btnOftenUse1 sizeToFit];
                cell.btnOftenUse1Width.constant = cell.btnOftenUse1.frame.size.width;
                [cell.btnOftenUse1 addTarget:self action:@selector(replaceExpenseName:) forControlEvents:UIControlEventTouchUpInside];
                
                //border the button
                [cell.btnOftenUse1.layer setBorderWidth:1.0];
                [cell.btnOftenUse1.layer setBorderColor:[tBlueColor CGColor]];
                
                //round the button
                cell.btnOftenUse1.layer.cornerRadius = 10; // this value vary as per your desire
                cell.btnOftenUse1.clipsToBounds = YES;
            }
            
            //btnOftenUse2
            {
                [cell.btnOftenUse2 setTitle:oftenUse.oftenUse2 forState:UIControlStateNormal];
                [cell.btnOftenUse2 sizeToFit];
                cell.btnOftenUse2Width.constant = cell.btnOftenUse2.frame.size.width;
                [cell.btnOftenUse2 addTarget:self action:@selector(replaceExpenseName:) forControlEvents:UIControlEventTouchUpInside];
                
                //border the button
                [cell.btnOftenUse2.layer setBorderWidth:1.0];
                [cell.btnOftenUse2.layer setBorderColor:[tBlueColor CGColor]];
                
                //round the button
                cell.btnOftenUse2.layer.cornerRadius = 10; // this value vary as per your desire
                cell.btnOftenUse2.clipsToBounds = YES;
            }
            
            //btnOftenUse3
            {
                [cell.btnOftenUse3 setTitle:oftenUse.oftenUse3 forState:UIControlStateNormal];
                [cell.btnOftenUse3 sizeToFit];
                cell.btnOftenUse3Width.constant = cell.btnOftenUse3.frame.size.width;
                [cell.btnOftenUse3 addTarget:self action:@selector(replaceExpenseName:) forControlEvents:UIControlEventTouchUpInside];
                
                //border the button
                [cell.btnOftenUse3.layer setBorderWidth:1.0];
                [cell.btnOftenUse3.layer setBorderColor:[tBlueColor CGColor]];
                
                //round the button
                cell.btnOftenUse3.layer.cornerRadius = 10; // this value vary as per your desire
                cell.btnOftenUse3.clipsToBounds = YES;
            }
            
            return cell;
            
        }
        else if(indexPath.item == 1)
        {
            CustomTableViewCellExpenseAmount *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierExpenseAmount];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.txtAmount.tag = 1;
            cell.txtAmount.delegate = self;
            
            return cell;
        }
        else if(indexPath.item == 2)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }

            cell.contentView.userInteractionEnabled = false;
            [cell addSubview:_btnSave];
            [cell addSubview:_btnCancel];
            return cell;
        }
    }
    else if(tableView == tbvData)
    {
        CustomTableViewCellExpenseDaily *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierExpenseDaily];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        
        ExpenseDaily *expenseDaily = expenseDailyList[indexPath.item];
        
        cell.lblItem.text = expenseDaily.name;
        cell.lblAmount.text = [Utility formatBaht:expenseDaily.amount withMinFraction:0 andMaxFraction:0];
        
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _tbvExpenseAdd)
    {
        if(indexPath.item == 0)
        {
            return 78;
        }
    }
    return 44;
}

 -(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(tableView == tbvData)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44)];
        UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 44, tableView.frame.size.width, 1)];
        bottomBorder.backgroundColor = [UIColor systemGroupedBackgroundColor];
        [view addSubview:bottomBorder];
        
        
        //Item
        UILabel *lblItem = [[UILabel alloc]initWithFrame:CGRectMake(16, 14, 100, 17)];
        lblItem.text = @"Item";
        lblItem.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14];
        [view addSubview:lblItem];
        
        
        //Amount
        UILabel *lblAmount = [[UILabel alloc]initWithFrame:CGRectMake(tableView.frame.size.width - 16 - 100, 14, 100, 17)];
        lblAmount.text = @"Amount";
        lblAmount.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14];
        lblAmount.textAlignment = NSTextAlignmentRight;
        [view addSubview:lblAmount];
        return view;
    }

    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if(tableView == tbvData)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44)];
        UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 3)];
        topBorder.backgroundColor = [UIColor systemGroupedBackgroundColor];
        [view addSubview:topBorder];

           
        //Item
        UILabel *lblItem = [[UILabel alloc]initWithFrame:CGRectMake(16, 14, 100, 17)];
        lblItem.text = @"Total";
        lblItem.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14];
        [view addSubview:lblItem];
        
        
        //Amount
        UILabel *lblAmount = [[UILabel alloc]initWithFrame:CGRectMake(tableView.frame.size.width - 16 - 100, 14, 100, 17)];
        lblAmount.text = [Utility formatBaht:[NSString stringWithFormat:@"%f", [self getTotalExpense]] withMinFraction:0 andMaxFraction:0];
        lblAmount.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14];
        lblAmount.textAlignment = NSTextAlignmentRight;
        [view addSubview:lblAmount];
       
        return view;
    }
    
    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(tableView == tbvData)
    {
        return 44;
    }
    
    return 0.01f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(tableView == tbvData)
    {
        return 44;
    }
    
    return 0.01f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == tbvData)
    {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == tbvData)
    {
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            //remove the deleted object from your data source.
            //If your data source is an NSMutableArray, do this
            [self loadingOverlayView];
            _expenseDailyDelete = expenseDailyList[indexPath.item];
            [self.homeModel deleteItems:dbExpenseDaily withData:_expenseDailyDelete];
            
            
//            [_expenseDailyList removeObjectAtIndex:indexPath.row];
//            [tableView reloadData]; // tell table to refresh now
        }
    }
}

-(void)itemsDeleted
{
    [self removeOverlayViews];
    [expenseDailyList removeObject:_expenseDailyDelete];
    [tbvData reloadData];
}

-(float)getTotalExpense
{
    float totalExpense = 0;
    for(ExpenseDaily *item in expenseDailyList)
    {
        totalExpense += [item.amount floatValue];
    }
    return totalExpense;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag == 0)
    {
        _expenseDaily.name = [Utility trimString:textField.text];
    }
    else if(textField.tag == 1)
    {
        _expenseDaily.amount = [Utility trimString:textField.text];
    }
}

- (IBAction)addExpense:(id)sender
{
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        CustomTableViewCellExpenseItem *cell = [_tbvExpenseAdd cellForRowAtIndexPath:indexPath];
        cell.txtName.text = @"";
    }
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        CustomTableViewCellExpenseAmount *cell = [_tbvExpenseAdd cellForRowAtIndexPath:indexPath];
        cell.txtAmount.text = @"";
    }
    [_tbvExpenseAdd reloadData];
    
    
    _tbvExpenseAdd.alpha = 0.0;
    [self.view addSubview:_vwDimBackground];
    [self.view addSubview:_tbvExpenseAdd];
    [UIView animateWithDuration:0.2 animations:^{
        _tbvExpenseAdd.alpha = 1.0;
    }];
}

- (IBAction)backButtonClicked:(id)sender
{
    [self performSegueWithIdentifier:@"segUnwindToReceiptSummary2" sender:self];
}

- (void) saveExpense:(id)sender
{
    if([_expenseDaily.name isEqualToString:@""])
    {
        [self alertMessage:@"Please input item" title:@"Warning"];
        return;
    }
    else if([_expenseDaily.amount isEqualToString:@""])
    {
        [self alertMessage:@"Please input amount" title:@"Warning"];
        return;
    }
    

    [self loadingOverlayView];
    [self.homeModel insertItems:dbExpenseDaily withData:_expenseDaily];
    
}

-(void)cancelExpense:(id)sender
{
    [_tbvExpenseAdd removeFromSuperview];
    [_vwDimBackground removeFromSuperview];
}

-(void)itemsInsertedWithReturnData:(NSArray *)data
{
    [self removeOverlayViews];
    [_tbvExpenseAdd removeFromSuperview];
    [_vwDimBackground removeFromSuperview];
    NSMutableArray *expenseDailyListDB = data[0];
    ExpenseDaily *expenseDaily = expenseDailyListDB[0];
    
    [expenseDailyList addObject:expenseDaily];
    [tbvData reloadData];
}

-(void)replaceExpenseName:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    CustomTableViewCellExpenseItem *cell = [_tbvExpenseAdd cellForRowAtIndexPath:indexPath];
    cell.txtName.text = button.titleLabel.text;
    _expenseDaily.name = [Utility trimString:cell.txtName.text];
}
@end
