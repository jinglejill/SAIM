//
//  AccountReceiptPDFViewController.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 2/7/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import "AccountReceiptPDFViewController.h"
#import "CustomPrintPageRenderer.h"
#import "InvoiceComposer.h"
#import "Utility.h"
#import "AccountReceipt.h"
#import "AccountReceiptProductItem.h"
#import "ProductName.h"
#import "AccountInventorySummary.h"
#import "AccountInventory.h"
#import "AccountMapping.h"


@interface AccountReceiptPDFViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    InvoiceComposer *invoiceComposer;
    NSString *htmlContent;
    NSMutableArray *htmlContentList;
    NSMutableArray *salesProductAndPriceBillingsOnlyList;
    NSMutableArray *_postCustomerList;
    NSMutableArray *_accountReceiptList;
    NSMutableArray *_accountReceiptProductItemList;
    NSMutableArray *_accountMappingList;
    NSMutableArray *_accountInventoryList;
    NSString *_pdfFileName;
    NSMutableArray *receiptInfoList;
    NSString *_strAccountReceiptHistoryDate;
    
    
    
    NSString *pdfFileName;
}
@end

@implementation AccountReceiptPDFViewController
@synthesize webPreview;
@synthesize saleProductAndPriceList;
@synthesize accountInventorySummaryList;
@synthesize dateOut;
@synthesize sendMail;



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
    
    if(sendMail)
    {
        self.navigationItem.rightBarButtonItem.title = @"Send email";
        
    }
    
    
    
    
    salesProductAndPriceBillingsOnlyList = [SalesProductAndPrice getSalesProductAndPriceBillingsOnly:saleProductAndPriceList];
    salesProductAndPriceBillingsOnlyList = [SalesProductAndPrice getSalesProductAndPriceSortByReceiptDate:salesProductAndPriceBillingsOnlyList];
    
    
    NSSet *uniqueReceiptID = [NSSet setWithArray:[salesProductAndPriceBillingsOnlyList valueForKey:@"_receiptID"]];
    NSArray *arrReceiptID = [uniqueReceiptID allObjects];
    
    
    [self loadingOverlayView];
    SalesProductAndPrice *saleProductAndPrice = saleProductAndPriceList[0];
    NSString *accountYearMonth = [Utility formatDate:saleProductAndPrice.receiptDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM"];
    [_homeModel downloadItems:dbPostCustomerByReceiptID condition:@[arrReceiptID,accountYearMonth]];
}

- (void)itemsDownloaded:(NSArray *)items
{
    [self removeOverlayViews];
    int i=0;
    _postCustomerList = items[i++];
    _accountReceiptList = items[i++];
    _accountReceiptProductItemList = items[i++];
    _accountMappingList = items[i++];
    _accountInventoryList = items[i++];
    
    
    [self createReceiptAsHtml];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)createReceiptAsHtml
{
    NSMutableArray *salesProductAndPriceBillingsOnlySumQuantityList = [[NSMutableArray alloc]init];
    
    {
        //sum quantity
        
        NSInteger previousReceiptID = 0;
        NSInteger previousProductNameID = 0;
        float previousPriceSales = 0;
        NSInteger countProductName = 1;
        SalesProductAndPrice *lastSalesProductAndPrice;
        for(SalesProductAndPrice *salesProductAndPrice in salesProductAndPriceBillingsOnlyList)
        {
            if((salesProductAndPrice.receiptID == previousReceiptID) && (salesProductAndPrice.productNameID == previousProductNameID) && (salesProductAndPrice.priceSales == previousPriceSales))
            {
                countProductName++;
            }
            else
            {
                if(previousReceiptID != 0)
                {
                    SalesProductAndPrice *salesProductAndPriceAdd = [lastSalesProductAndPrice copy];
                    salesProductAndPriceAdd.quantity = countProductName;
                    salesProductAndPriceAdd.amountPerUnit = salesProductAndPriceAdd.priceSales;
                    [salesProductAndPriceBillingsOnlySumQuantityList addObject:salesProductAndPriceAdd];
                    countProductName = 1;
                }
                previousReceiptID = salesProductAndPrice.receiptID;
                previousProductNameID = salesProductAndPrice.productNameID;
                previousPriceSales = salesProductAndPrice.priceSales;
            }
            
            lastSalesProductAndPrice = salesProductAndPrice;
        }
        
        SalesProductAndPrice *salesProductAndPriceAdd = [lastSalesProductAndPrice copy];
        salesProductAndPriceAdd.quantity = countProductName;
        salesProductAndPriceAdd.amountPerUnit = salesProductAndPriceAdd.priceSales;
        [salesProductAndPriceBillingsOnlySumQuantityList addObject:salesProductAndPriceAdd];
    }
    
    
    
    
    AccountReceipt *accountReceipt = _accountReceiptList[0];
    NSInteger maxRunningReceiptNo = accountReceipt.maxRunningReceiptNo;
    
    
    PostCustomer *postCustomer;
    NSMutableDictionary *receiptInfo;
    receiptInfoList = [[NSMutableArray alloc]init];
    NSMutableArray *items = [[NSMutableArray alloc]init];
    NSInteger previousReceiptID = 0;
    float grandTotalAmount = 0;
    float receiptDiscountFromItem = 0;
    for(SalesProductAndPrice *salesProductAndPrice in salesProductAndPriceBillingsOnlySumQuantityList)
    {
        if(previousReceiptID != salesProductAndPrice.receiptID)
        {
            if(previousReceiptID != 0)
            {
                NSInteger countAddRow = 9-[items count];
                for(int i=0; i<countAddRow; i++)
                {
                    NSMutableDictionary *item = [[NSMutableDictionary alloc]init];
                    [item setValue:@"&nbsp;" forKey:@"itemNo"];///*************
                    [item setValue:@"" forKey:@"itemDesc"];
                    [item setValue:@"" forKey:@"quantity"];
                    [item setValue:@"" forKey:@"amountPerUnit"];
                    [item setValue:@"" forKey:@"totalAmount"];
                    
                    [items addObject:item];
                }
                [receiptInfo setValue:items forKey:@"items"];
                
                
                postCustomer = [PostCustomer getPostCustomerWithReceiptID:salesProductAndPrice.receiptID postCustomerList:_postCustomerList];
                SalesProductAndPrice *previousSalesProductAndPrice = [SalesProductAndPrice getSalesProductAndPriceWithReceiptID:previousReceiptID salesProductAndPriceList:salesProductAndPriceBillingsOnlySumQuantityList];
                
                float discount = 0;
//                if(![postCustomer.taxCustomerName isEqualToString:@""])//เปลี่ยนเป็นออกทุกบิล เอา discount ตามจริง
                {
//                    discount = roundf(previousSalesProductAndPrice.receiptDiscount*100)/100;
                    discount = roundf(receiptDiscountFromItem*100)/100;
                }
                float totalAmountIncludeVat = grandTotalAmount - discount;
                float vat = roundf(totalAmountIncludeVat*7/107*100)/100;
                NSString *strGrandTotalAmount = [NSString stringWithFormat:@"%f",grandTotalAmount];
                NSString *strDiscount = [NSString stringWithFormat:@"%f",discount];
                NSString *strTotalAmountIncludeVat = [NSString stringWithFormat:@"%f",totalAmountIncludeVat];
                NSString *strVat = [NSString stringWithFormat:@"%f",vat];
                NSString *strTotalAmountBeforeVat = [NSString stringWithFormat:@"%f",totalAmountIncludeVat-vat];
                
                
                
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
                
                
                grandTotalAmount = 0;
                receiptDiscountFromItem = 0;
                items = [[NSMutableArray alloc]init];
            }
            
            NSString *strReceiptID = [NSString stringWithFormat:@"%d",salesProductAndPrice.receiptID];
            NSString *strMaxRunningReceiptNo = [NSString stringWithFormat:@"%03ld",++maxRunningReceiptNo];
            NSString *strReceiptDate = [Utility formatDate:salesProductAndPrice.receiptDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"dd/MM/yyyy"];
            NSString *prefixReceiptNo = [Utility formatDate:salesProductAndPrice.receiptDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"MM-yy"];
            NSString *receiptNo = [NSString stringWithFormat:@"%@/%@",prefixReceiptNo,strMaxRunningReceiptNo];
            receiptInfo = [[NSMutableDictionary alloc]init];
            [receiptInfo setValue:receiptNo forKey:@"receiptNo"];
            [receiptInfo setValue:strReceiptDate forKey:@"receiptDate"];
            [receiptInfo setValue:strMaxRunningReceiptNo forKey:@"runningReceiptNo"];
            [receiptInfo setValue:strReceiptID forKey:@"receiptID"];
            
            
            
//            PostCustomer *postCustomer = [PostCustomer getPostCustomerWithReceiptID:salesProductAndPrice.receiptID postCustomerList:_postCustomerList];
            if(postCustomer && ![postCustomer.taxCustomerName isEqualToString:@""])
            {
                [receiptInfo setValue:postCustomer.taxCustomerName forKey:@"customerName"];
                [receiptInfo setValue:postCustomer.taxCustomerAddress forKey:@"customerAddress"];
                [receiptInfo setValue:postCustomer.taxNo forKey:@"customerTaxNo"];
            }
            else
            {
                [receiptInfo setValue:@"สด" forKey:@"customerName"];
                [receiptInfo setValue:@"-" forKey:@"customerAddress"];
                [receiptInfo setValue:@"-" forKey:@"customerTaxNo"];
            }
            
            previousReceiptID = salesProductAndPrice.receiptID;
        }
        
        NSMutableDictionary *item = [[NSMutableDictionary alloc]init];
        NSString *strProductNameID = [NSString stringWithFormat:@"%d",salesProductAndPrice.productNameID];
        NSString *strItemNo = [ProductName getProductCode:salesProductAndPrice.productNameID];
        NSString *strQuantity = [NSString stringWithFormat:@"%f",salesProductAndPrice.quantity];
        NSString *strAmountPerUnit = [NSString stringWithFormat:@"%f",salesProductAndPrice.amountPerUnit];
        NSString *strItemDiscount = [NSString stringWithFormat:@"%f",salesProductAndPrice.itemDiscount];
        NSString *strTotalAmount = [NSString stringWithFormat:@"%f",salesProductAndPrice.quantity*salesProductAndPrice.amountPerUnit];
//        NSString *strProductName = [NSString stringWithFormat:@"รองเท้ารุ่น %@",salesProductAndPrice.productName];
        ProductName *productName = [ProductName getProductName:salesProductAndPrice.productNameID];
        NSString *strProductName;
        if([productName.productCategory2 isEqualToString:@"01"])
        {
            strProductName = [NSString stringWithFormat:@"รองเท้ารุ่น %@",productName.name];
        }
        else if([productName.productCategory2 isEqualToString:@"02"])
        {
            strProductName = [NSString stringWithFormat:@"เครื่องประดับรุ่น %@",productName.name];
        }
        else if([productName.productCategory2 isEqualToString:@"03"])
        {
            if([productName.name isEqualToString:@"Pearl strap"] || [productName.name isEqualToString:@"Gold chain"])
            {
                strProductName = [NSString stringWithFormat:@"กระเป๋ารุ่น %@",@"Accessories"];
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
        
        strQuantity = [Utility formatBaht:strQuantity withMinFraction:2 andMaxFraction:2];
        strAmountPerUnit = [Utility formatBaht:strAmountPerUnit withMinFraction:2 andMaxFraction:2];
        strItemDiscount = [Utility formatBaht:strItemDiscount withMinFraction:2 andMaxFraction:2];
        strTotalAmount = [Utility formatBaht:strTotalAmount withMinFraction:2 andMaxFraction:2];
        
        
        if([strProductName isEqualToString:@"รองเท้ารุ่น Sock U"] || [strProductName isEqualToString:@"รองเท้ารุ่น Sock V"] || [strProductName isEqualToString:@"รองเท้ารุ่น Sock O"] || [strProductName isEqualToString:@"รองเท้ารุ่น Sock Taylor"])
        {
            strProductName = @"รองเท้ารุ่น Sock";
        }
        
        
        [item setValue:strItemNo forKey:@"itemNo"];///*************
        [item setValue:strProductName forKey:@"itemDesc"];
        [item setValue:strQuantity forKey:@"quantity"];
        [item setValue:strAmountPerUnit forKey:@"amountPerUnit"];
        [item setValue:strItemDiscount forKey:@"itemDiscount"];
        [item setValue:strTotalAmount forKey:@"totalAmount"];
        [item setValue:strProductNameID forKey:@"productNameID"];
        
        
        [items addObject:item];
        grandTotalAmount += salesProductAndPrice.quantity*salesProductAndPrice.amountPerUnit;
        receiptDiscountFromItem += salesProductAndPrice.itemDiscount;
    }
    //last receiptid
    {
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
        
        
        
        SalesProductAndPrice *previousSalesProductAndPrice = [SalesProductAndPrice getSalesProductAndPriceWithReceiptID:previousReceiptID salesProductAndPriceList:salesProductAndPriceBillingsOnlySumQuantityList];
//        float discount = roundf(previousSalesProductAndPrice.receiptDiscount*100)/100;
        float discount = receiptDiscountFromItem;
        float totalAmountIncludeVat = grandTotalAmount - discount;
        float vat = roundf(totalAmountIncludeVat*7/107*100)/100;
        NSString *strGrandTotalAmount = [NSString stringWithFormat:@"%f",grandTotalAmount];
        NSString *strDiscount = [NSString stringWithFormat:@"%f",discount];
        NSString *strTotalAmountIncludeVat = [NSString stringWithFormat:@"%f",totalAmountIncludeVat];
        NSString *strVat = [NSString stringWithFormat:@"%f",vat];
        NSString *strTotalAmountBeforeVat = [NSString stringWithFormat:@"%f",totalAmountIncludeVat-vat];
        
        
        
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
    }
    
    
    
    
    
//    htmlContent = @"";
//    htmlContentList = [[NSMutableArray alloc]init];
//    for(int i=0; i<[receiptInfoList count]; i++)
//    {
//        NSMutableDictionary *receiptInfo = receiptInfoList[i];
//        invoiceComposer = [[InvoiceComposer alloc]init];
//        NSString *invoiceHtml = [invoiceComposer renderInvoice:receiptInfo[@"receiptNo"] invoiceDate:receiptInfo[@"receiptDate"] customerName:receiptInfo[@"customerName"] customerAddress:receiptInfo[@"customerAddress"] customerTaxNo:receiptInfo[@"customerTaxNo"] items:receiptInfo[@"items"] totalAmount:receiptInfo[@"totalAmount"] discount:receiptInfo[@"discount"] totalAmountBeforeVat:receiptInfo[@"totalAmountBeforeVat"] vat:receiptInfo[@"vat"] totalAmountIncludeVat:receiptInfo[@"totalAmountIncludeVat"]];
//
//
//        htmlContent = [NSString stringWithFormat:@"%@%@",htmlContent,invoiceHtml];
//        [htmlContentList addObject:invoiceHtml];
//    }
    
    
//    [webPreview loadHTMLString:htmlContent baseURL:[NSURL URLWithString:invoiceComposer.pathToInvoiceHtml]];
}

- (IBAction)genReceipt:(id)sender
{
    [self loadingOverlayView];
    
    
    _strAccountReceiptHistoryDate = [Utility dateToString:[Utility currentDateTime] toFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strFileName = [NSString stringWithFormat:@"Tax_Invoice_%@",[Utility formatDate:_strAccountReceiptHistoryDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd_HH:mm:ss"]];
    CustomPrintPageRenderer *printPageRenderer = [[CustomPrintPageRenderer alloc]init];
//    _pdfFileName = [printPageRenderer exportHTMLContentToPDF:htmlContentList fileName:strFileName];
    
    
    //insert accountInventory
    //insert accountReceipt
    //insert accountReceiptProductItem
    //insert accountMapping
    AccountReceipt *accountReceipt = _accountReceiptList[0];
    NSInteger maxAccountReceiptID = accountReceipt.maxAccountReceiptID;
    NSInteger maxRunningAccountReceiptHistory = accountReceipt.maxRunningAccountReceiptHistory;
    AccountReceiptProductItem *accountReceiptProductItem = _accountReceiptProductItemList[0];
    AccountMapping *accountMapping = _accountMappingList[0];
    NSInteger maxAccountReceiptProductItemID = accountReceiptProductItem.maxAccountReceiptProductItemID;
    NSInteger maxAccountMappingID = accountMapping.maxAccountMappingID;
    AccountInventory *accountInventory = _accountInventoryList[0];
    NSInteger maxAccountInventoryID = accountInventory.maxAccountInventoryID;
    
    
    NSMutableArray *accountInventorySummaryBillingOnlyList = [AccountInventorySummary getAccountInventorySummaryBillingsOnly:accountInventorySummaryList];
    NSMutableArray *accountInventoryList = [[NSMutableArray alloc]init];
    for(AccountInventorySummary *item in accountInventorySummaryBillingOnlyList)
    {
        AccountInventory *accountInventory = [[AccountInventory alloc]initWithAccountInventoryID:++maxAccountInventoryID productNameID:item.productNameID quantity:item.billings status:-1 inOutDate:dateOut runningAccountReceiptHistory:(maxRunningAccountReceiptHistory+1) modifiedDate:[Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"]];
        [accountInventoryList addObject:accountInventory];
    }
    
    //    `AccountInventoryID`, `ProductNameID`, `Quantity`, `Status`, `InOutDate`
    //insert fail
    //image quality
    //btn save image
    
    
    NSMutableArray *accountReceiptList = [[NSMutableArray alloc]init];
    NSMutableArray *accountReceiptProductItemList = [[NSMutableArray alloc]init];
    for(NSMutableDictionary *receiptInfo in receiptInfoList)
    {
        NSInteger runningReceiptNo = [[receiptInfo valueForKey:@"runningReceiptNo"] integerValue];
        NSString *strReceiptNo = [receiptInfo valueForKey:@"receiptNo"];
        NSString *strReceiptDate = [Utility formatDate:[receiptInfo valueForKey:@"receiptDate"] fromFormat:@"dd/MM/yyyy" toFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSInteger receiptID = [[receiptInfo valueForKey:@"receiptID"] integerValue];
        float receiptDiscount = [Utility floatValue:[receiptInfo valueForKey:@"discount"]];
        
        
        AccountReceipt *accountReceipt = [[AccountReceipt alloc]initWithAccountReceiptID:++maxAccountReceiptID runningAccountReceiptHistory:(maxRunningAccountReceiptHistory+1) runningReceiptNo:runningReceiptNo accountReceiptHistoryDate:_strAccountReceiptHistoryDate receiptNo:strReceiptNo receiptDate:strReceiptDate receiptID:receiptID receiptDiscount:receiptDiscount];
        
        
        [accountReceiptList addObject:accountReceipt];
        
        
        NSMutableArray *items = [receiptInfo valueForKey:@"items"];
        for(NSMutableDictionary *item in items)
        {
            NSString *itemDesc = [item valueForKey:@"itemDesc"];
            if([itemDesc isEqualToString:@""])
            {
                break;
            }
            
            NSInteger productNameID = [[item valueForKey:@"productNameID"] integerValue];
            float quantity = [Utility floatValue:[item valueForKey:@"quantity"]];
            float amountPerUnit = [Utility floatValue:[item valueForKey:@"amountPerUnit"]];
            float itemDiscount = [Utility floatValue:[item valueForKey:@"itemDiscount"]];
            AccountReceiptProductItem *accountReceiptProductItem = [[AccountReceiptProductItem alloc]initWithAccountReceiptProductItemID:++maxAccountReceiptProductItemID accountReceiptID:maxAccountReceiptID productNameID:productNameID quantity:quantity amountPerUnit:amountPerUnit itemDiscount:itemDiscount];
            [accountReceiptProductItemList addObject:accountReceiptProductItem];
        }
    }
    
    
    NSMutableArray *accountMappingList = [[NSMutableArray alloc]init];
    for(SalesProductAndPrice *item in salesProductAndPriceBillingsOnlyList)
    {
        AccountMapping *accountMapping = [[AccountMapping alloc]initWithAccountMappingID:++maxAccountMappingID receiptID:item.receiptID receiptProductItemID:item.receiptProductItemID runningAccountReceiptHistory:(maxRunningAccountReceiptHistory+1)];
        [accountMappingList addObject:accountMapping];
    }
    
    [_homeModel insertItemsJson:dbAccountReceiptInsert withData:@[accountInventoryList,accountReceiptList,accountReceiptProductItemList,accountMappingList]];
}

//test
-(void)itemsFail
{
    [self removeOverlayViews];
}

-(void)itemsInserted
{
    if(sendMail)//save image to photo album
    {
        [self emailPDF:nil];
    }
    else
    {
        [self removeOverlayViews];
        [self performSegueWithIdentifier:@"segUnwindToAccountInventorySummary" sender:self];
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


//send mail
- (IBAction)emailPDF:(id)sender
{
    [self loadingOverlayView];
    
    
    NSString *strFileName = [NSString stringWithFormat:@"Tax_Invoice_%@",[Utility formatDate:_strAccountReceiptHistoryDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd_HH:mm:ss"]];
    CustomPrintPageRenderer *printPageRenderer = [[CustomPrintPageRenderer alloc]init];
    pdfFileName = [printPageRenderer exportHTMLContentToPDF:htmlContentList fileName:strFileName];
    
    [self performSelectorOnMainThread: @selector(mail:) withObject:pdfFileName waitUntilDone:NO];
}

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
                                                                  handler:^(UIAlertAction * action)
                                            {
                                                if(sendMail)
                                                {
                                                    [self.navigationController popViewControllerAnimated:YES];
                                                }
                                                
                                                
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

-(UIImage *)pdfToImage:(NSURL *)sourcePDFUrl
{
    CGPDFDocumentRef SourcePDFDocument = CGPDFDocumentCreateWithURL((__bridge CFURLRef)sourcePDFUrl);
    size_t numberOfPages = CGPDFDocumentGetNumberOfPages(SourcePDFDocument);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    
    
    for(int currentPage = 1; currentPage <= numberOfPages; currentPage ++ )
    {
        CGPDFPageRef SourcePDFPage = CGPDFDocumentGetPage(SourcePDFDocument, currentPage);
        // CoreGraphics: MUST retain the Page-Refernce manually
        CGPDFPageRetain(SourcePDFPage);
        
        
        CGRect sourceRect = CGPDFPageGetBoxRect(SourcePDFPage,kCGPDFMediaBox);
        UIGraphicsBeginImageContext(CGSizeMake(sourceRect.size.width,sourceRect.size.height));
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(currentContext, 0.0, sourceRect.size.height); //596,842 //640×960,
        CGContextScaleCTM(currentContext, 1.0, -1.0);
        CGContextDrawPDFPage (currentContext, SourcePDFPage); // draws the page in the graphics context
        
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
    return nil;
}

@end
