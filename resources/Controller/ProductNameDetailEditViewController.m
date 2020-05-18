//
//  ProductNameDetailEditViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 3/13/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "ProductNameDetailEditViewController.h"
#import "HomeModel.h"
#import "Utility.h"
#import "ProductSales.h"
#import "SharedProductSales.h"
#import "SharedPushSync.h"
#import "PushSync.h"
#import <Photos/Photos.h>

#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]
#define tYellow          [UIColor colorWithRed:251/255.0 green:188/255.0 blue:5/255.0 alpha:1]
#define tTheme          [UIColor colorWithRed:196/255.0 green:164/255.0 blue:168/255.0 alpha:1]


@interface ProductNameDetailEditViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    BOOL _booImageSelect;
}
@end



@implementation ProductNameDetailEditViewController
@synthesize arrProductSalesID;
@synthesize edit;
@synthesize btnCancel;
@synthesize btnDone;
@synthesize productNameDetailList;


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
    switch (status) {
        case PHAuthorizationStatusAuthorized:
            NSLog(@"PHAuthorizationStatusAuthorized");
            break;
        case PHAuthorizationStatusDenied:
            NSLog(@"PHAuthorizationStatusDenied");
            break;
        case PHAuthorizationStatusNotDetermined:
            NSLog(@"PHAuthorizationStatusNotDetermined");
            break;
        case PHAuthorizationStatusRestricted:
            NSLog(@"PHAuthorizationStatusRestricted");
            break;
    }
}];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.000001f;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if([arrProductSalesID count]==1)
    {
        //get product sales to show
        ProductSales *selectedProductSales = arrProductSalesID[0];
        ProductSales *productSales = [self getProductSales:selectedProductSales.productSalesID fromList:productNameDetailList];;
        if(indexPath.row == 0)
        {
            txtPrice.text = productSales.price;
            [cell addSubview:txtPrice];
            
            if(![productSales.price isEqualToString:@"0"])
            {
                swtPrice.on = NO;
            }
        }
        else if(indexPath.row == 1)
        {
            txVwDetail.text = productSales.detail;
            [cell addSubview:txVwDetail];
            
            if(![productSales.detail isEqualToString:@""])
            {
                swtDetail.on = NO;
            }
        }
        else if(indexPath.row == 2)
        {
            [self loadingOverlayView];
            NSString *imageFileName = productSales.imageDefault;
            if(![imageFileName isEqualToString:@""])
            {
                swtImage.on = NO;
                [imgVwProductImage setUserInteractionEnabled:NO];
                scrVwProductImage.minimumZoomScale = 1;
                scrVwProductImage.maximumZoomScale = 1;
                [_homeModel downloadImageWithFileName:imageFileName completionBlock:^(BOOL succeeded, UIImage *image) {
                    if (succeeded)
                    {
                        _booImageSelect = YES;
                        imgVwProductImage.image = image;
                        NSLog(@"download image successful");
                    }
                    else
                    {
                        NSLog(@"download image fail");
                    }
                }];
            }
            
            [self removeOverlayViews];
            [scrVwProductImage addSubview:imgVwProductImage];
            [cell addSubview:scrVwProductImage];
        }
    }
    else
    {
        //set blank
        if(indexPath.row == 0)
        {
            txtPrice.text = @"";
            [cell addSubview:txtPrice];
        }
        else if(indexPath.row == 1)
        {
            txVwDetail.text = @"";
            [cell addSubview:txVwDetail];
            
        }
        else if(indexPath.row == 2)
        {
            [cell addSubview:imgVwProductImage];
        }
    }
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return indexPath.row == 0?44:132; //132 price detail image
}

#pragma mark - Life Cycle method
- (void)loadView
{
    [super loadView];
    
    _homeModel = [[HomeModel alloc] init];
    _homeModel.delegate = self;
    
    {
        overlayView = [[UIView alloc] initWithFrame:imgVwProductImage.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        indicator.frame = CGRectMake(imgVwProductImage.frame.origin.x+imgVwProductImage.bounds.size.width/2-indicator.frame.size.width/2,64+44+132+imgVwProductImage.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);
    }
    
    
    _booImageSelect = NO;
    float controlWidth = self.tableView.bounds.size.width - 40*2 - 60;//minus left, right margin and switch
    float controlXOrigin = 15;
    float controlYOrigin = (44 - 25)/2;//table row height minus control height and set vertical center
    
    
    txtPrice = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, 25)];
    txtPrice.placeholder = @"Price";
    txtPrice.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtPrice.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
    [txtPrice setKeyboardType:UIKeyboardTypeDecimalPad];
    
    
    txVwDetail = [[CustomUITextView alloc] initWithFrame:CGRectMake(controlXOrigin-4, controlYOrigin, controlWidth, 25)];
    txVwDetail.placeholder = @" Detail";
    txVwDetail.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
    txVwDetail.font = txtPrice.font;
    
    
    scrVwProductImage = [[UIScrollView alloc]init];
    scrVwProductImage.frame = CGRectMake(controlXOrigin, controlYOrigin-10,132,132);
    scrVwProductImage.delegate = self;
    scrVwProductImage.minimumZoomScale = 0.2;
    scrVwProductImage.maximumZoomScale = 5;
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
    singleTap.numberOfTapsRequired = 1;
    imgVwProductImage =[[UIImageView alloc]init ];
    imgVwProductImage.image =[UIImage imageNamed:@"addImage.png"];
    imgVwProductImage.frame = CGRectMake(0,0,132,132);
    [imgVwProductImage setUserInteractionEnabled:YES];
    [imgVwProductImage addGestureRecognizer:singleTap];
    
    
    UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    NSInteger widthSwt = mySwitch.frame.size.width;
    NSInteger heightSwt = mySwitch.frame.size.height;
    
    float controlXOriginSwt = self.tableView.bounds.size.width-20-widthSwt;
    float controlYOriginSwt = (44 - 25)/2;//table row height minus control height and set vertical center
    
    
    CGRect framePrice = CGRectMake(controlXOriginSwt, controlYOriginSwt, widthSwt, heightSwt);
    swtPrice = [[UISwitch alloc] initWithFrame: framePrice];
    swtPrice.on = YES;
    [swtPrice setSelected:YES];
    [swtPrice setOnTintColor:tTheme];
    [self.view addSubview: swtPrice];
    [swtPrice addTarget:self action:@selector(switchTwisted:) forControlEvents:UIControlEventValueChanged];
    
    CGRect frameDetail = CGRectMake(controlXOriginSwt, controlYOriginSwt+44, widthSwt, heightSwt);
    swtDetail = [[UISwitch alloc] initWithFrame: frameDetail];
    swtDetail.on = YES;
    [swtDetail setSelected:YES];
    [swtDetail setOnTintColor:tTheme];
    [self.view addSubview: swtDetail];
    [swtDetail addTarget:self action:@selector(switchTwisted:) forControlEvents:UIControlEventValueChanged];
    
    CGRect frameImage = CGRectMake(controlXOriginSwt, controlYOriginSwt+44+132, widthSwt, heightSwt);
    swtImage = [[UISwitch alloc] initWithFrame: frameImage];
    swtImage.on = YES;
    [swtImage setOnTintColor:tTheme];
    [self.view addSubview: swtImage];
    [swtImage addTarget:self action:@selector(switchTwisted:) forControlEvents:UIControlEventValueChanged];
    [self loadViewProcess];
}

- (void)loadViewProcess
{
}

- (void)switchTwisted:(UISwitch *)twistedSwitch
{
    if(twistedSwitch == swtPrice)
    {
        if ([twistedSwitch isOn] && (![twistedSwitch isSelected]))
        {
            [twistedSwitch setSelected:YES];
            
            //Write code for SwitchON Action
            txtPrice.enabled = YES;
        }
        else if ((![twistedSwitch isOn]) && [twistedSwitch isSelected])
        {
            [twistedSwitch setSelected:NO];
            
            //Write code for SwitchOFF Action
            txtPrice.enabled = NO;
        }
    }
    else if(twistedSwitch == swtDetail)
    {
        if ([twistedSwitch isOn] && (![twistedSwitch isSelected]))
        {
            [twistedSwitch setSelected:YES];
            
            //Write code for SwitchON Action
            txVwDetail.editable = YES;
        }
        else if ((![twistedSwitch isOn]) && [twistedSwitch isSelected])
        {
            [twistedSwitch setSelected:NO];
            
            //Write code for SwitchOFF Action
            txVwDetail.editable = NO;
        }
    }
    else if(twistedSwitch == swtImage)
    {
        if ([twistedSwitch isOn] && (![twistedSwitch isSelected]))
        {
            [twistedSwitch setSelected:YES];
            
            //Write code for SwitchON Action
            [imgVwProductImage setUserInteractionEnabled:YES];
            scrVwProductImage.minimumZoomScale = 0.2;
            scrVwProductImage.maximumZoomScale = 5;
            
        }
        else if ((![twistedSwitch isOn]) && [twistedSwitch isSelected])
        {
            [twistedSwitch setSelected:NO];
            
            //Write code for SwitchOFF Action
            [imgVwProductImage setUserInteractionEnabled:NO];
            scrVwProductImage.minimumZoomScale = 1;
            scrVwProductImage.maximumZoomScale = 1;
        }
    }
    
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {

    return YES;
}

-(void)tapDetected:(UIGestureRecognizer *)gestureRecognizer
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
    
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    if(_booImageSelect)
    {
        [alert addAction:
         [UIAlertAction actionWithTitle:@"Delete photo"
                                  style:UIAlertActionStyleDestructive
                                handler:^(UIAlertAction *action) {
                                    _booImageSelect = NO;
                                    imgVwProductImage.image = [UIImage imageNamed:@"addImage.png"];
                                }]];
    }
    
    
    [alert addAction:
     [UIAlertAction actionWithTitle:@"Take a new photo"
                              style:UIAlertActionStyleDestructive
                            handler:^(UIAlertAction *action) {
                                [self takeNewPhotoFromCamera];
                            }]];
    
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
    
    
    
    ///////////////ipad
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        [alert setModalPresentationStyle:UIModalPresentationPopover];
        
        UIPopoverPresentationController *popPresenter = [alert
                                                         popoverPresentationController];
        popPresenter.sourceView = cell;
        popPresenter.sourceRect = cell.bounds;
        //        popPresenter.barButtonItem = _barButtonIpad;
    }
    ///////////////
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
 
    
    _booImageSelect = YES;
    float zoomScale = .5;
    UIImage *scaleImage = [self scaleProportionalToSize:CGSizeMake(132/zoomScale, 132/zoomScale) image:image];//132*132
    
    imgVwProductImage.image = scaleImage;
    imgVwProductImage.frame = CGRectMake(0, 0, imgVwProductImage.image.size.width, imgVwProductImage.image.size.height);

    CGFloat newContentOffsetX = (scrVwProductImage.contentSize.width*zoomScale - scrVwProductImage.frame.size.width) / 2;
    CGFloat newContentOffsetY = (scrVwProductImage.contentSize.height*zoomScale - scrVwProductImage.frame.size.height) / 2;
    scrVwProductImage.contentSize = imgVwProductImage.image.size;
    scrVwProductImage.zoomScale = zoomScale;
    scrVwProductImage.contentOffset = CGPointMake(newContentOffsetX/zoomScale, newContentOffsetY/zoomScale);

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
{
    [self.navigationController dismissViewControllerAnimated: YES completion: nil];
}
- (BOOL)validateData
{
    if([[txtPrice.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                       message:@"Please input promotion price"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    
    return YES;
    
}

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    // return which subview we want to zoom
    return imgVwProductImage;
}

- (ProductSales *)getProductSales:(NSInteger)productSalesID fromList:(NSMutableArray *)productSalesList
{
    for(ProductSales *item in productSalesList)
    {
        if(item.productSalesID == productSalesID)
        {
            return item;
        }
    }
    return nil;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([sender isEqual:btnDone])
    {
        edit = YES;
        NSMutableArray *productSalesUpdateList = [[NSMutableArray alloc]init];
        if([arrProductSalesID count] == 1) //price at last index
        {
            
            //save image to server
            NSString *imageFileName;
            if(swtImage.on && _booImageSelect)
            {
                //if image default(imagefilename) exist, use the old one, if not -> gen new filename
                NSString *imageRunningID = [NSString stringWithFormat:@"%06ld",(long)[Utility getNextImageRunningID]];
                imageFileName = [NSString stringWithFormat:@"IMG_%@",imageRunningID];
                
                
                //update db imagerunningid
                [_homeModel insertItems:dbImageRunningID withData:imageRunningID];
                float scale = 1.0f/scrVwProductImage.zoomScale;
                
                
                CGRect visibleRect;
                visibleRect.origin.x = scrVwProductImage.contentOffset.x * scale;
                visibleRect.origin.y = scrVwProductImage.contentOffset.y * scale;
                visibleRect.size.width = scrVwProductImage.bounds.size.width * scale;
                visibleRect.size.height = scrVwProductImage.bounds.size.height * scale;
                
                CGImageRef cr = CGImageCreateWithImageInRect([imgVwProductImage.image CGImage], visibleRect);
                UIImage* cropped = [[UIImage alloc] initWithCGImage:cr];
                CGImageRelease(cr);
                
                
                NSData *imgData = UIImageJPEGRepresentation(cropped,1);
//                test
//                NSData *imgData = UIImageJPEGRepresentation([UIImage imageNamed:@"webgreecegrey.jpg"], 1);
                [_homeModel uploadPhoto:imgData fileName:imageFileName];
            }
    
            ProductSales *selectedProductSales = arrProductSalesID[0];
            ProductSales *productSales = [self getProductSales:selectedProductSales.productSalesID fromList:productNameDetailList];
            productSales.price = swtPrice.on?[self getPrice]:productSales.price;
            productSales.detail = swtDetail.on?[Utility trimString:txVwDetail.text]:productSales.detail;
            productSales.pricePromotion = productSales.price;
            productSales.imageDefault = !swtImage.on?productSales.imageDefault:_booImageSelect?[NSString stringWithFormat:@"%@.jpg",imageFileName]:@"";//image filename
            
            
            if(swtPrice.on || swtDetail.on || swtImage.on)
            {
                //update sharedproductsales
                NSMutableArray *productSalesList = [SharedProductSales sharedProductSales].productSalesList;
                for(ProductSales *item in productSalesList)
                {
                    if(item.productSalesID == productSales.productSalesID)
                    {
                        item.price = productSales.price;
                        item.pricePromotion = productSales.price;
                        item.detail = productSales.detail;
                        item.imageDefault = productSales.imageDefault;
                        item.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                        item.modifiedUser = [Utility modifiedUser];
                        [productSalesUpdateList addObject:item];
                        break;
                    }
                }
                
                NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_productSalesID" ascending:YES];
                NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
                NSArray *sortArray = [productSalesUpdateList sortedArrayUsingDescriptors:sortDescriptors];
                [_homeModel updateItems:dbProductSalesUpdateDetail withData:sortArray];
            }
        }
        else
        {
            NSString *imageFileName = @"";
            if(swtImage.on && _booImageSelect)
            {
                //save image to server
                NSString *imageRunningID = [NSString stringWithFormat:@"%06ld",(long)[Utility getNextImageRunningID]];
                imageFileName = [NSString stringWithFormat:@"IMG_%@",imageRunningID];
                //update db imagerunningid
                [_homeModel insertItems:dbImageRunningID withData:imageRunningID];
                
                
                UIImage *scaleImage = [self scaleProportionalToSize:CGSizeMake(320, 320) image:imgVwProductImage.image];
                NSData *imgData = UIImageJPEGRepresentation(scaleImage,1);
                [_homeModel uploadPhoto:imgData fileName:imageFileName];
            }
            
            
            if(swtPrice.on || swtDetail.on || swtImage.on)
            {
//                for(NSString *strProductSalesID in arrProductSalesID)
                for(ProductSales *item in arrProductSalesID)
                {
                    ProductSales *productSales = [self getProductSales:item.productSalesID fromList:productNameDetailList];
                    productSales.price = swtPrice.on?[self getPrice]:productSales.price;
                    productSales.detail = swtDetail.on?[Utility trimString:txVwDetail.text]:productSales.detail;
                    productSales.pricePromotion = productSales.price;
                    productSales.imageDefault = !swtImage.on?productSales.imageDefault:_booImageSelect?[NSString stringWithFormat:@"%@.jpg",imageFileName]:@"";//image filename
                    [productSalesUpdateList addObject:productSales];
                    
                    
                    
                    //update sharedproductsales
                    NSMutableArray *productSalesList = [SharedProductSales sharedProductSales].productSalesList;
                    for(ProductSales *item in productSalesList)
                    {
                        if(item.productSalesID == productSales.productSalesID)
                        {
                            item.price = productSales.price;
                            item.pricePromotion = productSales.price;
                            item.detail = productSales.detail;
                            item.imageDefault = productSales.imageDefault;
                            item.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                            item.modifiedUser = [Utility modifiedUser];
                            break;
                        }
                    }
                }
                
                NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_productSalesID" ascending:YES];
                NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
                NSArray *sortArray = [productSalesUpdateList sortedArrayUsingDescriptors:sortDescriptors];
                
                
                float itemsPerConnection = [Utility getNumberOfRowForExecuteSql]+0.0;
                float countUpdate = ceil([sortArray count]/itemsPerConnection);
                for(int i=0; i<countUpdate; i++)
                {
                    NSInteger startIndex = i * itemsPerConnection;
                    NSInteger count = MIN([sortArray count] - startIndex, itemsPerConnection );
                    NSArray *subArray = [sortArray subarrayWithRange: NSMakeRange( startIndex, count )];
                    
                    [_homeModel updateItems:dbProductSalesUpdateDetail withData:subArray];
                }
            }
        }
    }
}
- (NSString *)getPrice
{
    txtPrice.text = [Utility trimString:txtPrice.text];
    if([txtPrice.text isEqualToString:@""])
    {
        return @"0";
    }
    else
    {
        return txtPrice.text;
    }
}
- (UIImage *) scaleToSize: (CGSize)size image:(UIImage *)lImage
{
    // Scalling selected image to targeted size
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextClearRect(context, CGRectMake(0, 0, size.width, size.height));
    
    if(lImage.imageOrientation == UIImageOrientationRight)
    {
        CGContextRotateCTM(context, -M_PI_2);
        CGContextTranslateCTM(context, -size.height, 0.0f);
        CGContextDrawImage(context, CGRectMake(0, 0, size.height, size.width), lImage.CGImage);
    }
    else
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), lImage.CGImage);
    
    CGImageRef scaledImage=CGBitmapContextCreateImage(context);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    UIImage *image = [UIImage imageWithCGImage: scaledImage];
    
    CGImageRelease(scaledImage);
    
    return image;
}

- (UIImage *) scaleProportionalToSize: (CGSize)size1 image:(UIImage *)image
{
    if(image.size.width>image.size.height)
    {
        NSLog(@"LandScape");
        size1=CGSizeMake((image.size.width/image.size.height)*size1.height,size1.height);
    }
    else
    {
        NSLog(@"Potrait");
        size1=CGSizeMake(size1.width,(image.size.height/image.size.width)*size1.width);
    }
    
    return [self scaleToSize:size1 image:image];
}
- (void)itemsInserted
{
    
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
