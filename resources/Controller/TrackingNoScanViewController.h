//
//  TrackingNoScanViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 3/2/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Homemodel.h"
#import "Product.h"
#import "Event.h"

@interface TrackingNoScanViewController : UIViewController<HomeModelProtocol, AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic) BOOL strReceiptID;
@property (strong, nonatomic) NSString *strTrackingNo;


@property (strong, nonatomic) IBOutlet UIView *vwPreview;
@property (strong, nonatomic) IBOutlet UILabel *lblStatus;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnStart;
- (IBAction)startStopReading:(id)sender;

@end
