//
//  AccountReceiptHistorySummaryViewController.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 3/6/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import "AccountReceiptHistorySummaryViewController.h"
#import "CustomUICollectionViewCellButton2.h"
#import "CustomUICollectionReusableView.h"
#import "Utility.h"
#import "AccountReceiptHistorySummary.h"



#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]


@interface AccountReceiptHistorySummaryViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSMutableArray *_accountReceiptHistorySummaryList;
    NSMutableArray *receiptInfoList;
    NSString *_strAccountReceiptHistoryDate;
}
@end

@implementation AccountReceiptHistorySummaryViewController
static NSString * const reuseIdentifier = @"Cell";
static NSString * const reuseHeaderViewIdentifier = @"HeaderView";
static NSString * const reuseFooterViewIdentifier = @"FooterView";


@synthesize colViewData;
@synthesize accountReceiptHistory;

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
    
    
    
    [self loadingOverlayView];
    [_homeModel downloadItems:dbAccountReceiptHistorySummary condition:accountReceiptHistory];
}

- (void)itemsDownloaded:(NSArray *)items
{
    [self removeOverlayViews];
    int i=0;
    _accountReceiptHistorySummaryList = items[i++];
    
    [colViewData reloadData];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return  1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger countColumn = 4;
    NSInteger noOfItem = ([_accountReceiptHistorySummaryList count]+1+1)*countColumn;
    return noOfItem;
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
    
    
    
    
    NSInteger item = indexPath.item;
    
    
    
    {
        NSArray *header = @[@"No.",@"Item",@"Qty.",@"Sales"];
        NSInteger countColumn = [header count];
        
        if(item/countColumn==0)
        {
            [cell addSubview:cell.leftBorder];
            [cell addSubview:cell.topBorder];
            [cell addSubview:cell.rightBorder];
            [cell addSubview:cell.bottomBorder];
            
            
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
            cell.label.textColor = [UIColor whiteColor];
            cell.label.backgroundColor = tBlueColor;
            
            
            NSInteger remainder = item%countColumn;
            cell.label.text = header[remainder];
            cell.label.textAlignment = NSTextAlignmentCenter;
        }
        else if(item < ([_accountReceiptHistorySummaryList count]+1)*countColumn)
        {
            [cell addSubview:cell.leftBorder];
            [cell addSubview:cell.topBorder];
            [cell addSubview:cell.rightBorder];
            [cell addSubview:cell.bottomBorder];
            
            
            AccountReceiptHistorySummary *accountReceiptHistorySummary = _accountReceiptHistorySummaryList[item/countColumn-1];
            if(item%countColumn==0)
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
                [cell addSubview:cell.label];
                cell.label.frame = cell.bounds;
                cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                cell.label.textColor = [UIColor blackColor];
                cell.label.backgroundColor = [UIColor clearColor];
                cell.label.textAlignment = NSTextAlignmentCenter;
                cell.label.text = accountReceiptHistorySummary.productName;
            }
            else if(item%countColumn==2)
            {
                [cell addSubview:cell.label];
                cell.label.frame = cell.bounds;
                cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                cell.label.textColor = [UIColor blackColor];
                cell.label.backgroundColor = [UIColor clearColor];
                cell.label.textAlignment = NSTextAlignmentRight;
                
                NSString *strQuantity = [NSString stringWithFormat:@"%f",accountReceiptHistorySummary.quantity];
                strQuantity = [Utility formatBaht:strQuantity withMinFraction:0 andMaxFraction:2];
                cell.label.text = strQuantity;
            }
            else if(item%countColumn==3)
            {
                [cell addSubview:cell.label];
                cell.label.frame = cell.bounds;
                cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                cell.label.textColor = [UIColor blackColor];
                cell.label.backgroundColor = [UIColor clearColor];
                cell.label.textAlignment = NSTextAlignmentRight;
                
                NSString *strSales = [NSString stringWithFormat:@"%f",accountReceiptHistorySummary.sales];
                strSales = [Utility formatBaht:strSales withMinFraction:0 andMaxFraction:2];
                cell.label.text = strSales;
            }
        }
        else
        {
            if(item%countColumn==1)
            {
                [cell addSubview:cell.label];
                cell.label.frame = cell.bounds;
                cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
                cell.label.textColor = [UIColor blackColor];
                cell.label.backgroundColor = [UIColor clearColor];
                cell.label.textAlignment = NSTextAlignmentCenter;
                cell.label.text = @"Total";
            }
            else if(item%countColumn==2)
            {
                [cell addSubview:cell.label];
                cell.label.frame = cell.bounds;
                cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
                cell.label.textColor = [UIColor blackColor];
                cell.label.backgroundColor = [UIColor clearColor];
                cell.label.textAlignment = NSTextAlignmentRight;
                
                NSString *strTotalQuantity = [NSString stringWithFormat:@"%f",[self getTotalQuantity]];
                strTotalQuantity = [Utility formatBaht:strTotalQuantity withMinFraction:0 andMaxFraction:2];
                cell.label.text = strTotalQuantity;
            }
            else if(item%countColumn==3)
            {
                [cell addSubview:cell.label];
                cell.label.frame = cell.bounds;
                cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
                cell.label.textColor = [UIColor blackColor];
                cell.label.backgroundColor = [UIColor clearColor];
                cell.label.textAlignment = NSTextAlignmentRight;
                
                NSString *strTotalSales = [NSString stringWithFormat:@"%f",[self getTotalSales]];
                strTotalSales = [Utility formatBaht:strTotalSales withMinFraction:0 andMaxFraction:2];
                cell.label.text = strTotalSales;
            }
        }
    }
    
    return cell;
}

-(float) getTotalQuantity
{
    float sum = 0;
    for(AccountReceiptHistorySummary *item in _accountReceiptHistorySummaryList)
    {
        sum += item.quantity;
    }
    
    return sum;
}

-(float) getTotalSales
{
    float sum = 0;
    for(AccountReceiptHistorySummary *item in _accountReceiptHistorySummaryList)
    {
        sum += item.sales;
    }
    
    return sum;
}

#pragma mark <UICollectionViewDelegate>
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width;
    NSArray *arrSize;
    arrSize = @[@30,@0,@60,@80];
    
    
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
    return UIEdgeInsetsMake(0, 0, 0, 0);//top, left, bottom, right
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
@end
