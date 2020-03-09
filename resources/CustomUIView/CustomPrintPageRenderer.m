//
//  CustomPrintPageRenderer.m
//  testPdf
//
//  Created by Thidaporn Kijkamjai on 1/27/2560 BE.
//  Copyright © 2560 Appxelent. All rights reserved.
//

#import "CustomPrintPageRenderer.h"

@implementation CustomPrintPageRenderer

- (id)init
{
    self = [super init];
    _A4PageWidth = 595.2;
    _A4PageHeight = 841.8;
    
    
    CGRect pageFrame = CGRectMake(0, 0, _A4PageWidth, _A4PageHeight);
    CGRect inset = CGRectInset(pageFrame, 10, 10);
    [self setValue:[NSValue value:&pageFrame withObjCType:@encode(CGRect)] forKey:@"paperRect"];
    [self setValue:[NSValue value:&inset withObjCType:@encode(CGRect)] forKey:@"printableRect"];
    
    
    return self;
}

- (NSString *)exportHTMLContentToPDF:(NSMutableArray *)htmlContentList fileName:(NSString *)fileName
{
    NSMutableArray *printPageRendererList = [[NSMutableArray alloc]init];
    for(int i=0; i<[htmlContentList count]; i++)
    {
        NSString *htmlContent = htmlContentList[i];
        CustomPrintPageRenderer *printPageRenderer = [[CustomPrintPageRenderer alloc]init];
        UIMarkupTextPrintFormatter *printFormatter = [[UIMarkupTextPrintFormatter alloc]initWithMarkupText:htmlContent];
        [printPageRenderer addPrintFormatter:printFormatter startingAtPageAtIndex:i];
        [printPageRendererList addObject:printPageRenderer];
    }
    
    NSData *pdfData = [self drawPDFUsingPrintPageRenderer:printPageRendererList];
    
    
    NSString *pdfFileName = [NSString stringWithFormat:@"%@/%@.pdf",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0],fileName];
    
    
    [pdfData writeToFile:pdfFileName atomically:YES];
    NSLog(@"pdf filename: %@",pdfFileName);
    
    return pdfFileName;
}

- (NSData *)exportHTMLContentToPDFNSData:(NSMutableArray *)htmlContentList fileName:(NSString *)fileName
{
    NSMutableArray *printPageRendererList = [[NSMutableArray alloc]init];
    for(int i=0; i<[htmlContentList count]; i++)
    {
        NSString *htmlContent = htmlContentList[i];
        CustomPrintPageRenderer *printPageRenderer = [[CustomPrintPageRenderer alloc]init];
        UIMarkupTextPrintFormatter *printFormatter = [[UIMarkupTextPrintFormatter alloc]initWithMarkupText:htmlContent];
        [printPageRenderer addPrintFormatter:printFormatter startingAtPageAtIndex:i];
        [printPageRendererList addObject:printPageRenderer];
    }
    
    NSData *pdfData = [self drawPDFUsingPrintPageRenderer:printPageRendererList];
    return pdfData;
    
//    NSString *pdfFileName = [NSString stringWithFormat:@"%@/%@.pdf",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0],fileName];
//    
//    
//    [pdfData writeToFile:pdfFileName atomically:YES];
//    NSLog(@"pdf filename: %@",pdfFileName);
//    
//    return pdfFileName;
}

- (NSData *)drawPDFUsingPrintPageRenderer:(NSMutableArray *)printPageRendererList
{
    NSMutableData *data = [[NSMutableData alloc]init];
    UIGraphicsBeginPDFContextToData(data, CGRectZero, nil);
    
    
    for(int i=0; i<[printPageRendererList count]; i++)
    {
        UIGraphicsBeginPDFPage();
        
        [printPageRendererList[i] drawPageAtIndex:i inRect:UIGraphicsGetPDFContextBounds()];
    }
    
    
    UIGraphicsEndPDFContext();
    return data;
}
@end
