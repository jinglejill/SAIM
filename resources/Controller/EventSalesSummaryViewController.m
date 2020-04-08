//
//  EventSalesSummaryViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/20/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "EventSalesSummaryViewController.h"
#import "CustomUICollectionViewCellButton.h"
#import "Utility.h"
#import "SharedSelectedEvent.h"
#import "EventSalesSummaryByDate.h"
#import "CustomUICollectionReusableView.h"
#import "SharedReceipt.h"
#import "SharedReceiptItem.h"
#import "Receipt.h"
#import "EventCost.h"
#import "SharedEventCost.h"
#import "SharedCostLabel.h"
#import "CostLabel.h"
#import "ReceiptProductItem.h"
#import "SharedReceiptItem.h"
#import "SharedProduct.h"
#import "ProductName.h"


#define orangeColor         [UIColor colorWithRed:253/255.0 green:182/255.0 blue:103/255.0 alpha:1]
#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]


@interface EventSalesSummaryViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSMutableArray *_eventSalesSummaryByDateList;
    NSMutableArray *_eventCostList;
    Event *_event;
    NSString *_strEventID;
    int _orientation; //0=portrait ,1=landscape
    UIView *_viewUnderline;
}

@end
static NSString * const reuseIdentifier = @"Cell";
static NSString * const reuseHeaderViewIdentifier = @"HeaderView";
static NSString * const reuseFooterViewIdentifier = @"FooterView";
@implementation EventSalesSummaryViewController
@synthesize colViewSummaryTable;
@synthesize lblLocation;
@synthesize txtStartDate;
@synthesize txtEndDate;
@synthesize dtPicker;


- (void)textFieldDidEndEditing:(UITextField *)textField;
{
    if([textField isEqual:txtStartDate] || [textField isEqual:txtEndDate])
    {
        if([textField isEqual:txtStartDate])
        {
            NSDate *startDate = [Utility stringToDate:txtStartDate.text fromFormat:@"dd/MM/yyyy"];
            NSDate *endDate = [Utility stringToDate:txtEndDate.text fromFormat:@"dd/MM/yyyy"];
            NSComparisonResult result = [startDate compare:endDate];
            if(result == NSOrderedDescending)
            {
                //EndDate = last date of that month
                NSDate *startDate = [Utility stringToDate:txtStartDate.text fromFormat:@"dd/MM/yyyy"];
                txtEndDate.text = [Utility dateToString:[Utility getEndOfMonth:startDate] toFormat:@"dd/MM/yyyy"];
            }
        }
        else if([textField isEqual:txtEndDate])
        {
            NSDate *startDate = [Utility stringToDate:txtStartDate.text fromFormat:@"dd/MM/yyyy"];
            NSDate *endDate = [Utility stringToDate:txtEndDate.text fromFormat:@"dd/MM/yyyy"];
            NSComparisonResult result = [startDate compare:endDate];
            if(result == NSOrderedDescending)
            {
                NSDate *endDate = [Utility stringToDate:txtEndDate.text fromFormat:@"dd/MM/yyyy"];
                txtStartDate.text = [Utility dateToString:[Utility getFirstDateOfMonth:endDate] toFormat:@"dd/MM/yyyy"];
            }
        }
    }
    dispatch_async(dispatch_get_main_queue(),^ {
        [self loadingOverlayView];
    } );
    
    NSString *strStartDate = [Utility formatDate:txtStartDate.text fromFormat:@"dd/MM/yyyy" toFormat:@"yyyy-MM-dd"];
    NSString *strEndDate = [Utility formatDate:txtEndDate.text fromFormat:@"dd/MM/yyyy" toFormat:@"yyyy-MM-dd"];
    [_homeModel downloadItems:dbEventSalesSummary condition:@[_strEventID,strStartDate,strEndDate]];
    
//    [self setDataSales];
//    [self setDataExpenses];
//    [self removeOverlayViews];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField;
{
    if([textField isEqual:txtStartDate] || [textField isEqual:txtEndDate])
    {
        NSDate *datePeriod = [Utility stringToDate:textField.text fromFormat:@"dd/MM/yyyy"];
        [dtPicker setDate:datePeriod];
    }
}

- (IBAction)datePickerChanged:(id)sender
{
    if([txtStartDate isFirstResponder])
    {
        txtStartDate.text = [Utility dateToString:dtPicker.date toFormat:@"dd/MM/yyyy"];
    }
    else if([txtEndDate isFirstResponder])
    {
        txtEndDate.text = [Utility dateToString:dtPicker.date toFormat:@"dd/MM/yyyy"];
    }
}

- (NSInteger)getCountItem:(NSInteger)receiptID
{
    NSMutableArray *receiptProductItemList = [SharedReceiptItem sharedReceiptItem].receiptItemList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_receiptID = %ld",receiptID];
    NSArray *filteredArray = [receiptProductItemList filteredArrayUsingPredicate:predicate1];
    return [filteredArray count];
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
    
    
    self.navigationItem.title = [NSString stringWithFormat:@"Event - Sales Summary"];
    lblLocation.text = [NSString stringWithFormat:@"Location: %@",[SharedSelectedEvent sharedSelectedEvent].event.location];
    lblLocation.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    
    _eventSalesSummaryByDateList = [[NSMutableArray alloc]init];
    _eventCostList = [[NSMutableArray alloc]init];
    _event = [Event getSelectedEvent];
    _strEventID = [NSString stringWithFormat:@"%ld",_event.eventID];
    
    
    
    txtStartDate.delegate = self;
    txtEndDate.delegate = self;
    txtStartDate.inputView = dtPicker;
    txtEndDate.inputView = dtPicker;
    [dtPicker setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [dtPicker removeFromSuperview];
    
    
    [self loadViewProcess];
}

- (void)loadViewProcess
{
    NSDate *startDate = [Utility stringToDate:_event.periodFrom fromFormat:@"yyyy-MM-dd 00:00:00"];
    NSDate *endDate = [Utility stringToDate:_event.periodTo fromFormat:@"yyyy-MM-dd 00:00:00"];
    NSDate *startDatePlus30Days = [Utility addDay:startDate numberOfDay:30];
    NSComparisonResult result = [startDatePlus30Days compare:endDate];
    if(result == NSOrderedAscending)
    {
        NSDate *firstDateOfCurrentDate = [Utility getFirstDateOfMonth:[Utility currentDateTime]];
        NSDate *endDateOfCurrentDate = [Utility getEndOfMonth:[Utility currentDateTime]];
        txtStartDate.text = [Utility dateToString:firstDateOfCurrentDate toFormat:@"dd/MM/yyyy"];
        txtEndDate.text = [Utility dateToString:endDateOfCurrentDate toFormat:@"dd/MM/yyyy"];
    }
    else
    {
        txtStartDate.text = [Utility formatDate:_event.periodFrom fromFormat:@"yyyy-MM-dd 00:00:00" toFormat:@"dd/MM/yyyy"];
        txtEndDate.text = [Utility formatDate:_event.periodTo fromFormat:@"yyyy-MM-dd 00:00:00" toFormat:@"dd/MM/yyyy"];
    }
    
    
    [self loadingOverlayView];
    NSString *strStartDate = [Utility formatDate:txtStartDate.text fromFormat:@"dd/MM/yyyy" toFormat:@"yyyy-MM-dd"];
    NSString *strEndDate = [Utility formatDate:txtEndDate.text fromFormat:@"dd/MM/yyyy" toFormat:@"yyyy-MM-dd"];
    [_homeModel downloadItems:dbEventSalesSummary condition:@[_strEventID,strStartDate,strEndDate]];

}

- (void)itemsDownloaded:(NSArray *)items
{
    [self removeOverlayViews];
    
    int i=0;
    _eventSalesSummaryByDateList = items[i++];
    _eventCostList = items[i++];
    [_eventCostList addObjectsFromArray:items[i++]];
    
    int j=1;
    for(EventSalesSummaryByDate *item in _eventSalesSummaryByDateList)
    {
        item.row = [NSString stringWithFormat:@"%d", j++];        
    }
    [colViewSummaryTable reloadData];
    
//    [Utility setEventSales:@"1" eventID:_event.eventID];
//
//
//    [self removeOverlayViews];
//    int i=0;
//    [[SharedProduct sharedProduct].productList addObjectsFromArray:items[i++]];
//    [[SharedReceipt sharedReceipt].receiptList addObjectsFromArray:items[i++]];
//    [[SharedReceiptItem sharedReceiptItem].receiptItemList addObjectsFromArray:items[i++]];
//
//
//    [self setDataSales];
//    [self setDataExpenses];
}

-(void)setDataSales
{
    //filter eventid
    NSString *strStartDate = [Utility formatDate:txtStartDate.text fromFormat:@"dd/MM/yyyy" toFormat:@"yyyy-MM-dd 00:00:00"];
    NSString *strEndDate = [Utility formatDate:txtEndDate.text fromFormat:@"dd/MM/yyyy" toFormat:@"yyyy-MM-dd 23:59:59"];
    NSMutableArray *receiptList = [SharedReceipt sharedReceipt].receiptList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_eventID = %@ and _receiptDate >= %@ and _receiptDate <= %@",_strEventID,strStartDate,strEndDate];
    NSArray *filtedArray = [receiptList filteredArrayUsingPredicate:predicate1];
    receiptList = [filtedArray mutableCopy];
    
    
    //sort to sum sales
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_receiptDate" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortArray = [receiptList sortedArrayUsingDescriptors:sortDescriptors];
    receiptList = [sortArray mutableCopy];
    
    //sum sales
    NSInteger countItem = 0;
    float sumValue = 0.0f;
    NSString *previousDate = @"";
    [_eventSalesSummaryByDateList removeAllObjects];
    for(Receipt *item in receiptList)
    {
        NSString *receiptDate = [Utility formatDate:item.receiptDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd"];
        if([previousDate isEqualToString:@""])
        {
            countItem += [self getCountItem:item.receiptID];
            sumValue += [item.payPrice floatValue];
        }
        else if(![previousDate isEqualToString:receiptDate])
        {
            //if new date then add previous one to list
            EventSalesSummaryByDate *salesSummaryByDate = [[EventSalesSummaryByDate alloc]init];
            salesSummaryByDate.date = previousDate;
            salesSummaryByDate.sumValue = [NSString stringWithFormat:@"%f", sumValue];
            salesSummaryByDate.noOfPair = [NSString stringWithFormat:@"%ld", (long)countItem];
            [_eventSalesSummaryByDateList addObject:salesSummaryByDate];
            
            countItem = [self getCountItem:item.receiptID];
            sumValue = [item.payPrice floatValue];
        }
        else if([previousDate isEqualToString:receiptDate])
        {
            countItem += [self getCountItem:item.receiptID];
            sumValue += [item.payPrice floatValue];
        }
        previousDate = receiptDate;
    }
    
    //add last date
    if([receiptList count]>0)
    {
        EventSalesSummaryByDate *salesSummaryByDate = [[EventSalesSummaryByDate alloc]init];
        salesSummaryByDate.date = previousDate;
        salesSummaryByDate.sumValue = [NSString stringWithFormat:@"%f", sumValue];
        salesSummaryByDate.noOfPair = [NSString stringWithFormat:@"%ld", (long)countItem];
        [_eventSalesSummaryByDateList addObject:salesSummaryByDate];
    }
    
    
    
    //run row no
    int i=0;
    for(EventSalesSummaryByDate *item in _eventSalesSummaryByDateList)
    {
        i +=1;
        item.row = [NSString stringWithFormat:@"%d", i];
    }
    
    [colViewSummaryTable reloadData];
}

- (void)setDataExpenses
{
    //filter eventid
    _eventCostList = [SharedEventCost sharedEventCost].eventCostList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_eventID = %@",_strEventID];
    NSArray *filtedArray = [_eventCostList filteredArrayUsingPredicate:predicate1];
    _eventCostList = [filtedArray mutableCopy];
    
    for(EventCost *item in _eventCostList)
    {
        if(![item.costLabelID isEqualToString:@"0"])
        {
            item.costLabel = [self getCostLabel:item.costLabelID];
        }
        item.floatCost = [item.cost floatValue];
    }
    
    
    //sort to sum sales
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_floatCost" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortArray = [_eventCostList sortedArrayUsingDescriptors:sortDescriptors];
    _eventCostList = [sortArray mutableCopy];
    
    
    //add product cost (variable cost)
    EventCost *eventCost = [[EventCost alloc]init];
    eventCost.costLabel = @"Product cost";
    eventCost.cost = [self getProductCost];
    [_eventCostList insertObject:eventCost atIndex:0];
}

- (NSString *)getCostLabel:(NSString *)costLabelID
{
    NSMutableArray *costLabelList = [SharedCostLabel sharedCostLabel].costLabelList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_costLabelID = %@",costLabelID];
    NSArray *filtedArray = [costLabelList filteredArrayUsingPredicate:predicate1];
    
    return ((CostLabel*)filtedArray[0]).costLabel;
}

- (NSString *)getProductCost
{
    //prepare receiptproductitem to include event and productcost
    NSMutableArray *receiptProductItemList = [SharedReceiptItem sharedReceiptItem].receiptItemList;
    for(ReceiptProductItem *item in receiptProductItemList)
    {
        ProductSales *productCost = [Utility getProductCost:item.productType productID:item.productID];
        Receipt *receipt = [Utility getReceipt:item.receiptID];
        item.eventID = receipt.eventID;
        item.itemCost = productCost.cost;
        if([item.productType isEqualToString:@"I"])
        {
            Product *product = [Product getProduct:item.productID];
            ProductName *productName = [ProductName getProductNameWithProductID:product.productID];
            item.productName = productName.name;
        }
        else if([item.productType isEqualToString:@"C"])
        {
            CustomMade *customMade = [Utility getCustomMade:[item.productID integerValue]];
            NSString *productNameGroup = [NSString stringWithFormat:@"%@%@%@",customMade.productCategory2,customMade.productCategory1,customMade.productName];
            NSString *customMadeProductName = [ProductName getNameWithProductNameGroup:productNameGroup];
            item.productName = customMadeProductName;
        }
    }
    
    //filter by event
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_eventID = %ld",_strEventID];
    NSArray *filteredArray = [receiptProductItemList filteredArrayUsingPredicate:predicate1];
    receiptProductItemList = [filteredArray mutableCopy];
    
    float sumProductCostEvent = 0;
    for(ReceiptProductItem *item in receiptProductItemList)
    {
        sumProductCostEvent += [item.itemCost floatValue];
    }
    
    
    return [NSString stringWithFormat:@"%f",sumProductCostEvent];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Register cell classes
    [colViewSummaryTable registerClass:[CustomUICollectionViewCellButton class] forCellWithReuseIdentifier:reuseIdentifier];
    [colViewSummaryTable registerClass:[CustomUICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeaderViewIdentifier];
    [colViewSummaryTable registerClass:[CustomUICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:reuseFooterViewIdentifier];
    
    colViewSummaryTable.delegate = self;
    colViewSummaryTable.dataSource = self;
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (NSInteger)getCellNumSales
{
    NSInteger count = [_eventSalesSummaryByDateList count];
    NSInteger countColumn = 4;
    return (count+1)*countColumn + 3;
}

- (NSInteger)getCellNumExpenses
{
    NSInteger count = [_eventCostList count];
    NSInteger countColumn = 2;
    return (count+2)*countColumn;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger numberOfItems=0;
    if(section == 0){numberOfItems = [self getCellNumSales];}
    else if(section == 1){numberOfItems = [self getCellNumExpenses];}
    else if(section == 2){numberOfItems = 2;}
    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CustomUICollectionViewCellButton *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if ([cell.label isDescendantOfView:cell]) {
        [cell.label removeFromSuperview];
    }
    
    if ([cell.imageView isDescendantOfView:cell]) {
        [cell.imageView removeFromSuperview];
    }
    if ([cell.leftBorder isDescendantOfView:cell]) {
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
    
    NSInteger item = indexPath.item;
    NSInteger section = indexPath.section;
    if(section == 0)
    {
        NSInteger totalCell = [self getCellNumSales];
        NSArray *header = @[@"No.",@"Date",@"Pairs",@"Amount"];
        NSInteger countColumn = [header count];
        
        if(item/countColumn==0)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
            cell.label.textColor= [UIColor whiteColor];
            cell.label.backgroundColor = tBlueColor;
            cell.label.textAlignment = NSTextAlignmentCenter;
        }
        else if(item == totalCell-3)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
            cell.label.textColor= [UIColor whiteColor];
            cell.label.backgroundColor = tBlueColor;
            cell.label.textAlignment = NSTextAlignmentLeft;
        }
        else if(item == totalCell-2 || item == totalCell-1)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
            cell.label.textColor= [UIColor whiteColor];
            cell.label.backgroundColor = tBlueColor;
            cell.label.textAlignment = NSTextAlignmentRight;
        }
        else if(item%countColumn == 0 || item%countColumn == 1)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
            cell.label.textColor= [UIColor blackColor];
            cell.label.backgroundColor = [UIColor clearColor];
            cell.label.textAlignment = NSTextAlignmentCenter;
            
            [cell addSubview:cell.leftBorder];
            [cell addSubview:cell.topBorder];
            [cell addSubview:cell.rightBorder];
            [cell addSubview:cell.bottomBorder];
        }
        else if(item%countColumn == 2 || item%countColumn == 3)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
            cell.label.textColor= [UIColor blackColor];
            cell.label.backgroundColor = [UIColor clearColor];
            cell.label.textAlignment = NSTextAlignmentRight;
            
            [cell addSubview:cell.leftBorder];
            [cell addSubview:cell.topBorder];
            [cell addSubview:cell.rightBorder];
            [cell addSubview:cell.bottomBorder];
        }
        
        
        if(item/countColumn == 0)
        {
            NSInteger remainder = item%countColumn;
            cell.label.text = header[remainder];
        }
        else if(item == totalCell-3)
        {
            cell.label.text = @"Total amount";
        }
        else if(item == totalCell-2)
        {
            cell.label.text = [NSString stringWithFormat:@"%ld", (long)[self getTotalNoOfPair]];
        }
        else if(item == totalCell-1)
        {
            NSString *totalAmount = [NSString stringWithFormat:@"%f", [self getTotalAmount] ];
            cell.label.text = [Utility formatBaht:totalAmount withMinFraction:0 andMaxFraction:0];
        }
        else
        {
            EventSalesSummaryByDate *eventSalesSummaryByDate = _eventSalesSummaryByDateList[item/countColumn-1];
            switch (item%countColumn) {
                case 0:
                {
                    cell.label.text = eventSalesSummaryByDate.row;
                }
                    break;
                case 1:
                {
                    cell.label.text = eventSalesSummaryByDate.date;
                }
                    break;
                case 2:
                {
                    cell.label.text = eventSalesSummaryByDate.noOfPair;
                }
                    break;
                case 3:
                {
                    NSString *strSumValue = eventSalesSummaryByDate.sumValue;
                    cell.label.text = [Utility formatBaht:strSumValue withMinFraction:0 andMaxFraction:0];
                }
                    break;
                default:
                    break;
            }
        }
    }
    else if(section == 1)
    {
        NSInteger totalCell = [self getCellNumExpenses];
        NSArray *header = @[@"Category" ,@"Amount"];
        NSInteger countColumn = [header count];
        
        if(item/countColumn == 0)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
            cell.label.textColor= [UIColor whiteColor];
            cell.label.backgroundColor = tBlueColor;
            cell.label.textAlignment = NSTextAlignmentCenter;
        }
        else if(item == totalCell-2)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
            cell.label.textColor= [UIColor whiteColor];
            cell.label.backgroundColor = tBlueColor;
            cell.label.textAlignment = NSTextAlignmentLeft;
        }
        else if(item == totalCell-1)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
            cell.label.textColor= [UIColor whiteColor];
            cell.label.backgroundColor = tBlueColor;
            cell.label.textAlignment = NSTextAlignmentRight;
        }
        else if(item%countColumn == 0)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
            cell.label.textColor= [UIColor blackColor];
            cell.label.backgroundColor = [UIColor clearColor];
            cell.label.textAlignment = NSTextAlignmentLeft;
            
            [cell addSubview:cell.leftBorder];
            [cell addSubview:cell.topBorder];
            [cell addSubview:cell.rightBorder];
            [cell addSubview:cell.bottomBorder];
        }
        else if(item%countColumn == 1)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
            cell.label.textColor= [UIColor blackColor];
            cell.label.backgroundColor = [UIColor clearColor];
            cell.label.textAlignment = NSTextAlignmentRight;
            
            [cell addSubview:cell.leftBorder];
            [cell addSubview:cell.topBorder];
            [cell addSubview:cell.rightBorder];
            [cell addSubview:cell.bottomBorder];
        }
        
        
        if(item/countColumn == 0)
        {
            NSInteger remainder = item%countColumn;
            cell.label.text = header[remainder];
        }
        else if(item == totalCell-2)
        {
            cell.label.text = @"Total amount";
        }
        else if(item == totalCell-1)
        {
            NSString *totalAmount = [NSString stringWithFormat:@"%f", [self getTotalExpenses] ];
            cell.label.text = [Utility formatBaht:totalAmount withMinFraction:0 andMaxFraction:0];
        }
        else
        {
            EventCost *eventCost = _eventCostList[item/countColumn-1];
            switch (item%countColumn) {
                case 0:
                {
                    cell.label.text = eventCost.costLabel;
                }
                    break;
                case 1:
                {
                    NSString *strSumValue = eventCost.cost;
                    cell.label.text = [Utility formatBaht:strSumValue withMinFraction:0 andMaxFraction:0];
                }
                    break;
                default:
                    break;
            }
        }
    }
    else if (section == 2)
    {
        NSInteger countColumn = 2;
        
        if(item%countColumn == 0)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
            cell.label.textColor= [UIColor whiteColor];
            cell.label.backgroundColor = tBlueColor;
            cell.label.textAlignment = NSTextAlignmentLeft;
            cell.label.text = @"Overall total";
        }
        else if(item%countColumn == 1)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
            cell.label.textColor= [UIColor blackColor];
            cell.label.backgroundColor = [UIColor whiteColor];
            cell.label.textAlignment = NSTextAlignmentRight;
            NSString *totalAmount = [NSString stringWithFormat:@"%f", [self getTotalAmount] - [self getTotalExpenses] ];
            cell.label.text = [Utility formatBaht:totalAmount withMinFraction:0 andMaxFraction:0];
            
            [cell addSubview:cell.leftBorder];
            [cell addSubview:cell.topBorder];
            [cell addSubview:cell.rightBorder];
            [cell addSubview:cell.bottomBorder];
        }
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //    [@"No",@"Date",@"Total amount",@"Total no. of pair"];
    CGFloat width;
    NSInteger section = indexPath.section;
    
    if(section == 0)
    {
        NSArray *arrSize = @[@30,@0,@40,@130];
        CGFloat size0 = 0;
        size0 = colViewSummaryTable.bounds.size.width;
        
        for(int i=0; i<[arrSize count]; i++)
        {
            size0 -= [arrSize[i] floatValue];
        }
        size0 -= 40;// inset
        
        if(indexPath.item == [self getCellNumSales]-3)
        {
            width = [arrSize[0] floatValue] + size0;
        }
        else if(indexPath.item == [self getCellNumSales]-2)
        {
            width = [arrSize[2] floatValue];
        }
        else if(indexPath.item == [self getCellNumSales]-1)
        {
            width = [arrSize[3] floatValue];
        }
        else
        {
            width = [arrSize[indexPath.item%[arrSize count]] floatValue]!=0?[arrSize[indexPath.item%[arrSize count]] floatValue]:size0;
        }
    }
    else
    {
        NSArray *arrSize = @[@0,@130];
        width = [arrSize[indexPath.item%[arrSize count]] floatValue];
        if(width == 0)
        {
            width = colViewSummaryTable.bounds.size.width;
            for(int i=0; i<[arrSize count]; i++)
            {
                width = width - [arrSize[i] floatValue];
            }
            width -= 40;
        }
    }
    
    CGSize size = CGSizeMake(width, 20);
    return size;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.colViewSummaryTable.collectionViewLayout;
    
    [layout invalidateLayout];
    [colViewSummaryTable reloadData];
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 20, 20, 20);//top, left, bottom, right -> collection view
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
        CustomUICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        
        if(indexPath.section == 0)
        {
            [headerView.labelAlignRight removeFromSuperview];
            CGRect frame = headerView.bounds;
            frame.origin.x = frame.origin.x + 20;
            headerView.label.frame = frame;
            headerView.label.textAlignment = NSTextAlignmentLeft;
            headerView.label.text = @"Sales";
            headerView.label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
            [headerView addSubview:headerView.label];
            
            
            CGRect frame2 = headerView.bounds;
            frame2.size.width = frame2.size.width - 20;
            headerView.labelAlignRight.frame = frame2;
            headerView.labelAlignRight.textAlignment = NSTextAlignmentRight;
            NSString *strCountItem = [NSString stringWithFormat:@"%ld",[_eventSalesSummaryByDateList count]];
            strCountItem = [Utility formatBaht:strCountItem];
            headerView.labelAlignRight.text = strCountItem;
            [headerView addSubview:headerView.labelAlignRight];
            [self setLabelUnderline:headerView.labelAlignRight underline:headerView.viewUnderline];
        }
        else if(indexPath.section == 1)
        {
            [headerView.labelAlignRight removeFromSuperview];
            CGRect frame = headerView.bounds;
            frame.origin.x = frame.origin.x + 20;
            headerView.label.frame = frame;
            headerView.label.textAlignment = NSTextAlignmentLeft;
            headerView.label.text = @"Expenses";
            headerView.label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
            [headerView addSubview:headerView.label];
            
            
            CGRect frame2 = headerView.bounds;
            frame2.size.width = frame2.size.width - 20;
            headerView.labelAlignRight.frame = frame2;
            headerView.labelAlignRight.textAlignment = NSTextAlignmentRight;
            NSString *strCountItem = [NSString stringWithFormat:@"%ld",[_eventCostList count]];
            strCountItem = [Utility formatBaht:strCountItem];
            headerView.labelAlignRight.text = strCountItem;
            [headerView addSubview:headerView.labelAlignRight];
            [self setLabelUnderline:headerView.labelAlignRight underline:headerView.viewUnderline];
        }
        else if(indexPath.section == 2)
        {
            [headerView.labelAlignRight removeFromSuperview];
            
            CGRect frame = headerView.bounds;
            frame.origin.x = frame.origin.x + 20;
            headerView.label.frame = frame;
            headerView.label.textAlignment = NSTextAlignmentLeft;
            headerView.label.text = @"Overall";
            headerView.label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
            [headerView addSubview:headerView.label];
        }
        
        reusableview = headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        
        reusableview = footerview;
    }
    
    return reusableview;
}

-(UILabel *)setLabelUnderline:(UILabel *)label underline:(UIView *)viewUnderline
{
    //    CGSize expectedLabelSize = [label.text sizeWithFont:label.font constrainedToSize:label.frame.size lineBreakMode:label.lineBreakMode];
    //
    //
    
    
    CGRect expectedLabelSize = [label.text boundingRectWithSize:label.frame.size
                                                        options:NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading
                                                     attributes:@{NSFontAttributeName:label.font}
                                                        context:nil];
    CGFloat xOrigin=0;
    switch (label.textAlignment) {
        case NSTextAlignmentCenter:
            xOrigin=(label.frame.size.width - expectedLabelSize.size.width)/2;
            break;
        case NSTextAlignmentLeft:
            xOrigin=0;
            break;
        case NSTextAlignmentRight:
            xOrigin=label.frame.size.width - expectedLabelSize.size.width;
            break;
        default:
            break;
    }
    viewUnderline.frame=CGRectMake(xOrigin,
                                   expectedLabelSize.size.height-1,
                                   expectedLabelSize.size.width,
                                   1);
    viewUnderline.backgroundColor=label.textColor;
    [label addSubview:viewUnderline];
    return label;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
{
    CGSize headerSize = CGSizeMake(collectionView.bounds.size.width, 20);
    return headerSize;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    CGSize footerSize = CGSizeMake(collectionView.bounds.size.width, 20);
    return footerSize;
}

- (float)getTotalExpenses
{
    float totalCost = 0;
    for(EventCost *item in _eventCostList)
    {
        totalCost += [item.cost floatValue];
    }
    return totalCost;
}

- (NSInteger)getTotalNoOfPair
{
    NSInteger totalNoOfPair = 0;
    for(EventSalesSummaryByDate *item in _eventSalesSummaryByDateList)
    {
        totalNoOfPair += [item.noOfPair intValue];
    }
    return totalNoOfPair;
}

- (float)getTotalAmount
{
    float totalAmount = 0;
    for(EventSalesSummaryByDate *item in _eventSalesSummaryByDateList)
    {
        totalAmount += [item.sumValue floatValue];
    }
    return totalAmount;
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

@end
