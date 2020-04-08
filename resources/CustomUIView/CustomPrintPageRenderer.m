//
//  CustomPrintPageRenderer.m
//  testPdf
//
//  Created by Thidaporn Kijkamjai on 1/27/2560 BE.
//  Copyright © 2560 Appxelent. All rights reserved.
//

#import "CustomPrintPageRenderer.h"
#import "Utility.h"

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

- (NSString *)exportHTMLContentToPDFWIthPrintFormatterList:(NSMutableArray *)printFormatterList fileName:(NSString *)fileName
{
    NSMutableArray *printPageRendererList = [[NSMutableArray alloc]init];
    CustomPrintPageRenderer *printPageRenderer = [[CustomPrintPageRenderer alloc]init];
    for(int i=0; i<[printFormatterList count]; i++)
    {
        [printPageRenderer addPrintFormatter:printFormatterList[i] startingAtPageAtIndex:i];
        [printPageRendererList addObject:printPageRenderer];
    }
        
    NSData *pdfData = [self drawPDFUsingPrintPageRendererList:printPageRendererList];
    
    
    NSString *pdfFileName = [NSString stringWithFormat:@"%@/%@.pdf",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0],fileName];
    
    
    [pdfData writeToFile:pdfFileName atomically:YES];
    NSLog(@"pdf filename: %@",pdfFileName);
    
    return pdfFileName;
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
    
    NSData *pdfData = [self drawPDFUsingPrintPageRendererList:printPageRendererList];
    
    
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
    
    NSData *pdfData = [self drawPDFUsingPrintPageRendererList:printPageRendererList];
    return pdfData;
    
//    NSString *pdfFileName = [NSString stringWithFormat:@"%@/%@.pdf",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0],fileName];
//    
//    
//    [pdfData writeToFile:pdfFileName atomically:YES];
//    NSLog(@"pdf filename: %@",pdfFileName);
//    
//    return pdfFileName;
}

- (NSData *)drawPDFUsingPrintPageRenderer:(CustomPrintPageRenderer *)printPageRenderer
{
    NSMutableData *data = [[NSMutableData alloc]init];
    UIGraphicsBeginPDFContextToData(data, CGRectZero, nil);
    
    
//    for(int i=0; i<[printPageRendererList count]; i++)
    {
        UIGraphicsBeginPDFPage();
        
        [printPageRenderer drawPageAtIndex:0 inRect:UIGraphicsGetPDFContextBounds()];
    }
    
    UIGraphicsEndPDFContext();
    
    
//    //test
//    NSString *strFileName = [NSString stringWithFormat:@"Tax_Invoice_%@",[Utility formatDate:@"2020-04-06 00:00:00" fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd_HH:mm:ss"]];
//    NSString *pdfFileName = [NSString stringWithFormat:@"%@/%@.pdf",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0],strFileName];
//
//
//    [data writeToFile:pdfFileName atomically:YES];
//    NSLog(@"pdf filename: %@",pdfFileName);
            
    return data;
}

- (NSData *)drawPDFUsingPrintPageRendererList:(NSMutableArray *)printPageRendererList
{
    NSMutableData *data = [[NSMutableData alloc]init];
    UIGraphicsBeginPDFContextToData(data, CGRectZero, nil);
    
    
    for(int i=0; i<[printPageRendererList count]; i++)
    {
        UIGraphicsBeginPDFPage();
        
        [printPageRendererList[i] drawPageAtIndex:i inRect:UIGraphicsGetPDFContextBounds()];
    }
    
    UIGraphicsEndPDFContext();
    
    
//    //test
//    NSString *strFileName = [NSString stringWithFormat:@"Tax_Invoice_%@",[Utility formatDate:@"2020-04-06 00:00:00" fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd_HH:mm:ss"]];
//    NSString *pdfFileName = [NSString stringWithFormat:@"%@/%@.pdf",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0],strFileName];
//
//
//    [data writeToFile:pdfFileName atomically:YES];
//    NSLog(@"pdf filename: %@",pdfFileName);
            
    return data;
}
@end
