//
//  ChartSalesByChannelViewController.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 3/10/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import "ChartSalesByChannelViewController.h"
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
#import "SharedPostCode.h"
#import "SalesByChannel.h"
#import "PostCode.h"


@interface ChartSalesByChannelViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSMutableArray *_salesByChannelList;
    NSMutableArray *_salesByItemDataList;
    NSMutableArray *_salesByItemDataListTemp;
}
@property (strong, nonatomic) IBOutlet UISegmentedControl *segConType;
@property (nonatomic, strong) IBOutlet CPTGraphHostingView *hostView;
@property (nonatomic, strong) CPTBarPlot *salesByItemPlot;
@property (nonatomic, strong) NSMutableArray *arrValueAnnotation;
@property (nonatomic, strong) NSMutableArray *arrLabelAnnotation;

-(void)initPlot;
-(void)configureGraph;
-(void)configurePlots;
-(void)configureAxes;

- (IBAction)segConChanged:(id)sender;
@end
extern BOOL globalRotateFromSeg;

@implementation ChartSalesByChannelViewController
@synthesize hostView;
@synthesize salesByItemPlot;
@synthesize arrValueAnnotation;
@synthesize arrLabelAnnotation;
@synthesize lblTotal;
@synthesize periodCondition;
@synthesize segConType;

- (void)loadView {
    [super loadView];
    // Do any additional setup after loading the view.
    
    _homeModel = [[HomeModel alloc] init];
    _homeModel.delegate = self;
    
    {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);
    }
    

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
    
    self.navigationController.topViewController.title = @"Sales by Channel";
    
    
    [self loadViewProcess];
}

-(void)loadViewProcess
{
    [self loadingOverlayView];
    [_homeModel downloadItems:dbSalesByChannel condition:periodCondition];
}

- (void)itemsDownloaded:(NSArray *)items
{
    int i=0;
    _salesByChannelList = items[i++];
        
    
    dispatch_async(dispatch_get_main_queue(),^ {
        [self removeOverlayViews];
        [self setData];
        [self initPlot];
    } );
}

-(void)setData
{
    for(SalesByChannel *item in _salesByChannelList)
    {
        SalesByItemData *salesByItem = [[SalesByItemData alloc]init];
        salesByItem.item = [SalesByChannel getChannel:item.channel];
        salesByItem.floatSumValue = item.sales;
        salesByItem.floatPercent = item.sales/[self getTotalSales]*100;
        salesByItem.floatPercent = roundf(salesByItem.floatPercent/0.1);
        salesByItem.floatPercent = salesByItem.floatPercent * 0.1f;
        [_salesByItemDataList addObject:salesByItem];
    }
    
    
    [self sortBySumValue];
    
    NSString *total = [NSString stringWithFormat:@"%f",[self getTotalSumValue]];
    total = [Utility formatBaht:total withMinFraction:0 andMaxFraction:0];
    lblTotal.text = [NSString stringWithFormat:@"%@",total];
}

-(float)getTotalSales
{
    float totalSales = 0;
    for(SalesByChannel *item in _salesByChannelList)
    {
        totalSales += item.sales;
    }
    return totalSales;
}
-(void)sortBySumValue
{
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_floatSumValue" ascending:NO];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_item" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2, nil];
    NSArray *sortArray = [_salesByItemDataList sortedArrayUsingDescriptors:sortDescriptors];
    _salesByItemDataList = [sortArray mutableCopy];
}

-(void)sortByPercent
{
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_floatPercent" ascending:NO];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_item" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2, nil];
    NSArray *sortArray = [_salesByItemDataList sortedArrayUsingDescriptors:sortDescriptors];
    _salesByItemDataList = [sortArray mutableCopy];
}

-(float)getTotalSumValue
{
    float total = 0;
    for(SalesByItemData *item in _salesByItemDataList)
    {
        total += item.floatSumValue;
    }
    return total;
}

-(float)getTotalPercent
{
    float total = 0;
    for(SalesByItemData *item in _salesByItemDataList)
    {
        total += item.floatPercent;
    }
    return total;
}

-(void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Chart behavior
-(void)initPlot {
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
    NSString *title = @"Sales by Channel";
    graph.title = title;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, -16.0f);
    // 5 - Set up plot space
    CGFloat xMin = 0.0f;
    CGFloat xMax = [_salesByItemDataList count];
    CGFloat yMin = 0.0f;
    
    
    float maxValue;
    if(segConType.selectedSegmentIndex==0){maxValue = [self getMaxSumValue];}
    else if(segConType.selectedSegmentIndex==1){maxValue = [self getMaxPercent];}
    
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
            if(segConType.selectedSegmentIndex==0){maxValue = [self getMaxSumValue];}
            else if(segConType.selectedSegmentIndex==1){maxValue = [self getMaxPercent];}
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
            if(segConType.selectedSegmentIndex==0){maxValue = [self getMaxSumValue];}
            else if(segConType.selectedSegmentIndex==1){maxValue = [self getMaxPercent];}
            if([self getXMax]<=8)
            {
                y = .05*maxValue*-2;
            }
            else
            {
                if(index % 2 == 0)
                {
                    y = .05*maxValue*-2;
                }
                else if(index % 2 == 1)
                {
                    y = .05*maxValue*-4;
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
    NSArray *yAxisLabel = @[@"Total amount (Baht)",@"Total amount (Percent)"];
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
            if(segConType.selectedSegmentIndex==0){value = salesByItemData.floatSumValue;}
            else if(segConType.selectedSegmentIndex==1){value = salesByItemData.floatPercent;}
            
            return @(value);
        }
        
    }
    return [NSDecimalNumber numberWithUnsignedInteger:index];
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
-(float)getMaxPercent
{
    float maxValue = 0;
    for(SalesByItemData *item in _salesByItemDataList)
    {
        if(maxValue<item.floatPercent)
        {
            maxValue = item.floatPercent;
        }
    }
    return maxValue;
}
-(float)getXMax
{
    return [_salesByItemDataList count];
}
- (IBAction)segConChanged:(id)sender {
    arrValueAnnotation = nil;
    arrLabelAnnotation = nil;
    
    
    if(segConType.selectedSegmentIndex==0)
    {
        [self sortBySumValue];
        
        NSString *total = [NSString stringWithFormat:@"%f",[self getTotalSumValue]];
        total = [Utility formatBaht:total withMinFraction:0 andMaxFraction:0];
        lblTotal.text = [NSString stringWithFormat:@"%@",total];
    }
    else if(segConType.selectedSegmentIndex==1)
    {
        [self sortByPercent];
        
        NSString *total = [NSString stringWithFormat:@"%f",[self getTotalPercent]];
        total = [Utility formatBaht:total withMinFraction:0 andMaxFraction:0];
        lblTotal.text = [NSString stringWithFormat:@"%@",total];
    }
    
    [self initPlot];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                   style:UIBarButtonItemStylePlain target:self action:@selector(backToPreviousPage)];
    self.tabBarController.navigationItem.leftBarButtonItem = leftButton;
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
