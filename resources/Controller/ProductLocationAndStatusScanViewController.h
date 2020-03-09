//
//  ProductLocationAndStatusScanViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/9/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>



@interface ProductLocationAndStatusScanViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate>
@property (strong, nonatomic) IBOutlet UIView *vwPreview;
@property (strong, nonatomic) IBOutlet UILabel *lblStatus;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnStart;

- (IBAction)startStopReading:(id)sender;
- (IBAction)unwindToProductLocationAndStatusScan:(UIStoryboardSegue *)segue;
@end
