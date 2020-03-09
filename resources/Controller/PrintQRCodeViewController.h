//
//  PrintQRCodeViewController.h
//  SAIM_UPDATING
//
//  Created by Thidaporn Kijkamjai on 7/8/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OptionView.h"
#import "PDFSelectVIewControllerViewController.h"
#import <BRPtouchPrinterKit/BRPtouchPrinterKit.h>
#import "HomeModel.h"


typedef enum : NSInteger {
    DocumentKindToPrintImage = 0,
    DocumentKindToPrintPDF
} DocumentKindToPrint;


@interface PrintQRCodeViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,HomeModelProtocol>
{
    NSArray         *printerList;
    NSInteger selectedPrinterIndex;
    DocumentKindToPrint printKind;
    UIBackgroundTaskIdentifier bgTask;
}
@property (strong, nonatomic) NSMutableArray *mutArrQRCodeQuantity;
@property (strong, nonatomic) NSString *strManufacturingDate;
@property(nonatomic, retain) OptionView *option;

@property (strong, nonatomic) IBOutlet UITableView *tableViewData;
@property (strong, nonatomic) IBOutlet UILabel *lblPrintStatus;
- (IBAction)connectPrinter:(id)sender;
- (IBAction)printQRCode:(id)sender;



@end
