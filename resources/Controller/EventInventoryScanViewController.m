//
//  EventInventoryScanViewController.m
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 8/9/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "EventInventoryScanViewController.h"
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

@interface EventInventoryScanViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIActivityIndicatorView *indicatorImage;
    UIView *overlayView;
    UIView *overlayViewImage;
    NSString *_previousProductIDGroup;
    NSDate *_dateScan;
    BOOL _executeQR;
    NSMutableArray *_productScanList;
    NSMutableArray *_productExecuteTempList;
    NSMutableArray *_productExecuteList;
    NSString *_previousDecryptedMessage;
    BOOL _QRMismatch;
    BOOL _scanBlank;
    BOOL _choosePhoto;
    Product *_productScan;
    
    
    NSInteger _productScanSuccessCount;
}

@property (nonatomic) BOOL isReading;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;


-(BOOL)startReading;
-(void)stopReading;

@end

@implementation EventInventoryScanViewController
@synthesize btnBack;
@synthesize lblLocation;
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
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);
    }
    
    
    self.navigationController.toolbarHidden = NO;
    self.navigationItem.title = [NSString stringWithFormat:@"Event - Inventory Scan"];
    lblLocation.text = [NSString stringWithFormat:@"Location: %@",[SharedSelectedEvent sharedSelectedEvent].event.location];
    lblLocation.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    
    
    _productScanList = [[NSMutableArray alloc]init];
    _productExecuteTempList = [[NSMutableArray alloc]init];
    _productExecuteList = [[NSMutableArray alloc]init];
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

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    stepper.value = textField.text.doubleValue;
    btnAdd.enabled = [textField.text integerValue] > 0;
}

//- (void)loadViewProcess
//{
//
//}

- (void)viewDidLoad
{
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
        Product *productInMain;
        NSString *currentProductIDGroup = [Utility getProductIDGroup:productQR];
        if(![_previousProductIDGroup isEqualToString:currentProductIDGroup])
        {
            _previousProductIDGroup = currentProductIDGroup;
            _scanBlank = NO;
            _dateScan = [NSDate date];
            _executeQR = YES;
            
            
//            productInMain = [self getProductInMainInventory:productQR];
//            if(productInMain)
//            {
//                _executeQR = YES;
//            }
//            else
//            {
//                dispatch_async(dispatch_get_main_queue(),^ {
//                    _lblStatus.textColor = [UIColor redColor];
//                    _lblStatus.text = [NSString stringWithFormat:@"Please add this product to main inventory first."];
//                } );
//                if (_audioPlayer)
//                {
//                    [_audioPlayer play];
//                }
//            }
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
                
//                productInMain = [self getProductInMainInventory:productQR];
//                if(productInMain)
//                {
//                    _executeQR = YES;
//                }
//                else
//                {
//                    dispatch_async(dispatch_get_main_queue(),^ {
//                        _lblStatus.textColor = [UIColor redColor];
//                        _lblStatus.text = [NSString stringWithFormat:@"Please add this product to main inventory first."];
//                    } );
//                    if (_audioPlayer)
//                    {
//                        [_audioPlayer play];
//                    }
//                }
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
                
                
//                productInMain = [self getProductInMainInventory:productQR];
//                if(productInMain)
//                {
//                    _executeQR = YES;
//                }
//                else
//                {
//                    dispatch_async(dispatch_get_main_queue(),^ {
//                        _lblStatus.textColor = [UIColor redColor];
//                        _lblStatus.text = [NSString stringWithFormat:@"Please add this product to main inventory first."];
//                    } );
//                    if (_audioPlayer)
//                    {
//                        [_audioPlayer play];
//                    }
//                }
            }
        }
        
        
        if(_executeQR)
        {
            _executeQR = NO;
            _productScan = productQR;
            
            
            NSInteger eventID = [SharedSelectedEvent sharedSelectedEvent].event.eventID;
            productQR.eventID = eventID;
            productQR.quantity = 1;
            [self loadingOverlayView];
            [_homeModel updateItems:dbProductMoveToEvent withData:productQR];
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

//-(Product *)getProductInMainInventory:(Product *)product
//{
//    //ถ้ามี mfd เดียวกัน return ไปเลย
//    //ถ้าไม่มี mfd เดียวกัน ให้ alert -> move product mfd:xx instead of mfd:xx โดยเลือก mfd ที่เก่าที่สุด
//    //ถ้าไม่มี product นี้เลย alert -> please add this product to main inventory first.
//
//    NSMutableArray *productList = [SharedProduct sharedProduct].productList;
//    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ and _productCategory1 = %@ and _productName = %@ and _color = %@ and _size = %@ and _manufacturingDate = %@ and _eventID = %ld and _status = %@",product.productCategory2,product.productCategory1,product.productName,product.color,product.size,product.manufacturingDate,0,@"I"];
//    NSArray *filterArray = [productList filteredArrayUsingPredicate:predicate1];
//
//    if([filterArray count] > 0)
//    {
//        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_modifiedDate" ascending:YES];
//        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
//        NSArray *sortArray = [filterArray sortedArrayUsingDescriptors:sortDescriptors];
//
//        return sortArray[0];
//    }
//    else
//    {
//        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ and _productCategory1 = %@ and _productName = %@ and _color = %@ and _size = %@ and _eventID = %ld and _status = %@",product.productCategory2,product.productCategory1,product.productName,product.color,product.size,0,@"I"];
//        NSArray *filterArray = [productList filteredArrayUsingPredicate:predicate1];
//
//        if([filterArray count] > 0)
//        {
//            NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_manufacturingDate" ascending:YES];
//            NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_modifiedDate" ascending:YES];
//            NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2,nil];
//            NSArray *sortArray = [filterArray sortedArrayUsingDescriptors:sortDescriptors];
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

- (void)itemsUpdatedWithReturnData:(NSArray *)data
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
        _productScanSuccessCount += _productScan.quantity;
        dispatch_async(dispatch_get_main_queue(),^ {
            _lblStatus.textColor = tBlueColor;
            _lblStatus.text = [NSString stringWithFormat:@"%lu",(unsigned long)_productScanSuccessCount];
        } );
        
        
        
        //show detail
        dispatch_async(dispatch_get_main_queue(), ^
        {
             [self loadingOverlayViewForImage];
        });
        ProductName *productName = [ProductName getProductNameWithProduct:_productScan];
        Color *color = [Color getColor:_productScan.color];
        ProductSize *productSize = [ProductSize getProductSize:_productScan.size];
        ProductSales *productSales = [ProductSales getProductSalesFromProductNameID:productName.productNameID color:_productScan.color size:_productScan.size  productSalesSetID:@"0"];
        NSString *imageFileName = productSales.imageDefault;
        [_homeModel downloadImageWithFileName:imageFileName completionBlock:^(BOOL succeeded, UIImage *image) {
            if (succeeded) {
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    imgVwProduct.image = image;
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
        
        dispatch_async(dispatch_get_main_queue(),^ {
            lblProductName.text = productName.name;
            lblColor.text = [NSString stringWithFormat:@"Color: %@",color.name];
            lblSize.text = [NSString stringWithFormat:@"Size: %@",productSize.sizeLabel];
            txtQuantity.text = @"1";
            stepper.value = 1;
    //        _productScan = productQR;
            stepper.enabled = YES;
            txtQuantity.enabled = YES;
            btnAdd.enabled = YES;
        } );
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(),^ {
            _lblStatus.textColor = [UIColor redColor];
            _lblStatus.text = message.message;
            _productScan = nil;
        } );
    }
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


- (IBAction)addProduct:(id)sender
{
    NSInteger count = [txtQuantity.text integerValue];
    _productScan.quantity = count;
    [self loadingOverlayView];
    [_homeModel updateItems:dbProductMoveToEvent withData:_productScan];
    
    
    
//    NSMutableArray *productListInMain = [Product getProductListInMainInventory:_productScan];
//    [self addProductInMainInventory:productListInMain];
    
    
//    NSMutableArray *productListInMain = [Product getProductListInMainInventory:_productScan];
//    if([productListInMain count] < [txtQuantity.text integerValue])
//    {
//        dispatch_async(dispatch_get_main_queue(),^ {
//            _lblStatus.textColor = [UIColor redColor];
//            _lblStatus.text = [NSString stringWithFormat:@"No scan product/Scan product is not enough in main inventory"];
//        } );
//    }
//    else
//    {
//        [self addProductInMainInventory:productListInMain];
//    }
    
}

//-(void) addProductInMainInventory:(NSMutableArray *)productListInMain
//{
//    NSInteger count = [txtQuantity.text integerValue];
//    for(Product *productInMain in productListInMain)
//    {
//        if(count == 0 ) break;
//
//        productInMain.eventID = [SharedSelectedEvent sharedSelectedEvent].event.eventID;
//        productInMain.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
//        productInMain.modifiedUser = [Utility modifiedUser];
//        [_productScanList addObject:productInMain];
//        [_productExecuteTempList addObject:productInMain];
//
//
//        if([_productExecuteTempList count] == [Utility getNumberOfRowForExecuteSql])
//        {
//            _productExecuteList = [NSMutableArray arrayWithArray:_productExecuteTempList];
//            [_productExecuteTempList removeAllObjects];
//
//
//            NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_productID" ascending:YES];
//            NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
//            NSArray *sortArray = [_productExecuteList sortedArrayUsingDescriptors:sortDescriptors];
//            [_homeModel updateItems:dbProduct withData:sortArray];
//        }
//
//
//        dispatch_async(dispatch_get_main_queue(),^ {
//            _lblStatus.textColor = tBlueColor;
//            _lblStatus.text = [NSString stringWithFormat:@"%lu",(unsigned long)[_productScanList count]];
//        } );
//        count--;
//    }
//}

-(void)startButtonClicked
{
    if (!_isReading)
    {
        if ([self startReading]) {
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

- (IBAction)stepperValueChanged:(id)sender {
    txtQuantity.text = [NSString stringWithFormat:@"%g",stepper.value];
    btnAdd.enabled = stepper.value > 0;
}

@end
