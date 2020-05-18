//
//  ComparingScanViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/30/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "ComparingScanViewController.h"
#import "Utility.h"
#import "Product.h"
#import "SharedSelectedEvent.h"
#import "CompareInventory.h"
//#import "SharedComparingScan.h"
#import "SharedCompareInventory.h"
#import "SharedCompareProductScan.h"




#import "SharedPushSync.h"
#import "PushSync.h"

#define orangeColor         [UIColor colorWithRed:253/255.0 green:182/255.0 blue:103/255.0 alpha:1]
#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]

@interface ComparingScanViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSString *_previousProductIDGroup;
    NSDate *_dateScan;
    BOOL _executeQR;
    BOOL _extraQR;
    NSMutableArray *_productScanList;
    NSMutableArray *_productExecuteTempList;
    NSMutableArray *_productExecuteList;
    NSMutableArray *_compareInventoryList;
    NSString *_previousDecryptedMessage;
    BOOL _QRMismatch;
    BOOL _scanBlank;
    NSMutableArray *_productDuplicateList;

}
@property (nonatomic) BOOL isReading;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;


-(BOOL)startReading;
-(void)stopReading;
@end

@implementation ComparingScanViewController
@synthesize lblLocation;
@synthesize runningSetNo;
@synthesize btnSummary;


- (void)loadView
{
    [super loadView];
    
    _homeModel = [[HomeModel alloc] init];
    _homeModel.delegate = self;
    
    {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);
    }
    
    
    self.navigationController.toolbarHidden = NO;
    self.navigationItem.title = [NSString stringWithFormat:@"Comparing Scan"];
    lblLocation.text = [NSString stringWithFormat:@"Location: %@",[SharedSelectedEvent sharedSelectedEvent].event.location];
    lblLocation.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    
    
    _productScanList = [SharedCompareProductScan sharedCompareProductScan].compareProductScanList;
    _productExecuteTempList = [[NSMutableArray alloc]init];
    _productExecuteList = [[NSMutableArray alloc]init];
    _productDuplicateList = [[NSMutableArray alloc]init];
    _previousProductIDGroup = @"";
    _executeQR = NO;
    _extraQR = NO;
    _previousDecryptedMessage = @"";
    _QRMismatch = NO;
    _scanBlank = NO;
    
    
    [self loadViewProcess];
}

- (void)loadViewProcess
{
    _compareInventoryList = [SharedCompareInventory sharedCompareInventory].compareInventoryList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_runningSetNo = %@",runningSetNo];
    NSArray *filterArray = [_compareInventoryList filteredArrayUsingPredicate:predicate1];
    _compareInventoryList = [filterArray mutableCopy];
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
                CompareInventory *compareInventoryInEvent;
                NSString *currentProductIDGroup = [Utility getProductIDGroup:productQR];
                if(![_previousProductIDGroup isEqualToString:currentProductIDGroup])
                {
                    _previousProductIDGroup = currentProductIDGroup;
                    _scanBlank = NO;
                    _dateScan = [NSDate date];
                    
                    
                    compareInventoryInEvent = [self getCompareInventoryInEvent:productQR];
                    if(compareInventoryInEvent)
                    {
                        _executeQR = YES;
                    }
                    else
                    {
                        _extraQR = YES;
                    }
                }
                else if([_previousProductIDGroup isEqualToString:currentProductIDGroup] && _scanBlank)
                {
                    NSDate *dateScanDelay = [_dateScan dateByAddingTimeInterval:[Utility getScanTimeInterValCaseBlur]];
                    NSComparisonResult result = [[NSDate date] compare:dateScanDelay];
                    if(result == NSOrderedDescending)//qrcode เดิม ซ้ำเกินเวลาที่กำหนด
                    {
                        _scanBlank = NO;
                        _dateScan = [NSDate date];
                        
                        
                        compareInventoryInEvent = [self getCompareInventoryInEvent:productQR];
                        if(compareInventoryInEvent)
                        {
                            _executeQR = YES;
                        }
                        else
                        {
                            _extraQR = YES;
                        }
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
                                                
                        
                        compareInventoryInEvent = [self getCompareInventoryInEvent:productQR];
                        if(compareInventoryInEvent)
                        {
                            _executeQR = YES;
                        }
                        else
                        {
                            _extraQR = YES;
                        }
                    }
                }
                
                if(_extraQR)
                {
                    _extraQR = NO;
                    
                    BOOL productDuplicateStatus = NO;
                    if(![_productDuplicateList containsObject:productQR.productID])
                    {
                        [_productDuplicateList addObject:productQR.productID];
                    }
                    else
                    {
                        productDuplicateStatus = YES;
                    }
                    
                    //insert product ที่เกิน
                    CompareInventory *compareInventory = [[CompareInventory alloc]init];
                    compareInventory.runningSetNo = runningSetNo;
                    //                        compareInventory.productID = @"";// product จาก qr ต้อง generate id ใหม่ ถ้าเป็น product ในระบบอ้างอิง productid ได้
                    compareInventory.productCode = [Utility getProductCode:productQR];
                    compareInventory.compareStatus = !productDuplicateStatus?@"E":@"F";
                    compareInventory.compareStatusRemark = @"";
                    compareInventory.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                    
                    compareInventory.checkOrUnCheck = @"XMark";
                    compareInventory.productCategory2 = productQR.productCategory2;
                    
                    [_homeModel insertItems:dbCompareInventoryNotMatchInsert withData:compareInventory];
                    
                    
                    //updateshared
                    [[SharedCompareInventory sharedCompareInventory].compareInventoryList addObject:compareInventory];
                    
                    
                    dispatch_async(dispatch_get_main_queue(),^ {
                        _lblStatus.textColor = [UIColor redColor];
                        if(productDuplicateStatus)
                        {
                            _lblStatus.text = [NSString stringWithFormat:@"Scan-product does not match (product duplicate)"];
                        }
                        else
                        {
                            _lblStatus.text = [NSString stringWithFormat:@"Scan-product does not match."];
                        }
                    } );
                    if (_audioPlayer)
                    {
                        [_audioPlayer play];
                    }
                }
                
                if(_executeQR)
                {
                    _executeQR = NO;
                    
                    BOOL productDuplicateStatus = NO;
                    if(![_productDuplicateList containsObject:productQR.productID])
                    {
                        [_productDuplicateList addObject:productQR.productID];
                    }
                    else
                    {
                        productDuplicateStatus = YES;
                        if([compareInventoryInEvent.compareStatus isEqualToString:@"M"])
                        {
                            compareInventoryInEvent.compareStatus = @"D";
                        }
                        else// W
                        {
                            compareInventoryInEvent.compareStatus = @"V";//[self changeFirstLetter:@"V" inText:compareInventoryInEvent.compareStatus];
                        }
                    }
                    compareInventoryInEvent.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                    compareInventoryInEvent.checkOrUnCheck = [compareInventoryInEvent.compareStatus isEqualToString:@"M"] || [compareInventoryInEvent.compareStatus isEqualToString:@"D"]?@"CMark":@"XMark";
                    
                    [_productScanList addObject:compareInventoryInEvent];
                    [_productExecuteTempList addObject:compareInventoryInEvent];
                    if([_productExecuteTempList count] == [Utility getNumberOfRowForExecuteSql])
                    {
                        _productExecuteList = [NSMutableArray arrayWithArray:_productExecuteTempList];
                        [_productExecuteTempList removeAllObjects];
                        
                        
                        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_productID" ascending:YES];
                        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
                        NSArray *sortArray = [_productExecuteList sortedArrayUsingDescriptors:sortDescriptors];
                        [_homeModel updateItems:dbCompareInventory withData:sortArray];
                    }
                
                    
                    dispatch_async(dispatch_get_main_queue(),^ {
                        if([compareInventoryInEvent.compareStatus isEqualToString:@"M"])
                        {
                            _lblStatus.textColor = tBlueColor;
                            _lblStatus.text = [NSString stringWithFormat:@"%lu",(unsigned long)[_productScanList count]];
                        }
                        else if([compareInventoryInEvent.compareStatus isEqualToString:@"D"])
                        {
                            _lblStatus.attributedText = [Utility getCountWithRemarkText:[_productScanList count] remark:@"product duplicate"];
//                            _lblStatus.textColor = [UIColor redColor];
//                            _lblStatus.text = [NSString stringWithFormat:@"%lu (product duplicate)",(unsigned long)[_productScanList count]];
                        }
                        else//V W
                        {
                            NSString *remark = @"";
                            if([compareInventoryInEvent.compareStatus isEqualToString:@"V"])
                            {
                                remark = @"Match, wrong MFD, product duplicate";
                            }
                            else //W
                            {
                                remark = @"Match, wrong MFD";
                            }
                            _lblStatus.attributedText = [Utility getCountWithRemarkText:[_productScanList count] remark:remark];
//                            _lblStatus.textColor = [UIColor redColor];
//                            _lblStatus.text = [NSString stringWithFormat:@"%lu (Match, wrong MFD)%@",(unsigned long)[_productScanList count],remark];
                        }
                    } );
                    if (_audioPlayer)
                    {
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
    }
    else
    {
        _scanBlank = YES;
    }
}
-(NSString *)changeFirstLetter:(NSString *)letter inText:(NSString *)text
{
    NSRange needleRange = NSMakeRange(1,[text length]-1);
    NSString *newText = [text substringWithRange:needleRange];
    newText = [NSString stringWithFormat:@"%@%@",letter,newText];
    return newText;
}
-(CompareInventory *)getCompareInventoryInEvent:(Product *)product
{
    //ถ้ามี mfd เดียวกัน return ไปเลย
    //ถ้าไม่มี mfd เดียวกัน ให้ alert -> use product mfd:xx instead of mfd:xx โดยเลือก mfd ที่เก่าที่สุด
    //ถ้าไม่มี product นี้เลย alert -> please add this product to main inventory first.
    
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2Code = %@ and _productCategory1Code = %@ and _productNameCode = %@ and _colorCode = %@ and _sizeCode = %@ and _manufacturingDate = %@ and _compareStatus = %@ and _runningSetNo = %@",product.productCategory2,product.productCategory1,product.productName,product.color,product.size,product.manufacturingDate,@"N",runningSetNo];
    NSArray *filterArray = [_compareInventoryList filteredArrayUsingPredicate:predicate1];
    
    if([filterArray count] > 0)
    {
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_modifiedDate" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
        NSArray *sortArray = [filterArray sortedArrayUsingDescriptors:sortDescriptors];
        
        CompareInventory *matchProduct = sortArray[0];
        matchProduct.compareStatus = @"M";
        return sortArray[0];
    }
    else
    {
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2Code = %@ and _productCategory1Code = %@ and _productNameCode = %@ and _colorCode = %@ and _sizeCode = %@ and _compareStatus = %@ and _runningSetNo = %@",product.productCategory2,product.productCategory1,product.productName,product.color,product.size,@"N",runningSetNo];
        NSArray *filterArray = [_compareInventoryList filteredArrayUsingPredicate:predicate1];
        
        if([filterArray count] > 0)
        {
            NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_manufacturingDate" ascending:YES];
            NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_modifiedDate" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2,nil];
            NSArray *sortArray = [filterArray sortedArrayUsingDescriptors:sortDescriptors];
            
            NSString *strRemark = [NSString stringWithFormat:@"Scan MFD:%@",product.manufacturingDate];
            CompareInventory *matchProduct = sortArray[0];
            matchProduct.compareStatus = @"W";
            matchProduct.compareStatusRemark = strRemark;
            
            
            return matchProduct;
        }
        else
        {
            return nil;
        }        
    }
}

- (void)itemsInserted
{

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
        
        
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_productID" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
        NSArray *sortArray = [_productExecuteList sortedArrayUsingDescriptors:sortDescriptors];
        [_homeModel updateItems:dbCompareInventory withData:sortArray];
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
    }
    
    _isReading = !_isReading;
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
    if([sender isEqual:btnSummary ]){
        if(_isReading)
        {
            [self stopReading];
        }
    }
    return YES;
}

-(void)itemsDownloaded:(NSArray *)items
{
    {
        PushSync *pushSync = [[PushSync alloc]init];
        pushSync.deviceToken = [Utility deviceToken];
        [_homeModel updateItems:dbPushSyncUpdateByDeviceToken withData:pushSync];
    }
    
    
    [Utility itemsDownloaded:items];
    [self removeOverlayViews];
    [self loadViewProcess];
}
- (void)itemsFail
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[Utility getConnectionLostTitle]
                                                                   message:[Utility getConnectionLostMessage]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [self loadingOverlayView];
                                                              [_homeModel downloadItems:dbMaster];
                                                          }];
    
    [alert addAction:defaultAction];
    dispatch_async(dispatch_get_main_queue(),^ {
        [self presentViewController:alert animated:YES completion:nil];
    } );
}
- (void)itemsUpdated
{
    
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
@end
