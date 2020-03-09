//
//  PreOrderScanPostViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/19/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "PreOrderScanPostViewController.h"
#import "Utility.h"
#import "Product.h"
#import "CustomMade.h"
#import "ReceiptProductItem.h"
#import "CustomerReceipt.h"
#import "PostDetail.h"
#import "SharedProduct.h"
#import "SharedPushSync.h"
#import "PushSync.h"

#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]

@interface PreOrderScanPostViewController ()
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
}
@property (nonatomic) BOOL isReading;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;


-(BOOL)startReading;
-(void)stopReading;
@end

@implementation PreOrderScanPostViewController
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
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
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
                if(![_previousTrackingNo isEqualToString:decryptedMessage] && [_arrReceiptIDScanPost count]>0)
                {
                    _previousTrackingNo = decryptedMessage;
                    
                    
                    //update tracking id for the latest product id
                    CustomerReceipt *customerReceipt = [CustomerReceipt getCustomerReceiptWithReceiptID:[_arrReceiptIDScanPost[[_arrReceiptIDScanPost count]-1] integerValue]];
                    customerReceipt.trackingNo = decryptedMessage;
                    customerReceipt.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                    customerReceipt.modifiedUser = [Utility modifiedUser];
                    [_homeModel updateItems:dbCustomerReceiptUpdateTrackingNo withData:customerReceipt];
                    [_trackingNoScanList addObject:decryptedMessage];
                    
                    
                    dispatch_async(dispatch_get_main_queue(),^ {
                        _lblStatus.textColor = tBlueColor;
                        _lblStatus.text = [NSString stringWithFormat:@"TN:%lu",(unsigned long)[_trackingNoScanList count]];
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
                if(![_previousTrackingNo isEqualToString:decryptedMessage] && [_arrReceiptIDScanPost count]>0)
                {
                    _previousTrackingNo = decryptedMessage;
                    
                    
                    //update tracking id for the latest product id
                    CustomerReceipt *customerReceipt = [CustomerReceipt getCustomerReceiptWithReceiptID:[_arrReceiptIDScanPost[[_arrReceiptIDScanPost count]-1] integerValue]];
                    customerReceipt.trackingNo = decryptedMessage;
                    customerReceipt.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                    customerReceipt.modifiedUser = [Utility modifiedUser];
                    NSLog(@"customer receipt id: %ld, tracking no: %@",customerReceipt.customerReceiptID,customerReceipt.trackingNo);
                    [_homeModel updateItems:dbCustomerReceiptUpdateTrackingNo withData:customerReceipt];
                    [_trackingNoScanList addObject:decryptedMessage];
                    
                    
                    dispatch_async(dispatch_get_main_queue(),^ {
                        _lblStatus.textColor = tBlueColor;
                        _lblStatus.text = [NSString stringWithFormat:@"TN:%lu",(unsigned long)[_trackingNoScanList count]];
                    } );
                    if (_audioPlayer) {
                        [_audioPlayer play];
                    }
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
                        
                        
                        preOrderProduct = [self getPreOrderProduct:productQR];
                        if(preOrderProduct)
                        {
                            if([preOrderProduct.productType isEqualToString:@"P"])
                            {
                                productInMain = [self getProductInMainInventory:productQR preOrderProduct:preOrderProduct preOrderEventID:selectedPreOrderEventID];//แต่แรกจะสามารถสั่ง ​preorder ได้จาก stock main เท่านั้น ภายหลังได้เปลี่ยนเป็นจาก event ใดๆก็ได้ จึงยังใช้ชื่อเดิมอยู่ getProductInMainInventory
                                if(productInMain)
                                {
                                    //execute qr แบบ inventory
                                    [self executeQRInventory:productQR preOrderProduct:preOrderProduct productInMain:productInMain ];
                                }
                                else//เหตุการณ์นี้ต้องไม่เกิดมั๊ย เพราะถ้ามี preorder ก็ต้องมีในแหล่งที่มันจองสินค้าด้วย
                                {
                                    dispatch_async(dispatch_get_main_queue(),^ {
                                        _lblStatus.textColor = [UIColor redColor];
                                        _lblStatus.text = [NSString stringWithFormat:@"Scan-product is not in main inventory."];
                                    } );
                                    if (_audioPlayer)
                                    {
                                        [_audioPlayer play];
                                    }
                                }
                            }
                            else//cm แบบมีของอยู่แล้ว (สั่งผ่านหน้าจอ preorder)
                            {
                                productInMain = [self getProductInMainInventoryForCM:productQR preOrderEventID:selectedPreOrderEventID];
                                if(productInMain)
                                {
                                    _executeQR = YES;
                                }
                                else
                                {
                                    dispatch_async(dispatch_get_main_queue(),^ {
                                        _lblStatus.textColor = [UIColor redColor];
                                        _lblStatus.text = [NSString stringWithFormat:@"Scan-product is not in main inventory."];
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
                            dispatch_async(dispatch_get_main_queue(),^ {
                                _lblStatus.textColor = [UIColor redColor];
                                _lblStatus.text = [NSString stringWithFormat:@"Scan-product does not match pre-order product."];
                            } );
                            if (_audioPlayer)
                            {
                                [_audioPlayer play];
                            }
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
                            
                            
                            preOrderProduct = [self getPreOrderProduct:productQR];
                            if(preOrderProduct)
                            {
                                if([preOrderProduct.productType isEqualToString:@"P"])//cm แบบมีของอยู่แล้ว (สั่งผ่านหน้าจอ preorder)
                                {
                                    productInMain = [self getProductInMainInventory:productQR preOrderProduct:preOrderProduct preOrderEventID:selectedPreOrderEventID];
                                    if(productInMain)
                                    {
                                        //execute qr แบบ inventory
                                        [self executeQRInventory:productQR preOrderProduct:preOrderProduct productInMain:productInMain];
                                    }
                                    else
                                    {
                                        dispatch_async(dispatch_get_main_queue(),^ {
                                            _lblStatus.textColor = [UIColor redColor];
                                            _lblStatus.text = [NSString stringWithFormat:@"Scan-product is not in main inventory."];
                                        } );
                                        if (_audioPlayer)
                                        {
                                            [_audioPlayer play];
                                        }
                                    }
                                }
                                else
                                {
                                    productInMain = [self getProductInMainInventoryForCM:productQR preOrderEventID:selectedPreOrderEventID];
                                    if(productInMain)
                                    {
                                        _executeQR = YES;
                                    }
                                    else
                                    {
                                        dispatch_async(dispatch_get_main_queue(),^ {
                                            _lblStatus.textColor = [UIColor redColor];
                                            _lblStatus.text = [NSString stringWithFormat:@"Scan-product is not in main inventory."];
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
                                dispatch_async(dispatch_get_main_queue(),^ {
                                    _lblStatus.textColor = [UIColor redColor];
                                    _lblStatus.text = [NSString stringWithFormat:@"Scan-product does not match pre-order product."];
                                } );
                                if (_audioPlayer)
                                {
                                    [_audioPlayer play];
                                }
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
                            
                            
                            preOrderProduct = [self getPreOrderProduct:productQR];
                            if(preOrderProduct)
                            {
                                if([preOrderProduct.productType isEqualToString:@"P"])//cm แบบมีของอยู่แล้ว (สั่งผ่านหน้าจอ preorder)
                                {
                                    productInMain = [self getProductInMainInventory:productQR preOrderProduct:preOrderProduct preOrderEventID:selectedPreOrderEventID];
                                    if(productInMain)
                                    {
                                        //execute qr แบบ inventory
                                        [self executeQRInventory:productQR preOrderProduct:preOrderProduct productInMain:productInMain ];
                                    }
                                    else
                                    {
                                        dispatch_async(dispatch_get_main_queue(),^ {
                                            _lblStatus.textColor = [UIColor redColor];
                                            _lblStatus.text = [NSString stringWithFormat:@"Scan-product is not in main inventory."];
                                        } );
                                        if (_audioPlayer)
                                        {
                                            [_audioPlayer play];
                                        }
                                    }
                                }
                                else
                                {
                                    productInMain = [self getProductInMainInventoryForCM:productQR preOrderEventID:selectedPreOrderEventID];
                                    if(productInMain)
                                    {
                                        _executeQR = YES;
                                    }
                                    else
                                    {
                                        dispatch_async(dispatch_get_main_queue(),^ {
                                            _lblStatus.textColor = [UIColor redColor];
                                            _lblStatus.text = [NSString stringWithFormat:@"Scan-product is not in main inventory."];
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
                                dispatch_async(dispatch_get_main_queue(),^ {
                                    _lblStatus.textColor = [UIColor redColor];
                                    _lblStatus.text = [NSString stringWithFormat:@"Scan-product does not match pre-order product."];
                                } );
                                if (_audioPlayer)
                                {
                                    [_audioPlayer play];
                                }
                            }
                        }
                    }
                    
                    
                    if(_executeQR)
                    {
                        _executeQR = NO;
                        
                        
                        //update product status = S
                        //update custommade productidpost
                        //update receiptproductitem productid, type R
                        
                        PostDetail *postDetail = [self getPostDetailFromProductType:@"C" andProductID:preOrderProduct.productID];
                        NSString *strReceiptID = [NSString stringWithFormat:@"%ld",(long)postDetail.receiptID];
                        [_arrReceiptIDScanPost addObject:strReceiptID];
                        
                        
                        productInMain.status = @"S";
                        productInMain.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                        productInMain.modifiedUser = [Utility modifiedUser];
                        
                        CustomMade *customMade = [Utility getCustomMade:[preOrderProduct.productID integerValue]];
                        customMade.productIDPost = productInMain.productID;
                        customMade.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                        customMade.modifiedUser = [Utility modifiedUser];
                        
                        
                        ReceiptProductItem *receiptProductItem = [Utility getReceiptProductItem:postDetail.receiptProductItemID];
                        receiptProductItem.productID = productInMain.productID;
                        receiptProductItem.productType = @"R";
                        receiptProductItem.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                        receiptProductItem.modifiedUser = [Utility modifiedUser];
                        
                        [_CMScanList addObject:productInMain];
                        
                        
                        [_productCMExecuteTempList addObject:productInMain];
                        [_customMadeExecuteTempList addObject:customMade];
                        [_receiptProductItemCMExecuteTempList addObject:receiptProductItem];
                        if([_productCMExecuteTempList count] == [Utility getNumberOfRowForExecuteSql])
                        {
                            _productCMExecuteList = [NSMutableArray arrayWithArray:_productCMExecuteTempList];
                            [_productCMExecuteTempList removeAllObjects];
                            
                            _customMadeExecuteList = [NSMutableArray arrayWithArray:_customMadeExecuteTempList];
                            [_customMadeExecuteTempList removeAllObjects];
                            
                            _receiptProductItemCMExecuteList = [NSMutableArray arrayWithArray:_receiptProductItemCMExecuteTempList];
                            [_receiptProductItemCMExecuteTempList removeAllObjects];
                            
                            NSArray *arrProductSort;
                            NSArray *arrCustomMadeSort;
                            NSArray *arrReceiptProductItemSort;
                            {
                                NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_productID" ascending:YES];
                                NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
                                arrProductSort = [_productCMExecuteList sortedArrayUsingDescriptors:sortDescriptors];
                            }
                            {
                                NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_customMadeID" ascending:YES];
                                NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
                                arrCustomMadeSort = [_customMadeExecuteList sortedArrayUsingDescriptors:sortDescriptors];
                            }
                            {
                                NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_receiptProductItemID" ascending:YES];
                                NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
                                arrReceiptProductItemSort = [_receiptProductItemCMExecuteList sortedArrayUsingDescriptors:sortDescriptors];
                            }
                            
                            [_homeModel updateItems:dbReceiptProductItemPreOrderCM withData:@[arrProductSort,arrCustomMadeSort,arrReceiptProductItemSort]];
                        }
                        
                        [arrSelectedPostDetail removeObject:postDetail];
                        [mutArrPostDetailList removeObject:postDetail];
                        
                        
                        dispatch_async(dispatch_get_main_queue(),^ {
                            _lblStatus.textColor = tBlueColor;
                            _lblStatus.text = [NSString stringWithFormat:@"%lu",(unsigned long)([_productScanList count]+[_CMScanList count])];
                        } );
                        if (_audioPlayer)
                        {
                            [_audioPlayer play];
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
                        
                        
                        preOrderProduct = [self getPreOrderProduct:productQR];
                        if(preOrderProduct)
                        {
                            productInMain = [self getProductInMainInventory:productQR preOrderProduct:preOrderProduct preOrderEventID:selectedPreOrderEventID];
                            if(productInMain)
                            {
                                _executeQR = YES;
                            }
                            else
                            {
                                dispatch_async(dispatch_get_main_queue(),^ {
                                    _lblStatus.textColor = [UIColor redColor];
                                    _lblStatus.text = [NSString stringWithFormat:@"Scan-product is not in main inventory."];
                                } );
                                if (_audioPlayer)
                                {
                                    [_audioPlayer play];
                                }
                            }
                        }
                        else
                        {
                            dispatch_async(dispatch_get_main_queue(),^ {
                                _lblStatus.textColor = [UIColor redColor];
                                _lblStatus.text = [NSString stringWithFormat:@"Scan-product does not match pre-order product."];
                            } );
                            if (_audioPlayer)
                            {
                                [_audioPlayer play];
                            }
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
                            
                            
                            preOrderProduct = [self getPreOrderProduct:productQR];
                            if(preOrderProduct)
                            {
                                productInMain = [self getProductInMainInventory:productQR preOrderProduct:preOrderProduct preOrderEventID:selectedPreOrderEventID];
                                if(productInMain)
                                {
                                    _executeQR = YES;
                                }
                                else
                                {
                                    dispatch_async(dispatch_get_main_queue(),^ {
                                        _lblStatus.textColor = [UIColor redColor];
                                        _lblStatus.text = [NSString stringWithFormat:@"Scan-product is not in main inventory."];
                                    } );
                                    if (_audioPlayer)
                                    {
                                        [_audioPlayer play];
                                    }
                                }
                            }
                            else
                            {
                                dispatch_async(dispatch_get_main_queue(),^ {
                                    _lblStatus.textColor = [UIColor redColor];
                                    _lblStatus.text = [NSString stringWithFormat:@"Scan-product does not match pre-order product."];
                                } );
                                if (_audioPlayer)
                                {
                                    [_audioPlayer play];
                                }
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
                            
                            
                            preOrderProduct = [self getPreOrderProduct:productQR];
                            if(preOrderProduct)
                            {
                                productInMain = [self getProductInMainInventory:productQR preOrderProduct:preOrderProduct preOrderEventID:selectedPreOrderEventID];
                                if(productInMain)
                                {
                                    _executeQR = YES;
                                }
                                else
                                {
                                    dispatch_async(dispatch_get_main_queue(),^ {
                                        _lblStatus.textColor = [UIColor redColor];
                                        _lblStatus.text = [NSString stringWithFormat:@"Scan-product is not in main inventory."];
                                    } );
                                    if (_audioPlayer)
                                    {
                                        [_audioPlayer play];
                                    }
                                }
                            }
                            else
                            {
                                dispatch_async(dispatch_get_main_queue(),^ {
                                    _lblStatus.textColor = [UIColor redColor];
                                    _lblStatus.text = [NSString stringWithFormat:@"Scan-product does not match pre-order product."];
                                } );
                                if (_audioPlayer)
                                {
                                    [_audioPlayer play];
                                }
                            }
                        }
                    }
                    
                    
                    if(_executeQR)
                    {
                        _executeQR = NO;
                        [self executeQRInventory:productQR preOrderProduct:preOrderProduct productInMain:productInMain];
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
-(void) executeQRInventory:(Product *)productQR preOrderProduct:(Product *)preOrderProduct productInMain:(Product *)productInMain
{
    //update new product status from I to S and old status from P to I, it can be the same product so assign the old product first, then new product
    //update receiptproductitem producttype, productID
    
    PostDetail *postDetail = [self getPostDetailFromProductType:@"P" andProductID:preOrderProduct.productID];
    NSString *strReceiptID = [NSString stringWithFormat:@"%ld",(long)postDetail.receiptID];
    [_arrReceiptIDScanPost addObject:strReceiptID];
    

    preOrderProduct.status = @"I";
    preOrderProduct.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
    preOrderProduct.modifiedUser = [Utility modifiedUser];
    
    productInMain.status = @"S";
    productInMain.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
    productInMain.modifiedUser = [Utility modifiedUser];
    
    
    ReceiptProductItem *receiptProductItem = [Utility getReceiptProductItem:postDetail.receiptProductItemID];
    receiptProductItem.productType = @"S";
    receiptProductItem.productID = productInMain.productID;
    receiptProductItem.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
    receiptProductItem.modifiedUser = [Utility modifiedUser];
    
    [_productScanList addObject:preOrderProduct];
    
    
    [_productExecuteTempList addObject:preOrderProduct];
    [_productExecuteTempList addObject:productInMain];
    [_receiptProductItemExecuteTempList addObject:receiptProductItem];
    if([_productExecuteTempList count] == [Utility getNumberOfRowForExecuteSql])
    {
        _productExecuteList = [NSMutableArray arrayWithArray:_productExecuteTempList];
        [_productExecuteTempList removeAllObjects];
        
        _receiptProductItemExecuteList = [NSMutableArray arrayWithArray:_receiptProductItemExecuteTempList];
        [_receiptProductItemExecuteTempList removeAllObjects];
        
        NSArray *arrProductSort;
        NSArray *arrReceiptProductItemSort;
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
        
        [_homeModel updateItems:dbReceiptProductItemPreOrder withData:@[arrProductSort,arrReceiptProductItemSort]];
    }
    
    [arrSelectedPostDetail removeObject:postDetail];
    [mutArrPostDetailList removeObject:postDetail];
    
    
    dispatch_async(dispatch_get_main_queue(),^ {
        _lblStatus.textColor = tBlueColor;
        _lblStatus.text = [NSString stringWithFormat:@"%lu",(unsigned long)([_productScanList count]+[_CMScanList count])];
    } );
    
    
    if (_audioPlayer)
    {
        [_audioPlayer play];
    }
}
-(Product *)getProductInMainInventory:(Product *)product preOrderProduct:(Product *)preOrderProduct preOrderEventID:(NSInteger)preOrderEventID
{
    //ถ้ามี mfd เดียวกัน return ไปเลย
    //ถ้าไม่มี mfd เดียวกัน ให้ alert -> use product mfd:xx instead of mfd:xx โดยเลือก mfd ที่เก่าที่สุด
    //ถ้าไม่มี product นี้เลย alert -> please add this product to main inventory first.
    
    NSMutableArray *productList = [SharedProduct sharedProduct].productList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ and _productCategory1 = %@ and _productName = %@ and _color = %@ and _size = %@ and _manufacturingDate = %@ and _eventID = %ld and (_status = %@ or (_status = %@ and _productID = %@))",product.productCategory2,product.productCategory1,product.productName,product.color,product.size,product.manufacturingDate,preOrderEventID,@"I",@"P",preOrderProduct.productID];//use status = I ด้วย สำหรับกรณีหยิบสินค้าที่เป็นคนละ mfd กับที่ booked ไว้
    NSArray *filterArray = [productList filteredArrayUsingPredicate:predicate1];
    
    if([filterArray count] > 0)
    {
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_modifiedDate" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
        NSArray *sortArray = [filterArray sortedArrayUsingDescriptors:sortDescriptors];
        
        return sortArray[0];
    }
    else
    {
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ and _productCategory1 = %@ and _productName = %@ and _color = %@ and _size = %@ and _eventID = %ld and (_status = %@ or (_status = %@ and _productID = %@))",product.productCategory2,product.productCategory1,product.productName,product.color,product.size,preOrderEventID,@"I",@"P",preOrderProduct.productID];//use status = I ด้วย สำหรับกรณีหยิบสินค้าที่เป็นคนละ mfd กับที่ booked ไว้
        NSArray *filterArray = [productList filteredArrayUsingPredicate:predicate1];
        
        if([filterArray count] > 0)
        {
            NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_manufacturingDate" ascending:YES];
            NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_modifiedDate" ascending:YES];
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
-(Product *)getProductInMainInventoryForCM:(Product *)product preOrderEventID:(NSInteger)preOrderEventID
{
    //ถ้ามี mfd เดียวกัน return ไปเลย
    //ถ้าไม่มี mfd เดียวกัน ให้ alert -> use product mfd:xx instead of mfd:xx โดยเลือก mfd ที่เก่าที่สุด
    //ถ้าไม่มี product นี้เลย alert -> please add this product to main inventory first.
    
    NSMutableArray *productList = [SharedProduct sharedProduct].productList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ and _productCategory1 = %@ and _productName = %@ and _color = %@ and _size = %@ and _manufacturingDate = %@ and _eventID = %ld and _status = %@",product.productCategory2,product.productCategory1,product.productName,product.color,product.size,product.manufacturingDate,preOrderEventID,@"I"];
    NSArray *filterArray = [productList filteredArrayUsingPredicate:predicate1];
    
    if([filterArray count] > 0)
    {
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_modifiedDate" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
        NSArray *sortArray = [filterArray sortedArrayUsingDescriptors:sortDescriptors];
        
        return sortArray[0];
    }
    else
    {
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ and _productCategory1 = %@ and _productName = %@ and _color = %@ and _size = %@ and _eventID = %ld and _status = %@",product.productCategory2,product.productCategory1,product.productName,product.color,product.size,preOrderEventID,@"I"];
        NSArray *filterArray = [productList filteredArrayUsingPredicate:predicate1];
        
        if([filterArray count] > 0)
        {
            NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_manufacturingDate" ascending:YES];
            NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_modifiedDate" ascending:YES];
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

-(Product *)getPreOrderProduct:(Product *)product
{
    //ถ้ามี product เดียวกัน return ไปเลย
    //ถ้าไม่มี product นี้เลย alert -> Scan-product does not match pre-order product.
    
    NSMutableArray *arrPreOrderProduct = [[NSMutableArray alloc]init];
    for(PostDetail *item in arrSelectedPostDetail)//เตรียมข้อมูลใส่ arrPreOrderProduct เพื่อนำไป filter ต่อไป
    {
        if([item.productType isEqualToString:@"P"])
        {
            Product *product = [Product getProduct:item.productID];
            product.productType = @"P";///---ไม่เห็นใช้ทำอะไรเลย
            [arrPreOrderProduct addObject:product];
        }
        else if([item.productType isEqualToString:@"C"])
        {
            CustomMade *customMade = [Utility getCustomMade:[item.productID integerValue]];
            Product *customMadeProduct = [[Product alloc]init];
            customMadeProduct.productID = [NSString stringWithFormat:@"%ld",customMade.customMadeID];
            customMadeProduct.productCategory2 = customMade.productCategory2;
            customMadeProduct.productCategory1 = customMade.productCategory1;
            customMadeProduct.productName = customMade.productName;
            customMadeProduct.color = @"00";
            customMadeProduct.size = @"00";
            customMadeProduct.manufacturingDate = @"0000-00-00";
            customMadeProduct.modifiedDate = customMade.modifiedDate;
            customMadeProduct.modifiedUser = [Utility modifiedUser];
            customMadeProduct.productType = @"C";
//            product.productType = @"C";///---คืออะไรไม่แน่ใจ
            [arrPreOrderProduct addObject:customMadeProduct];
        }
    }
    
    
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ and _productCategory1 = %@ and _productName = %@ and _color = %@ and _size = %@",product.productCategory2,product.productCategory1,product.productName,product.color,product.size];
    NSArray *filterArray = [arrPreOrderProduct filteredArrayUsingPredicate:predicate2];
    
    
    if([filterArray count] > 0)
    {
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_manufacturingDate" ascending:YES];
        NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_modifiedDate" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2,nil];
        NSArray *sortArray = [filterArray sortedArrayUsingDescriptors:sortDescriptors];
        
        return sortArray[0];
    }
    else
    {
        return nil;
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
- (void)updatePostDetailList:(NSInteger)receiptProductItemID productType:(NSString *)productType
{
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_receiptProductItemID = %ld",receiptProductItemID];
    NSArray *filterArray = [mutArrPostDetailList filteredArrayUsingPredicate:predicate1];
    PostDetail *postDetail = filterArray[0];
    postDetail.productType = productType;
}

-(void)stopReading{
    [_captureSession stopRunning];
    _captureSession = nil;
    
    [_videoPreviewLayer removeFromSuperlayer];
    
    
    
    if([_productScanList count]>0)
    {
        [_productScanList removeAllObjects];
    }
    if([_CMScanList count]>0)
    {
        [_CMScanList removeAllObjects];
    }
    
    
    if([_productExecuteTempList count]>0)
    {
        _productExecuteList = [NSMutableArray arrayWithArray:_productExecuteTempList];
        [_productExecuteTempList removeAllObjects];
        
        _receiptProductItemExecuteList = [NSMutableArray arrayWithArray:_receiptProductItemExecuteTempList];
        [_receiptProductItemExecuteTempList removeAllObjects];
        
        
        NSArray *arrProductSort;
        NSArray *arrReceiptProductItemSort;
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
        
        [_homeModel updateItems:dbReceiptProductItemPreOrder withData:@[arrProductSort,arrReceiptProductItemSort]];
    }
    
    if([_productCMExecuteTempList count]>0)
    {
        _productCMExecuteList = [NSMutableArray arrayWithArray:_productCMExecuteTempList];
        [_productCMExecuteTempList removeAllObjects];
        
        _receiptProductItemCMExecuteList = [NSMutableArray arrayWithArray:_receiptProductItemCMExecuteTempList];
        [_receiptProductItemCMExecuteTempList removeAllObjects];
        
        _customMadeExecuteList = [NSMutableArray arrayWithArray:_customMadeExecuteTempList];
        [_customMadeExecuteTempList removeAllObjects];
        
        NSArray *arrProductSort;
        NSArray *arrReceiptProductItemSort;
        NSArray *arrCustomMadeSort;
        {
            NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_productID" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
            arrProductSort = [_productCMExecuteList sortedArrayUsingDescriptors:sortDescriptors];
        }
        {
            NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_receiptProductItemID" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
            arrReceiptProductItemSort = [_receiptProductItemCMExecuteList sortedArrayUsingDescriptors:sortDescriptors];
        }
        {
            NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_customMadeID" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
            arrCustomMadeSort = [_customMadeExecuteList sortedArrayUsingDescriptors:sortDescriptors];
        }
        
        [_homeModel updateItems:dbReceiptProductItemPreOrderCM withData:@[arrProductSort,arrCustomMadeSort,arrReceiptProductItemSort]];
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
- (IBAction)backButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"segUnwindToProductPost" sender:self];
}
@end
