//
//  PreOrderScanPost2ViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/19/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "PreOrderScanPost2ViewController.h"
#import "Utility.h"
#import "Product.h"
#import "CustomMade.h"
#import "ReceiptProductItem.h"
#import "CustomerReceipt.h"
#import "ItemTrackingNo.h"
#import "PostDetail.h"
#import "SharedProduct.h"
#import "SharedPushSync.h"
#import "PushSync.h"

#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]

@interface PreOrderScanPost2ViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    Product *_product;
    NSMutableArray *_CMScanList;
    NSMutableArray *_trackingNoScanList;
    NSString *_preOrderProductID;
    NSString *_preOrderReceiptProductItemID;
    NSMutableArray *_productScanPostList;
    NSMutableArray *_CMScanPostList;
    NSMutableArray *_arrReceiptIDScanPost;
    
    
    NSString *_previousProductIDGroup;
    NSDate *_dateScan;
    BOOL _executeQR;
    NSMutableArray *_productScanList;
    NSMutableArray *_productExecuteTempList;
    NSMutableArray *_productExecuteList;
    NSMutableArray *_receiptProductItemExecuteTempList;
    NSMutableArray *_receiptProductItemExecuteList;
    NSMutableArray *_productCMExecuteTempList;
    NSMutableArray *_productCMExecuteList;
    NSMutableArray *_receiptProductItemCMExecuteTempList;
    NSMutableArray *_receiptProductItemCMExecuteList;
    NSMutableArray *_customMadeExecuteTempList;
    NSMutableArray *_customMadeExecuteList;
    NSString *_previousDecryptedMessage;
    NSString *_previousTrackingNo;
    BOOL _QRMismatch;
    BOOL _scanBlank;
    
    
    NSInteger countScanSuccess;
    NSInteger countTrackingNo;
    NSInteger _currentReceiptProductItemID;
//    NSInteger _currentReceiptID;
}
@property (nonatomic) BOOL isReading;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;


-(BOOL)startReading;
-(void)stopReading;
@end

@implementation PreOrderScanPost2ViewController
@synthesize lblLocation;
@synthesize arrSelectedPostDetail;
@synthesize btnBackButton;
@synthesize mutArrPostDetailList;
@synthesize selectedPreOrderEventID;


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
    
    
    self.navigationController.toolbarHidden = NO;
    self.navigationItem.title = [NSString stringWithFormat:@"Pre-order Scan"];
    
    lblLocation.text = @"";
    lblLocation.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    
    
    _arrReceiptIDScanPost = [[NSMutableArray alloc]init];
    _CMScanList = [[NSMutableArray alloc]init];
    _trackingNoScanList = [[NSMutableArray alloc]init];
    _productScanPostList = [[NSMutableArray alloc]init];
    _CMScanPostList = [[NSMutableArray alloc]init];
    
    
    _productScanList = [[NSMutableArray alloc]init];
    _productExecuteTempList = [[NSMutableArray alloc]init];
    _productExecuteList = [[NSMutableArray alloc]init];
    _receiptProductItemExecuteTempList = [[NSMutableArray alloc]init];
    _receiptProductItemExecuteList = [[NSMutableArray alloc]init];
    _productCMExecuteTempList = [[NSMutableArray alloc]init];
    _productCMExecuteList = [[NSMutableArray alloc]init];
    _receiptProductItemCMExecuteTempList = [[NSMutableArray alloc]init];
    _receiptProductItemCMExecuteList = [[NSMutableArray alloc]init];
    _customMadeExecuteTempList = [[NSMutableArray alloc]init];
    _customMadeExecuteList = [[NSMutableArray alloc]init];
    _previousProductIDGroup = @"";
    _executeQR = NO;
    _previousDecryptedMessage = @"";
    _previousTrackingNo = @"";
    _QRMismatch = NO;
    _scanBlank = NO;

    
    [self loadViewProcess];
}

- (void)loadViewProcess
{
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _isReading = NO;
    _captureSession = nil;
    
    [self loadBeepSound];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self startButtonClicked];
    
    
    //Get Preview Layer connection
    AVCaptureConnection *previewLayerConnection=_videoPreviewLayer.connection;
    
    if ([previewLayerConnection isVideoOrientationSupported])
        [previewLayerConnection setVideoOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

-(BOOL)startReading
{
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
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeQRCode,AVMetadataObjectTypeCode128Code, nil]];
    
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:_vwPreview.layer.bounds];
    [_vwPreview.layer addSublayer:_videoPreviewLayer];
    
    _captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    [_captureSession startRunning];
    
    return YES;
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    if (metadataObjects != nil && [metadataObjects count] > 0)
    {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeCode128Code])
        {
            NSString *decryptedMessage = [metadataObj stringValue];
            
            //tracking post barcode
            if([decryptedMessage length] == 13 || [decryptedMessage length] == 7 || [decryptedMessage length] < 18)
            {
                if(![_previousTrackingNo isEqualToString:decryptedMessage] && _currentReceiptProductItemID != 0)
                {
                    _previousTrackingNo = decryptedMessage;
                    
                    
                    //****
                    //trackingNo
                    //receiptID
                    //update tracking id for the latest product id
                    [self updateTrackingNoInDb:decryptedMessage];
                    //*******
        
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
        else if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode])
        {
            NSString *error;
            NSString *decryptedMessage = [metadataObj stringValue];
            decryptedMessage = [decryptedMessage stringByReplacingOccurrencesOfString:@"\r"
                                                                           withString:@""];
            decryptedMessage = [decryptedMessage stringByReplacingOccurrencesOfString:@"\\n"
                                                                           withString:@"\n"];
            NSArray *lines = [decryptedMessage componentsSeparatedByString:@"\n"];
            NSString *line0Format = [NSString stringWithFormat:@"SAIM %@",[Utility makeFirstLetterUpperCaseOtherLower:[Utility dbName]]];
            
            //tracking post barcode
            if([decryptedMessage length] < 18)
            {
                if(![_previousTrackingNo isEqualToString:decryptedMessage] && _currentReceiptProductItemID != 0)
                {
                    _previousTrackingNo = decryptedMessage;
                    
                    
                    //****
                    //trackingNo
                    //receiptID
                    //update tracking id for the latest product id
                    [self updateTrackingNoInDb:decryptedMessage];
                    //*******
                    
                    
                }
            }
            else if(!([lines count]==3 && [lines[0] isEqualToString:line0Format] && [lines[1] length] == 24 && [lines[2] isEqualToString:@"End"] && [Utility isValidProduct:[Utility getProductWithProductCode:lines[1]] error:&error]))
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
            else if([lines count]==3 && [lines[0] isEqualToString:line0Format] && [lines[1] length] == 24 && [lines[2] isEqualToString:@"End"] && [Utility isValidProduct:[Utility getProductWithProductCode:lines[1]] error:&error])//check product format
            {
                //cm (productname = '00')
                NSRange needleRange = NSMakeRange(4,2);
                NSString *strProductName = [lines[1] substringWithRange:needleRange];
                if([strProductName isEqualToString:@"00"])
                {
                    //productCategory2+productCategory1+productName+color+size+year+month+day+id 00+00+00+00+xx+00+00+00+000000
                    Product *productQR = [Utility getProductWithProductCode:lines[1]];
                    Product *productInMain;
                    Product *preOrderProduct;
                    NSString *currentProductIDGroup = [Utility getProductIDGroup:productQR];
                    if(![_previousProductIDGroup isEqualToString:currentProductIDGroup])
                    {
                        _previousProductIDGroup = currentProductIDGroup;
                        _scanBlank = NO;
                        _dateScan = [NSDate date];
                        
                        
                        //******
                        [self queryInDb:productQR];
                        //******
                 
                    }
                    else if([_previousProductIDGroup isEqualToString:currentProductIDGroup] && _scanBlank)
                    {
                        NSDate *dateScanDelay = [_dateScan dateByAddingTimeInterval:[Utility getScanTimeInterValCaseBlur]];
                        NSComparisonResult result = [[NSDate date] compare:dateScanDelay];
                        if(result == NSOrderedDescending)//qrcode เดิม ซ้ำเกินเวลาที่กำหนด
                        {
                            _scanBlank = NO;
                            _dateScan = [NSDate date];
                            
                            //*****
                            [self queryInDb:productQR];
                            //*****
                    
                        }
                    }
                    else if([_previousProductIDGroup isEqualToString:currentProductIDGroup] && !_scanBlank)
                    {
                        NSDate *dateScanDelay = [_dateScan dateByAddingTimeInterval:[Utility getScanTimeInterVal]];
                        NSComparisonResult result = [[NSDate date] compare:dateScanDelay];
                        if(result == NSOrderedDescending)//qrcode เดิม ซ้ำเกินเวลาที่กำหนด
                        {
                            _scanBlank = NO;
                            _dateScan = [NSDate date];
                            
                            
                            //*****
                            [self queryInDb:productQR];
                            //*****
                        }
                    }
                }
                else// product inventory
                {
                    Product *productQR = [Utility getProductWithProductCode:lines[1]];
                    Product *preOrderProduct;
                    Product *productInMain;
                    NSString *currentProductIDGroup = [Utility getProductIDGroup:productQR];
                    if(![_previousProductIDGroup isEqualToString:currentProductIDGroup])
                    {
                        _previousProductIDGroup = currentProductIDGroup;
                        _scanBlank = NO;
                        _dateScan = [NSDate date];
                        
                        
                        //*****
                        [self queryInDb:productQR];
                        //*****
                    }
                    else if([_previousProductIDGroup isEqualToString:currentProductIDGroup] && _scanBlank)
                    {
                        NSDate *dateScanDelay = [_dateScan dateByAddingTimeInterval:[Utility getScanTimeInterValCaseBlur]];
                        NSComparisonResult result = [[NSDate date] compare:dateScanDelay];
                        if(result == NSOrderedDescending)//qrcode เดิม ซ้ำเกินเวลาที่กำหนด
                        {
                            _scanBlank = NO;
                            _dateScan = [NSDate date];
                            
                            
                            //*****
                            [self queryInDb:productQR];
                            //*****
                        }
                    }
                    else if([_previousProductIDGroup isEqualToString:currentProductIDGroup] && !_scanBlank)
                    {
                        NSDate *dateScanDelay = [_dateScan dateByAddingTimeInterval:[Utility getScanTimeInterVal]];
                        NSComparisonResult result = [[NSDate date] compare:dateScanDelay];
                        if(result == NSOrderedDescending)//qrcode เดิม ซ้ำเกินเวลาที่กำหนด
                        {
                            _scanBlank = NO;
                            _dateScan = [NSDate date];
                            
                            
                            //*****
                            [self queryInDb:productQR];
                            //*****
                        }
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
    }
    else
    {
        _scanBlank = YES;
    }
}

-(void)queryInDb:(Product *)productQR
{
    if (_audioPlayer)
    {
        [_audioPlayer play];
    }
    
    [self stopReading];
    dispatch_async(dispatch_get_main_queue(),^ {
        [self loadingOverlayView];
    } );
    NSString *scanProductIDGroup = [Utility getProductIDGroup:productQR];
    [_homeModel updateItems:dbScanPost withData:@[arrSelectedPostDetail,scanProductIDGroup,[Utility modifiedUser],[Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"]]];
}

-(void)updateTrackingNoInDb:(NSString *)trackingNo
{
    if (_audioPlayer)
    {
        [_audioPlayer play];
    }
    
    [self stopReading];
    dispatch_async(dispatch_get_main_queue(),^ {
        [self loadingOverlayView];
    } );


    ItemTrackingNo *itemTrackingNo = [[ItemTrackingNo alloc]init];
    itemTrackingNo.receiptProductItemID = _currentReceiptProductItemID;
    itemTrackingNo.trackingNo = trackingNo;
    itemTrackingNo.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
    itemTrackingNo.modifiedUser = [Utility modifiedUser];
    [_homeModel updateItems:dbItemTrackingNoTrackingNoUpdate withData:itemTrackingNo];
}

- (void)itemsUpdated
{
    [self removeOverlayViews];
    
    
    countTrackingNo++;
    dispatch_async(dispatch_get_main_queue(),^
    {
        _lblStatus.textColor = tBlueColor;
        _lblStatus.text = [NSString stringWithFormat:@"TN:%lu",(unsigned long)countTrackingNo];
        [self startReading];
    } );
}

-(void)itemsUpdatedWithReturnID:(NSInteger)ID
{
    [self removeOverlayViews];
    if(ID == 0)
    {
        dispatch_async(dispatch_get_main_queue(),^
        {
            _lblStatus.textColor = [UIColor redColor];
            _lblStatus.text = @"Not found in selected to-post product";
            [self startReading];
        } );
    }
    else if(ID == -1)
    {
        dispatch_async(dispatch_get_main_queue(),^
        {
            _lblStatus.textColor = [UIColor redColor];
            _lblStatus.text = @"No product in inventory";
            [self startReading];
        } );
    }
    else
    {
        PostDetail *postDetail = [self getPostDetailFromReceiptProductItemID:ID];
//        _currentReceiptID = postDetail.receiptID;
        _currentReceiptProductItemID = ID;
        [arrSelectedPostDetail removeObject:postDetail];
        [mutArrPostDetailList removeObject:postDetail];
        
        
        countScanSuccess++;
        dispatch_async(dispatch_get_main_queue(),^
        {
            _lblStatus.textColor = tBlueColor;
            _lblStatus.text = [NSString stringWithFormat:@"%lu",(unsigned long)countScanSuccess];
            [self startReading];
        } );
    }
}

-(PostDetail *)getPostDetailFromReceiptProductItemID:(NSInteger)receiptProductItemID
{
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"_receiptProductItemID = %ld",receiptProductItemID];
    NSArray *filterArray = [arrSelectedPostDetail filteredArrayUsingPredicate:predicate2];
    if([filterArray count]>0)
    {
        return filterArray[0];
    }
    return nil;
}

-(void)stopReading
{
    [_captureSession stopRunning];
    _captureSession = nil;
    
    [_videoPreviewLayer removeFromSuperlayer];
}

-(void)startButtonClicked
{
    countScanSuccess = 0;
    countTrackingNo = 0;
    if (!_isReading)
    {
        if ([self startReading])
        {
            _lblStatus.textColor = tBlueColor;
            [_btnStart setTitle:@"Stop"];
            [_lblStatus setText:@"Scanning for QR Code/Barcode..."];
        }
    }
    else
    {
        [self stopReading];
        [_btnStart setTitle:@"Start!"];
        _lblStatus.textColor = tBlueColor;
        _lblStatus.text = @"QR Code/Barcode Reader is not yet running…";
    }
    
    _isReading = !_isReading;
}
- (IBAction)startStopReading:(id)sender
{
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
    if([sender isEqual:btnBackButton]){
        if(_isReading)
        {
            [self stopReading];
        }
    }
    return YES;
}

-(void)itemsDownloaded:(NSArray *)items
{

}

- (void)itemsFail
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[Utility getConnectionLostTitle]
                                                                   message:[Utility getConnectionLostMessage]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
//
                                                          }];
    
    [alert addAction:defaultAction];
    dispatch_async(dispatch_get_main_queue(),^ {
        [self presentViewController:alert animated:YES completion:nil];
    } );
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

- (IBAction)backButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"segUnwindToProductPost" sender:self];
}
@end
