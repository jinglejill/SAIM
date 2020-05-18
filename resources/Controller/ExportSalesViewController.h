//
//  ExportSalesViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 3/23/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"
//#import <DropboxSDK/DropboxSDK.h>

@interface ExportSalesViewController : UITableViewController<HomeModelProtocol,UITextFieldDelegate>//,DBSessionDelegate,DBNetworkRequestDelegate,DBRestClientDelegate
{
//    DBRestClient* restClient;
}
@property (strong, nonatomic) IBOutlet UITableView *tbv;
- (IBAction)unwindToExportSales:(UIStoryboardSegue *)segue;
- (IBAction)exportButtonClicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnExport;
@property (nonatomic) NSInteger fromMenu;//0=all event,1=selected event




- (IBAction)chartButtonClicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnChart;


@end
