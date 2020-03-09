//
//  QRCodeImageViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/4/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRCodeImageViewController : UIViewController
@property (strong, nonatomic) NSString *productCode;

@property (strong, nonatomic) IBOutlet UIImageView *imgQRCode;
@property (strong, nonatomic) IBOutlet UIButton *btnSaveImage;

- (IBAction)saveQRCodeImage:(id)sender;
@end
