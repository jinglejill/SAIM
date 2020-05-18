//
//  ChartSalesByItemViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/18/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "ChartSalesByItemViewController.h"
#import "SharedSalesByItemData.h"
#import "SalesByItemData.h"
#import "SharedSelectedEvent.h"
#import "SalesByItemData.h"
#import "ReceiptProductItem.h"
#import "Receipt.h"
#import "Utility.h"
#import "ProductCost.h"
#import "SharedReceiptItem.h"
#import "SharedReceipt.h"
#import "SharedProduct.h"
#import "SharedCustomMade.h"
#import "ProductName.h"


@interface ChartSalesByItemViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSMutableArray *_salesByItemDataList;
    NSMutableArray *_salesByItemDataListTemp;
    Event *_event;
    NSString *_strEventID;
}
@property (strong, nonatomic) IBOutlet UISegmentedControl *segConType;
@property (nonatomic, strong) IBOutlet CPTGraphHostingView *hostView;
@property (nonatomic, strong) CPTBarPlot *salesByItemPlot;
@property (nonatomic, strong) NSMutableArray *arrValueAnnotation;
@property (nonatomic, strong) NSMutableArray *arrLabelAnnotation;
- (IBAction)segConChanged:(id)sender;

-(void)initPlot;
-(void)configureGraph;
-(void)configurePlots;
-(void)configureAxes;
@end

extern BOOL globalRotateFromSeg;
@implementation ChartSalesByItemViewController

@synthesize hostView;
@synthesize salesByItemPlot;
@synthesize arrValueAnnotation;
@synthesize arrLabelAnnotation;
@synthesize segConType;
@synthesize lblTotal;
@synthesize dtPicker;
@synthesize txtStartDate;
@synthesize txtEndDate;


#pragma mark - UIViewController lifecycle methods

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self loadData];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField;
{
    NSString *strDate = textField.text;
    NSDate *datePeriod = [Utility stringToDate:strDate fromFormat:@"yyyy-MM-dd"];
    [dtPicker setDate:datePeriod];
}

- (IBAction)datePickerChanged:(id)sender
{
    if([txtStartDate isFirstResponder])
    {
        txtStartDate.text = [Utility dateToString:dtPicker.date toFormat:@"yyyy-MM-dd"];
    }
    else if([txtEndDate isFirstResponder])
    {
        txtEndDate.text = [Utility dateToString:dtPicker.date toFormat:@"yyyy-MM-dd"];
    }
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGRect frame = segConType.frame;
    frame.size.width = 300;
    segConType.frame = frame;
    segConType.center = CGPointMake(self.view.frame.size.width/2, segConType.frame.origin.y+segConType.frame.size.height/2);

}
- (void)loadView {
    [super loadView];
    // Do any additional setup after loading the view.
    
    [dtPicker removeFromSuperview];
    txtStartDate.inputView = dtPicker;
    txtStartDate.delegate = self;
    
    txtEndDate.inputView = dtPicker;
    txtEndDate.delegate = self;
    
    txtStartDate.text = [Utility dateToString:[Utility addDay:[Utility currentDateTime]  numberOfDay:-6] toFormat:@"yyyy-MM-dd"];
    txtEndDate.text = [Utility dateToString:[Utility currentDateTime] toFormat:@"yyyy-MM-dd"];
    
    
    CGRect frame = segConType.frame;
    frame.size.width = self.view.frame.size.width/3;
    segConType.frame = frame;
    
    
    
    
    _homeModel = [[HomeModel alloc] init];
    _homeModel.delegate = self;
    
    {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);
    }
    
    
    _event = [Event getSelectedEvent];
    _strEventID = [NSString stringWithFormat:@"%ld",_event.eventID];
    _salesByItemDataList = [[NSMutableArray alloc]init];
    _salesByItemDataListTemp = [[NSMutableArray alloc]init];
    
    //tabbar title font size
    for(UIViewController *tab in  self.tabBarController.viewControllers)
    {
        [tab.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIFont fontWithName:@"Helvetica" size:16.0], NSFontAttributeName, nil]
                                      forState:UIControlStateNormal];
        [tab.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -14)];
    }
    
    self.navigationController.topViewController.title = @"Sales Chart by Type";
}

-(void)loadData
{
    [self loadingOverlayView];
    [_homeModel downloadItems:dbSalesSummaryByEventByPeriod condition:@[_event,txtStartDate.text,txtEndDate.text]];
}

- (void)itemsDownloaded:(NSArray *)items
{
    int i=0;
    [SharedProduct sharedProduct].productList = items[i++];
    [SharedReceipt sharedReceipt].receiptList = items[i++];
    [SharedReceiptItem sharedReceiptItem].receiptItemList = items[i++];
    [SharedCustomMade sharedCustomMade].customMadeList = items[i++];
    
    
    dispatch_async(dispatch_get_main_queue(),^ {
        [self removeOverlayViews];
        [self setData];
        [self initPlot];
    } );
}

-(void)setData
{
    {
        //prepare receiptproductitem to include event and productcost
        NSMutableArray *receiptProductItemList = [SharedReceiptItem sharedReceiptItem].receiptItemList;
        for(ReceiptProductItem *item in receiptProductItemList)
        {
            ProductSales *productSalesCost = [Utility getProductCost:item.productType productID:item.productID];
            Receipt *receipt = [Utility getReceipt:item.receiptID];
            item.eventID = receipt.eventID;
            item.itemCost = productSalesCost.cost;
            //I=Inventory,C=Custom made,A=change I,B=change C,P=preorder,D=change P,S=post preorder
            if(item.isPreOrder2)
            {
                ProductName *productName = [ProductName getProductName:item.preOrder2ProductNameID];
                item.productName = productName.name;
            }
            else if([item.productType isEqualToString:@"I"] || [item.productType isEqualToString:@"P"] || [item.productType isEqualToString:@"S"] || [item.productType isEqualToString:@"A"] || [item.productType isEqualToString:@"D"] || [item.productType isEqualToString:@"F"])
            {
                Product *product = [Product getProduct:item.productID];
                ProductName *productName = [ProductName getProductNameWithProductID:product.productID];
                item.productName = productName.name;
            }
            else if([item.productType isEqualToString:@"C"] || [item.productType isEqualToString:@"B"])
            {
                CustomMade *customMade = [Utility getCustomMade:[item.productID integerValue]];
                NSString *productNameGroup = [NSString stringWithFormat:@"%@%@%@",customMade.productCategory2,customMade.productCategory1,customMade.productName];
                NSString *customMadeProductName = [ProductName getNameWithProductNameGroup:productNameGroup];
                item.productName = customMadeProductName;
            }
            else if([item.productType isEqualToString:@"R"] || [item.productType isEqualToString:@"E"])
            {
                CustomMade *customMade = [Utility getCustomMadeFromProductIDPost:item.productID];
                NSString *productNameGroup = [NSString stringWithFormat:@"%@%@%@",customMade.productCategory2,customMade.productCategory1,customMade.productName];
                item.productName = [ProductName getNameWithProductNameGroup:productNameGroup];
            }
        }
        
//        //filter by event
//        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_eventID = %@",_strEventID];
//        NSArray *filteredArray = [receiptProductItemList filteredArrayUsingPredicate:predicate1];
//        receiptProductItemList = [filteredArray mutableCopy];
        
        //sort by productname
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_productName" ascending:NO];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
        NSArray *sortArray = [receiptProductItemList sortedArrayUsingDescriptors:sortDescriptors];
        receiptProductItemList = [sortArray mutableCopy];
        
        //count pair and sumValue
        NSInteger countItem = 0;
        float sumValue = 0.0f;
        float sumCost = 0.0f;
        NSString *previousProductName = @"";
        [_salesByItemDataListTemp removeAllObjects];
        for(ReceiptProductItem *item in receiptProductItemList)
        {
            if([previousProductName isEqualToString:@""])
            {
                countItem += 1;
                sumValue += [item.priceSales floatValue];
                sumCost += [item.itemCost floatValue];
            }
            else if(![previousProductName isEqualToString:item.productName])
            {
                SalesByItemData *salesByItem = [[SalesByItemData alloc]init];
                salesByItem.eventID = item.eventID;
                salesByItem.item = previousProductName;
                salesByItem.intNoOfPair = countItem;
                salesByItem.floatSumValue = sumValue;
                salesByItem.floatSumMargin = sumValue - sumCost;
                
                [_salesByItemDataListTemp addObject:salesByItem];
                countItem = 1;
                sumValue = [item.priceSales floatValue];
                sumCost = [item.itemCost floatValue];
            }
            else if([previousProductName isEqualToString:item.productName])
            {
                countItem += 1;
                sumValue += [item.priceSales floatValue];
                sumCost += [item.itemCost floatValue];
            }
            previousProductName = item.productName;
        }
        
        NSString *strEventID = [NSString stringWithFormat:@"%ld",_event.eventID];
        SalesByItemData *salesByItem = [[SalesByItemData alloc]init];
        salesByItem.eventID = strEventID;
        salesByItem.item = previousProductName;
        salesByItem.intNoOfPair = countItem;
        salesByItem.floatSumValue = sumValue;
        salesByItem.floatSumMargin = sumValue - sumCost;
        [_salesByItemDataListTemp addObject:salesByItem];
    }

    
    [self sortByNoOfPair];
    [self showEightThOutOfTenNoOfPair];
    lblTotal.text = [NSString stringWithFormat:@"%d",[self getTotalNoOfPair]];
}

-(void)sortByNoOfPair
{
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_intNoOfPair" ascending:NO];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_item" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2, nil];
    NSArray *sortArray = [_salesByItemDataListTemp sortedArrayUsingDescriptors:sortDescriptors];
    _salesByItemDataListTemp = [sortArray mutableCopy];
}

-(void)sortBySumValue
{
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_floatSumValue" ascending:NO];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_item" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2, nil];
    NSArray *sortArray = [_salesByItemDataListTemp sortedArrayUsingDescriptors:sortDescriptors];
    _salesByItemDataListTemp = [sortArray mutableCopy];
}

-(void)sortBySumMargin
{
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_floatSumMargin" ascending:NO];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_item" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2, nil];
    NSArray *sortArray = [_salesByItemDataListTemp sortedArrayUsingDescriptors:sortDescriptors];
    _salesByItemDataListTemp = [sortArray mutableCopy];
}

-(int)getTotalNoOfPair
{
    float total = 0;
    for(SalesByItemData *item in _salesByItemDataListTemp)
    {
        total += item.intNoOfPair;
    }
    return total;
}

-(float)getTotalSumValue
{
    float total = 0;
    for(SalesByItemData *item in _salesByItemDataListTemp)
    {
        total += item.floatSumValue;
    }
    return total;
}

-(float)getTotalSumMargin
{
    float total = 0;
    for(SalesByItemData *item in _salesByItemDataListTemp)
    {
        total += item.floatSumMargin;
    }
    return total;
}

-(void)showEightThOutOfTenNoOfPair
{
    //show only 80%
    int noOfPairOthers = 0;
    float sumValueOthers = 0;
    float sumMarginOthers = 0;
    float accumAmount = 0;
    int totalAmount = [self getTotalNoOfPair];
    float eightThOutOfTenAmount = 0.8*totalAmount;
    [_salesByItemDataList removeAllObjects];
    for(SalesByItemData *item in _salesByItemDataListTemp)
    {
        if(accumAmount <= eightThOutOfTenAmount)
        {
            [_salesByItemDataList addObject:item];
            accumAmount += item.intNoOfPair;
        }
        else
        {
            noOfPairOthers += item.intNoOfPair;
            sumValueOthers += item.floatSumValue;
            sumMarginOthers += item.floatSumMargin;
        }
        
        if(accumAmount > eightThOutOfTenAmount)
        {
            continue;
        }
    }
    
    SalesByItemData *salesByItem = [[SalesByItemData alloc]init];
    salesByItem.eventID = _strEventID;
    salesByItem.item = @"Others";
    salesByItem.intNoOfPair = noOfPairOthers;
    salesByItem.floatSumValue = sumValueOthers;
    salesByItem.floatSumMargin = sumMarginOthers;
    [_salesByItemDataList addObject:salesByItem];
}

-(void)showEightThOutOfTenSumValue
{
    //show only 80%
    int noOfPairOthers = 0;
    float sumValueOthers = 0;
    float sumMarginOthers = 0;
    float accumAmount = 0;
    float totalAmount = [self getTotalSumValue];
    float eightThOutOfTenAmount = 0.8*totalAmount;
    [_salesByItemDataList removeAllObjects];
    for(SalesByItemData *item in _salesByItemDataListTemp)
    {
        if(accumAmount <= eightThOutOfTenAmount)
        {
            [_salesByItemDataList addObject:item];
            accumAmount += item.floatSumValue;
        }
        else
        {
            noOfPairOthers += item.intNoOfPair;
            sumValueOthers += item.floatSumValue;
            sumMarginOthers += item.floatSumMargin;
        }
        
        if(accumAmount > eightThOutOfTenAmount)
        {
            continue;
        }
    }
    
    SalesByItemData *salesByItem = [[SalesByItemData alloc]init];
    salesByItem.eventID = _strEventID;
    salesByItem.item = @"Others";
    salesByItem.intNoOfPair = noOfPairOthers;
    salesByItem.floatSumValue = sumValueOthers;
    salesByItem.floatSumMargin = sumMarginOthers;
    [_salesByItemDataList addObject:salesByItem];
}

-(void)showEightThOutOfTenSumMargin
{
    //show only 80%
    int noOfPairOthers = 0;
    float sumValueOthers = 0;
    float sumMarginOthers = 0;
    float accumAmount = 0;
    float totalAmount = [self getTotalSumMargin];
    float eightThOutOfTenAmount = 0.8*totalAmount;
    [_salesByItemDataList removeAllObjects];
    for(SalesByItemData *item in _salesByItemDataListTemp)
    {
        if(accumAmount <= eightThOutOfTenAmount)
        {
            [_salesByItemDataList addObject:item];
            accumAmount += item.floatSumMargin;
        }
        else
        {
            noOfPairOthers += item.intNoOfPair;
            sumValueOthers += item.floatSumValue;
            sumMarginOthers += item.floatSumMargin;
        }
        
        if(accumAmount > eightThOutOfTenAmount)
        {
            continue;
        }
    }
    
    SalesByItemData *salesByItem = [[SalesByItemData alloc]init];
    salesByItem.eventID = _strEventID;
    salesByItem.item = @"Others";
    salesByItem.intNoOfPair = noOfPairOthers;
    salesByItem.floatSumValue = sumValueOthers;
    salesByItem.floatSumMargin = sumMarginOthers;
    [_salesByItemDataList addObject:salesByItem];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    
//    [self loadData];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                    style:UIBarButtonItemStylePlain target:self action:@selector(backToPreviousPage)];
    self.tabBarController.navigationItem.leftBarButtonItem = leftButton;
    [self loadData];
}

#pragma mark - Chart behavior
-(void)initPlot {
    arrValueAnnotation = nil;
    arrLabelAnnotation = nil;
    self.hostView.allowPinchScaling = NO;
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
}

-(void)configureGraph {
    // 1 - Create the graph
//    NSLog([NSString stringWithFormat:@"hostview y: %f",self.hostView.bounds.origin.y]);
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    graph.plotAreaFrame.masksToBorder = NO;
    self.hostView.hostedGraph = graph;
    // 2 - Configure the graph
    [graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    graph.paddingBottom = 38.0f;
    graph.paddingLeft  = 13.0f;
    graph.paddingTop    = -1.0f;
    graph.paddingRight  = 13.0f;
    // 3 - Set up styles
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor blackColor];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 14.0f;
    // 4 - Set up title
    NSString *title = @"Sales by Item";
    graph.title = title;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, -16.0f);
    // 5 - Set up plot space
    CGFloat xMin = 0.0f;
    CGFloat xMax = [_salesByItemDataList count];
    CGFloat yMin = 0.0f;
    

    float maxValue;
    if(segConType.selectedSegmentIndex==0){maxValue = [self getMaxNoOfPair];}
    else if(segConType.selectedSegmentIndex==1){maxValue = [self getMaxSumValue];}
    else if(segConType.selectedSegmentIndex==2){maxValue = [self getMaxSumMargin];}
    CGFloat yMax = maxValue*1.5;// should determine dynamically based on max price
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xMin) length:CPTDecimalFromFloat(xMax)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(yMin) length:CPTDecimalFromFloat(yMax)];
}

-(void)configurePlots {
    // 1 - Set up the three plots
    //tBlue color
    CPTColor *cptColor = [CPTColor colorWithComponentRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1];
    CPTBarPlot *barPlot = [[CPTBarPlot alloc]init];
    barPlot.fill =  [CPTFill fillWithColor:cptColor];
    
    self.salesByItemPlot = barPlot;
    self.salesByItemPlot.identifier = CPDSalesByCat;
    // 2 - Set up line style
    CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
    barLineStyle.lineColor = cptColor;
    barLineStyle.lineWidth = 0.5;
    // 3 - Add plots to graph
    CPTGraph *graph = self.hostView.hostedGraph;
    CGFloat barX = CPDBarInitialX;
    NSArray *plots = [NSArray arrayWithObjects:self.salesByItemPlot, nil];
    for (CPTBarPlot *plot in plots) {
        plot.dataSource = self;
        plot.delegate = self;
        plot.barWidth = CPTDecimalFromDouble(CPDBarWidth);
        plot.barOffset = CPTDecimalFromDouble(barX);
        plot.lineStyle = barLineStyle;
        [graph addPlot:plot toPlotSpace:graph.defaultPlotSpace];
        
        
        //initial annotation for value
        if(arrValueAnnotation == nil && [_salesByItemDataList count]>0)
        {
            arrValueAnnotation = [[NSMutableArray alloc]init];
            for(int index=0; index<[_salesByItemDataList count]; index++)
            {
                NSNumber *x = [NSNumber numberWithInt:0];
                NSNumber *y = [NSNumber numberWithInt:0];
                NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
                CPTPlotSpaceAnnotation *priceAnnotation = (CPTPlotSpaceAnnotation*)[[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:plot.plotSpace anchorPlotPoint:anchorPoint];
                
                [arrValueAnnotation addObject:priceAnnotation];
            }
        }
        //initial annotation for label x axis
        if(arrLabelAnnotation == nil && [_salesByItemDataList count]>0)
        {
            arrLabelAnnotation = [[NSMutableArray alloc]init];
            for(int index=0; index<[_salesByItemDataList count]; index++)
            {
                NSNumber *x = [NSNumber numberWithInt:0];
                NSNumber *y = [NSNumber numberWithInt:0];
                NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
                CPTPlotSpaceAnnotation *labelAnnotation = (CPTPlotSpaceAnnotation*)[[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:plot.plotSpace anchorPlotPoint:anchorPoint];
                
                [arrLabelAnnotation addObject:labelAnnotation];
            }
        }

        //annotation for value
        for(int index=0; index<[_salesByItemDataList count]; index++)
        {
            // 1 - Is the plot hidden?
            if (plot.isHidden == YES) {
                return;
            }
            // 2 - Create style, if necessary
            static CPTMutableTextStyle *style = nil;
            if (!style) {
                style = [CPTMutableTextStyle textStyle];
                CPTColor *cptColor = [CPTColor blackColor];
                style.color= cptColor;
                style.fontSize = 12.0f;
                style.fontName = @"HelveticaNeue-Medium";
            }
            // 3 - Create annotation, if necessary
            NSNumber *value = [self numberForPlot:plot field:CPTBarPlotFieldBarTip recordIndex:index];
            CPTPlotSpaceAnnotation *priceAnnotation = self.arrValueAnnotation[index];
            
            
            // 4 - Create number formatter, if needed
            static NSNumberFormatter *formatter = nil;
            if (!formatter) {
                formatter = [[NSNumberFormatter alloc] init];
                formatter.numberStyle = NSNumberFormatterDecimalStyle;
            }
            // 5 - Create text layer for annotation
            NSString *strValue = [formatter stringFromNumber:value];
            CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:strValue style:style];
            priceAnnotation.contentLayer = textLayer;
            // 6 - Get plot index based on identifier
            NSInteger plotIndex = 0;
            if ([plot.identifier isEqual:CPDSalesByCat] == YES) {
                plotIndex = 0;
            }
            // 7 - Get the anchor point for annotation
            CGFloat x = index + CPDBarInitialX + (plotIndex * CPDBarWidth);
            NSNumber *anchorX = [NSNumber numberWithFloat:x];
            
            float maxValue;
            if(segConType.selectedSegmentIndex==0){maxValue = [self getMaxNoOfPair];}
            else if(segConType.selectedSegmentIndex==1){maxValue = [self getMaxSumValue];}
            else if(segConType.selectedSegmentIndex==2){maxValue = [self getMaxSumMargin];}
            CGFloat y = [value floatValue] + .05*maxValue;              
            
            NSNumber *anchorY = [NSNumber numberWithFloat:y];
            priceAnnotation.anchorPlotPoint = [NSArray arrayWithObjects:anchorX, anchorY, nil];
            // 8 - Add the annotation
            [plot.graph.plotAreaFrame.plotArea addAnnotation:priceAnnotation];
        }
        
        //label x axis
        for(int index=0; index<[_salesByItemDataList count]; index++)
        {
            // 1 - Is the plot hidden?
            if (plot.isHidden == YES) {
                return;
            }
            // 2 - Create style, if necessary
            static CPTMutableTextStyle *style = nil;
            if (!style) {
                style = [CPTMutableTextStyle textStyle];

                CPTColor *cptColor = [CPTColor blackColor];
                style.color= cptColor;
                style.fontSize = 10.0f;
                style.fontName = @"HelveticaNeue-Medium";
            }
            // 3 - Create annotation, if necessary
            NSString *label = ((SalesByItemData *)_salesByItemDataList[index]).item;
            CPTPlotSpaceAnnotation *labelAnnotation = self.arrLabelAnnotation[index];
            
            
            // 4 - Create number formatter, if needed
            static NSNumberFormatter *formatter = nil;
            if (!formatter) {
                formatter = [[NSNumberFormatter alloc] init];
                [formatter setMaximumFractionDigits:2];
            }
            // 5 - Create text layer for annotation
            CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:label style:style];
            labelAnnotation.contentLayer = textLayer;
            // 6 - Get plot index based on identifier
            NSInteger plotIndex = 0;
            if ([plot.identifier isEqual:CPDSalesByCat] == YES) {
                plotIndex = 0;
            }
            // 7 - Get the anchor point for annotation
            CGFloat x = index + CPDBarInitialX + (plotIndex * CPDBarWidth);
            NSNumber *anchorX = [NSNumber numberWithFloat:x];
            CGFloat y;
            float maxValue = 0.0;
            if(segConType.selectedSegmentIndex==0){maxValue = [self getMaxNoOfPair];}
            else if(segConType.selectedSegmentIndex==1){maxValue = [self getMaxSumValue];}
            else if(segConType.selectedSegmentIndex==2){maxValue = [self getMaxSumMargin];}
            if([self getXMax]<=8)
            {
                y = .05*maxValue*-1;
            }
            else
            {
                if(index % 2 == 0)
                {
                    y = .05*maxValue*-1;
                }
                else if(index % 2 == 1)
                {
                    y = .05*maxValue*-2;
                }
            }
            
            
            NSNumber *anchorY = [NSNumber numberWithFloat:y];
            labelAnnotation.anchorPlotPoint = [NSArray arrayWithObjects:anchorX, anchorY, nil];
            // 8 - Add the annotation            
            [plot.graph.plotAreaFrame.plotArea addAnnotation:labelAnnotation];
        }
        
        //////////////////
        barX += CPDBarWidth;
    }
}

-(void)configureAxes {
    // 1 - Configure styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor blackColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [[CPTColor blackColor] colorWithAlphaComponent:1];
    // 2 - Get the graph's axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    // 3 - Configure the x-axis
    axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    axisSet.xAxis.title = @"Item";
    axisSet.xAxis.titleTextStyle = axisTitleStyle;
    axisSet.xAxis.titleOffset = 34.0f;
    axisSet.xAxis.axisLineStyle = axisLineStyle;
    
    // 4 - Configure the y-axis
    NSArray *yAxisLabel = @[@"No. of item",@"Total amount (Baht)",@"Total margin (Baht)"];
    axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    axisSet.yAxis.title = yAxisLabel[segConType.selectedSegmentIndex];
    axisSet.yAxis.titleTextStyle = axisTitleStyle;
    axisSet.yAxis.titleOffset = 10.0f;
    axisSet.yAxis.axisLineStyle = axisLineStyle;
}

-(void)hideAnnotation:(CPTGraph *)graph {
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return [_salesByItemDataList count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    if ((fieldEnum == CPTBarPlotFieldBarTip) && (index < [_salesByItemDataList count])) {
        if ([plot.identifier isEqual:CPDSalesByCat]) {
            SalesByItemData *salesByItemData = [_salesByItemDataList objectAtIndex:index];
            
            NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
            f.numberStyle = NSNumberFormatterDecimalStyle;
            
            float value = 0.0;
            if(segConType.selectedSegmentIndex==0){value = salesByItemData.intNoOfPair;}
            else if(segConType.selectedSegmentIndex==1){value = salesByItemData.floatSumValue;}
            else if(segConType.selectedSegmentIndex==2){value = salesByItemData.floatSumMargin;}            
            return @(value);
        }

    }
    return [NSDecimalNumber numberWithUnsignedInteger:index];
}

-(NSInteger)getMaxNoOfPair
{
    NSInteger maxValue = 0;
    for(SalesByItemData *item in _salesByItemDataList)
    {
        if(maxValue<item.intNoOfPair)
        {
            maxValue = item.intNoOfPair;
        }
    }
    return maxValue;
}
-(float)getMaxSumValue
{
    float maxValue = 0;
    for(SalesByItemData *item in _salesByItemDataList)
    {
        if(maxValue<item.floatSumValue)
        {
            maxValue = item.floatSumValue;
        }
    }
    return maxValue;
}
-(float)getMaxSumMargin
{
    float maxValue = 0;
    for(SalesByItemData *item in _salesByItemDataList)
    {
        if(maxValue<item.floatSumMargin)
        {
            maxValue = item.floatSumMargin;
        }
    }
    return maxValue;
}
-(float)getXMax
{
    return [_salesByItemDataList count];
}
- (IBAction)segConChanged:(id)sender {
    if(segConType.selectedSegmentIndex==0)
    {
        [self sortByNoOfPair];
        [self showEightThOutOfTenNoOfPair];
        
        NSString *total = [NSString stringWithFormat:@"%d",[self getTotalNoOfPair]];
        total = [Utility formatBaht:total withMinFraction:0 andMaxFraction:0];
        lblTotal.text = [NSString stringWithFormat:@"%@",total];
    }
    else if(segConType.selectedSegmentIndex==1)
    {
        [self sortBySumValue];
        [self showEightThOutOfTenSumValue];
        
        NSString *total = [NSString stringWithFormat:@"%f",[self getTotalSumValue]];
        total = [Utility formatBaht:total withMinFraction:0 andMaxFraction:0];
        lblTotal.text = [NSString stringWithFormat:@"%@",total];
    }
    else if(segConType.selectedSegmentIndex==2)
    {
        [self sortBySumMargin];
        [self showEightThOutOfTenSumMargin];
        
        NSString *total = [NSString stringWithFormat:@"%f",[self getTotalSumMargin]];
        total = [Utility formatBaht:total withMinFraction:0 andMaxFraction:0];
        lblTotal.text = [NSString stringWithFormat:@"%@",total];
    }
    
    [self initPlot];
}

-(void)backToPreviousPage
{
    globalRotateFromSeg = YES;
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    [self.navigationController popViewControllerAnimated:YES];
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
