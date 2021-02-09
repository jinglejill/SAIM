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
    CustomPrintPageRenderer *printPageRenderer = [[CustomPrintPageRenderer alloc]init];
    for(int i=0; i<[printFormatterList count]; i++)
    {
        [printPageRenderer addPrintFormatter:printFormatterList[i] startingAtPageAtIndex:i];
    }
        
    NSData *pdfData = [self drawPDFUsingPrintPageRendererList:printPageRenderer];
    
    
    NSString *pdfFileName = [NSString stringWithFormat:@"%@/%@.pdf",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0],fileName];
    
    
    [pdfData writeToFile:pdfFileName atomically:YES];
    NSLog(@"pdf filename: %@",pdfFileName);
    
    return pdfFileName;
}

- (NSString *)exportHTMLContentToPDFWIthPrintFormatter:(UIPrintFormatter *)printFormatter fileName:(NSString *)fileName
{
    CustomPrintPageRenderer *printPageRenderer = [[CustomPrintPageRenderer alloc]init];
//    for(int i=0; i<[printFormatterList count]; i++)
    {
        [printPageRenderer addPrintFormatter:printFormatter startingAtPageAtIndex:0];
    }
        
    NSData *pdfData = [self drawPDFUsingPrintPageRendererList:printPageRenderer];
    
    
    NSString *pdfFileName = [NSString stringWithFormat:@"%@/%@.pdf",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0],fileName];
    
    
    [pdfData writeToFile:pdfFileName atomically:YES];
    NSLog(@"pdf filename: %@",pdfFileName);
    
    return pdfFileName;
}


- (NSString *)exportHTMLContentToPDF:(NSMutableArray *)htmlContentList fileName:(NSString *)fileName
{
    CustomPrintPageRenderer *printPageRenderer = [[CustomPrintPageRenderer alloc]init];
    for(int i=0; i<[htmlContentList count]; i++)
    {
        NSString *htmlContent = htmlContentList[i];        
        UIMarkupTextPrintFormatter *printFormatter = [[UIMarkupTextPrintFormatter alloc]initWithMarkupText:htmlContent];
        [printPageRenderer addPrintFormatter:printFormatter startingAtPageAtIndex:i];
    }
    
    NSData *pdfData = [self drawPDFUsingPrintPageRendererList:printPageRenderer];
    
    
    NSString *pdfFileName = [NSString stringWithFormat:@"%@/%@.pdf",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0],fileName];
    
    
    [pdfData writeToFile:pdfFileName atomically:YES];
    NSLog(@"pdf filename: %@",pdfFileName);
    
    return pdfFileName;
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
    

            
    return data;
}

- (NSData *)drawPDFUsingPrintPageRendererList:(CustomPrintPageRenderer *)printPageRenderer
{
    NSMutableData *data = [[NSMutableData alloc]init];
    UIGraphicsBeginPDFContextToData(data, CGRectZero, nil);
    
    
    for(int i=0; i<[printPageRenderer numberOfPages]; i++)
    {
        UIGraphicsBeginPDFPage();
        
        [printPageRenderer drawPageAtIndex:i inRect:UIGraphicsGetPDFContextBounds()];
    }
    
    UIGraphicsEndPDFContext();

            
    return data;
}
@end
