//
//  PrintAddressLotTestViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 2/29/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OptionView.h"
#import "PDFSelectVIewControllerViewController.h"
#import <BRPtouchPrinterKit/BRPtouchPrinterKit.h>

typedef enum : NSInteger {
    DocumentKindToPrintImage = 0,
    DocumentKindToPrintPDF
} DocumentKindToPrint;


@interface PrintAddressViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSArray         *printerList;
    NSInteger selectedPrinterIndex;
    DocumentKindToPrint printKind;
    UIBackgroundTaskIdentifier bgTask;
}

@property (strong, nonatomic) NSMutableArray *arrPostDetail;
@property(nonatomic, retain) OptionView *option;

@property (strong, nonatomic) IBOutlet UITableView *tableViewAddress;
@property (strong, nonatomic) IBOutlet UILabel *lblPrintStatus;
- (IBAction)connectPrinter:(id)sender;
- (IBAction)printAddress:(id)sender;

@end
