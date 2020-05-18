//
//  QRCodeImageViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/4/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "QRCodeImageViewController.h"
#import "Utility.h"

@interface QRCodeImageViewController ()
{
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
}
@end

@implementation QRCodeImageViewController
@synthesize productCode;
@synthesize imgQRCode;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)loadView
{
    [super loadView];
    
    {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);        
    }
        
    
    NSString *line0Format = [NSString stringWithFormat:@"SAIM %@",[Utility makeFirstLetterUpperCaseOtherLower:[Utility dbName]]];
    NSString *line1 = productCode;
    NSString *line2 = @"End";
    
    
    NSString *qrString = [NSString stringWithFormat:@"%@\n%@\n%@",line0Format,line1,line2];
    imgQRCode.image = [self generateQRCodeWithString:qrString scale:5.0f];
    [self loadViewProcess];
}

- (void)loadViewProcess
{
}

- (IBAction)saveQRCodeImage:(id)sender {
    UIImageWriteToSavedPhotosAlbum(imgQRCode.image, nil, nil, nil);
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                   message:@"Save image success"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    dispatch_async(dispatch_get_main_queue(),^ {
        [self presentViewController:alert animated:YES completion:nil];
    } );
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
-(NSData *)uiimageToBitmap
{
    CGSize newSize = CGSizeMake(384, 384);
    UIGraphicsBeginImageContext( newSize );
    
    [imgQRCode.image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    
    
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
//    NSData * data = UIImagePNGRepresentation(newImage);
//    [data writeToFile:@"foo.png" atomically:YES];
//    
//    
//    UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil);///save image in phone
//    
//    OR For Bitmap.
    
    CGContextRef context;
//    CGContextRelease(context);
    CGColorSpaceRef colorSpace = CGBitmapContextGetColorSpace (context);
    context = CGBitmapContextCreate (NULL,
                                     imgQRCode.image.size.width,
                                     imgQRCode.image.size.height,
                                     8,    // bits per component
                                     384*4,
                                     colorSpace,
                                     kCGImageAlphaLast
                                     );
    CGColorSpaceRelease( colorSpace );
    
    CGContextDrawImage(context, CGRectMake(0, 0, imgQRCode.image.size.width, imgQRCode.image.size.height), imgQRCode.image.CGImage);
    NSData *pixelData = CGBitmapContextGetData(context);
    
    return pixelData;
    
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
