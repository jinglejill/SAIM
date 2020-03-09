//
//  PreOrderScanViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/3/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Homemodel.h"
#import "Product.h"
#import "Event.h"

@interface PreOrderScanViewController : UIViewController<HomeModelProtocol, AVCaptureMetadataOutputObjectsDelegate>
@property (strong, nonatomic) IBOutlet UIView *vwPreview;
@property (strong, nonatomic) IBOutlet UILabel *lblStatus;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnStart;

@property (strong, nonatomic) IBOutlet UILabel *lblLocation;

@property (strong, nonatomic) NSString *preOrderProductID;
@property (strong, nonatomic) NSString *preOrderReceiptProductItemID;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnBack;

- (IBAction)startStopReading:(id)sender;

@end
