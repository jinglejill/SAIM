//
//  EventProductDeleteScanViewController.h
//  SAIM_UPDATING
//
//  Created by Thidaporn Kijkamjai on 4/25/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Homemodel.h"
#import "Event.h"



@interface EventProductDeleteScanViewController : UIViewController<HomeModelProtocol,AVCaptureMetadataOutputObjectsDelegate>
@property (strong, nonatomic) IBOutlet UIView *vwPreview;
@property (strong, nonatomic) IBOutlet UILabel *lblStatus;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnStart;

- (IBAction)startStopReading:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnBack;
@property (strong, nonatomic) IBOutlet UILabel *lblLocation;
- (IBAction)backButtonClicked:(id)sender;

@end
