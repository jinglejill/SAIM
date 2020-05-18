//
//  EventProductDeleteScanViewController.m
//  SAIM_UPDATING
//
//  Created by Thidaporn Kijkamjai on 4/25/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "EventProductDeleteScanViewController.h"
#import "Utility.h"
#import "Product.h"
#import "SharedSelectedEvent.h"
#import "SharedProduct.h"
#import "SharedPushSync.h"
#import "PushSync.h"

#import "SharedProduct.h"
#import "SharedProductSize.h"
#import "SharedProductName.h"
#import "SharedProductCategory2.h"
#import "SharedProductCategory1.h"
#import "SharedColor.h"
#import "Message.h"

#define orangeColor         [UIColor colorWithRed:253/255.0 green:182/255.0 blue:103/255.0 alpha:1]
#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]

@interface EventProductDeleteScanViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSString *_previousProductIDGroup;
    NSDate *_dateScan;
    BOOL _executeQR;
    NSMutableArray *_productScanList;
    NSMutableArray *_productExecuteTempList;
    NSMutableArray *_productExecuteList;
    NSString *_previousDecryptedMessage;
    BOOL _QRMismatch;
    BOOL _scanBlank;
    
    NSInteger _productScanSuccessCount;
}

@property (nonatomic) BOOL isReading;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;


-(BOOL)startReading;
-(void)stopReading;

@end


@implementation EventProductDeleteScanViewController

@synthesize btnBack;
@synthesize lblLocation;
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
    self.navigationItem.title = [NSString stringWithFormat:@"Event - Delete Inventory Scan"];
    lblLocation.text = [NSString stringWithFormat:@"Location: %@",[SharedSelectedEvent sharedSelectedEvent].event.location];
    lblLocation.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    
    
    //product scanning this period not the whole product in inventory
    _productScanList = [[NSMutableArray alloc]init];
    _productExecuteTempList = [[NSMutableArray alloc]init];
    _productExecuteList = [[NSMutableArray alloc]init];
    _previousProductIDGroup = @"";
    _executeQR = NO;
    _previousDecryptedMessage = @"";
    _QRMismatch = NO;
    _scanBlank = NO;
    

    //    [self loadViewProcess];
//    [self loadingOverlayView];
//    [_homeModel downloadItems:dbMainInventory];
}

//- (void)itemsDownloaded:(NSArray *)items
//{
//    [self removeOverlayViews];
//    int i=0;
//
////    [self addToMutArrPostDetail:items[i++]];
//    [SharedProductName sharedProductName].productNameList = items[i++];
//    [SharedColor sharedColor].colorList = items[i++];
//    [SharedProductCategory2 sharedProductCategory2].productCategory2List = items[i++];
//    [SharedProductCategory1 sharedProductCategory1].productCategory1List = items[i++];
//    [SharedProductSize sharedProductSize].productSizeList = items[i++];
//    [SharedProduct sharedProduct].productList = items[i++];
//}


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
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
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
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode])
        {
            NSString *error;
            NSString *decryptedMessage = [metadataObj stringValue];
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
                Product *productInEvent;
                NSString *currentProductIDGroup = [Utility getProductIDGroup:productQR];
                if(![_previousProductIDGroup isEqualToString:currentProductIDGroup])
                {
                    _previousProductIDGroup = currentProductIDGroup;
                    _scanBlank = NO;
                    _dateScan = [NSDate date];
                    _executeQR = YES;
                    
//                    productInEvent = [self getProductInEventInventory:productQR];
//                    if(productInEvent)
//                    {
//                        _executeQR = YES;
//                    }
//                    else
//                    {
//                        dispatch_async(dispatch_get_main_queue(),^ {
//                            _lblStatus.textColor = [UIColor redColor];
//                            _lblStatus.text = [NSString stringWithFormat:@"No scan-product in this event."];
//                        } );
//                        if (_audioPlayer)
//                        {
//                            [_audioPlayer play];
//                        }
//                    }
                }
                else if([_previousProductIDGroup isEqualToString:currentProductIDGroup] && _scanBlank)
                {
                    NSDate *dateScanDelay = [_dateScan dateByAddingTimeInterval:[Utility getScanTimeInterValCaseBlur]];
                    NSComparisonResult result = [[NSDate date] compare:dateScanDelay];
                    if(result == NSOrderedDescending)//qrcode เดิม ซ้ำเกินเวลาที่กำหนด
                    {
                        _scanBlank = NO;
                        _dateScan = [NSDate date];
                        _executeQR = YES;
                        
                        
//                        productInEvent = [self getProductInEventInventory:productQR];
//                        if(productInEvent)
//                        {
//                            _executeQR = YES;
//                        }
//                        else
//                        {
//                            dispatch_async(dispatch_get_main_queue(),^ {
//                                _lblStatus.textColor = [UIColor redColor];
//                                _lblStatus.text = [NSString stringWithFormat:@"No scan-product in this event."];
//                            } );
//                            if (_audioPlayer)
//                            {
//                                [_audioPlayer play];
//                            }
//                        }
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
                        _executeQR = YES;
                          
                        
//                        productInEvent = [self getProductInEventInventory:productQR];
//                        if(productInEvent)
//                        {
//                            _executeQR = YES;
//                        }
//                        else
//                        {
//                            dispatch_async(dispatch_get_main_queue(),^ {
//                                _lblStatus.textColor = [UIColor redColor];
//                                _lblStatus.text = [NSString stringWithFormat:@"No scan-product in this event."];
//                            } );
//                            if (_audioPlayer)
//                            {
//                                [_audioPlayer play];
//                            }
//                        }
                    }
                }
                
                
                
                if(_executeQR)
                {
                    _executeQR = NO;
                    
                    NSInteger eventID = [SharedSelectedEvent sharedSelectedEvent].event.eventID;
                    productQR.eventID = eventID;
                    [self loadingOverlayView];
                    [_homeModel updateItems:dbProductMoveToMain withData:productQR];
//                    productInEvent.eventID = 0;
//                    productInEvent.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
//                    productInEvent.modifiedUser = [Utility modifiedUser];
//                    [_productScanList addObject:productInEvent];
//                    [_productExecuteTempList addObject:productInEvent];
//                    if([_productExecuteTempList count] == [Utility getNumberOfRowForExecuteSql])
//                    {
//                        _productExecuteList = [NSMutableArray arrayWithArray:_productExecuteTempList];
//                        [_productExecuteTempList removeAllObjects];
//
//
//                        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_productID" ascending:YES];
//                        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
//                        NSArray *sortArray = [_productExecuteList sortedArrayUsingDescriptors:sortDescriptors];
//                        [_homeModel updateItems:dbProduct withData:sortArray];
//                    }
//
//
//                    dispatch_async(dispatch_get_main_queue(),^ {
////                        if(![productInEvent.remark isEqualToString:@""])
////                        {
////                            NSString *remark = [NSString stringWithFormat:@"delete MFD:%@ instead of MFD:%@",[Utility formatDateForDisplay:productInEvent.manufacturingDate],[Utility formatDateForDisplay:productQR.manufacturingDate]];
////                            _lblStatus.attributedText = [Utility getCountWithRemarkText:[_productScanList count] remark:remark];
////                        }
////                        else
//                        {
//                            _lblStatus.textColor = tBlueColor;
//                            _lblStatus.text = [NSString stringWithFormat:@"%lu",(unsigned long)[_productScanList count]];
//                        }
//                    } );
//                    if (_audioPlayer)
//                    {
//                        [_audioPlayer play];
//                    }
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

-(void)itemsUpdatedWithReturnData:(NSArray *)data
{
    [self removeOverlayViews];
    NSMutableArray *messageList = data[0];
    InAppMessage *message = messageList[0];
    if (_audioPlayer)
    {
        [_audioPlayer play];
    }
    
    if([Utility isStringEmpty: message.message])
    {
        dispatch_async(dispatch_get_main_queue(),^ {
            _lblStatus.textColor = tBlueColor;
            _lblStatus.text = [NSString stringWithFormat:@"%lu",(unsigned long)++_productScanSuccessCount];
        } );        
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(),^ {
            _lblStatus.textColor = [UIColor redColor];
            _lblStatus.text = message.message;
        } );
    }
}
//
//-(Product *)getProductInEventInventory:(Product *)product
//{
//    //ถ้ามี mfd เดียวกัน return เลย
//    //ถ้าไม่มี mfd เดียวกัน ให้ alert -> delete product mfd: instead of mfd: โดยเลือกอันที่ใหม่ที่สุด
//    //ถ้าไม่มี product ให้ alert -> no scan-product in this event
//
//    NSInteger eventID = [SharedSelectedEvent sharedSelectedEvent].event.eventID;
//    NSMutableArray *productList = [SharedProduct sharedProduct].productList;
//    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ and _productCategory1 = %@ and _productName = %@ and _color = %@ and _size = %@ and _manufacturingDate = %@ and _eventID = %ld and _status = %@",product.productCategory2,product.productCategory1,product.productName,product.color,product.size,product.manufacturingDate,eventID,@"I"];
//    NSArray *filterArray = [productList filteredArrayUsingPredicate:predicate1];
//
//    if([filterArray count] > 0)
//    {
//        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_modifiedDate" ascending:NO];
//        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
//        NSArray *sortArray = [filterArray sortedArrayUsingDescriptors:sortDescriptors];
//
//        return sortArray[0];
//    }
//    else
//    {
//        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ and _productCategory1 = %@ and _productName = %@ and _color = %@ and _size = %@ and _eventID = %ld and _status = %@",product.productCategory2,product.productCategory1,product.productName,product.color,product.size,eventID,@"I"];
//        NSArray *filterArray = [productList filteredArrayUsingPredicate:predicate1];
//
//        if([filterArray count] > 0)
//        {
//            NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_manufacturingDate" ascending:NO];
//            NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_modifiedDate" ascending:NO];
//            NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2,nil];
//            NSArray *sortArray = [filterArray sortedArrayUsingDescriptors:sortDescriptors];
//
//            Product *matchProduct = sortArray[0];
//            matchProduct.remark = [NSString stringWithFormat:@"Scan MFD:%@",[Utility formatDateForDisplay:product.manufacturingDate]];
//
//            return matchProduct;
//        }
//        else
//        {
//            return nil;
//        }
//    }
//}

-(void)stopReading{
    [_captureSession stopRunning];
    _captureSession = nil;
    
    [_videoPreviewLayer removeFromSuperlayer];
    
    _productScanSuccessCount = 0;
    
//    if([_productScanList count]>0)
//    {
//        [_productScanList removeAllObjects];
//    }
//
//    if([_productExecuteTempList count]>0)
//    {
//        _productExecuteList = [NSMutableArray arrayWithArray:_productExecuteTempList];
//        [_productExecuteTempList removeAllObjects];
//
//
//        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_productID" ascending:YES];
//        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
//        NSArray *sortArray = [_productExecuteList sortedArrayUsingDescriptors:sortDescriptors];
//        [_homeModel updateItems:dbProduct withData:sortArray];
//    }
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
    }
    
    _isReading = !_isReading;
}
- (IBAction)startStopReading:(id)sender {
    [self startButtonClicked];
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

- (void)itemsFail
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[Utility getConnectionLostTitle]
                                                                   message:[Utility getConnectionLostMessage]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {

                                                          }];
    
    [alert addAction:defaultAction];
    dispatch_async(dispatch_get_main_queue(),^ {
        [self presentViewController:alert animated:YES completion:nil];
    } );
}

-(void) loadingOverlayView
{
    dispatch_async(dispatch_get_main_queue(),^ {
        [indicator startAnimating];
        indicator.layer.zPosition = 1;
        indicator.alpha = 1;
        
        // and just add them to navigationbar view
        [self.navigationController.view addSubview:overlayView];
        [self.navigationController.view addSubview:indicator];
    });    
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

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
