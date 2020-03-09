//
//  MemberAndPointViewController.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 2/19/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import "MemberAndPointViewController.h"
#import "MemberReceiptViewController.h"
#import "CustomUICollectionViewCellButton2.h"
#import "CustomUICollectionReusableView.h"
#import "PushSync.h"
#import "SharedPushSync.h"
#import "Utility.h"
#import "MemberAndPoint.h"
#import "Receipt.h"
#import "SharedReceipt.h"
#import "SharedReceiptItem.h"


#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]


@interface MemberAndPointViewController ()<UISearchBarDelegate>
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSInteger defaultFontSize;
    NSMutableArray *_memberAndPointList;
    NSMutableArray *_sumAndAvgAllList;
    NSMutableArray *_sumAndAvgTop20PercentList;
    NSMutableArray *_booAscending;
    NSMutableArray *_selectedReceiptList;
    NSMutableArray *_selectedReceiptProductItemList;
    MemberAndPoint *_selectedMemberAndPoint;
    NSMutableArray *_mutArrProductSalesList;
}

@property (nonatomic,strong) NSArray        *dataSource;
@property (nonatomic,strong) NSArray        *dataSourceForSearchResult;
@property (nonatomic)        BOOL           searchBarActive;
@property (nonatomic)        float          searchBarBoundsY;
@end


@implementation MemberAndPointViewController

static NSString * const reuseIdentifier = @"Cell";
static NSString * const reuseHeaderViewIdentifier = @"HeaderView";
static NSString * const reuseFooterViewIdentifier = @"FooterView";


@synthesize colViewData;

- (void)itemsDownloaded:(NSArray *)items
{
    if(_homeModel.propCurrentDB == dbMemberAndPoint)
    {
        [self removeOverlayViews];
        int i=0;
        _memberAndPointList = items[i++];
        _sumAndAvgAllList = items[i++];
        _sumAndAvgTop20PercentList = items[i++];
        
        
        [colViewData reloadData];
    }
    else if(_homeModel.propCurrentDB == dbReceiptByMember)
    {
        [self removeOverlayViews];
        int i=0;
        _selectedReceiptList = items[i++];
        _selectedReceiptProductItemList = items[i++];

        
        [self performSegueWithIdentifier:@"segMemberReceipt" sender:self];
    }
}

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
    
    
    
    NSArray *arrAscending = @[@NO,@NO,@NO,@NO,@NO];
    _booAscending = [arrAscending mutableCopy];
    
    
    
    self.dataSourceForSearchResult = [NSArray new];
    self.searchBar.delegate = self;
    
    
    
    [self loadingOverlayView];
    [_homeModel downloadItems:dbMemberAndPoint condition:@""];
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

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 3;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger noOfItems = 0;
    NSInteger countColumn = 5;
    if(section == 0)
    {        
        noOfItems = ([_memberAndPointList count]+1)*countColumn;
    }
    else if(section == 1)
    {
        noOfItems = (2+1)*countColumn;
    }
    else if(section == 2)
    {
        noOfItems = (2+1)*countColumn;
    }
    
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
    
    
    [cell.leftBorder removeFromSuperview];
    [cell.topBorder removeFromSuperview];
    [cell.rightBorder removeFromSuperview];
    [cell.bottomBorder removeFromSuperview];
    
    
    
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
    [cell addSubview:cell.topBorder];
    [cell addSubview:cell.bottomBorder];
    [cell addSubview:cell.leftBorder];
    [cell addSubview:cell.rightBorder];
    
    NSInteger item = indexPath.item;
    NSInteger section = indexPath.section;
    if(section == 0)
    {
        NSArray *header = @[@"No.",@"Name/Phone no.",@"Point all",@"PT spent",@"PT remain."];
        NSInteger countColumn = [header count];
        
        if(item == 0)
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
        else if(item/countColumn==0)
        {
            NSInteger remainder = item%countColumn;
            [cell addSubview:cell.buttonDetail];
            cell.buttonDetail.frame = cell.bounds;
            [cell.buttonDetail setTitle:header[remainder] forState:UIControlStateNormal];
            [cell.buttonDetail setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [cell.buttonDetail setBackgroundColor:tBlueColor];
            cell.buttonDetail.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:defaultFontSize];
            cell.buttonDetail.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
            cell.buttonDetail.tag = item;
            [cell.buttonDetail removeTarget:nil
                                     action:NULL
                           forControlEvents:UIControlEventAllEvents];
            [cell.buttonDetail addTarget:self action:@selector(sortColumn:)
                        forControlEvents:UIControlEventTouchUpInside];
            
            
            if(item == 1)
            {
                cell.buttonDetail.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            }
            else if(item == 2 || item == 3 || item == 4)
            {
                cell.buttonDetail.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            }
        }
        else if(item%countColumn == 0 || item%countColumn == 2 || item%countColumn == 3 || item%countColumn == 4)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:defaultFontSize];
            cell.label.textColor= [UIColor blackColor];
            cell.label.backgroundColor = [UIColor clearColor];
            
            MemberAndPoint *memberAndPoint = _memberAndPointList[item/countColumn-1];
            switch (item%countColumn) {
                case 0:
                {
                    cell.label.textAlignment = NSTextAlignmentCenter;
                    cell.label.text = [NSString stringWithFormat:@"%ld",item/countColumn];
                }
                    break;
                case 2:
                {
                    NSString *strPointAllTime = [NSString stringWithFormat:@"%ld",(long)memberAndPoint.pointAllTime];
                    cell.label.textAlignment = NSTextAlignmentRight;
                    cell.label.text = [Utility formatBaht:strPointAllTime withMinFraction:0 andMaxFraction:0];
                }
                    break;
                case 3:
                {
                    NSString *strPointSpent = [NSString stringWithFormat:@"%ld",(long)memberAndPoint.pointSpent];
                    cell.label.textAlignment = NSTextAlignmentRight;
                    cell.label.text = [Utility formatBaht:strPointSpent withMinFraction:0 andMaxFraction:0];
                }
                    break;
                case 4:
                {
                    NSString *strPointRemaining = [NSString stringWithFormat:@"%ld",(long)memberAndPoint.pointRemaining];
                    cell.label.textAlignment = NSTextAlignmentRight;
                    cell.label.text = [Utility formatBaht:strPointRemaining withMinFraction:0 andMaxFraction:0];
                }
                    break;
                default:
                    break;
            }
        }
        else if(item%countColumn == 1)
        {
            MemberAndPoint *memberAndPoint = _memberAndPointList[item/countColumn-1];
            [cell addSubview:cell.buttonDetail];
            cell.buttonDetail.frame = cell.bounds;
            cell.buttonDetail.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.buttonDetail.titleLabel.numberOfLines = 2;//if you want unlimited number of lines put 0
            NSString *nameAndPhoneNo = [NSString stringWithFormat:@"%@\r%@",memberAndPoint.name,[Utility setPhoneNoFormat:memberAndPoint.phoneNo]];
            [cell.buttonDetail setTitle:[Utility setPhoneNoFormat:nameAndPhoneNo] forState:UIControlStateNormal];
            [cell.buttonDetail setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [cell.buttonDetail setBackgroundColor:[UIColor clearColor]];
            cell.buttonDetail.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:defaultFontSize];
            cell.buttonDetail.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
            cell.buttonDetail.tag = item;
            [cell.buttonDetail removeTarget:nil
                                     action:NULL
                           forControlEvents:UIControlEventAllEvents];
            [cell.buttonDetail addTarget:self action:@selector(viewMemberReceipt:)
                        forControlEvents:UIControlEventTouchUpInside];
            cell.buttonDetail.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        }
    }
    else if(section == 1)
    {
        NSArray *header = @[@"No.",@"All member",@"Point all",@"PT spent",@"PT remain."];
        NSInteger countColumn = [header count];
        
        if(item/countColumn == 0)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:defaultFontSize];
            cell.label.textColor = [UIColor whiteColor];
            cell.label.backgroundColor = tBlueColor;
            if(item == 0)
            {
                cell.label.textAlignment = NSTextAlignmentCenter;
            }
            else if(item == 1)
            {
                cell.label.textAlignment = NSTextAlignmentLeft;
            }
            else if(item == 2 || item == 3 || item == 4)
            {
                cell.label.textAlignment = NSTextAlignmentRight;
            }
            
            NSInteger remainder = item%countColumn;
            cell.label.text = header[remainder];
        }
        else if(item == 5)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:defaultFontSize];
            cell.label.textColor= [UIColor blackColor];
            cell.label.backgroundColor = [UIColor clearColor];
            cell.label.textAlignment = NSTextAlignmentCenter;
            cell.label.text = @"1";
        }
        else if(item == 6)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:defaultFontSize];
            cell.label.textColor= [UIColor blackColor];
            cell.label.backgroundColor = [UIColor clearColor];
            cell.label.textAlignment = NSTextAlignmentLeft;
            cell.label.text = @"Sum";
        }
        else if(item == 7 || item == 8 || item == 9)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:defaultFontSize];
            cell.label.textColor= [UIColor blackColor];
            cell.label.backgroundColor = [UIColor clearColor];
            cell.label.textAlignment = NSTextAlignmentRight;
            
            MemberAndPoint *memberAndPoint = _sumAndAvgAllList[0];
            if(item == 7)
            {
                NSString *strPointAllTime = [NSString stringWithFormat:@"%ld",(long)memberAndPoint.sumPointAllTime];
                cell.label.text = [Utility formatBaht:strPointAllTime withMinFraction:0 andMaxFraction:0];
            }
            else if(item == 8)
            {
                NSString *strPointSpent = [NSString stringWithFormat:@"%ld",(long)memberAndPoint.sumPointSpent];
                cell.label.text = [Utility formatBaht:strPointSpent withMinFraction:0 andMaxFraction:0];
            }
            else if(item == 9)
            {
                NSString *strPointRemaining = [NSString stringWithFormat:@"%ld",(long)memberAndPoint.sumPointRemaining];
                cell.label.text = [Utility formatBaht:strPointRemaining withMinFraction:0 andMaxFraction:0];
            }
        }
        else if(item == 10)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:defaultFontSize];
            cell.label.textColor= [UIColor blackColor];
            cell.label.backgroundColor = [UIColor clearColor];
            cell.label.textAlignment = NSTextAlignmentCenter;
            cell.label.text = @"2";
        }
        else if(item == 11)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:defaultFontSize];
            cell.label.textColor= [UIColor blackColor];
            cell.label.backgroundColor = [UIColor clearColor];
            cell.label.textAlignment = NSTextAlignmentLeft;
            cell.label.text = @"Avg";
        }
        else if(item == 12 || item == 13 || item == 14)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:defaultFontSize];
            cell.label.textColor= [UIColor blackColor];
            cell.label.backgroundColor = [UIColor clearColor];
            cell.label.textAlignment = NSTextAlignmentRight;
            
            MemberAndPoint *memberAndPoint = _sumAndAvgAllList[0];
            if(item == 12)
            {
                NSString *strPointAllTime = [NSString stringWithFormat:@"%ld",(long)memberAndPoint.avgPointAllTime];
                cell.label.text = [Utility formatBaht:strPointAllTime withMinFraction:0 andMaxFraction:0];
            }
            else if(item == 13)
            {
                NSString *strPointSpent = [NSString stringWithFormat:@"%ld",(long)memberAndPoint.avgPointSpent];
                cell.label.text = [Utility formatBaht:strPointSpent withMinFraction:0 andMaxFraction:0];
            }
            else if(item == 14)
            {
                NSString *strPointRemaining = [NSString stringWithFormat:@"%ld",(long)memberAndPoint.avgPointRemaining];
                cell.label.text = [Utility formatBaht:strPointRemaining withMinFraction:0 andMaxFraction:0];
            }
        }
    }
    else if(section == 2)
    {
        NSArray *header = @[@"No.",@"Top 20%",@"Point all",@"PT spent",@"PT remain."];
        NSInteger countColumn = [header count];
        
        if(item/countColumn == 0)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:defaultFontSize];
            cell.label.textColor = [UIColor whiteColor];
            cell.label.backgroundColor = tBlueColor;
            if(item == 0)
            {
                cell.label.textAlignment = NSTextAlignmentCenter;
            }
            else if(item == 1)
            {
                cell.label.textAlignment = NSTextAlignmentLeft;
            }
            else if(item == 2 || item == 3 || item == 4)
            {
                cell.label.textAlignment = NSTextAlignmentRight;
            }
            
            NSInteger remainder = item%countColumn;
            cell.label.text = header[remainder];
        }
        else if(item == 5)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:defaultFontSize];
            cell.label.textColor= [UIColor blackColor];
            cell.label.backgroundColor = [UIColor clearColor];
            cell.label.textAlignment = NSTextAlignmentCenter;
            cell.label.text = @"2";
        }
        else if(item == 6)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:defaultFontSize];
            cell.label.textColor= [UIColor blackColor];
            cell.label.backgroundColor = [UIColor clearColor];
            cell.label.textAlignment = NSTextAlignmentLeft;
            cell.label.text = @"Sum";
        }
        else if(item == 7 || item == 8 || item == 9)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:defaultFontSize];
            cell.label.textColor= [UIColor blackColor];
            cell.label.backgroundColor = [UIColor clearColor];
            cell.label.textAlignment = NSTextAlignmentRight;
            
            MemberAndPoint *memberAndPoint = _sumAndAvgTop20PercentList[0];
            if(item == 7)
            {
                NSString *strPointAllTime = [NSString stringWithFormat:@"%ld",(long)memberAndPoint.sumPointAllTime];
                cell.label.text = [Utility formatBaht:strPointAllTime withMinFraction:0 andMaxFraction:0];
            }
            else if(item == 8)
            {
                NSString *strPointSpent = [NSString stringWithFormat:@"%ld",(long)memberAndPoint.sumPointSpent];
                cell.label.text = [Utility formatBaht:strPointSpent withMinFraction:0 andMaxFraction:0];
            }
            else if(item == 9)
            {
                NSString *strPointRemaining = [NSString stringWithFormat:@"%ld",(long)memberAndPoint.sumPointRemaining];
                cell.label.text = [Utility formatBaht:strPointRemaining withMinFraction:0 andMaxFraction:0];
            }
        }
        else if(item == 10)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:defaultFontSize];
            cell.label.textColor= [UIColor blackColor];
            cell.label.backgroundColor = [UIColor clearColor];
            cell.label.textAlignment = NSTextAlignmentCenter;
            cell.label.text = @"2";
        }
        else if(item == 11)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:defaultFontSize];
            cell.label.textColor= [UIColor blackColor];
            cell.label.backgroundColor = [UIColor clearColor];
            cell.label.textAlignment = NSTextAlignmentLeft;
            cell.label.text = @"Avg";
        }
        else if(item == 12 || item == 13 || item == 14)
        {
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:defaultFontSize];
            cell.label.textColor= [UIColor blackColor];
            cell.label.backgroundColor = [UIColor clearColor];
            cell.label.textAlignment = NSTextAlignmentRight;
            
            MemberAndPoint *memberAndPoint = _sumAndAvgTop20PercentList[0];
            if(item == 12)
            {
                NSString *strPointAllTime = [NSString stringWithFormat:@"%ld",(long)memberAndPoint.avgPointAllTime];
                cell.label.text = [Utility formatBaht:strPointAllTime withMinFraction:0 andMaxFraction:0];
            }
            else if(item == 13)
            {
                NSString *strPointSpent = [NSString stringWithFormat:@"%ld",(long)memberAndPoint.avgPointSpent];
                cell.label.text = [Utility formatBaht:strPointSpent withMinFraction:0 andMaxFraction:0];
            }
            else if(item == 14)
            {
                NSString *strPointRemaining = [NSString stringWithFormat:@"%ld",(long)memberAndPoint.avgPointRemaining];
                cell.label.text = [Utility formatBaht:strPointRemaining withMinFraction:0 andMaxFraction:0];
            }
        }
    }
    return cell;
}

- (void)viewMemberReceipt:(id)sender
{
    UIButton *button = sender;
    NSInteger item = button.tag;
    NSInteger countColumn = 5;
    _selectedMemberAndPoint = _memberAndPointList[item/countColumn-1];

    
    [self loadingOverlayView];
    NSString *strCustomerID = [NSString stringWithFormat:@"%ld",_selectedMemberAndPoint.customerID];
    [_homeModel downloadItems:dbReceiptByMember condition:strCustomerID];
}
//
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"segMemberReceipt"])
    {
        MemberReceiptViewController *vc = segue.destinationViewController;
        vc.selectedReceiptList = _selectedReceiptList;
        vc.selectedReceiptProductItemList = _selectedReceiptProductItemList;
        vc.selectedMemberAndPoint = _selectedMemberAndPoint;
    }
}

- (void)sortColumn:(id)sender
{
    UIButton *button = sender;
    NSInteger item = button.tag;
    NSArray *headerSortColumn = @[@"ลำดับ",@"_phoneNo",@"_pointAllTime",@"_pointSpent",@"_pointRemaining"];
    
    BOOL ascending = ![_booAscending[item] boolValue];
    [_booAscending replaceObjectAtIndex:item withObject:[NSNumber numberWithBool:ascending]];
    
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:headerSortColumn[item] ascending:ascending];
    NSArray *sortDescriptors1 = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortedArray = [_memberAndPointList sortedArrayUsingDescriptors:sortDescriptors1];
    _memberAndPointList = [sortedArray mutableCopy];
    
    
    [colViewData reloadData];
}

#pragma mark <UICollectionViewDelegate>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize size;
    CGFloat width = 0.0;
    NSArray *arrSize;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        arrSize = @[@35,@0,@100,@100,@100];
        
        width = [arrSize[indexPath.item%[arrSize count]] floatValue];
        if(width == 0)
        {
            width = colViewData.bounds.size.width;
            for(int i=0; i<[arrSize count]; i++)
            {
                width = width - [arrSize[i] floatValue];
            }
        }
        
        size = CGSizeMake(width, 30);
    }
    else
    {
        arrSize = @[@26,@0,@70,@70,@70];
        
        width = [arrSize[indexPath.item%[arrSize count]] floatValue];
        if(width == 0)
        {
            width = colViewData.bounds.size.width;
            for(int i=0; i<[arrSize count]; i++)
            {
                width = width - [arrSize[i] floatValue];
            }
        }
        if(indexPath.section == 0)
        {
            size = CGSizeMake(width, 40);
        }
        else
        {
            size = CGSizeMake(width, 20);
        }
        
    }
    return size;
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    {
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)colViewData.collectionViewLayout;
        
        [layout invalidateLayout];
        [colViewData reloadData];
    }
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
        
//        NSString *strCountItem = [NSString stringWithFormat:@"%ld",self.searchBarActive?self.dataSourceForSearchResult.count:[_memberAndPointList count]];
        NSString *strCountItem = [NSString stringWithFormat:@"%ld",[_memberAndPointList count]];
        strCountItem = [Utility formatBaht:strCountItem];
        headerView.labelAlignRight.text = strCountItem;
        [headerView.labelAlignRight setFont:[UIFont fontWithName:@"HelveticaNeue-light" size:defaultFontSize]];
        CGRect frameAlignRight = headerView.frame;
        frameAlignRight.size.height = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad?30:20;
        frameAlignRight.size.width = frameAlignRight.size.width;
        headerView.labelAlignRight.frame = frameAlignRight;
        headerView.labelAlignRight.textAlignment = NSTextAlignmentRight;
        [headerView addSubview:headerView.labelAlignRight];
        
        reusableview = headerView;
    }
    
    
    if (kind == UICollectionElementKindSectionFooter) {
        CustomUICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:reuseFooterViewIdentifier forIndexPath:indexPath];
        
        NSInteger colWidth = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad?100:70;
        
        {
            footerView.label.text = @"รวม";
            [footerView.label setFont:[UIFont fontWithName:@"HelveticaNeue-medium" size:defaultFontSize]];
            CGRect frame = footerView.frame;
            frame.origin.x = 0;
            frame.origin.y = 0;
            frame.size.height = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad?30:20;
            footerView.label.frame = frame;
            footerView.label.textAlignment = NSTextAlignmentLeft;
            [footerView addSubview:footerView.label];
        }
        
        
        {
            NSString *strPointAllTime = [NSString stringWithFormat:@"%ld",[self getTotalPointAllTime]];
            footerView.labelAlignRight.text = [Utility formatBaht:strPointAllTime withMinFraction:0 andMaxFraction:0];
            [footerView.labelAlignRight setFont:[UIFont fontWithName:@"HelveticaNeue-medium" size:defaultFontSize]];
            CGRect frameAlignRight = footerView.frame;
            frameAlignRight.origin.x = frameAlignRight.size.width - colWidth;
            frameAlignRight.origin.y = 0;
            frameAlignRight.size.height = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad?30:20;
            frameAlignRight.size.width = colWidth;
            footerView.labelAlignRight.frame = frameAlignRight;
            footerView.labelAlignRight.textAlignment = NSTextAlignmentRight;
            [footerView addSubview:footerView.labelAlignRight];
        }
        
        
        {
            NSString *strPointSpent = [NSString stringWithFormat:@"%ld",[self getTotalPointSpent]];
            footerView.labelAlignRight2.text = [Utility formatBaht:strPointSpent withMinFraction:0 andMaxFraction:0];
            [footerView.labelAlignRight2 setFont:[UIFont fontWithName:@"HelveticaNeue-medium" size:defaultFontSize]];
            CGRect frameAlignRight = footerView.frame;
            frameAlignRight.origin.x = frameAlignRight.size.width - 2*colWidth;
            frameAlignRight.origin.y = 0;
            frameAlignRight.size.height = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad?30:20;
            frameAlignRight.size.width = colWidth;
            footerView.labelAlignRight2.frame = frameAlignRight;
            footerView.labelAlignRight2.textAlignment = NSTextAlignmentRight;
            [footerView addSubview:footerView.labelAlignRight2];
        }
        
        
        {
            NSString *strPointRemaining = [NSString stringWithFormat:@"%ld",[self getTotalPointRemaining]];
            footerView.labelAlignRight3.text = [Utility formatBaht:strPointRemaining withMinFraction:0 andMaxFraction:0];
            [footerView.labelAlignRight3 setFont:[UIFont fontWithName:@"HelveticaNeue-medium" size:defaultFontSize]];
            CGRect frameAlignRight = footerView.frame;
            frameAlignRight.origin.x = frameAlignRight.size.width - 3*colWidth;
            frameAlignRight.origin.y = 0;
            frameAlignRight.size.height = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad?30:20;
            frameAlignRight.size.width = colWidth;
            footerView.labelAlignRight3.frame = frameAlignRight;
            footerView.labelAlignRight3.textAlignment = NSTextAlignmentRight;
            [footerView addSubview:footerView.labelAlignRight3];
        }
        
        
        reusableview = footerView;
    }
    
    return reusableview;
}

-(NSInteger)getTotalPointAllTime
{
    NSInteger sum = 0;
    for(MemberAndPoint *item in _memberAndPointList)
    {
        sum += item.pointAllTime;
    }
    return sum;
}

-(NSInteger)getTotalPointSpent
{
    NSInteger sum = 0;
    for(MemberAndPoint *item in _memberAndPointList)
    {
        sum += item.pointSpent;
    }
    return sum;
}

-(NSInteger)getTotalPointRemaining
{
    NSInteger sum = 0;
    for(MemberAndPoint *item in _memberAndPointList)
    {
        sum += item.pointRemaining;
    }
    return sum;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
{
    NSInteger headerHeight = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad?30:20;
    CGSize headerSize = CGSizeMake(collectionView.bounds.size.width, headerHeight);
    return headerSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
//    NSInteger footerHeight = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad?30:20;
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
                                                              
                                                          }];
    
    [alert addAction:defaultAction];
    dispatch_async(dispatch_get_main_queue(),^ {
        [self presentViewController:alert animated:YES completion:nil];
    } );
}

- (IBAction)sendEmail:(id)sender
{
    [self loadingOverlayView];
    [self exportImpl];
}

- (void) exportImpl
{
    NSArray* documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDir = [documentPaths objectAtIndex:0];
    NSString* csvPath = [documentsDir stringByAppendingPathComponent: @"export.csv"];
    
    
    [self exportCsv: csvPath];
    
    
    // mail is graphical and must be run on UI thread
    [self performSelectorOnMainThread: @selector(mail:) withObject: csvPath waitUntilDone: NO];
}

- (void) mail: (NSString*) filePath
{
    [self removeOverlayViews];
    BOOL success = NO;
    if ([MFMailComposeViewController canSendMail]) {
        // TODO: autorelease pool needed ?
        NSData* database = [NSData dataWithContentsOfFile: filePath];
        
        if (database != nil) {
            MFMailComposeViewController* picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self;
            [picker setSubject:@"File: Customer and point"];
            
            NSString* filename = [filePath lastPathComponent];
            [picker addAttachmentData: database mimeType:@"application/octet-stream" fileName: filename];
            NSString* emailBody = @"";
            [picker setMessageBody:emailBody isHTML:YES];
            
            
            [self presentViewController:picker animated:YES completion:nil];
            success = YES;
        }
    }
    
    if (!success)
    {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:@"Unable to send attachment!"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void) exportCsv: (NSString*) filename
{
    [self createTempFile: filename];
    NSOutputStream* output = [[NSOutputStream alloc] initToFileAtPath: filename append: YES];
    [output open];
    if (![output hasSpaceAvailable]) {
        NSLog(@"No space available in %@", filename);
        // TODO: UIAlertView?
    }
    else
    {
        NSString* header = @"No.,Phone no.,Point all time,PT spent,PT remain.";
        NSInteger result = [output write: [header UTF8String] maxLength: [header length]];
        if (result <= 0) {
            NSLog(@"exportCsv encountered error=%ld from header write", (long)result);
        }
        
        BOOL errorLogged = NO;
        
        {
            // Loop through the results and write them to the CSV file
            
            NSInteger rowNum = 0;
            for(MemberAndPoint *item in _memberAndPointList)
            {
                NSString *strRowNum = [NSString stringWithFormat:@"%ld",++rowNum];
                NSString *strTelNo = [Utility setPhoneNoFormat:item.phoneNo];
                NSString *strPointAllTime = [NSString stringWithFormat:@"%ld",item.pointAllTime];
                NSString *strPointSpent = [NSString stringWithFormat:@"%ld",item.pointSpent];
                NSString *strPointRemaining = [NSString stringWithFormat:@"%ld",item.pointRemaining];
                
                
                NSString* line = [[NSString alloc] initWithFormat: @"%@,%@,%@,%@,%@\n",
                                  strRowNum, strTelNo, strPointAllTime, strPointSpent, strPointRemaining];
                NSData *data = [line dataUsingEncoding:NSUTF8StringEncoding];
                result = [output write:[data bytes] maxLength:[data length]];
                
                
                if (!errorLogged && (result <= 0)) {
                    NSLog(@"exportCsv write returned %ld", (long)result);
                    errorLogged = YES;
                }
            }
        }
    }
    [output close];
}

-(void) createTempFile: (NSString*) filename {
    NSFileManager* fileSystem = [NSFileManager defaultManager];
    [fileSystem removeItemAtPath: filename error: nil];
    
    NSMutableDictionary* attributes = [[NSMutableDictionary alloc] init];
    NSNumber* permission = [NSNumber numberWithLong: 0640];
    [attributes setObject: permission forKey: NSFilePosixPermissions];
    if (![fileSystem createFileAtPath: filename contents: nil attributes: attributes]) {
        NSLog(@"Unable to create temp file for exporting CSV.");
        NSLog(@"Error was code: %d - message: %s", errno, strerror(errno));
        // TODO: UIAlertView?
    }
}

#pragma mark - search
//- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
//    NSPredicate *resultPredicate    = [NSPredicate predicateWithFormat:@"_productNameText contains[c] %@ || _colorText contains[c] %@ || _sizeText contains[c] %@ || _price contains[c] %@ || _cost contains[c] %@", searchText,searchText,searchText,searchText,searchText];
//    self.dataSourceForSearchResult  = [_mutArrProductSalesList filteredArrayUsingPredicate:resultPredicate];
//}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    // user did type something, check our datasource for text that looks the same
//    if (searchText.length>0)
    {
        // search and reload data source
        self.searchBarActive = YES;
        [_homeModel downloadItems:dbMemberAndPoint condition:searchBar.text];
//        [self filterContentForSearchText:searchText scope:@""];
//        [self setData];
    }
//    else
//    {
//        // if text lenght == 0
//        // we will consider the searchbar is not active
//        //        self.searchBarActive = NO;
//        
//        [self cancelSearching];
//        [self setData];
//    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self cancelSearching];
    [_homeModel downloadItems:dbMemberAndPoint condition:searchBar.text];
//    [self setData];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    self.searchBarActive = YES;
    [self.view endEditing:YES];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    // we used here to set self.searchBarActive = YES
    // but we'll not do that any more... it made problems
    // it's better to set self.searchBarActive = YES when user typed something
    [self.searchBar setShowsCancelButton:YES animated:YES];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    // this method is being called when search btn in the keyboard tapped
    // we set searchBarActive = NO
    // but no need to reloadCollectionView
    //    self.searchBarActive = NO;
    [self.searchBar setShowsCancelButton:NO animated:YES];
}
-(void)cancelSearching{
    self.searchBarActive = NO;
    [self.searchBar resignFirstResponder];
    self.searchBar.text  = @"";
}
@end
