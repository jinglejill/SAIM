//
//  ChartSalesByColorViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/18/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "ChartSalesByColorViewController.h"
#import "ChartSalesByItemViewController.h"
#import "SharedSalesByColorData.h"
#import "SalesByColorData.h"
#import "SharedSelectedEvent.h"
#import "SalesByColorData.h"
#import "Utility.h"
#import "SharedReceiptItem.h"
#import "ReceiptProductItem.h"
#import "SharedReceipt.h"
#import "SharedProduct.h"
#import "SharedCustomMade.h"

@interface ChartSalesByColorViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSMutableArray *_salesByColorDataList;
    NSMutableArray *_salesByColorDataListTemp;
    Event *_event;
    NSString *_strEventID;
}
@property (strong, nonatomic) IBOutlet UISegmentedControl *segConType;
@property (nonatomic, strong) IBOutlet CPTGraphHostingView *hostView;
- (IBAction)segConChanged:(id)sender;

@property (nonatomic, strong) CPTBarPlot *salesByColorPlot;
@property (nonatomic, strong) NSMutableArray *arrValueAnnotation;
@property (nonatomic, strong) NSMutableArray *arrLabelAnnotation;


-(void)initPlot;
-(void)configureGraph;
-(void)configurePlots;
-(void)configureAxes;
@end

@implementation ChartSalesByColorViewController

@synthesize hostView;
@synthesize salesByColorPlot;
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
    ChartSalesByItemViewController *vc = (ChartSalesByItemViewController *)[[self.tabBarController viewControllers] objectAtIndex:0];
    vc.txtStartDate.text = txtStartDate.text;
    vc.txtEndDate.text = txtEndDate.text;
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

- (void)loadView {
    [super loadView];
    // Do any additional setup after loading the view.
    
    [dtPicker removeFromSuperview];
    txtStartDate.inputView = dtPicker;
    txtStartDate.delegate = self;
    
    txtEndDate.inputView = dtPicker;
    txtEndDate.delegate = self;
    

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
    
    _salesByColorDataList = [[NSMutableArray alloc]init];
    _salesByColorDataListTemp = [[NSMutableArray alloc]init];
    CGRect frameSize = CGRectMake(segConType.frame.origin.x, segConType.frame.origin.y, segConType.frame.size.width, 20);
    segConType.frame = frameSize;
    
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
            Receipt *receipt = [Utility getReceipt:item.receiptID];
            item.eventID = receipt.eventID;
            //I=Inventory,C=Custom made,A=change I,B=change C,P=preorder,D=change P,S=post preorder
            if(item.isPreOrder2)
            {
                Color *color = [Color getColor:item.preOrder2Color];
                item.color = color.name;
            }
            else if([item.productType isEqualToString:@"I"] || [item.productType isEqualToString:@"P"] || [item.productType isEqualToString:@"S"] || [item.productType isEqualToString:@"A"] || [item.productType isEqualToString:@"D"] || [item.productType isEqualToString:@"F"])
            {
                Product *product = [Product getProduct:item.productID];
                item.color = [Utility getColorName:product.color];
            }
            else if([item.productType isEqualToString:@"C"] || [item.productType isEqualToString:@"B"] || [item.productType isEqualToString:@"E"])
            {
                CustomMade *customMade = [Utility getCustomMade:[item.productID integerValue]];
                item.color = customMade.body;
            }
            else if([item.productType isEqualToString:@"R"])
            {
                CustomMade *customMade = [Utility getCustomMadeFromProductIDPost:item.productID];
                item.color = customMade.body;
            }
        }
        
        
        //sort by color
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_color" ascending:NO];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
        NSArray *sortArray = [receiptProductItemList sortedArrayUsingDescriptors:sortDescriptors];
        receiptProductItemList = [sortArray mutableCopy];
        
        //count pair and sumValue
        NSInteger countItem = 0;
        float sumValue = 0.0f;
        NSString *previousColor = @"";
        [_salesByColorDataListTemp removeAllObjects];
        for(ReceiptProductItem *item in receiptProductItemList)
        {
            if([previousColor isEqualToString:@""])
            {
                countItem += 1;
                sumValue += [item.priceSales floatValue];
            }
            else if(![previousColor isEqualToString:item.color])
            {
                SalesByColorData *salesByColor = [[SalesByColorData alloc]init];
                salesByColor.eventID = item.eventID;
                salesByColor.color = previousColor;
                salesByColor.intNoOfPair = countItem;
                salesByColor.floatSumValue = sumValue;
                
                [_salesByColorDataListTemp addObject:salesByColor];
                countItem = 1;
                sumValue = [item.priceSales floatValue];
            }
            else if([previousColor isEqualToString:item.color])
            {
                countItem += 1;
                sumValue += [item.priceSales floatValue];
            }
            previousColor = item.color;
        }
        
        NSString *strEventID = [NSString stringWithFormat:@"%ld",_event.eventID];
        SalesByColorData *salesByColor = [[SalesByColorData alloc]init];
        salesByColor.eventID = strEventID;
        salesByColor.color = previousColor;
        salesByColor.intNoOfPair = countItem;
        salesByColor.floatSumValue = sumValue;
        [_salesByColorDataListTemp addObject:salesByColor];
    }
    
    [self sortByNoOfPair];
    [self showEightThOutOfTenNoOfPair];
    lblTotal.text = [NSString stringWithFormat:@"%d",[self getTotalNoOfPair]];
}

-(void)sortByNoOfPair
{
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_intNoOfPair" ascending:NO];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_color" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2, nil];
    NSArray *sortArray = [_salesByColorDataListTemp sortedArrayUsingDescriptors:sortDescriptors];
    _salesByColorDataListTemp = [sortArray mutableCopy];
}

-(void)sortBySumValue
{
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_floatSumValue" ascending:NO];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_color" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2, nil];
    NSArray *sortArray = [_salesByColorDataListTemp sortedArrayUsingDescriptors:sortDescriptors];
    _salesByColorDataListTemp = [sortArray mutableCopy];
}

-(int)getTotalNoOfPair
{
    float total = 0;
    for(SalesByColorData *item in _salesByColorDataListTemp)
    {
        total += item.intNoOfPair;
    }
    return total;
}

-(float)getTotalSumValue
{
    float total = 0;
    for(SalesByColorData *item in _salesByColorDataListTemp)
    {
        total += item.floatSumValue;
    }
    return total;
}

-(void)showEightThOutOfTenNoOfPair
{
    //show only 80%
    int noOfPairOthers = 0;
    float sumValueOthers = 0;
    float accumAmount = 0;
    int totalAmount = [self getTotalNoOfPair];
    float eightThOutOfTenAmount = 0.8*totalAmount;
    [_salesByColorDataList removeAllObjects];
    for(SalesByColorData *item in _salesByColorDataListTemp)
    {
        if(accumAmount <= eightThOutOfTenAmount)
        {
            [_salesByColorDataList addObject:item];
            accumAmount += item.intNoOfPair;
        }
        else
        {
            noOfPairOthers += item.intNoOfPair;
            sumValueOthers += item.floatSumValue;
        }
        
        if(accumAmount > eightThOutOfTenAmount)
        {
            continue;
        }
    }
    
    SalesByColorData *salesByColor = [[SalesByColorData alloc]init];
    salesByColor.eventID = _strEventID;
    salesByColor.color = @"Others";
    salesByColor.intNoOfPair = noOfPairOthers;
    salesByColor.floatSumValue = sumValueOthers;
    [_salesByColorDataList addObject:salesByColor];
}

-(void)showEightThOutOfTenSumValue
{
    //show only 80%
    int noOfPairOthers = 0;
    float sumValueOthers = 0;
    float accumAmount = 0;
    float totalAmount = [self getTotalSumValue];
    float eightThOutOfTenAmount = 0.8*totalAmount;
    [_salesByColorDataList removeAllObjects];
    for(SalesByColorData *item in _salesByColorDataListTemp)
    {
        if(accumAmount <= eightThOutOfTenAmount)
        {
            [_salesByColorDataList addObject:item];
            accumAmount += item.floatSumValue;
        }
        else
        {
            noOfPairOthers += item.intNoOfPair;
            sumValueOthers += item.floatSumValue;
        }
        
        if(accumAmount > eightThOutOfTenAmount)
        {
            continue;
        }
    }
    
    SalesByColorData *salesByColor = [[SalesByColorData alloc]init];
    salesByColor.eventID = _strEventID;
    salesByColor.color = @"Others";
    salesByColor.intNoOfPair = noOfPairOthers;
    salesByColor.floatSumValue = sumValueOthers;
    [_salesByColorDataList addObject:salesByColor];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ChartSalesByItemViewController *vc = (ChartSalesByItemViewController *)[[self.tabBarController viewControllers] objectAtIndex:0];
    txtStartDate.text = vc.txtStartDate.text;
    txtEndDate.text = vc.txtEndDate.text;
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
    NSString *title = @"Sales by Color";
    graph.title = title;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, -16.0f);
    // 5 - Set up plot space
    CGFloat xMin = 0.0f;
    CGFloat xMax = [_salesByColorDataList count];
    CGFloat yMin = 0.0f;
    CGFloat yMax = segConType.selectedSegmentIndex==0?[self getMaxNoOfPair]*1.5:[self getMaxSumValue]*1.5;// should determine dynamically based on max price
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
    self.salesByColorPlot = barPlot;
    self.salesByColorPlot.identifier = CPDSalesByCat;
    // 2 - Set up line style
    CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
    barLineStyle.lineColor = cptColor;
    barLineStyle.lineWidth = 0.5;
    // 3 - Add plots to graph
    CPTGraph *graph = self.hostView.hostedGraph;
    CGFloat barX = CPDBarInitialX;
    NSArray *plots = [NSArray arrayWithObjects:self.salesByColorPlot, nil];
    for (CPTBarPlot *plot in plots) {
        plot.dataSource = self;
        plot.delegate = self;
        plot.barWidth = CPTDecimalFromDouble(CPDBarWidth);
        plot.barOffset = CPTDecimalFromDouble(barX);
        plot.lineStyle = barLineStyle;
        [graph addPlot:plot toPlotSpace:graph.defaultPlotSpace];
        
        
        //initial annotation for value
        if(arrValueAnnotation == nil && [_salesByColorDataList count]>0)
        {
            arrValueAnnotation = [[NSMutableArray alloc]init];
            for(int index=0; index<[_salesByColorDataList count]; index++)
            {
                NSNumber *x = [NSNumber numberWithInt:0];
                NSNumber *y = [NSNumber numberWithInt:0];
                NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
                CPTPlotSpaceAnnotation *priceAnnotation = (CPTPlotSpaceAnnotation*)[[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:plot.plotSpace anchorPlotPoint:anchorPoint];
                
                [arrValueAnnotation addObject:priceAnnotation];
            }
        }
        //initial annotation for label x axis
        if(arrLabelAnnotation == nil && [_salesByColorDataList count]>0)
        {
            arrLabelAnnotation = [[NSMutableArray alloc]init];
            for(int index=0; index<[_salesByColorDataList count]; index++)
            {
                NSNumber *x = [NSNumber numberWithInt:0];
                NSNumber *y = [NSNumber numberWithInt:0];
                NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
                CPTPlotSpaceAnnotation *labelAnnotation = (CPTPlotSpaceAnnotation*)[[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:plot.plotSpace anchorPlotPoint:anchorPoint];
                
                [arrLabelAnnotation addObject:labelAnnotation];
            }
        }
        
        //annotation for value
        for(int index=0; index<[_salesByColorDataList count]; index++)
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
                //                [formatter setMaximumFractionDigits:2];
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
            CGFloat y = segConType.selectedSegmentIndex==0?[value floatValue] + .05*[self getMaxNoOfPair]:[value floatValue]+ .05*[self getMaxSumValue];
            
            NSNumber *anchorY = [NSNumber numberWithFloat:y];
            priceAnnotation.anchorPlotPoint = [NSArray arrayWithObjects:anchorX, anchorY, nil];
            // 8 - Add the annotation
            [plot.graph.plotAreaFrame.plotArea addAnnotation:priceAnnotation];
            
        }
        
        //label x axis
        for(int index=0; index<[_salesByColorDataList count]; index++)
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
            NSString *label = ((SalesByColorData *)_salesByColorDataList[index]).color;
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
            if([self getXMax]<=8)
            {
                y = segConType.selectedSegmentIndex==0?.05*[self getMaxNoOfPair]*-1:.05*[self getMaxSumValue]*-1;
            }
            else
            {
                if(index % 2 == 0)
                {
                    y = segConType.selectedSegmentIndex==0?.05*[self getMaxNoOfPair]*-1:.05*[self getMaxSumValue]*-1;
                }
                else if(index % 2 == 1)
                {
                    y = segConType.selectedSegmentIndex==0?.05*[self getMaxNoOfPair]*-2:.05*[self getMaxSumValue]*-2;
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
    axisSet.xAxis.title = @"Color";
    axisSet.xAxis.titleTextStyle = axisTitleStyle;
    axisSet.xAxis.titleOffset = 34.0f;
    axisSet.xAxis.axisLineStyle = axisLineStyle;
    // 4 - Configure the y-axis
    axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    axisSet.yAxis.title = segConType.selectedSegmentIndex==0?@"No. of item":@"Total amount (Baht)";
    axisSet.yAxis.titleTextStyle = axisTitleStyle;
    axisSet.yAxis.titleOffset = 10.0f;
    axisSet.yAxis.axisLineStyle = axisLineStyle;
}

-(void)hideAnnotation:(CPTGraph *)graph {
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return [_salesByColorDataList count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    if ((fieldEnum == CPTBarPlotFieldBarTip) && (index < [_salesByColorDataList count])) {
        if ([plot.identifier isEqual:CPDSalesByCat]) {
            SalesByColorData *salesByColorData = [_salesByColorDataList objectAtIndex:index];
            
            NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
            f.numberStyle = NSNumberFormatterDecimalStyle;
            
            float value = 0.0;
            if(segConType.selectedSegmentIndex==0){value = salesByColorData.intNoOfPair;}
            else if(segConType.selectedSegmentIndex==1){value = salesByColorData.floatSumValue;}            
            return @(value);
        }
        
    }
    return [NSDecimalNumber numberWithUnsignedInteger:index];
}

-(NSInteger)getMaxNoOfPair
{
    NSInteger maxValue = 0;
    for(SalesByColorData *item in _salesByColorDataList)
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
    for(SalesByColorData *item in _salesByColorDataList)
    {
        if(maxValue<item.floatSumValue)
        {
            maxValue = item.floatSumValue;
        }
    }
    return maxValue;
}
-(float)getXMax
{
    return [_salesByColorDataList count];
}
- (IBAction)segConChanged:(id)sender {
    arrValueAnnotation = nil;
    arrLabelAnnotation = nil;
    
    if(segConType.selectedSegmentIndex==0)
    {
        [self sortByNoOfPair];
        
        NSString *total = [NSString stringWithFormat:@"%d",[self getTotalNoOfPair]];
        total = [Utility formatBaht:total withMinFraction:0 andMaxFraction:0];
        lblTotal.text = [NSString stringWithFormat:@"%@",total];
    }
    else
    {
        [self sortBySumValue];
        
        NSString *total = [NSString stringWithFormat:@"%f",[self getTotalSumValue]];
        total = [Utility formatBaht:total withMinFraction:0 andMaxFraction:0];
        lblTotal.text = [NSString stringWithFormat:@"%@",total];
    }
    [self initPlot];    
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
