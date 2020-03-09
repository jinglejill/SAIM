//
//  PreOrderScanPostViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/19/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "HomeModel.h"
#import "Product.h"
#import "Event.h"

@interface PreOrderScanPostViewController : UIViewController<HomeModelProtocol, AVCaptureMetadataOutputObjectsDelegate>
@property (strong, nonatomic) IBOutlet UIView *vwPreview;
@property (strong, nonatomic) IBOutlet UILabel *lblStatus;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnStart;

@property (strong, nonatomic) IBOutlet UILabel *lblLocation;
@property (strong, nonatomic) NSMutableArray *mutArrPostDetailList;
@property (strong, nonatomic) NSMutableArray *arrSelectedPostDetail;
@property (nonatomic) NSInteger selectedPreOrderEventID;
- (IBAction)startStopReading:(id)sender;
- (IBAction)backButtonPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnBackButton;

@end
