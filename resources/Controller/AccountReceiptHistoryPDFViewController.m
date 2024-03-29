//
//  AccountReceiptHistoryPDFViewController.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 2/13/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import "AccountReceiptHistoryPDFViewController.h"
#import "CustomPrintPageRenderer.h"
#import "InvoiceComposer.h"
#import "Utility.h"
#import "AccountReceipt.h"
#import "AccountReceiptProductItem.h"
#import "ProductName.h"
#import "ExportManager.h"


@interface AccountReceiptHistoryPDFViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    InvoiceComposer *invoiceComposer;
    NSString *htmlContent;
    NSMutableArray *htmlContentList;
    NSMutableArray *_accountReceiptList;
    NSMutableArray *_accountReceiptProductItemList;
    NSString *pdfFileName;
    NSMutableArray *receiptInfoList;
    NSString *_strAccountReceiptHistoryDate;
    NSInteger runningPage;
    NSMutableArray *_viewPrintFormatterList;
}
@end

@implementation AccountReceiptHistoryPDFViewController
@synthesize webPreview;
@synthesize accountReceiptHistory;
@synthesize strReceiptDateFrom;
@synthesize strReceiptDateTo;


- (void)loadView
{
    [super loadView];
    
    webPreview.navigationDelegate = self;
    _viewPrintFormatterList = [[NSMutableArray alloc]init];
    
    _homeModel = [[HomeModel alloc] init];
    _homeModel.delegate = self;
    
    
    {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);
    }
    
    
    
    [self loadingOverlayView];
    
    if(accountReceiptHistory)
    {
        [_homeModel downloadItems:dbAccountReceiptHistoryDetail condition:accountReceiptHistory];
    }
    else
    {
        [_homeModel downloadItems:dbAccountReceiptByPeriod condition:@[strReceiptDateFrom,strReceiptDateTo]];
    }
}

- (void)itemsDownloaded:(NSArray *)items
{
    [self removeOverlayViews];
    int i=0;
    _accountReceiptList = items[i++];
    _accountReceiptProductItemList = items[i++];
    
    if(accountReceiptHistory)
    {
        _accountReceiptList = [AccountReceipt getAccountReceiptSortByAccountReceiptID:_accountReceiptList];
    }
    else
    {
        //reorder _accountReceipt for print 2 receipts in 1 A4 page
        _accountReceiptList = [AccountReceipt getAccountReceiptSortByAccountReceiptID:_accountReceiptList];
        NSInteger firstHalfCount = ceil([_accountReceiptList count]/2.0);
        NSArray *receiptLeftList = [_accountReceiptList subarrayWithRange:NSMakeRange(0, firstHalfCount)];
        NSArray *receiptRightList = [_accountReceiptList subarrayWithRange:NSMakeRange(firstHalfCount,[_accountReceiptList count]-firstHalfCount)];
        
        int i = 0;
        NSMutableArray *accountReceiptTempList = [[NSMutableArray alloc]init];
        for(AccountReceipt *receiptLeft in receiptLeftList)
        {
            [accountReceiptTempList addObject:receiptLeft];
            if(i<[receiptRightList count])
            {
                AccountReceipt *receiptRight = receiptRightList[i++];
                [accountReceiptTempList addObject:receiptRight];
            }
        }
        _accountReceiptList = accountReceiptTempList;
    }
    
    [self createReceiptAsHtml];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)createReceiptAsHtml
{
    int i = 0;
    receiptInfoList = [[NSMutableArray alloc]init];
    for(AccountReceipt *accountReceipt in _accountReceiptList)
    {
//        //test*****
//        if(accountReceipt.accountReceiptID != 13090)
//        {
//            continue;
//        }
//        //******
        
        
//        option1
        if(i == 300)
        {
            break;
        }
        i++;
        

//        //option2
//        if(i < 300)
//        {
//            i++;
//            continue;
//        }
//        else
//        {
//            i++;
//        }

        
        NSString *strReceiptDate = [Utility formatDate:accountReceipt.receiptDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"dd/MM/yyyy"];
        NSString *taxCustomerName = [accountReceipt.taxCustomerName isEqualToString:@""]?@"สด":accountReceipt.taxCustomerName;
        NSString *taxCustomerAddress = [accountReceipt.taxCustomerAddress isEqualToString:@""]?@"-":accountReceipt.taxCustomerAddress;
        NSString *taxNo = [accountReceipt.taxNo isEqualToString:@""]?@"-":accountReceipt.taxNo;
        NSMutableDictionary *receiptInfo = [[NSMutableDictionary alloc]init];
        [receiptInfo setValue:accountReceipt.receiptNo forKey:@"receiptNo"];
        [receiptInfo setValue:strReceiptDate forKey:@"receiptDate"];
        [receiptInfo setValue:taxCustomerName forKey:@"customerName"];
        [receiptInfo setValue:taxCustomerAddress forKey:@"customerAddress"];
        [receiptInfo setValue:taxNo forKey:@"customerTaxNo"];
        _strAccountReceiptHistoryDate = accountReceipt.accountReceiptHistoryDate;
        
        
        
        float grandTotalAmount = 0;
        float receiptDiscountFromItem = 0;
        NSMutableArray *items = [[NSMutableArray alloc]init];
        NSMutableArray *accountReceiptProductItemList = [AccountReceiptProductItem getAccountReceiptProductItem:_accountReceiptProductItemList accountReceiptID:accountReceipt.accountReceiptID];
        for(AccountReceiptProductItem *accountReceiptProductItem in accountReceiptProductItemList)
        {
            NSMutableDictionary *item = [[NSMutableDictionary alloc]init];
            ProductName *productName = accountReceiptProductItem.productNameID==56?[ProductName getProductName:15]:[ProductName getProductName:accountReceiptProductItem.productNameID];

            //test
            NSString *strItemNo;
            if(accountReceiptProductItem.productNameID==2001)
            {
                strItemNo = @"1010117";
            }
            else if(accountReceiptProductItem.productNameID==2002)
            {
                strItemNo = @"2010101";
            }
            else if(accountReceiptProductItem.productNameID==2003)
            {
                strItemNo = @"2010102";
            }
            else if(accountReceiptProductItem.productNameID==2072)
            {
                strItemNo = @"201010‐2";
            }
            else
            {
                strItemNo = [ProductName getProductCode:accountReceiptProductItem.productNameID];
            }
            NSString *strQuantity = [NSString stringWithFormat:@"%f",accountReceiptProductItem.quantity];
            NSString *strAmountPerUnit = [NSString stringWithFormat:@"%f",accountReceiptProductItem.amountPerUnit];
            NSString *strItemDiscount = [NSString stringWithFormat:@"%f",accountReceiptProductItem.itemDiscount];
            float totalAmount = accountReceiptProductItem.quantity*accountReceiptProductItem.amountPerUnit;
            float itemDiscount = accountReceiptProductItem.quantity*accountReceiptProductItem.itemDiscount;

            NSString *strTotalAmount = [NSString stringWithFormat:@"%f",totalAmount];
            NSString *strProductName;
            if([productName.productCategory2 isEqualToString:@"01"])
            {
                strProductName = [NSString stringWithFormat:@"รองเท้ารุ่น %@",productName.name];
            }
            else if([productName.productCategory2 isEqualToString:@"02"])
            {
                if([productName.name isEqualToString:@"CM กันกัด"] || [productName.name isEqualToString:@"ฟองน้ำเสริมหัว"])//temp
                {
                    strProductName = @"รองเท้ารุ่น Sock";
                }
                else
                {
                    strProductName = [NSString stringWithFormat:@"เครื่องประดับรุ่น %@",productName.name];
                }
            }
            else if([productName.productCategory2 isEqualToString:@"03"])
            {
                if([productName.name isEqualToString:@"Pearl strap"] || [productName.name isEqualToString:@"Gold chain"] || [productName.name isEqualToString:@"Adjustable chain strap"])
                {
                    strProductName = [NSString stringWithFormat:@"กระเป๋ารุ่น %@",@"Accessories"];
                }
                else if([productName.name isEqualToString:@"Laptop case"])
                {
                    strProductName = [NSString stringWithFormat:@"กระเป๋ารุ่น %@",@"Juliet"];
                }
                else
                {
                    strProductName = [NSString stringWithFormat:@"กระเป๋ารุ่น %@",productName.name];
                }
            }
            else
            {
                strProductName = [NSString stringWithFormat:@"สินค้ารุ่น %@",productName.name];
            }
//            NSString *strProductName = [NSString stringWithFormat:@"รองเท้ารุ่น %@",productName.name];
            strQuantity = [Utility formatBaht:strQuantity withMinFraction:2 andMaxFraction:2];
            strAmountPerUnit = [Utility formatBaht:strAmountPerUnit withMinFraction:2 andMaxFraction:2];
            strItemDiscount = [Utility formatBaht:strItemDiscount withMinFraction:2 andMaxFraction:2];
//            strAmountPerUnit = @"1,618.505";//test
            strTotalAmount = [Utility formatBaht:strTotalAmount withMinFraction:2 andMaxFraction:2];
//            strTotalAmount = @"3,237.01";//test
            

            //temp
            if([strProductName isEqualToString:@"รองเท้ารุ่น Sock U"] || [strProductName isEqualToString:@"รองเท้ารุ่น Sock V"] || [strProductName isEqualToString:@"รองเท้ารุ่น Sock O"] || [strProductName isEqualToString:@"รองเท้ารุ่น Sock Taylor"] || [strProductName isEqualToString:@"รองเท้ารุ่น CM กันกัด"] || [productName.name isEqualToString:@"ฟองน้ำเสริมหัว"])
            {
                strProductName = @"รองเท้ารุ่น Sock";
            }
            else if([strProductName isEqualToString:@"รองเท้ารุ่น Sale 2"])
            {
                strProductName = @"รองเท้ารุ่น Rachael";
            }

            
            [item setValue:strItemNo forKey:@"itemNo"];
            [item setValue:strProductName forKey:@"itemDesc"];
            [item setValue:strQuantity forKey:@"quantity"];
            [item setValue:strAmountPerUnit forKey:@"amountPerUnit"];
            [item setValue:strItemDiscount forKey:@"itemDiscount"];
            [item setValue:strTotalAmount forKey:@"totalAmount"];



            [items addObject:item];
            grandTotalAmount += totalAmount;
            receiptDiscountFromItem += itemDiscount;
        }

//        //test
//        NSArray *arrItemNo = @[@"KT276",@"ML04",@"ML01-1",@"ML01-1",@"ML03",@"ML03",@"ML03",@"ML06-2",@"ML06-2"];
//        NSArray *arrDesc = @[@"size 35",@"size 42",@"size 40",@"size 41",@"size 37",@"size 40",@"size 41",@"size 35",@"size 38"];
//        NSArray *arrAmountPerUnit = @[@"374.50",@"374.50",@"535.00",@"535.00",@"374.50",@"374.50",@"374.50",@"642.00",@"642.00"];
//        for(int i=0; i<arrItemNo.count; i++)
//        {
//            NSMutableDictionary *item = [[NSMutableDictionary alloc]init];
//
//
//
//
//            [item setValue:arrItemNo[i] forKey:@"itemNo"];
//            [item setValue:arrDesc[i] forKey:@"itemDesc"];
//            [item setValue:@"1.00" forKey:@"quantity"];
//            [item setValue:arrAmountPerUnit[i] forKey:@"amountPerUnit"];
//            [item setValue:arrAmountPerUnit[i] forKey:@"totalAmount"];
//
//
//
//            [items addObject:item];
////            grandTotalAmount += totalAmount;
//        }
//        grandTotalAmount = 4226.5;//test
////        ******
        
        NSInteger countAddRow = 9-[items count];
        for(int i=0; i<countAddRow; i++)
        {
            NSMutableDictionary *item = [[NSMutableDictionary alloc]init];
            [item setValue:@"&nbsp;" forKey:@"itemNo"];///*************
            [item setValue:@"" forKey:@"itemDesc"];
            [item setValue:@"" forKey:@"quantity"];
            [item setValue:@"" forKey:@"amountPerUnit"];
            [item setValue:@"" forKey:@"itemDiscount"];
            [item setValue:@"" forKey:@"totalAmount"];
            
            [items addObject:item];
        }
        [receiptInfo setValue:items forKey:@"items"];
        
        
//        float discount = roundf(accountReceipt.receiptDiscount*100)/100;
        float discount = roundf(receiptDiscountFromItem*100)/100;
        float totalAmountIncludeVat = grandTotalAmount - discount;
        float vat = roundf(totalAmountIncludeVat*7/107*100)/100;
        NSString *strGrandTotalAmount = [NSString stringWithFormat:@"%f",grandTotalAmount];
        NSString *strDiscount = [NSString stringWithFormat:@"%f",discount];
        NSString *strVat = [NSString stringWithFormat:@"%f",vat];
        NSString *strTotalAmountBeforeVat = [NSString stringWithFormat:@"%f",totalAmountIncludeVat-vat];
        NSString *strTotalAmountIncludeVat = [NSString stringWithFormat:@"%f",totalAmountIncludeVat];
        strGrandTotalAmount = [Utility formatBaht:strGrandTotalAmount withMinFraction:2 andMaxFraction:2];
        strDiscount = [Utility formatBaht:strDiscount withMinFraction:2 andMaxFraction:2];
        strVat = [Utility formatBaht:strVat withMinFraction:2 andMaxFraction:2];
        strTotalAmountBeforeVat = [Utility formatBaht:strTotalAmountBeforeVat withMinFraction:2 andMaxFraction:2];
        strTotalAmountIncludeVat = [Utility formatBaht:strTotalAmountIncludeVat withMinFraction:2 andMaxFraction:2];
    
        
                
        [receiptInfo setValue:strGrandTotalAmount forKey:@"totalAmount"];
        [receiptInfo setValue:strDiscount forKey:@"discount"];
        [receiptInfo setValue:strTotalAmountBeforeVat forKey:@"totalAmountBeforeVat"];
        [receiptInfo setValue:strVat forKey:@"vat"];
        [receiptInfo setValue:strTotalAmountIncludeVat forKey:@"totalAmountIncludeVat"];
        [receiptInfoList addObject:receiptInfo];


//        //test
//        [receiptInfo setValue:@"3,237.01" forKey:@"totalAmount"];
//        [receiptInfo setValue:@"0.00" forKey:@"discount"];
//        [receiptInfo setValue:@"3025.24" forKey:@"totalAmountBeforeVat"];
//        [receiptInfo setValue:@"276.50" forKey:@"vat"];
//        [receiptInfo setValue:@"3,237.01" forKey:@"totalAmountIncludeVat"];
//        [receiptInfoList addObject:receiptInfo];
    }
    
    runningPage = 0;
    htmlContent = @"";
    htmlContentList = [[NSMutableArray alloc]init];
//    NSMutableArray *webViewList = [[NSMutableArray alloc]init];
    for(int i=0; i<[receiptInfoList count]; i++)
    {
//        WKWebView *webPreview = [[WKWebView alloc] initWithFrame:self.webPreview.frame];
//        webPreview.navigationDelegate = self;
        NSMutableDictionary *receiptInfo = receiptInfoList[i];
        invoiceComposer = [[InvoiceComposer alloc]init];
        NSString *invoiceHtml = [invoiceComposer renderInvoice:receiptInfo[@"receiptNo"] invoiceDate:receiptInfo[@"receiptDate"] customerName:receiptInfo[@"customerName"] customerAddress:receiptInfo[@"customerAddress"] customerTaxNo:receiptInfo[@"customerTaxNo"] items:receiptInfo[@"items"] totalAmount:receiptInfo[@"totalAmount"] discount:receiptInfo[@"discount"] totalAmountBeforeVat:receiptInfo[@"totalAmountBeforeVat"] vat:receiptInfo[@"vat"] totalAmountIncludeVat:receiptInfo[@"totalAmountIncludeVat"]];
        
//        webPreview.tag = i;
//        [webPreview loadHTMLString:invoiceHtml baseURL:[NSURL URLWithString:@""]];


//        //for individual receipt//test
//        if([receiptInfo[@"receiptNo"] isEqualToString: @"10-20/092"])
//        {
//            [webPreview loadHTMLString:invoiceHtml baseURL:[NSURL URLWithString:@""]];
//        }
//////
   
//        NSString *runningReceiptNo = [ receiptInfo[@"receiptNo"] stringByReplacingOccurrencesOfString:@"01-21/" withString:@""];
        htmlContent = [NSString stringWithFormat:@"%@%@",htmlContent,invoiceHtml];
//        if([receiptInfo[@"customerName"] isEqualToString:@"GHWAIN TECH. CO., LTD."])
        {
            [htmlContentList addObject:invoiceHtml];
        }
    }
    
    //load one by one
//    [webPreview loadHTMLString:htmlContent baseURL:[NSURL URLWithString:@""]];
    [webPreview loadHTMLString:htmlContentList[0] baseURL:[NSURL URLWithString:@""]];
//    [webPreview loadHTMLString:htmlContentList[runningPage] baseURL:[NSURL URLWithString:@""]];//test
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSLog(@"didFinishNavigation");
    
    [_viewPrintFormatterList addObject: webView.viewPrintFormatter];
    
    if(_viewPrintFormatterList.count < htmlContentList.count)
    {
        WKWebView *webPreview = [[WKWebView alloc] initWithFrame:self.view.frame];
        webPreview.navigationDelegate = self;
        [self.view addSubview:webPreview];
        [webPreview loadHTMLString:htmlContentList[_viewPrintFormatterList.count] baseURL:[NSURL URLWithString:@""]];
    }
    else
    {
        NSString *strFileName = [NSString stringWithFormat:@"Tax_Invoice_%@",[Utility formatDate:_strAccountReceiptHistoryDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd_HH:mm:ss"]];
        CustomPrintPageRenderer *printPageRenderer = [[CustomPrintPageRenderer alloc]init];
        pdfFileName = [printPageRenderer exportHTMLContentToPDFWIthPrintFormatterList:_viewPrintFormatterList fileName:strFileName];
    }
    
    
//    [_viewPrintFormatterList addObject: [webView.viewPrintFormatter copyWithZone:NULL]];
    
    
//    //******test********
//    NSString *strFileName = [NSString stringWithFormat:@"Tax_Invoice_%ld_%@",runningPage,[Utility formatDate:_strAccountReceiptHistoryDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd_HH:mm:ss"]];
//    CustomPrintPageRenderer *printPageRenderer = [[CustomPrintPageRenderer alloc]init];
//    pdfFileName = [printPageRenderer exportHTMLContentToPDFWIthPrintFormatter:webView.viewPrintFormatter fileName:strFileName];
//    //******test********
//
//    return;
    
//    
//    if([receiptInfoList count] == [_viewPrintFormatterList count])//test
//    {
//        NSString *strFileName = [NSString stringWithFormat:@"Tax_Invoice_%@",[Utility formatDate:_strAccountReceiptHistoryDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd_HH:mm:ss"]];
//        CustomPrintPageRenderer *printPageRenderer = [[CustomPrintPageRenderer alloc]init];
//        pdfFileName = [printPageRenderer exportHTMLContentToPDFWIthPrintFormatterList:_viewPrintFormatterList fileName:strFileName];
////        pdfFileName = [printPageRenderer exportHTMLContentToPDF:htmlContentList fileName:strFileName];
//
//    }
//    else//test
//    {
//        runningPage++;
//        [webPreview loadHTMLString:htmlContentList[runningPage] baseURL:[NSURL URLWithString:@""]];//test
//    }
    
    
    
//    if(runningPage == [htmlContentList count]-1)
//    {
//        NSString *strFileName = [NSString stringWithFormat:@"Tax_Invoice_%@",[Utility formatDate:_strAccountReceiptHistoryDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd_HH:mm:ss"]];
//
//        CustomPrintPageRenderer *printPageRenderer = [[CustomPrintPageRenderer alloc]init];
//        pdfFileName = [printPageRenderer exportHTMLContentToPDF:htmlContentList fileName:strFileName];
//    }
//    else
//    {
//        runningPage++;
//        [webPreview loadHTMLString:htmlContentList[runningPage] baseURL:[NSURL URLWithString:@""]];
//    }
}

-(NSString *) convertImageAtPathToBase64String:(NSString *)fileName
{
    NSData *imageData = UIImagePNGRepresentation([UIImage imageNamed:@"oneSignature3.png"]);
    NSString * base64String = [imageData base64EncodedStringWithOptions:0];
    return [NSString stringWithFormat:@"data:image/png;base64,%@",base64String];
//
//    let paths = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
//    let documentsURL = paths[0]
//    let imageFileURL = documentsURL.URLByAppendingPathComponent(fileName)
//    if let imageData = NSData(contentsOfURL: imageFileURL) {
//        let strBase64:String = imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
//        print(strBase64)
//        return "data:image/gif;base64,\(strBase64)"
//    }
//    return ""
}

- (IBAction)emailPDF:(id)sender
{
//    exportManager not show webView on screen, right now delegate not working, don't know why
//    ExportManager *exportManager = [[ExportManager alloc]init];
//    [exportManager exportPDF:htmlContent completion:^(BOOL success, NSData * _Nonnull pdfData, NSError * _Nonnull error)
//    {
//       if(success)
//       {
//            NSString *strFileName = [NSString stringWithFormat:@"Tax_Invoice_%@",[Utility formatDate:_strAccountReceiptHistoryDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd_HH:mm:ss"]];
//            NSString *pdfFileName = [NSString stringWithFormat:@"%@/%@.pdf",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0],strFileName];
//
//
//            [pdfData writeToFile:pdfFileName atomically:YES];
//            NSLog(@"pdf filename: %@",pdfFileName);
//       }
//    }];


////    //old with uiWebView work when run on device but not on simulator
//    [self loadingOverlayView];
//
//
//    NSString *strFileName = [NSString stringWithFormat:@"Tax_Invoice_%@",[Utility formatDate:_strAccountReceiptHistoryDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd_HH:mm:ss"]];
//    CustomPrintPageRenderer *printPageRenderer = [[CustomPrintPageRenderer alloc]init];
//    pdfFileName = [printPageRenderer exportHTMLContentToPDF:htmlContentList fileName:strFileName];
//
    [self performSelectorOnMainThread: @selector(mail:) withObject:pdfFileName waitUntilDone:NO];
////*********



    //NDHTML this is work for 1 pdf page, if want to use->need to modify the code
//    NSString *strFileName = [NSString stringWithFormat:@"Tax_Invoice_%@",[Utility formatDate:_strAccountReceiptHistoryDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd_HH:mm:ss"]];
//    NSString *pdfFileName = [NSString stringWithFormat:@"%@/%@.pdf",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0],strFileName];
//    NSLog(@"file name : %@",pdfFileName);
//    self.PDFCreator = [NDHTMLtoPDF createPDFWithHTML:htmlContentList[0] pathForPDF:pdfFileName delegate:self pageSize:kPaperSizeA4 margins:UIEdgeInsetsMake(10, 5, 10, 5)];
}

//#pragma mark NDHTMLtoPDFDelegate

//- (void)HTMLtoPDFDidSucceed:(NDHTMLtoPDF*)htmlToPDF
//{
//    NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did succeed (%@ / %@)", htmlToPDF, htmlToPDF.PDFpath];
//    NSLog(@"%@",result);
////    self.resultLabel.text = result;
//}
//
//- (void)HTMLtoPDFDidFail:(NDHTMLtoPDF*)htmlToPDF
//{
//    NSString *result = [NSString stringWithFormat:@"HTMLtoPDF did fail (%@)", htmlToPDF];
//    NSLog(@"%@",result);
////    self.resultLabel.text = result;
//}

- (void) mail: (NSString*) filePath
{
    [self removeOverlayViews];
    BOOL success = NO;
    if ([MFMailComposeViewController canSendMail]) {
        // TODO: autorelease pool needed ?
        NSData* database = [NSData dataWithContentsOfFile: filePath];
        
        if (database != nil)
        {
            NSString *strSubject = [NSString stringWithFormat:@"Tax_Invoice_%@",[Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd_HH:mm:ss"]];
            MFMailComposeViewController* picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self;
            [picker setSubject:strSubject];
            
            NSString* filename = [filePath lastPathComponent];
            [picker addAttachmentData: database mimeType:@"application/octet-stream" fileName: filename];
            NSString* emailBody = @"";
            [picker setMessageBody:emailBody isHTML:YES];
            
            
            [self presentViewController:picker animated:YES completion:nil];
            success = YES;
        }
    }
    
    if (!success)
    {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:@"Unable to send attachment!"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
        NSLog(@"Mail cancelled");
        break;
        case MFMailComposeResultSaved:
        NSLog(@"Mail saved");
        break;
        case MFMailComposeResultSent:
        {
            NSLog(@"Mail sent");
        }
        break;
        case MFMailComposeResultFailed:
        NSLog(@"Mail sent failure: %@", [error localizedDescription]);
        break;
        default:
        break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
        //            NSLog(@"Mail cancelled");
        break;
        case MFMailComposeResultSaved:
        //            NSLog(@"Mail saved");
        break;
        case MFMailComposeResultSent:
        {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                           message:@"Mail sent successfully"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      
                                                                  }];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        break;
        case MFMailComposeResultFailed:
        //            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
        break;
        default:
        break;
    }
    
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
