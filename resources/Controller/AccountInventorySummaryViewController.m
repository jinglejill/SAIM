//
//  AccountInventorySummaryViewController.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 2/4/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import "AccountInventorySummaryViewController.h"
#import "CustomUICollectionViewCellButton2.h"
#import "CustomUICollectionReusableView.h"
#import "AccountReceiptPDFViewController.h"
#import "PushSync.h"
#import "SharedPushSync.h"
#import "Utility.h"
#import "ProductCategory2.h"
#import "SharedProductCategory2.h"
#import "AccountInventorySummary.h"
#import "ProductName.h"
#import "SalesProductAndPrice.h"



#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]
#define tLightBlueColor          [UIColor colorWithRed:200/255.0 green:224/255.0 blue:243/255.0 alpha:1]


@interface AccountInventorySummaryViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSMutableArray *_productCategory2List;
    NSMutableArray *_accountInventorySummaryList;
    NSMutableArray *_salesProductAndPriceList;
    NSMutableArray *_booAscendingAccountInventorySummary;
    BOOL _viewInventOrSales;//yes=invent,no=sales
//    float _totalSalesSelected;    
}
@end


@implementation AccountInventorySummaryViewController

static NSString * const reuseIdentifier = @"Cell";
static NSString * const reuseHeaderViewIdentifier = @"HeaderView";
static NSString * const reuseFooterViewIdentifier = @"FooterView";


@synthesize colViewData;
@synthesize txtRequiredSales;
@synthesize lblCurrentAccumSales;
@synthesize dtPicker;
@synthesize txtDateFrom;
@synthesize txtDateTo;


- (IBAction)unwindToAccountInventorySummary:(UIStoryboardSegue *)segue
{
    [self loadViewProcess];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField;
{
    if([textField isEqual:txtDateFrom])
    {
        NSString *strDate = textField.text;
        NSDate *datePeriod = [Utility stringToDate:strDate fromFormat:@"yyyy-MM-dd"];
        [dtPicker setDate:datePeriod];
    }
    else if([textField isEqual:txtDateTo])
    {
        NSString *strDate = textField.text;
        NSDate *datePeriod = [Utility stringToDate:strDate fromFormat:@"yyyy-MM-dd"];
        [dtPicker setDate:datePeriod];
    }
    else
    {
        NSInteger countColumn = 5;
        NSInteger item = textField.tag;
        AccountInventorySummary *accountInventorySummary = _accountInventorySummaryList[item/countColumn-1];
        if(accountInventorySummary.quantity == 0)
        {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                           message:@"Inventory qty. is zero"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      
                                                                  }];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        else if(accountInventorySummary.salesQuantity == 0)
        {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                           message:@"Sales qty. is zero"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      
                                                                  }];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        else if([textField.text isEqualToString:@"0"])
        {
            textField.text = @"";
        }
    }
}

- (IBAction)datePickerChanged:(id)sender
{
    if([txtDateFrom isFirstResponder])
    {
        txtDateFrom.text = [Utility dateToString:dtPicker.date toFormat:@"yyyy-MM-dd"];
        NSString *strDateInMonth = [Utility formatDate:txtDateFrom.text fromFormat:@"yyyy-MM-dd" toFormat:@"yyyy-MM"];
        NSString *strDateToMonth = [Utility formatDate:txtDateTo.text fromFormat:@"yyyy-MM-dd" toFormat:@"yyyy-MM"];
        if(![strDateInMonth isEqualToString:strDateToMonth])
        {
            NSDate *dateIn = [Utility stringToDate:txtDateFrom.text fromFormat:@"yyyy-MM-dd"];
            txtDateTo.text = [NSString stringWithFormat:@"%@-%02ld",strDateInMonth,[Utility getLastDayOfMonth:dateIn]];
        }
    }
    else if([txtDateTo isFirstResponder])
    {
        txtDateTo.text = [Utility dateToString:dtPicker.date toFormat:@"yyyy-MM-dd"];
        NSString *strDateInMonth = [Utility formatDate:txtDateFrom.text fromFormat:@"yyyy-MM-dd" toFormat:@"yyyy-MM"];
        NSString *strDateToMonth = [Utility formatDate:txtDateTo.text fromFormat:@"yyyy-MM-dd" toFormat:@"yyyy-MM"];
        if(![strDateInMonth isEqualToString:strDateToMonth])
        {
            txtDateFrom.text = [NSString stringWithFormat:@"%@-01",strDateToMonth];
        }
    }
}

- (id)findFirstResponder:(UIView *)view
{
    if (view.isFirstResponder) {
        return view;
    }
    for (UIView *subView in view.subviews) {
        id responder = [self findFirstResponder:subView];//[subView findFirstResponder];
        if (responder) return responder;
    }
    return nil;
}

- (IBAction)viewPDF:(id)sender
{
    id responder = [self findFirstResponder:self.view];
    if(responder)
    {
        [responder resignFirstResponder];
    }
    
    
    if([SalesProductAndPrice getCountSalesProductAndPriceBillingsOnly:_salesProductAndPriceList] == 0)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                       message:@"No billings selected"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    [self performSegueWithIdentifier:@"segAccountReceiptPDF" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"segAccountReceiptPDF"])
    {
        AccountReceiptPDFViewController *vc = segue.destinationViewController;
        vc.saleProductAndPriceList = _salesProductAndPriceList;
        vc.accountInventorySummaryList = _accountInventorySummaryList;
        vc.dateOut = txtDateTo.text;        
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
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);        
    }
        
    
    
    NSArray *arrAscendingAccountInventorySummary = @[@YES,@YES,@YES,@YES];
    _booAscendingAccountInventorySummary = [arrAscendingAccountInventorySummary mutableCopy];
    
 
    _accountInventorySummaryList = [[NSMutableArray alloc]init];
    _salesProductAndPriceList = [[NSMutableArray alloc]init];
    //    _totalSalesSelected = 0;
    _viewInventOrSales = YES;
    
    
    
    [dtPicker removeFromSuperview];
    txtDateFrom.inputView = dtPicker;
    txtDateFrom.delegate = self;
    txtDateFrom.text = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-01"];
    
    
    txtDateTo.inputView = dtPicker;
    txtDateTo.delegate = self;
    txtDateTo.text = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd"];
    
    
//    [self loadViewProcess];
    
}

-(void)loadViewProcess
{
    lblCurrentAccumSales.text = @"Sales: 0";
    
    [self queryAccountInventorySummaryWithDateFrom:txtDateFrom.text dateTo:txtDateTo.text];
}

-(void)queryAccountInventorySummaryWithDateFrom:(NSString *)dateFrom dateTo:(NSString *)dateTo
{
    [self loadingOverlayView];
    [_homeModel downloadItems:dbAccountInventorySummary condition:@[dateFrom,dateTo]];
}

- (void)itemsDownloaded:(NSArray *)items
{
    [self removeOverlayViews];
    int i=0;
    _accountInventorySummaryList = items[i++];
    _salesProductAndPriceList = items[i++];
    
    
    _accountInventorySummaryList = [AccountInventorySummary getAccountInventorySummaryFilterOutUsedUp:_accountInventorySummaryList];
    _accountInventorySummaryList = [AccountInventorySummary getAccountInventorySummarySortByProductCategory2AndProductName:_accountInventorySummaryList];
    [AccountInventorySummary hilightEveryOtherProductCategory2:_accountInventorySummaryList];
    
    
    _salesProductAndPriceList = [SalesProductAndPrice getSalesProductAndPriceSortByReceiptDate:_salesProductAndPriceList];
    [SalesProductAndPrice hilightEveryOtherReceipt:_salesProductAndPriceList];
    
    
    [colViewData reloadData];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger noOfItems = 0;
    NSInteger countColumn = 0;
    if(_viewInventOrSales)
    {
        countColumn = 5;
        noOfItems = (([_accountInventorySummaryList count]+1)*countColumn) + 3;
        float sum =0;
        for(AccountInventorySummary *item in _accountInventorySummaryList)
        {
            sum += item.salesQuantity;
        }
        NSLog(@"sum sales quantity: %f",sum);
    }
    else
    {
        countColumn = 6;
        noOfItems = ([_salesProductAndPriceList count]+1)*countColumn;
        
        
        NSLog(@"count sales product: %ld",[_salesProductAndPriceList count]);
    }
    
    return noOfItems;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CustomUICollectionViewCellButton2 *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if ([cell.textField isDescendantOfView:cell])
    {
        [cell.textField removeFromSuperview];
    }
    if ([cell.buttonDetail isDescendantOfView:cell]) {
        [cell.buttonDetail removeFromSuperview];
    }
    if ([cell.label isDescendantOfView:cell])
    {
        [cell.label removeFromSuperview];
    }
    if ([cell.imageView isDescendantOfView:cell])
    {
        [cell.imageView removeFromSuperview];
    }
//    if ([cell.leftBorder isDescendantOfView:cell])
    {
        [cell.leftBorder removeFromSuperview];
        [cell.topBorder removeFromSuperview];
        [cell.rightBorder removeFromSuperview];
        [cell.bottomBorder removeFromSuperview];
    }
    
    //cell border
    {
        cell.leftBorder.frame = CGRectMake(cell.bounds.origin.x
                                           , cell.bounds.origin.y, 1, cell.bounds.size.height);
        cell.topBorder.frame = CGRectMake(cell.bounds.origin.x
                                          , cell.bounds.origin.y, cell.bounds.size.width, 1);
        cell.rightBorder.frame = CGRectMake(cell.bounds.origin.x+cell.bounds.size.width
                                            , cell.bounds.origin.y, 1, cell.bounds.size.height);
        cell.bottomBorder.frame = CGRectMake(cell.bounds.origin.x
                                             , cell.bounds.origin.y+cell.bounds.size.height, cell.bounds.size.width, 1);
    }
    
    [cell addSubview:cell.topBorder];
    [cell addSubview:cell.bottomBorder];
    [cell addSubview:cell.leftBorder];
    [cell addSubview:cell.rightBorder];
    
    
    
    NSInteger item = indexPath.item;
    
    
    if(_viewInventOrSales)
    {
        NSArray *header = @[@"Main cat.",@"Item",@"Qty.",@"Sales Qty.",@"Billings"];
        NSInteger countColumn = [header count];
        
        if(item/countColumn==0)
        {
            if(item == 0 || item == 1 || item == 2 || item == 3)
            {
                [cell.buttonDetail removeTarget:nil
                                         action:NULL
                               forControlEvents:UIControlEventAllEvents];
                [cell.buttonDetail addTarget:self action:@selector(sortColumnAccountInventorySummary:)
                            forControlEvents:UIControlEventTouchUpInside];
                
                
                NSInteger remainder = item%countColumn;
                [cell addSubview:cell.buttonDetail];
                cell.buttonDetail.frame = cell.bounds;
                [cell.buttonDetail setTitle:header[remainder] forState:UIControlStateNormal];
                [cell.buttonDetail setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [cell.buttonDetail setBackgroundColor:tBlueColor];
                cell.buttonDetail.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
                cell.buttonDetail.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
                cell.buttonDetail.tag = item;
                
                if(item == 0 || item == 1)
                {
                    cell.buttonDetail.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                }
                else if(item == 2 || item == 3)
                {
                    cell.buttonDetail.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
                }
            }
            else if(item == 4)
            {
                [cell addSubview:cell.label];
                cell.label.frame = cell.bounds;
                cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
                cell.label.textColor = [UIColor whiteColor];
                cell.label.backgroundColor = tBlueColor;
                cell.label.textAlignment = NSTextAlignmentRight;
                
                
                NSInteger remainder = item%countColumn;
                cell.label.text = header[remainder];                
            }
        }
        else if(item < ([_accountInventorySummaryList count]+1)*countColumn)
        {
            if(item%countColumn==0 || item%countColumn==1 || item%countColumn==2 || item%countColumn==3)
            {
                AccountInventorySummary *accountInventorySummary = _accountInventorySummaryList[item/countColumn-1];
//                NSLog(@"accountInventorySummary (item,item/countcolumn - 1): %ld,%ld",item,item/countColumn-1);
                [cell addSubview:cell.label];
                cell.label.frame = cell.bounds;
                cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                cell.label.textColor= [UIColor blackColor];
                
                
                if(accountInventorySummary.hilight == 1)
                {
                    cell.label.backgroundColor = tLightBlueColor;
                }
                else
                {
                    cell.label.backgroundColor = [UIColor clearColor];
                }
                
                switch (item%countColumn) {
                    case 0:
                    {
                        cell.label.textAlignment = NSTextAlignmentLeft;
                        cell.label.text = accountInventorySummary.productCategory2;
                    }
                    break;
                    case 1:
                    {
                        cell.label.textAlignment = NSTextAlignmentLeft;
                        cell.label.text = accountInventorySummary.productName;
                    }
                    break;
                    case 2:
                    {
                        cell.label.textAlignment = NSTextAlignmentRight;
                        NSString *strQuantity = [NSString stringWithFormat:@"%f",accountInventorySummary.quantity];
                        cell.label.text = [Utility formatBaht:strQuantity];
                    }
                    break;
                    case 3:
                    {
                        cell.label.textAlignment = NSTextAlignmentRight;
                        NSString *strSalesQuantity = [NSString stringWithFormat:@"%f",accountInventorySummary.salesQuantity];
                        cell.label.text = [Utility formatBaht:strSalesQuantity];
                    }
                    break;
                    default:
                    break;
                }
            }
            else if(item%countColumn==4)
            {
                [cell addSubview:cell.textField];
                cell.textField.frame = cell.bounds;
                cell.textField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
                cell.textField.delegate = self;
                cell.textField.tag = item;
                AccountInventorySummary *accountInventorySummary = _accountInventorySummaryList[item/countColumn-1];
                
                
                
                cell.textField.delegate = self;
                cell.textField.textAlignment = NSTextAlignmentRight;
                [cell.textField setKeyboardType:UIKeyboardTypeDecimalPad];
                NSString *strBillings = [NSString stringWithFormat:@"%ld",accountInventorySummary.billings];
                cell.textField.text = [Utility formatBaht:strBillings withMinFraction:0 andMaxFraction:2];
            }
        }
        else
        {
            [cell.topBorder removeFromSuperview];
            [cell.bottomBorder removeFromSuperview];
            [cell.leftBorder removeFromSuperview];
            [cell.rightBorder removeFromSuperview];
            if(item%countColumn==1)
            {
                [cell addSubview:cell.label];
                cell.label.frame = cell.bounds;
                cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
                cell.label.textColor = [UIColor blackColor];
                cell.label.backgroundColor = [UIColor clearColor];
                cell.label.textAlignment = NSTextAlignmentCenter;
                cell.label.text = @"Total";
            }
            else if(item%countColumn==2)
            {
                [cell addSubview:cell.label];
                cell.label.frame = cell.bounds;
                cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
                cell.label.textColor = [UIColor blackColor];
                cell.label.backgroundColor = [UIColor clearColor];
                cell.label.textAlignment = NSTextAlignmentRight;
                
                NSString *strTotalQuantity = [NSString stringWithFormat:@"%f",[self getTotalQuantity]];
                strTotalQuantity = [Utility formatBaht:strTotalQuantity withMinFraction:0 andMaxFraction:2];
                cell.label.text = strTotalQuantity;
            }
        }
        
    }
    else
    {
        NSArray *header = @[@"Receipt date",@"Item",@"Price",@"Tax",@"Cr.",@"SEL"];
        NSInteger countColumn = [header count];
        
        if(item/countColumn==0)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
            cell.label.textColor = [UIColor whiteColor];
            cell.label.backgroundColor = tBlueColor;
            cell.label.textAlignment = NSTextAlignmentCenter;
            
            
            NSInteger remainder = item%countColumn;
            cell.label.text = header[remainder];
            
            if(item%countColumn==0 || item%countColumn==1)
            {
                cell.buttonDetail.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            }
            else if(item%countColumn==2)
            {
                cell.buttonDetail.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            }
            else if(item%countColumn==3 || item%countColumn==4)
            {
                cell.buttonDetail.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            }
        }
        else if(item%countColumn==0 || item%countColumn==1 || item%countColumn==2 || item%countColumn==3 || item%countColumn==4)
        {
            SalesProductAndPrice *salesProductAndPrice = _salesProductAndPriceList[item/countColumn-1];
            
            
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
            cell.label.textColor= [UIColor blackColor];
            if(salesProductAndPrice.hilight == 1)
            {
                cell.label.backgroundColor = tLightBlueColor;
            }
            else
            {
                cell.label.backgroundColor = [UIColor clearColor];
            }
            
            
            switch (item%countColumn) {
                case 0:
                {
                    cell.label.textAlignment = NSTextAlignmentLeft;
                    cell.label.text = [Utility formatDate:salesProductAndPrice.receiptDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd HH:mm"];
                }
                    break;
                case 1:
                {
                    cell.label.textAlignment = NSTextAlignmentLeft;
                    cell.label.text = salesProductAndPrice.productName;
                }
                    break;
                case 2:
                {
                    cell.label.textAlignment = NSTextAlignmentRight;
                    NSString *strPrice = [NSString stringWithFormat:@"%f",salesProductAndPrice.priceSales];
                    cell.label.text = [Utility formatBaht:strPrice];
                }
                    break;
                case 3:
                {
                    NSString *strHasTax = [salesProductAndPrice.taxCustomerName isEqualToString:@""]?@"":@"Y";
                    cell.label.textAlignment = NSTextAlignmentCenter;
                    cell.label.text = strHasTax;
                }
                    break;
                case 4:
                {
                    NSString *strIsCredit = salesProductAndPrice.isCredit == 1?@"Y":@"";
                    cell.label.textAlignment = NSTextAlignmentCenter;
                    cell.label.text = strIsCredit;
                }
                    break;
                default:
                    break;
            }
        }
        else if(item%countColumn==5)
        {
            SalesProductAndPrice *salesProductAndPrice = _salesProductAndPriceList[item/countColumn-1];
            
            
            cell.label.backgroundColor = [UIColor clearColor];
            cell.imageView.userInteractionEnabled = YES;
            [cell addSubview:cell.imageView];
            
            CGRect frame = cell.bounds;
            NSInteger imageSize = 26;
            frame.origin.x = (frame.size.width-imageSize)/2;
            frame.origin.y = (frame.size.height-imageSize)/2;
            frame.size.width = imageSize;
            frame.size.height = imageSize;
            cell.imageView.frame = frame;
            cell.imageView.tag = item;
            
            
            cell.singleTap.numberOfTapsRequired = 1;
            cell.singleTap.numberOfTouchesRequired = 1;
            [cell.singleTap addTarget:self action:@selector(selectRow:)];
            [cell.imageView addGestureRecognizer:cell.singleTap];
            
            
            if(salesProductAndPrice.billings == 0)
            {
                cell.imageView.image = [UIImage imageNamed:@"unselect.png"];
            }
            else if(salesProductAndPrice.billings == 1)
            {
                cell.imageView.image = [UIImage imageNamed:@"select.png"];
            }
        }
    }
    [cell bringSubviewToFront:cell.topBorder];
    [cell bringSubviewToFront:cell.bottomBorder];
    [cell bringSubviewToFront:cell.leftBorder];
    [cell bringSubviewToFront:cell.rightBorder];
    return cell;
}

-(float) getTotalQuantity
{
    float sum = 0;
    for(AccountInventorySummary *item in _accountInventorySummaryList)
    {
        sum += item.quantity;
    }
    
    return sum;
}

- (void) selectRow:(UIGestureRecognizer *)gestureRecognizer
{
    //test
    //select all at once
    NSInteger sumPairs = 0;
    float sumTotalValue = 0;
    for(SalesProductAndPrice *item in _salesProductAndPriceList)
    {
//        //test
//        NSRange needleRange = NSMakeRange(8,2);
//        NSString *strDate = [item.receiptDate substringWithRange:needleRange];
//        if([strDate integerValue] <= 14)
//        {
//            continue;
//        }



//        if((item.isCredit && item.priceSales > 0) || ![Utility isStringEmpty:item.taxCustomerName])
        {
            item.billings = 1;
            sumTotalValue += item.amountPerUnit;
            sumPairs++;
        }
    }
    
    
    
//    //วนเพื่อออกบิลเพิ่ม ให้หลุดเงื่อนไข sumPairs < requirePairs
//    NSInteger requirePairs = [txtRequiredSales.text integerValue];
//    for(;sumPairs < requirePairs;)
//    {
//        NSInteger lastDate = 0;
//        for(SalesProductAndPrice *item in _salesProductAndPriceList)
//        {
//            NSRange needleRange = NSMakeRange(8,2);
//            NSString *strDate = [item.receiptDate substringWithRange:needleRange];
////            if([strDate integerValue] != lastDate)
//            if([strDate integerValue] != lastDate && [strDate integerValue] > 14)
//            {
//                if(item.priceSales > 0 && item.billings == 0)
//                {
//                    item.billings = 1;
//                    sumTotalValue += item.amountPerUnit;
//                    sumPairs++;
//                    lastDate = [strDate integerValue];
//                    if(sumPairs == requirePairs)
//                    {
//                        break;
//                    }
//                }
//            }
//        }
//    }
    NSLog(@"sumPair > requirePair");



    for(AccountInventorySummary *item in _accountInventorySummaryList)
    {
        NSInteger countSelected = 0;
        for(SalesProductAndPrice *salesProductAndPrice in _salesProductAndPriceList)
        {
            if(item.productNameID == salesProductAndPrice.productNameID)
            {
                countSelected++;
            }
        }

        item.billings = countSelected;
    }
    //
    
    
//    //select row normal case
//    NSInteger countColumn = 6;
//    UIView* view = gestureRecognizer.view;
//
//    NSInteger item = view.tag;
//    SalesProductAndPrice *salesProductAndPrice = _salesProductAndPriceList[item/countColumn-1];
//
//
//    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
//    CustomUICollectionViewCellButton2 *cell = (CustomUICollectionViewCellButton2*)[colViewData cellForItemAtIndexPath:indexPath];
//
//
//    if(salesProductAndPrice.billings == 0)
//    {
//        salesProductAndPrice.billings = 1;
//        cell.imageView.image = [UIImage imageNamed:@"select.png"];
//        [AccountInventorySummary addBillingsWithProductNameID:salesProductAndPrice.productNameID accountInventorySummary:_accountInventorySummaryList];
//    }
//    else if(salesProductAndPrice.billings == 1)
//    {
//        salesProductAndPrice.billings = 0;
//        cell.imageView.image = [UIImage imageNamed:@"unselect.png"];
//        [AccountInventorySummary removeBillingsWithProductNameID:salesProductAndPrice.productNameID accountInventorySummary:_accountInventorySummaryList];
//    }
    
    [colViewData reloadData];
   
   
    [self updateSelectedAccumSales];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if([textField isEqual:txtRequiredSales])
    {
        return;
    }
    
    if([textField isEqual:txtDateFrom] || [textField isEqual:txtDateTo])
    {
        [self queryAccountInventorySummaryWithDateFrom:txtDateFrom.text dateTo:txtDateTo.text];
        [colViewData reloadData];
        return;
    }
    
    NSInteger countColumn = 5;
    NSInteger item = textField.tag;
    
    AccountInventorySummary *accountInventory = _accountInventorySummaryList[item/countColumn-1];
    if([[Utility trimString:textField.text] isEqualToString:@""])
    {
        textField.text = @"0";
        accountInventory.billings = 0;
        [SalesProductAndPrice clearBillingsWithProductNameID:accountInventory.productNameID salesProductAndPrice:_salesProductAndPriceList];
    }
    else if([Utility floatValue:textField.text] > accountInventory.salesQuantity)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                       message:@"Billing qty. cannot exceed sales qty."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        textField.text = [NSString stringWithFormat:@"%ld",accountInventory.billings];
        return;
    }
    else if([Utility floatValue:textField.text] > accountInventory.quantity)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                       message:@"Billing qty. cannot exceed inventory qty."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        textField.text = [NSString stringWithFormat:@"%ld",accountInventory.billings];
        return;
    }
    else
    {
        accountInventory.billings = [Utility floatValue:textField.text];
        NSInteger countBillingsSales = [SalesProductAndPrice getCountBillingsWithProductNameID:accountInventory.productNameID salesProductAndPrice:_salesProductAndPriceList];
        NSInteger diffBillings = accountInventory.billings - countBillingsSales;
        if(diffBillings > 0)
        {
            [SalesProductAndPrice addBillings:diffBillings productNameID:accountInventory.productNameID salesProductAndPrice:_salesProductAndPriceList];
            [self updateSelectedAccumSales];
        }
        else if(diffBillings < 0)
        {
            [SalesProductAndPrice removeBillings:labs(diffBillings) productNameID:accountInventory.productNameID salesProductAndPrice:_salesProductAndPriceList];
            [self updateSelectedAccumSales];
        }
    }
}

- (void)sortColumnAccountInventorySummary:(id)sender
{
    UIButton *button = sender;
    NSInteger item = button.tag;
    NSArray *headerSortColumn = @[@"_productCategory2",@"_productName",@"_quantity",@"_salesQuantity"];
    
    
    BOOL ascending = ![_booAscendingAccountInventorySummary[item] boolValue];
    [_booAscendingAccountInventorySummary replaceObjectAtIndex:item withObject:[NSNumber numberWithBool:ascending]];
    
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:headerSortColumn[item] ascending:ascending];
    NSArray *sortDescriptors1 = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortedArray = [_accountInventorySummaryList sortedArrayUsingDescriptors:sortDescriptors1];
    _accountInventorySummaryList = [sortedArray mutableCopy];
    
    
    [colViewData reloadData];
}

#pragma mark <UICollectionViewDelegate>


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width;
    NSArray *arrSize;
    if(_viewInventOrSales)
    {
        arrSize = @[@75,@85,@45,@60,@0];
    }
    else
    {
        arrSize = @[@110,@85,@50,@30,@30,@0];
    }
    
    
    width = [arrSize[indexPath.item%[arrSize count]] floatValue];
    if(width == 0)
    {
        width = colViewData.bounds.size.width;
        for(int i=0; i<[arrSize count]; i++)
        {
            width = width - [arrSize[i] floatValue];
        }
    }
    
    
    CGSize size = CGSizeMake(width, 30);
    return size;
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.colViewData.collectionViewLayout;
    
    [layout invalidateLayout];
    [colViewData reloadData];
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 20, 0);//top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        
        reusableview = headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footerPayment" forIndexPath:indexPath];
        
        
        reusableview = footerview;
    }
    
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
{
    CGSize headerSize = CGSizeMake(collectionView.bounds.size.width, 0);
    return headerSize;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Register cell classes
    [colViewData registerClass:[CustomUICollectionViewCellButton2 class] forCellWithReuseIdentifier:reuseIdentifier];
    [colViewData registerClass:[CustomUICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeaderViewIdentifier];
    [colViewData registerClass:[CustomUICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:reuseFooterViewIdentifier];
    colViewData.delegate = self;
    colViewData.dataSource = self;
    
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
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
                                                              
                                                          }];
    
    [alert addAction:defaultAction];
    dispatch_async(dispatch_get_main_queue(),^ {
        [self presentViewController:alert animated:YES completion:nil];
    } );
}

- (IBAction)viewSwitched:(id)sender
{    
    [colViewData reloadData];
    _viewInventOrSales = !_viewInventOrSales;
}

-(void)updateSelectedAccumSales
{
    float totalSalesSelected = [SalesProductAndPrice getTotalSalesSelected:_salesProductAndPriceList];
    NSString *strTotalSalesSelected = [NSString stringWithFormat:@"%f",totalSalesSelected];
    
    NSInteger totalPairs = [SalesProductAndPrice getTotalPairsSelected:_salesProductAndPriceList];
    NSString *strTotalPairsSelected = [NSString stringWithFormat:@"%ld",totalPairs];
    
    
    lblCurrentAccumSales.text = [NSString stringWithFormat:@"Sales/Amount: %@/%@",[Utility formatBaht:strTotalSalesSelected],[Utility formatBaht:strTotalPairsSelected]];
    
    
    float exceedAmount = totalSalesSelected - [Utility floatValue:txtRequiredSales.text];
    NSString *strExceedAmount = [NSString stringWithFormat:@"%f",exceedAmount];
    strExceedAmount = [Utility formatBaht:strExceedAmount withMinFraction:0 andMaxFraction:2];
    if(exceedAmount>0)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                       message:[NSString stringWithFormat:@"Sales exceed required sales: %@",strExceedAmount]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end
