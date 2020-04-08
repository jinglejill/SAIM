//
//  ExportManager.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 5/4/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import "ExportManager.h"



@interface ExportManager()
{
    
}
@end
@implementation ExportManager
-(void) exportPDF:(NSString *)html completion:(void (^)(BOOL, NSData *, NSError *))completion
{
    self.completion = completion;
    WKWebView *webView = [[WKWebView alloc]init];
    webView.navigationDelegate = self;
    
    [webView loadHTMLString:html baseURL:nil];
    self.webView = webView;
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    UIViewPrintFormatter *formatter = [webView viewPrintFormatter];
    [self createPdf:formatter];
}

-(void)createPdf:(UIViewPrintFormatter *)formatter
{
     UIPrintPageRenderer *render = [[UIPrintPageRenderer alloc]init];
     [render addPrintFormatter:formatter startingAtPageAtIndex:0];
     
     
     // Assign paperRect and printableRect
     // A4, 72 dpi
     CGRect paperRect = CGRectMake(0, 0, 595.2, 841.8);
     [render setValue:@(paperRect) forKey:@"paperRect"];
//     CGFloat padding = 24;
     CGRect printableRect = CGRectMake(0, 0, 547.2,793.8);
     [render setValue:@(printableRect) forKey:@"printableRect"];
     
     
     // 4. Create PDF context and draw
     NSMutableData *pdfData = [[NSMutableData alloc]init];
     UIGraphicsBeginPDFContextToData(pdfData, CGRectZero, nil);
     for(int i=0; i<[render numberOfPages]; i++)
     {
        UIGraphicsBeginPDFPage();
        [render drawPageAtIndex:i inRect:UIGraphicsGetPDFContextBounds()];
     }
     UIGraphicsEndPDFContext();
     
    self.completion(YES, pdfData, nil);
}

-(NSString *)imageBase64Tag:(UIImage *)image
{
//    NSData *jpegData = UIImageJPEGRepresentation(image, 1);
    NSData *pngData = UIImagePNGRepresentation(image);
    NSString *base64EncodedString = [pngData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSString *src = [NSString stringWithFormat:@"data:image/png;base64,%@",base64EncodedString];
    NSString *tag = [NSString stringWithFormat:@"<img src=\"%@\"/>",src];
    return tag;
}
@end
