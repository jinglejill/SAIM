//
//  SalesScanAddScanViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 9/29/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Homemodel.h"
#import "Product.h"

@interface SalesScanAddScanViewController : UIViewController<HomeModelProtocol, AVCaptureMetadataOutputObjectsDelegate>
@property (strong, nonatomic) IBOutlet UIView *vwPreview;
@property (strong, nonatomic) IBOutlet UILabel *lblStatus;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnStart;
@property (strong, nonatomic) IBOutlet UILabel *lblLocation;

- (IBAction)startStopReading:(id)sender;
- (IBAction)unwindToSalesScan:(UIStoryboardSegue *)segue;

@property (strong, nonatomic) Product *product;

@end
