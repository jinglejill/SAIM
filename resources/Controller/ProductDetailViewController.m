//
//  ProductDetailViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 8/13/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "ProductDetailViewController.h"
#import "Utility.h"
#import "ProductDetail.h"
#import "SharedProduct.h"
#import "ProductSales.h"
#import "SharedSelectedEvent.h"
#import <QuartzCore/QuartzCore.h>
#import "SharedProductBuy.h"
#import "SalesCustomMadeAddCustomMadeViewController.h"
#import "SalesScanAddScanViewController.h"
#import "PreOrderAddPreOrderViewController.h"
#import "PreOrderAddPreOrder2ViewController.h"
#import "SharedProductDetail.h"
#import "SharedProductSales.h"
#import "ProductName.h"
#import "SharedProductName.h"
#import "SharedReplaceReceiptProductItem.h"

@interface ProductDetailViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSMutableArray *_productBuyList;
    NSArray *_productDetailList;
    NSArray *_productSalesList;
    Event *_event;
}
@end

@implementation ProductDetailViewController
@synthesize product;
@synthesize imvProduct;
@synthesize lblModel;
@synthesize lblColor;
@synthesize lblSize;
@synthesize lblPrice;
@synthesize lblPromotionPrice;
@synthesize txvDetail;
@synthesize customMade;
@synthesize productType;
@synthesize btnViewReceipt;
@synthesize btnDelete;
@synthesize productIDGroup;

-(void)clearProductDetail
{
    imvProduct.image = nil;
    lblModel.text = [NSString stringWithFormat:@"Model"];
    lblColor.text = [NSString stringWithFormat:@"Color"];
    lblSize.text = [NSString stringWithFormat:@"Size"];
    lblPrice.text = [NSString stringWithFormat:@"Price"];
    lblPromotionPrice.text = [NSString stringWithFormat:@"Price offer"];
    txvDetail.text = [NSString stringWithFormat:@""];
}

- (IBAction)unwindToProductDetail:(UIStoryboardSegue *)segue
{
    if([[segue sourceViewController] isMemberOfClass:[SalesCustomMadeAddCustomMadeViewController class]])
    {
        SalesCustomMadeAddCustomMadeViewController *source = [segue sourceViewController];
        customMade = source.customMade;
        
        if(customMade)
        {
            //clear data before set new
            [self clearProductDetail];
            
            
            productType = productCustomMade;
            [self setData];
        }
        else//press back button
        {
            //stay the same as before add more product
        }
    }
    else if([[segue sourceViewController] isMemberOfClass:[SalesScanAddScanViewController class]])
    {
        self.navigationController.toolbarHidden = YES;
        SalesScanAddScanViewController *source = [segue sourceViewController];
        product = source.product;
        
        if(product)
        {
            //clear data before set new
            [self clearProductDetail];
            
            
            productType = productInventory;
            [self setData];
        }
        else//press back button
        {
            //stay the same as before add more product
        }
    }
    else if([[segue sourceViewController] isMemberOfClass:[PreOrderAddPreOrderViewController class]])
    {
        self.navigationController.toolbarHidden = YES;
        PreOrderAddPreOrderViewController *source = [segue sourceViewController];
        product = source.product;
        
        if(product)
        {
            //clear data before set new
            [self clearProductDetail];
            
            
            productType = productPreOrder;
            [self setData];
        }
        else//press back button
        {
            //stay the same as before add more product
        }
    }
    else if([[segue sourceViewController] isMemberOfClass:[PreOrderAddPreOrder2ViewController class]])
    {
        self.navigationController.toolbarHidden = YES;
        PreOrderAddPreOrder2ViewController *source = [segue sourceViewController];
        productIDGroup = source.productIDGroup;


        if(![Utility isStringEmpty:productIDGroup])
        {
            //clear data before set new
            [self clearProductDetail];
            
            
            productType = productPreOrder2;
            [self setData];
        }
        else//press back button
        {
            //stay the same as before add more product
        }
    }
}


- (void)loadView
{
    [super loadView];
    
    _homeModel = [[HomeModel alloc] init];
    _homeModel.delegate = self;
    
    {
        overlayView = [[UIView alloc] initWithFrame:imvProduct.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.frame = CGRectMake(imvProduct.frame.origin.x+imvProduct.bounds.size.width/2-indicator.frame.size.width/2,imvProduct.frame.origin.y+imvProduct.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);
    }
    
    
    self.navigationController.toolbarHidden = YES;
    btnViewReceipt.enabled = NO;
    btnDelete.enabled = NO;
    _event = [Event getSelectedEvent];
    [self clearProductDetail];
    
    
    if([SharedReplaceReceiptProductItem sharedReplaceReceiptProductItem].replaceReceiptProductItem.receiptProductItemID == 0)
    {
        [self setData];
    }
}

-(void)setData
{
    if(productType == productInventory || productType == productPreOrder)
    {
        NSString *productNameGroup = [NSString stringWithFormat:@"%@%@%@",product.productCategory2,product.productCategory1,product.productName];
        ProductName *productName = [ProductName getProductNameWithProductNameGroup:productNameGroup];
        
        
        //ราคาขายตาม event, ส่วน รูปและdetail ตาม event = 0
        //productsalessetid = event.productsalessetid
        ProductSales *productSalesEvent = [Utility getProductSales:productName.productNameID color:product.color size:product.size  productSalesSetID:_event.productSalesSetID];
        NSString *pricePromotion = productSalesEvent.pricePromotion;
        
        
        
        //productsalessetid = 0
        ProductSales *productSales = [Utility getProductSales:productName.productNameID color:product.color size:product.size  productSalesSetID:@"0"];
     
        
        ProductDetail *productDetail = [[ProductDetail alloc]init];
        productDetail.productID = product.productID;
        productDetail.productName = productName.name;
        productDetail.color = [Utility getColorName:product.color];
        productDetail.size = product.size;
        productDetail.price = productSales.price;
        productDetail.pricePromotion = pricePromotion;
        productDetail.detail = productSales.detail;
        productDetail.imageDefault = productSales.imageDefault;
        productDetail.status = product.status;
        productDetail.productIDGroup = [Utility getProductIDGroup:product];
        productDetail.productNameID = productName.productNameID;
        productDetail.manufacturingDate = product.manufacturingDate;
        
  
        
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        
        NSString *price = [formatter stringFromNumber:[NSNumber numberWithFloat:[productDetail.price floatValue]]];
        NSString *strPricePromotion = [formatter stringFromNumber:[NSNumber numberWithFloat:[productDetail.pricePromotion floatValue]]];
        price = [NSString stringWithFormat:@"%@ baht",price];
        strPricePromotion = [NSString stringWithFormat:@"%@ baht",strPricePromotion];


        
        btnDelete.enabled = YES;
        btnViewReceipt.enabled = YES;

        
        
        //download product image
        [self loadingOverlayView];
        NSString *imageFileName = productSales.imageDefault;
        [_homeModel downloadImageWithFileName:imageFileName completionBlock:^(BOOL succeeded, UIImage *image) {
            if (succeeded) {
                imvProduct.image = image;
                [self removeOverlayViews];
                NSLog(@"download image successful");
            }else
            {
                NSLog(@"download image fail");
                [self removeOverlayViews];
            }
        }];
        lblModel.attributedText = [self getTextFormatHeader:@"Model: " detail:productDetail.productName];
        lblColor.attributedText = [self getTextFormatHeader:@"Color: " detail:productDetail.color];
        lblSize.attributedText = [self getTextFormatHeader:@"Size: " detail:[Utility getSizeLabel:productDetail.size]];
        lblPrice.attributedText = [self getTextFormatHeader:@"Price: " detail:price];
        lblPromotionPrice.attributedText = [self getTextFormatHeader:@"Price offer: " detail:strPricePromotion];
        txvDetail.attributedText = [self getTextFormatHeader:@"Detail: \r\n" detail:productDetail.detail];
        
        
        
        //                enum enumProductBuy{productType,productDetail,image,price,pricePromotion};
        _productBuyList = [SharedProductBuy sharedProductBuy].productBuyList;
        if(productType == productPreOrder)
        {
            [_productBuyList addObject:[NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"%d",productPreOrder], productDetail,imageFileName,price,productDetail.pricePromotion,[NSNull null],nil]];
        }
        else
        {
            [_productBuyList addObject:[NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"%d",productInventory], productDetail,imageFileName,price,productDetail.pricePromotion,[NSNull null],nil]];
        }
    }
    else if(productType == productPreOrder2)
    {
        NSRange needleRange = NSMakeRange(0,6);
        NSString *productNameGroup = [productIDGroup substringWithRange:needleRange];
        
        needleRange = NSMakeRange(6,2);
        NSString *strColor = [productIDGroup substringWithRange:needleRange];
        
        needleRange = NSMakeRange(8,2);
        NSString *strSize = [productIDGroup substringWithRange:needleRange];
        
        ProductName *productName = [ProductName getProductNameWithProductNameGroup:productNameGroup];
        
        
        //ราคาขายตาม event, ส่วน รูปและdetail ตาม event = 0
        //productsalessetid = event.productsalessetid
        
        ProductSales *productSalesEvent = [Utility getProductSales:productName.productNameID color:strColor size:strSize  productSalesSetID:_event.productSalesSetID];
        NSString *pricePromotion = productSalesEvent.pricePromotion;
        
        
        ProductSales *productSales = [Utility getProductSales:productName.productNameID color:strColor size:strSize  productSalesSetID:@"0"];
        
        
        ProductDetail *productDetail = [[ProductDetail alloc]init];
//        productDetail.productID = product.productID;
        productDetail.productName = productName.name;
        productDetail.color = [Utility getColorName:strColor];
        productDetail.size = strSize;
        productDetail.price = productSales.price;
        productDetail.pricePromotion = pricePromotion;
        productDetail.detail = productSales.detail;
        productDetail.imageDefault = productSales.imageDefault;
//        productDetail.status = product.status;
        productDetail.productIDGroup = productIDGroup;//[Utility getProductIDGroup:product];
//        productDetail.manufacturingDate = product.manufacturingDate;
        
  
        
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        
        NSString *price = [formatter stringFromNumber:[NSNumber numberWithFloat:[productDetail.price floatValue]]];
        NSString *strPricePromotion = [formatter stringFromNumber:[NSNumber numberWithFloat:[productDetail.pricePromotion floatValue]]];
        price = [NSString stringWithFormat:@"%@ baht",price];
        strPricePromotion = [NSString stringWithFormat:@"%@ baht",strPricePromotion];


        
        btnDelete.enabled = YES;
        btnViewReceipt.enabled = YES;

        
        
        //download product image
        [self loadingOverlayView];
        NSString *imageFileName = productSales.imageDefault;
        [_homeModel downloadImageWithFileName:imageFileName completionBlock:^(BOOL succeeded, UIImage *image) {
            if (succeeded) {
                imvProduct.image = image;
                [self removeOverlayViews];
                NSLog(@"download image successful");
            }else
            {
                NSLog(@"download image fail");
                [self removeOverlayViews];
            }
        }];
        lblModel.attributedText = [self getTextFormatHeader:@"Model: " detail:productDetail.productName];
        lblColor.attributedText = [self getTextFormatHeader:@"Color: " detail:productDetail.color];
        lblSize.attributedText = [self getTextFormatHeader:@"Size: " detail:[Utility getSizeLabel:productDetail.size]];
        lblPrice.attributedText = [self getTextFormatHeader:@"Price: " detail:price];
        lblPromotionPrice.attributedText = [self getTextFormatHeader:@"Price offer: " detail:strPricePromotion];
        txvDetail.attributedText = [self getTextFormatHeader:@"Detail: \r\n" detail:productDetail.detail];
        
        
        
        //                enum enumProductBuy{productType,productDetail,image,price,pricePromotion};
        _productBuyList = [SharedProductBuy sharedProductBuy].productBuyList;
        [_productBuyList addObject:[NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"%d",productPreOrder2], productDetail,imageFileName,price,productDetail.pricePromotion,productIDGroup,nil]];
    }
    else if(productType == productCustomMade)
    {
        _productSalesList = [SharedProductSales sharedProductSales].productSalesList;
        for(ProductSales *item in _productSalesList)
        {
            ProductName *productName = [ProductName getProductName:item.productNameID];
            item.productCategory2 = productName.productCategory2;
            item.productCategory1 = productName.productCategory1;
            item.productName = productName.code;
        }
        
        NSString *pricePromotion;
        //productsalessetid = event.productsalessetid
        {
            NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productSalesSetID = %@ and _productCategory2 = %@ and _productCategory1 = %@ and _productName = %@",_event.productSalesSetID,customMade.productCategory2,customMade.productCategory1,@"00"];
            
            NSArray *productSalesCustomMadeFilter = [_productSalesList filteredArrayUsingPredicate:predicate1];
            ProductSales *productSalesEvent = productSalesCustomMadeFilter[0];
            pricePromotion = productSalesEvent.pricePromotion;
        }
        
        
        ProductSales *productSales;
        //productsalessetid = 0
        {
            NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productSalesSetID = %@ and _productCategory2 = %@ and _productCategory1 = %@ and _productName = %@",@"0",customMade.productCategory2,customMade.productCategory1,@"00"];
            
            NSArray *productSalesCustomMadeFilter = [_productSalesList filteredArrayUsingPredicate:predicate1];
            productSales  = productSalesCustomMadeFilter[0];
        }
        
        
        
        NSString *productNameGroup = [NSString stringWithFormat:@"%@%@%@",productSales.productCategory2,productSales.productCategory1,productSales.productName];
        NSString *strProductName = [ProductName getNameWithProductNameGroup:productNameGroup];
        
        
        
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        
        NSString *price = [formatter stringFromNumber:[NSNumber numberWithFloat:[productSales.price floatValue]]];
        NSString *strPricePromotion = [formatter stringFromNumber:[NSNumber numberWithFloat:[pricePromotion floatValue]]];
        price = [NSString stringWithFormat:@"%@ baht",price];
        strPricePromotion = [NSString stringWithFormat:@"%@ baht",strPricePromotion];
        
        
        
        //custom made detail
        NSString *customMadeDetail = [NSString stringWithFormat:@"Size: %@\r\nToe: %@\r\nBody: %@\r\nAccessory: %@\r\nRemark: %@",customMade.size,customMade.toe,customMade.body,customMade.accessory,customMade.remark];
        
//        customMade.productName = strProductName;
        
        

        btnDelete.enabled = YES;
        btnViewReceipt.enabled = YES;
        
        
        
        //download product image
        [self loadingOverlayView];
        NSString *imageFileName = productSales.imageDefault;
        [_homeModel downloadImageWithFileName:imageFileName completionBlock:^(BOOL succeeded, UIImage *image) {
            if (succeeded) {
                imvProduct.image = image;
                [self removeOverlayViews];
                NSLog(@"download image successful");
            }else
            {
                NSLog(@"download image fail");
                [self removeOverlayViews];
            }
        }];
        
        
        
        lblModel.attributedText = [self getTextFormatHeader:@"Model: " detail:strProductName];
        lblColor.attributedText = [self getTextFormatHeader:@"Color: " detail:@"-"];
        lblSize.attributedText = [self getTextFormatHeader:@"Size: " detail:@"-"];
        lblPrice.attributedText = [self getTextFormatHeader:@"Price: " detail:price];
        lblPromotionPrice.attributedText = [self getTextFormatHeader:@"Price offer: " detail:strPricePromotion];
        txvDetail.attributedText = [self getTextFormatHeader:@"Detail: \r\n" detail:customMadeDetail];
        
        
        
        //                enum enumProductBuy{productType,productDetail,image,price,pricePromotion};
        _productBuyList = [SharedProductBuy sharedProductBuy].productBuyList;
        [_productBuyList addObject:[NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"%d",productCustomMade], customMade,imageFileName,price,pricePromotion,[NSNull null],nil]];
    }
}

-(NSMutableAttributedString *)getTextFormatHeader:(NSString *)header detail:(NSString *)detail
{
    UIFont *font1 = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    NSDictionary *arialDict = [NSDictionary dictionaryWithObject: font1 forKey:NSFontAttributeName];
    NSMutableAttributedString *aAttrString1 = [[NSMutableAttributedString alloc] initWithString:header attributes: arialDict];
    
    UIFont *font2 = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
    NSDictionary *arialDict2 = [NSDictionary dictionaryWithObject: font2 forKey:NSFontAttributeName];
    NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:detail attributes: arialDict2];
    [aAttrString1 appendAttributedString:aAttrString2];
    return aAttrString1;
}
-(UIImage*)resizeImage:(UIImage *)image imageSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    //here is the scaled image which has been changed to the size specified
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
}

- (IBAction)deleteProductBuy:(id)sender {
    btnDelete.enabled = NO;
    [_productBuyList removeLastObject];
    btnViewReceipt.enabled = [_productBuyList count] > 0;

    
    //clear detail
    [self clearProductDetail];
    
    //disable view receipt button
    
}

- (IBAction)addScan:(id)sender {
    [self performSegueWithIdentifier:@"segAddScan" sender:self];
}

- (IBAction)addCustomMade:(id)sender {
    [self performSegueWithIdentifier:@"segAddCustomMade" sender:self];
}

- (IBAction)addPreOrder:(id)sender {
    [self performSegueWithIdentifier:@"segAddPreOrderPage" sender:self];
}

- (IBAction)addPreOrder2:(id)sender {
    [self performSegueWithIdentifier:@"segAddPreOrderPage2" sender:self];
}

- (IBAction)viewReceipt:(id)sender {
    [self performSegueWithIdentifier:@"segReceipt2" sender:self];
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
