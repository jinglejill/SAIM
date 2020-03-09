//
//  ChartSalesByZoneViewController.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 10/7/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "CPDConstants.h"
#import "CPDStockPriceStore.h"
#import "CPTGraphHostingView.h"
#import "CPTTheme.h"
#import "HomeModel.h"
#import "Event.h"

@interface ChartSalesByZoneViewController : UIViewController<CPTBarPlotDataSource, CPTBarPlotDelegate,HomeModelProtocol>
@property (strong, nonatomic) IBOutlet UILabel *lblTotal;
@property (strong, nonatomic) Event *periodCondition;
@end
