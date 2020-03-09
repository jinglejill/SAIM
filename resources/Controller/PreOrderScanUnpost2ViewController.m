//
//  PreOrderScanUnpost2ViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/19/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "PreOrderScanUnpost2ViewController.h"
#import "Utility.h"
#import "Product.h"
#import "CustomMade.h"
#import "ReceiptProductItem.h"
#import "PostDetail.h"
#import "SharedProduct.h"
#import "SharedPushSync.h"
#import "PushSync.h"

#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]
@interface PreOrderScanUnpost2ViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSArray *_productList;
    Product *_product;
    
    NSMutableArray *_CMScanList;
    NSString *_preOrderProductID;
    NSString *_preOrderReceiptProductItemID;
    NSString *_productIDPost;
    NSMutableArray *_productScanPostList;
    NSMutableArray *_CMScanPostList;
    
    
    
    
    
    NSMutableArray *_productScanList;
    NSMutableArray *_productExecuteTempList;
    NSMutableArray *_productExecuteList;
    NSMutableArray *_receiptProductItemExecuteTempList;
    NSMutableArray *_receiptProductItemExecuteList;
    NSMutableArray *_customerReceiptExecuteTempList;
    NSMutableArray *_customerReceiptExecuteList;
    NSMutableArray *_productCMExecuteTempList;
    NSMutableArray *_productCMExecuteList;
    NSMutableArray *_receiptProductItemCMExecuteTempList;
    NSMutableArray *_receiptProductItemCMExecuteList;
    NSMutableArray *_customMadeExecuteTempList;
    NSMutableArray *_customMadeExecuteList;
    NSMutableArray *_customerReceiptCMExecuteTempList;
    NSMutableArray *_customerReceiptCMExecuteList;
    
    NSString *_previousProductIDGroup;
    NSDate *_dateScan;
    BOOL _executeQR;
    NSString *_previousDecryptedMessage;
    BOOL _QRMismatch;
    BOOL _scanBlank;
    
    
    NSInteger countScanSuccess;
}
@property (nonatomic) BOOL isReading;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;


-(BOOL)startReading;
-(void)stopReading;
@end

@implementation PreOrderScanUnpost2ViewController
@synthesize lblLocation;
@synthesize arrSelectedPostDetail;
@synthesize btnBackButton;
@synthesize mutArrPostDetailList;


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
    self.navigationItem.title = [NSString stringWithFormat:@"Pre-order Unpost"];
    
    lblLocation.text = @"";
    lblLocation.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    
    
    
    //product scanning this period not the whole product in inventory
    _CMScanList = [[NSMutableArray alloc]init];
    _productScanPostList = [[NSMutableArray alloc]init];
    _CMScanPostList = [[NSMutableArray alloc]init];
    
    
    _productList = [SharedProduct sharedProduct].productList;
    _productScanList = [[NSMutableArray alloc]init];
    _productExecuteTempList = [[NSMutableArray alloc]init];
    _productExecuteList = [[NSMutableArray alloc]init];
    _receiptProductItemExecuteTempList = [[NSMutableArray alloc]init];
    _receiptProductItemExecuteList = [[NSMutableArray alloc]init];
    _customerReceiptExecuteTempList = [[NSMutableArray alloc]init];
    _customerReceiptExecuteList = [[NSMutableArray alloc]init];
    _productCMExecuteTempList = [[NSMutableArray alloc]init];
    _productCMExecuteList = [[NSMutableArray alloc]init];
    _receiptProductItemCMExecuteTempList = [[NSMutableArray alloc]init];
    _receiptProductItemCMExecuteList = [[NSMutableArray alloc]init];
    _customMadeExecuteTempList = [[NSMutableArray alloc]init];
    _customMadeExecuteList = [[NSMutableArray alloc]init];
    _customerReceiptCMExecuteTempList = [[NSMutableArray alloc]init];
    _customerReceiptCMExecuteList = [[NSMutableArray alloc]init];
    
    
    _previousProductIDGroup = @"";
    _executeQR = NO;
    _previousDecryptedMessage = @"";
    _QRMismatch = NO;
    _scanBlank = NO;
    
    
    [self loadViewProcess];
}

- (void)loadViewProcess
{
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_productScanList removeAllObjects];
    [_CMScanList removeAllObjects];
    self.navigationController.toolbarHidden = NO;
}

- (void)viewDidLoad
{
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
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:_vwPreview.layer.bounds];
    [_vwPreview.layer addSublayer:_videoPreviewLayer];
    
    _captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    [_captureSession startRunning];
    
    return YES;
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
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
                //cm (productname = '00')
                NSRange needleRange = NSMakeRange(4,2);
                NSString *strProductName = [lines[1] substringWithRange:needleRange];
                if([strProductName isEqualToString:@"00"])
                {
                    //productCategory2+productCategory1+productName+color+size+year+month+day+id 00+00+00+00+xx+00+00+00+000000
                    Product *productQR = [Utility getProductWithProductCode:lines[1]];
                    Product *postedProduct;
                    NSString *currentProductIDGroup = [Utility getProductIDGroup:productQR];
                    if(![_previousProductIDGroup isEqualToString:currentProductIDGroup])
                    {
                        _previousProductIDGroup = currentProductIDGroup;
                        _scanBlank = NO;
                        _dateScan = [NSDate date];
                        
                        
                        //*****
                        [self queryInDbCM:productQR];
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
                            [self queryInDbCM:productQR];
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
                            [self queryInDbCM:productQR];
                            //*****
                        }
                    }
                }
                else// product inventory
                {
                    Product *productQR = [Utility getProductWithProductCode:lines[1]];
                    Product *postedProduct;
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
                    
                    
                    if(_executeQR)
                    {
                        _executeQR = NO;
                        
   
                        //update product status to P
                        //update receiptproductitem type P
                        //update customerreceipt tracking no=''
                        
                        PostDetail *postDetail = [self getPostDetailFromProductType:@"S" andProductID:postedProduct.productID];
                        
                        postedProduct.status = @"P";
                        postedProduct.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                        postedProduct.modifiedUser = [Utility modifiedUser];
                        
                        ReceiptProductItem *receiptProductItem = [Utility getReceiptProductItem:postDetail.receiptProductItemID];
                        receiptProductItem.productType = @"P";
                        receiptProductItem.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                        receiptProductItem.modifiedUser = [Utility modifiedUser];
                        
                        CustomerReceipt *customerReceipt = [CustomerReceipt getCustomerReceiptWithReceiptID:postDetail.receiptID];
                        customerReceipt.trackingNo = @"";
                        customerReceipt.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                        customerReceipt.modifiedUser = [Utility modifiedUser];
                        [_productScanList addObject:postedProduct];
                        
                        
                        
                        [_productExecuteTempList addObject:postedProduct];
                        [_receiptProductItemExecuteTempList addObject:receiptProductItem];
                        [_customerReceiptExecuteTempList addObject:customerReceipt];
                        if([_productExecuteTempList count] == [Utility getNumberOfRowForExecuteSql])
                        {
                            _productExecuteList = [NSMutableArray arrayWithArray:_productExecuteTempList];
                            [_productExecuteTempList removeAllObjects];
                            
                            _receiptProductItemExecuteList = [NSMutableArray arrayWithArray:_receiptProductItemExecuteTempList];
                            [_receiptProductItemExecuteTempList removeAllObjects];
                            
                            _customerReceiptExecuteList = [NSMutableArray arrayWithArray:_customerReceiptExecuteTempList];
                            [_customerReceiptExecuteTempList removeAllObjects];
                            
                            NSArray *arrProductSort;
                            NSArray *arrReceiptProductItemSort;
                            NSArray *arrCustomerReceiptSort;
                            {
                                NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_productID" ascending:YES];
                                NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
                                arrProductSort = [_productExecuteList sortedArrayUsingDescriptors:sortDescriptors];
                            }
                            {
                                NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_receiptProductItemID" ascending:YES];
                                NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
                                arrReceiptProductItemSort = [_receiptProductItemExecuteList sortedArrayUsingDescriptors:sortDescriptors];
                            }
                            {
                                NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_customerReceiptID" ascending:YES];
                                NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
                                arrReceiptProductItemSort = [_customerReceiptExecuteList sortedArrayUsingDescriptors:sortDescriptors];
                            }
                            
                            [_homeModel updateItems:dbReceiptProductItemUnpost withData:@[arrProductSort,arrReceiptProductItemSort,arrCustomerReceiptSort]];
                        }
                        [arrSelectedPostDetail removeObject:postDetail];
                        [mutArrPostDetailList removeObject:postDetail];
                        
                        
                        dispatch_async(dispatch_get_main_queue(),^ {
                            if(![postedProduct.remark isEqualToString:@""])
                            {
                                NSString *remark = [NSString stringWithFormat:@"use MFD:%@ instead of MFD:%@",[Utility formatDateForDisplay:postedProduct.manufacturingDate],[Utility formatDateForDisplay:productQR.manufacturingDate]];
                                _lblStatus.attributedText = [Utility getCountWithRemarkText:([_productScanList count]+[_CMScanList count]) remark:remark];
                            }
                            else
                            {
                                _lblStatus.textColor = tBlueColor;
                                _lblStatus.text = [NSString stringWithFormat:@"%lu",(unsigned long)([_productScanList count]+[_CMScanList count])];
                            }
                        } );
                        if (_audioPlayer)
                        {
                            [_audioPlayer play];
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

-(void)queryInDbCM:(Product *)productQR
{
    if (_audioPlayer)
    {
        [_audioPlayer play];
    }
    
    [self stopReading];
    dispatch_async(dispatch_get_main_queue(), ^
    {
         [self loadingOverlayView];
    });
    
    NSString *scanProductIDGroup = [Utility getProductIDGroup:productQR];
    [_homeModel updateItems:dbScanUnpostCM withData:@[arrSelectedPostDetail,scanProductIDGroup,[Utility modifiedUser],[Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"]]];
}

-(void)queryInDb:(Product *)productQR
{
    if (_audioPlayer)
    {
        [_audioPlayer play];
    }
    
    [self stopReading];
    dispatch_async(dispatch_get_main_queue(), ^
    {
         [self loadingOverlayView];
    });
    NSString *scanProductIDGroup = [Utility getProductIDGroup:productQR];
    [_homeModel updateItems:dbScanUnpost withData:@[arrSelectedPostDetail,scanProductIDGroup,[Utility modifiedUser],[Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"]]];
}

-(void)itemsUpdatedWithReturnID:(NSInteger)ID
{
    [self removeOverlayViews];
    if(ID == 0)
    {
        dispatch_async(dispatch_get_main_queue(),^
        {
            _lblStatus.textColor = [UIColor redColor];
            _lblStatus.text = @"Not found in selected posted product";
            [self startReading];
        } );
    }
    else
    {
        PostDetail *postDetail = [self getPostDetailFromReceiptProductItemID:ID];
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

-(Product *)getPostedProduct:(Product *)product
{
    //ถ้ามี mfd เดียวกัน return ไปเลย
    //ถ้าไม่มี mfd เดียวกัน ให้ alert -> use product mfd:xx instead of mfd:xx โดยเลือก mfd ที่ใหม่ที่สุด
    //ถ้าไม่มี product นี้เลย alert -> Scan-product does not match pre-order product.
    
    NSMutableArray *arrPostedProduct = [[NSMutableArray alloc]init];
    for(PostDetail *item in arrSelectedPostDetail)
    {
        Product *product = [Product getProduct:item.productID];
        [arrPostedProduct addObject:product];
    }
    
    
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ and _productCategory1 = %@ and _productName = %@ and _color = %@ and _size = %@ and _manufacturingDate = %@",product.productCategory2,product.productCategory1,product.productName,product.color,product.size,product.manufacturingDate];
    NSArray *filterArray = [arrPostedProduct filteredArrayUsingPredicate:predicate2];
    
    
    if([filterArray count] > 0)
    {
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_modifiedDate" ascending:NO];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
        NSArray *sortArray = [filterArray sortedArrayUsingDescriptors:sortDescriptors];
        
        return sortArray[0];
    }
    else
    {
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ and _productCategory1 = %@ and _productName = %@ and _color = %@ and _size = %@",product.productCategory2,product.productCategory1,product.productName,product.color,product.size];
        NSArray *filterArray = [arrPostedProduct filteredArrayUsingPredicate:predicate2];
        
        
        if([filterArray count] > 0)
        {
            NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_manufacturingDate" ascending:NO];
            NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_modifiedDate" ascending:NO];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2,nil];
            NSArray *sortArray = [filterArray sortedArrayUsingDescriptors:sortDescriptors];
            
            Product *matchProduct = sortArray[0];
            matchProduct.remark = [NSString stringWithFormat:@"Scan MFD:%@",[Utility formatDateForDisplay:product.manufacturingDate]];
            
            return matchProduct;
        }
        else
        {
            return nil;
        }
    }
}

-(PostDetail *)getPostDetailFromProductType:(NSString *)productType andProductID:(NSString *)productID
{
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"_productType = %@ and _productID = %@",productType,productID];
    NSArray *filterArray = [arrSelectedPostDetail filteredArrayUsingPredicate:predicate2];
    if([filterArray count]>0)
    {
        return filterArray[0];
    }
    return nil;
}

-(void)stopReading{
    [_captureSession stopRunning];
    _captureSession = nil;
    
    [_videoPreviewLayer removeFromSuperlayer];
}

-(void)startButtonClicked
{
    countScanSuccess = 0;
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

- (IBAction)backButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"segUnwindToProductPosted2" sender:self];
}
@end
