//
//  ChartSalesByPriceViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/18/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "CPDConstants.h"
#import "CPDStockPriceStore.h"
#import "CPTGraphHostingView.h"
#import "CPTTheme.h"
#import "HomeModel.h"

@interface ChartSalesByPriceViewController : UIViewController<CPTBarPlotDataSource, CPTBarPlotDelegate,HomeModelProtocol>
@property (strong, nonatomic) IBOutlet UILabel *lblTotal;

@end
