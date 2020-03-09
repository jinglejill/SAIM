//
//  ReceiptSummaryViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/3/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "ReceiptSummaryViewController.h"
#import "AccountReceiptPDFViewController.h"
#import "Utility.h"
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
#import "SharedCashAllocation.h"
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

//
//
//
//#import "CustomPrintPageRenderer.h"
//#import "InvoiceComposer.h"
//#import "AccountReceipt.h"
//#import "AccountReceiptProductItem.h"
//#import "AccountInventorySummary.h"
//#import "AccountInventory.h"
//#import "AccountMapping.h"


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


@interface ReceiptSummaryViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    UIActivityIndicatorView *indicator2;
    Event *_event;
    NSString *_strEventID;
    NSMutableArray *_salesSummaryList;
    NSArray *_cashAllocationList;
    CashAllocation *_cashAllocation;
    NSNumberFormatter *_formatter;
    BOOL _booChangesOrTransfer; //yes = changes, no = transfer
    UILabel *_lblTotalCredit;
    UILabel *_lblTotalCash;
    UILabel *_lblTotalAmount;
    UILabel *_lblFrontTotalCredit;
    UILabel *_lblFrontTotalCash;
    UILabel *_lblFrontTotalAmount;
    UIButton *_btnInitialChanges;
    UIButton *_btnTransfer;
    UILabel *_lblCashAndChanges;
    
    UILabel *_lblFrontInitialChanges;
    UILabel *_lblFrontTransfer;
    UILabel *_lblFrontCashAndChanges;
    
    
    UIButton *_btnAfterTransfer;
    NSString *_selectedReceiptProductItemID;
    NSInteger _selectedIndexPathForRow;
    NSString *_strSelectedDateDB;
    UITextView *_txvDetail;
    UISegmentedControl *_segmentControl;
    NSArray *_receiptList;
    NSArray *_receiptProductItemList;
    NSMutableArray *_arrCellSize;
    NSMutableArray *_arrCellData;
    NSMutableArray *_arrCellType;
    NSMutableArray *_arrCellBorder;
    NSMutableArray *_arrCellReceiptID;
    NSMutableArray *_arrCellReceiptProductItemIndex;
    NSMutableArray *_arrCellProductType;
    NSDate *_selectedDateTime;
    NSDate *_selectedDateTimeEndOfDay;
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
    NSInteger _customMadeIDEdit;
    CustomMade *_customMadeInitial;
    BOOL _booShortOrDetail;
    
    UITextField *_txtChanges;
    UITextField *_txtTransfer;
    CashAllocation *_cashAllocationInitial;
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
    NSMutableArray *_customerReceiptListForDate;
    NSMutableArray *_postCustomerListForDate;
    NSMutableArray *_preOrderEventIDHistoryListForDate;
    Receipt *_receiptRemark;
}

@property (nonatomic,strong) UIRefreshControl   *refreshControl;
@end


static NSString * const reuseIdentifier = @"Cell";
static NSString * const reuseHeaderViewIdentifier = @"HeaderView";
static NSString * const reuseFooterViewIdentifier = @"FooterView";
@implementation ReceiptSummaryViewController
@synthesize colViewSummaryTable;
@synthesize lblLocation;
@synthesize lblDate;
@synthesize btnChangeDate;
@synthesize dtPicker;
@synthesize customMadeView;
@synthesize btnShortOrDetail;
@synthesize cashAllocationView;
@synthesize preOrderEventIDHistoryView;
@synthesize titleAndCloseButtonView;


- (IBAction)unwindToReceiptSummary:(UIStoryboardSegue *)segue
{
    AddEditPostCustomerViewController *vc = segue.sourceViewController;
    [_postCustomerListForDate addObject: vc.selectedPostCustomer];
    [self setData];
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
    
    _lblTotalCredit = [[UILabel alloc]init];
    _lblTotalCash = [[UILabel alloc]init];
    _lblTotalAmount = [[UILabel alloc]init];
    _lblFrontTotalCredit = [[UILabel alloc]init];
    _lblFrontTotalCash = [[UILabel alloc]init];
    _lblFrontTotalAmount = [[UILabel alloc]init];
    
    _btnInitialChanges = [[UIButton alloc]init];
    _btnTransfer = [[UIButton alloc]init];
    _lblCashAndChanges = [[UILabel alloc]init];
    _lblFrontInitialChanges = [[UILabel alloc]init];
    _lblFrontTransfer = [[UILabel alloc]init];
    _lblFrontCashAndChanges = [[UILabel alloc]init];
    
    
    _txvDetail = [[UITextView alloc]init];
    
    
    //subview of headerview
    //align right
    _lblTotalCredit.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
    _lblTotalCredit.textColor = [UIColor blackColor];
    _lblTotalCredit.textAlignment = NSTextAlignmentRight;
    
    
    _lblTotalCash.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
    _lblTotalCash.textColor = [UIColor blackColor];
    _lblTotalCash.textAlignment = NSTextAlignmentRight;
    
    
    _lblTotalAmount.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
    _lblTotalAmount.textColor = [UIColor blackColor];
    _lblTotalAmount.textAlignment = NSTextAlignmentRight;
    
    
    
    _lblFrontTotalCredit.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    _lblFrontTotalCredit.textColor = [UIColor blackColor];
    _lblFrontTotalCredit.textAlignment = NSTextAlignmentLeft;
    
    
    _lblFrontTotalCash.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    _lblFrontTotalCash.textColor = [UIColor blackColor];
    _lblFrontTotalCash.textAlignment = NSTextAlignmentLeft;
    
    
    _lblFrontTotalAmount.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    _lblFrontTotalAmount.textColor = [UIColor blackColor];
    _lblFrontTotalAmount.textAlignment = NSTextAlignmentLeft;
    
    
    //align left
    CGFloat yPosition = 0;
    float widthSubview = self.view.bounds.size.width;
    
    
    [_btnInitialChanges addTarget:self action:@selector(setInitialChanges:) forControlEvents:UIControlEventTouchUpInside];
    [_btnInitialChanges setTitle:@"Initial changes: " forState:UIControlStateNormal];
    [_btnInitialChanges setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _btnInitialChanges.titleLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
    
    
    [_btnTransfer addTarget:self action:@selector(setTransfer:) forControlEvents:UIControlEventTouchUpInside];
    [_btnTransfer setTitle:@"Transfer: " forState:UIControlStateNormal];
    [_btnTransfer setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _btnTransfer.titleLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
    
    
    _lblCashAndChanges.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
    _lblCashAndChanges.textColor = [UIColor blackColor];
    _lblCashAndChanges.textAlignment = NSTextAlignmentRight;
    
    
    _lblFrontInitialChanges.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    _lblFrontInitialChanges.textColor = [UIColor blackColor];
    _lblFrontInitialChanges.textAlignment = NSTextAlignmentLeft;
    _lblFrontInitialChanges.frame = CGRectMake(0, yPosition+20, widthSubview, 20);
    
    
    _lblFrontTransfer.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    _lblFrontTransfer.textColor = [UIColor blackColor];
    _lblFrontTransfer.textAlignment = NSTextAlignmentLeft;
    _lblFrontTransfer.frame = CGRectMake(0, yPosition+40, widthSubview, 20);
    
    
    _lblFrontCashAndChanges.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    _lblFrontCashAndChanges.textColor = [UIColor blackColor];
    _lblFrontCashAndChanges.textAlignment = NSTextAlignmentLeft;
    _lblFrontCashAndChanges.frame = CGRectMake(0, yPosition+60, widthSubview, 20);
    
    
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
        widthSegCon = maximumSize;//numAvailableShowDate*sizeOfEachSegment;
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

-(void)setInitialChanges:(id)sender
{
    NSInteger eventID = [SharedSelectedEvent sharedSelectedEvent].event.eventID;
    [self editCashAllocationEventID:eventID inputDate:_strSelectedDateDB];
}

-(void)setTransfer:(id)sender
{
    NSInteger eventID = [SharedSelectedEvent sharedSelectedEvent].event.eventID;
    [self editCashAllocationEventID:eventID inputDate:_strSelectedDateDB];
}

-(void)segmentedControlValueDidChange:(UISegmentedControl *)segment
{
    [_txvDetail removeFromSuperview];
    [customMadeView removeFromSuperview];
    [cashAllocationView removeFromSuperview];
    [preOrderEventIDHistoryView removeFromSuperview];
    
    
    _selectedDateTime = (NSDate*)(_dateRange[segment.selectedSegmentIndex]);
    _selectedDateTimeEndOfDay = [_selectedDateTime dateByAddingTimeInterval:60*60*24*1-1];
    NSString *strSelectedDateDisplay = [Utility dateToString:_selectedDateTime toFormat:[Utility setting:vFormatDateDisplay]];
    _strSelectedDateDB = [Utility dateToString:_selectedDateTime toFormat:[Utility setting:vFormatDateDB]];
    
    
    //display
    lblDate.text = [NSString stringWithFormat:@"%@",strSelectedDateDisplay];
    lblDate.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    
    
    NSMutableArray *cashAllocationList = [SharedCashAllocation sharedCashAllocation].cashAllocationList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_eventID = %@ and _inputDate = %@", _strEventID,_strSelectedDateDB];
    NSArray *filterArray = [cashAllocationList filteredArrayUsingPredicate:predicate1];
    if([filterArray count] == 0)
    {
        CashAllocation *cashAllocation = [[CashAllocation alloc]init];
        cashAllocation.cashAllocationID = [Utility getNextID:tblCashAllocation];
        cashAllocation.eventID = _strEventID;
        cashAllocation.inputDate = _strSelectedDateDB;
        cashAllocation.cashChanges = @"0";
        cashAllocation.cashTransfer = @"0";
        cashAllocation.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
        cashAllocation.modifiedUser = [Utility modifiedUser];
        
        [_homeModel insertItems:dbCashAllocationByEventIDAndInputDate withData:cashAllocation];
        
        //update shared
        [cashAllocationList addObject:cashAllocation];
    }
    
    
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
    NSMutableArray *receiptList = _receiptListForDate;
    NSMutableArray *receiptProductItemList = _receiptProductItemListForDate;
    
    
    for(Receipt *item in receiptList)
    {
        item.dtReceiptDate = [Utility stringToDate:item.receiptDate fromFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    {
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_eventID = %@ and _dtReceiptDate BETWEEN %@",_strEventID,[NSArray arrayWithObjects:_selectedDateTime, _selectedDateTimeEndOfDay, nil]];
        _receiptList = [receiptList filteredArrayUsingPredicate:predicate1];
    }
    
    
    
    NSArray *receiptProductItemFilter;
    NSMutableArray *receiptProductItemTemp = [[NSMutableArray alloc]init];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_receiptID" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    _receiptList = [_receiptList sortedArrayUsingDescriptors:sortDescriptors];
    
    for(Receipt *item in _receiptList)
    {
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_receiptID = %ld", item.receiptID];
        receiptProductItemFilter = [receiptProductItemList filteredArrayUsingPredicate:predicate1];
        
        if([receiptProductItemFilter count] == 1)
        {
            ReceiptProductItem *receiptProductItemCountInReceipt = (ReceiptProductItem *)receiptProductItemFilter[0];
            receiptProductItemCountInReceipt.countInReceipt = 1;
        }
        else if ([receiptProductItemFilter count] > 1)
        {
            for(ReceiptProductItem *receiptProductItemCountInReceipt in receiptProductItemFilter)
            {
                receiptProductItemCountInReceipt.countInReceipt = [receiptProductItemFilter count];
            }
        }
        [receiptProductItemTemp addObjectsFromArray:receiptProductItemFilter];
    }
    _receiptProductItemList = receiptProductItemTemp;
    
    for(ReceiptProductItem *item in _receiptProductItemList)
    {
        if([item.productType isEqualToString:@"I"] || [item.productType isEqualToString:@"A"] || [item.productType isEqualToString:@"P"] || [item.productType isEqualToString:@"D"] || [item.productType isEqualToString:@"S"] || [item.productType isEqualToString:@"F"] || [item.productType isEqualToString:@"U"])
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
    
    [colViewSummaryTable reloadData];
}

-(void)itemsDownloaded:(NSArray *)items
{
    [self removeOverlayViews];
    
//    if(_homeModel.propCurrentDB == dbMaster)
//    {
//        PushSync *pushSync = [[PushSync alloc]init];
//        pushSync.deviceToken = [Utility deviceToken];
//        [_homeModel updateItems:dbPushSyncUpdateByDeviceToken withData:pushSync];
//
//
//        [Utility itemsDownloaded:items];
//        [self loadViewProcess];
//    }
    if(_homeModel.propCurrentDB == dbSalesForDate)
    {
//        [self removeOverlayViews];
        int i=0;
        
        _receiptListForDate = items[i++];
        _receiptProductItemListForDate = items[i++];
        _productListForDate = items[i++];
        _customMadeListForDate = items[i++];
        _customerReceiptListForDate = items[i++];
        _postCustomerListForDate = items[i++];
        _preOrderEventIDHistoryListForDate = items[i++];
        
        [self setData];
    }
    else if(_homeModel.propCurrentDB == dbAccountReceipt)
    {
        NSMutableArray *accountReceiptList = items[0];
        
        
        NSInteger alreadyGenReceipt = [accountReceiptList count]>0;
        if(alreadyGenReceipt)
        {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                           message:@"Tax invoice has already generated"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      
                                                                  }];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        else
        {
            
            Receipt *receipt = _selectedPrintReceipt;
            NSMutableArray *receiptProductItemList = [[self getReceiptProductItemList:receipt.receiptID] mutableCopy];
            _accountInventorySummaryList = [[NSMutableArray alloc]init];
            _salesProductAndPriceBillingsOnlyList = [[NSMutableArray alloc]init];
            for(ReceiptProductItem *item in receiptProductItemList)
            {
                Product *product = [self getProduct:item.productID];
                ProductName *productName = [ProductName getProductNameWithProduct:product];
                CustomerReceipt *customerReceipt = [self getCustomerReceiptWithReceiptID:receipt.receiptID];
                PostCustomer *postCustomer = [self getPostCustomer:customerReceipt.postCustomerID];
                
                
                
                //SalesProductAndPrice
                SalesProductAndPrice *salesProductAndPrice = [[SalesProductAndPrice alloc]init];
                salesProductAndPrice.productNameID = (int)(productName.productNameID);
                salesProductAndPrice.productName = productName.name;
                salesProductAndPrice.priceSales = [item.priceSales floatValue];
                salesProductAndPrice.billings = 1;
                salesProductAndPrice.receiptID = (int)(receipt.receiptID);
                salesProductAndPrice.receiptDiscount = [Utility floatValue:receipt.discountValue];
                salesProductAndPrice.receiptProductItemID = (int)(item.receiptProductItemID);
                salesProductAndPrice.receiptDate = receipt.receiptDate;
                salesProductAndPrice.taxCustomerName = postCustomer.taxCustomerName;
                [_salesProductAndPriceBillingsOnlyList addObject:salesProductAndPrice];
                
                
                
                
                
                //AccountInventorySummary
                AccountInventorySummary *accountInventorySummary = [[AccountInventorySummary alloc]init];
                accountInventorySummary.productNameID = (int)(productName.productNameID);
                accountInventorySummary.quantity = 1;
                accountInventorySummary.billings = 1;
                [_accountInventorySummaryList addObject:accountInventorySummary];
            }
            
            
            
            _dateOut = [Utility formatDate:receipt.receiptDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd"];
            [self performSegueWithIdentifier:@"segAccountReceiptPDF" sender:self];
        }
    }
    
}

-(void)prepareDataForCollectionView
{
    //run no.
    NSInteger runningNo = 0;
    NSInteger runningNo2 = [_receiptProductItemList count];
    NSString *previousReceiptID = @"";
    for(ReceiptProductItem *item in _receiptProductItemList)
    {
        if(!(item.receiptID == [previousReceiptID integerValue]))
        {
            runningNo = 0;
            previousReceiptID = [NSString stringWithFormat:@"%ld",item.receiptID];
        }
        runningNo = runningNo+1;
        item.row = [NSString stringWithFormat:@"%ld",runningNo];
    }
    
    
    //สำหรับ summary แบบ short
    NSInteger statusPaymentMethod = 0; //0=cash,1=credit
    float cashRemain = 0;
    float creditRemain = 0;
    for(ReceiptProductItem *item in _receiptProductItemList)
    {
        item.row2 = [NSString stringWithFormat:@"%ld",runningNo2--];
        
        
        Receipt *receipt = [self getReceipt:item.receiptID];
        if([item.row integerValue] == 1)
        {
            cashRemain = [receipt.cashAmount floatValue];
            statusPaymentMethod = 0;
            creditRemain = [receipt.creditAmount floatValue];
        }
        
        
        if(item.countInReceipt == 1)
        {
            item.cash = [receipt.cashAmount floatValue];
            item.credit = [receipt.creditAmount floatValue];
        }
        else if(item.countInReceipt > 1 && [receipt.discount floatValue] == 0)
        {
            if([receipt.paymentMethod isEqualToString:@"CA"])
            {
                item.cash = [item.priceSales floatValue];
                item.credit = 0;
            }
            else if([receipt.paymentMethod isEqualToString:@"CC"])
            {
                item.cash = 0;
                item.credit = [item.priceSales floatValue];
            }
            else if([receipt.paymentMethod isEqualToString:@"BO"])
            {
                if(statusPaymentMethod == 0 && cashRemain >= [item.priceSales floatValue])
                {
                    item.cash = [item.priceSales floatValue];
                    item.credit = 0;
                    cashRemain -= item.cash;
                    if(cashRemain == 0)
                    {
                        statusPaymentMethod = 1;
                    }
                }
                else if(statusPaymentMethod == 0 && cashRemain < [item.priceSales floatValue])
                {
                    item.cash = cashRemain;
                    cashRemain = 0;
                    item.credit = [item.priceSales floatValue]-item.cash;
                    statusPaymentMethod = 1;
                }
                else if (statusPaymentMethod == 1)
                {
                    item.cash =0;
                    item.credit = [item.priceSales floatValue];
                }
            }
        }
        else if(item.countInReceipt > 1 && [receipt.discount floatValue] != 0)
        {
            if([receipt.paymentMethod isEqualToString:@"CA"] && cashRemain >= [item.priceSales floatValue])
            {
                item.cash = [item.priceSales floatValue];
                item.credit = 0;
                cashRemain -= [item.priceSales floatValue];
            }
            else if([receipt.paymentMethod isEqualToString:@"CA"] && cashRemain < [item.priceSales floatValue])
            {
                item.cash = cashRemain;
                item.credit = 0;
                cashRemain = 0;
            }
            else if([receipt.paymentMethod isEqualToString:@"CC"] && creditRemain >= [item.priceSales floatValue])
            {
                item.cash = 0;
                item.credit = [item.priceSales floatValue];
                creditRemain -= [item.priceSales floatValue];
            }
            else if([receipt.paymentMethod isEqualToString:@"CC"] && creditRemain < [item.priceSales floatValue])
            {
                item.cash = 0;
                item.credit = creditRemain;
                creditRemain = 0;
            }
            else if([receipt.paymentMethod isEqualToString:@"BO"])
            {
                if(statusPaymentMethod == 0 && cashRemain >= [item.priceSales floatValue])
                {
                    item.cash = [item.priceSales floatValue];
                    item.credit = 0;
                    cashRemain -= item.cash;
                    if(cashRemain == 0)
                    {
                        statusPaymentMethod = 1;
                    }
                }
                else if(statusPaymentMethod == 0 && cashRemain < [item.priceSales floatValue])
                {
                    item.cash = cashRemain;
                    cashRemain = 0;
                    statusPaymentMethod = 1;
                    if(creditRemain >= [item.priceSales floatValue]-item.cash)
                    {
                        item.credit = [item.priceSales floatValue]-item.cash;
                        creditRemain -= item.credit;
                    }
                    else
                    {
                        item.credit = creditRemain;
                    }
                }
                else if (statusPaymentMethod == 1)
                {
                    item.cash =0;
                    if(creditRemain >= [item.priceSales floatValue])
                    {
                        item.credit = [item.priceSales floatValue];
                        creditRemain -= item.credit;
                    }
                    else
                    {
                        item.credit = creditRemain;
                    }
                }
            }
        }
    }
    
    
    //set size, data, type of cell for cell
    int receiptCount = 0;
    _arrCellSize = [[NSMutableArray alloc]init];
    _arrCellData = [[NSMutableArray alloc]init];
    _arrCellType = [[NSMutableArray alloc]init];
    _arrCellBorder = [[NSMutableArray alloc]init];
    _arrCellReceiptID = [[NSMutableArray alloc]init];
    _arrCellReceiptProductItemIndex = [[NSMutableArray alloc]init];
    _arrCellProductType = [[NSMutableArray alloc]init];
    float mainScreenBoundsWidth = [[UIScreen mainScreen] bounds].size.width;
    previousReceiptID = @"";
    
    
    int sizeCellNo = 26;
    int sizeCellStyle = 0;
    int sizeCellColor = 64;
    int sizeCellSize = 38;
    int sizeCellPrice = 44;
    int sizeCellChange = 64;
    sizeCellStyle = mainScreenBoundsWidth - sizeCellNo - sizeCellColor - sizeCellSize - sizeCellPrice - sizeCellChange;
    
    
    int sizeCellReceiptNo = sizeCellNo + sizeCellSize + sizeCellStyle + sizeCellColor;
    int sizeCellCustomer = sizeCellPrice;
    int sizeCellDeleteButton = sizeCellChange;
    int sizeCellCashCredit = 44;
    Receipt *itemReceipt;
    NSString *strReceiptID;
    float totalPerReceipt = 0.0;
    for(int i=0; i<[_receiptProductItemList count]; i++)
    {
        ReceiptProductItem *item = _receiptProductItemList[i];
        if(!(item.receiptID == [previousReceiptID integerValue]))
        {
            totalPerReceipt = 0;
            //header
            //size
            [_arrCellSize addObject:[NSString stringWithFormat:@"%d",sizeCellReceiptNo]];
            [_arrCellSize addObject:[NSString stringWithFormat:@"%d",sizeCellCustomer]];
            [_arrCellSize addObject:[NSString stringWithFormat:@"%d",sizeCellDeleteButton]];
            [_arrCellSize addObject:[NSString stringWithFormat:@"%d",sizeCellNo]];
            [_arrCellSize addObject:[NSString stringWithFormat:@"%d",sizeCellStyle]];
            [_arrCellSize addObject:[NSString stringWithFormat:@"%d",sizeCellColor]];
            [_arrCellSize addObject:[NSString stringWithFormat:@"%d",sizeCellSize]];
            [_arrCellSize addObject:[NSString stringWithFormat:@"%d",sizeCellPrice]];
            [_arrCellSize addObject:[NSString stringWithFormat:@"%d",sizeCellChange]];
            
            //data
            itemReceipt = _receiptList[receiptCount];
            receiptCount = receiptCount + 1;
            strReceiptID = [NSString stringWithFormat:@"%ld",(long)itemReceipt.receiptID];
            [_arrCellData addObject:[NSString stringWithFormat:@"%lu. Receipt no. %@", [_receiptList count]+1-receiptCount, [NSString stringWithFormat:@"R%06ld", item.receiptID]]];
            [_arrCellData addObject:@""];
            [_arrCellData addObject:@""];
            [_arrCellData addObject:@"No."];
            [_arrCellData addObject:@"Style"];
            [_arrCellData addObject:@"Color"];
            [_arrCellData addObject:@"Size"];
            [_arrCellData addObject:@"Price"];
            [_arrCellData addObject:@"Chg"];
            
            //Type
            [_arrCellType addObject:@"16"];//0=head,1=detailCenter,2=del,3=post,4=priceHeaderFooter,5=priceItem,6=headerLeft,7=discountReason,8=sales remark,9=detailRight,10=productName,11=productNo,12=change,13=detailcenter strikethrough,14=priceHeaderFooterWithBackgroundColor,15=customer,16=receiptno
            
            [_arrCellType addObject:@"15"];
            [_arrCellType addObject:@"2"];
            [_arrCellType addObject:@"0"];
            [_arrCellType addObject:@"0"];
            [_arrCellType addObject:@"0"];
            [_arrCellType addObject:@"0"];
            [_arrCellType addObject:@"0"];
            [_arrCellType addObject:@"0"];
            
            //Cell border
            [_arrCellBorder addObject:@"TBLR"];
            [_arrCellBorder addObject:@"TBLR"];
            [_arrCellBorder addObject:@"TBLR"];
            [_arrCellBorder addObject:@"TBLR"];
            [_arrCellBorder addObject:@"TBLR"];
            [_arrCellBorder addObject:@"TBLR"];
            [_arrCellBorder addObject:@"TBLR"];
            [_arrCellBorder addObject:@"TBLR"];
            [_arrCellBorder addObject:@"TBLR"];
            
            //Cell receipt id
            [_arrCellReceiptID addObject:strReceiptID];
            [_arrCellReceiptID addObject:strReceiptID];
            [_arrCellReceiptID addObject:strReceiptID];
            [_arrCellReceiptID addObject:strReceiptID];
            [_arrCellReceiptID addObject:strReceiptID];
            [_arrCellReceiptID addObject:strReceiptID];
            [_arrCellReceiptID addObject:strReceiptID];
            [_arrCellReceiptID addObject:strReceiptID];
            [_arrCellReceiptID addObject:strReceiptID];
            
            //Cell receipt product item id
            [_arrCellReceiptProductItemIndex addObject:[NSString stringWithFormat:@"%d",i]];
            [_arrCellReceiptProductItemIndex addObject:[NSString stringWithFormat:@"%d",i]];
            [_arrCellReceiptProductItemIndex addObject:[NSString stringWithFormat:@"%d",i]];
            [_arrCellReceiptProductItemIndex addObject:[NSString stringWithFormat:@"%d",i]];
            [_arrCellReceiptProductItemIndex addObject:[NSString stringWithFormat:@"%d",i]];
            [_arrCellReceiptProductItemIndex addObject:[NSString stringWithFormat:@"%d",i]];
            [_arrCellReceiptProductItemIndex addObject:[NSString stringWithFormat:@"%d",i]];
            [_arrCellReceiptProductItemIndex addObject:[NSString stringWithFormat:@"%d",i]];
            [_arrCellReceiptProductItemIndex addObject:[NSString stringWithFormat:@"%d",i]];
            
            //Cell product type
            [_arrCellProductType addObject:[NSString stringWithFormat:@""]];
            [_arrCellProductType addObject:[NSString stringWithFormat:@""]];
            [_arrCellProductType addObject:[NSString stringWithFormat:@""]];
            [_arrCellProductType addObject:[NSString stringWithFormat:@""]];
            [_arrCellProductType addObject:[NSString stringWithFormat:@""]];
            [_arrCellProductType addObject:[NSString stringWithFormat:@""]];
            [_arrCellProductType addObject:[NSString stringWithFormat:@""]];
            [_arrCellProductType addObject:[NSString stringWithFormat:@""]];
            [_arrCellProductType addObject:[NSString stringWithFormat:@""]];
            
            previousReceiptID = [NSString stringWithFormat:@"%ld",(long)item.receiptID];
        }
        
        //item
        //size
        [_arrCellSize addObject:[NSString stringWithFormat:@"%d",sizeCellNo]];
        [_arrCellSize addObject:[NSString stringWithFormat:@"%d",sizeCellStyle]];
        [_arrCellSize addObject:[NSString stringWithFormat:@"%d",sizeCellColor]];
        [_arrCellSize addObject:[NSString stringWithFormat:@"%d",sizeCellSize]];
        [_arrCellSize addObject:[NSString stringWithFormat:@"%d",sizeCellPrice]];
        [_arrCellSize addObject:[NSString stringWithFormat:@"%d",sizeCellChange]];
        
        //data
        [_arrCellData addObject:[NSString stringWithFormat:@"%@",item.row]];
        [_arrCellData addObject:[NSString stringWithFormat:@"%@",item.productName]];
        [_arrCellData addObject:[NSString stringWithFormat:@"%@",item.color]];
        [_arrCellData addObject:[NSString stringWithFormat:@"%@",item.size]];
        [_arrCellData addObject:[NSString stringWithFormat:@"%@",item.priceSales]];
        [_arrCellData addObject:[NSString stringWithFormat:@"%@",item.productType]];
        totalPerReceipt = totalPerReceipt + [item.priceSales floatValue];
        
        //Type
        [_arrCellType addObject:@"11"];//0=head,1=detailCenter,2=del,3=post,4=priceHeaderFooter,5=priceItem,6=headerLeft,7=discountReason,8=sales remark,9=detailRight,10=productName,11=productNo,12=change,13=detailcenter strikethrough,14=priceHeaderFooterWithBackgroundColor
        [_arrCellType addObject:@"10"];
        [_arrCellType addObject:@"13"];
        [_arrCellType addObject:@"13"];
        [_arrCellType addObject:@"5"];
        [_arrCellType addObject:@"12"];
        
        //cell border
        [_arrCellBorder addObject:@"TBLR"];
        [_arrCellBorder addObject:@"TBLR"];
        [_arrCellBorder addObject:@"TBLR"];
        [_arrCellBorder addObject:@"TBLR"];
        [_arrCellBorder addObject:@"TBLR"];
        [_arrCellBorder addObject:@"TBLR"];
        
        //Cell receipt id
        [_arrCellReceiptID addObject:strReceiptID];
        [_arrCellReceiptID addObject:strReceiptID];
        [_arrCellReceiptID addObject:strReceiptID];
        [_arrCellReceiptID addObject:strReceiptID];
        [_arrCellReceiptID addObject:strReceiptID];
        [_arrCellReceiptID addObject:strReceiptID];
        
        //Cell receipt product item id
        [_arrCellReceiptProductItemIndex addObject:[NSString stringWithFormat:@"%d",i]];
        [_arrCellReceiptProductItemIndex addObject:[NSString stringWithFormat:@"%d",i]];
        [_arrCellReceiptProductItemIndex addObject:[NSString stringWithFormat:@"%d",i]];
        [_arrCellReceiptProductItemIndex addObject:[NSString stringWithFormat:@"%d",i]];
        [_arrCellReceiptProductItemIndex addObject:[NSString stringWithFormat:@"%d",i]];
        [_arrCellReceiptProductItemIndex addObject:[NSString stringWithFormat:@"%d",i]];
        
        //Cell product type
        [_arrCellProductType addObject:[NSString stringWithFormat:@"%@",item.productType]];
        [_arrCellProductType addObject:[NSString stringWithFormat:@"%@",item.productType]];
        [_arrCellProductType addObject:[NSString stringWithFormat:@"%@",item.productType]];
        [_arrCellProductType addObject:[NSString stringWithFormat:@"%@",item.productType]];
        [_arrCellProductType addObject:[NSString stringWithFormat:@"%@",item.productType]];
        [_arrCellProductType addObject:[NSString stringWithFormat:@"%@",item.productType]];
        
        BOOL addFooter = NO;
        ReceiptProductItem *itemNext;
        if(i != [_receiptProductItemList count]-1)
        {
            itemNext = _receiptProductItemList[i+1];
            if(!(itemNext.receiptID == item.receiptID))
            {
                addFooter = YES;
            }
        }
        else
        {
            addFooter = YES;
        }
        
        if(addFooter)
        {
            //add footer
            float discountValue = [itemReceipt.discount intValue]==0?0:[itemReceipt.discount intValue]==1?[itemReceipt.discountValue floatValue]:[itemReceipt.discountPercent floatValue]*0.01*totalPerReceipt;
            NSString *discountLabel;
            if([itemReceipt.discount intValue]==2)
            {
                discountLabel = [NSString stringWithFormat:@"Disc (%@\uFF05)",itemReceipt.discountPercent];
            }
            else
            {
                discountLabel = [NSString stringWithFormat:@"Discount"];
            }
            
            //size
            [_arrCellSize addObject:[NSString stringWithFormat:@"%d",sizeCellCashCredit]];
            [_arrCellSize addObject:[NSString stringWithFormat:@"%d",sizeCellStyle+sizeCellNo-sizeCellCashCredit]];
            [_arrCellSize addObject:[NSString stringWithFormat:@"%d",sizeCellColor]];
            [_arrCellSize addObject:[NSString stringWithFormat:@"%d",sizeCellSize+sizeCellPrice]];
            [_arrCellSize addObject:[NSString stringWithFormat:@"%d",sizeCellChange]];
            [_arrCellSize addObject:[NSString stringWithFormat:@"%d",sizeCellCashCredit]];
            [_arrCellSize addObject:[NSString stringWithFormat:@"%d",sizeCellStyle+sizeCellNo-sizeCellCashCredit]];
            [_arrCellSize addObject:[NSString stringWithFormat:@"%d",sizeCellColor]];
            [_arrCellSize addObject:[NSString stringWithFormat:@"%d",sizeCellSize+sizeCellPrice]];
            [_arrCellSize addObject:[NSString stringWithFormat:@"%d",sizeCellChange]];
            [_arrCellSize addObject:[NSString stringWithFormat:@"%d",sizeCellCashCredit]];
            [_arrCellSize addObject:[NSString stringWithFormat:@"%d",sizeCellStyle+sizeCellNo-sizeCellCashCredit]];
            [_arrCellSize addObject:[NSString stringWithFormat:@"%d",sizeCellColor]];
            [_arrCellSize addObject:[NSString stringWithFormat:@"%d",sizeCellSize+sizeCellPrice]];
            [_arrCellSize addObject:[NSString stringWithFormat:@"%d",sizeCellChange]];
            [_arrCellSize addObject:[NSString stringWithFormat:@"%d",sizeCellNo+sizeCellStyle+sizeCellColor+sizeCellSize+sizeCellPrice+sizeCellChange]];
            [_arrCellSize addObject:[NSString stringWithFormat:@"%d",sizeCellSize+sizeCellPrice]];
            [_arrCellSize addObject:[NSString stringWithFormat:@"%d",sizeCellNo+sizeCellStyle+sizeCellColor+sizeCellChange]];
            
            
            //data
            [_arrCellData addObject:[NSString stringWithFormat:@"Cash"]];
            [_arrCellData addObject:[NSString stringWithFormat:@"%@",itemReceipt.cashAmount]];
            [_arrCellData addObject:[NSString stringWithFormat:@""]];
            [_arrCellData addObject:[NSString stringWithFormat:@"Total"]];
            [_arrCellData addObject:[NSString stringWithFormat:@"%f",totalPerReceipt]];
            [_arrCellData addObject:[NSString stringWithFormat:@"Credit"]];
            [_arrCellData addObject:[NSString stringWithFormat:@"%@",itemReceipt.creditAmount]];
            [_arrCellData addObject:[NSString stringWithFormat:@""]];
            [_arrCellData addObject:[NSString stringWithFormat:@"%@",discountLabel]];
            //            [_arrCellData addObject:[NSString stringWithFormat:discountLabel,itemReceipt.discountPercent]];
            [_arrCellData addObject:[NSString stringWithFormat:@"%f",discountValue]];
            [_arrCellData addObject:[NSString stringWithFormat:@"Time"]];
            [_arrCellData addObject:[NSString stringWithFormat:@"%@",[Utility formatDate:itemReceipt.receiptDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"HH:mm"]]];
            [_arrCellData addObject:[NSString stringWithFormat:@""]];
            [_arrCellData addObject:[NSString stringWithFormat:@"Aft. discount"]];
            [_arrCellData addObject:[NSString stringWithFormat:@"%@",itemReceipt.payPrice]];
            [_arrCellData addObject:[NSString stringWithFormat:@"%@",itemReceipt.discountReason]];
            [_arrCellData addObject:[NSString stringWithFormat:@"Sales remark:"]];
            [_arrCellData addObject:[NSString stringWithFormat:@"%@",itemReceipt.remark]];
            
            //Type
            [_arrCellType addObject:@"6"];//0=head,1=detailCenter,2=del,3=post,4=priceHeaderFooter,5=priceItem,6=headerLeft,7=discountReason,8=sales remark,9=detailRight,10=productName,11=productNo,12=change,13=detailcenter strikethrough,14=priceHeaderFooterWithBackgroundColor
            [_arrCellType addObject:@"4"];
            [_arrCellType addObject:@"1"];
            [_arrCellType addObject:@"6"];
            [_arrCellType addObject:@"4"];
            [_arrCellType addObject:@"6"];
            [_arrCellType addObject:@"4"];
            [_arrCellType addObject:@"1"];
            [_arrCellType addObject:@"6"];
            [_arrCellType addObject:@"4"];
            [_arrCellType addObject:@"6"];
            [_arrCellType addObject:@"9"];
            [_arrCellType addObject:@"0"];
            [_arrCellType addObject:@"6"];
            [_arrCellType addObject:@"14"];
            [_arrCellType addObject:@"7"];
            [_arrCellType addObject:@"6"];
            [_arrCellType addObject:@"8"];
            
            for(int j=0; j<16; j++)
            {
                //cell border
                [_arrCellBorder addObject:@"TBLR"];
                
                //Cell receipt id
                [_arrCellReceiptID addObject:strReceiptID];
                
                //Cell receipt product item id
                [_arrCellReceiptProductItemIndex addObject:[NSString stringWithFormat:@"%d",i]];
                
                //Cell product type
                [_arrCellProductType addObject:[NSString stringWithFormat:@""]];
            }
            
            //sales remark
            {
                //cell border
                [_arrCellBorder addObject:@"TBL"];
                
                //Cell receipt id
                [_arrCellReceiptID addObject:strReceiptID];
                
                //Cell receipt product item id
                [_arrCellReceiptProductItemIndex addObject:[NSString stringWithFormat:@"%d",i]];
                
                //Cell product type
                [_arrCellProductType addObject:[NSString stringWithFormat:@""]];
            }
            {
                //cell border
                [_arrCellBorder addObject:@"TBR"];
                
                //Cell receipt id
                [_arrCellReceiptID addObject:strReceiptID];
                
                //Cell receipt product item id
                [_arrCellReceiptProductItemIndex addObject:[NSString stringWithFormat:@"%d",i]];
                
                //Cell product type
                [_arrCellProductType addObject:[NSString stringWithFormat:@""]];
            }
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self loadingOverlayView];
    
    NSString *strReceiptID = _arrCellReceiptID[textField.tag];
    _receiptRemark = [[Receipt alloc]init];
    _receiptRemark.receiptID = [strReceiptID integerValue];
    _receiptRemark.remark = [Utility trimString:textField.text];
//    Receipt *receipt = [self getReceipt:[strReceiptID integerValue]];
//    receipt.remark = [Utility trimString:textField.text];
    _homeModel = [[HomeModel alloc] init];
    _homeModel.delegate = self;
    [_homeModel updateItems:dbReceipt withData:_receiptRemark];
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
-(BOOL)cashAllocationChanged
{
    NSString *allText = [NSString stringWithFormat:@"%@%@",_txtChanges.text,_txtTransfer.text];
    NSString *allDBText = [NSString stringWithFormat:@"%@%@",_cashAllocationInitial.cashChanges,_cashAllocationInitial.cashTransfer];
    if([allText isEqualToString:allDBText])
    {
        return NO;
    }
    return YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register cell classes
    [colViewSummaryTable registerClass:[CustomUICollectionViewCellButton2 class] forCellWithReuseIdentifier:reuseIdentifier];
    [colViewSummaryTable registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeaderViewIdentifier];
    [colViewSummaryTable registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:reuseFooterViewIdentifier];
    
    colViewSummaryTable.delegate = self;
    colViewSummaryTable.dataSource = self;
    
    
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
    preOrderEventIDHistoryView.backgroundColor = [UIColor lightGrayColor];
    
    
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
        float customViewWidth = 180;
        float customViewHeight = 180;
        customMadeView.frame = CGRectMake((self.view.frame.size.width-customViewWidth)/2, (self.view.frame.size.height-customViewHeight)/2, customViewWidth, customViewHeight);
        
        
        float preOrderEventIDHistoryViewWidth = self.view.frame.size.width;
        float preOrderEventIDHistoryViewHeight = self.view.frame.size.width;
        preOrderEventIDHistoryView.frame = CGRectMake((self.view.frame.size.width-preOrderEventIDHistoryViewWidth)/2, (self.view.frame.size.height-preOrderEventIDHistoryViewHeight)/2, preOrderEventIDHistoryViewWidth, preOrderEventIDHistoryViewHeight);
        
        
        float controlWidth = 300;//customMadeView.bounds.size.width - 40*2;//minus left, right margin
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
    }
    
    
    
    [[NSBundle mainBundle] loadNibNamed:@"CashAllocationView" owner:self options:nil];
    cashAllocationView.delegate = self;
    cashAllocationView.dataSource = self;
    cashAllocationView.backgroundColor = [UIColor lightGrayColor];
    
    
    {
        float cashAllocationViewWidth = 180;
        float cashAllocationViewHeight = 80;
        cashAllocationView.frame = CGRectMake((self.view.frame.size.width-cashAllocationViewWidth)/2, (self.view.frame.size.height-cashAllocationViewHeight)/2, cashAllocationViewWidth, cashAllocationViewHeight);
        
        
        float controlWidth = 300;//customMadeView.bounds.size.width - 40*2;//minus left, right margin
        float controlHeight = 25;
        float controlXOrigin = 20;
        float controlYOrigin = 3+(cashAllocationView.rowHeight-25)/2;
        
        
        _txtChanges = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, controlHeight)];
        _txtChanges.placeholder = @"Initial Changes";
        _txtChanges.clearButtonMode = UITextFieldViewModeWhileEditing;
        _txtChanges.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
        _txtChanges.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
        _txtChanges.keyboardType = UIKeyboardTypeNumberPad;
        
        _txtTransfer = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, controlHeight)];
        _txtTransfer.placeholder = @"Transfer";
        _txtTransfer.clearButtonMode = UITextFieldViewModeWhileEditing;
        _txtTransfer.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
        _txtTransfer.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
        _txtTransfer.keyboardType = UIKeyboardTypeNumberPad;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    if(_booShortOrDetail)
    {
        NSInteger countColumn = 6;
        return ([_receiptProductItemList count]+1)*countColumn;
    }
    else
    {
        NSInteger itemNo = 0;
        NSInteger countColumn = 6;
        if([_receiptList count] != 0)
        {
            itemNo =([_receiptProductItemList count])*countColumn + (countColumn+3)*[_receiptList count] + (18)*[_receiptList count];
        }
        return itemNo;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(_booShortOrDetail)
    {
        CustomUICollectionViewCellButton2 *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        
        if ([cell.label isDescendantOfView:cell]) {
            [cell.label removeFromSuperview];
        }
        if ([cell.buttonAdd isDescendantOfView:cell]) {
            [cell.buttonAdd removeFromSuperview];
        }
        if ([cell.buttonInfo isDescendantOfView:cell]) {
            [cell.buttonInfo removeFromSuperview];
        }
        if ([cell.buttonDetail isDescendantOfView:cell]) {
            [cell.buttonDetail removeFromSuperview];
        }
        if ([cell.buttonDetail2 isDescendantOfView:cell]) {
            [cell.buttonDetail2 removeFromSuperview];
        }
        if ([cell.imageView isDescendantOfView:cell]) {
            [cell.imageView removeFromSuperview];
        }
        if ([cell.topBorder isDescendantOfView:cell]) {
            [cell.leftBorder removeFromSuperview];
            [cell.topBorder removeFromSuperview];
            [cell.rightBorder removeFromSuperview];
            [cell.bottomBorder removeFromSuperview];
        }
        if ([cell.cellBackground isDescendantOfView:cell]) {
            [cell.cellBackground removeFromSuperview];
        }
        if ([cell.textField isDescendantOfView:cell])
        {
            [cell.textField removeFromSuperview];
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
        
        //        NSInteger section = indexPath.section;
        NSInteger item = indexPath.item;
        
        NSArray *header = @[@"No.",@"Item",@"Color",@"Size",@"Cash",@"Credit"];
        NSInteger countColumn = [header count];
        
        
        if(item/countColumn==0)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
            cell.label.textColor = [UIColor whiteColor];
            cell.label.backgroundColor = tBlueColor;
            cell.label.textAlignment = NSTextAlignmentCenter;
        }
        else if(item%countColumn == 0 || item%countColumn == 1 || item%countColumn == 2 || item%countColumn == 3)
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
        else if(item%countColumn == 4 || item%countColumn == 5)
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
        
        
        cell.label.minimumScaleFactor = 1;
        cell.label.lineBreakMode = NSLineBreakByTruncatingTail;
        if(item/countColumn == 0)
        {
            NSInteger remainder = item%countColumn;
            cell.label.text = header[remainder];
        }
        else
        {
            ReceiptProductItem *receiptProductItem = (ReceiptProductItem *)_receiptProductItemList[item/countColumn-1];
            switch (item%countColumn) {
                case 0:
                {
                    cell.label.text = receiptProductItem.row2;
                }
                break;
                case 1:
                {
                    cell.label.text = receiptProductItem.productName;
                }
                break;
                case 2:
                {
                    cell.label.minimumScaleFactor = 0.5;
                    cell.label.lineBreakMode = NSLineBreakByTruncatingMiddle;
                    cell.label.text = receiptProductItem.color;
                }
                break;
                case 3:
                {
                    cell.label.text = receiptProductItem.size;
                }
                break;
                case 4:
                {
                    NSString *strCash = [NSString stringWithFormat:@"%f",receiptProductItem.cash];
                    cell.label.text = receiptProductItem.cash==0?@"-":[Utility formatBaht:strCash];
                }
                break;
                case 5:
                {
                    NSString *strCredit = [NSString stringWithFormat:@"%f",receiptProductItem.credit];
                    cell.label.text = receiptProductItem.credit==0?@"-":[Utility formatBaht:strCredit];
                }
                break;
                default:
                break;
            }
        }
        
        return cell;
    }
    else
    {
        CustomUICollectionViewCellButton2 *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        
        if ([cell.btnPrint isDescendantOfView:cell]) {
            [cell.btnPrint removeFromSuperview];
        }
        if ([cell.label isDescendantOfView:cell]) {
            [cell.label removeFromSuperview];
        }
        if ([cell.buttonAdd isDescendantOfView:cell]) {
            [cell.buttonAdd removeFromSuperview];
        }
        if ([cell.buttonInfo isDescendantOfView:cell]) {
            [cell.buttonInfo removeFromSuperview];
        }
        if ([cell.buttonDetail isDescendantOfView:cell]) {
            [cell.buttonDetail removeFromSuperview];
        }
        if ([cell.buttonDetail2 isDescendantOfView:cell]) {
            [cell.buttonDetail2 removeFromSuperview];
        }
        if ([cell.imageView isDescendantOfView:cell]) {
            [cell.imageView removeFromSuperview];
        }
        if ([cell.topBorder isDescendantOfView:cell]) {
            [cell.leftBorder removeFromSuperview];
            [cell.topBorder removeFromSuperview];
            [cell.rightBorder removeFromSuperview];
            [cell.bottomBorder removeFromSuperview];
        }
        if ([cell.cellBackground isDescendantOfView:cell]) {
            [cell.cellBackground removeFromSuperview];
        }
        if ([cell.textField isDescendantOfView:cell])
        {
            [cell.textField removeFromSuperview];
        }
        
        NSInteger item = indexPath.item;
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
            cell.cellBackground.frame = CGRectMake(cell.bounds.origin.x+1
                                                   , cell.bounds.origin.y+1, cell.bounds.size.width-1, cell.bounds.size.height-1);
            
            if([_arrCellBorder[item] isEqualToString:@"TBLR"])
            {
                [cell addSubview:cell.leftBorder];
                [cell addSubview:cell.topBorder];
                [cell addSubview:cell.rightBorder];
                [cell addSubview:cell.bottomBorder];
            }
            else if([_arrCellBorder[item] isEqualToString:@"TBL"])
            {
                [cell addSubview:cell.leftBorder];
                [cell addSubview:cell.topBorder];
                [cell addSubview:cell.bottomBorder];
            }
            else if([_arrCellBorder[item] isEqualToString:@"TBR"])
            {
                [cell addSubview:cell.topBorder];
                [cell addSubview:cell.rightBorder];
                [cell addSubview:cell.bottomBorder];
            }
        }
        cell.label.backgroundColor = [UIColor clearColor];
        
        cell.label.minimumScaleFactor = 1;
        cell.label.lineBreakMode = NSLineBreakByTruncatingTail;
        if([_arrCellType[item] intValue] == 0)//0=head,1=detailCenter,2=del,3=post,4=priceHeaderFooter,5=priceItem,6=headerLeft,7=discountReason,8=sales remark,9=detailRight,10=productName,11=productNo,12=change,13=detailcenter strikethrough,14=priceHeaderFooterWithBackgroundColor
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
            cell.label.textColor= [UIColor blackColor];
            cell.label.textAlignment = NSTextAlignmentCenter;
            
            UIFont *font2 = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
            NSDictionary *arialDict2 = [NSDictionary dictionaryWithObject: font2 forKey:NSFontAttributeName];
            NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:_arrCellData[item] attributes: arialDict2];
            cell.label.attributedText = aAttrString2;
        }
        else if([_arrCellType[item] intValue] == 1)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
            cell.label.textColor= [UIColor blackColor];
            cell.label.textAlignment = NSTextAlignmentCenter;
            
            UIFont *font2 = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
            NSDictionary *arialDict2 = [NSDictionary dictionaryWithObject: font2 forKey:NSFontAttributeName];
            NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:_arrCellData[item] attributes: arialDict2];
            cell.label.attributedText = aAttrString2;
            cell.label.minimumScaleFactor = 0.5;
            cell.label.lineBreakMode = NSLineBreakByTruncatingMiddle;
        }
        else if([_arrCellType[item] intValue] == 2)
        {
            cell.imageView.image = [self renderMark];
            cell.imageView.userInteractionEnabled = YES;
            [cell addSubview:cell.imageView];
            
            CGRect frame = cell.bounds;
            NSInteger imageSize = 18;
            frame.origin.x = (frame.size.width-imageSize)/2;
            frame.origin.y = (frame.size.height-imageSize)/2;
            frame.size.width = imageSize;
            frame.size.height = imageSize;
            cell.imageView.frame = frame;
            
            
            cell.imageView.tag = item;
            [cell.singleTap removeTarget:self action:@selector(addPostCustomer:)];
            [cell.singleTap removeTarget:self action:@selector(editPostCustomer:)];
            [cell.singleTap removeTarget:self action:@selector(changeProduct:)];
            [cell.singleTap removeTarget:self action:@selector(deleteSales:)];
            [cell.singleTap removeTarget:self action:@selector(postProductItem:)];
            [cell.singleTap addTarget:self action:@selector(deleteSales:)];
            cell.singleTap.numberOfTapsRequired = 1;
            cell.singleTap.numberOfTouchesRequired = 1;
            [cell.imageView addGestureRecognizer:cell.singleTap];
        }
        else if([_arrCellType[item] intValue] == 4)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
            cell.label.textColor= [UIColor blackColor];
            cell.label.textAlignment = NSTextAlignmentRight;
            
            UIFont *font2 = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
            NSDictionary *arialDict2 = [NSDictionary dictionaryWithObject: font2 forKey:NSFontAttributeName];
            NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:[Utility formatBaht:_arrCellData[item]] attributes: arialDict2];
            cell.label.attributedText = aAttrString2;
        }
        else if([_arrCellType[item] intValue] == 5)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
            cell.label.textColor= [UIColor blackColor];
            cell.label.textAlignment = NSTextAlignmentCenter;
            
            UIFont *font2 = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
            NSDictionary *arialDict2 = [NSDictionary dictionaryWithObject: font2 forKey:NSFontAttributeName];
            NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:[Utility formatBaht:_arrCellData[item]] attributes: arialDict2];
            cell.label.attributedText = aAttrString2;
        }
        else if([_arrCellType[item] intValue] == 6)//0=headerCenter,1=detail,2=del,3=post,4=priceHeaderFooter,5=priceItem,6=headerLeft
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
            cell.label.textColor= [UIColor blackColor];
            cell.label.textAlignment = NSTextAlignmentLeft;
            
            UIFont *font2 = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
            NSDictionary *arialDict2 = [NSDictionary dictionaryWithObject: font2 forKey:NSFontAttributeName];
            NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:_arrCellData[item] attributes: arialDict2];
            cell.label.attributedText = aAttrString2;
            
            
        }
        else if([_arrCellType[item] intValue] == 7)
        {
            UIFont *font1 = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
            NSDictionary *arialDict = [NSDictionary dictionaryWithObject: font1 forKey:NSFontAttributeName];
            NSMutableAttributedString *aAttrString1 = [[NSMutableAttributedString alloc] initWithString:@"Discount reason: " attributes: arialDict];
            
            UIFont *font2 = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
            NSDictionary *arialDict2 = [NSDictionary dictionaryWithObject: font2 forKey:NSFontAttributeName];
            NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:_arrCellData[item] attributes: arialDict2];
            [aAttrString1 appendAttributedString:aAttrString2];
            
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.textColor= [UIColor blackColor];
            cell.label.textAlignment = NSTextAlignmentLeft;
            cell.label.attributedText = aAttrString1;
        }
        else if([_arrCellType[item] intValue] == 8)
        {
            float controlYOrigin = (30-13)/2;//table row height minus control height and set vertical center
            CGRect frame = CGRectMake(10.0f, controlYOrigin, cell.frame.size.width-10, 15.0f);
            cell.textField.frame = frame;
            cell.textField.delegate = self;
            cell.textField.tag = item;
            cell.textField.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
            cell.textField.text = _arrCellData[item];
            [cell addSubview:cell.textField];
        }
        else if([_arrCellType[item] intValue] == 9)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
            cell.label.textColor= [UIColor blackColor];
            cell.label.textAlignment = NSTextAlignmentRight;
            
            UIFont *font2 = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
            NSDictionary *arialDict2 = [NSDictionary dictionaryWithObject: font2 forKey:NSFontAttributeName];
            NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:_arrCellData[item] attributes: arialDict2];
            cell.label.attributedText = aAttrString2;
        }
        else if([_arrCellType[item] intValue] == 10)
        {
            [cell addSubview:cell.cellBackground];
            
            NSInteger receiptProductItemIndex = [_arrCellReceiptProductItemIndex[item] integerValue];
            ReceiptProductItem *receiptProductItem = _receiptProductItemList[receiptProductItemIndex];
            NSMutableArray *preOrderEventIDHistoryList = [self getHistoryWithReceiptProductItemID:receiptProductItem.receiptProductItemID];
            //I=Inventory,C=Custom made,A=change I,B=change C,P=preorder,D=change P,S=post preorder,R=post CM,E=change R,F=change S
            if([_arrCellProductType[item] isEqualToString:@"P"])
            {
                cell.cellBackground.backgroundColor = [UIColor lightGrayColor];
                [cell addSubview:cell.label];
                cell.label.frame = cell.bounds;
                cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                cell.label.textColor= [UIColor blackColor];
                cell.label.textAlignment = NSTextAlignmentCenter;
                
                UIFont *font2 = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                NSDictionary *arialDict2 = [NSDictionary dictionaryWithObject: font2 forKey:NSFontAttributeName];
                NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:_arrCellData[item] attributes: arialDict2];
                cell.label.attributedText = aAttrString2;
                
                
                cell.tag = item;
                [cell.singleTap removeTarget:self action:@selector(addPostCustomer:)];
                [cell.singleTap removeTarget:self action:@selector(editPostCustomer:)];
                [cell.singleTap removeTarget:self action:@selector(changeProduct:)];
                [cell.singleTap removeTarget:self action:@selector(deleteSales:)];
                [cell.singleTap removeTarget:self action:@selector(postProductItem:)];
                [cell.singleTap addTarget:self action:@selector(postProductItem:)];
                cell.singleTap.numberOfTapsRequired = 1;
                cell.singleTap.numberOfTouchesRequired = 1;
                [cell addGestureRecognizer:cell.singleTap];
            }
            else if([_arrCellProductType[item] isEqualToString:@"S"] && [preOrderEventIDHistoryList count]>0)
            {
                cell.cellBackground.backgroundColor = tBlueColor;
                [cell addSubview:cell.label];
                cell.label.frame = cell.bounds;
                cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                cell.label.textColor= [UIColor whiteColor];
                cell.label.textAlignment = NSTextAlignmentCenter;
                
                UIFont *font2 = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                NSDictionary *arialDict2 = [NSDictionary dictionaryWithObject: font2 forKey:NSFontAttributeName];
                NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:_arrCellData[item] attributes: arialDict2];
                cell.label.attributedText = aAttrString2;
                
                
                cell.tag = item;
                [cell.singleTap removeTarget:self action:@selector(addPostCustomer:)];
                [cell.singleTap removeTarget:self action:@selector(editPostCustomer:)];
                [cell.singleTap removeTarget:self action:@selector(changeProduct:)];
                [cell.singleTap removeTarget:self action:@selector(deleteSales:)];
                [cell.singleTap removeTarget:self action:@selector(postProductItem:)];
                [cell.singleTap addTarget:self action:@selector(postProductItem:)];
                cell.singleTap.numberOfTapsRequired = 1;
                cell.singleTap.numberOfTouchesRequired = 1;
                [cell addGestureRecognizer:cell.singleTap];
            }
            else if([_arrCellProductType[item] isEqualToString:@"D"] && [preOrderEventIDHistoryList count]>0)
            {
                cell.cellBackground.backgroundColor = [UIColor lightGrayColor];
                [cell addSubview:cell.label];
                cell.label.frame = cell.bounds;
                cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                cell.label.textColor= [UIColor blackColor];
                cell.label.textAlignment = NSTextAlignmentCenter;
                
                NSDictionary* attributes = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
                NSAttributedString* attrText = [[NSAttributedString alloc] initWithString:_arrCellData[item] attributes:attributes];
                cell.label.attributedText = attrText;
                
                cell.tag = item;
                [cell.singleTap removeTarget:self action:@selector(addPostCustomer:)];
                [cell.singleTap removeTarget:self action:@selector(editPostCustomer:)];
                [cell.singleTap removeTarget:self action:@selector(changeProduct:)];
                [cell.singleTap removeTarget:self action:@selector(deleteSales:)];
                [cell.singleTap removeTarget:self action:@selector(postProductItem:)];
                [cell.singleTap addTarget:self action:@selector(postProductItem:)];
                cell.singleTap.numberOfTapsRequired = 1;
                cell.singleTap.numberOfTouchesRequired = 1;
                [cell addGestureRecognizer:cell.singleTap];
            }
            else if([_arrCellProductType[item] isEqualToString:@"I"] || [_arrCellProductType[item] isEqualToString:@"S"] || [_arrCellProductType[item] isEqualToString:@"U"])
            {
                cell.cellBackground.backgroundColor = tBlueColor;
                [cell addSubview:cell.label];
                cell.label.frame = cell.bounds;
                cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                cell.label.textColor= [UIColor whiteColor];
                cell.label.textAlignment = NSTextAlignmentCenter;
                
                UIFont *font2 = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                NSDictionary *arialDict2 = [NSDictionary dictionaryWithObject: font2 forKey:NSFontAttributeName];
                NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:_arrCellData[item] attributes: arialDict2];
                cell.label.attributedText = aAttrString2;
            }
            else if([_arrCellProductType[item] isEqualToString:@"C"] || [_arrCellProductType[item] isEqualToString:@"R"] || [_arrCellProductType[item] isEqualToString:@"V"])
            {
                cell.cellBackground.backgroundColor = tBlueColor;
                [cell addSubview:cell.buttonDetail];
                cell.buttonDetail.frame = cell.bounds;
                
                NSDictionary* attributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
                NSAttributedString* attrText = [[NSAttributedString alloc] initWithString:_arrCellData[item] attributes:attributes];
                [cell.buttonDetail setAttributedTitle:attrText forState:UIControlStateNormal];
                cell.buttonDetail.titleLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                
                
                cell.buttonDetail.tag = item;
                [cell.buttonDetail removeTarget:self action:@selector(showProductID:)
                               forControlEvents:UIControlEventTouchDown];
                [cell.buttonDetail removeTarget:self action:@selector(editCustomMadeDetail:)
                               forControlEvents:UIControlEventTouchUpInside];
                
                
                [cell.buttonDetail addTarget:self action:@selector(editCustomMadeDetail:)
                            forControlEvents:UIControlEventTouchUpInside];
            }
            else if([_arrCellProductType[item] isEqualToString:@"A"] || [_arrCellProductType[item] isEqualToString:@"F"])
            {
                cell.cellBackground.backgroundColor = tBlueColor;
                [cell addSubview:cell.label];
                cell.label.frame = cell.bounds;
                cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                cell.label.textColor= [UIColor whiteColor];
                cell.label.textAlignment = NSTextAlignmentCenter;
                
                NSDictionary* attributes = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
                NSAttributedString* attrText = [[NSAttributedString alloc] initWithString:_arrCellData[item] attributes:attributes];
                cell.label.attributedText = attrText;
            }
            else if([_arrCellProductType[item] isEqualToString:@"B"] || [_arrCellProductType[item] isEqualToString:@"E"])
            {
                cell.cellBackground.backgroundColor = tBlueColor;
                [cell addSubview:cell.buttonDetail];
                cell.buttonDetail.frame = cell.bounds;
                
                
                NSDictionary* attributes = @{NSStrikethroughStyleAttributeName:[NSNumber numberWithInt:NSUnderlineStyleSingle],NSForegroundColorAttributeName:[UIColor whiteColor]};
                NSAttributedString* attrText = [[NSAttributedString alloc] initWithString:_arrCellData[item] attributes:attributes];
                [cell.buttonDetail setAttributedTitle:attrText forState:UIControlStateNormal];
                cell.buttonDetail.titleLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                
                
                
                [cell.buttonDetail removeTarget:self action:@selector(showProductID:)
                               forControlEvents:UIControlEventTouchDown];
                [cell.buttonDetail removeTarget:self action:@selector(editCustomMadeDetail:)
                               forControlEvents:UIControlEventTouchUpInside];
                
                
                cell.buttonDetail.tag = item;
                [cell.buttonDetail addTarget:self action:@selector(editCustomMadeDetail:)
                            forControlEvents:UIControlEventTouchUpInside];
            }
            else if([_arrCellProductType[item] isEqualToString:@"D"])
            {
                cell.cellBackground.backgroundColor = [UIColor lightGrayColor];
                [cell addSubview:cell.label];
                cell.label.frame = cell.bounds;
                cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                cell.label.textColor= [UIColor blackColor];
                cell.label.textAlignment = NSTextAlignmentCenter;
                
                NSDictionary* attributes = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
                NSAttributedString* attrText = [[NSAttributedString alloc] initWithString:_arrCellData[item] attributes:attributes];
                cell.label.attributedText = attrText;
            }
        }
        else if([_arrCellType[item] intValue] == 11)
        {
            NSDictionary* attributes;
            if([_arrCellProductType[item] isEqualToString:@"I"] || [_arrCellProductType[item] isEqualToString:@"C"] || [_arrCellProductType[item] isEqualToString:@"P"] || [_arrCellProductType[item] isEqualToString:@"S"] || [_arrCellProductType[item] isEqualToString:@"R"])
            {
                attributes = @{NSForegroundColorAttributeName:[UIColor blackColor]};
            }
            else if([_arrCellProductType[item] isEqualToString:@"A"] || [_arrCellProductType[item] isEqualToString:@"B"] || [_arrCellProductType[item] isEqualToString:@"D"] || [_arrCellProductType[item] isEqualToString:@"E"] || [_arrCellProductType[item] isEqualToString:@"F"])
            {
                attributes = @{NSForegroundColorAttributeName:[UIColor blackColor],NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
            }
            
            NSAttributedString* attrText = [[NSAttributedString alloc] initWithString:_arrCellData[item] attributes:attributes];
            [cell.buttonDetail setAttributedTitle:attrText forState:UIControlStateNormal];
            [cell.buttonDetail setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            cell.buttonDetail.titleLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
            
            [cell addSubview:cell.buttonDetail];
            cell.buttonDetail.frame = cell.bounds;
            
            
            [cell.buttonDetail removeTarget:self action:@selector(showProductID:)
                           forControlEvents:UIControlEventTouchDown];
            [cell.buttonDetail removeTarget:self action:@selector(editCustomMadeDetail:)
                           forControlEvents:UIControlEventTouchUpInside];
            
            
            cell.buttonDetail.tag = item;
            [cell.buttonDetail addTarget:self action:@selector(showProductID:)
                        forControlEvents:UIControlEventTouchDown];
        }
        else if([_arrCellType[item] intValue] == 12)
        {
            if([_arrCellProductType[item] isEqualToString:@"I"] || [_arrCellProductType[item] isEqualToString:@"C"] || [_arrCellProductType[item] isEqualToString:@"P"] || [_arrCellProductType[item] isEqualToString:@"S"] || [_arrCellProductType[item] isEqualToString:@"R"] || [_arrCellProductType[item] isEqualToString:@"U"] || [_arrCellProductType[item] isEqualToString:@"V"])
            {
                cell.imageView.image = [UIImage imageNamed:@"change active3.png"];
                cell.imageView.userInteractionEnabled = YES;
                [cell addSubview:cell.imageView];
                
                CGRect frame = cell.bounds;
                NSInteger imageSize = 18;
                frame.origin.x = (frame.size.width-imageSize)/2;
                frame.origin.y = (frame.size.height-imageSize)/2;
                frame.size.width = imageSize;
                frame.size.height = imageSize;
                cell.imageView.frame = frame;
                
                
                cell.imageView.tag = item;
                [cell.singleTap removeTarget:self action:@selector(addPostCustomer:)];
                [cell.singleTap removeTarget:self action:@selector(editPostCustomer:)];
                [cell.singleTap removeTarget:self action:@selector(changeProduct:)];
                [cell.singleTap removeTarget:self action:@selector(deleteSales:)];
                [cell.singleTap removeTarget:self action:@selector(postProductItem:)];
                [cell.singleTap addTarget:self action:@selector(changeProduct:)];
                cell.singleTap.numberOfTapsRequired = 1;
                cell.singleTap.numberOfTouchesRequired = 1;
                [cell.imageView addGestureRecognizer:cell.singleTap];
            }
            else if([_arrCellProductType[item] isEqualToString:@"A"] || [_arrCellProductType[item] isEqualToString:@"B"] || [_arrCellProductType[item] isEqualToString:@"D"] || [_arrCellProductType[item] isEqualToString:@"E"] || [_arrCellProductType[item] isEqualToString:@"F"])
            {
                cell.imageView.image = [UIImage imageNamed:@"change inactive3.png"];
                cell.imageView.userInteractionEnabled = YES;
                [cell addSubview:cell.imageView];
                
                CGRect frame = cell.bounds;
                NSInteger imageSize = 18;
                frame.origin.x = (frame.size.width-imageSize)/2;
                frame.origin.y = (frame.size.height-imageSize)/2;
                frame.size.width = imageSize;
                frame.size.height = imageSize;
                cell.imageView.frame = frame;
                
                
                cell.imageView.tag = item;
                [cell.singleTap removeTarget:self action:@selector(addPostCustomer:)];
                [cell.singleTap removeTarget:self action:@selector(editPostCustomer:)];
                [cell.singleTap removeTarget:self action:@selector(changeProduct:)];
                [cell.singleTap removeTarget:self action:@selector(deleteSales:)];
                [cell.singleTap removeTarget:self action:@selector(postProductItem:)];
                cell.singleTap.numberOfTapsRequired = 1;
                cell.singleTap.numberOfTouchesRequired = 1;
                [cell.imageView addGestureRecognizer:cell.singleTap];
            }
        }
        else if([_arrCellType[item] intValue] == 13)
        {
            cell.label.minimumScaleFactor = 0.5;
            cell.label.lineBreakMode = NSLineBreakByTruncatingMiddle;
            if([_arrCellProductType[item] isEqualToString:@"I"] || [_arrCellProductType[item] isEqualToString:@"C"] || [_arrCellProductType[item] isEqualToString:@"P"] || [_arrCellProductType[item] isEqualToString:@"S"] || [_arrCellProductType[item] isEqualToString:@"R"] || [_arrCellProductType[item] isEqualToString:@"U"] || [_arrCellProductType[item] isEqualToString:@"V"])
            {
                [cell addSubview:cell.label];
                cell.label.frame = cell.bounds;
                cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                cell.label.textColor= [UIColor blackColor];
                cell.label.textAlignment = NSTextAlignmentCenter;
                
                UIFont *font2 = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                NSDictionary *arialDict2 = [NSDictionary dictionaryWithObject: font2 forKey:NSFontAttributeName];
                NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:_arrCellData[item] attributes: arialDict2];
                cell.label.attributedText = aAttrString2;
            }
            else if([_arrCellProductType[item] isEqualToString:@"A"] || [_arrCellProductType[item] isEqualToString:@"B"] || [_arrCellProductType[item] isEqualToString:@"D"] || [_arrCellProductType[item] isEqualToString:@"E"] || [_arrCellProductType[item] isEqualToString:@"F"])
            {
                [cell addSubview:cell.label];
                cell.label.frame = cell.bounds;
                cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                cell.label.textColor= [UIColor blackColor];
                cell.label.textAlignment = NSTextAlignmentCenter;
                
                NSDictionary* attributes = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
                NSAttributedString* attrText = [[NSAttributedString alloc] initWithString:_arrCellData[item] attributes:attributes];
                cell.label.attributedText = attrText;
            }
        }
        else if([_arrCellType[item] intValue] == 14)
        {
            [cell addSubview:cell.cellBackground];
            cell.cellBackground.backgroundColor = tTheme;
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
            cell.label.textColor= [UIColor whiteColor];
            cell.label.textAlignment = NSTextAlignmentRight;
            
            
            UIFont *font2 = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
            NSDictionary *arialDict2 = [NSDictionary dictionaryWithObject: font2 forKey:NSFontAttributeName];
            NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:[Utility formatBaht:_arrCellData[item]] attributes: arialDict2];
            cell.label.attributedText = aAttrString2;
        }
        else if([_arrCellType[item] intValue] == 15)
        {
            cell.imageView.userInteractionEnabled = YES;
            [cell addSubview:cell.imageView];
            
            CGRect frame = cell.bounds;
            NSInteger imageSize = 18;
            frame.origin.x = (frame.size.width-imageSize)/2;
            frame.origin.y = (frame.size.height-imageSize)/2;
            frame.size.width = imageSize;
            frame.size.height = imageSize;
            cell.imageView.frame = frame;
            
            
            cell.imageView.tag = item;
            [cell.singleTap removeTarget:self action:@selector(addPostCustomer:)];
            [cell.singleTap removeTarget:self action:@selector(editPostCustomer:)];
            [cell.singleTap removeTarget:self action:@selector(changeProduct:)];
            [cell.singleTap removeTarget:self action:@selector(deleteSales:)];
            [cell.singleTap removeTarget:self action:@selector(postProductItem:)];
            
            NSInteger receiptID = [_arrCellReceiptID[item] integerValue];
            if([self hasPost:receiptID])
            {
                cell.imageView.image = [UIImage imageNamed:@"postCustomer.png"];
                [cell.singleTap addTarget:self action:@selector(editPostCustomer:)];
            }
            else
            {
                cell.imageView.image = [UIImage imageNamed:@"postCustomerNo.png"];
                [cell.singleTap addTarget:self action:@selector(addPostCustomer:)];
            }
            
            
            cell.singleTap.numberOfTapsRequired = 1;
            cell.singleTap.numberOfTouchesRequired = 1;
            [cell.imageView addGestureRecognizer:cell.singleTap];
            
        }
        else if([_arrCellType[item] intValue] == 16)//0=headerCenter,1=detail,2=del,3=post,4=priceHeaderFooter,5=priceItem,6=headerLeft
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
            cell.label.textColor= [UIColor blackColor];
            cell.label.textAlignment = NSTextAlignmentLeft;
            
            UIFont *font2 = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
            NSDictionary *arialDict2 = [NSDictionary dictionaryWithObject: font2 forKey:NSFontAttributeName];
            NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:_arrCellData[item] attributes: arialDict2];
            cell.label.attributedText = aAttrString2;
            
            
            //button print
            //            if(item == 0)
            {
                NSInteger receiptProductItemIndex = [_arrCellReceiptProductItemIndex[item] integerValue];
                ReceiptProductItem *receiptProductItem = _receiptProductItemList[receiptProductItemIndex];
                
                
                
                //            UIButton *btnPrint = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                cell.btnPrint.frame = CGRectMake(cell.frame.size.width-60-8,0, 60, 30);
                cell.btnPrint.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 8);
                cell.btnPrint.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
                [cell.btnPrint setTitle:@"Print" forState:UIControlStateNormal];
                [cell.btnPrint setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [cell.btnPrint setBackgroundColor:[UIColor clearColor]];
                cell.btnPrint.tag = receiptProductItem.receiptID;
                
                [cell.btnPrint addTarget:self action:@selector(printTaxInvoice:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:cell.btnPrint];
            }
        }
        
        return cell;
    }
}
- (BOOL) hasPost:(NSInteger)receiptID
{
//    NSMutableArray *customerReceiptList = [SharedCustomerReceipt sharedCustomerReceipt].customerReceiptList;
    NSMutableArray *customerReceiptList = _customerReceiptListForDate;
    for(CustomerReceipt *item in customerReceiptList)
    {
        if((item.receiptID == receiptID) && (item.postCustomerID == 0))
        {
            return NO;
        }
        else if((item.receiptID == receiptID) && (item.postCustomerID != 0))
        {
            return YES;
        }
    }
    return NO;
}

- (void) editPostCustomer:(UIGestureRecognizer *)gestureRecognizer
{
    UIView* view = gestureRecognizer.view;
    NSInteger item = view.tag;
    _selectedReceiptID = _arrCellReceiptID[item];
    _booAddOrEdit = NO;
    [self performSegueWithIdentifier:@"segPostCustomer" sender:self];
}

- (void) addPostCustomer:(UIGestureRecognizer *)gestureRecognizer
{
    UIView* view = gestureRecognizer.view;
    NSInteger item = view.tag;
    _selectedReceiptID = _arrCellReceiptID[item];
    _booAddOrEdit = YES;
    
    
    [self performSegueWithIdentifier:@"segPostCustomer" sender:self];
}
- (void) postProductItem:(UIGestureRecognizer *)gestureRecognizer {
    //    UIView* view = gestureRecognizer.view;
    //    NSInteger item = view.tag;
    //    NSInteger receiptProductItemIndex = [_arrCellReceiptProductItemIndex[item] integerValue];
    //    ReceiptProductItem *receiptProductItem = _receiptProductItemList[receiptProductItemIndex];
    //    _preOrderProductID = receiptProductItem.productID;
    //    _preOrderReceiptProductItemID = [NSString stringWithFormat:@"%ld",receiptProductItem.receiptProductItemID];
    //
    //    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    //    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    //    [self performSegueWithIdentifier:@"segPreOrderScan" sender:self];
    
    
    //เปลี่ยนจากใช้ post เป็นใช้ดูว่าเอา stock จาก event ไหน ส่งให้ลูกค้า
    if([preOrderEventIDHistoryView isDescendantOfView:self.view])
    {
        [preOrderEventIDHistoryView removeFromSuperview];
    }
    else
    {
        UIView* view = gestureRecognizer.view;
        NSInteger item = view.tag;
        NSInteger receiptProductItemIndex = [_arrCellReceiptProductItemIndex[item] integerValue];
        ReceiptProductItem *receiptProductItem = _receiptProductItemList[receiptProductItemIndex];
        
        
        _preOrderEventIDHistoryList = [self getHistoryWithReceiptProductItemID:receiptProductItem.receiptProductItemID];
        [preOrderEventIDHistoryView reloadData];
        
        
        {
            preOrderEventIDHistoryView.alpha = 0.0;
            [self.view addSubview:preOrderEventIDHistoryView];
            [UIView animateWithDuration:0.2 animations:^{
                preOrderEventIDHistoryView.alpha = 1.0;
            }];
        }
    }
    
    
}
- (void) changeProduct:(UIGestureRecognizer *)gestureRecognizer {
    
    UIView* view = gestureRecognizer.view;
    NSInteger item = view.tag;
    NSInteger receiptProductItemIndex = [_arrCellReceiptProductItemIndex[item] integerValue];
    ReceiptProductItem *receiptProductItem = _receiptProductItemList[receiptProductItemIndex];
    
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
    CustomUICollectionViewCellButton2 *cell = (CustomUICollectionViewCellButton2*)[self.colViewSummaryTable cellForItemAtIndexPath:indexPath];
    
    
    if([receiptProductItem.productType isEqualToString:@"U"] || [receiptProductItem.productType isEqualToString:@"V"])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Cannnot change product"
                                                                       message:@"Product is unidentified"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                              }];
        
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
//                                    Product *product = [self getProduct:receiptProductItem.productID];
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
//                                    CustomMade *customMade = [self getCustomMadeFromProductIDPost:receiptProductItem.productID];
                                    CustomMade *customMade = [[CustomMade alloc]init];
                                    NSString *strCustomMadeID = [NSString stringWithFormat:@"%ld",customMade.customMadeID];
                                    customMade.productIDPost = @"";
                                    customMade.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                                    customMade.modifiedUser = [Utility modifiedUser];
                                    [arrCustomMade addObject:customMade];
                                    
                                    receiptProductItemUpdate.productID = strCustomMadeID;
                                    receiptProductItemUpdate.productType = @"E";
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
    
    
    //////////////ipad
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        [alert setModalPresentationStyle:UIModalPresentationPopover];
        
        UIPopoverPresentationController *popPresenter = [alert
                                                         popoverPresentationController];
        CGRect frame = cell.imageView.bounds;
        frame.origin.y = frame.origin.y-15;
        popPresenter.sourceView = cell.imageView;
        popPresenter.sourceRect = frame;
        //        popPresenter.barButtonItem = _barButtonIpad;
    }
    ///////////////
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) deleteSales:(UIGestureRecognizer *)gestureRecognizer
{
    UIView* view = gestureRecognizer.view;
    NSInteger item = view.tag;
    NSInteger receiptID = [_arrCellReceiptID[item] integerValue];
    CustomerReceipt *customerReceipt = [self getCustomerReceiptWithReceiptID:receiptID];
    PostCustomer *postCustomer = [self getPostCustomer:customerReceipt.postCustomerID];
    
    
    //check ว่าบิลนี้เก็บ point รึเปล่า ถ้าไม่เก็บก็ให้ทำ part delete ได้เลย, ถ้าเก็บ ให้เช็คการใช้แต้มว่าเกินของตัวที่ลบไปหรือไม่
    RewardPoint *rewardPoint = [RewardPoint getRewardPointReceiveWithReceiptID:receiptID];
    if(rewardPoint)
    {
        float pointRemaining = [RewardPoint getRewardPointPointWithCustomerID:postCustomer.customerID];
        
        //คืนค่าแต้มที่เกิดจากบิลที่จะลบกลับไป
        RewardPoint *rewardPointReceive = [RewardPoint getRewardPointReceiveWithReceiptID:receiptID];
        RewardPoint *rewardPointSpent = [RewardPoint getRewardPointSpentWithReceiptID:receiptID];
        if(rewardPointReceive)
        {
            pointRemaining -= rewardPointReceive.point;
        }
        if(rewardPointSpent)
        {
            pointRemaining += rewardPointSpent.point;
        }
        
        
        if(pointRemaining < 0)
        {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Cannot delete"
                                                                           message:@"Point in this bill was used"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action)
                                            {
                                            }];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
    }
    
    
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        CustomUICollectionViewCellButton2 *cell = (CustomUICollectionViewCellButton2*)[self.colViewSummaryTable cellForItemAtIndexPath:indexPath];
        
        
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
                                    NSInteger receiptID = [_arrCellReceiptID[item] integerValue];
                                    _selectedReceiptID = [NSString stringWithFormat:@"%ld", receiptID];
                                    Receipt *receipt = [self getReceipt:receiptID];
                                    CustomerReceipt *customerReceipt = [self getCustomerReceiptWithReceiptID:receiptID];
                                    NSArray *arrReceiptProductItem = [self getReceiptProductItemList:receiptID];
                                    NSArray *arrCustomMade = [self getCustomMadeList:arrReceiptProductItem];
                                    NSArray *arrProduct = [self getProductList:arrReceiptProductItem];
                                    NSMutableArray *arrRewardPoint = [RewardPoint getRewardPointWithReceiptID:receiptID];
                                    [[SharedRewardPoint sharedRewardPoint].rewardPointList removeObjectsInArray:arrRewardPoint];
                                    
//                                    [[SharedReceipt sharedReceipt].receiptList removeObject:receipt];
//                                    [[SharedCustomerReceipt sharedCustomerReceipt].customerReceiptList removeObject:customerReceipt];
//                                    [[SharedReceiptItem sharedReceiptItem].receiptItemList removeObjectsInArray:arrReceiptProductItem];
//                                    [[SharedCustomMade sharedCustomMade].customMadeList removeObjectsInArray:arrCustomMade];
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
                                    
                                    NSArray *arrData = @[receipt,customerReceipt,arrReceiptProductItem,arrCustomMade,updateProductList];
                                    [self loadingOverlayView];
                                    [_homeModel deleteItems:dbReceiptAndReceiptProductItemDelete withData:arrData];
                                    
//                                    [self fetchData];
                                    
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
            CGRect frame = cell.imageView.bounds;
            frame.origin.y = frame.origin.y-15;
            popPresenter.sourceView = cell.imageView;
            popPresenter.sourceRect = frame;
            //        popPresenter.barButtonItem = _barButtonIpad;
        }
        ///////////////
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)itemsDeleted
{
    [self removeOverlayViews];
    if(_homeModel.propCurrentDB == dbReceiptAndReceiptProductItemDelete)
    {
        NSInteger receiptID = [_selectedReceiptID integerValue];
        Receipt *receipt = [self getReceipt:receiptID];
        CustomerReceipt *customerReceipt = [self getCustomerReceiptWithReceiptID:receiptID];
        NSArray *arrReceiptProductItem = [self getReceiptProductItemList:receiptID];
        NSArray *arrCustomMade = [self getCustomMadeList:arrReceiptProductItem];
        NSArray *arrProduct = [self getProductList:arrReceiptProductItem];
       
       
        
        [_receiptListForDate removeObject:receipt];
        [_customerReceiptListForDate removeObject:customerReceipt];
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
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger row = 0;
    if(tableView == customMadeView)
    {
        row = 5;
    }
    else if(tableView == cashAllocationView)
    {
        row = 2;
    }
    else if(tableView == preOrderEventIDHistoryView)
    {
        row = [_preOrderEventIDHistoryList count];
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
    
    if(tableView == customMadeView)
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
        }
    }
    else if(tableView == cashAllocationView)
    {
        switch (indexPath.row) {
            case 0:
            [cell addSubview:_txtChanges];
            break;
            case 1:
            [cell addSubview:_txtTransfer];
            break;
        }
    }
    else if(tableView == preOrderEventIDHistoryView)
    {
        PreOrderEventIDHistory *preOrderEventIDHistory = _preOrderEventIDHistoryList[indexPath.row];
        cell.textLabel.text = [Event getEvent:preOrderEventIDHistory.preOrderEventID].location;
        cell.detailTextLabel.text = [Utility formatDate:preOrderEventIDHistory.modifiedDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd HH:mm"];
    }
    
    return cell;
}
- (void)tableView: (UITableView*)tableView
  willDisplayCell: (UITableViewCell*)cell
forRowAtIndexPath: (NSIndexPath*)indexPath
{
    cell.backgroundColor = [UIColor lightGrayColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
}

- (void) closePreOrderEventIDHistoryView:(id)sender
{
    [preOrderEventIDHistoryView removeFromSuperview];
}

- (void) editCustomMadeDetail:(id)sender
{
    if([customMadeView isDescendantOfView:self.view])
    {
        [customMadeView removeFromSuperview];
        
        if(![self customMadeChanged])
        {
            return;
        }
        
        
//        CustomMade *customMade = [self getCustomMade:_customMadeIDEdit];
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
        
//        [self fetchData];
    }
    else
    {
        UIButton *button = sender;
        NSInteger receiptProductItemIndex = [_arrCellReceiptProductItemIndex[button.tag] integerValue];
        ReceiptProductItem *receiptProductItem = _receiptProductItemList[receiptProductItemIndex];
        
        _customMadeIDEdit = [receiptProductItem.productID integerValue];
        _txtCMSize.text = receiptProductItem.size;
        _txtCMToe.text = receiptProductItem.toe;
        _txtCMBody.text = receiptProductItem.body;
        _txtCMAccessory.text = receiptProductItem.accessory;
        _txtCMRemark.text = receiptProductItem.customMadeRemark;
        [customMadeView reloadData];
        
        
        _customMadeInitial = [[CustomMade alloc]init];
        _customMadeInitial.size = receiptProductItem.size;
        _customMadeInitial.toe = receiptProductItem.toe;
        _customMadeInitial.body = receiptProductItem.body;
        _customMadeInitial.accessory = receiptProductItem.accessory;
        _customMadeInitial.remark = receiptProductItem.customMadeRemark;
        
        {
            customMadeView.alpha = 0.0;
            [self.view addSubview:customMadeView];
            [UIView animateWithDuration:0.2 animations:^{
                customMadeView.alpha = 1.0;
            }];
        }
    }
}

- (void) editCashAllocationEventID:(NSInteger)eventID inputDate:(NSString *)inputDate
{
    if([cashAllocationView isDescendantOfView:self.view])
    {
        [cashAllocationView removeFromSuperview];
        
        if(![self cashAllocationChanged])
        {
            return;
        }
        
        
        //        NSLog([NSString stringWithFormat:@"txtchange:%@",[Utility trimString:_txtChanges.text]]);
        //        NSLog([NSString stringWithFormat:@"txtchange float:%f",[[Utility trimString:_txtChanges.text] floatValue]]);
        NSString *strChangesRemoveComma = [[Utility trimString:_txtChanges.text] stringByReplacingOccurrencesOfString:@"," withString:@""];//[NSString stringWithFormat:@"%f",[[Utility trimString:_txtChanges.text] floatValue]];
        NSString *strTransferRemoveComma = [[Utility trimString:_txtTransfer.text] stringByReplacingOccurrencesOfString:@"," withString:@""];//[NSString stringWithFormat:@"%f",[[Utility trimString:_txtTransfer.text] floatValue]];
        CashAllocation *cashAllocation = [[CashAllocation alloc]init];
        cashAllocation.eventID = _strEventID;
        cashAllocation.inputDate = _strSelectedDateDB;
        cashAllocation.cashChanges = [strChangesRemoveComma floatValue]==0?@"0":strChangesRemoveComma;
        cashAllocation.cashTransfer = [strTransferRemoveComma floatValue]==0?@"0":strTransferRemoveComma;
        [_homeModel updateItems:dbCashAllocationByEventIDAndInputDate withData:cashAllocation];
        
        
        //update shared
        for(CashAllocation *item in [SharedCashAllocation sharedCashAllocation].cashAllocationList)
        {
            if([item.eventID integerValue] == [cashAllocation.eventID integerValue] && [item.inputDate isEqualToString:cashAllocation.inputDate])
            {
                item.cashChanges = cashAllocation.cashChanges;
                item.cashTransfer = cashAllocation.cashTransfer;
                item.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                item.modifiedUser = [Utility modifiedUser];
                break;
            }
        }
        
        //update initial changes, transfer, changes after transer, cash and changes
        //add comma
        NSString *strChanges = [_formatter stringFromNumber:[NSNumber numberWithFloat:[self initialChanges]]];
        [_btnInitialChanges setTitle:strChanges forState:UIControlStateNormal];
        
        
        NSString *strTransfer = [_formatter stringFromNumber:[NSNumber numberWithFloat:[self transfer]]];
        [_btnTransfer setTitle:strTransfer forState:UIControlStateNormal];
        
        
        NSString *strCashAndChanges = [_formatter stringFromNumber:[NSNumber numberWithFloat:[self cashAndChanges]]];
        _lblCashAndChanges.text = strCashAndChanges;
        
        
        _lblFrontInitialChanges.text = @"Initial changes:";
        _lblFrontTransfer.text = @"Transfer";
        _lblFrontCashAndChanges.text = @"Cash+Change:";
    }
    else
    {
        NSMutableArray *cashAllocationList = [SharedCashAllocation sharedCashAllocation].cashAllocationList;
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_eventID = %@ and _inputDate = %@", _strEventID,_strSelectedDateDB];
        NSArray *filterArray = [cashAllocationList filteredArrayUsingPredicate:predicate1];
        CashAllocation *cashAllocation = filterArray[0];
        
        
        
        _txtChanges.text = [Utility formatBaht:cashAllocation.cashChanges];
        _txtTransfer.text = [Utility formatBaht:cashAllocation.cashTransfer];
        
        _txtChanges.frame = CGRectMake(20,7.5,300,25);
        _txtTransfer.frame = CGRectMake(20,7.5,300,25);
        [cashAllocationView reloadData];
        
        
        _cashAllocationInitial = [[CashAllocation alloc]init];
        _cashAllocationInitial.cashChanges = cashAllocation.cashChanges;
        _cashAllocationInitial.cashTransfer = cashAllocation.cashTransfer;
        
        
        {
            cashAllocationView.alpha = 0.0;
            [self.view addSubview:cashAllocationView];
            [UIView animateWithDuration:0.2 animations:^{
                cashAllocationView.alpha = 1.0;
            }];
        }
    }
}

- (void) showProductID:(id)sender
{
    if ([_txvDetail isDescendantOfView:self.view]) {
        [_txvDetail removeFromSuperview];
    }
    else
    {
        UIButton *button = sender;
        NSInteger itemIndexPath = button.tag;
        NSInteger receiptProductItemIndex = [_arrCellReceiptProductItemIndex[itemIndexPath] integerValue];
        ReceiptProductItem * receiptProductItem = _receiptProductItemList[receiptProductItemIndex];
        NSString *productIDLabel = [NSString stringWithFormat:@"ProductID: %@",receiptProductItem.productID];
        
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemIndexPath inSection:0];
        CustomUICollectionViewCellButton2 *cell = (CustomUICollectionViewCellButton2*)[self.colViewSummaryTable cellForItemAtIndexPath:indexPath];
        
        
        CGRect frame = [colViewSummaryTable convertRect:cell.frame toView:self.view];
        _txvDetail.frame = CGRectMake(frame.size.width*3/4+frame.origin.x, frame.size.height*3/4+frame.origin.y, 120, 30);
        _txvDetail.backgroundColor = [UIColor lightGrayColor];
        _txvDetail.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
        _txvDetail.text = productIDLabel;
        [self.view addSubview:_txvDetail];
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segPostCustomer"])
    {
        PostCustomer *postCustomer = [self getPostCustomer:[self getPostCustomerID:[_selectedReceiptID integerValue]]];
        AddEditPostCustomerViewController *vc = segue.destinationViewController;
        vc.paid = YES;
        vc.booAddOrEdit = _booAddOrEdit;
        vc.telephoneNoSearch = postCustomer.telephone;
        vc.postCustomerID = postCustomer.postCustomerID;
        vc.receiptID = [_selectedReceiptID integerValue];
        
        vc.selectedCustomerReceipt = [self getCustomerReceiptWithReceiptID:[_selectedReceiptID integerValue]];
        vc.selectedPostCustomer = postCustomer;
    }
    else if ([[segue identifier] isEqualToString:@"segPreOrderScan"])
    {
        // Get reference to the destination view controller
        PreOrderScanViewController *vc = segue.destinationViewController;
        
        // Pass any objects to the view controller here, like...
        vc.preOrderProductID = _preOrderProductID;
        vc.preOrderReceiptProductItemID = _preOrderReceiptProductItemID;
    }
    else if([[segue identifier] isEqualToString:@"segAccountReceiptPDF"])
    {
        AccountReceiptPDFViewController *vc = segue.destinationViewController;
        vc.saleProductAndPriceList = _salesProductAndPriceBillingsOnlyList;
        vc.accountInventorySummaryList = _accountInventorySummaryList;
        vc.dateOut = _dateOut;
        vc.sendMail = 1;
    }
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if(_booShortOrDetail)
    {
        CGFloat width;
        NSArray *arrSize;
        //@[@"No.",@"Item",@"Color",@"Size",@"Cash",@"Credit"];
        arrSize = @[@26,@0,@60,@30,@60,@60];
        
        
        width = [arrSize[indexPath.item%[arrSize count]] floatValue];
        if(width == 0)
        {
            width = colViewSummaryTable.bounds.size.width;
            for(int i=0; i<[arrSize count]; i++)
            {
                width = width - [arrSize[i] floatValue];
            }
        }
        
        
        CGSize size = CGSizeMake(width, 30);
        return size;
    }
    else
    {
        CGFloat width = [_arrCellSize[indexPath.row] floatValue];
        CGSize size = CGSizeMake(width, 30);
        return size;
    }
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    //    return UIEdgeInsetsMake(0, 20, 0, 20);//top, left, bottom, right -> collection view
    return UIEdgeInsetsMake(0, 0, 0, 0);//top, left, bottom, right -> collection view
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

- (NSMutableAttributedString *)getStringWithHeaderBold:(NSString *)header content:(NSString *)content
{
    UIFont *font1 = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    NSDictionary *arialDict = [NSDictionary dictionaryWithObject: font1 forKey:NSFontAttributeName];
    NSMutableAttributedString *aAttrString1 = [[NSMutableAttributedString alloc] initWithString:header attributes: arialDict];
    
    UIFont *font2 = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
    NSDictionary *arialDict2 = [NSDictionary dictionaryWithObject: font2 forKey:NSFontAttributeName];
    NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:content attributes: arialDict2];
    [aAttrString1 appendAttributedString:aAttrString2];
    return  aAttrString1;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        
        CGFloat yPosition = 0;
        
        float widthSubview = headerView.bounds.size.width;
        float xOrigin = widthSubview/2+20;
        float widthLeftLabel = widthSubview/2-20;
        
        //align right
        _lblTotalCredit.frame = CGRectMake(0, yPosition+20, widthSubview, 20);
        _lblTotalCash.frame = CGRectMake(0, yPosition+40, widthSubview, 20);
        _lblTotalAmount.frame = CGRectMake(0, yPosition+60, widthSubview, 20);
        _lblFrontTotalCredit.frame = CGRectMake(xOrigin, yPosition+20, widthSubview, 20);
        _lblFrontTotalCash.frame = CGRectMake(xOrigin, yPosition+40, widthSubview, 20);
        _lblFrontTotalAmount.frame = CGRectMake(xOrigin, yPosition+60, widthSubview, 20);
        
        
        //align left
        _btnInitialChanges.frame = CGRectMake(0, yPosition+20, widthLeftLabel, 20);
        _btnTransfer.frame = CGRectMake(0, yPosition+40, widthLeftLabel, 20);
        _lblCashAndChanges.frame = CGRectMake(0, yPosition+60, widthLeftLabel, 20);
        _btnInitialChanges.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _btnTransfer.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _lblCashAndChanges.textAlignment = NSTextAlignmentRight;
        
        
        _lblFrontInitialChanges.frame = CGRectMake(0, yPosition+20, widthSubview, 20);
        _lblFrontTransfer.frame = CGRectMake(0, yPosition+40, widthSubview, 20);
        _lblFrontCashAndChanges.frame = CGRectMake(0, yPosition+60, widthSubview, 20);
        _lblFrontInitialChanges.textAlignment = NSTextAlignmentLeft;
        _lblFrontTransfer.textAlignment = NSTextAlignmentLeft;
        _lblFrontCashAndChanges.textAlignment = NSTextAlignmentLeft;
        
        
        
        //add comma
        NSString *strTotalCredit = [_formatter stringFromNumber:[NSNumber numberWithFloat:[self totalCredit]]];
        NSString *strTotalCash = [_formatter stringFromNumber:[NSNumber numberWithFloat:[self totalCash]]];
        NSString *strTotalAmount = [_formatter stringFromNumber:[NSNumber numberWithFloat:[self totalAmount]]];
        
        
        _lblTotalCredit.text = strTotalCredit;
        _lblTotalCash.text = strTotalCash;
        _lblTotalAmount.text = strTotalAmount;
        
        _lblFrontTotalCredit.text = @"Total credit:";
        _lblFrontTotalCash.text = @"Total cash:";
        _lblFrontTotalAmount.text = @"Total amount:";
        
        
        
        //add comma
        NSString *strChanges = [_formatter stringFromNumber:[NSNumber numberWithFloat:[self initialChanges]]];
        [_btnInitialChanges setTitle:strChanges forState:UIControlStateNormal];
        
        NSString *strTransfer = [_formatter stringFromNumber:[NSNumber numberWithFloat:[self transfer]]];
        [_btnTransfer setTitle:strTransfer forState:UIControlStateNormal];
        
        NSString *strCashAndChanges = [_formatter stringFromNumber:[NSNumber numberWithFloat:[self cashAndChanges]]];
        _lblCashAndChanges.text = strCashAndChanges;
        
        _lblFrontInitialChanges.text = @"Initial changes:";
        _lblFrontTransfer.text = @"Transfer:";
        _lblFrontCashAndChanges.text = @"Cash+changes:";
        
        
        [headerView addSubview:_lblTotalCredit];
        [headerView addSubview:_lblTotalCash];
        [headerView addSubview:_lblTotalAmount];
        [headerView addSubview:_lblFrontTotalCredit];
        [headerView addSubview:_lblFrontTotalCash];
        [headerView addSubview:_lblFrontTotalAmount];
        
        
        [headerView addSubview:_btnInitialChanges];
        [headerView addSubview:_btnTransfer];
        [headerView addSubview:_lblCashAndChanges];
        [headerView addSubview:_lblFrontInitialChanges];
        [headerView addSubview:_lblFrontTransfer];
        [headerView addSubview:_lblFrontCashAndChanges];
        
        
        
        reusableview = headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        
        reusableview = footerview;
    }
    
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
{
    CGSize headerSize = CGSizeMake(collectionView.bounds.size.width, 80);
    return headerSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    CGSize footerSize = CGSizeMake(collectionView.bounds.size.width, 0);
    return footerSize;
}

- (float)totalCredit
{
    float totalCredit = 0;
    for(Receipt *item in _receiptList)
    {
        if([item.paymentMethod isEqualToString:@"CC"] || [item.paymentMethod isEqualToString:@"BO"])
        {
            totalCredit += [item.creditAmount floatValue];
        }
    }
    return totalCredit;
}

- (float)totalCash
{
    float totalCash = 0;
    for(Receipt *item in _receiptList)
    {
        if([item.paymentMethod isEqualToString:@"CA"] || [item.paymentMethod isEqualToString:@"BO"])
        {
            totalCash += [item.cashAmount floatValue];
        }
    }
    return totalCash;
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
    return [self totalCash]+[self initialChanges]-[self transfer];
}
- (float)initialChanges
{
    NSInteger eventID = [SharedSelectedEvent sharedSelectedEvent].event.eventID;
    NSString *strEventID = [NSString stringWithFormat:@"%ld",eventID];
    NSMutableArray *cashAllocationList = [SharedCashAllocation sharedCashAllocation].cashAllocationList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_eventID = %@ and _inputDate = %@",strEventID,_strSelectedDateDB];
    NSArray *filterArray = [cashAllocationList filteredArrayUsingPredicate:predicate1];
    if([filterArray count]==0)
    {
        return 0;
    }
    CashAllocation *cashAllocation = filterArray[0];
    return [cashAllocation.cashChanges floatValue];
}
- (float)transfer
{
    NSInteger eventID = [SharedSelectedEvent sharedSelectedEvent].event.eventID;
    NSString *strEventID = [NSString stringWithFormat:@"%ld",eventID];
    NSMutableArray *cashAllocationList = [SharedCashAllocation sharedCashAllocation].cashAllocationList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_eventID = %@ and _inputDate = %@",strEventID,_strSelectedDateDB];
    NSArray *filterArray = [cashAllocationList filteredArrayUsingPredicate:predicate1];
    if([filterArray count]==0)
    {
        return 0;
    }
    CashAllocation *cashAllocation = filterArray[0];
    return [cashAllocation.cashTransfer floatValue];
}
- (float)changesAfterTransfer
{
    //cash and changes minus transfer amount
    //    NSString *strTransfer = [_btnTransfer.titleLabel.text stringByReplacingOccurrencesOfString:@"Transfer: " withString:@""];
    float changesAfterTransfer = [self cashAndChanges]-[self transfer];//[strTransfer floatValue];
    return changesAfterTransfer;
}

- (void)itemsInserted
{
    
}

-(void)itemsUpdated
{
    [self removeOverlayViews];
    if(_homeModel.propCurrentDB == dbReceipt)
    {
        //update remark success
        Receipt *receipt = [self getReceipt:_receiptRemark.receiptID];
        receipt.remark = _receiptRemark.remark;
        [self setData];
    }
    else if(_homeModel.propCurrentDB == dbCustomMade)
    {
        CustomMade *customMade = [self getCustomMade:_customMadeIDEdit];
//        CustomMade *customMade = [[CustomMade alloc]init];
        customMade.customMadeID = _customMadeIDEdit;
        customMade.size = _txtCMSize.text;
        customMade.toe = _txtCMToe.text;
        customMade.body = _txtCMBody.text;
        customMade.accessory = _txtCMAccessory.text;
        customMade.remark = _txtCMRemark.text;
//        customMade.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
//        customMade.modifiedUser = [Utility modifiedUser];

        [self setData];
    }
    else if(_homeModel.propCurrentDB == dbReceiptProductItemAndProductUpdate)
    {
        
    }
}
-(void)itemsUpdatedWithReturnData:(NSArray *)data
{
    if(_homeModel.propCurrentDB == dbReceiptProductItemAndProductUpdate)
    {
        [self removeOverlayViews];
        NSMutableArray *returnProductList = data[0];
        NSMutableArray *returnCustomMadeList = data[1];
        NSMutableArray *returnReceiptProductItemList = data[2];
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
    }
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
    
    [_txvDetail removeFromSuperview];
    [customMadeView removeFromSuperview];
    [cashAllocationView removeFromSuperview];
    [preOrderEventIDHistoryView removeFromSuperview];
    
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
    [self.colViewSummaryTable reloadData];
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

-(void)refreashControlAction{
    _refreshingControl = YES;
//    [_homeModel downloadItems:dbMaster];
    
}

-(void)addRefreshControl{
    if (!self.refreshControl) {
        self.refreshControl                  = [UIRefreshControl new];
        self.refreshControl.tintColor        = [UIColor grayColor];
        [self.refreshControl addTarget:self
                                action:@selector(refreashControlAction)
                      forControlEvents:UIControlEventValueChanged];
    }
    if (![self.refreshControl isDescendantOfView:self.colViewSummaryTable]) {
        [self.colViewSummaryTable addSubview:self.refreshControl];
    }
}

-(void)startRefreshControl{
    if (!self.refreshControl.refreshing) {
        [self.refreshControl beginRefreshing];
    }
}

- (void)itemsFail
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[Utility getConnectionLostTitle]
                                                                   message:[Utility getConnectionLostMessage]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [self loadingOverlayView];
                                                              //                                                              [self loadViewProcess];
                                                              //                                                              [self removeOverlayViews];
//                                                              [_homeModel downloadItems:dbMaster];
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

- (void)printTaxInvoice:(id)sender
{
    
    UIButton *button = sender;
    NSInteger receiptID = button.tag;
    Receipt *receipt = [self getReceipt:receiptID];
    _selectedPrintReceipt = receipt;
    
    
    NSString *strReceiptDate = [Utility formatDate:receipt.receiptDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd"];
    NSString *currentDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd"];
    if(![strReceiptDate isEqualToString:currentDate])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                       message:@"Can print today receipt only"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    
    //ถ้าเคย generate แล้ว ไม่ต้อง gen ซ้ำ ให้เอาข้อมูลที่ gen มาแสดงเลย
    //ถ้าไม่เคย gen
    [self loadingOverlayView];
    [_homeModel downloadItems:dbAccountReceipt condition:receipt];
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

- (NSInteger) getPostCustomerID:(NSInteger)receiptID
{
    NSMutableArray *customerReceiptList = _customerReceiptListForDate;
    for(CustomerReceipt *item in customerReceiptList)
    {
        if(item.receiptID == receiptID)
        {
            return item.postCustomerID;
        }
    }
    return 0;
}

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

-(CustomerReceipt *)getCustomerReceiptWithReceiptID:(NSInteger)receiptID
{
    NSMutableArray *customerReceiptList = _customerReceiptListForDate;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_receiptID = %ld",receiptID];
    NSArray *filterArray = [customerReceiptList filteredArrayUsingPredicate:predicate1];
    
    if([filterArray count]>0)
    {
        return filterArray[0];
    }
    return nil;
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

- (NSArray *)getCustomMadeList:(NSArray *)receiptProductItemList
{
    NSMutableArray *customMadeList = [[NSMutableArray alloc]init];
    for(ReceiptProductItem *item in receiptProductItemList)
    {
        if([item.productType isEqualToString:@"C"] || [item.productType isEqualToString:@"B"] || [item.productType isEqualToString:@"E"])
        {
            CustomMade *customMade = [self getCustomMade:[item.productID integerValue]];
            [customMadeList addObject:customMade];
        }
        else if([item.productType isEqualToString:@"R"])
        {
            CustomMade *customMade = [self getCustomMadeFromProductIDPost:item.productID];
            [customMadeList addObject:customMade];
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
            [productList addObject:product];
        }
    }
    return productList;
}
@end
