//
//  SalesScanViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 8/12/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Homemodel.h"
#import "Product.h"


@interface SalesScanViewController : UIViewController<HomeModelProtocol, AVCaptureMetadataOutputObjectsDelegate>
@property (strong, nonatomic) IBOutlet UIView *vwPreview;
@property (strong, nonatomic) IBOutlet UILabel *lblStatus;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnStart;

- (IBAction)startStopReading:(id)sender;
- (IBAction)unwindToSalesScan:(UIStoryboardSegue *)segue;
@property (strong, nonatomic) IBOutlet UILabel *lblLocation;


@end
