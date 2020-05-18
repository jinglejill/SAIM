//
//  MainInventoryScanViewController.m
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/31/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "MainInventoryScanViewController.h"
#import "Utility.h"
#import "Product.h"
#import "SharedProduct.h"
#import "SharedPushSync.h"
#import "PushSync.h"

#import "SharedProduct.h"
#import "SharedProductSize.h"
#import "SharedProductName.h"
#import "SharedProductCategory2.h"
#import "SharedProductCategory1.h"
#import "SharedColor.h"

#define orangeColor         [UIColor colorWithRed:253/255.0 green:182/255.0 blue:103/255.0 alpha:1]
#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]

@interface MainInventoryScanViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIActivityIndicatorView *indicatorImage;
    UIView *overlayView;
    UIView *overlayViewImage;
    NSMutableArray *_productScanList;
    NSString *_previousProductIDGroup;
    NSDate *_dateScan;
    BOOL _executeQR;
    NSMutableArray *_productExecuteList;
    NSMutableArray *_productExecuteTempList;
    NSString *_previousDecryptedMessage;
    BOOL _QRMismatch;
    BOOL _scanBlank;
    BOOL _choosePhoto;
    Product *_productScan;
}
@property (nonatomic) BOOL isReading;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;


-(BOOL)startReading;
-(void)stopReading;

@end

@implementation MainInventoryScanViewController
@synthesize btnBack;
@synthesize imgVwProduct;
@synthesize lblProductName;
@synthesize lblColor;
@synthesize lblSize;
@synthesize txtQuantity;
@synthesize stepper;
@synthesize btnAdd;


- (void)loadView
{
    [super loadView];
    
    // Create new HomeModel object and assign it to _homeModel variable
    _homeModel = [[HomeModel alloc] init];
    _homeModel.delegate = self;
    
    {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);
    }
    {
        overlayViewImage = [[UIView alloc] initWithFrame:imgVwProduct.frame];
        overlayViewImage.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        indicatorImage = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        indicatorImage.frame = CGRectMake(imgVwProduct.bounds.size.width/2-indicatorImage.frame.size.width/2,imgVwProduct.bounds.size.height/2-indicatorImage.frame.size.height/2,indicatorImage.frame.size.width,indicatorImage.frame.size.height);
    }

    
    self.navigationController.toolbarHidden = NO;
    
    
    _productExecuteList = [[NSMutableArray alloc]init];
    _productExecuteTempList = [[NSMutableArray alloc]init];
    _productScanList = [[NSMutableArray alloc]init];
    _previousProductIDGroup = @"";
    _executeQR = NO;
    _previousDecryptedMessage = @"";
    _QRMismatch = NO;
    _scanBlank = NO;
    _choosePhoto = NO;
    
    
    txtQuantity.delegate = self;
    [stepper setMinimumValue:0];
    [stepper setContinuous:YES];
    [stepper setWraps:NO];
    [stepper setStepValue:1];
    [stepper setMaximumValue:99];
    txtQuantity.text = @"0";
    stepper.value = 0;
    [btnAdd.layer setBorderColor:[tBlueColor CGColor]];
    stepper.enabled = NO;
    txtQuantity.enabled = NO;
    btnAdd.enabled = NO;
    
    
//    [self loadViewProcess];
    [self loadingOverlayView];
    [_homeModel downloadItems:dbMainInventory];
}

- (void)itemsDownloaded:(NSArray *)items
{
    [self removeOverlayViews];
    int i=0;
    
//    [self addToMutArrPostDetail:items[i++]];
    [SharedProductName sharedProductName].productNameList = items[i++];
    [SharedColor sharedColor].colorList = items[i++];
    [SharedProductCategory2 sharedProductCategory2].productCategory2List = items[i++];
    [SharedProductCategory1 sharedProductCategory1].productCategory1List = items[i++];
    [SharedProductSize sharedProductSize].productSizeList = items[i++];
    [SharedProduct sharedProduct].productList = items[i++];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    stepper.value = textField.text.doubleValue;
    btnAdd.enabled = [textField.text integerValue] > 0;
}
//
//- (void)loadViewProcess
//{
//    
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _isReading = NO;
    _captureSession = nil;
    
    [self loadBeepSound];    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    if(!_choosePhoto)
    {
        [self startButtonClicked];
    }
    else
    {
        _choosePhoto = NO;
    }
    
    
    
    //Get Preview Layer connection
    AVCaptureConnection *previewLayerConnection=_videoPreviewLayer.connection;
    
    if ([previewLayerConnection isVideoOrientationSupported])
        [previewLayerConnection setVideoOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

-(void)itemsInserted
{
}

-(void)itemsUpdated
{
}

-(BOOL)startReading{
    NSError *error;
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    _captureSession = [[AVCaptureSession alloc] init];
    [_captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    //    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:_vwPreview.layer.bounds];
    [_vwPreview.layer addSublayer:_videoPreviewLayer];
    
    _captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    [_captureSession startRunning];
    
    return YES;
}

-(void)scanQRcode:(NSString *)decryptedMessage
{
    NSString *error;
    decryptedMessage = [decryptedMessage stringByReplacingOccurrencesOfString:@"\r"
                                                                   withString:@""];
    decryptedMessage = [decryptedMessage stringByReplacingOccurrencesOfString:@"\\n"
                                                                   withString:@"\n"];
    NSArray *lines = [decryptedMessage componentsSeparatedByString:@"\n"];
    NSString *line0Format = [NSString stringWithFormat:@"SAIM %@",[Utility makeFirstLetterUpperCaseOtherLower:[Utility dbName]]];
    if([lines count]==3 && [lines[0] isEqualToString:line0Format] && [lines[1] length] == 24 && [lines[2] isEqualToString:@"End"] && [Utility isValidProduct:[Utility getProductWithProductCode:lines[1]] error:&error])
    {
        //productCategory2+productCategory1+productName+color+size+year+month+day+id 00+00+00+00+xx+00+00+00+000000
        Product *productQR = [Utility getProductWithProductCode:lines[1]];
        NSString *currentProductIDGroup = [Utility getProductIDGroup:productQR];
        if(![_previousProductIDGroup isEqualToString:currentProductIDGroup])//กรณีถ้าซ้ำ แต่คนละกล่องก็จะเข้าอันนี้ เพราะต้องผ่านตัว clear _previousProductIDGroup = @"" ก่อนอยู่แล้ว
        {
            //insert qr
            _previousProductIDGroup = currentProductIDGroup;
            _scanBlank = NO;
            _dateScan = [NSDate date];
            
            
            _executeQR = YES;
            NSLog(@"qr change 0 second");
        }
        else if([_previousProductIDGroup isEqualToString:currentProductIDGroup] && _scanBlank)
        {
            NSDate *dateScanDelay = [_dateScan dateByAddingTimeInterval:[Utility getScanTimeInterValCaseBlur]];
            NSComparisonResult result = [[NSDate date] compare:dateScanDelay];
            if(result == NSOrderedDescending)//qrcode เดิม ซ้ำเกินเวลาที่กำหนด
            {
                //insert qr
                _scanBlank = NO;
                _dateScan = [NSDate date];
                
                
                _executeQR = YES;
                NSLog(@"scan blur 2 second");
            }
        }
        else if([_previousProductIDGroup isEqualToString:currentProductIDGroup] && !_scanBlank)
        {
            NSDate *dateScanDelay = [_dateScan dateByAddingTimeInterval:[Utility getScanTimeInterVal]];
            NSComparisonResult result = [[NSDate date] compare:dateScanDelay];
            if(result == NSOrderedDescending)//qrcode เดิม ซ้ำเกินเวลาที่กำหนด
            {
                //insert qr
                _scanBlank = NO;
                _dateScan = [NSDate date];
                
                
                _executeQR = YES;
                NSLog(@"scan repeat 5 second");
            }
        }
        
        
        
        if(_executeQR)
        {
            _executeQR = NO;
            
            
            //insert to db
            productQR.productID = [Utility getNextProductID];
            productQR.status = @"I";
            productQR.eventID = 0;
            productQR.modifiedUser = [Utility modifiedUser];
            productQR.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];            
            [[SharedProduct sharedProduct].productList addObject:productQR];//add to shared product
            [_productScanList addObject:productQR];
            [_productExecuteTempList addObject:productQR];
            if([_productExecuteTempList count] == [Utility getNumberOfRowForExecuteSql])
            {
                _productExecuteList = [NSMutableArray arrayWithArray:_productExecuteTempList];
                [_productExecuteTempList removeAllObjects];
                [_homeModel insertItems:dbProduct withData:_productExecuteList];
            }
            
            
            dispatch_async(dispatch_get_main_queue(),^ {
                _lblStatus.textColor = tBlueColor;
                _lblStatus.text = [NSString stringWithFormat:@"%lu",(unsigned long)[_productScanList count]];
                
                //show detail
                dispatch_async(dispatch_get_main_queue(), ^
                {
                     [self loadingOverlayViewForImage];
                });
                
                ProductName *productName = [ProductName getProductNameWithProduct:productQR];
                Color *color = [Color getColor:productQR.color];
                ProductSize *productSize = [ProductSize getProductSize:productQR.size];
                ProductSales *productSales = [ProductSales getProductSalesFromProductNameID:productName.productNameID color:productQR.color size:productQR.size  productSalesSetID:@"0"];
                NSString *imageFileName = productSales.imageDefault;
                [_homeModel downloadImageWithFileName:imageFileName completionBlock:^(BOOL succeeded, UIImage *image) {
                    if (succeeded) {
                        imgVwProduct.image = image;
                        dispatch_async(dispatch_get_main_queue(), ^
                        {
                             [self removeOverlayViewsForImage];
                        });
                        
                        NSLog(@"download image successful");
                    }else
                    {
                        NSLog(@"download image fail");
                        dispatch_async(dispatch_get_main_queue(), ^
                        {
                             [self removeOverlayViewsForImage];
                        });
                    }
                }];
                
                lblProductName.text = productName.name;
                lblColor.text = [NSString stringWithFormat:@"Color: %@",color.name];
                lblSize.text = [NSString stringWithFormat:@"Size: %@",productSize.sizeLabel];
                txtQuantity.text = @"1";
                stepper.value = 1;
                _productScan = productQR;
                stepper.enabled = YES;
                txtQuantity.enabled = YES;
                btnAdd.enabled = YES;
            } );
            if (_audioPlayer) {
                [_audioPlayer play];
            }
        }
    }
    else
    {
        //qr not match
        if(![decryptedMessage isEqualToString:_previousDecryptedMessage])
        {
            _previousDecryptedMessage = decryptedMessage;
            _scanBlank = NO;
            _dateScan = [NSDate date];
            _QRMismatch = YES;
        }
        else if([decryptedMessage isEqualToString:_previousDecryptedMessage] && _scanBlank)
        {
            NSDate *dateScanDelay = [_dateScan dateByAddingTimeInterval:[Utility getScanTimeInterValCaseBlur]];
            NSComparisonResult result = [[NSDate date] compare:dateScanDelay];
            if(result == NSOrderedDescending)//qrcode เดิม ซ้ำเกินเวลาที่กำหนด
            {
                _scanBlank = NO;
                _dateScan = [NSDate date];
                _QRMismatch = YES;
            }
        }
        else if([decryptedMessage isEqualToString:_previousDecryptedMessage] && !_scanBlank)
        {
            NSDate *dateScanDelay = [_dateScan dateByAddingTimeInterval:[Utility getScanTimeInterVal]];
            NSComparisonResult result = [[NSDate date] compare:dateScanDelay];
            if(result == NSOrderedDescending)//qrcode เดิม ซ้ำเกินเวลาที่กำหนด
            {
                _scanBlank = NO;
                _dateScan = [NSDate date];
                _QRMismatch = YES;
            }
        }
        
        if(_QRMismatch)
        {
            dispatch_async(dispatch_get_main_queue(),^ {
                _lblStatus.textColor = [UIColor redColor];
                _lblStatus.text = [Utility msg:codeMismatch];
            } );
            if (_audioPlayer)
            {
                [_audioPlayer play];
            }
        }
    }
}

-(void) addProductInMainInventory
{
//    NSInteger nextProductID = [[Utility getNextProductID] integerValue];
    for(int i=0; i<[txtQuantity.text integerValue]; i++)
    {
        Product *productQR = [_productScan copy];
        productQR.productID = [Utility getNextProductID];//[NSString stringWithFormat:@"%06ld", nextProductID+i];
        productQR.status = @"I";
        productQR.eventID = 0;
        productQR.modifiedUser = [Utility modifiedUser];
        productQR.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        
        [[SharedProduct sharedProduct].productList addObject:productQR];//add to shared product
        [_productScanList addObject:productQR];
        [_productExecuteTempList addObject:productQR];
        if([_productExecuteTempList count] == [Utility getNumberOfRowForExecuteSql])
        {
            _productExecuteList = [NSMutableArray arrayWithArray:_productExecuteTempList];
            [_productExecuteTempList removeAllObjects];
            [_homeModel insertItems:dbProduct withData:_productExecuteList];
        }
        
        
        dispatch_async(dispatch_get_main_queue(),^ {
            _lblStatus.textColor = tBlueColor;
            _lblStatus.text = [NSString stringWithFormat:@"%lu",(unsigned long)[_productScanList count]];
        } );
    }
}

-(void) loadingOverlayView
{
    [indicator startAnimating];
    indicator.layer.zPosition = 1;
    indicator.alpha = 1;
    
    
    // and just add them to navigationbar view
    [self.navigationController.view addSubview:overlayView];
    [self.navigationController.view addSubview:indicator];
}

-(void) removeOverlayViews{
    UIView *view = overlayView;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         view.alpha = 0.0;
                         indicator.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         dispatch_async(dispatch_get_main_queue(),^ {
                             [view removeFromSuperview];
                             [indicator stopAnimating];
                             [indicator removeFromSuperview];
                         } );
                         
                     }
     ];
}

-(void) loadingOverlayViewForImage
{
    [indicatorImage startAnimating];
    indicatorImage.layer.zPosition = 1;
    indicatorImage.alpha = 1;
    
    
    // and just add them to navigationbar view
    [self.navigationController.view addSubview:overlayViewImage];
    [self.navigationController.view addSubview:indicatorImage];
}

-(void) removeOverlayViewsForImage
{
    UIView *view = overlayViewImage;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         view.alpha = 0.0;
                         indicatorImage.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         dispatch_async(dispatch_get_main_queue(),^ {
                             [view removeFromSuperview];
                             [indicatorImage stopAnimating];
                             [indicatorImage removeFromSuperview];
                         } );
                         
                     }
     ];
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    if (metadataObjects && [metadataObjects count] > 0)
    {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode])
        {
            NSString *decryptedMessage = [metadataObj stringValue];
            [self scanQRcode:decryptedMessage];
        }
    }
    else
    {
        _scanBlank = YES;
    }
}

-(void)stopReading{
    [_captureSession stopRunning];
    _captureSession = nil;
    
    [_videoPreviewLayer removeFromSuperlayer];
    
    
    if([_productScanList count]>0)
    {
        [_productScanList removeAllObjects];
    }
    
    if([_productExecuteTempList count]>0)
    {
        _productExecuteList = [NSMutableArray arrayWithArray:_productExecuteTempList];
        [_productExecuteTempList removeAllObjects];
        [_homeModel insertItems:dbProduct withData:_productExecuteList];
    }
}

-(void)startButtonClicked
{
    if (!_isReading) {
        if ([self startReading]) {
            _lblStatus.textColor = tBlueColor;
            [_btnStart setTitle:@"Stop"];
            [_lblStatus setText:@"Scanning for QR Code/Barcode..."];
        }
    }
    else{
        [self stopReading];
        [_btnStart setTitle:@"Start!"];
        _lblStatus.textColor = tBlueColor;
        _lblStatus.text = @"QR Code/Barcode Reader is not yet running…";
        
        //clear product detail
        imgVwProduct.image = nil;
        lblProductName.text = @"";
        lblColor.text = @"";
        lblSize.text = @"";
        txtQuantity.text = @"0";
        stepper.value = 0;
        _productScan = nil;
        stepper.enabled = NO;
        txtQuantity.enabled = NO;
        btnAdd.enabled = NO;
    }
    
    _isReading = !_isReading;
}

- (IBAction)choosePhoto:(id)sender {
    _choosePhoto = YES;
    if(_isReading)
    {
        [self stopReading];
    }
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    
//    [alert addAction:
//     [UIAlertAction actionWithTitle:@"Take a new photo"
//                              style:UIAlertActionStyleDestructive
//                            handler:^(UIAlertAction *action) {
//                                [self takeNewPhotoFromCamera];
//                            }]];
    
    [alert addAction:
     [UIAlertAction actionWithTitle:@"Choose from existing"
                              style:UIAlertActionStyleDestructive
                            handler:^(UIAlertAction *action) {
                                [self choosePhotoFromExistingImages];
                            }]];
    
    [alert addAction:
     [UIAlertAction actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleCancel
                            handler:^(UIAlertAction *action) {}]];
    

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)takeNewPhotoFromCamera
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
        controller.allowsEditing = NO;
        controller.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
        controller.delegate = self;
        [self.navigationController presentViewController: controller animated: YES completion: nil];
    }
}

-(void)choosePhotoFromExistingImages
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        controller.allowsEditing = NO;
        controller.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
        controller.delegate = self;
        [self.navigationController presentViewController: controller animated: YES completion: nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.navigationController dismissViewControllerAnimated: YES completion: nil];
    UIImage *image = [info valueForKey: UIImagePickerControllerOriginalImage];
    CIImage *ciImage = [[CIImage alloc] initWithCGImage:image.CGImage options:nil];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                       context:nil
                       options:@{CIDetectorTracking: @YES,
                                 CIDetectorAccuracy: CIDetectorAccuracyLow}];
    NSString *qrCodeText = @"";
    NSArray *arrFeature = [detector featuresInImage:ciImage];
    for(CIQRCodeFeature *item in arrFeature)
    {
        qrCodeText = [NSString stringWithFormat:@"%@%@",qrCodeText,item.messageString];
    }
    [self scanQRcode:qrCodeText];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
{
    [self.navigationController dismissViewControllerAnimated: YES completion: nil];
}
- (IBAction)startStopReading:(id)sender {
    [self startButtonClicked];
}

-(void)loadBeepSound{
    NSString *beepFilePath = [[NSBundle mainBundle] pathForResource:@"beep" ofType:@"mp3"];
    NSURL *beepURL = [NSURL URLWithString:beepFilePath];
    NSError *error;
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:beepURL error:&error];
    if (error) {
        NSLog(@"Could not play beep file.");
        NSLog(@"%@", [error localizedDescription]);
    }
    else{
        [_audioPlayer prepareToPlay];
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if([sender isEqual:btnBack]){
        if(_isReading)
        {
            [self stopReading];
        }
    }
    return YES;
}

//-(void)itemsDownloaded:(NSArray *)items
//{
//    {
//        PushSync *pushSync = [[PushSync alloc]init];
//        pushSync.deviceToken = [Utility deviceToken];
//        [_homeModel updateItems:dbPushSyncUpdateByDeviceToken withData:pushSync];
//    }
//
//
//    [Utility itemsDownloaded:items];
//    [self removeOverlayViews];
//    [self loadViewProcess];
//}

- (void)itemsFail
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[Utility getConnectionLostTitle]
                                                                   message:[Utility getConnectionLostMessage]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
//                                                              [self loadingOverlayView];
//                                                              [_homeModel downloadItems:dbMaster];
                                                          }];
    
    [alert addAction:defaultAction];
    dispatch_async(dispatch_get_main_queue(),^ {
        [self presentViewController:alert animated:YES completion:nil];
    } );
}

- (void) connectionFail
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[Utility subjectNoConnection]
                                                                   message:[Utility detailNoConnection]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              //                                                              exit(0);
                                                          }];
    
    [alert addAction:defaultAction];
    dispatch_async(dispatch_get_main_queue(),^ {
        [self presentViewController:alert animated:YES completion:nil];
    } );
}


- (IBAction)stepperValueChanged:(id)sender {
    txtQuantity.text = [NSString stringWithFormat:@"%g",stepper.value];
    btnAdd.enabled = stepper.value > 0;
}

- (IBAction)addProduct:(id)sender {
    [self addProductInMainInventory];
}
@end

