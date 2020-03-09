//
//  InvoiceComposer.h
//  testPdf
//
//  Created by Thidaporn Kijkamjai on 1/25/2560 BE.
//  Copyright © 2560 Appxelent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InvoiceComposer : NSObject
@property (retain, nonatomic) NSString * senderInfo;
@property (retain, nonatomic) NSString * dueDate;
@property (retain, nonatomic) NSString * paymentMethod;
@property (retain, nonatomic) NSString * logoImageURL;

@property (retain, nonatomic) NSString * invoiceNumber;
@property (retain, nonatomic) NSString * pdfFilename;

@property (retain, nonatomic) NSString * pathToInvoiceHtml;
@property (retain, nonatomic) NSString * pathToSingle_itemHtml;
@property (retain, nonatomic) NSString * pathToLast_itemHtml;

- (id)init;
- (NSString *)renderInvoice:(NSString *)invoiceNumber invoiceDate:(NSString *)invoiceDate customerName:(NSString *)customerName customerAddress:(NSString *)customerAddress customerTaxNo:(NSString *)customerTaxNo items:(NSMutableArray *)items totalAmount:(NSString *)totalAmount discount:(NSString *)discount totalAmountBeforeVat:(NSString *)totalAmountBeforeVat vat:(NSString *)vat totalAmountIncludeVat:(NSString *)totalAmountIncludeVat;


@end
