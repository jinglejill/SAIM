//
//  ProductStatusDetailViewController.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 8/25/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "ProductStatusDetailViewController.h"
#import "CustomUICollectionViewCellButton.h"
#import "CustomUICollectionReusableView.h"
#import "Utility.h"
#import "CustomerReceipt.h"
#import "ReceiptProductItem.h"
#import "CustomMade.h"
#import "Product.h"
#import "SharedCustomerReceipt.h"
#import "SharedReceiptItem.h"
#import "SharedProduct.h"
#import "SharedReceipt.h"
#import "ProductDetail.h"


#define orangeColor         [UIColor colorWithRed:253/255.0 green:182/255.0 blue:103/255.0 alpha:1]
#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]


@interface ProductStatusDetailViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
//    NSMutableArray *_receiptProductItemList;
    NSMutableArray *_mutArrCustomerReceiptList;
    NSMutableArray *_mutArrReceiptProductItemList;
    NSInteger _selectedIndexPathForRow;
    NSInteger _countColumn;
}
@end

@implementation ProductStatusDetailViewController
static NSString * const reuseIdentifier = @"Cell";
static NSString * const reuseHeaderViewIdentifier = @"HeaderView";
static NSString * const reuseFooterViewIdentifier = @"FooterView";


@synthesize colViewProductItem;
@synthesize productDetailList;


- (IBAction)unwindToProductStatusDetail:(UIStoryboardSegue *)segue
{
    
}
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
    
    
    self.navigationItem.title = [NSString stringWithFormat:@"Product Status Detail"];
    
    
    
    ProductDetail *productDetailFirstRow = productDetailList[0];
    if([productDetailFirstRow.status isEqualToString:@"I"] && productDetailFirstRow.eventID == 0)
    {
        _countColumn = 2;
    }
    else if([productDetailFirstRow.status isEqualToString:@"I"] && productDetailFirstRow.eventID != 0)
    {
        _countColumn = 3;
    }
    else if([productDetailFirstRow.status isEqualToString:@"P"] && [productDetailFirstRow.status isEqualToString:@"S"])
    {
        _countColumn = 6;
    }
    else
    {
        _countColumn = 6;
    }

    
    [self loadViewProcess];
}

- (void)loadViewProcess
{
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_receiptDate" ascending:NO];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_manufacturingDate" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2, nil];
    NSArray *sortArray = [productDetailList sortedArrayUsingDescriptors:sortDescriptors];
    productDetailList = [sortArray mutableCopy];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Register cell classes
    [colViewProductItem registerClass:[CustomUICollectionViewCellButton class] forCellWithReuseIdentifier:reuseIdentifier];
    [colViewProductItem registerClass:[CustomUICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeaderViewIdentifier];
    [colViewProductItem registerClass:[CustomUICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:reuseFooterViewIdentifier];
    
    colViewProductItem.delegate = self;
    colViewProductItem.dataSource = self;
    
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSInteger rowNo = [productDetailList count];
    return (rowNo+1)*_countColumn;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CustomUICollectionViewCellButton *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if ([cell.label isDescendantOfView:cell]) {
        [cell.label removeFromSuperview];
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
    NSArray *header;
    if(_countColumn == 2)
    {
        header = @[@"No.",@"MFD"];
    }
    else if(_countColumn == 3)
    {
        header = @[@"No.",@"MFD",@"Offer P."];
    }
    else if(_countColumn == 6)
    {
        header = @[@"No.",@"MFD",@"Offer P.",@"Sold P.",@"Rcpt No",@"Rcpt Date"];
    }
    
    NSInteger countColumn = [header count];
    
    if(item/countColumn==0)
    {
        [cell addSubview:cell.label];
        cell.label.frame = cell.bounds;
        cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
        cell.label.textColor= [UIColor whiteColor];
        cell.label.backgroundColor = tBlueColor;
    }
    else
    {
        [cell addSubview:cell.label];
        cell.label.frame = cell.bounds;
        cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
        cell.label.textColor= [UIColor blackColor];
        cell.label.backgroundColor = [UIColor clearColor];
        
        
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
    else if(_countColumn == 2)
    {
        ProductDetail *productDetail = productDetailList[item/countColumn-1];
        switch (item%countColumn) {
            case 0:
            {
                NSString *strNo = [NSString stringWithFormat:@"%ld",item/countColumn];
                cell.label.text = strNo;
            }
                break;
            case 1:
            {
                cell.label.text = [Utility formatDate:productDetail.manufacturingDate fromFormat:@"yyyy-MM-dd" toFormat:@"dd/MM/yyyy"];
            }
                break;
            default:
                break;
        }
    }
    else if(_countColumn == 3)
    {
        ProductDetail *productDetail = productDetailList[item/countColumn-1];
        switch (item%countColumn) {
            case 0:
            {
                NSString *strNo = [NSString stringWithFormat:@"%ld",item/countColumn];
                cell.label.text = strNo;
            }
                break;
            case 1:
            {
                cell.label.text = [Utility formatDate:productDetail.manufacturingDate fromFormat:@"yyyy-MM-dd" toFormat:@"dd/MM/yyyy"];
            }
                break;
            case 2:
            {
                cell.label.text = [Utility formatBaht:productDetail.pricePromotion];
            }
                break;
            default:
                break;
        }
    }
    else if(_countColumn == 6)
    {
        ProductDetail *productDetail = productDetailList[item/countColumn-1];
        switch (item%countColumn) {
            case 0:
            {
                NSString *strNo = [NSString stringWithFormat:@"%ld",item/countColumn];
                cell.label.text = strNo;
            }
                break;
            case 1:
            {
                cell.label.text = [Utility formatDate:productDetail.manufacturingDate fromFormat:@"yyyy-MM-dd" toFormat:@"dd/MM/yyyy"];
            }
                break;
            case 2:
            {
                cell.label.text = [Utility formatBaht:productDetail.pricePromotion];
            }
                break;
            case 3:
            {
                cell.label.text = [Utility formatBaht:productDetail.priceSold];
            }
                break;
            case 4:
            {
                cell.label.text = productDetail.receiptNo;
            }
                break;
            case 5:
            {
                cell.label.text = [Utility formatDate:productDetail.receiptDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"dd/MM/yyyy"];
            }
                break;
            default:
                break;
        }
    }
    
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //    @[@"Date",@"Event",@"Style",@"Color",@"Size"];
//    @[@"No.",@"MFD",@"Price Offer",@"Price sold",@"Receipt No",@"Receipt Date"];
    CGFloat width;
    NSArray *arrSize;
    if(_countColumn == 2)
    {
        arrSize = @[@26,@0];
    }
    else if(_countColumn == 3)
    {
        arrSize = @[@26,@0,@55];
    }
    else if(_countColumn == 6)
    {
        arrSize = @[@26,@0,@55,@55,@60,@70];
    }
    
    
    
    width = [arrSize[indexPath.item%[arrSize count]] floatValue];
    if(width == 0)
    {
        width = colViewProductItem.bounds.size.width;
        for(int i=0; i<[arrSize count]; i++)
        {
            width = width - [arrSize[i] floatValue];
        }
        width = width - 40;
    }
    
    
    CGSize size = CGSizeMake(width, 30);
    return size;
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.colViewProductItem.collectionViewLayout;
    
    [layout invalidateLayout];
    [colViewProductItem reloadData];
}
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 20, 20, 20);//top, left, bottom, right -> collection view
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
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        
        reusableview = footerview;
    }
    
    return reusableview;
}

-(UILabel *)setLabelUnderline:(UILabel *)label underline:(UIView *)viewUnderline
{
    CGRect expectedLabelSize = [label.text boundingRectWithSize:label.frame.size
                                                        options:NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading
                                                     attributes:@{NSFontAttributeName:label.font}
                                                        context:nil];
    CGFloat xOrigin=0;
    switch (label.textAlignment) {
        case NSTextAlignmentCenter:
        xOrigin=(label.frame.size.width - expectedLabelSize.size.width)/2;
        break;
        case NSTextAlignmentLeft:
        xOrigin=0;
        break;
        case NSTextAlignmentRight:
        xOrigin=label.frame.size.width - expectedLabelSize.size.width;
        break;
        default:
        break;
    }
    viewUnderline.frame=CGRectMake(xOrigin,
                                   expectedLabelSize.size.height-1,
                                   expectedLabelSize.size.width,
                                   1);
    viewUnderline.backgroundColor=label.textColor;
    [label addSubview:viewUnderline];
    return label;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
{
    CGSize headerSize = CGSizeMake(collectionView.bounds.size.width, 20);
    return headerSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    CGSize footerSize = CGSizeMake(collectionView.bounds.size.width, 0);
    return footerSize;
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
