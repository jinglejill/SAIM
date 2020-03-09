//
//  AccountReceiptHistoryViewController.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 2/12/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import "AccountReceiptHistoryViewController.h"
#import "AccountReceiptHistoryPDFViewController.h"
#import "AccountReceiptHistorySummaryViewController.h"
#import "CustomUICollectionViewCellButton2.h"
#import "CustomUICollectionReusableView.h"
#import "PushSync.h"
#import "SharedPushSync.h"
#import "Utility.h"
#import "ProductCategory2.h"
#import "SharedProductCategory2.h"
#import "SharedProductName.h"
#import "SharedProductSales.h"
#import "AccountReceipt.h"


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


@interface AccountReceiptHistoryViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSMutableArray *_accountReceiptList;
    AccountReceipt *_accountReceiptHistory;
}
@end

@implementation AccountReceiptHistoryViewController
static NSString * const reuseIdentifier = @"Cell";
static NSString * const reuseHeaderViewIdentifier = @"HeaderView";
static NSString * const reuseFooterViewIdentifier = @"FooterView";


@synthesize colViewData;
@synthesize txtAccountReceiptHistoryDate;
@synthesize dtPicker;


- (void)textFieldDidBeginEditing:(UITextField *)textField;
{
    if([textField isEqual:txtAccountReceiptHistoryDate])
    {
        NSString *strDate = textField.text;
        NSDate *datePeriod = [Utility stringToDate:strDate fromFormat:@"yyyy-MM-dd"];
        [dtPicker setDate:datePeriod];
    }
}

- (IBAction)datePickerChanged:(id)sender
{
    if([txtAccountReceiptHistoryDate isFirstResponder])
    {
        txtAccountReceiptHistoryDate.text = [Utility dateToString:dtPicker.date toFormat:@"yyyy-MM-dd"];
    }
    
    
    [self queryProductWithAccountReceiptHistoryDate:[Utility formatDate:txtAccountReceiptHistoryDate.text fromFormat:@"yyyy-MM-dd" toFormat:@"yyyy-MM-dd HH:mm:ss"]];
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
        
    
    
    [dtPicker removeFromSuperview];
    txtAccountReceiptHistoryDate.inputView = dtPicker;
    txtAccountReceiptHistoryDate.delegate = self;
    
    
    NSInteger year = [[Utility dateToString:[NSDate date] toFormat:@"yyyy"] integerValue]-1;
    txtAccountReceiptHistoryDate.text = [NSString stringWithFormat:@"%ld%@",year,[Utility dateToString:[NSDate date] toFormat:@"-MM-dd"]];
    
    
    [self queryProductWithAccountReceiptHistoryDate:[Utility formatDate:txtAccountReceiptHistoryDate.text fromFormat:@"yyyy-MM-dd" toFormat:@"yyyy-MM-dd HH:mm:ss"]];
}

-(void)queryProductWithAccountReceiptHistoryDate:(NSString *)accountReceiptHistoryDate
{
    [self loadingOverlayView];
    [_homeModel downloadItems:dbAccountReceiptHistory condition:accountReceiptHistoryDate];
}

- (void)itemsDownloaded:(NSArray *)items
{
    [self removeOverlayViews];
    int i=0;
    _accountReceiptList = items[i++];

    
    [colViewData reloadData];
}

- (void)itemsDeleted
{
    
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return  1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger countColumn = 4;
    return ([_accountReceiptList count]+1)*countColumn;
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
    if ([cell.buttonDetail isDescendantOfView:cell]) {
        [cell.buttonDetail removeFromSuperview];
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
        NSArray *header = @[@"No",@"Issue date",@"PDF",@"Delete"];
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
            cell.label.textAlignment = NSTextAlignmentCenter;
        }
        else if(item%countColumn==0)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
            cell.label.textColor = [UIColor blackColor];
            cell.label.backgroundColor = [UIColor clearColor];
            cell.label.textAlignment = NSTextAlignmentCenter;
            cell.label.text = [NSString stringWithFormat:@"%ld",item/countColumn];
        }
        else if(item%countColumn==1)
        {
            AccountReceipt *accountReceipt = _accountReceiptList[item/countColumn-1];
            [cell.buttonDetail removeTarget:nil
                                     action:NULL
                           forControlEvents:UIControlEventAllEvents];
            [cell.buttonDetail addTarget:self action:@selector(viewAccountReceipt:)
                        forControlEvents:UIControlEventTouchUpInside];
            
            
            NSString *strAccountReceiptHistoryDate = [Utility formatDate:accountReceipt.accountReceiptHistoryDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd HH:mm"];
            [cell addSubview:cell.buttonDetail];
            [cell.buttonDetail setTitle:strAccountReceiptHistoryDate forState:UIControlStateNormal];
            [cell.buttonDetail setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [cell.buttonDetail setBackgroundColor:[UIColor clearColor]];
            cell.buttonDetail.frame = cell.bounds;
            cell.buttonDetail.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
            cell.buttonDetail.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
            cell.buttonDetail.tag = item;
            cell.buttonDetail.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        }

        else if(item%countColumn==2)
        {
            cell.imageView.userInteractionEnabled = YES;
            [cell addSubview:cell.imageView];
            
            CGRect frame = cell.bounds;
            NSInteger imageSize = 18;
            frame.origin.x = (frame.size.width-imageSize)/2;
            frame.origin.y = (frame.size.height-imageSize)/2;
            frame.size.width = imageSize;
            frame.size.height = imageSize;
            cell.imageView.frame = frame;
            cell.imageView.tag = item;
            
            cell.singleTap.numberOfTapsRequired = 1;
            cell.singleTap.numberOfTouchesRequired = 1;
            [cell.imageView addGestureRecognizer:cell.singleTap];
            
            
            cell.imageView.image = [UIImage imageNamed:@"pdfDoc.png"];
            [cell.singleTap removeTarget:self action:@selector(deleteAccountReceipt:)];
            [cell.singleTap removeTarget:self action:@selector(viewAccountReceiptPDF:)];
            [cell.singleTap addTarget:self action:@selector(viewAccountReceiptPDF:)];
        }
        else if(item%countColumn==3)
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
            [cell.singleTap removeTarget:self action:@selector(deleteAccountReceipt:)];
            [cell.singleTap removeTarget:self action:@selector(viewAccountReceiptPDF:)];
            [cell.singleTap addTarget:self action:@selector(deleteAccountReceipt:)];
            cell.singleTap.numberOfTapsRequired = 1;
            cell.singleTap.numberOfTouchesRequired = 1;
            [cell.imageView addGestureRecognizer:cell.singleTap];
        }
    }
    
    return cell;
}

- (void) viewAccountReceiptPDF:(UIGestureRecognizer *)gestureRecognizer
{
    NSInteger countColumn = 4;
    UIView* view = gestureRecognizer.view;
    
    NSInteger item = view.tag;
    _accountReceiptHistory = _accountReceiptList[item/countColumn-1];
    [self performSegueWithIdentifier:@"segAccountReceiptHistoryPDF" sender:self];
}

- (void)viewAccountReceipt:(id)sender
{
    UIButton *button = sender;
    NSInteger item = button.tag;
    NSInteger countColumn = 4;
    _accountReceiptHistory = _accountReceiptList[item/countColumn-1];
    [self performSegueWithIdentifier:@"segAccountReceiptHistorySummary" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"segAccountReceiptHistoryPDF"])
    {
        AccountReceiptHistoryPDFViewController *vc = segue.destinationViewController;
        vc.accountReceiptHistory = _accountReceiptHistory;
    }
    else if([[segue identifier] isEqualToString:@"segAccountReceiptHistorySummary"])
    {
        AccountReceiptHistorySummaryViewController *vc = segue.destinationViewController;
        vc.accountReceiptHistory = _accountReceiptHistory;
    }
}

- (void) deleteAccountReceipt:(UIGestureRecognizer *)gestureRecognizer {
    UIView* view = gestureRecognizer.view;
    NSInteger item = view.tag;
    NSInteger countColumn = 4;
    AccountReceipt *accountReceipt = _accountReceiptList[item/countColumn-1];
    
    
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
                                    
                                    [_accountReceiptList removeObject:accountReceipt];
                                    [colViewData reloadData];
                                    
                                    //remove from accountInventory
                                    //remove from accountMapping
                                    //remove from accountReceipt
                                    //remove from accountReceiptProductItem
                                    [_homeModel deleteItems:dbAccountReceiptHistory withData:accountReceipt];
                                    
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
    arrSize = @[@30,@0,@50,@80];
    
    
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
