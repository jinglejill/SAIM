//
//  ProductLocationAndStatusViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/9/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "ProductLocationAndStatusViewController.h"
#import "ProductSales.h"
#import "Utility.h"
#import "ProductDetail.h"
#import "Event.h"
#import "Receipt.h"
#import "SharedReceiptItem.h"
#import "SharedReceipt.h"
#import "ReceiptProductItem.h"
#import "SharedProduct.h"
#import "ProductStatusSummary.h"
#import "CustomUICollectionViewCellButton2.h"
#import "ProductStatusDetailViewController.h"
#import "ProductName.h"


#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]


@interface ProductLocationAndStatusViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSMutableArray *_productStatusSummaryListSort;
    NSMutableArray *_productStatusItemList;
    NSMutableArray *_selectedProductDetailList;
}

@end

@implementation ProductLocationAndStatusViewController
static NSString * const reuseIdentifier = @"Cell";
@synthesize imvProduct;
@synthesize lblModel;
@synthesize lblColor;
@synthesize lblSize;
@synthesize lblManufacturingDate;
@synthesize lblPrice;
@synthesize txvDetail;
@synthesize product;
@synthesize colVwData;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register cell classes
    [colVwData registerClass:[CustomUICollectionViewCellButton2 class] forCellWithReuseIdentifier:reuseIdentifier];
    colVwData.delegate = self;
    colVwData.dataSource = self;
    

    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
}

- (void)loadView
{
    [super loadView];
    
    _homeModel = [[HomeModel alloc] init];
    _homeModel.delegate = self;
    
    
    {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);
    }
    
    
    self.automaticallyAdjustsScrollViewInsets = NO; // Avoid the top UITextView space, iOS7 (~bug?)
    _productStatusItemList = [[NSMutableArray alloc]init];
    _selectedProductDetailList = [[NSMutableArray alloc]init];
    
    
    [self loadViewProcess];
}

- (void)loadViewProcess
{
    //get sold data from db
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        //get sold data
        Product *productLoadMore = [product copy];
        productLoadMore.status = @"S";
        [_homeModel downloadItems:dbProductStatus condition:productLoadMore];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            [self loadingOverlayView];
            [self setData];
        });
    });
}

- (void)itemsDownloaded:(NSArray *)items
{
    [self removeOverlayViews];
    int i=0;
    [[SharedProduct sharedProduct].productList addObjectsFromArray:items[i++]];
    [[SharedReceipt sharedReceipt].receiptList addObjectsFromArray:items[i++]];
    [[SharedReceiptItem sharedReceiptItem].receiptItemList addObjectsFromArray:items[i++]];
    [self setData];
}

-(void)setData
{
    NSString *productNameGroup = [NSString stringWithFormat:@"%@%@%@",product.productCategory2,product.productCategory1,product.productName];
    ProductName *productName = [ProductName getProductNameWithProductNameGroup:productNameGroup];
    
    
    //productsalessetid = 0
    ProductSales *productSales = [Utility getProductSales:productName.productNameID color:product.color size:product.size  productSalesSetID:@"0"];
    
    
    
    ProductDetail *productDetail = [[ProductDetail alloc]init];
    productDetail.productName = productName.name;
    productDetail.color = [Utility getColorName:product.color];
    productDetail.size = [Utility getSizeLabel:product.size];
    productDetail.price = productSales.price;
    productDetail.detail = productSales.detail;
    productDetail.imageDefault = productSales.imageDefault;
    productDetail.manufacturingDate = product.manufacturingDate;
    
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSString *strFmtPrice = [formatter stringFromNumber:[NSNumber numberWithFloat:[productDetail.price floatValue]]];
    strFmtPrice = [NSString stringWithFormat:@"%@ baht",strFmtPrice];
    NSString *strManufacturingDate = [Utility formatDate:productDetail.manufacturingDate fromFormat:@"yyyy-MM-dd" toFormat:@"dd/MM/yyyy"];
    
    
    //download product image
//    [self loadingOverlayView];
    NSString *imageFileName = productSales.imageDefault;
    [_homeModel downloadImageWithFileName:imageFileName completionBlock:^(BOOL succeeded, UIImage *image) {
        if (succeeded) {
            imvProduct.image = image;
            NSLog(@"download image successful");
        }
        else
        {
            NSLog(@"download image fail");
        }
    }];
    
    
    lblModel.attributedText = [self getTextFormatHeader:@"Model: " detail:productDetail.productName];
    lblColor.attributedText = [self getTextFormatHeader:@"Color: " detail:productDetail.color];
    lblSize.attributedText = [self getTextFormatHeader:@"Size: " detail:productDetail.size];
    lblManufacturingDate.attributedText = [self getTextFormatHeader:@"MFD: " detail:strManufacturingDate];
    lblPrice.attributedText = [self getTextFormatHeader:@"Price: " detail:strFmtPrice];
    txvDetail.attributedText = [self getTextFormatHeader:@"Detail: \r\n" detail:productDetail.detail];
    [txvDetail scrollRangeToVisible:NSMakeRange(0, 0)];
    
    
    ///------------
    NSMutableArray *productStatusSummaryList = [[NSMutableArray alloc]init];
    NSMutableArray *productList = [SharedProduct sharedProduct].productList;
    
    {
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ and _productCategory1 = %@ and _productName = %@ and _color = %@ and _size = %@ and _eventID = %ld and _status = %@",product.productCategory2,product.productCategory1,product.productName,product.color,product.size,0,@"I"];
        NSArray *filterArray = [productList filteredArrayUsingPredicate:predicate1];
        ProductStatusSummary *productStatusSummary = [[ProductStatusSummary alloc]init];
        productStatusSummary.eventID = 0;
        productStatusSummary.status = @"I";
        productStatusSummary.amount = [filterArray count];
        [productStatusSummaryList addObject:productStatusSummary];
        for(Product *item in filterArray)
        {
            ProductDetail *productDetail = [[ProductDetail alloc]init];
            productDetail.productID = item.productID;
            productDetail.status = @"I";
            productDetail.eventID = 0;
            productDetail.manufacturingDate = item.manufacturingDate;
            [_productStatusItemList addObject:productDetail];
        }
    }
    {
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ and _productCategory1 = %@ and _productName = %@ and _color = %@ and _size = %@ and _eventID != %ld and _status = %@",product.productCategory2,product.productCategory1,product.productName,product.color,product.size,0,@"I"];
        NSArray *filterArray = [productList filteredArrayUsingPredicate:predicate1];
        NSSet *uniqueEventID = [NSSet setWithArray:[filterArray valueForKey:@"eventID"]];
        for(NSString *strEventID in uniqueEventID)
        {
            NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ and _productCategory1 = %@ and _productName = %@ and _color = %@ and _size = %@ and _eventID = %ld and _status = %@",product.productCategory2,product.productCategory1,product.productName,product.color,product.size,[strEventID integerValue],@"I"];
            NSArray *filterArray = [productList filteredArrayUsingPredicate:predicate1];
            ProductStatusSummary *productStatusSummary = [[ProductStatusSummary alloc]init];
            productStatusSummary.eventID = [strEventID integerValue];
            productStatusSummary.status = @"I";
            productStatusSummary.amount = [filterArray count];
            [productStatusSummaryList addObject:productStatusSummary];
            
            for(Product *item in filterArray)
            {
                ProductDetail *productDetail = [[ProductDetail alloc]init];
                productDetail.productID = item.productID;
                productDetail.status = @"I";
                productDetail.eventID = [strEventID integerValue];
                productDetail.manufacturingDate = item.manufacturingDate;
                productDetail.pricePromotion = [Utility getPricePromotion:item eventID:[strEventID integerValue]];
                [_productStatusItemList addObject:productDetail];
            }
        }
    }
    {
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ and _productCategory1 = %@ and _productName = %@ and _color = %@ and _size = %@ and _eventID = %ld and _status = %@",product.productCategory2,product.productCategory1,product.productName,product.color,product.size,0,@"P"];
        NSArray *filterArray = [productList filteredArrayUsingPredicate:predicate1];
        
        
        for(Product *item in filterArray)
        {
            ReceiptProductItem *receiptProductItem = [Utility getReceiptProductItemFromProductID:item.productID productType:@"P"];
            Receipt *receipt = [Utility getReceipt:receiptProductItem.receiptID];
            item.eventIDSpare = [receipt.eventID integerValue];
        }
        
        NSSet *uniqueEventID = [NSSet setWithArray:[filterArray valueForKey:@"eventIDSpare"]];
        for(NSString *strEventID in uniqueEventID)
        {
            NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_eventIDSpare = %ld",[strEventID integerValue]];
            NSArray *productByEventList = [filterArray filteredArrayUsingPredicate:predicate1];
            ProductStatusSummary *productStatusSummary = [[ProductStatusSummary alloc]init];
            productStatusSummary.eventID = [strEventID integerValue];
            productStatusSummary.status = @"P";
            productStatusSummary.amount = [productByEventList count];
            [productStatusSummaryList addObject:productStatusSummary];
            
            for(Product *item in productByEventList)
            {
                ReceiptProductItem *receiptProductItem = [ReceiptProductItem getReceiptProductItem:item.productID productType:@"P"];
                Receipt *receipt = [Utility getReceipt:receiptProductItem.receiptID];
                ProductDetail *productDetail = [[ProductDetail alloc]init];
                productDetail.productID = item.productID;
                productDetail.status = @"P";
                productDetail.eventID = [strEventID integerValue];
                productDetail.manufacturingDate = item.manufacturingDate;
                productDetail.pricePromotion = [Utility getPricePromotion:item eventID:[strEventID integerValue]];
                productDetail.receiptNo = [NSString stringWithFormat:@"R%06ld",receipt.receiptID];
                productDetail.priceSold = receiptProductItem.priceSales;
                productDetail.receiptDate = receipt.receiptDate;
                [_productStatusItemList addObject:productDetail];
            }
        }
    }
    {
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ and _productCategory1 = %@ and _productName = %@ and _color = %@ and _size = %@ and _status = %@",product.productCategory2,product.productCategory1,product.productName,product.color,product.size,@"S"];
        NSArray *filterArray = [productList filteredArrayUsingPredicate:predicate1];
        
        for(Product *item in filterArray)
        {
            if(item.eventID != 0)
            {
                item.eventIDSpare = item.eventID;
            }
            else
            {
                ReceiptProductItem *receiptProductItem = [Utility getReceiptProductItemFromProductID:item.productID productType:@"S"];
                Receipt *receipt = [Utility getReceipt:receiptProductItem.receiptID];
                item.eventIDSpare = [receipt.eventID integerValue];
            }
        }
        NSSet *uniqueEventID = [NSSet setWithArray:[filterArray valueForKey:@"eventIDSpare"]];
        for(NSString *strEventID in uniqueEventID)
        {
            NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_eventIDSpare = %ld",[strEventID integerValue]];
            NSArray *productByEventList = [filterArray filteredArrayUsingPredicate:predicate1];
            ProductStatusSummary *productStatusSummary = [[ProductStatusSummary alloc]init];
            productStatusSummary.eventID = [strEventID integerValue];
            productStatusSummary.status = @"S";
            productStatusSummary.amount = [productByEventList count];
            [productStatusSummaryList addObject:productStatusSummary];
            
            for(Product *item in productByEventList)
            {
                ReceiptProductItem *receiptProductItem = [ReceiptProductItem getReceiptProductItem:item.productID productType:@"S"];
                Receipt *receipt = [Utility getReceipt:receiptProductItem.receiptID];
                ProductDetail *productDetail = [[ProductDetail alloc]init];
                productDetail.productID = item.productID;
                productDetail.status = @"S";
                productDetail.eventID = [strEventID integerValue];
                productDetail.manufacturingDate = item.manufacturingDate;
                productDetail.pricePromotion = [Utility getPricePromotion:item eventID:[strEventID integerValue]];
                productDetail.receiptNo = [NSString stringWithFormat:@"R%06ld",receipt.receiptID];
                productDetail.priceSold = receiptProductItem.priceSales;
                productDetail.receiptDate = receipt.receiptDate;
                [_productStatusItemList addObject:productDetail];
            }
        }
    }
    
    for(ProductStatusSummary *item in productStatusSummaryList)
    {
        Event *event = [Utility getEvent:item.eventID];
        item.location = event.location;
        item.periodTo = event.periodTo;
    }
    
    _productStatusSummaryListSort = [[NSMutableArray alloc]init];
    {
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_eventID = %ld",0];
        NSArray *filterArray = [productStatusSummaryList filteredArrayUsingPredicate:predicate1];
        [_productStatusSummaryListSort addObjectsFromArray:filterArray];
    }
    
    {
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_eventID != %ld",0];
        NSArray *filterArray = [productStatusSummaryList filteredArrayUsingPredicate:predicate1];
        
        
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_periodTo" ascending:NO];
        NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_location" ascending:YES];
        NSSortDescriptor *sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:@"_status" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2,sortDescriptor3, nil];
        NSArray *sortArray = [filterArray sortedArrayUsingDescriptors:sortDescriptors];
        [_productStatusSummaryListSort addObjectsFromArray:sortArray];
    }
    
    NSInteger i = 0;
    for(ProductStatusSummary *item in _productStatusSummaryListSort)
    {
        item.row = [NSString stringWithFormat:@"%ld",++i];
    }
    
    //reload table
    [colVwData reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger rowNo;
    rowNo = [_productStatusSummaryListSort count];
    
    NSInteger countColumn = 5;
    return (rowNo+1)*countColumn;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CustomUICollectionViewCellButton2 *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if ([cell.label isDescendantOfView:cell]) {
        [cell.label removeFromSuperview];
    }
    if ([cell.buttonDetail isDescendantOfView:cell]) {
        [cell.buttonDetail removeFromSuperview];
    }
    if ([cell.imageView isDescendantOfView:cell]) {
        [cell.imageView removeFromSuperview];
    }
    if ([cell.leftBorder isDescendantOfView:cell]) {
        [cell.leftBorder removeFromSuperview];
        [cell.topBorder removeFromSuperview];
        [cell.rightBorder removeFromSuperview];
        [cell.bottomBorder removeFromSuperview];
    }
    
    //cell border
    {
        cell.leftBorder.frame = CGRectMake(cell.bounds.origin.x
                                           , cell.bounds.origin.y, 1, cell.bounds.size.height);
        cell.topBorder.frame = CGRectMake(cell.bounds.origin.x
                                          , cell.bounds.origin.y, cell.bounds.size.width, 1);
        cell.rightBorder.frame = CGRectMake(cell.bounds.origin.x+cell.bounds.size.width
                                            , cell.bounds.origin.y, 1, cell.bounds.size.height);
        cell.bottomBorder.frame = CGRectMake(cell.bounds.origin.x
                                             , cell.bounds.origin.y+cell.bounds.size.height, cell.bounds.size.width, 1);
    }
    
    NSInteger item = indexPath.item;
    
    NSArray *header = @[@"No",@"Date",@"Location",@"Status",@"Total"];
    NSInteger countColumn = [header count];
    
    if(item/countColumn==0)
    {
        [cell addSubview:cell.label];
        cell.label.frame = cell.bounds;
        cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
        cell.label.textColor= [UIColor whiteColor];
        cell.label.backgroundColor = tBlueColor;
    }
    else if(item%countColumn == 0 || item%countColumn == 1 || item%countColumn == 2 || item%countColumn == 3)
    {
        [cell addSubview:cell.label];
        cell.label.frame = cell.bounds;
        cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
        cell.label.textColor= [UIColor blackColor];
        cell.label.backgroundColor = [UIColor clearColor];
        cell.label.textAlignment = NSTextAlignmentCenter;
        
        [cell addSubview:cell.leftBorder];
        [cell addSubview:cell.topBorder];
        [cell addSubview:cell.rightBorder];
        [cell addSubview:cell.bottomBorder];
    }
    else if(item%countColumn == 4)
    {
        [cell addSubview:cell.buttonDetail];
        cell.buttonDetail.frame = cell.bounds;
        
        [cell addSubview:cell.leftBorder];
        [cell addSubview:cell.topBorder];
        [cell addSubview:cell.rightBorder];
        [cell addSubview:cell.bottomBorder];        
    }
    
    if(item/countColumn == 0)
    {
        NSInteger remainder = item%countColumn;
        cell.label.text = header[remainder];
    }
    else
    {
        ProductStatusSummary *productStatusSummary = (ProductStatusSummary *)_productStatusSummaryListSort[item/countColumn-1];
        switch (item%countColumn) {
            case 0:
            {
                cell.label.text = productStatusSummary.row;
            }
                break;
            case 1:
            {
                if(productStatusSummary.eventID == 0)
                {
                    cell.label.text = [Utility dateToString:[NSDate date] toFormat:[Utility setting:vFormatDateDisplay]];
                }
                else
                {
                    cell.label.text = [Utility formatDateForDisplay:productStatusSummary.periodTo];
                }
            }
                break;
            case 2:
            {
                if(productStatusSummary.eventID == 0)
                {
                    cell.label.text = @"Main Inventory";
                }
                else
                {
                    cell.label.text = productStatusSummary.location;
                }
            }
                break;
            case 3:
            {
                if([productStatusSummary.status isEqualToString:@"I"])
                {
                    cell.label.text = @"In-stock";
                }
                else if([productStatusSummary.status isEqualToString:@"P"])
                {
                    cell.label.text = @"Pre-order";
                }
                else if([productStatusSummary.status isEqualToString:@"S"])
                {
                    cell.label.text = @"Sold";
                }
            }
                break;
            case 4:
            {
//                cell.label.text = [NSString stringWithFormat:@"%ld",productStatusSummary.amount];
                NSString *amount = [NSString stringWithFormat:@"%ld",productStatusSummary.amount];
                [cell.buttonDetail setTitle:amount forState:UIControlStateNormal];
                [cell.buttonDetail setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                cell.buttonDetail.titleLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                cell.buttonDetail.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                
                
                
                cell.buttonDetail.tag = [productStatusSummary.row integerValue];
                [cell.buttonDetail removeTarget:nil
                                         action:NULL
                               forControlEvents:UIControlEventAllEvents];
                [cell.buttonDetail addTarget:self action:@selector(showProductStatusItem:)
                            forControlEvents:UIControlEventTouchUpInside];
            }
                break;            
            default:
                break;
        }
    }
    
    return cell;
}

- (void) showProductStatusItem:(id)sender
{
    UIButton *button = sender;
    NSInteger row = button.tag;
    ProductStatusSummary *productStatusSummary = _productStatusSummaryListSort[row-1];
    
    
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_status = %@ and _eventID = %ld",productStatusSummary.status,productStatusSummary.eventID];
    NSArray *filterArray = [_productStatusItemList filteredArrayUsingPredicate:predicate1];
    [_selectedProductDetailList removeAllObjects];
    NSMutableArray *distinctProductID = [[NSMutableArray alloc]init];
    for(ProductDetail *item in filterArray)
    {
        if(![distinctProductID containsObject:item.productID])
        {
            [distinctProductID addObject:item.productID];
            [_selectedProductDetailList addObject: item];
        }
    }
    [self performSegueWithIdentifier:@"segProductStatusDetail" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"segProductStatusDetail"])
    {
        ProductStatusDetailViewController *vc = segue.destinationViewController;
        vc.productDetailList = _selectedProductDetailList;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width;
    NSArray *arrSize;
    arrSize = @[@26,@85,@0,@65,@35];
//     @[@"No",@"Location",@"Status",@"Total"];
    
    width = [arrSize[indexPath.item%[arrSize count]] floatValue];
    if(width == 0)
    {
        width = colVwData.bounds.size.width;
        for(int i=0; i<[arrSize count]; i++)
        {
            width = width - [arrSize[i] floatValue];
        }
        width -= 20*2;
    }
    
    
    CGSize size = CGSizeMake(width, 30);
    return size;
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)colVwData.collectionViewLayout;
    
    [layout invalidateLayout];
    [colVwData reloadData];
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    //    return UIEdgeInsetsMake(0, 20, 0, 20);//top, left, bottom, right -> collection view
    return UIEdgeInsetsMake(0, 20, 0, 20);//top, left, bottom, right -> collection view
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        
        reusableview = headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footerPayment" forIndexPath:indexPath];
        
        reusableview = footerview;
    }
    
    return reusableview;
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
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
