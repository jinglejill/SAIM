//
//  PrintQRCodeViewController.m
//  SAIM_UPDATING
//
//  Created by Thidaporn Kijkamjai on 7/8/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "PrintQRCodeViewController.h"
#import "CustomUITableViewCell4.h"
#import "Utility.h"
//#import "CustomIOSAlertView.h"
#import "coretext/coretext.h"
#import "ReachabilityBrother.h"
#import "PrinterView.h"
#import "Utilities.h"
#import "Utility.h"
#import "QRCodeView.h"
#import "ProductName.h"
#import "Color.h"
#import "ProductSize.h"
#import "ProductSales.h"
#import "SharedPushSync.h"
#import "PushSync.h"
#import "QRCodeQuantity.h"
#include "TargetConditionals.h"

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


@interface PrintQRCodeViewController () < UITableViewDataSource, UITableViewDelegate>
{
    NSString *_ip;
    BRPtouchPrinter	*ptp;
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSMutableArray *_mutArrAllProductLabel;
    NSString *_printerName;
}

@end


@implementation PrintQRCodeViewController

@synthesize mutArrQRCodeQuantity,strManufacturingDate,tableViewData,lblPrintStatus;


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
-(BOOL)checkPrinterReady
{
    BRPtouchPrintInfo*	printInfo;
    BOOL	isCarbon;
    BOOL	isDashPrint;
    int		feedMode;
    int copies;
    NSString*		strPaperTmp;
    
    //	Create BRPtouchPrintInfo
    printInfo = [[BRPtouchPrintInfo alloc] init];
    
    
    //	Load Paramator from UserDefault
    NSUserDefaults *printSetting = [NSUserDefaults standardUserDefaults];
    NSString *printerName = [printSetting stringForKey:@"LastSelectedPrinter"];
    if(!printerName)
    {
        printerName = @"Brother QL-720NW";
    }
    _printerName = printerName;
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
    
    
    //    strPaperTmp = [printSetting stringForKey:@"paperName"];
    strPaperTmp =  @"62mm";
    if (0 != [printInfo.strPaperName length]) {
        //        printInfo.strPaperName      = @"RD 76mm";//[printSetting stringForKey:@"paperName"];
        
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
            printInfo.nDensity = 0;
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
        
        //
        if (isFuncAvailable(kFuncAutoCut, printerName)) {
            printInfo.nAutoCutFlag      = 1;//[printSetting integerForKey:@"AutoCut"];
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
    else{
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
                }
                strPath = [[NSBundle mainBundle] pathForResource:strPaper ofType:@"bin"];
            }
            else{
                strPath = [[NSBundle mainBundle] pathForResource:defaultCustomizedPaper(printerName) ofType:@"bin"];
            }
            [ptp setCustomPaperFile:strPath];
        }
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
    
    _homeModel = [[HomeModel alloc] init];
    _homeModel.delegate = self;
    
    {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);
    }
    
    
    _mutArrAllProductLabel = [[NSMutableArray alloc]init];
    
    
    tableViewData.delegate = self;
    tableViewData.dataSource = self;
    
    
    
    
    NSUserDefaults *userSettings = [NSUserDefaults standardUserDefaults];
    //*****fix ค่า ip ไว้จาก db
    [userSettings setObject:[Utility setting:vPrinterIPAddress] forKey:@"ipAddress"];
    [userSettings setObject:[Utility setting:vPrinterModelName] forKey:@"LastSelectedPrinter"];
    //*****fix ค่า ip ไว้จาก db
    
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
    NSInteger countQR = 0;
    for(NSArray *qrCodeGroup in mutArrQRCodeQuantity)
    {
        NSInteger quantity = [qrCodeGroup[3] integerValue];
        countQR += quantity;
    }
    NSString *strCountQR = [NSString stringWithFormat:@"%ld",countQR];
    [_homeModel insertItems:dbItemRunningID withData:strCountQR];
}

-(void)removeOverlayViewConnectionFail
{
    //    [self removeOverlayViews];
    [self connectionFail];
}

- (void)itemsInsertedWithReturnID:(NSInteger)ID
{
    //    [self removeOverlayViews];
    
    //สร้าง productcode จาก mutarr
    for(NSArray *qrCodeGroup in mutArrQRCodeQuantity)
    {
        ProductName *productName = qrCodeGroup[0];
        Color *color = qrCodeGroup[1];
        ProductSize *productSize = qrCodeGroup[2];
        NSInteger quantity = [qrCodeGroup[3] integerValue];
        ProductSales *productSales = [Utility getProductSales:productName.productNameID color:color.code size:productSize.code productSalesSetID:@"0"];
        
        for(int i=0; i<quantity; i++)
        {
            Product *product = [[Product alloc]init];
            product.productID = [NSString stringWithFormat:@"%06ld",ID++];
            product.productCode = @"";
            product.productCategory2 = productName.productCategory2;
            product.productCategory1 = productName.productCategory1;
            product.productName = productName.code;
            product.color = color.code;
            product.size = productSize.code;
            product.manufacturingDate = [Utility formatDate:strManufacturingDate fromFormat:@"dd/MM/yyyy" toFormat:@"yyyy-MM-dd"];
            product.status = @"";
            product.eventID = -1;
            product.remark = @"";
            
            //can generate qr code now
            QRCodeQuantity *qrCodeQuantity = [[QRCodeQuantity alloc]init];
            ProductCategory2 *productCategory2 = [Utility getProductCategory2:productName.productCategory2];
            qrCodeQuantity.productCategory2 = productCategory2.name;
            qrCodeQuantity.productName = productName.name;
            qrCodeQuantity.color = color.name;
            qrCodeQuantity.size = productSize.sizeLabel;
            qrCodeQuantity.price = productSales.price;
            qrCodeQuantity.qrCode = [self getStringForQRCode:product];
            [_mutArrAllProductLabel addObject:qrCodeQuantity];
        }
    }
    NSSortDescriptor *sortDescriptor0 = [[NSSortDescriptor alloc] initWithKey:@"_productCategory2" ascending:YES];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_productName" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_color" ascending:YES];
    NSSortDescriptor *sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:@"_size" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor0,sortDescriptor1,sortDescriptor2,sortDescriptor3, nil];
    NSArray *sortArray = [_mutArrAllProductLabel sortedArrayUsingDescriptors:sortDescriptors];
    _mutArrAllProductLabel = [sortArray mutableCopy];
    [tableViewData reloadData];
}

-(void)itemsDownloaded:(NSArray *)items
{
    {
        PushSync *pushSync = [[PushSync alloc]init];
        pushSync.deviceToken = [Utility deviceToken];
        [_homeModel updateItems:dbPushSyncUpdateByDeviceToken withData:pushSync];
    }
    
    
    [Utility itemsDownloaded:items];
    [self removeOverlayViews];
    [self loadViewProcess];
}

- (void)itemsFail
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[Utility getConnectionLostTitle]
                                                                   message:[Utility getConnectionLostMessage]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [self loadingOverlayView];
                                                              [_homeModel downloadItems:dbMaster];
                                                          }];
    
    [alert addAction:defaultAction];
    dispatch_async(dispatch_get_main_queue(),^ {
        [self presentViewController:alert animated:YES completion:nil];
    } );
}

- (void)itemsUpdated
{
    
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
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_mutArrAllProductLabel count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomUITableViewCell4 *cell;
    if (cell == nil) {
        cell = [[CustomUITableViewCell4 alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"QRCodeCell"];
    }
    
    
    NSInteger item = indexPath.item;
    if([_mutArrAllProductLabel count] == 0)
    {
        return cell;
    }
    QRCodeQuantity *qrCodeQuantity = _mutArrAllProductLabel[item];
    
    
    //vwPrint (316,371)
    float margin = 20;
    //    float qrCodeWidth = 70;
    float qrCodeWidth = 90;
    float vwPrintWidth = cell.frame.size.width;//cell.vwPrint.frame.size.width;
    float labelWidth = vwPrintWidth-qrCodeWidth-2*margin;
    cell.vwPrint.frame = CGRectMake(0,0,vwPrintWidth,160);
    cell.lblProductName.frame = CGRectMake(margin,15,labelWidth,50);
    cell.lblProductName.text = qrCodeQuantity.productName;
    
    
    cell.lblColor.frame = CGRectMake(margin,65,labelWidth,50);
    cell.lblColor.text = qrCodeQuantity.color;
    
    
    cell.lblPrice.frame = CGRectMake(margin,120,labelWidth,25);
    cell.lblPrice.text = [NSString stringWithFormat:@"%@ Baht",[Utility formatBaht:qrCodeQuantity.price]];
    

    cell.lblSize.frame = CGRectMake(margin+labelWidth,105,qrCodeWidth,50);
    cell.lblSize.text = qrCodeQuantity.size;
    

    cell.imgVwQRCode.frame = CGRectMake(margin+labelWidth,margin-10,qrCodeWidth,qrCodeWidth);
    cell.imgVwQRCode.image = [self generateQRCodeWithString:qrCodeQuantity.qrCode scale:5.0f];
    {
        CGSize sizeLblProductName = [cell.lblProductName.text sizeWithAttributes:@{ NSFontAttributeName: cell.lblProductName.font}];
        CGSize sizeLblColor = [cell.lblColor.text sizeWithAttributes:@{ NSFontAttributeName: cell.lblColor.font}];
        NSLog(@"size lblproductname width: %f,%f",cell.lblProductName.bounds.size.width,sizeLblProductName.width);
        NSLog(@"size sizeLblColor width: %f,%f",cell.lblColor.bounds.size.width,sizeLblColor.width);
        if (sizeLblProductName.width > cell.lblProductName.bounds.size.width || sizeLblColor.width > cell.lblColor.bounds.size.width)
            
        {
            cell.lblProductName.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:28];
            cell.lblColor.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:28];
            cell.lblPrice.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
            
        }
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

-(NSString *)getStringForQRCode:(Product *)product
{
    NSString *line0Format = [NSString stringWithFormat:@"SAIM %@",[Utility makeFirstLetterUpperCaseOtherLower:[Utility dbName]]];
    NSString *line1 = [Utility getProductCode:product];
    NSString *line2 = @"End";
    
    return [NSString stringWithFormat:@"%@\n%@\n%@",line0Format,line1,line2];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableViewData deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 160;
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
- (IBAction)printQRCode:(id)sender {
    
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
        
        
        //	Get ImageRef
//        UIImage *combineImage;
        for(int i=0; i<[_mutArrAllProductLabel count]; i++)
        {
            NSInteger margin = 10;
//            if ([_printerName isEqualToString:@"Brother QL-720NW"])
//            {
//                margin = 10;
//            }
//            else if([_printerName isEqualToString:@"Brother RJ-3150"])
//            {
//                margin = 20;
//            }
//            else
//            {
//                margin = 20;
//            }
            QRCodeView *vwQRCode = [[QRCodeView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 188)];
            {
                
                QRCodeQuantity *qrCodeQuantity = _mutArrAllProductLabel[i];
                NSString *strProductName = qrCodeQuantity.productName;
                NSString *strColor = qrCodeQuantity.color;
                NSString *strSize = qrCodeQuantity.size;
                NSString *strPrice = qrCodeQuantity.price;
                NSString *strQRCode = qrCodeQuantity.qrCode;
                
                
                float qrCodeWidth = 110;//90;
                float vwPrintWidth = vwQRCode.vwPrint.frame.size.width;
                float labelWidth = vwPrintWidth-qrCodeWidth-2*margin;//fixed label width
                vwQRCode.lblProductName.frame = CGRectMake(margin,15,labelWidth,50);
                vwQRCode.lblProductName.text = strProductName;
                
                vwQRCode.lblColor.frame = CGRectMake(margin,65,labelWidth,50);
                vwQRCode.lblColor.text = strColor;
                
                vwQRCode.lblPrice.frame = CGRectMake(margin,120,labelWidth,25);
                vwQRCode.lblPrice.text = [NSString stringWithFormat:@"%@ Baht",[Utility formatBaht:strPrice]];
                

                vwQRCode.lblSize.frame = CGRectMake(margin+labelWidth,130,qrCodeWidth,50);
                vwQRCode.lblSize.text = strSize;
                

                vwQRCode.imgVwQRCode.frame = CGRectMake(margin+labelWidth,margin-10,qrCodeWidth,qrCodeWidth);
                vwQRCode.imgVwQRCode.image = [self generateQRCodeWithString:strQRCode scale:5.0f];
                
                
                {
                    CGSize sizeLblProductName = [vwQRCode.lblProductName.text sizeWithAttributes:@{ NSFontAttributeName: vwQRCode.lblProductName.font}];
                    CGSize sizeLblColor = [vwQRCode.lblColor.text sizeWithAttributes:@{ NSFontAttributeName: vwQRCode.lblColor.font}];
                    NSLog(@"size lblproductname width: %f,%f",vwQRCode.lblProductName.bounds.size.width,sizeLblProductName.width);
                    NSLog(@"size sizeLblColor width: %f,%f",vwQRCode.lblColor.bounds.size.width,sizeLblColor.width);
                    if (sizeLblProductName.width > vwQRCode.lblProductName.bounds.size.width || sizeLblColor.width > vwQRCode.lblColor.bounds.size.width)
                        
                    {
                        vwQRCode.lblProductName.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:35];
                        vwQRCode.lblColor.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:35];
                        vwQRCode.lblPrice.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:25];
                        
                    }
                }

            }
            UIImage *imagePrint = [self imageForView:vwQRCode.vwPrint];
            
            
            
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
            [ptp printImage:imgRef copy:1 timeout:1000];
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

-(UIImage *) generateQRCodeWithString:(NSString *)string scale:(CGFloat) scale{
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding ];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:stringData forKey:@"inputMessage"];
    [filter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    // Render the image into a CoreGraphics image
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:[filter outputImage] fromRect:[[filter outputImage] extent]];
    
    //Scale the image usign CoreGraphics
    UIGraphicsBeginImageContext(CGSizeMake([[filter outputImage] extent].size.width * scale, [filter outputImage].extent.size.width * scale));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *preImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //Cleaning up .
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    
    // Rotate the image
    UIImage *qrImage = [UIImage imageWithCGImage:[preImage CGImage]
                                           scale:[preImage scale]
                                     orientation:UIImageOrientationDownMirrored];
    return qrImage;
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


- (void) connectionFail
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[Utility subjectNoConnection]
                                                                   message:[Utility detailNoConnection]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              //                                                              exit(0);
                                                          }];
    
    [alert addAction:defaultAction];
    dispatch_async(dispatch_get_main_queue(),^ {
        [self presentViewController:alert animated:YES completion:nil];
    } );
}

@end
