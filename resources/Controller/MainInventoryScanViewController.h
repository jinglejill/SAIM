//
//  MainInventoryScanViewController.h
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/31/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Homemodel.h"

@interface MainInventoryScanViewController : UIViewController<HomeModelProtocol,AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIView *vwPreview;
@property (strong, nonatomic) IBOutlet UILabel *lblStatus;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnStart;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnBack;
- (IBAction)choosePhoto:(id)sender;
- (IBAction)startStopReading:(id)sender;


@property (strong, nonatomic) IBOutlet UIImageView *imgVwProduct;
@property (strong, nonatomic) IBOutlet UILabel *lblProductName;
@property (strong, nonatomic) IBOutlet UILabel *lblColor;
@property (strong, nonatomic) IBOutlet UILabel *lblSize;
@property (strong, nonatomic) IBOutlet UITextField *txtQuantity;
@property (strong, nonatomic) IBOutlet UIStepper *stepper;
@property (strong, nonatomic) IBOutlet UIButton *btnAdd;
- (IBAction)stepperValueChanged:(id)sender;
- (IBAction)addProduct:(id)sender;



@end
