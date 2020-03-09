//
//  AccountReceiptPDFViewController.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 2/7/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "SalesProductAndPrice.h"
#import "HomeModel.h"


@interface AccountReceiptPDFViewController : UIViewController<HomeModelProtocol,MFMailComposeViewControllerDelegate>
- (IBAction)genReceipt:(id)sender;

@property (strong, nonatomic) IBOutlet UIWebView *webPreview;
@property (strong, nonatomic) NSMutableArray *saleProductAndPriceList;
@property (strong, nonatomic) NSMutableArray *accountInventorySummaryList;
@property (strong, nonatomic) NSString *dateOut;
@property (nonatomic) NSInteger sendMail;

@end
