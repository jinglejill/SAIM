//
//  MemberReceiptViewController.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 4/16/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import "MemberReceiptViewController.h"
#import "CustomUICollectionViewCellButton2.h"
#import "CustomUICollectionReusableView.h"
#import "ReceiptProductItem.h"
#import "Utility.h"
#import "PushSync.h"
#import "SharedPushSync.h"
#import "RewardPoint.h"
#import "PostCustomer.h"


#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]


@interface MemberReceiptViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSInteger defaultFontSize;
}
@end
@implementation MemberReceiptViewController
static NSString * const reuseIdentifier = @"Cell";
static NSString * const reuseHeaderViewIdentifier = @"HeaderView";
static NSString * const reuseFooterViewIdentifier = @"FooterView";

@synthesize colViewData;
@synthesize selectedReceiptList;
@synthesize selectedReceiptProductItemList;
@synthesize selectedMemberAndPoint;
@synthesize lblName;
@synthesize lblPhoneNo;


- (void)loadView
{
    [super loadView];
    
    
    _homeModel = [[HomeModel alloc] init];
    _homeModel.delegate = self;
    
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        defaultFontSize = 16;
    }
    else
    {
        defaultFontSize = 13;
    }
    
    
    {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        overlayView.tag = 88;
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);
        indicator.tag = 77;
    }
    
    selectedReceiptList = [Receipt getReceiptSortByReceiptDate:selectedReceiptList];
    lblName.text = [NSString stringWithFormat:@"Name: %@",selectedMemberAndPoint.name];
    NSString *strPhoneNo = [selectedMemberAndPoint.phoneNo isEqualToString:@""]?@"-":[Utility setPhoneNoFormat:selectedMemberAndPoint.phoneNo];
    lblPhoneNo.text = [NSString stringWithFormat:@"Phone no: %@",strPhoneNo];
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

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [selectedReceiptList count];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    Receipt *receipt = selectedReceiptList[section];
    NSMutableArray *receiptProductItemList = [ReceiptProductItem getReceiptProductItemWithReceiptID:receipt.receiptID receiptProductItemList:selectedReceiptProductItemList];
    
    
    NSInteger countColumn = 5;
    NSInteger noOfItems = ([receiptProductItemList count]+1)*countColumn;
    return noOfItems;
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
    if ([cell.textField isDescendantOfView:cell]) {
        [cell.textField removeFromSuperview];
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
    
    
    [cell addSubview:cell.leftBorder];
    [cell addSubview:cell.topBorder];
    [cell addSubview:cell.rightBorder];
    [cell addSubview:cell.bottomBorder];
    
    
    if([collectionView isEqual:colViewData])
    {
        NSInteger item = indexPath.item;
        NSArray *header;
//        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
//        {
//            header = @[@"ลำดับ",@"รายการอาหาร",@"จำนวน",@"ราคา",@"ลด",@"ราคารวม"];
//        }
//        else
        {
            header = @[@"No",@"Item",@"Color",@"Size",@"Price"];
        }
        
        
        NSInteger countColumn = [header count];
        
        if(item/countColumn==0)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:defaultFontSize];
            cell.label.textColor = [UIColor whiteColor];
            cell.label.backgroundColor = tBlueColor;
            cell.label.textAlignment = NSTextAlignmentCenter;
            
            
            NSInteger remainder = item%countColumn;
            cell.label.text = header[remainder];
        }
        else
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:defaultFontSize];
            cell.label.textColor= [UIColor blackColor];
            cell.label.backgroundColor = [UIColor clearColor];
            cell.label.textAlignment = NSTextAlignmentCenter;
            
            
            Receipt *receipt = selectedReceiptList[indexPath.section];
            NSMutableArray *receiptProductItemList = [ReceiptProductItem getReceiptProductItemWithReceiptID:receipt.receiptID receiptProductItemList:selectedReceiptProductItemList];
            receiptProductItemList = [ReceiptProductItem getReceiptProductItemSortByProductNameColorSize:receiptProductItemList];
            
            ReceiptProductItem *receiptProductItem = receiptProductItemList[item/countColumn-1];
            switch (item%countColumn) {
                case 0:
                {
                    NSString *strRunningNo = [NSString stringWithFormat:@"%ld",item/countColumn];
                    cell.label.text = strRunningNo;
                }
                    break;
                case 1:
                {
                    cell.label.textAlignment = NSTextAlignmentCenter;
                    cell.label.text = receiptProductItem.productName;
                }
                    break;
                case 2:
                {
                    cell.label.textAlignment = NSTextAlignmentCenter;
                    cell.label.text = receiptProductItem.color;
                }
                    break;
                case 3:
                {
                    cell.label.textAlignment = NSTextAlignmentCenter;
                    cell.label.text = receiptProductItem.size;
                }
                    break;
                case 4:
                {
                    NSString *strPriceSales = receiptProductItem.priceSales;
                    cell.label.textAlignment = NSTextAlignmentRight;
                    cell.label.text = [Utility formatBaht:strPriceSales withMinFraction:0 andMaxFraction:2];
                }
                    break;
                default:
                    break;
            }
        }
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize size;
    CGFloat width;
    CGFloat height;
    NSArray *arrSize;
//    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
//    {
//        arrSize = @[@45,@0,@65,@80,@80,@80];
//        height = 30;
//    }
//    else
    {
        arrSize = @[@26,@0,@80,@30,@70];
        height = 20;
    }
    
    
    
    width = [arrSize[indexPath.item%[arrSize count]] floatValue];
    if(width == 0)
    {
        width = colViewData.bounds.size.width;
        for(int i=0; i<[arrSize count]; i++)
        {
            width = width - [arrSize[i] floatValue];
        }
    }
    
    size = CGSizeMake(width, height);
    
    return size;
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)colViewData.collectionViewLayout;
    
    [layout invalidateLayout];
    [colViewData reloadData];
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(0, 0, 0, 0);//top, left, bottom, right -> collection view
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
        CustomUICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeaderViewIdentifier forIndexPath:indexPath];
        
        CGFloat height = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad?30:20;
        
        {
            Receipt *receipt = selectedReceiptList[indexPath.section];
            headerView.label.text = [NSString stringWithFormat:@"Receipt no. R%06ld",receipt.receiptID];
            [headerView.label setFont:[UIFont fontWithName:@"HelveticaNeue-light" size:defaultFontSize]];
            CGRect frame = headerView.frame;
            frame.origin.x = 0;
            frame.origin.y = 0;
            frame.size.height = height;
            frame.size.width = frame.size.width;
            headerView.label.frame = frame;
            headerView.label.textAlignment = NSTextAlignmentLeft;
            [headerView addSubview:headerView.label];
        }
        {
            Receipt *receipt = selectedReceiptList[indexPath.section];
            Event *event = [Event getEvent:[receipt.eventID integerValue]];
            headerView.labelAlignRight.text = [NSString stringWithFormat:@"Event: %@",event.location];
            [headerView.labelAlignRight setFont:[UIFont fontWithName:@"HelveticaNeue-light" size:defaultFontSize]];
            CGRect frameAlignRight = headerView.frame;
            frameAlignRight.origin.y = 0;
            frameAlignRight.size.height = height;
            frameAlignRight.size.width = frameAlignRight.size.width;
            headerView.labelAlignRight.frame = frameAlignRight;
            headerView.labelAlignRight.textAlignment = NSTextAlignmentRight;
            [headerView addSubview:headerView.labelAlignRight];
        }
        
        reusableview = headerView;
    }
    
    
    if (kind == UICollectionElementKindSectionFooter) {
        CustomUICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:reuseFooterViewIdentifier forIndexPath:indexPath];
        
        CGFloat height = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad?30:20;
        
        
        Receipt *receipt = selectedReceiptList[indexPath.section];
        NSInteger yPosition = 0;
        if(![receipt.remark isEqualToString:@""])
        {
            yPosition = 1;
            
            
            footerView.label4.text = [NSString stringWithFormat:@"หมายเหตุ: %@",receipt.remark];
            [footerView.label4 setFont:[UIFont fontWithName:@"HelveticaNeue-light" size:defaultFontSize]];
            CGRect frame = footerView.frame;
            frame.origin.y = 0;
            frame.size.height = height;
            footerView.label4.frame = frame;
            footerView.label4.textAlignment = NSTextAlignmentLeft;
            [footerView addSubview:footerView.label4];
        }
        else
        {
            yPosition = 0;
            [footerView.label4 removeFromSuperview];
        }
        
        
        {
            footerView.label.text = @"Total";
            [footerView.label setFont:[UIFont fontWithName:@"HelveticaNeue-light" size:defaultFontSize]];
            CGRect frame = footerView.frame;
            frame.origin.x = frame.size.width - 100 - 100;
            frame.origin.y = yPosition*height;
            frame.size.height = height;
            frame.size.width = frame.size.width - 100;
            footerView.label.frame = frame;
            footerView.label.textAlignment = NSTextAlignmentLeft;
            [footerView addSubview:footerView.label];
            
            
            NSString *strTotalAmount = [NSString stringWithFormat:@"%f",[self getTotalAmountByReceipt:receipt]];
            footerView.labelAlignRight.text = [Utility formatBaht:strTotalAmount withMinFraction:0 andMaxFraction:2];
            [footerView.labelAlignRight setFont:[UIFont fontWithName:@"HelveticaNeue-light" size:defaultFontSize]];
            CGRect frameAlignRight = footerView.frame;
            frameAlignRight.origin.y = yPosition*height;
            frameAlignRight.size.height = height;
            frameAlignRight.size.width = frameAlignRight.size.width;
            footerView.labelAlignRight.frame = frameAlignRight;
            footerView.labelAlignRight.textAlignment = NSTextAlignmentRight;
            [footerView addSubview:footerView.labelAlignRight];
        }
        {
            footerView.label2.text = [self getDiscountLabelByReceipt:receipt];
            [footerView.label2 setFont:[UIFont fontWithName:@"HelveticaNeue-light" size:defaultFontSize]];
            CGRect frame = footerView.frame;
            frame.origin.x = frame.size.width - 100 - 100;
            frame.origin.y = (yPosition+1)*height;
            frame.size.height = height;
            frame.size.width = frame.size.width - 100;
            footerView.label2.frame = frame;
            footerView.label2.textAlignment = NSTextAlignmentLeft;
            [footerView addSubview:footerView.label2];
            
            
            float discount = [self getDiscountByReceipt:receipt];
            if(discount == 0.0f)
            {
                footerView.labelAlignRight2.text = @"-";
            }
            else
            {
                NSString *strDiscount = [NSString stringWithFormat:@"%f",discount];
                footerView.labelAlignRight2.text = [Utility formatBaht:strDiscount withMinFraction:0 andMaxFraction:0];;
            }
            [footerView.labelAlignRight2 setFont:[UIFont fontWithName:@"HelveticaNeue-light" size:defaultFontSize]];
            CGRect frameAlignRight = footerView.frame;
            frameAlignRight.origin.y = (yPosition+1)*height;
            frameAlignRight.size.height = height;
            frameAlignRight.size.width = frameAlignRight.size.width;
            footerView.labelAlignRight2.frame = frameAlignRight;
            footerView.labelAlignRight2.textAlignment = NSTextAlignmentRight;
            [footerView addSubview:footerView.labelAlignRight2];
        }
        {
            footerView.label3.text = @"Aft. discount";
            [footerView.label3 setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:defaultFontSize]];
            CGRect frame = footerView.frame;
            frame.origin.x = frame.size.width - 100 - 100;
            frame.origin.y = (yPosition+2)*height;
            frame.size.height = height;
            frame.size.width = frame.size.width - 100;
            footerView.label3.frame = frame;
            footerView.label3.textAlignment = NSTextAlignmentLeft;
            [footerView addSubview:footerView.label3];
            
            
            NSString *strTotalAmountAfterDiscount = [NSString stringWithFormat:@"%f",[self getTotalAmountAfterDiscountByReceipt:receipt]];
            footerView.labelAlignRight3.text = [Utility formatBaht:strTotalAmountAfterDiscount withMinFraction:0 andMaxFraction:0];
            [footerView.labelAlignRight3 setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:defaultFontSize]];
            CGRect frameAlignRight = footerView.frame;
            frameAlignRight.origin.y = (yPosition+2)*height;
            frameAlignRight.size.height = height;
            frameAlignRight.size.width = frameAlignRight.size.width;
            footerView.labelAlignRight3.frame = frameAlignRight;
            footerView.labelAlignRight3.textAlignment = NSTextAlignmentRight;
            [footerView addSubview:footerView.labelAlignRight3];
        }
        {
            footerView.label5.text = @"Point receive";
            [footerView.label5 setFont:[UIFont fontWithName:@"HelveticaNeue-light" size:defaultFontSize]];
            CGRect frame = footerView.frame;
            frame.origin.x = frame.size.width - 100 - 100;
            frame.origin.y = (yPosition+3)*height;
            frame.size.height = height;
            frame.size.width = frame.size.width - 100;
            footerView.label5.frame = frame;
            footerView.label5.textAlignment = NSTextAlignmentLeft;
            [footerView addSubview:footerView.label5];
            
            
            NSString *strPointReceive = [NSString stringWithFormat:@"%ld",[self getRewardPointReceiveByReceipt:receipt]];
            footerView.labelAlignRight5.text = [strPointReceive isEqualToString:@"0"]?@"-":[Utility formatBaht:strPointReceive withMinFraction:0 andMaxFraction:0];
            [footerView.labelAlignRight5 setFont:[UIFont fontWithName:@"HelveticaNeue-light" size:defaultFontSize]];
            CGRect frameAlignRight = footerView.frame;
            frameAlignRight.origin.y = (yPosition+3)*height;
            frameAlignRight.size.height = height;
            frameAlignRight.size.width = frameAlignRight.size.width;
            footerView.labelAlignRight5.frame = frameAlignRight;
            footerView.labelAlignRight5.textAlignment = NSTextAlignmentRight;
            [footerView addSubview:footerView.labelAlignRight5];
        }
        
        reusableview = footerView;
    }
    
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
{
    CGFloat height;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        height = 30;
    }
    else
    {
        height = 20;
    }
    CGSize headerSize = CGSizeMake(collectionView.bounds.size.width, height);
    return headerSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    CGFloat height;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        height = 30;
    }
    else
    {
        height = 20;
    }
    
    CGSize footerSize;
    Receipt *receipt = selectedReceiptList[section];
    if(![receipt.remark isEqualToString:@""])
    {
        footerSize = CGSizeMake(collectionView.bounds.size.width, height*5.5);
    }
    else
    {
        footerSize = CGSizeMake(collectionView.bounds.size.width, height*4.5);
    }
    return footerSize;
}

- (NSInteger)getRewardPointReceiveByReceipt:(Receipt *)receipt
{
    NSInteger rewardPointReceive = 0;
    RewardPoint *rewardPoint = [RewardPoint getRewardPointReceiveWithReceiptID:receipt.receiptID];
    if(rewardPoint)
    {
        rewardPointReceive = rewardPoint.point;
    }
    return rewardPointReceive;
}

- (NSString *)getDiscountLabelByReceipt:(Receipt *)receipt
{
    if(receipt.discount == 0)
    {
        return @"Discount";
    }
    else
    {
        RewardPoint *rewardPoint = [RewardPoint getRewardPointSpentWithReceiptID:receipt.receiptID];
        if(rewardPoint)
        {
            if([receipt.discount integerValue] == 2)
            {
                return [NSString stringWithFormat:@"Use %ld point for disc (%@\uFF05)",rewardPoint.point,receipt.discountPercent];
            }
            else if([receipt.discount integerValue] == 1)
            {
                return [NSString stringWithFormat:@"Use %ld point for discount",rewardPoint.point];
            }
        }
        else
        {
            if([receipt.discount integerValue] == 1)//discountType = baht
            {
                return @"Discount";
            }
            else if([receipt.discount integerValue] == 2)//discountType = Percent
            {
                return [NSString stringWithFormat:@"Disc (%@\uFF05)",receipt.discountPercent];
            }
        }
    }
    
    return @"Discount";
}

- (float)getTotalAmountByReceipt:(Receipt *)receipt
{
    NSMutableArray *receiptProductItemList = [ReceiptProductItem getReceiptProductItemWithReceiptID:receipt.receiptID receiptProductItemList:selectedReceiptProductItemList];
    receiptProductItemList = [ReceiptProductItem getReceiptProductItemSortByProductNameColorSize:receiptProductItemList];

    
    float sum = 0;
    for(ReceiptProductItem *item in receiptProductItemList)
    {
        sum += [item.priceSales floatValue];
    }
    return sum;
}

- (float)getDiscountByReceipt:(Receipt *)receipt
{
    float discountValue=0;
    if(receipt.discount == 0)
    {
        discountValue = 0;
    }
    else if([receipt.discount integerValue] == 1)
    {
        discountValue = [receipt.discountValue floatValue];
    }
    else if([receipt.discount integerValue] == 2)
    {
        discountValue = [receipt.payPrice floatValue]/(100-[receipt.discountPercent floatValue])*[receipt.discountPercent floatValue];
    }
    return discountValue;
}

- (float)getTotalAmountAfterDiscountByReceipt:(Receipt *)receipt
{
    return [self getTotalAmountByReceipt:receipt]-[self getDiscountByReceipt:receipt];
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

- (void)itemsUpdated
{
}

-(void)itemsDownloaded:(NSArray *)items
{
    if(_homeModel.propCurrentDB == dbMaster)
    {
        [Utility itemsDownloaded:items];
        [self removeOverlayViews];
        [self loadViewProcess];
    }
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

@end
