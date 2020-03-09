//
//  ComparingScanViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/30/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Homemodel.h"
#import "Product.h"
@interface ComparingScanViewController : UIViewController<HomeModelProtocol, AVCaptureMetadataOutputObjectsDelegate>
@property (strong, nonatomic) IBOutlet UIView *vwPreview;
@property (strong, nonatomic) IBOutlet UILabel *lblStatus;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnStart;

- (IBAction)startStopReading:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *lblLocation;
@property (strong, nonatomic) NSString *runningSetNo;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnSummary;

@end
