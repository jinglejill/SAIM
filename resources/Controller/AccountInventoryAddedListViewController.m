//
//  AccountInventoryAddedListViewController.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 2/11/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import "AccountInventoryAddedListViewController.h"
#import "CustomUICollectionViewCellButton2.h"
#import "CustomUICollectionReusableView.h"
#import "PushSync.h"
#import "SharedPushSync.h"
#import "Utility.h"
#import "ProductCategory2.h"
#import "SharedProductCategory2.h"
#import "SharedProductName.h"
#import "SharedProductSales.h"
#import "AccountInventory.h"


/* Macro for background colors */
#define orangeColor         [UIColor colorWithRed:253/255.0 green:182/255.0 blue:103/255.0 alpha:1]
#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]

#define colorWithRGBHex(hex)[UIColor colorWithRed:((float)((hex&0xFF0000)>>16))/255.0 green:((float)((hex&0xFF00)>>8))/255.0 blue:((float)(hex&0xFF))/255.0 alpha:1.0]
#define clearColorWithRGBHex(hex)[UIColor colorWithRed:MIN((((int)(hex>>16)&0xFF)/255.0)+.1,1.0)green:MIN((((int)(hex>>8)&0xFF)/255.0)+.1,1.0)blue:MIN((((int)(hex)&0xFF)/255.0)+.1,1.0)alpha:1.0]

/* Unselected mark constants */
#define kCircleRadioUnselected      23.0
#define kCircleLeftMargin           13.0
#define kCircleRect                 CGRectMake(3.5, 2.5, 22.0, 22.0)
#define kCircleOverlayRect          CGRectMake(1.5, 12.5, 26.0, 23.0)

/* Mark constants */
#define kStrokeWidth                2.0
#define kShadowRadius               4.0
#define kMarkDegrees                70.0
#define kMarkWidth                  3.0
#define kMarkHeight                 6.0
#define kShadowOffset               CGSizeMake(.0, 2.0)
#define kMarkShadowOffset           CGSizeMake(.0, -1.0)
#define kMarkImageSize              CGSizeMake(30.0, 30.0)
#define kMarkBase                   CGPointMake(9.0, 13.5)
#define kMarkDrawPoint              CGPointMake(20.0, 9.5)
#define kShadowColor                [UIColor colorWithWhite:.0 alpha:0.7]
#define kMarkShadowColor            [UIColor colorWithWhite:.0 alpha:0.3]
#define kBlueColor                  0x236ed8
#define kGreenColor                 0x179714
#define kRedColor                   0xa4091c
#define kMarkColor                  kRedColor

/* Colums and cell constants */
#define kColumnPosition             50.0
#define kMarkCell                   60.0
#define kImageRect                  CGRectMake(10.0, 8.0, 30.0, 30.0)


@interface AccountInventoryAddedListViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSMutableArray *_productCategory2List;
    NSInteger _selectedProductCategory2;
    NSMutableArray *_accountInventoryAddedList;
}
@end

@implementation AccountInventoryAddedListViewController
static NSString * const reuseIdentifier = @"Cell";
static NSString * const reuseHeaderViewIdentifier = @"HeaderView";
static NSString * const reuseFooterViewIdentifier = @"FooterView";


@synthesize colViewData;
@synthesize txtDateIn;
@synthesize dtPicker;
@synthesize txtMainCategory;
@synthesize txtPicker;


- (void)textFieldDidBeginEditing:(UITextField *)textField;
{
    if([textField isEqual:txtDateIn])
    {
        NSString *strDate = textField.text;
        NSDate *datePeriod = [Utility stringToDate:strDate fromFormat:@"yyyy-MM-dd"];
        [dtPicker setDate:datePeriod];
    }
}

- (IBAction)datePickerChanged:(id)sender
{
    if([txtDateIn isFirstResponder])
    {
        txtDateIn.text = [Utility dateToString:dtPicker.date toFormat:@"yyyy-MM-dd"];
    }
    
    
    ProductCategory2 *productCategory2 = _productCategory2List[_selectedProductCategory2];
    [self queryProduct:productCategory2.code dateIn:[Utility formatDate:txtDateIn.text fromFormat:@"yyyy-MM-dd" toFormat:@"yyyy-MM-dd HH:mm:ss"]];
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
    
    _selectedProductCategory2 = 0;
    
    
    [txtPicker removeFromSuperview];
    txtMainCategory.delegate = self;
    txtMainCategory.inputView = txtPicker;
    txtPicker.delegate = self;
    txtPicker.dataSource = self;
    txtPicker.showsSelectionIndicator = YES;
    
    
    [dtPicker removeFromSuperview];
    txtDateIn.inputView = dtPicker;
    txtDateIn.delegate = self;
    
    
    NSInteger year = [[Utility dateToString:[NSDate date] toFormat:@"yyyy"] integerValue]-1;
    txtDateIn.text = [NSString stringWithFormat:@"%ld%@",year,[Utility dateToString:[NSDate date] toFormat:@"-MM-dd"]];
    
    
    _productCategory2List = [SharedProductCategory2 sharedProductCategory2].productCategory2List;
    _productCategory2List = [ProductCategory2 getProductCategory2SortByOrderNo:_productCategory2List];
    
    
    ProductCategory2 *productCategory2 = _productCategory2List[_selectedProductCategory2];
    txtMainCategory.text = productCategory2.name;
    
    
    [self queryProduct:productCategory2.code dateIn:[Utility formatDate:txtDateIn.text fromFormat:@"yyyy-MM-dd" toFormat:@"yyyy-MM-dd HH:mm:ss"]];
}

-(void)queryProduct:(NSString *)productCategory2 dateIn:(NSString *)dateIn
{
    [self loadingOverlayView];
    [_homeModel downloadItems:dbAccountInventoryAdded condition:@[productCategory2,dateIn]];
}

- (void)itemsDownloaded:(NSArray *)items
{
    [self removeOverlayViews];
    int i=0;
    _accountInventoryAddedList = items[i++];
    _accountInventoryAddedList = [AccountInventory getAccountInventorySortedByUsed:_accountInventoryAddedList];
    
    
    [colViewData reloadData];
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return  1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger countColumn = 5;
    return ([_accountInventoryAddedList count]+1)*countColumn;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CustomUICollectionViewCellButton2 *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if ([cell.textField isDescendantOfView:cell])
    {
        [cell.textField removeFromSuperview];
    }
    if ([cell.label isDescendantOfView:cell])
    {
        [cell.label removeFromSuperview];
    }
    if ([cell.imageView isDescendantOfView:cell]) {
        [cell.imageView removeFromSuperview];
    }
    if ([cell.leftBorder isDescendantOfView:cell])
    {
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
    
    [cell addSubview:cell.leftBorder];
    [cell addSubview:cell.topBorder];
    [cell addSubview:cell.rightBorder];
    [cell addSubview:cell.bottomBorder];
    
    
    NSInteger item = indexPath.item;

    
    
    {
        NSArray *header = @[@"No",@"Item",@"Date in",@"Qty.",@"Delete"];
        NSInteger countColumn = [header count];
        
        if(item/countColumn==0)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
            cell.label.textColor = [UIColor whiteColor];
            cell.label.backgroundColor = tBlueColor;
            
            
            NSInteger remainder = item%countColumn;
            cell.label.text = header[remainder];
            
            
            if(item == 1)
            {
                cell.label.textAlignment = NSTextAlignmentLeft;
            }
            else if(item == 0 || item == 2 || item == 4)
            {
                cell.label.textAlignment = NSTextAlignmentCenter;
            }
            else if(item == 3)
            {
                cell.label.textAlignment = NSTextAlignmentRight;
            }
        }
        else if(item%countColumn==0 || item%countColumn==1 || item%countColumn==2 || item%countColumn==3)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
            cell.label.backgroundColor = [UIColor clearColor];
            
            
            AccountInventory *accountInventory = _accountInventoryAddedList[item/countColumn-1];
            if(accountInventory.used == 0)
            {
                cell.label.textColor = [UIColor blackColor];
            }
            else if(accountInventory.used == 1)
            {
                cell.label.textColor = [UIColor lightGrayColor];
            }
            
            
            switch (item%countColumn) {
                case 0:
                {
                    cell.label.textAlignment = NSTextAlignmentCenter;
                    cell.label.text = [NSString stringWithFormat:@"%ld",item/countColumn];
                }
                break;
                case 1:
                {
                    cell.label.textAlignment = NSTextAlignmentLeft;
                    cell.label.text = accountInventory.productName;
                }
                break;
                case 2:
                {
                    cell.label.textAlignment = NSTextAlignmentCenter;
                    NSString *strDateIn = [Utility formatDate:accountInventory.inOutDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd"];
                    cell.label.text = strDateIn;
                }
                break;
                case 3:
                {
                    cell.label.textAlignment = NSTextAlignmentRight;
                    NSString *strQuantity = [NSString stringWithFormat:@"%f",accountInventory.quantity];
                    cell.label.text = [Utility formatBaht:strQuantity withMinFraction:0 andMaxFraction:2];
                }
                break;
                default:
                break;
            }
        }
        else if(item%countColumn==4)
        {
            cell.imageView.image = [self renderMark];
            cell.imageView.userInteractionEnabled = YES;
            [cell addSubview:cell.imageView];
            
            CGRect frame = cell.bounds;
            frame.origin.x = (frame.size.width-18)/2;
            frame.origin.y = (frame.size.height-18)/2;
            frame.size.width = 18;
            frame.size.height = 18;
            cell.imageView.frame = frame;
            
            
            cell.imageView.tag = item;
            [cell.singleTap addTarget:self action:@selector(deleteAccountInventory:)];
            cell.singleTap.numberOfTapsRequired = 1;
            cell.singleTap.numberOfTouchesRequired = 1;
            [cell.imageView addGestureRecognizer:cell.singleTap];
        }
    }    
    
    return cell;
}

- (void) deleteAccountInventory:(UIGestureRecognizer *)gestureRecognizer {
    UIView* view = gestureRecognizer.view;
    NSInteger item = view.tag;
    NSInteger countColumn = 5;
    AccountInventory *accountInventory = _accountInventoryAddedList[item/countColumn-1];
    
    if(accountInventory.used == 1)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Cannot delete"
                                                                       message:@"Some or all of this inventory are used"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    
    //    else
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        CustomUICollectionViewCellButton2 *cell = (CustomUICollectionViewCellButton2*)[colViewData cellForItemAtIndexPath:indexPath];
        
        
        //delete with product id -> confirm delete -> delete -> reload collectionview
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:
         [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"ลบรายการที่ %ld",item/countColumn]
                                  style:UIAlertActionStyleDestructive
                                handler:^(UIAlertAction *action) {
                                    
                                    
                                    [_accountInventoryAddedList removeObject:accountInventory];
                                    [colViewData reloadData];
                                    
                                    [_homeModel deleteItems:dbAccountInventory withData:accountInventory];
//                                    [self loadViewProcess];
                                    
                                }]];
        [alert addAction:
         [UIAlertAction actionWithTitle:@"ยกเลิก"
                                  style:UIAlertActionStyleCancel
                                handler:^(UIAlertAction *action) {}]];
        
        
        ///////////////ipad
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            [alert setModalPresentationStyle:UIModalPresentationPopover];
            
            UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
            CGRect frame = cell.imageView.bounds;
            frame.origin.y = frame.origin.y-15;
            popPresenter.sourceView = cell.imageView;
            popPresenter.sourceRect = frame;
            //        popPresenter.barButtonItem = _barButtonIpad;
        }
        ///////////////
        
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}
#pragma mark <UICollectionViewDelegate>


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width;
    NSArray *arrSize;
    arrSize = @[@30,@110,@90,@60,@0];
    
    
    width = [arrSize[indexPath.item%[arrSize count]] floatValue];
    if(width == 0)
    {
        width = colViewData.bounds.size.width;
        for(int i=0; i<[arrSize count]; i++)
        {
            width = width - [arrSize[i] floatValue];
        }
    }
    
    
    CGSize size = CGSizeMake(width, 30);
    return size;
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.colViewData.collectionViewLayout;
    
    [layout invalidateLayout];
    [colViewData reloadData];
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 20, 0);//top, left, bottom, right
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
{
    CGSize headerSize = CGSizeMake(collectionView.bounds.size.width, 0);
    return headerSize;
}

- (void)loadViewProcess
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Register cell classes
    [colViewData registerClass:[CustomUICollectionViewCellButton2 class] forCellWithReuseIdentifier:reuseIdentifier];
    [colViewData registerClass:[CustomUICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeaderViewIdentifier];
    [colViewData registerClass:[CustomUICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:reuseFooterViewIdentifier];
    colViewData.delegate = self;
    colViewData.dataSource = self;
    
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
    
    ProductCategory2 *productCategory2 = _productCategory2List[row];
    txtMainCategory.text = productCategory2.name;
    [self queryProduct:productCategory2.code dateIn:[Utility formatDate:txtDateIn.text fromFormat:@"yyyy-MM-dd" toFormat:@"yyyy-MM-dd HH:mm:ss"]];
    [colViewData reloadData];
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [_productCategory2List count];
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    ProductCategory2 *productCategory2 = _productCategory2List[row];
    return productCategory2.name;
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    //    int sectionWidth = 300;
    
    return self.view.frame.size.width;
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
                                                              
                                                          }];
    
    [alert addAction:defaultAction];
    dispatch_async(dispatch_get_main_queue(),^ {
        [self presentViewController:alert animated:YES completion:nil];
    } );
}

- (UIImage *)renderMark
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
    UIGraphicsBeginImageContextWithOptions(kMarkImageSize, NO, [UIScreen mainScreen].scale);
    else
    UIGraphicsBeginImageContext(kMarkImageSize);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIBezierPath *markCircle = [UIBezierPath bezierPathWithOvalInRect:kCircleRect];
    
    /* Background */
    CGContextSaveGState(ctx);
    {
        CGContextAddPath(ctx, markCircle.CGPath);
        CGContextSetFillColorWithColor(ctx, clearColorWithRGBHex(kMarkColor).CGColor);
        CGContextSetShadowWithColor(ctx, kShadowOffset, kShadowRadius, kShadowColor.CGColor );
        CGContextDrawPath(ctx, kCGPathFill);
    }
    CGContextRestoreGState(ctx);
    
    /* Overlay */
    CGContextSaveGState(ctx);
    {
        CGContextAddPath(ctx, markCircle.CGPath);
        CGContextClip(ctx);
        CGContextAddEllipseInRect(ctx, kCircleOverlayRect);
        CGContextSetFillColorWithColor(ctx, colorWithRGBHex(kMarkColor).CGColor);
        CGContextDrawPath(ctx, kCGPathFill);
    }
    CGContextRestoreGState(ctx);
    
    /* Stroke */
    CGContextSaveGState(ctx);
    {
        CGContextAddPath(ctx, markCircle.CGPath);
        CGContextSetLineWidth(ctx, kStrokeWidth);
        CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
        CGContextDrawPath(ctx, kCGPathStroke);
    }
    CGContextRestoreGState(ctx);
    
    /* Mark */
    CGContextSaveGState(ctx);
    {
        CGContextSetShadowWithColor(ctx, kMarkShadowOffset, .0, kMarkShadowColor.CGColor );
        CGContextMoveToPoint(ctx, kMarkBase.x, kMarkBase.y);
        //        CGContextAddLineToPoint(ctx, kMarkBase.x + kMarkHeight * sin(kMarkDegrees), kMarkBase.y + kMarkHeight * cos(kMarkDegrees));
        //        CGContextAddLineToPoint(ctx, kMarkDrawPoint.x, kMarkDrawPoint.y);
        CGContextAddLineToPoint(ctx, kMarkDrawPoint.x, kMarkBase.y);
        CGContextSetLineWidth(ctx, kMarkWidth);
        CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
        CGContextStrokePath(ctx);
    }
    CGContextRestoreGState(ctx);
    
    UIImage *selectedMark = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return selectedMark;
}

@end
