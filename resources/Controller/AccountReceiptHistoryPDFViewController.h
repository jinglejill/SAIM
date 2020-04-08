//
//  AccountReceiptHistoryPDFViewController.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 2/13/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "HomeModel.h"
#import "AccountReceipt.h"
#import "WebKit/WebKit.h"
#import "NDHTMLtoPDF.h"


@interface AccountReceiptHistoryPDFViewController : UIViewController<HomeModelProtocol, MFMailComposeViewControllerDelegate,NDHTMLtoPDFDelegate,WKNavigationDelegate>

@property (strong, nonatomic) IBOutlet WKWebView *webPreview;
@property (strong, nonatomic) AccountReceipt *accountReceiptHistory;
@property (strong, nonatomic) NSString *strReceiptDateFrom;
@property (strong, nonatomic) NSString *strReceiptDateTo;
@property (nonatomic, strong) NDHTMLtoPDF *PDFCreator;
- (IBAction)emailPDF:(id)sender;

@end
