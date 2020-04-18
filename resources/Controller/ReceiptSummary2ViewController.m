//
//  ReceiptSummary2ViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/3/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "ReceiptSummary2ViewController.h"
#import "AccountReceiptPDFViewController.h"
#import "ExpenseDailyViewController.h"
#import "Utility.h"
#import "CustomTableViewCellReceipt.h"
#import "CustomTableViewCellReceiptProductItem.h"
#import "CustomTableViewCellReceiptShort.h"
#import "CustomUICollectionViewCellButton2.h"
#import "Event.h"
#import "SharedSelectedEvent.h"
#import "CashAllocation.h"
#import "AddEditPostCustomerViewController.h"
#import "CustomMade.h"
#import "Receipt.h"
#import "ReceiptProductItem.h"
#import "PreOrderScanViewController.h"
#import "CustomerReceipt.h"
#import "CustomCollectionViewFlowLayout.h"
#import "SharedProduct.h"
#import "SharedCustomMade.h"
#import "SharedReceipt.h"
#import "SharedReceiptItem.h"
#import "SharedCustomerReceipt.h"
#import "SharedPostCustomer.h"
#import "SharedPushSync.h"
#import "PushSync.h"
#import "RewardPoint.h"
#import "SharedRewardPoint.h"
#import "PreOrderEventIDHistory.h"
#import "ProductName.h"
#import "AccountInventorySummary.h"
#import "SalesProductAndPrice.h"
#import "ExpenseDaily.h"
#import "ItemTrackingNo.h"
#import "Message.h"


/* Macro for background colors */
#define tYellow          [UIColor colorWithRed:251/255.0 green:188/255.0 blue:5/255.0 alpha:1]
#define tTheme          [UIColor colorWithRed:196/255.0 green:164/255.0 blue:168/255.0 alpha:1]
#define orangeColor         [UIColor colorWithRed:253/255.0 green:182/255.0 blue:103/255.0 alpha:1]
#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]

#define colorWithRGBHex(hex)[UIColor colorWithRed:((float)((hex&0xFF0000)>>16))/255.0 green:((float)((hex&0xFF00)>>8))/255.0 blue:((float)(hex&0xFF))/255.0 alpha:1.0]
#define clearColorWithRGBHex(hex)[UIColor colorWithRed:MIN((((int)(hex>>16)&0xFF)/255.0)+.1,1.0)green:MIN((((int)(hex>>8)&0xFF)/255.0)+.1,1.0)blue:MIN((((int)(hex)&0xFF)/255.0)+.1,1.0)alpha:1.0]

/* Unselected mark constants */
#define kCircleRadioUnselected      23.0
#define kCircleLeftMargin           13.0
#define kCircleRect                 CGRectMake(3.5, 2.5, 22.0, 22.0)
#define kCircleOverlayRect          CGRectMake(1.5, 12.5, 26.0, 23.0)

/* Mark constants */
#define kStrokeWidth                2.0
#define kShadowRadius               4.0
#define kMarkDegrees                70.0
#define kMarkWidth                  3.0
#define kMarkHeight                 6.0
#define kShadowOffset               CGSizeMake(.0, 2.0)
#define kMarkShadowOffset           CGSizeMake(.0, -1.0)
#define kMarkImageSize              CGSizeMake(30.0, 30.0)
#define kMarkBase                   CGPointMake(9.0, 13.5)
#define kMarkDrawPoint              CGPointMake(20.0, 9.5)
#define kShadowColor                [UIColor colorWithWhite:.0 alpha:0.7]
#define kMarkShadowColor            [UIColor colorWithWhite:.0 alpha:0.3]
#define kBlueColor                  0x236ed8
#define kGreenColor                 0x179714
#define kRedColor                   0xa4091c
#define kMarkColor                  kRedColor

/* Colums and cell constants */
#define kColumnPosition             50.0
#define kMarkCell                   60.0
#define kImageRect                  CGRectMake(10.0, 8.0, 30.0, 30.0)


@interface ReceiptSummary2ViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    UIActivityIndicatorView *indicator2;
    Event *_event;
    NSString *_strEventID;
    NSMutableArray *_salesSummaryList;
    NSNumberFormatter *_formatter;
    BOOL _booChangesOrTransfer; //yes = changes, no = transfer
    UILabel *_lblFrontTotalCredit;
    UILabel *_lblFrontTotalCash;
    UILabel *_lblFrontTotalAmount;

    
    UILabel *_lblFrontInitialChanges;
    UILabel *_lblFrontTransfer;
    UILabel *_lblFrontCashAndChanges;
    
    
    UIButton *_btnAfterTransfer;
    NSString *_selectedReceiptProductItemID;
    NSInteger _selectedIndexPathForRow;
    NSString *_strSelectedDateDB;
    UISegmentedControl *_segmentControl;
    NSArray *_receiptList;
    NSArray *_receiptProductItemList;

    NSDate *_selectedDateTime;
    NSString *_preOrderProductID;
    NSString *_preOrderReceiptProductItemID;
    BOOL _booAddOrEdit;
    NSString *_selectedReceiptID;
    NSDate *_selectedDate;
    NSMutableArray *_dayRange;
    NSMutableArray *_dateRange;
    
    UITextField *_txtCMSize;
    UITextField *_txtCMToe;
    UITextField *_txtCMBody;
    UITextField *_txtCMAccessory;
    UITextField *_txtCMRemark;
    UIButton *_btnSaveCM;
    UIButton *_btnCancelCM;
    NSInteger _customMadeIDEdit;
    CustomMade *_customMadeInitial;
    BOOL _booShortOrDetail;
    
    UITextField *_txtChanges;
    UITextField *_txtTransfer;
    BOOL _refreshingControl;
    NSMutableArray *_preOrderEventIDHistoryList;
    
    
    
    
    NSMutableArray *_salesProductAndPriceBillingsOnlyList;
    NSMutableArray *_accountInventorySummaryList;
    NSString *_dateOut;
    Receipt *_selectedPrintReceipt;
    
    
    NSMutableArray *_receiptListForDate;
    NSMutableArray *_receiptProductItemListForDate;
    NSMutableArray *_productListForDate;
    NSMutableArray *_customMadeListForDate;
    NSMutableArray *_itemTrackingNoListForDate;
    NSMutableArray *_postCustomerListForDate;
    NSMutableArray *_preOrderEventIDHistoryListForDate;
    NSMutableArray *_cashAllocationListForDate;
    NSMutableArray *_expenseDailyListForDate;
 
    NSMutableArray *_selectedReceiptProductItemList;
    PostCustomer *_selectedPostCustomer;
    UIView *_vwDimBackground;
    
    
    UITextField *_txtReferenceOrderNo;
//    UITapGestureRecognizer *_singleTap;
}

@end


static NSString * const reuseIdentifier = @"Cell";
static NSString * const reuseHeaderViewIdentifier = @"HeaderView";
static NSString * const reuseFooterViewIdentifier = @"FooterView";
static NSString * const reuseIdentifierReceipt = @"CustomTableViewCellReceipt";
static NSString * const reuseIdentifierReceiptProductItem = @"CustomTableViewCellReceiptProductItem";
static NSString * const reuseIdentifierReceiptShort = @"CustomTableViewCellReceiptShort";
@implementation ReceiptSummary2ViewController
@synthesize lblLocation;
@synthesize lblDate;
@synthesize btnChangeDate;
@synthesize dtPicker;
@synthesize customMadeView;
@synthesize btnShortOrDetail;
@synthesize preOrderEventIDHistoryView;
@synthesize titleAndCloseButtonView;
@synthesize tbvData;


- (IBAction)unwindToReceiptSummary2:(UIStoryboardSegue *)segue
{
    if([segue.sourceViewController isMemberOfClass:[AddEditPostCustomerViewController class]])
    {
        if([[segue identifier] isEqualToString:@"segUnwindToReceiptSummary2"])
        {
            AddEditPostCustomerViewController *vc = segue.sourceViewController;
            if(vc.selectedPostCustomer)
            {
                PostCustomer *postCustomer = [self getPostCustomer:vc.selectedPostCustomer.postCustomerID];
                if(postCustomer)
                {
                    [_postCustomerListForDate removeObject:postCustomer];
                }
                [_postCustomerListForDate addObject: vc.selectedPostCustomer];
                            
                
                for(ReceiptProductItem *item in _selectedReceiptProductItemList)
                {
                    ItemTrackingNo *itemTrackingNo = [self getItemTrackingNo:item.receiptProductItemID];
                    itemTrackingNo.postCustomerID = vc.selectedPostCustomer.postCustomerID;
                }
                [self setData];
            }
        }
        else if([[segue identifier] isEqualToString:@"segUnwindToReceiptSummary2Cancel"])
        {
            [self setData];
        }
        else if([[segue identifier] isEqualToString:@"segUnwindToReceiptSummary2Delete"])
        {
            for(ReceiptProductItem *item in _selectedReceiptProductItemList)
            {
                ItemTrackingNo *itemTrackingNo = [self getItemTrackingNo:item.receiptProductItemID];
                itemTrackingNo.postCustomerID = 0;
            }
            [self setData];
        }
    }
    else if([segue.sourceViewController isMemberOfClass:[ExpenseDailyViewController class]])
    {
        ExpenseDailyViewController *vc = segue.sourceViewController;
        _expenseDailyListForDate = vc.expenseDailyList;
        
        [self setData];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
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
    
    
    _formatter = [NSNumberFormatter new];
    _formatter.numberStyle = NSNumberFormatterDecimalStyle;
        

    [_homeModel updateItems:dbUserAccountUpdateCountNotSeen withData:@""];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    _booShortOrDetail = YES;
    
    
    [self loadViewProcess];
}

- (void)loadViewProcess
{
    [dtPicker setHidden:YES];
    
    
    _event = [Event getSelectedEvent];
    _strEventID = [NSString stringWithFormat:@"%ld",_event.eventID];
    
    //prepare event date for segment control
    NSDate *datePeriodTo = [Utility stringToDate:_event.periodTo fromFormat:[Utility setting:vFormatDateDB]];
    NSDate *datePeriodFrom = [Utility stringToDate:_event.periodFrom fromFormat:[Utility setting:vFormatDateDB]];
    
    NSInteger numberOfDays = [Utility numberOfDaysFromDate:datePeriodFrom dateTo:datePeriodTo];
    NSDate *dateNow = [Utility GMTDate:[Utility dateFromDateTime:[NSDate date]]];
    
    dtPicker.minimumDate = datePeriodFrom;
    dtPicker.maximumDate = datePeriodTo;
    
    //prepare array for segment control and selectedDate
    NSInteger selectedSegmentControl = 0;
    int daysToAdd = 0;
    _dayRange = [[NSMutableArray alloc]init];
    _dateRange = [[NSMutableArray alloc]init];
    for(int i = 0; i<numberOfDays; i++)
    {
        daysToAdd = i;
        NSDate *newDate1 = [datePeriodFrom dateByAddingTimeInterval:60*60*24*daysToAdd];
        
        [_dateRange addObject: newDate1];
    }
    
    
    float sizeOfEachSegment = 30;
    NSInteger widthSegCon = [_dateRange count]*sizeOfEachSegment;//size of each segment = 50
    NSInteger maximumSize = self.view.frame.size.width-16*2;//ลบ margin ข้างละ 16
    
    
    _selectedDate = dateNow;
    NSInteger numAvailableShowDate;
    if(widthSegCon > maximumSize)
    {
        NSInteger countDate = 0;
        numAvailableShowDate = maximumSize/sizeOfEachSegment;
        widthSegCon = maximumSize;
        NSMutableArray *removeDate = [[NSMutableArray alloc]init];
        for(NSInteger i=numberOfDays-1; i>=0; i--)
        {
            countDate++;
            if(countDate <= numAvailableShowDate && [_dateRange[i] isEqual:_selectedDate])
            {
                for(int j=0; j<numberOfDays-numAvailableShowDate; j++)
                {
                    [removeDate addObject:_dateRange[j]];
                }
                selectedSegmentControl = numAvailableShowDate-countDate;
                break;
            }
            else if(countDate > numAvailableShowDate && ![_dateRange[i] isEqual:_selectedDate])
            {
                [removeDate addObject:_dateRange[[_dateRange count]-(countDate-numAvailableShowDate)]];
            }
            else if(countDate > numAvailableShowDate && [_dateRange[i] isEqual:_selectedDate])
            {
                for(int j=0; j<numberOfDays-countDate; j++)
                {
                    [removeDate addObject:_dateRange[j]];
                }
                selectedSegmentControl = 0;
                break;
            }
        }
        
        [_dateRange removeObjectsInArray:removeDate];
    }
    else
    {
        for(int i=0; i<[_dateRange count]; i++)
        {
            if([_dateRange[i] isEqual:_selectedDate])
            {
                selectedSegmentControl = i;
            }
        }
    }
    
    for(int i=0; i<[_dateRange count]; i++)
    {
        NSInteger day = [Utility dayFromDateTime:_dateRange[i]];
        [_dayRange addObject:[NSString stringWithFormat:@"%lu",(long)day]];
    }
    
    
    //create segment control
    [_segmentControl removeFromSuperview];
    _segmentControl = [[UISegmentedControl alloc]initWithItems:_dayRange];
    _segmentControl.tintColor = [UIColor blackColor];
    NSInteger xOriginSegCon = (self.view.bounds.size.width-widthSegCon)/2;
    _segmentControl.frame = CGRectMake(xOriginSegCon, 70, widthSegCon, 16);
    [_segmentControl addTarget:self action:@selector(segmentedControlValueDidChange:) forControlEvents:UIControlEventValueChanged];
    [_segmentControl setSelectedSegmentIndex:selectedSegmentControl];
    [self segmentedControlValueDidChange:_segmentControl];
    [self.view addSubview:_segmentControl];
    
    
    //event location
    lblLocation.text =  [NSString stringWithFormat:@"Location: %@", _event.location];
    lblLocation.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    [lblLocation sizeToFit];
}

-(void)segmentedControlValueDidChange:(UISegmentedControl *)segment
{
    [customMadeView removeFromSuperview];
    [preOrderEventIDHistoryView removeFromSuperview];
    [_txtReferenceOrderNo removeFromSuperview];
    
    
    _selectedDateTime = (NSDate*)(_dateRange[segment.selectedSegmentIndex]);
//    _selectedDateTimeEndOfDay = [_selectedDateTime dateByAddingTimeInterval:60*60*24*1-1];
    NSString *strSelectedDateDisplay = [Utility dateToString:_selectedDateTime toFormat:[Utility setting:vFormatDateDisplay]];
    _strSelectedDateDB = [Utility dateToString:_selectedDateTime toFormat:[Utility setting:vFormatDateDB]];
    
    
    //display
    lblDate.text = [NSString stringWithFormat:@"%@",strSelectedDateDisplay];
    lblDate.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    
    
    [self fetchData];
}

- (void) changeSegmentControlData:(NSDate *)selectedDate
{
    //prepare event date for segment control
    NSDate *datePeriodTo = [Utility stringToDate:_event.periodTo fromFormat:[Utility setting:vFormatDateDB]];
    NSDate *datePeriodFrom = [Utility stringToDate:_event.periodFrom fromFormat:[Utility setting:vFormatDateDB]];
    NSInteger numberOfDays = [Utility numberOfDaysFromDate:datePeriodFrom dateTo:datePeriodTo];
    

    dtPicker.minimumDate = datePeriodFrom;
    dtPicker.maximumDate = datePeriodTo;
    
    //prepare array for segment control and selectedDate
    NSInteger selectedSegmentControl = 0;
    int daysToAdd = 0;
    _dayRange = [[NSMutableArray alloc]init];
    _dateRange = [[NSMutableArray alloc]init];
    for(int i = 0; i<numberOfDays; i++)
    {
        daysToAdd = i;
        NSDate *newDate1 = [datePeriodFrom dateByAddingTimeInterval:60*60*24*daysToAdd];
        
        [_dateRange addObject: newDate1];
    }
    
    
    float sizeOfEachSegment = 30;
    NSInteger widthSegCon = [_dateRange count]*sizeOfEachSegment;//size of each segment = 50
    NSInteger maximumSize = self.view.frame.size.width-16*2;//ลบ margin ข้างละ 16
    
    
    _selectedDate = selectedDate;//dateNow;
    NSInteger numAvailableShowDate;
    if(widthSegCon > maximumSize)
    {
        NSInteger countDate = 0;
        numAvailableShowDate = maximumSize/sizeOfEachSegment;
        widthSegCon = numAvailableShowDate*sizeOfEachSegment;//size of each segment = 50
        NSMutableArray *removeDate = [[NSMutableArray alloc]init];
        for(NSInteger i=numberOfDays-1; i>=0; i--)
        {
            countDate++;
            if(countDate <= numAvailableShowDate && [_dateRange[i] isEqual:_selectedDate])
            {
                for(int j=0; j<numberOfDays-numAvailableShowDate; j++)
                {
                    [removeDate addObject:_dateRange[j]];
                }
                selectedSegmentControl = numAvailableShowDate-countDate;
                break;
            }
            else if(countDate > numAvailableShowDate && ![_dateRange[i] isEqual:_selectedDate])
            {
                [removeDate addObject:_dateRange[[_dateRange count]-(countDate-numAvailableShowDate)]];
            }
            else if(countDate > numAvailableShowDate && [_dateRange[i] isEqual:_selectedDate])
            {
                for(int j=0; j<numberOfDays-countDate; j++)
                {
                    [removeDate addObject:_dateRange[j]];
                }
                selectedSegmentControl = 0;
                break;
            }
        }
        [_dateRange removeObjectsInArray:removeDate];
    }
    else
    {
        for(int i=0; i<[_dateRange count]; i++)
        {
            if([_dateRange[i] isEqual:_selectedDate])
            {
                selectedSegmentControl = i;
            }
        }
    }
    
    for(int i=0; i<[_dateRange count]; i++)
    {
        NSInteger day = [Utility dayFromDateTime:_dateRange[i]];
        [_dayRange addObject:[NSString stringWithFormat:@"%lu",(long)day]];
    }
    
    //change segment items
    //change selected segment index
    [_segmentControl removeAllSegments];
    for(int i=0; i<[_dateRange count]; i++)
    {
        [_segmentControl insertSegmentWithTitle:_dayRange[i] atIndex:i animated:NO];
    }
    [_segmentControl setSelectedSegmentIndex:selectedSegmentControl];
    [self segmentedControlValueDidChange:_segmentControl];
}

-(void)fetchData
{
    [self loadingOverlayView];
    [_homeModel downloadItems:dbSalesForDate condition:@[_strEventID,_selectedDateTime]];
}

-(void)setData
{
   _receiptList = _receiptListForDate;
    _receiptProductItemList = _receiptProductItemListForDate;
    for(ReceiptProductItem *item in _receiptProductItemList)
    {
        if(item.isPreOrder2)
        {
            ProductName *productName = [ProductName getProductName:item.preOrder2ProductNameID];
            item.productName = productName.name;
            item.color = [Utility getColorName:item.preOrder2Color];
            item.size = [Utility getSizeLabel:item.preOrder2Size];
            item.sizeOrder = [Utility getSizeOrder:item.preOrder2Size];
        }
        else if([item.productType isEqualToString:@"I"] || [item.productType isEqualToString:@"A"] || [item.productType isEqualToString:@"P"] || [item.productType isEqualToString:@"D"] || [item.productType isEqualToString:@"S"] || [item.productType isEqualToString:@"F"] || [item.productType isEqualToString:@"U"])
        {
            Product *product = [self getProduct:item.productID];
            NSString *productNameGroup = [NSString stringWithFormat:@"%@%@%@",product.productCategory2,product.productCategory1,product.productName];
            item.productName = [ProductName getNameWithProductNameGroup:productNameGroup];
            item.color = [Utility getColorName:product.color];
            item.size = [Utility getSizeLabel:product.size];
            item.sizeOrder = [Utility getSizeOrder:product.size];
        }
        else if([item.productType isEqualToString:@"C"] || [item.productType isEqualToString:@"B"] || [item.productType isEqualToString:@"E"] || [item.productType isEqualToString:@"V"])
        {
            CustomMade *customMade = [self getCustomMade:[item.productID integerValue]];
            NSString *productNameGroup = [NSString stringWithFormat:@"%@%@%@",customMade.productCategory2,customMade.productCategory1,customMade.productName];
            item.productName = [ProductName getNameWithProductNameGroup:productNameGroup];
            item.color = customMade.body;
            item.size = customMade.size;
            item.sizeOrder = [Utility getSizeOrder:customMade.size];
            item.toe = customMade.toe;
            item.body = customMade.body;
            item.accessory = customMade.accessory;
            item.customMadeRemark = customMade.remark;
        }
        else if([item.productType isEqualToString:@"R"])
        {
            CustomMade *customMade = [self getCustomMadeFromProductIDPost:item.productID];
            NSString *productNameGroup = [NSString stringWithFormat:@"%@%@%@",customMade.productCategory2,customMade.productCategory1,customMade.productName];
            item.productName = [ProductName getNameWithProductNameGroup:productNameGroup];
            item.color = customMade.body;
            item.size = customMade.size;
            item.sizeOrder = [Utility getSizeOrder:customMade.size];
            item.toe = customMade.toe;
            item.body = customMade.body;
            item.accessory = customMade.accessory;
            item.customMadeRemark = customMade.remark;
        }
    }
    
    
    //เรียงตาม receiptid, item,color,size
    {
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_receiptID" ascending:NO];
        NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_productName" ascending:YES];
        NSSortDescriptor *sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:@"_color" ascending:YES];
        NSSortDescriptor *sortDescriptor4 = [[NSSortDescriptor alloc] initWithKey:@"_sizeOrder" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2,sortDescriptor3,sortDescriptor4, nil];
        _receiptProductItemList = [_receiptProductItemList sortedArrayUsingDescriptors:sortDescriptors];
    }
    
    [self prepareDataForCollectionView];
        
    [tbvData reloadData];

    //set summary
    self.txtInitialChanges.delegate = self;
    self.txtDeposit.delegate = self;
    self.txtInitialChanges.text = [_formatter stringFromNumber:[NSNumber numberWithFloat:[self initialChanges]]];
    self.txtDeposit.text = [_formatter stringFromNumber:[NSNumber numberWithFloat:[self deposit]]];
    self.lblCashAndChanges.text = [_formatter stringFromNumber:[NSNumber numberWithFloat:[self cashAndChanges]]];
    self.lblSalesPerChange.text = [self salesPerChange];
    
    self.lblTotalCash.text = [_formatter stringFromNumber:[NSNumber numberWithFloat:[self totalCash]]];
    self.lblTotalCredit.text = [_formatter stringFromNumber:[NSNumber numberWithFloat:[self totalCredit]]];
    self.lblTotalTransfer.text = [_formatter stringFromNumber:[NSNumber numberWithFloat:[self totalTransfer]]];
    self.lblTotalAmount.text = [_formatter stringFromNumber:[NSNumber numberWithFloat:[self totalAmount]]];
    self.lblTotalDiscount.text = [_formatter stringFromNumber:[NSNumber numberWithFloat:[self totalDiscount]]];;
    
    NSString *strExpense = [_formatter stringFromNumber:[NSNumber numberWithFloat:[self expense]]];;
    [self.btnExpense setTitle:strExpense forState:UIControlStateNormal];
    
    
    //initial changes is editable only at the date equal to the first date of event
    Event *event = [SharedSelectedEvent sharedSelectedEvent].event;
    self.txtInitialChanges.enabled = event.dtPeriodFrom == _selectedDateTime;
    
        
    //deposit value can be changed only at the date equal to current date
    self.txtDeposit.enabled = [[Utility dateToString:_selectedDateTime toFormat:@"yyyy-MM-dd"] isEqualToString: [Utility dateToString:[Utility currentDateTime] toFormat:@"yyyy-MM-dd"]];
    
    
    //expense value can be changed only at the date equal to current date
    self.btnExpense.enabled = [[Utility dateToString:_selectedDateTime toFormat:@"yyyy-MM-dd"] isEqualToString: [Utility dateToString:[Utility currentDateTime] toFormat:@"yyyy-MM-dd"]];
    
}

-(void)itemsDownloaded:(NSArray *)items
{
    [self removeOverlayViews];
    

    if(_homeModel.propCurrentDB == dbSalesForDate)
    {
        int i=0;
        
        _receiptListForDate = items[i++];
        _receiptProductItemListForDate = items[i++];
        _productListForDate = items[i++];
        _customMadeListForDate = items[i++];
        _itemTrackingNoListForDate = items[i++];
        _postCustomerListForDate = items[i++];
        _preOrderEventIDHistoryListForDate = items[i++];
        _expenseDailyListForDate = items[i++];
        _cashAllocationListForDate = items[i++];
        
        [self setData];
    }

}

-(void)prepareDataForCollectionView
{
    //allocate cash, credit, transfer to each receiptProductItem
    NSInteger previousReceiptID = 0;
    float remainingCash = 0;
    float remainingCredit = 0;
    float remainingTransfer = 0;
    float remainingPayItem = 0;
    int row = 0;
    for(ReceiptProductItem *item in _receiptProductItemList)
    {
        if(previousReceiptID != item.receiptID)
        {
            Receipt *receipt = [self getReceipt:item.receiptID];
            previousReceiptID = item.receiptID;
            
            
            remainingCash = [receipt.cashAmount floatValue];
            remainingCredit = [receipt.creditAmount floatValue];
            remainingTransfer = [receipt.transferAmount floatValue];
            row = 0;
        
        }
        
        item.row = [NSString stringWithFormat:@"%d",++row];
        
        float discountValue = 0;
        if(item.discount == 1)
        {
            discountValue = item.discountValue;
        }
        else if(item.discount == 2)
        {
            discountValue = roundf(item.discountPercent*[Utility floatValue:item.priceSales]/100*100)/100;
        }
        remainingPayItem = [item.priceSales floatValue] + item.shippingFee - discountValue;
        
        //cash
        if(remainingPayItem <= remainingCash)
        {
            item.cash = remainingPayItem;
            remainingCash -= remainingPayItem;
            continue;
        }
        else
        {
            item.cash = remainingCash;
            remainingCash = 0;
            remainingPayItem -= item.cash;
            if(remainingPayItem <= remainingCredit)
            {
                item.credit = remainingPayItem;
                remainingCredit -= remainingPayItem;
                continue;
            }
            else
            {
                item.credit = remainingCredit;
                remainingCredit = 0;
                remainingPayItem -= item.credit;
                if(remainingPayItem <= remainingTransfer)
                {
                    item.transfer = remainingPayItem;
                    remainingTransfer -= remainingPayItem;
                    continue;
                }
            }
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self loadingOverlayView];
    
    if(textField == self.txtInitialChanges || textField == self.txtDeposit)
    {
        NSString *strChangesRemoveComma = [[Utility trimString:self.txtInitialChanges.text] stringByReplacingOccurrencesOfString:@"," withString:@""];
        NSString *strDepositRemoveComma = [[Utility trimString:self.txtDeposit.text] stringByReplacingOccurrencesOfString:@"," withString:@""];
        CashAllocation *cashAllocation = [[CashAllocation alloc]init];
        cashAllocation.eventID = _strEventID;
        cashAllocation.inputDate = _strSelectedDateDB;
        cashAllocation.cashChanges = [strChangesRemoveComma floatValue]==0?@"0":strChangesRemoveComma;
        cashAllocation.cashTransfer = [strDepositRemoveComma floatValue]==0?@"0":strDepositRemoveComma;
        cashAllocation.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
        [self loadingOverlayView];
        [_homeModel updateItems:dbCashAllocationByEventIDAndInputDate withData:cashAllocation];
    }
    else if(textField == _txtReferenceOrderNo)
    {
        NSString *strReceiptID = [NSString stringWithFormat:@"%ld",textField.tag];
        NSString *strReferenceOrderNo = [Utility trimString:_txtReferenceOrderNo.text];
        [self loadingOverlayView];
        [_homeModel updateItems:dbReceiptReferenceOrderNo withData:@[strReceiptID,strReferenceOrderNo]];
    }
    else
    {
        //txtRemark
        
        Receipt *_receiptRemark = [[Receipt alloc]init];
        _receiptRemark.receiptID = textField.tag;
        _receiptRemark.remark = [Utility trimString:textField.text];
        
        _homeModel = [[HomeModel alloc] init];
        _homeModel.delegate = self;
        [_homeModel updateItems:dbReceipt withData:_receiptRemark];
    }
}

-(BOOL)customMadeChanged
{
    NSString *allText = [NSString stringWithFormat:@"%@%@%@%@%@",_txtCMSize.text,_txtCMToe.text,_txtCMBody.text,_txtCMAccessory.text,_txtCMRemark.text];
    NSString *allDBText = [NSString stringWithFormat:@"%@%@%@%@%@",_customMadeInitial.size,_customMadeInitial.toe,_customMadeInitial.body,_customMadeInitial.accessory,_customMadeInitial.remark];
    if([allText isEqualToString:allDBText])
    {
        return NO;
    }
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //dimBackground
    _vwDimBackground = [[UIView alloc]initWithFrame:self.view.frame];
    _vwDimBackground.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    
    
    
    //Register table
    tbvData.delegate = self;
    tbvData.dataSource = self;
    tbvData.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    {
        UINib *nib = [UINib nibWithNibName:reuseIdentifierReceipt bundle:nil];
        [tbvData registerNib:nib forCellReuseIdentifier:reuseIdentifierReceipt];
    }
    {
        UINib *nib = [UINib nibWithNibName:reuseIdentifierReceiptShort bundle:nil];
        [tbvData registerNib:nib forCellReuseIdentifier:reuseIdentifierReceiptShort];
    }

    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tapGesture];
    [tapGesture setCancelsTouchesInView:NO];

    
    
    [[NSBundle mainBundle] loadNibNamed:@"CustomMadeView" owner:self options:nil];
    customMadeView.delegate = self;
    customMadeView.dataSource = self;
    customMadeView.backgroundColor = [UIColor lightGrayColor];
    
    
    [[NSBundle mainBundle] loadNibNamed:@"PreOrderEventIDHistoryView" owner:self options:nil];
    preOrderEventIDHistoryView.delegate = self;
    preOrderEventIDHistoryView.dataSource = self;

    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0,0, self.view.frame.size.width, 40)];
    headerView.backgroundColor = tBlueColor;
    preOrderEventIDHistoryView.tableHeaderView = headerView;
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(0,12, 200, 25)];
    title.text = @"Pre-order event history";
    title.textColor = [UIColor whiteColor];
    [headerView addSubview:title];
    UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnClose.frame = CGRectMake(self.view.frame.size.width-50,12, 50, 25);
    [btnClose setTitle:@"Close" forState:UIControlStateNormal];
    [btnClose setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnClose setBackgroundColor:tBlueColor];
    [btnClose addTarget:self action:@selector(closePreOrderEventIDHistoryView:)
       forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:btnClose];
    
    
    {
        
        //customMadeView ***************
        float customViewWidth = 180;
        float customViewHeight = 264;
        customMadeView.frame = CGRectMake((self.view.frame.size.width-customViewWidth)/2, (self.view.frame.size.height-customViewHeight)/2, customViewWidth, customViewHeight);
        
        {
            //add dropshadow
            customMadeView.layer.shadowRadius  = 1.5f;
            customMadeView.layer.shadowColor   = [UIColor colorWithRed:176.f/255.f green:199.f/255.f blue:226.f/255.f alpha:1.f].CGColor;
            customMadeView.layer.shadowOffset  = CGSizeMake(0.0f, 0.0f);
            customMadeView.layer.shadowOpacity = 0.9f;
            customMadeView.layer.masksToBounds = NO;

            UIEdgeInsets shadowInsets     = UIEdgeInsetsMake(0, 0, -1.5f, 0);
            UIBezierPath *shadowPath      = [UIBezierPath bezierPathWithRect:UIEdgeInsetsInsetRect(customMadeView.bounds, shadowInsets)];
            customMadeView.layer.shadowPath    = shadowPath.CGPath;
        }
        //******************************
        
        
    
        //preOrderEventIDHistoryView *********
        float preOrderEventIDHistoryViewWidth = self.view.frame.size.width;
        float preOrderEventIDHistoryViewHeight = self.view.frame.size.width;
        preOrderEventIDHistoryView.frame = CGRectMake((self.view.frame.size.width-preOrderEventIDHistoryViewWidth)/2, (self.view.frame.size.height-preOrderEventIDHistoryViewHeight)/2, preOrderEventIDHistoryViewWidth, preOrderEventIDHistoryViewHeight);
        
        //add dropshadow
        {
            preOrderEventIDHistoryView.layer.shadowRadius  = 1.5f;
            preOrderEventIDHistoryView.layer.shadowColor   = [UIColor colorWithRed:176.f/255.f green:199.f/255.f blue:226.f/255.f alpha:1.f].CGColor;
            preOrderEventIDHistoryView.layer.shadowOffset  = CGSizeMake(0.0f, 0.0f);
            preOrderEventIDHistoryView.layer.shadowOpacity = 0.9f;
            preOrderEventIDHistoryView.layer.masksToBounds = NO;

            UIEdgeInsets shadowInsets     = UIEdgeInsetsMake(0, 0, -1.5f, 0);
            UIBezierPath *shadowPath      = [UIBezierPath bezierPathWithRect:UIEdgeInsetsInsetRect(preOrderEventIDHistoryView.bounds, shadowInsets)];
            preOrderEventIDHistoryView.layer.shadowPath    = shadowPath.CGPath;
        }
        //************************************
        
        
        float controlWidth = 300;
        float controlHeight = 25;
        float controlXOrigin = 20;
        float controlYOrigin = 3+(customMadeView.rowHeight-25)/2;
        
        
        _txtCMSize = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, controlHeight)];
        _txtCMSize.placeholder = @"Size";
        _txtCMSize.clearButtonMode = UITextFieldViewModeWhileEditing;
        _txtCMSize.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
        _txtCMSize.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
        
        _txtCMToe = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, controlHeight)];
        _txtCMToe.placeholder = @"Toe";
        _txtCMToe.clearButtonMode = UITextFieldViewModeWhileEditing;
        _txtCMToe.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
        _txtCMToe.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
        
        _txtCMBody = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, controlHeight)];
        _txtCMBody.placeholder = @"Body";
        _txtCMBody.clearButtonMode = UITextFieldViewModeWhileEditing;
        _txtCMBody.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
        _txtCMBody.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
        
        _txtCMAccessory = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, controlHeight)];
        _txtCMAccessory.placeholder = @"Accessory";
        _txtCMAccessory.clearButtonMode = UITextFieldViewModeWhileEditing;
        _txtCMAccessory.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
        _txtCMAccessory.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
        
        _txtCMRemark = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, controlHeight)];
        _txtCMRemark.placeholder = @"Remark";
        _txtCMRemark.clearButtonMode = UITextFieldViewModeWhileEditing;
        _txtCMRemark.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
        _txtCMRemark.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
        
        
        float saveCMWidth = 44;
        _btnSaveCM = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _btnSaveCM.frame = CGRectMake(controlXOrigin, controlYOrigin, saveCMWidth, controlHeight);
        [_btnSaveCM setTitle:@"Save" forState:UIControlStateNormal];
        [_btnSaveCM setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
        _btnSaveCM.titleLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Medium" size:14];
        [_btnSaveCM addTarget:self action:@selector(saveCM:) forControlEvents:UIControlEventTouchUpInside];
        _btnSaveCM.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        
        _btnCancelCM = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _btnCancelCM.frame = CGRectMake(controlXOrigin+saveCMWidth, controlYOrigin, saveCMWidth, controlHeight);
        [_btnCancelCM setTitle:@"Cancel" forState:UIControlStateNormal];
        [_btnCancelCM setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
        _btnCancelCM.titleLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Medium" size:14];
        [_btnCancelCM addTarget:self action:@selector(cancelCM:) forControlEvents:UIControlEventTouchUpInside];
        _btnCancelCM.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    
    
    //txtReferenceOrderNo
    {
        float controlWidth = 300;
        float controlHeight = 44;
        float controlXOrigin = 20;
        float controlYOrigin = 20;
        _txtReferenceOrderNo = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, controlHeight)];
        _txtReferenceOrderNo.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
        _txtReferenceOrderNo.placeholder = @"Reference order no.";
//        _txtReferenceOrderNo.clearButtonMode = UITextFieldViewModeWhileEditing;
        _txtReferenceOrderNo.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
        _txtReferenceOrderNo.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:14];
        _txtReferenceOrderNo.delegate = self;
        
        //add dropshadow
        {
            _txtReferenceOrderNo.layer.shadowRadius  = 1.5f;
            _txtReferenceOrderNo.layer.shadowColor   = [UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:0.f/255.f alpha:1.f].CGColor;
            _txtReferenceOrderNo.layer.shadowOffset  = CGSizeMake(0.f, 0.f);
            _txtReferenceOrderNo.layer.shadowOpacity = 0.2f;
            _txtReferenceOrderNo.layer.masksToBounds = NO;

            UIEdgeInsets shadowInsets     = UIEdgeInsetsMake(0, 0, -1.5f, 0);
            UIBezierPath *shadowPath      = [UIBezierPath bezierPathWithRect:UIEdgeInsetsInsetRect(_txtReferenceOrderNo.bounds, shadowInsets)];
            _txtReferenceOrderNo.layer.shadowPath    = shadowPath.CGPath;
        }
    }
    
}

- (BOOL) hasPost:(NSInteger)receiptID
{
    BOOL hasPost = NO;
    NSArray *receiptProductItemList = [self getReceiptProductItemList:receiptID];
    for(ReceiptProductItem *item in receiptProductItemList)
    {
        ItemTrackingNo *itemTrackingNo = [self getItemTrackingNo:item.receiptProductItemID];
        if(itemTrackingNo.postCustomerID > 0)
        {
            hasPost = YES;
            break;
        }
    }
    
    return hasPost;
}

- (void) addEditPostCustomer:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger receiptID = button.tag;
    _selectedPostCustomer = [self getPostCustomerFromReceiptID:receiptID];
    _selectedReceiptProductItemList = [[self getReceiptProductItemList:receiptID] mutableCopy];
    [self performSegueWithIdentifier:@"segPostCustomer" sender:self];
}

-(void)viewPreOrderHistory:(NSInteger)receiptProductItemID
{
    ReceiptProductItem *receiptProductItem = [self getReceiptProductItem:receiptProductItemID];
    
    
    _preOrderEventIDHistoryList = [self getHistoryWithReceiptProductItemID:receiptProductItem.receiptProductItemID];
    [preOrderEventIDHistoryView reloadData];
    
    //set height
    CGRect frame = preOrderEventIDHistoryView.frame;
    frame.size.height = 44*[_preOrderEventIDHistoryList count]+44;
    preOrderEventIDHistoryView.frame = frame;
    
    {
        preOrderEventIDHistoryView.alpha = 0.0;
        [self.view addSubview:_vwDimBackground];
        [self.view addSubview:preOrderEventIDHistoryView];
        [UIView animateWithDuration:0.2 animations:^{
            preOrderEventIDHistoryView.alpha = 1.0;
        }];
    }
}

- (void) changeProduct:(NSInteger)receiptProductItemID
{
    ReceiptProductItem *receiptProductItem = [self getReceiptProductItem:receiptProductItemID];
    
    if([receiptProductItem.productType isEqualToString:@"U"] || [receiptProductItem.productType isEqualToString:@"V"])
    {
        UIAlertController* alert = [UIAlertController
            alertControllerWithTitle:@"Cannnot change product"
            message:@"Product is unidentified"
            preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
            handler:^(UIAlertAction * action)
            {}];
        
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                            preferredStyle:UIAlertControllerStyleActionSheet];
                            
                            
    [alert addAction:
     [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Change product (No.%@)",receiptProductItem.row]
                              style:UIAlertActionStyleDestructive
                            handler:^(UIAlertAction *action) {
                                //update receiptproductitem producttype=xx,productID=customMadeEdit
                                //update product status = 'I'
                                //update customMade productIDPost = ''
                                //customerreceipt trackingno คงไว้
                                
                                NSMutableArray *arrProduct = [[NSMutableArray alloc]init];
                                NSMutableArray *arrCustomMade = [[NSMutableArray alloc]init];;
                                NSMutableArray *arrReceiptProductItem = [[NSMutableArray alloc]init];;
                                if([receiptProductItem.productType isEqualToString:@"I"] || [receiptProductItem.productType isEqualToString:@"P"] || [receiptProductItem.productType isEqualToString:@"R"] || [receiptProductItem.productType isEqualToString:@"S"])
                                {
                                    Product *product = [[Product alloc]init];
                                    product.productID = receiptProductItem.productID;
                                    product.status = @"I";
                                    product.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                                    product.modifiedUser = [Utility modifiedUser];
                                    [arrProduct addObject:product];
                                }
                                ReceiptProductItem *receiptProductItemUpdate = [[ReceiptProductItem alloc]init];
                                receiptProductItemUpdate.receiptProductItemID = receiptProductItem.receiptProductItemID;
                                receiptProductItemUpdate.productID = receiptProductItem.productID;
                                if([receiptProductItem.productType isEqualToString:@"I"])
                                {
                                    receiptProductItemUpdate.productType = @"A";
                                }
                                else if([receiptProductItem.productType isEqualToString:@"C"])
                                {
                                    receiptProductItemUpdate.productType = @"B";
                                }
                                else if([receiptProductItem.productType isEqualToString:@"P"])
                                {
                                    receiptProductItemUpdate.productType = @"D";
                                }
                                else if([receiptProductItem.productType isEqualToString:@"R"])
                                {
                                    if(receiptProductItem.isPreOrder2)
                                    {
                                        receiptProductItemUpdate.productID = @"";
                                        receiptProductItemUpdate.productType = @"E";
                                    }
                                    else
                                    {
                                        CustomMade *customMade = [[CustomMade alloc]init];
                                        NSString *strCustomMadeID = [NSString stringWithFormat:@"%ld",customMade.customMadeID];
                                        customMade.productIDPost = @"";
                                        customMade.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                                        customMade.modifiedUser = [Utility modifiedUser];
                                        [arrCustomMade addObject:customMade];
                                        
                                        receiptProductItemUpdate.productID = strCustomMadeID;
                                        receiptProductItemUpdate.productType = @"E";
                                    }
                                }
                                else if([receiptProductItem.productType isEqualToString:@"S"])
                                {
                                    receiptProductItemUpdate.productType = @"F";
                                }
                                receiptProductItemUpdate.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                                receiptProductItemUpdate.modifiedUser = [Utility modifiedUser];
                                [arrReceiptProductItem addObject:receiptProductItemUpdate];
                                
                                
                                
                                NSArray *arrData = @[arrProduct,arrCustomMade,arrReceiptProductItem];
                                [self loadingOverlayView];
                                [_homeModel updateItems:dbReceiptProductItemAndProductUpdate withData:arrData];
                                
//                                [self fetchData];
                            }]];
    [alert addAction:
     [UIAlertAction actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleCancel
                            handler:^(UIAlertAction *action) {}]];
    
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)deleteReceiptTapped:(id)sender
{
    UIButton *deleteButton = (UIButton *)sender;
    NSInteger receiptID = deleteButton.tag;

    
    
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:nil
                                    preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:
         [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Delete sales"]
                                  style:UIAlertActionStyleDestructive
                                handler:^(UIAlertAction *action) {
                                    //delete Receipt
                                    //delete customerreceipt
                                    //delete receiptproductitem
                                    //delete custommade
                                    //update product set status = I
                                    //postcustomer คงไว้ เป็นฐานรายชื่อลูกค้า แต่เราลบตัว link postcustomer ใน customerreceipt ไปแล้ว
                                    _selectedReceiptID = [NSString stringWithFormat:@"%ld", receiptID];
                                    Receipt *receipt = [self getReceipt:receiptID];
                                    NSArray *arrItemTrackingNo = [self getItemTrackingNoList:receiptID];
                                    NSArray *arrReceiptProductItem = [self getReceiptProductItemList:receiptID];
                                    NSArray *arrCustomMade = [self getCustomMadeList:arrReceiptProductItem];
                                    NSArray *arrProduct = [self getProductList:arrReceiptProductItem];
                                    NSMutableArray *arrRewardPoint = [RewardPoint getRewardPointWithReceiptID:receiptID];
                                    [[SharedRewardPoint sharedRewardPoint].rewardPointList removeObjectsInArray:arrRewardPoint];
                                    

                                    NSMutableArray *updateProductList = [[NSMutableArray alloc]init];
                                    for(Product *item in arrProduct)
                                    {
                                        Product *updateProduct = [[Product alloc]init];
                                        updateProduct.productID = item.productID;
                                        updateProduct.status = @"I";
                                        updateProduct.remark = @"";
                                        updateProduct.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                                        updateProduct.modifiedUser = [Utility modifiedUser];
                                        [updateProductList addObject:updateProduct];
                                    }
                                    {
                                        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_receiptProductItemID" ascending:YES];
                                        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
                                        NSArray *sortArray = [arrReceiptProductItem sortedArrayUsingDescriptors:sortDescriptors];
                                        arrReceiptProductItem = sortArray;
                                    }
                                    {
                                        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_customMadeID" ascending:YES];
                                        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
                                        NSArray *sortArray = [arrCustomMade sortedArrayUsingDescriptors:sortDescriptors];
                                        arrCustomMade = sortArray;
                                    }
                                    {
                                        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_productID" ascending:YES];
                                        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
                                        NSArray *sortArray = [updateProductList sortedArrayUsingDescriptors:sortDescriptors];
                                        updateProductList = [sortArray mutableCopy];
                                    }
                                    
                                    NSArray *arrData = @[receipt,arrItemTrackingNo,arrReceiptProductItem,arrCustomMade,updateProductList];
                                    [self loadingOverlayView];
                                    [_homeModel deleteItems:dbReceiptAndReceiptProductItemDelete withData:arrData];
                                                                        
                                }]];
        [alert addAction:
         [UIAlertAction actionWithTitle:@"Cancel"
                                  style:UIAlertActionStyleCancel
                                handler:^(UIAlertAction *action) {}]];
        
        //////////////ipad
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            [alert setModalPresentationStyle:UIModalPresentationPopover];
            
            UIPopoverPresentationController *popPresenter = [alert
                                                             popoverPresentationController];
            CGRect frame = deleteButton.imageView.bounds;
            frame.origin.y = frame.origin.y-15;
            popPresenter.sourceView = deleteButton.imageView;
            popPresenter.sourceRect = frame;
            //        popPresenter.barButtonItem = _barButtonIpad;
        }
        ///////////////
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)itemsDeletedWithReturnData:(NSArray *)data
{
    [self removeOverlayViews];
    if(_homeModel.propCurrentDB == dbReceiptAndReceiptProductItemDelete)
    {
        NSInteger receiptID = [_selectedReceiptID integerValue];
        Receipt *receipt = [self getReceipt:receiptID];
        NSArray *arrItemTrackingNo = [self getItemTrackingNoList:receiptID];
        NSArray *arrReceiptProductItem = [self getReceiptProductItemList:receiptID];
        NSArray *arrCustomMade = [self getCustomMadeList:arrReceiptProductItem];
        NSArray *arrProduct = [self getProductList:arrReceiptProductItem];
       
       
        
        [_receiptListForDate removeObject:receipt];
        [_itemTrackingNoListForDate removeObjectsInArray:arrItemTrackingNo];
        [_receiptProductItemListForDate removeObjectsInArray:arrReceiptProductItem];
        [_customMadeListForDate removeObjectsInArray:arrCustomMade];
        for(Product *item in arrProduct)
        {
            item.status = @"I";
            item.remark = @"";
            item.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
            item.modifiedUser = [Utility modifiedUser];
        }
        
        [self setData];
        
        
        NSArray *messageList = data[0];
        InAppMessage *message = messageList[0];
        NSString *strMessage = message.message;
        if(![Utility isStringEmpty:message.message])
        {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                   message:strMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      
                                                                  }];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if(tableView == tbvData)
    {
        if(_booShortOrDetail)
        {
            return 1;
        }
        else
        {
            return [_receiptListForDate count];
        }
    }

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger row = 0;
    if(tableView == tbvData)
    {
        if(_booShortOrDetail)
        {
            row = [_receiptProductItemListForDate count];
        }
        else
        {
            row = 1;
        }
    }
    else if(tableView == customMadeView)
    {
        row = 6;
    }
    else if(tableView == preOrderEventIDHistoryView)
    {
        row = [_preOrderEventIDHistoryList count];
    }
    else
    {
        row = [[self getReceiptProductItemList:tableView.tag] count];
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if(tableView == tbvData)
    {
        if(_booShortOrDetail)
        {
            CustomTableViewCellReceiptShort *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierReceiptShort];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
         
            ReceiptProductItem *receiptProductItem = _receiptProductItemList[indexPath.item];
            Receipt *receipt = [self getReceipt:receiptProductItem.receiptID];
            cell.lblProduct.text = [NSString stringWithFormat:@"%ld. %@",indexPath.item+1,receiptProductItem.productName];
            cell.lblColor.text = receiptProductItem.color;
            cell.lblSize.text = receiptProductItem.size;
            
            
            if([receipt.payPrice isEqualToString:@"0"])
            {
                cell.lblCash.text = @"-";
                cell.lblCredit.text = @"-";
                cell.lblTransfer.text = @"-";
            }
            else
            {
                NSString *strCash = [NSString stringWithFormat:@"%f",receiptProductItem.cash];
                cell.lblCash.text = receiptProductItem.cash == 0?@"-":[Utility formatBaht:strCash];
                NSString *strCredit = [NSString stringWithFormat:@"%f",receiptProductItem.credit];
                cell.lblCredit.text = receiptProductItem.credit == 0?@"-":[Utility formatBaht:strCredit];
                NSString *strTransfer = [NSString stringWithFormat:@"%f",receiptProductItem.transfer];
                cell.lblTransfer.text = receiptProductItem.transfer == 0?@"-":[Utility formatBaht:strTransfer];

            }
            return cell;
        }
        else
        {
            CustomTableViewCellReceipt *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierReceipt];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            
            Receipt *receipt = _receiptListForDate[indexPath.section];
            NSString *receiptTime = [Utility formatDate:receipt.receiptDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"HH:mm"];
            
            cell.lblReceiptLabel.text = [NSString stringWithFormat:@"%ld. Receipt",indexPath.section+1];
            [cell.lblReceiptLabel sizeToFit];
            cell.lblReceiptLabelWidth.constant = cell.lblReceiptLabel.frame.size.width;


            NSString *receiptNoID = [NSString stringWithFormat:@"#%@ (%@)",receipt.receiptNoID,receiptTime];
            [cell.btnReceipt setTitle:receiptNoID forState:UIControlStateNormal];
            
            
            cell.lblCash.text = [receipt.cashAmount isEqualToString:@"0"]?@"-":[Utility formatBaht:receipt.cashAmount];
            cell.lblCredit.text = [receipt.creditAmount isEqualToString:@"0"]?@"-":[Utility formatBaht:receipt.creditAmount];
            cell.lblTransfer.text = [receipt.transferAmount isEqualToString:@"0"]?@"-":[Utility formatBaht:receipt.transferAmount];
            
            cell.lblTotal.text = [Utility formatBaht:receipt.total];
            cell.lblShippingFee.text = [Utility formatBaht:receipt.shippingFee];
            
            
            //discountValue
            float discountValue = 0;
            NSString *strDiscountValue = @"";
            NSString *strDiscountLabel = @"Discount";
            if([receipt.discount isEqualToString:@"1"])//baht
            {
                discountValue = [receipt.discountValue floatValue];
            }
            else if([receipt.discount isEqualToString:@"2"])//percent
            {
                discountValue = [receipt.discountPercent floatValue]*[receipt.total floatValue]/100;
                strDiscountLabel = [NSString stringWithFormat:@"Disc (%@\uFF05)",receipt.discountPercent];
            }
            strDiscountValue = [NSString stringWithFormat:@"%f",discountValue];
            
            NSString *minusSign = discountValue > 0?@"-":@"";            
            cell.lblDiscount.text = [NSString stringWithFormat:@"%@%@",minusSign,[Utility formatBaht:strDiscountValue]];
            
            
            cell.lblAfterDiscount.text = [Utility formatBaht:receipt.payPrice];
            
            
            //discountReason
            NSArray *receiptProductItemList = [self getReceiptProductItemList:receipt.receiptID];
            NSString *strDiscountReason = @"";
            for(ReceiptProductItem *item in receiptProductItemList)
            {
                if([Utility isStringEmpty:strDiscountReason])
                {
                    strDiscountReason = [NSString stringWithFormat:@"%@",item.discountReason];
                }
                else
                {
                    strDiscountReason = [NSString stringWithFormat:@"%@,%@",strDiscountReason,item.discountReason];
                }
            }
            cell.lblDiscountReason.text = strDiscountReason;
            if(![Utility isStringEmpty:strDiscountReason])
            {
                [cell.lblDiscountReason sizeToFit];
                cell.lblDiscountReasonHeight.constant = cell.lblDiscountReason.frame.size.height;
            }
            
            
            
            //remark
            cell.txtRemark.text = receipt.remark;
            cell.txtRemark.tag = receipt.receiptID;
            cell.txtRemark.delegate = self;
            
            
            //tbvData for receiptProductItem
            cell.tbvData.tag = receipt.receiptID;
            
            //Register table
            cell.tbvData.delegate = self;
            cell.tbvData.dataSource = self;
            
            {
                UINib *nib = [UINib nibWithNibName:reuseIdentifierReceiptProductItem bundle:nil];
                [cell.tbvData registerNib:nib forCellReuseIdentifier:reuseIdentifierReceiptProductItem];
            }
            {
                NSArray *receiptProductItemList = [self getReceiptProductItemList:receipt.receiptID];
                float tableViewHeight = [receiptProductItemList count]*30;
                cell.tbvDataHeight.constant = tableViewHeight;
                [cell.tbvData reloadData];
            }
            
            
            
            
            //button for delivery address
            cell.btnPostCustomer.tag = receipt.receiptID;
            
            
            
            if([self hasPost:receipt.receiptID])
            {
                cell.btnPostCustomer.imageView.image = [UIImage imageNamed:@"postCustomer2.png"];
                [cell.btnPostCustomer addTarget:self action:@selector(addEditPostCustomer:) forControlEvents:UIControlEventTouchUpInside];
            }
            else
            {
                cell.btnPostCustomer.imageView.image = [UIImage imageNamed:@"postCustomerNo2.png"];
                [cell.btnPostCustomer addTarget:self action:@selector(addEditPostCustomer:) forControlEvents:UIControlEventTouchUpInside];
            }

            
            //button delete
            cell.btnDelete.tag = receipt.receiptID;
            [cell.btnDelete addTarget:self action:@selector(deleteReceiptTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            return cell;
        }
    }
    else if(tableView == customMadeView)
    {
        switch (indexPath.row) {
            case 0:
            [cell addSubview:_txtCMSize];
            break;
            case 1:
            [cell addSubview:_txtCMToe];
            break;
            case 2:
            [cell addSubview:_txtCMBody];
            break;
            case 3:
            [cell addSubview:_txtCMAccessory];
            break;
            case 4:
            [cell addSubview:_txtCMRemark];
            break;
            case 5:
            {
//                [cell addSubview:_txtCMRemark];
                [cell addSubview:_btnSaveCM];
                [cell addSubview:_btnCancelCM];
            }
            break;
        }
    }
    else if(tableView == preOrderEventIDHistoryView)
    {
        PreOrderEventIDHistory *preOrderEventIDHistory = _preOrderEventIDHistoryList[indexPath.row];
        cell.textLabel.text = [Event getEvent:preOrderEventIDHistory.preOrderEventID].location;
        cell.detailTextLabel.text = [Utility formatDate:preOrderEventIDHistory.modifiedDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd HH:mm"];
    }
    else
    {
        //table for receiptProductItem
        NSArray *receiptProductItemList = [self getReceiptProductItemList:tableView.tag];
        ReceiptProductItem *receiptProductItem = receiptProductItemList[indexPath.item];
        
        
        CustomTableViewCellReceiptProductItem *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierReceiptProductItem];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        NSString *strProduct = [NSString stringWithFormat:@"%ld. %@ / %@ / %@",(indexPath.item+1),receiptProductItem.productName,receiptProductItem.color,receiptProductItem.size];
        if([receiptProductItem.productType isEqualToString:@"A"]
        || [receiptProductItem.productType isEqualToString:@"B"]
        || [receiptProductItem.productType isEqualToString:@"D"]
        || [receiptProductItem.productType isEqualToString:@"E"]
        || [receiptProductItem.productType isEqualToString:@"F"]
        )
        {
            //change product
            NSDictionary* attributes = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
            NSAttributedString* attrText = [[NSAttributedString alloc] initWithString:strProduct attributes:attributes];
            
            [cell.btnProduct setAttributedTitle:attrText forState:UIControlStateNormal];
        }
        else
        {
            [cell.btnProduct setTitle:strProduct forState:UIControlStateNormal];
        }
        
        [cell.btnProduct addTarget:self action:@selector(showActionList:) forControlEvents:UIControlEventTouchUpInside];
        cell.btnProduct.tag = receiptProductItem.receiptProductItemID;
        
        
        
        
        //I=Inventory,C=Custom made,A=change I,B=change C,P=preorder,D=change P,S=post preorder,R=post CM,E=change R,F=change S
        if([receiptProductItem.productType isEqualToString:@"C"]
        || [receiptProductItem.productType isEqualToString:@"B"]
        || [receiptProductItem.productType isEqualToString:@"P"]
        || [receiptProductItem.productType isEqualToString:@"D"]
        || [receiptProductItem.productType isEqualToString:@"S"]
        || [receiptProductItem.productType isEqualToString:@"R"]
        || [receiptProductItem.productType isEqualToString:@"E"]
        || [receiptProductItem.productType isEqualToString:@"F"]
        )
        {
            if(receiptProductItem.isPreOrder2)
            {
                UIColor *color = [UIColor colorWithRed:255/255.0 green:47/255.0 blue:146/255.0 alpha:1];
                [cell.btnProduct setTitleColor:color forState:UIControlStateNormal];
            }
            else
            {
                [cell.btnProduct setTitleColor:tBlueColor forState:UIControlStateNormal];
            }
        }
        else
        {
            [cell.btnProduct setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        
        
        
        cell.lblPrice.text = [Utility formatBaht:receiptProductItem.priceSales];
        
        return cell;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == tbvData)
    {
        if(_booShortOrDetail)
        {
            return 30;
        }
        else
        {
            CustomTableViewCellReceipt *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierReceipt];
            Receipt *receipt = _receiptListForDate[indexPath.section];
            cell.lblDiscountReason.text = receipt.discountReason;
            float discountReasonHeight = 17;
            
            
            NSArray *receiptProductItemList = [self getReceiptProductItemList:receipt.receiptID];
            NSString *strDiscountReason = @"";
            for(ReceiptProductItem *item in receiptProductItemList)
            {
                if([Utility isStringEmpty:strDiscountReason])
                {
                    strDiscountReason = [NSString stringWithFormat:@"%@",item.discountReason];
                }
                else
                {
                    strDiscountReason = [NSString stringWithFormat:@"%@,%@",strDiscountReason,item.discountReason];
                }
            }
            cell.lblDiscountReason.text = strDiscountReason;
            if(![Utility isStringEmpty:strDiscountReason])
            {
                [cell.lblDiscountReason sizeToFit];
                discountReasonHeight = cell.lblDiscountReason.frame.size.height;
            }
            
//            NSArray *receiptProductItemList = [self getReceiptProductItemList:receipt.receiptID];
            return 176+[receiptProductItemList count]*30 -17+discountReasonHeight;
        }
    }
    else if(tableView == customMadeView)
    {
        return 44;
    }
    else if(tableView == preOrderEventIDHistoryView)
    {
        return 44;
    }
    else
    {
        return 30;
    }
    return 44;
}

 -(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(tableView == tbvData)
    {
        if(_booShortOrDetail)
        {
            CustomTableViewCellReceiptShort *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierReceiptShort];
            CGRect frame = cell.frame;
            frame.size.width = tableView.frame.size.width;
            cell.frame = frame;
            
            
            cell.lblProduct.text = @"Item";
            cell.lblColor.text = @"Color";
            cell.lblSize.text = @"Size";
            cell.lblCash.text = @"Cash";
            cell.lblCredit.text = @"Credit";
            cell.lblTransfer.text = @"Transfer";
            cell.lblProduct.textColor = [UIColor whiteColor];
            cell.lblProduct.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
            cell.lblColor.textColor = [UIColor whiteColor];
            cell.lblColor.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
            cell.lblSize.textColor = [UIColor whiteColor];
            cell.lblSize.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
            cell.lblCash.textColor = [UIColor whiteColor];
            cell.lblCash.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
            cell.lblCredit.textColor = [UIColor whiteColor];
            cell.lblCredit.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
            cell.lblTransfer.textColor = [UIColor whiteColor];
            cell.lblTransfer.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
            
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
            [view addSubview:cell];
            [view setBackgroundColor:tBlueColor]; //your background color...
            return view;
        }
        else
        {
            if(section == 0)
            {
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
                [view setBackgroundColor:[UIColor systemGroupedBackgroundColor]]; //your background color...
                return view;
            }
        }
    }
    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if(tableView == tbvData)
    {
        if(!_booShortOrDetail)
        {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
            [view setBackgroundColor:[UIColor systemGroupedBackgroundColor]]; //your background color...
            return view;
        }
    }
    
    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    if(tableView == tbvData)
    {
        if(_booShortOrDetail)
        {
            return 30;
        }
        else
        {
            if(section == 0)
            {
                return 30;
            }
        }
    }
    return 0.01f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(tableView == tbvData)
    {
        if(!_booShortOrDetail)
        {
            return 30;
        }
    }
    return 0.01f;
}

-(void)showActionList:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger receiptProductItemID = button.tag;
    ReceiptProductItem *receiptProductItem = [self getReceiptProductItem:receiptProductItemID];
    
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                preferredStyle:UIAlertControllerStyleActionSheet];
           
    
    //I=Inventory,C=Custom made,A=change I,B=change C,P=preorder,D=change P,S=post preorder,R=post CM,E=change R,F=change S
    if([receiptProductItem.productType isEqualToString:@"I"]
    || [receiptProductItem.productType isEqualToString:@"C"]
    || [receiptProductItem.productType isEqualToString:@"P"]
    || [receiptProductItem.productType isEqualToString:@"S"]
    || [receiptProductItem.productType isEqualToString:@"R"]
    )
    {
        [alert addAction:
        [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Change Product"]
                                 style:UIAlertActionStyleDestructive
                               handler:^(UIAlertAction *action)
                               {
                                   [self changeProduct:receiptProductItemID];
                               }]];
    }
    
              
              
  //I=Inventory,C=Custom made,A=change I,B=change C,P=preorder,D=change P,S=post preorder,R=post CM,E=change R,F=change S
  if([receiptProductItem.productType isEqualToString:@"C"] && !receiptProductItem.isPreOrder2
  )
  {
      [alert addAction:
       [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Change CM Spec"]
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction *action)
      {
           [self editCustomMadeDetail:receiptProductItemID];
      }]];
  }
    
                    
  
  //I=Inventory,C=Custom made,A=change I,B=change C,P=preorder,D=change P,S=post preorder,R=post CM,E=change R,F=change S
  if([receiptProductItem.productType isEqualToString:@"P"]
  || [receiptProductItem.productType isEqualToString:@"D"]
  || [receiptProductItem.productType isEqualToString:@"S"]
  || [receiptProductItem.productType isEqualToString:@"F"]
  )
  {
        [alert addAction:
         [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Show pre-order route"]
                                                          style:UIAlertActionStyleDestructive
                                                        handler:^(UIAlertAction *action)
        {
            [self viewPreOrderHistory:receiptProductItemID];
        }]];
  }
   
   [alert addAction:
    [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Add/Edit Post"]
                                                     style:UIAlertActionStyleDestructive
                                                   handler:^(UIAlertAction *action)
   {
        NSMutableArray *receiptProductItemList = [[NSMutableArray alloc]init];
        [receiptProductItemList addObject:receiptProductItem];
        
       _selectedReceiptProductItemList = receiptProductItemList;
       ItemTrackingNo *itemTrackingNo = [self getItemTrackingNo:receiptProductItem.receiptProductItemID];
       _selectedPostCustomer = [self getPostCustomer:itemTrackingNo.postCustomerID];
       [self performSegueWithIdentifier:@"segPostCustomer" sender:self];
   }]];
   
                
                            
    [alert addAction:
     [UIAlertAction actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleCancel
                            handler:^(UIAlertAction *action) {}]];

    //////////////ipad
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        [alert setModalPresentationStyle:UIModalPresentationPopover];
        
        UIPopoverPresentationController *popPresenter = [alert
                                                         popoverPresentationController];
        CGRect frame = button.imageView.bounds;
        frame.origin.y = frame.origin.y-15;
        popPresenter.sourceView = button.imageView;
        popPresenter.sourceRect = frame;
    }
    ///////////////
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void) closePreOrderEventIDHistoryView:(id)sender
{
    [preOrderEventIDHistoryView removeFromSuperview];
    [_vwDimBackground removeFromSuperview];
}

- (void) saveCM:(id)sender
{
    if(![self customMadeChanged])
    {
        [customMadeView removeFromSuperview];
        [_vwDimBackground removeFromSuperview];
        return;
    }
    
    
    CustomMade *customMade = [[CustomMade alloc]init];
    customMade.customMadeID = _customMadeIDEdit;
    customMade.size = _txtCMSize.text;
    customMade.toe = _txtCMToe.text;
    customMade.body = _txtCMBody.text;
    customMade.accessory = _txtCMAccessory.text;
    customMade.remark = _txtCMRemark.text;
    customMade.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
    customMade.modifiedUser = [Utility modifiedUser];
    [self loadingOverlayView];
    [_homeModel updateItems:dbCustomMade withData:customMade];
    
}

-(void)cancelCM:(id)sender
{
    [customMadeView removeFromSuperview];
    [_vwDimBackground removeFromSuperview];
}

-(void)editCustomMadeDetail:(NSInteger)receiptProductItemID
{
    ReceiptProductItem *receiptProductItem = [self getReceiptProductItem:receiptProductItemID];
    
    CustomMade *customMade = [self getCustomMade:[receiptProductItem.productID integerValue]];
    _customMadeIDEdit = [receiptProductItem.productID integerValue];
    _txtCMSize.text = customMade.size;
    _txtCMToe.text = customMade.toe;
    _txtCMBody.text = customMade.body;
    _txtCMAccessory.text = customMade.accessory;
    _txtCMRemark.text = customMade.remark;
    [customMadeView reloadData];
    
    
    _customMadeInitial = [[CustomMade alloc]init];
    _customMadeInitial.size = customMade.size;
    _customMadeInitial.toe = customMade.toe;
    _customMadeInitial.body = customMade.body;
    _customMadeInitial.accessory = customMade.accessory;
    _customMadeInitial.remark = customMade.remark;
    
    {
        customMadeView.alpha = 0.0;
        [self.view addSubview:_vwDimBackground];
        [self.view addSubview:customMadeView];
        [UIView animateWithDuration:0.2 animations:^{
            customMadeView.alpha = 1.0;
        }];
    }
}

-(PostCustomer *)getPostCustomerFromReceiptID:(NSInteger)receiptID
{
    NSArray *receiptProductItemList = [self getReceiptProductItemList:receiptID];
    for(ReceiptProductItem *item in receiptProductItemList)
    {
        ItemTrackingNo *itemTrackingNo = [self getItemTrackingNo:item.receiptProductItemID];
        if(itemTrackingNo.postCustomerID > 0)
        {
            PostCustomer *postCustomer = [self getPostCustomer:itemTrackingNo.postCustomerID];
            return postCustomer;
        }
    }
    
    return nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segPostCustomer"])
    {
        AddEditPostCustomerViewController *vc = segue.destinationViewController;
        vc.paid = YES;
        vc.telephoneNoSearch = _selectedPostCustomer?_selectedPostCustomer.telephone:@"";
        vc.receiptProductItemList = _selectedReceiptProductItemList;
        vc.selectedPostCustomer = _selectedPostCustomer;
    }
    else if([[segue identifier] isEqualToString:@"segExpenseDaily"])
    {
        NSInteger eventID = [SharedSelectedEvent sharedSelectedEvent].event.eventID;
        
        ExpenseDailyViewController *vc = segue.destinationViewController;
        vc.inputDate = _strSelectedDateDB;
        vc.eventID = eventID;
    }
    
}

- (float)totalDiscount
{
    float totalDiscount = 0;
    for(Receipt *item in _receiptList)
    {
        if(![item.payPrice isEqualToString:@"0"])
        {
            if([item.discount isEqualToString:@"1"])
            {
                totalDiscount += [item.discountValue floatValue];
            }
            else if([item.discount isEqualToString:@"2"])
            {
                totalDiscount += ([item.payPrice floatValue] - [item.shippingFee floatValue])/(100-[item.discountPercent floatValue])*[item.discountPercent floatValue];
            }
        }
        
    }
    return totalDiscount;
}

- (float)totalCredit
{
    float totalCredit = 0;
    for(Receipt *item in _receiptList)
    {
        totalCredit += [item.creditAmount floatValue];
    }
    return totalCredit;
}

- (float)totalCash
{
    float totalCash = 0;
    for(Receipt *item in _receiptList)
    {
//        if([item.paymentMethod isEqualToString:@"CA"] || [item.paymentMethod isEqualToString:@"BO"])
        {
            totalCash += [item.cashAmount floatValue];
        }
    }
    return totalCash;
}

- (float)totalTransfer
{
    float totalTransfer = 0;
    for(Receipt *item in _receiptList)
    {
//        if([item.paymentMethod isEqualToString:@"CA"] || [item.paymentMethod isEqualToString:@"BO"])
        {
            totalTransfer += [item.transferAmount floatValue];
        }
    }
    return totalTransfer;
}

- (float)totalAmount
{
    float totalAmount = 0;
    for(Receipt *item in _receiptList)
    {
        totalAmount += [item.payPrice floatValue];
    }
    return totalAmount;
}

- (float)cashAndChanges
{
    return [self totalCash]+[self initialChanges]-[self deposit];
}

- (NSString *)salesPerChange
{
    NSInteger salesNum = 0;
    NSInteger changeNum = 0;
    NSInteger upProductNum = 0;
    for(ReceiptProductItem *item in _receiptProductItemListForDate)
    {
        if(item.replaceProduct)
        {
            float discountValue = 0;
            if(item.discount == 1)
            {
                discountValue = item.discountValue;
            }
            else if(item.discount == 2)
            {
                discountValue = roundf(item.discountPercent * [Utility floatValue:item.priceSales]/100*100)/100;
            }
            
            
            if(discountValue == [Utility floatValue:item.priceSales])
            {
                changeNum += 1;
            }
            else
            {
                upProductNum +=1;
            }
        }
        else
        {
            salesNum += 1;
        }
    }
    return [NSString stringWithFormat:@"%ld/%ld/%ld",salesNum,changeNum,upProductNum];
}

- (float)initialChanges
{
    NSInteger eventID = [SharedSelectedEvent sharedSelectedEvent].event.eventID;
    NSString *strEventID = [NSString stringWithFormat:@"%ld",eventID];
    NSMutableArray *cashAllocationList = _cashAllocationListForDate;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_eventID = %@ and (_inputDate = %@ or _inputDate = %@)",strEventID,_selectedDateTime,_strSelectedDateDB];
    NSArray *filterArray = [cashAllocationList filteredArrayUsingPredicate:predicate1];
    if([filterArray count]==0)
    {
        return 0;
    }
    CashAllocation *cashAllocation = filterArray[0];
    return [cashAllocation.cashChanges floatValue];
}

- (float)deposit
{
    NSInteger eventID = [SharedSelectedEvent sharedSelectedEvent].event.eventID;
    NSString *strEventID = [NSString stringWithFormat:@"%ld",eventID];
    NSMutableArray *cashAllocationList = _cashAllocationListForDate;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_eventID = %@ and (_inputDate = %@ or _inputDate = %@)",strEventID,_selectedDateTime,_strSelectedDateDB];
    NSArray *filterArray = [cashAllocationList filteredArrayUsingPredicate:predicate1];
    if([filterArray count]==0)
    {
        return 0;
    }
    CashAllocation *cashAllocation = filterArray[0];
    return [cashAllocation.cashTransfer floatValue];
}

- (float)expense
{
    float sumExpense = 0;
    for(ExpenseDaily *item in _expenseDailyListForDate)
    {
        sumExpense += [item.amount floatValue];
    }
    return sumExpense;
}

- (float)changesAfterTransfer
{
    float changesAfterTransfer = [self cashAndChanges]-[self deposit];
    return changesAfterTransfer;
}

- (void)itemsInserted
{
    
}

-(void)itemsUpdated
{

}
-(void)itemsUpdatedWithReturnData:(NSArray *)data
{
    if(_homeModel.propCurrentDB == dbCashAllocationByEventIDAndInputDate)
    {
        [self removeOverlayViews];
        _cashAllocationListForDate = data[0];
        self.txtInitialChanges.text = [_formatter stringFromNumber:[NSNumber numberWithFloat:[self initialChanges]]];
        self.txtDeposit.text = [_formatter stringFromNumber:[NSNumber numberWithFloat:[self deposit]]];
        self.lblCashAndChanges.text = [_formatter stringFromNumber:[NSNumber numberWithFloat:[self cashAndChanges]]];
    }
    else if(_homeModel.propCurrentDB == dbReceipt)
    {
        [self removeOverlayViews];
        NSArray *receiptList = data[0];
        Receipt *dbReceipt = receiptList[0];
        Receipt *receipt = [self getReceipt:dbReceipt.receiptID];
        receipt.remark = dbReceipt.remark;
        [tbvData reloadData];
    }
    else if(_homeModel.propCurrentDB == dbCustomMade)
    {
        [self removeOverlayViews];
        [customMadeView removeFromSuperview];
        [_vwDimBackground removeFromSuperview];
            
        NSArray *customMadeList = data[0];
        CustomMade *dbCustomMade = customMadeList[0];
        CustomMade *customMade = [self getCustomMade:dbCustomMade.customMadeID];
        customMade.customMadeID = dbCustomMade.customMadeID;
        customMade.size = dbCustomMade.size;
        customMade.toe = dbCustomMade.toe;
        customMade.body = dbCustomMade.body;
        customMade.accessory = dbCustomMade.accessory;
        customMade.remark = dbCustomMade.remark;

    }
    else if(_homeModel.propCurrentDB == dbReceiptProductItemAndProductUpdate)
    {
        [self removeOverlayViews];
        NSMutableArray *returnProductList = data[0];
        NSMutableArray *returnCustomMadeList = data[1];
        NSMutableArray *returnReceiptProductItemList = data[2];
        NSArray *messageList = data[3];
        InAppMessage *message = messageList[0];
        if([returnProductList count]>0)
        {
            Product *returnProduct = returnProductList[0];
            Product *updateProduct = [self getProduct:returnProduct.productID];
            updateProduct.status = returnProduct.status;
        }
        if([returnCustomMadeList count] > 0)
        {
            CustomMade *returnCustomMade = returnCustomMadeList[0];
            CustomMade *updateCustomMade = [self getCustomMade:returnCustomMade.customMadeID];
            updateCustomMade.productIDPost = @"";
        }
        ReceiptProductItem *returnReceiptProductItem = returnReceiptProductItemList[0];
        ReceiptProductItem *updateReceiptProductItem = [self getReceiptProductItem:returnReceiptProductItem.receiptProductItemID];
        updateReceiptProductItem.productType = returnReceiptProductItem.productType;
        updateReceiptProductItem.productID = returnReceiptProductItem.productID;
        [self setData];
        
                
        if(![Utility isStringEmpty:message.message])
        {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                   message:message.message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      
                                                                  }];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    else if(_homeModel.propCurrentDB == dbReceiptReferenceOrderNo)
    {
        [self removeOverlayViews];
        [_txtReferenceOrderNo removeFromSuperview];
        [_vwDimBackground removeFromSuperview];
        
        
        NSArray *receiptList = data[0];
        Receipt *dbReceipt = receiptList[0];
        Receipt *receipt = [self getReceipt:dbReceipt.receiptID];
        receipt.referenceOrderNo = dbReceipt.referenceOrderNo;
        [tbvData reloadData];
    }
}

- (IBAction)expenseButtonClicked:(id)sender
{
    [self performSegueWithIdentifier:@"segExpenseDaily" sender:self];
}

- (IBAction)changeDate:(id)sender {
    if([btnChangeDate.titleLabel.text isEqualToString:@"Choose date"])
    {
        [sender setTitle:@"OK" forState:UIControlStateNormal];
        [dtPicker setHidden:NO];
        [dtPicker setDate:[Utility stringToDate:lblDate.text fromFormat:@"dd/MM/yyyy"]];
        dtPicker.backgroundColor = [UIColor lightGrayColor];
        _segmentControl.layer.zPosition = 1;
    }
    else if([btnChangeDate.titleLabel.text isEqualToString:@"OK"])
    {
        [sender setTitle:@"Choose date" forState:UIControlStateNormal];
        [dtPicker setHidden:YES];
        [self changeSegmentControlData:[Utility stringToDate:lblDate.text fromFormat:@"dd/MM/yyyy"]];
    }
    
}

- (IBAction)datePickerChanged:(id)sender {
    NSString *strSelectedDateDisplay = [Utility dateToString:dtPicker.date toFormat:[Utility setting:vFormatDateDisplay]];
    lblDate.text = [NSString stringWithFormat:@"%@",strSelectedDateDisplay];
    lblDate.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
}

- (IBAction)shortOrDetail:(id)sender {
    
    [customMadeView removeFromSuperview];
    [preOrderEventIDHistoryView removeFromSuperview];
    [_txtReferenceOrderNo removeFromSuperview];
    [_vwDimBackground removeFromSuperview];
    
    if([btnShortOrDetail.title isEqualToString:@"Detail"])
    {
        btnShortOrDetail.title = @"Short";
        _booShortOrDetail = NO;
    }
    else if([btnShortOrDetail.title isEqualToString:@"Short"])
    {
        btnShortOrDetail.title = @"Detail";
        _booShortOrDetail = YES;
    }
    
    [tbvData reloadData];
}

- (UIImage *)renderMark
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
    UIGraphicsBeginImageContextWithOptions(kMarkImageSize, NO, [UIScreen mainScreen].scale);
    else
    UIGraphicsBeginImageContext(kMarkImageSize);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIBezierPath *markCircle = [UIBezierPath bezierPathWithOvalInRect:kCircleRect];
    
    /* Background */
    CGContextSaveGState(ctx);
    {
        CGContextAddPath(ctx, markCircle.CGPath);
        CGContextSetFillColorWithColor(ctx, clearColorWithRGBHex(kMarkColor).CGColor);
        CGContextSetShadowWithColor(ctx, kShadowOffset, kShadowRadius, kShadowColor.CGColor );
        CGContextDrawPath(ctx, kCGPathFill);
    }
    CGContextRestoreGState(ctx);
    
    /* Overlay */
    CGContextSaveGState(ctx);
    {
        CGContextAddPath(ctx, markCircle.CGPath);
        CGContextClip(ctx);
        CGContextAddEllipseInRect(ctx, kCircleOverlayRect);
        CGContextSetFillColorWithColor(ctx, colorWithRGBHex(kMarkColor).CGColor);
        CGContextDrawPath(ctx, kCGPathFill);
    }
    CGContextRestoreGState(ctx);
    
    /* Stroke */
    CGContextSaveGState(ctx);
    {
        CGContextAddPath(ctx, markCircle.CGPath);
        CGContextSetLineWidth(ctx, kStrokeWidth);
        CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
        CGContextDrawPath(ctx, kCGPathStroke);
    }
    CGContextRestoreGState(ctx);
    
    /* Mark */
    CGContextSaveGState(ctx);
    {
        CGContextSetShadowWithColor(ctx, kMarkShadowOffset, .0, kMarkShadowColor.CGColor );
        CGContextMoveToPoint(ctx, kMarkBase.x, kMarkBase.y);
        //        CGContextAddLineToPoint(ctx, kMarkBase.x + kMarkHeight * sin(kMarkDegrees), kMarkBase.y + kMarkHeight * cos(kMarkDegrees));
        //        CGContextAddLineToPoint(ctx, kMarkDrawPoint.x, kMarkDrawPoint.y);
        CGContextAddLineToPoint(ctx, kMarkDrawPoint.x, kMarkBase.y);
        CGContextSetLineWidth(ctx, kMarkWidth);
        CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
        CGContextStrokePath(ctx);
    }
    CGContextRestoreGState(ctx);
    
    UIImage *selectedMark = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return selectedMark;
}

-(void) loadingOverlayView
{
    [indicator startAnimating];
    indicator.layer.zPosition = 1;
    indicator.alpha = 1;
    overlayView.alpha = 1;
    
    
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

- (void)itemsFail
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[Utility getConnectionLostTitle]
                                                                   message:[Utility getConnectionLostMessage]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
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
                                                          }];
    
    [alert addAction:defaultAction];
    dispatch_async(dispatch_get_main_queue(),^ {
        [self presentViewController:alert animated:YES completion:nil];
    } );
}

- (Product *)getProduct:(NSString *)productID
{
    NSMutableArray *productList = _productListForDate;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productID = %@",productID];
    NSArray *filterArray = [productList filteredArrayUsingPredicate:predicate1];
    if([filterArray count]>0)
    {
        return filterArray[0];
    }
    
    return nil;
}

- (CustomMade *)getCustomMade:(NSInteger)customMadeID
{
    NSMutableArray *customMadeList = _customMadeListForDate;
    for(CustomMade *item in customMadeList)
    {
        if(item.customMadeID == customMadeID)
        {
            return item;
        }
    }
    return nil;
}

- (CustomMade *)getCustomMadeFromProductIDPost:(NSString *)productIDPost
{
    NSMutableArray *customMadeList = _customMadeListForDate;//[SharedCustomMade sharedCustomMade].customMadeList;
    for(CustomMade *item in customMadeList)
    {
        if([item.productIDPost isEqualToString:productIDPost])
        {
            return item;
        }
    }
    return nil;
}

- (Receipt *)getReceipt:(NSInteger)receiptID
{
    NSMutableArray *receiptList = _receiptListForDate;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_receiptID = %ld",receiptID];
    NSArray *filterArray = [receiptList filteredArrayUsingPredicate:predicate1];
    
    if([filterArray count] > 0)
    {
        return filterArray[0];
    }
    return nil;
}
//
//- (NSInteger) getPostCustomerID:(NSInteger)receiptID
//{
//    NSMutableArray *customerReceiptList = _customerReceiptListForDate;
//    for(CustomerReceipt *item in customerReceiptList)
//    {
//        if(item.receiptID == receiptID)
//        {
//            return item.postCustomerID;
//        }
//    }
//    return 0;
//}

- (PostCustomer *) getPostCustomer:(NSInteger)postCustomerID
{
    NSMutableArray *postCustomerList = _postCustomerListForDate;
    for(PostCustomer *item in postCustomerList)
    {
        if(item.postCustomerID == postCustomerID)
        {
            return item;
        }
    }
    return nil;
}

-(NSMutableArray *)getHistoryWithReceiptProductItemID:(NSInteger)receiptProductItemID
{
    NSMutableArray *preOrderEventIDHistoryList = _preOrderEventIDHistoryListForDate;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_receiptProductItemID = %ld",receiptProductItemID];
    NSArray *filterArray = [preOrderEventIDHistoryList filteredArrayUsingPredicate:predicate1];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_preOrderEventIDHistoryID" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortArray = [filterArray sortedArrayUsingDescriptors:sortDescriptors];
    
    return [sortArray mutableCopy];
}

-(ReceiptProductItem *)getReceiptProductItem:(NSInteger)receiptProductItemID
{
    NSMutableArray *receiptProductItemList = _receiptProductItemListForDate;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_receiptProductItemID = %ld",receiptProductItemID];
    NSArray *filterArray = [receiptProductItemList filteredArrayUsingPredicate:predicate1];
    
    if([filterArray count]>0)
    {
        return filterArray[0];
    }
    return nil;
}

- (NSArray *)getReceiptProductItemList:(NSInteger)receiptID
{
    NSMutableArray *receiptProductItemList = _receiptProductItemListForDate;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_receiptID = %ld",receiptID];
    NSArray *filterArray  = [receiptProductItemList filteredArrayUsingPredicate:predicate1];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_receiptProductItemID" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortArray = [filterArray sortedArrayUsingDescriptors:sortDescriptors];
    
    return sortArray;
}

- (ItemTrackingNo *)getItemTrackingNo:(NSInteger)receiptProductItemID
{
    NSMutableArray *itemTrackingNoList = _itemTrackingNoListForDate;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_receiptProductItemID = %ld",receiptProductItemID];
    NSArray *filterArray  = [itemTrackingNoList filteredArrayUsingPredicate:predicate1];
    
    return filterArray[0];
}

- (NSArray *)getItemTrackingNoList:(NSInteger)receiptID
{
    NSMutableArray *itemTrackingNoList = [[NSMutableArray alloc]init];
    NSArray *receiptProductItemList = [self getReceiptProductItemList:receiptID];
    for(ReceiptProductItem *item in receiptProductItemList)
    {
        ItemTrackingNo *itemTrackingNo = [self getItemTrackingNo:item.receiptProductItemID];
        [itemTrackingNoList addObject:itemTrackingNo];
    }
    
    return itemTrackingNoList;
}

- (NSArray *)getCustomMadeList:(NSArray *)receiptProductItemList
{
    NSMutableArray *customMadeList = [[NSMutableArray alloc]init];
    for(ReceiptProductItem *item in receiptProductItemList)
    {
        if([item.productType isEqualToString:@"C"] || [item.productType isEqualToString:@"B"] || [item.productType isEqualToString:@"E"])
        {
            CustomMade *customMade = [self getCustomMade:[item.productID integerValue]];
            if(customMade)
            {
                [customMadeList addObject:customMade];
            }
        }
        else if([item.productType isEqualToString:@"R"])
        {
            CustomMade *customMade = [self getCustomMadeFromProductIDPost:item.productID];
            if(customMade)
            {
                [customMadeList addObject:customMade];
            }
        }
    }
    return customMadeList;
}

- (NSArray *)getProductList:(NSArray *)receiptProductItemList
{
    NSMutableArray *productList = [[NSMutableArray alloc]init];
    for(ReceiptProductItem *item in receiptProductItemList)
    {
        if([item.productType isEqualToString:@"I"] || [item.productType isEqualToString:@"P"] || [item.productType isEqualToString:@"S"] || [item.productType isEqualToString:@"R"])
        {
            Product *product = [self getProduct:item.productID];
            if(product)
            {
                [productList addObject:product];
            }
        }
    }
    return productList;
}

@end
