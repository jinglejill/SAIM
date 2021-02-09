//
//  InvoiceComposer.m
//  testPdf
//
//  Created by Thidaporn Kijkamjai on 1/25/2560 BE.
//  Copyright © 2560 Appxelent. All rights reserved.
//

#import "InvoiceComposer.h"
#import <UIKit/UIKit.h>

@implementation InvoiceComposer
- (id)init
{
    self = [super init];
    _pathToInvoiceHtml = [[NSBundle mainBundle] pathForResource:@"receipt" ofType:@"html"];
    _pathToSingle_itemHtml = [[NSBundle mainBundle] pathForResource:@"single_item" ofType:@"html"];
    _pathToLast_itemHtml = [[NSBundle mainBundle] pathForResource:@"last_item" ofType:@"html"];
    
    return  self;
}

- (NSString *)renderInvoice:(NSString *)invoiceNumber invoiceDate:(NSString *)invoiceDate customerName:(NSString *)customerName customerAddress:(NSString *)customerAddress customerTaxNo:(NSString *)customerTaxNo items:(NSMutableArray *)items totalAmount:(NSString *)totalAmount discount:(NSString *)discount totalAmountBeforeVat:(NSString *)totalAmountBeforeVat vat:(NSString *)vat totalAmountIncludeVat:(NSString *)totalAmountIncludeVat
{
    
    _invoiceNumber = invoiceNumber;
    NSString* htmlContent = [NSString stringWithContentsOfFile:_pathToInvoiceHtml
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];

    htmlContent = [htmlContent stringByReplacingOccurrencesOfString:@"#INVOICE_NUMBER#" withString:invoiceNumber];
    htmlContent = [htmlContent stringByReplacingOccurrencesOfString:@"#INVOICE_DATE#" withString:invoiceDate];
    htmlContent = [htmlContent stringByReplacingOccurrencesOfString:@"#CUSTOMER_NAME#" withString:customerName];
    htmlContent = [htmlContent stringByReplacingOccurrencesOfString:@"#CUSTOMER_ADDRESS#" withString:customerAddress];
    htmlContent = [htmlContent stringByReplacingOccurrencesOfString:@"#CUSTOMER_TAX_NO#" withString:customerTaxNo];


    htmlContent = [htmlContent stringByReplacingOccurrencesOfString:@"#TOTAL_AMOUNT#" withString:totalAmount];
    htmlContent = [htmlContent stringByReplacingOccurrencesOfString:@"#DISCOUNT#" withString:discount];
    htmlContent = [htmlContent stringByReplacingOccurrencesOfString:@"#TOTAL_AMOUNT_BEFORE_VAT#" withString:totalAmountBeforeVat];
    htmlContent = [htmlContent stringByReplacingOccurrencesOfString:@"#VAT#" withString:vat];
    htmlContent = [htmlContent stringByReplacingOccurrencesOfString:@"#TOTAL_AMOUNT_INCLUDE_VAT#" withString:totalAmountIncludeVat];
    
    
//    NSString *imgPath = [[[NSBundle mainBundle] URLForResource:@"oneSignature3" withExtension:@"png"] absoluteString];
//    htmlContent = [htmlContent stringByReplacingOccurrencesOfString:@"#IMG_SIGNATURE#" withString:imgPath];
    
    
    NSString *imgTag = [self imageBase64Tag:[UIImage imageNamed:@"oneSignature3.png"]];
    htmlContent = [htmlContent stringByReplacingOccurrencesOfString:@"#ONE_SIGNATURE#" withString:imgTag];
    
    
    NSString *base64Image = [self getBase64Image];
    htmlContent = [htmlContent stringByReplacingOccurrencesOfString:@"#BASE64IMAGE#" withString:base64Image];
    
    NSString *allItems = @"";
    for(int i=0; i<[items count]; i++)
    {
        NSString *itemHtmlContent;
        if(i == [items count]-1)
        {
            itemHtmlContent = [NSString stringWithContentsOfFile:_pathToLast_itemHtml
                                                        encoding:NSUTF8StringEncoding
                                                           error:NULL];
        }
        else
        {
            itemHtmlContent = [NSString stringWithContentsOfFile:_pathToSingle_itemHtml
                                                        encoding:NSUTF8StringEncoding
                                                           error:NULL];
        }
        
        
        NSDictionary *dicItem = items[i];
        itemHtmlContent = [itemHtmlContent stringByReplacingOccurrencesOfString:@"#ITEM_NO#" withString:[dicItem valueForKey:@"itemNo"]];
        itemHtmlContent = [itemHtmlContent stringByReplacingOccurrencesOfString:@"#ITEM_DESC#" withString:[dicItem valueForKey:@"itemDesc"]];
        itemHtmlContent = [itemHtmlContent stringByReplacingOccurrencesOfString:@"#QUANTITY#" withString:[dicItem valueForKey:@"quantity"]];
        itemHtmlContent = [itemHtmlContent stringByReplacingOccurrencesOfString:@"#AMOUNT_PER_UNIT#" withString:[dicItem valueForKey:@"amountPerUnit"]];
        itemHtmlContent = [itemHtmlContent stringByReplacingOccurrencesOfString:@"#TOTAL_AMOUNT#" withString:[dicItem valueForKey:@"totalAmount"]];
        NSString *formattedPrice = [self getStringValueFormattedAsCurrency:[dicItem valueForKey:@"price"]];
        itemHtmlContent = [itemHtmlContent stringByReplacingOccurrencesOfString:@"#PRICE#" withString:formattedPrice];
        
        allItems = [NSString stringWithFormat:@"%@%@",allItems,itemHtmlContent];
    }
    
    htmlContent = [htmlContent stringByReplacingOccurrencesOfString:@"#ITEMS#" withString:allItems];
    
    return htmlContent;
}

- (NSString *)getStringValueFormattedAsCurrency:(NSString *)value
{
    NSNumberFormatter *formatterBaht = [[NSNumberFormatter alloc]init];
    [formatterBaht setNumberStyle:NSNumberFormatterCurrencyPluralStyle];
    formatterBaht.maximumFractionDigits = 2;
    formatterBaht.currencyCode = @"eur";
    
    
    NSString *strFormattedBaht = [formatterBaht stringFromNumber:[NSNumber numberWithFloat:[value floatValue]]];
    return strFormattedBaht;
}

-(NSString *)imageBase64Tag:(UIImage *)image
{
//    NSData *jpegData = UIImageJPEGRepresentation(image, 1);
    NSData *pngData = UIImagePNGRepresentation(image);
    NSString *base64EncodedString = [pngData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSString *src = [NSString stringWithFormat:@"data:image/png;base64,%@",base64EncodedString];
    NSString *tag = [NSString stringWithFormat:@"<img width=\"200px\" src=\"%@\"/>",src];
    return tag;
}

-(NSString *) getBase64Image
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
@end
