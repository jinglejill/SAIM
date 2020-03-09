//
//  PrintAddressLotTestViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 2/29/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "PrintAddressViewController.h"
#import "CustomUITableViewCell3.h"
#import "PostCustomer.h"
#import "Utility.h"
#import "CustomIOSAlertView.h"
#import "coretext/coretext.h"
#import "ReachabilityBrother.h"
#import "PrinterView.h"
#import "Utilities.h"
#import "PostDetail.h"
#import "PrintAddressView.h"
#import "ProductName.h"


#define kBROTHERPJ673   @"Brother PJ-673"

#define	EXT_PJ673_ENCRYPT		0x01
#define	EXT_PJ673_CARBON		0x02
#define	EXT_PJ673_DASHPRINT		0x04
#define	EXT_PJ673_NFD			0x08
#define	EXT_PJ673_EOP			0x10
#define	EXT_PJ673_EPR			0x20


#define kPrinterCapabilitiesKey     @"Capabilities"
#define kPrinterPaperSizeKey        @"PaperSize"

#define kFuncDensity                @"FuncDensity"
#define kFuncCustomPaper            @"FuncCustomPaper"
#define kFuncAutoCut                @"FuncAutoCut"
#define kFuncChainPrint             @"FuncChainPrint"
#define kFuncHalfCut                @"FuncHalfCut"
#define kFuncSpecialTape            @"FuncSpecialTape"
#define kFuncCopies                 @"FuncCopies"
#define kFuncCarbonPrint            @"FuncCarbonPrint"
#define kFuncDashPrint              @"FuncDashPrint"
#define kFuncFeedMode               @"FuncFeedMode"


@interface PrintAddressViewController () < UITableViewDataSource, UITableViewDelegate>
{
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSString *_ip;
    BRPtouchPrinter	*ptp;
}

@end


@implementation PrintAddressViewController
@synthesize arrPostDetail,tableViewAddress,lblPrintStatus;


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(TARGET_OS_SIMULATOR == 0)
    {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            //Background Thread
            BOOL printStatus = [self checkPrinterReady];
            dispatch_async(dispatch_get_main_queue(), ^(void){
                //Run UI Updates
                if(printStatus)
                {
                    NSUserDefaults *userSettings = [NSUserDefaults standardUserDefaults];
                    NSString *selectedPrinterName = [userSettings stringForKey:@"LastSelectedPrinter"];
                    
                    if(selectedPrinterName && [selectedPrinterName length]>0)
                    {
                        NSString *strStatus = [NSString stringWithFormat:@"Printer name: %@ (ready)",selectedPrinterName];
                        lblPrintStatus.text = strStatus;
                    }
                }
                else
                {
                    NSUserDefaults *userSettings = [NSUserDefaults standardUserDefaults];
                    NSString *selectedPrinterName = [userSettings stringForKey:@"LastSelectedPrinter"];
                    
                    if(selectedPrinterName && [selectedPrinterName length]>0)
                    {
                        NSString *strStatus = [NSString stringWithFormat:@"Printer name: %@ (not ready)",selectedPrinterName];
                        lblPrintStatus.text = strStatus;
                    }
                    else
                    {
                        lblPrintStatus.text = @"No printer selected";
                    }
                }
                
            });
        });
    }
}
-(NSString *)getPrinterName
{
    NSUserDefaults *printSetting = [NSUserDefaults standardUserDefaults];
    NSString *printerName = [printSetting stringForKey:@"LastSelectedPrinter"];
    if(!printerName)
    {
        printerName = @"Brother QL-720NW";
    }
    return printerName;
}
-(BOOL)checkPrinterReady
{
    BRPtouchPrintInfo*	printInfo;
    BOOL	isCarbon;
    BOOL	isDashPrint;
    int		feedMode;
    int copies;
    
    
    //	Create BRPtouchPrintInfo
    printInfo = [[BRPtouchPrintInfo alloc] init];
    
    
    //	Load Paramator from UserDefault
    NSUserDefaults *printSetting = [NSUserDefaults standardUserDefaults];
    NSString *printerName = [self getPrinterName];
//    _printerName = printerName;
    if([printerName isEqualToString:@"Brother QL-720NW"])
    {
        printInfo.strPaperName      = @"62mm";
    }
    else if([printerName isEqualToString:@"Brother RJ-3150"])
    {
        printInfo.strPaperName      = @"RD 76mm";
    }
    else
    {
        printInfo.strPaperName      = @"62mm";
    }
    
    
    ptp = [[BRPtouchPrinter alloc] initWithPrinterName:printerName];
    
    
    if (0 != printInfo.strPaperName)
    {
        if (![supportedPaperSizeForPrinter(printerName) containsObject:printInfo.strPaperName]) {
            printInfo.strPaperName = @"Custom";
        }
        NSLog(@"paper: %@",printInfo.strPaperName);
        NSInteger density			= [printSetting integerForKey:@"density"];
        if (!isAvailableDensity(printerName, density)) {
            density = 0;
            NSUserDefaults *printSetting = [NSUserDefaults standardUserDefaults];
            [printSetting setInteger: density forKey:@"density"];
        }
        
        
        if([printerName isEqualToString:@"Brother QL-720NW"])
        {
            printInfo.nPrintMode = PRINT_FIT;
            printInfo.nDensity = -2;
            printInfo.nOrientation = ORI_PORTRATE;
            printInfo.nHalftone = HALFTONE_BINARY;
            printInfo.nHorizontalAlign = ALIGN_LEFT;
            printInfo.nVerticalAlign = ALIGN_TOP;
            printInfo.nPaperAlign = PAPERALIGN_LEFT;
            printInfo.nAutoCutFlag = 1;
        }
        else if([printerName isEqualToString:@"Brother RJ-3150"])
        {
            //	Set printInfo for rj-3150**** have to set papername or try to use custompaper
            printInfo.nPrintMode = PRINT_FIT;//fit
            printInfo.nDensity = 5;
            printInfo.nOrientation = ORI_PORTRATE;
            printInfo.nHalftone = HALFTONE_BINARY;
            printInfo.nHorizontalAlign = ALIGN_CENTER;
            printInfo.nVerticalAlign = ALIGN_MIDDLE;
            printInfo.nPaperAlign = PAPERALIGN_LEFT;
            printInfo.nAutoCutFlag = 0;
        }
        else
        {
            printInfo.nPrintMode = PRINT_FIT;
            printInfo.nDensity = 0;
            printInfo.nOrientation = ORI_PORTRATE;
            printInfo.nHalftone = HALFTONE_BINARY;
            printInfo.nHorizontalAlign = ALIGN_LEFT;
            printInfo.nVerticalAlign = ALIGN_TOP;
            printInfo.nPaperAlign = PAPERALIGN_LEFT;
            printInfo.nAutoCutFlag = 0;
        }
        
        
        
        if (isFuncAvailable(kFuncAutoCut, printerName)) {
            printInfo.nAutoCutFlag      = 1;
        }
        
        if (isFuncAvailable(kFuncChainPrint, printerName) ||
            isFuncAvailable(kFuncSpecialTape, printerName) ||
            isFuncAvailable(kFuncHalfCut, printerName)) {
            printInfo.nExMode = [printSetting integerForKey:@"ExMode"];
        }
        
        if (isFuncAvailable(kFuncCopies, printerName)) {
            copies = [printSetting integerForKey:@"Copies"];
        }
        else{
            copies = 0;
        }
        
        if (isFuncAvailable(kFuncCarbonPrint, printerName)) {
            isCarbon = [printSetting boolForKey:@"isCarbon"];
        }
        
        if (isFuncAvailable(kFuncDashPrint, printerName)) {
            isDashPrint = [printSetting boolForKey:@"isDashPrint"];
        }
        
        if (isFuncAvailable(kFuncFeedMode, printerName)) {
            feedMode = [printSetting integerForKey:@"feedMode"];            
        }
    }
    else
    {
        if ([printerName isEqualToString:@"Brother PJ-673"]) {
            printInfo.strPaperName = @"A4_CutSheet";
        }
        else{
            //            printInfo.strPaperName = @"RD 102mm";
            printInfo.strPaperName = @"RD 76mm";
        }
        printInfo.nPrintMode = PRINT_FIT;
        printInfo.nDensity = 0;
        printInfo.nOrientation = ORI_PORTRATE;
        printInfo.nHalftone = HALFTONE_ERRDIF;
        printInfo.nHorizontalAlign = ALIGN_CENTER;
        printInfo.nVerticalAlign = ALIGN_MIDDLE;
        printInfo.nPaperAlign = PAPERALIGN_LEFT;
        
        if (isFuncAvailable(kFuncCarbonPrint, printerName)) {
            isCarbon = false;
        }
        
        if (isFuncAvailable(kFuncDashPrint, printerName)) {
            isDashPrint = false;
        }
        
        if (isFuncAvailable(kFuncFeedMode, printerName)) {
            feedMode = 0;
        }
    }
    
    
    if (isFuncAvailable(kFuncCarbonPrint, printerName) ||
        isFuncAvailable(kFuncDashPrint, printerName) ||
        isFuncAvailable(kFuncFeedMode, printerName))
    {
        if (isCarbon) {
            printInfo.nExtFlag |= EXT_PJ673_CARBON;
        }
        if (isDashPrint) {
            printInfo.nExtFlag |= EXT_PJ673_DASHPRINT;
        }
        
        printInfo.nExtFlag |= feedMode;
    }
    
    _ip = [printSetting stringForKey:@"ipAddress"] == nil?@"":[printSetting stringForKey:@"ipAddress"];
//    _ip = @"192.168.100.55";
    [ptp setIPAddress:_ip];
    
    /********************************************************************************************
     // Refer to the following structure members in order to get tape color or printing color,
     // every color is associated with an ID, the IDs are all described in the User's Manual.
     
     // For tape color -> (PTSTATUSINFO)status.byLabelColor
     // For printing color -> (PTSTATUSINFO)status.byFontColor
     
     // for example:
     PTSTATUSINFO    status;
     [ptp getPTStatus:&status];
     NSLog(@"byLabelColor[%d]",status.byLabelColor);
     NSLog(@"byFontColor[%d]",status.byFontColor);
     *******************************************************************************************/
    
    if (isFuncAvailable(kFuncCustomPaper, printerName)) {
        //	Set custom paper
        if (0 == [printInfo.strPaperName compare:@"Custom"]) {
            NSString* strPaper = [printSetting stringForKey:@"customPaper"];
            NSString* strPath = nil;
            if (strPaper) {
                if (![customizedPapers(printerName) containsObject:strPaper]) {
                    strPaper = defaultCustomizedPaper(printerName);
                    NSLog(@"custom paper: %@",strPaper);
                }
                strPath = [[NSBundle mainBundle] pathForResource:strPaper ofType:@"bin"];
            }
            else{
                strPath = [[NSBundle mainBundle] pathForResource:defaultCustomizedPaper(printerName) ofType:@"bin"];
            }
            [ptp setCustomPaperFile:strPath];
        }
    }
    

    if([printerName isEqualToString:@"Brother RJ-3150"])
    {
        //	Set printInfo
        printInfo.nPrintMode = 1;//fit
        printInfo.nDensity = 3;
        printInfo.nOrientation = 1;
        printInfo.nHalftone = 0;
        printInfo.nHorizontalAlign = 1;
        printInfo.nVerticalAlign = 1;
    }
    [ptp setPrintInfo:printInfo];
    
    
    if ([ptp isPrinterReady]) {
        NSLog(@"Will start to print image file...");
        NSLog(@"Printer is ready !");
        return YES;
    }
    else
    {
        return NO;
    }
}
- (void)loadView
{
    [super loadView];
    
    {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);        
    }
        
    
    tableViewAddress.delegate = self;
    tableViewAddress.dataSource = self;
    
    
    NSUserDefaults *userSettings = [NSUserDefaults standardUserDefaults];
    NSString *selectedPrinterName = [userSettings stringForKey:@"LastSelectedPrinter"];
    
    if(selectedPrinterName && [selectedPrinterName length]>0)
    {
        NSString *strStatus = [NSString stringWithFormat:@"Printer name: %@ (connecting)",selectedPrinterName];
        lblPrintStatus.text = strStatus;
    }
    else
    {
        lblPrintStatus.text = @"No printer selected";
    }
    
    
    [self loadViewProcess];
}

- (void)loadViewProcess
{    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrPostDetail count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomUITableViewCell3 *cell;// = [self.tableViewAddress dequeueReusableCellWithIdentifier:@"AddressCell"];
    if (cell == nil) {
        cell = [[CustomUITableViewCell3 alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"AddressCell"];
    }
    
    PostDetail *postDetail = arrPostDetail[indexPath.row];
//    NSInteger receiptProductItemID = postDetail.receiptProductItemID;
//    ReceiptProductItem *receiptProductItem = [Utility getReceiptProductItem:receiptProductItemID];
//    NSInteger receiptID = receiptProductItem.receiptID;
//    NSInteger postCustomerID = [Utility getPostCustomerID:receiptID];
//    PostCustomer *postCustomer = [Utility getPostCustomer:postCustomerID];
    NSString *strAddress = @"";
    NSString *postcode = @"";
    NSString *country = @"";;
//    if(postCustomer)
//    {
//        NSString *strTel = [postCustomer.telephone isEqualToString:@""]?@"":[NSString stringWithFormat:@"\r\n(โทร. %@)",[Utility insertDash:postCustomer.telephone]];
//        NSString *street1 = [postCustomer.street1 length]>0?[NSString stringWithFormat:@"%@ ",postCustomer.street1]:@"";
//        strAddress = [NSString stringWithFormat:@"%@%@\r\n\r\n%@",postCustomer.firstName,strTel,street1];
//        
//
//        postcode = [postCustomer.postcode length]>0?[NSString stringWithFormat:@"\r\n%@ ",postCustomer.postcode]:@"";
//        country = postCustomer.country;
//    }
    if(postDetail.hasPostCustomer)
    {
        NSString *strTel = [postDetail.telephone isEqualToString:@""]?@"":[NSString stringWithFormat:@"\r\n(โทร. %@)",[Utility insertDash:postDetail.telephone]];
        NSString *street1 = [postDetail.street1 length]>0?[NSString stringWithFormat:@"%@ ",postDetail.street1]:@"";
        strAddress = [NSString stringWithFormat:@"%@%@\r\n\r\n%@",postDetail.customerName,strTel,street1];
        
        
        postcode = [postDetail.postcode length]>0?[NSString stringWithFormat:@"\r\n%@ ",postDetail.postcode]:@"";
        country = postDetail.country;
    }
    
    
    //ชื่อและที่อยู่ผู้รับ
    UIFont *font1 = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17];
    NSDictionary *arialDict = [NSDictionary dictionaryWithObject: font1 forKey:NSFontAttributeName];
    NSMutableAttributedString *aAttrString1 = [[NSMutableAttributedString alloc] initWithString:@"ชื่อและที่อยู่ผู้รับ" attributes: arialDict];
    cell.lblHeaderAddress.attributedText = aAttrString1;
//    [self setLabelUnderline:cell.lblHeaderAddress underline:cell.viewUnderline];
    
    
    
    //customer's address
    UIFont *font2 = [UIFont fontWithName:@"HelveticaNeue" size:17];
    NSDictionary *arialDict2 = [NSDictionary dictionaryWithObject: font2 forKey:NSFontAttributeName];
    NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:strAddress attributes: arialDict2];
    
    //postcode
    UIFont *font22 = [UIFont fontWithName:@"HelveticaNeue" size:26];
    NSDictionary *arialDict22 = [NSDictionary dictionaryWithObject: font22 forKey:NSFontAttributeName];
    NSMutableAttributedString *aAttrString22 = [[NSMutableAttributedString alloc] initWithString:postcode attributes: arialDict22];
    
    //country
    UIFont *font23 = [UIFont fontWithName:@"HelveticaNeue" size:17];
    NSDictionary *arialDict23 = [NSDictionary dictionaryWithObject: font23 forKey:NSFontAttributeName];
    NSMutableAttributedString *aAttrString23 = [[NSMutableAttributedString alloc] initWithString:country attributes: arialDict23];
    
    
    
    [aAttrString2 appendAttributedString:aAttrString22];
    [aAttrString2 appendAttributedString:aAttrString23];
    cell.txtVwAddress.attributedText = aAttrString2;
    
    
    
    //style/color/size
    NSString *remark = [NSString stringWithFormat:@"* %@",postDetail.product];
//    NSString *remark;
//    if([receiptProductItem.productType isEqualToString:@"P"])
//    {
//        Product *product = [Product getProduct:receiptProductItem.productID];
//        PostDetail *postDetail = [[PostDetail alloc]init];
//        postDetail.productName = [ProductName getNameWithProductID:product.productID];
//        postDetail.color = [Utility getColorName:product.color];
//        postDetail.size = [Utility getSizeLabel:product.size];
//        postDetail.product = [NSString stringWithFormat:@"%@/%@/%@",postDetail.productName,postDetail.color,postDetail.size];
//        remark = [NSString stringWithFormat:@"* %@",postDetail.product];
//    }
//    else if([receiptProductItem.productType isEqualToString:@"C"])
//    {
//        CustomMade *customMade = [Utility getCustomMade:[receiptProductItem.productID integerValue]];
//        PostDetail *postDetail = [[PostDetail alloc]init];
//        postDetail.productName = [ProductName getNameWithCustomMadeID:customMade.customMadeID];
//        postDetail.color = customMade.body;
//        postDetail.size = customMade.size;
//        postDetail.product = [NSString stringWithFormat:@"%@/%@/%@",@"CM",postDetail.color,postDetail.size];
//        remark = [NSString stringWithFormat:@"* %@",postDetail.product];
//    }
    

    UIFont *font3 = [UIFont fontWithName:@"HelveticaNeue" size:17];
    NSDictionary *arialDict3 = [NSDictionary dictionaryWithObject: font3 forKey:NSFontAttributeName];
    NSMutableAttributedString *aAttrString3 = [[NSMutableAttributedString alloc] initWithString:remark attributes: arialDict3];
    cell.lblRemark.attributedText = aAttrString3;
    cell.lblRemark.adjustsFontSizeToFitWidth = true;
    cell.lblRemark.minimumScaleFactor = 0.5;
    
    
    
//    [cell.vwPrint addSubview:cell.txtVwAddress];
    
    
    
    //adjust vwprint height and remark y for ql720
    NSString *prnterName = [self getPrinterName];
    if([prnterName isEqualToString:@"Brother QL-720NW"])
    {
        {
            CGRect frame = cell.vwPrint.frame;
            frame.size.height = 390;
            cell.vwPrint.frame = frame;
        }
        {
            [cell.txtVwAddress sizeToFit];
            CGRect frame = cell.lblRemark.frame;
            frame.origin.y = cell.txtVwAddress.frame.origin.y+cell.txtVwAddress.frame.size.height+10;
            cell.lblRemark.frame = frame;
        }
    }
    else
    {
//        [cell.vwPrint addSubview:cell.lblHeaderAddress];
    }

    return cell;

}
-(UILabel *)setLabelUnderline:(UILabel *)label underline:(UIView *)viewUnderline
{
    CGRect expectedLabelSize = [label.text boundingRectWithSize:label.frame.size
                                                        options:NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading
                                                     attributes:@{NSFontAttributeName:label.font}
                                                        context:nil];
    CGFloat xOrigin=0;
    switch (label.textAlignment) {
        case NSTextAlignmentCenter:
            xOrigin=(label.frame.size.width - expectedLabelSize.size.width)/2;
            break;
        case NSTextAlignmentLeft:
            xOrigin=0;
            break;
        case NSTextAlignmentRight:
            xOrigin=label.frame.size.width - expectedLabelSize.size.width;
            break;
        default:
            break;
    }
    viewUnderline.frame=CGRectMake(xOrigin,
                                   expectedLabelSize.size.height-1,
                                   expectedLabelSize.size.width,
                                   1);
    viewUnderline.backgroundColor=label.textColor;
    [label addSubview:viewUnderline];
    return label;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableViewAddress deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    return 373.6;
    
    
    //adjust vwprint height and remark y for ql720
    NSString *prnterName = [self getPrinterName];
    if([prnterName isEqualToString:@"Brother QL-720NW"])
    {
        return 405;//390
    }
    else if([prnterName isEqualToString:@"Brother RJ-3150"])
    {
        return 385+15;
    }
    else
    {
        return 405;//390
    }
}
- (BOOL)shouldStartSearch
{
    BOOL shouldStart = NO;
    
    ReachabilityBrother *wifiReachability = [ReachabilityBrother reachabilityForLocalWiFi];
    if ((![wifiReachability currentReachabilityStatus]) == NotReachable) {
        shouldStart = YES;
    }
    
    return shouldStart;
}
- (IBAction)connectPrinter:(id)sender {
    if (![self shouldStartSearch]) {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:@"Please check your Network settings"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    
    PrinterView *pv = [[PrinterView alloc] initWithNibName: @"PrinterView" bundle: nil];
    UINavigationController* nv = [[UINavigationController alloc] initWithRootViewController:pv];
    
    [self presentViewController:nv animated:YES completion:nil];
}
//342,169
- (UIImage *)combineImage:(NSArray *)arrImage
{
    UIImage *image0 = arrImage[0];
    CGSize size = CGSizeMake(image0.size.width, image0.size.height*[arrImage count]);
    
    UIGraphicsBeginImageContext(size);
    for(int i=0; i<[arrImage count]; i++)
    {
        [arrImage[i] drawInRect:CGRectMake(0,i*image0.size.height,size.width, image0.size.height)];
    }
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return finalImage;
}
- (IBAction)printAddress:(id)sender {
    
    BOOL printerReady = [self checkPrinterReady];
    
    
    UIApplication *app = [UIApplication sharedApplication];
    bgTask = [app beginBackgroundTaskWithExpirationHandler: ^{
        //A handler to be called shortly before the app’s remaining background time reaches 0.
        // You should use this handler to clean up and mark the end of the background task.
    }];
    
    if (printerReady)
    {
        NSLog(@"Will start to print image file...");
        NSLog(@"Printer is ready !");
        
        
        CGImageRef	imgRef;
        for(int i=0; i<[arrPostDetail count]; i++)
        {
            NSString *printerName = [self getPrinterName];
            NSInteger margin;
            if ([printerName isEqualToString:@"Brother QL-720NW"])
            {
                margin = 10;
            }
            else if([printerName isEqualToString:@"Brother RJ-3150"])
            {
                margin = 20;
            }
            else
            {
                margin = 20;
            }
            PrintAddressView *vwPrintAddress = [[PrintAddressView alloc]initWithFrame:CGRectMake(margin, 0, 10, 10)];//use only x position value
            {
                PostDetail *postDetail = arrPostDetail[i];
//                NSInteger receiptProductItemID = postDetail.receiptProductItemID;
//                ReceiptProductItem *receiptProductItem = [Utility getReceiptProductItem:receiptProductItemID];
//                NSInteger receiptID = receiptProductItem.receiptID;
//                NSInteger postCustomerID = [Utility getPostCustomerID:receiptID];
//                PostCustomer *postCustomer = [Utility getPostCustomer:postCustomerID];
                NSString *strAddress = @"";
                NSString *postcode = @"";
                NSString *country = @"";;
//                if(postCustomer)
//                {
//                    NSString *strTel = [postCustomer.telephone isEqualToString:@""]?@"":[NSString stringWithFormat:@"\r\n(โทร. %@)",[Utility insertDash:postCustomer.telephone]];
//                    NSString *street1 = [postCustomer.street1 length]>0?[NSString stringWithFormat:@"%@ ",postCustomer.street1]:@"";
//                    strAddress = [NSString stringWithFormat:@"%@%@\r\n\r\n%@",postCustomer.firstName,strTel,street1];
//
//
//                    postcode = [postCustomer.postcode length]>0?[NSString stringWithFormat:@"\r\n%@ ",postCustomer.postcode]:@"";
//                    country = postCustomer.country;
//                }
                if(postDetail.hasPostCustomer)
                {
                    NSString *strTel = [postDetail.telephone isEqualToString:@""]?@"":[NSString stringWithFormat:@"\r\n(โทร. %@)",[Utility insertDash:postDetail.telephone]];
                    NSString *street1 = [postDetail.street1 length]>0?[NSString stringWithFormat:@"%@ ",postDetail.street1]:@"";
                    strAddress = [NSString stringWithFormat:@"%@%@\r\n\r\n%@",postDetail.customerName,strTel,street1];
                    
                    
                    postcode = [postDetail.postcode length]>0?[NSString stringWithFormat:@"\r\n%@ ",postDetail.postcode]:@"";
                    country = postDetail.country;
                }
                
                
                //ชื่อและที่อยู่ผู้รับ
//                UIFont *font1 = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17];
//                NSDictionary *arialDict = [NSDictionary dictionaryWithObject: font1 forKey:NSFontAttributeName];
//                NSMutableAttributedString *aAttrString1 = [[NSMutableAttributedString alloc] initWithString:@"ชื่อและที่อยู่ผู้รับ" attributes: arialDict];
//                vwPrintAddress.lblHeaderAddress.attributedText = aAttrString1;
//                [self setLabelUnderline:vwPrintAddress.lblHeaderAddress underline:vwPrintAddress.viewUnderline];
                
                
                //customer's address
                UIFont *font2 = [UIFont fontWithName:@"HelveticaNeue" size:17];
                NSDictionary *arialDict2 = [NSDictionary dictionaryWithObject: font2 forKey:NSFontAttributeName];
                NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:strAddress attributes: arialDict2];
                
                //postcode
                UIFont *font22 = [UIFont fontWithName:@"HelveticaNeue" size:26];
                NSDictionary *arialDict22 = [NSDictionary dictionaryWithObject: font22 forKey:NSFontAttributeName];
                NSMutableAttributedString *aAttrString22 = [[NSMutableAttributedString alloc] initWithString:postcode attributes: arialDict22];
                
                //country
                UIFont *font23 = [UIFont fontWithName:@"HelveticaNeue" size:17];
                NSDictionary *arialDict23 = [NSDictionary dictionaryWithObject: font23 forKey:NSFontAttributeName];
                NSMutableAttributedString *aAttrString23 = [[NSMutableAttributedString alloc] initWithString:country attributes: arialDict23];
                
                
                
                [aAttrString2 appendAttributedString:aAttrString22];
                [aAttrString2 appendAttributedString:aAttrString23];
                vwPrintAddress.txtVwAddress.attributedText = aAttrString2;
                
                
                
                //style/color/size
                NSString *remark = [NSString stringWithFormat:@"* %@",postDetail.product];
//                NSString *remark;
//                if([receiptProductItem.productType isEqualToString:@"P"])
//                {
//                    Product *product = [Product getProduct:receiptProductItem.productID];
//                    PostDetail *postDetail = [[PostDetail alloc]init];
//                    postDetail.productName = [ProductName getNameWithProductID:product.productID];
//                    postDetail.color = [Utility getColorName:product.color];
//                    postDetail.size = [Utility getSizeLabel:product.size];
//                    postDetail.product = [NSString stringWithFormat:@"%@/%@/%@",postDetail.productName,postDetail.color,postDetail.size];
//                    remark = [NSString stringWithFormat:@"* %@",postDetail.product];
//                }
//                else if([receiptProductItem.productType isEqualToString:@"C"])
//                {
//                    CustomMade *customMade = [Utility getCustomMade:[receiptProductItem.productID integerValue]];
//                    PostDetail *postDetail = [[PostDetail alloc]init];
//                    postDetail.productName = [ProductName getNameWithCustomMadeID:customMade.customMadeID];
//                    postDetail.color = customMade.body;
//                    postDetail.size = customMade.size;
//                    postDetail.product = [NSString stringWithFormat:@"%@/%@/%@",@"CM",postDetail.color,postDetail.size];
//                    remark = [NSString stringWithFormat:@"* %@",postDetail.product];
//                }
                
                
                UIFont *font3 = [UIFont fontWithName:@"HelveticaNeue" size:17];
                NSDictionary *arialDict3 = [NSDictionary dictionaryWithObject: font3 forKey:NSFontAttributeName];
                NSMutableAttributedString *aAttrString3 = [[NSMutableAttributedString alloc] initWithString:remark attributes: arialDict3];
                vwPrintAddress.lblRemark.attributedText = aAttrString3;
                vwPrintAddress.lblRemark.adjustsFontSizeToFitWidth = true;
                vwPrintAddress.lblRemark.minimumScaleFactor = 0.5;
                
                
                
                //adjust vwprint height and remark y for ql720
                NSString *prnterName = [self getPrinterName];
                if([prnterName isEqualToString:@"Brother QL-720NW"])
                {
                    {
                        CGRect frame = vwPrintAddress.vwPrint.frame;
                        frame.size.height = 390;
                        vwPrintAddress.vwPrint.frame = frame;
                    }
                    {
//                        CGRect frame = vwPrintAddress.lblRemark.frame;
//                        frame.origin.y = 351;
//                        vwPrintAddress.lblRemark.frame = frame;
                        
                        
                        [vwPrintAddress.txtVwAddress sizeToFit];
                        CGRect frame = vwPrintAddress.lblRemark.frame;
                        frame.origin.y = vwPrintAddress.txtVwAddress.frame.origin.y+vwPrintAddress.txtVwAddress.frame.size.height+10;
                        vwPrintAddress.lblRemark.frame = frame;
                    }
                }
                else
                {
                    [vwPrintAddress.vwPrint addSubview:vwPrintAddress.lblHeaderAddress];
                }
            }
            
            
            
            UIImage *imagePrint = [self imageForView:vwPrintAddress.vwPrint];
            imgRef = [imagePrint CGImage];
            if (!imgRef) {
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                               message:@"Bad image"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {}];
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
                return;
            }
            [ptp printImage:imgRef copy:1 timeout:500];
        }
    }
    else
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:@"Please check your Network settings"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    [app endBackgroundTask:bgTask];
}

- (UIImage*)imageByCombiningImage:(UIImage*)image1 withImage:(UIImage*)image2 {
    CGSize size = CGSizeMake(image1.size.width, image1.size.height + image2.size.height);
    
    UIGraphicsBeginImageContext(size);
    
    [image1 drawInRect:CGRectMake(0,0,size.width, image1.size.height)];
    [image2 drawInRect:CGRectMake(0,image1.size.height,size.width, image2.size.height)];
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return finalImage;
}

- (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)imageForView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0);
    
    if ([view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
        [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];  // if we have efficient iOS 7 method, use it ...
    else
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];         // ... otherwise, fall back to tried and true methods
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (NSArray *)getPrinterList
{
    NSArray *list;
    
    NSString *	path = [[NSBundle mainBundle] pathForResource:@"PrinterList" ofType:@"plist"];
    if( path )
    {
        NSDictionary *printerDict = [NSDictionary dictionaryWithContentsOfFile:path];
        
        list = [[NSArray alloc] initWithArray:printerDict.allKeys];
    }
    else{
        NSLog(@"Path is not existed !");
        return nil;
    }
    
    return list;
}
- (void)initStoredSettings
{
    NSUserDefaults *userSettings = [NSUserDefaults standardUserDefaults];
    NSString *selectedPrinterName = [userSettings stringForKey:@"LastSelectedPrinter"];
    if (selectedPrinterName) {
        selectedPrinterIndex = [printerList indexOfObject:selectedPrinterName];
        if (![selectedPrinterName isEqualToString:@"Brother PJ-673"]) {
            if (printKind == DocumentKindToPrintPDF) {
                printKind = DocumentKindToPrintImage;
            }
        }
    }
    else{
        selectedPrinterIndex = 0;
    }
}
- (NSString *)optionViewForPrinter:(NSString *)printerName
{
    NSString *optionView;
    
    if ( !([printerName rangeOfString:@"PT-"].location == NSNotFound) ) {
        optionView = @"OptionView_PT";
    }
    else if( !([printerName rangeOfString:@"QL-"].location == NSNotFound) ){
        optionView = @"OptionView_QL";
    }
    else if (!([printerName rangeOfString:@"PJ-"].location == NSNotFound) ){
        optionView = @"OptionView_PJ";
    }
    else if (!([printerName rangeOfString:@"TD-"].location == NSNotFound) ){
        optionView = @"OptionView_TD";
    }
    else if (!([printerName rangeOfString:@"RJ-"].location == NSNotFound) ){
        optionView = @"OptionView_RJ";
    }
    else{
        optionView = @"Not Supported";
    }
    
    return optionView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
    
    if (printerList == nil) {
        printerList = [[NSArray alloc] initWithArray:[self getPrinterList]];
    }
    [self initStoredSettings];
    
    
    if(self.option == nil){
        NSString *optionViewName = [self optionViewForPrinter:@"Brother RJ-3150"];
        OptionView *newOption = [[OptionView alloc] initWithNibName:optionViewName bundle:nil];
        newOption.printerName = @"Brother RJ-3150";
        self.option = newOption;
    }
    
    printKind = DocumentKindToPrintImage;
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
