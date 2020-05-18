//
//  CompareInventoryBySetViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/3/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "CompareInventoryBySetViewController.h"
#import "CustomUICollectionViewCellButton.h"
#import "Utility.h"
#import "SharedSelectedEvent.h"
#import "ComparingScanViewController.h"
#import "SharedCompareInventory.h"
#import "CompareInventory.h"
#import "QRCodeImageViewController.h"
#import "CustomUICollectionReusableView.h"
#import "ProductName.h"


#define orangeColor         [UIColor colorWithRed:253/255.0 green:182/255.0 blue:103/255.0 alpha:1]
#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]

@interface CompareInventoryBySetViewController ()<UISearchBarDelegate>
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSArray *_productItemList;
    NSArray *_compareInventoryList;
    NSMutableArray *_mutArrCompareInventoryList;
    NSInteger _selectedIndexPathForRow;
    NSString *_productCode;
}
@property (nonatomic,strong) NSArray        *dataSource;
@property (nonatomic,strong) NSArray        *dataSourceForSearchResult;
@property (nonatomic)        BOOL           searchBarActive;
@property (nonatomic)        float          searchBarBoundsY;
@end

@implementation CompareInventoryBySetViewController
static NSString * const reuseIdentifier = @"Cell";
static NSString * const reuseHeaderViewIdentifier = @"HeaderView";
static NSString * const reuseFooterViewIdentifier = @"FooterView";
@synthesize colViewProductItem;
@synthesize lblLocation;
@synthesize runningSetNo;
@synthesize eventName;
- (IBAction)unwindToCompareInventoryBySet:(UIStoryboardSegue *)segue{}
- (void)loadView {
    [super loadView];
    // Do any additional setup after loading the view.
    
    // Create new HomeModel object and assign it to _homeModel variable
    _homeModel = [[HomeModel alloc] init];
    _homeModel.delegate = self;
    
    {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);
    }
    
    
    self.navigationItem.title = [NSString stringWithFormat:@"Compare Inventory Summary"];
    lblLocation.text = [NSString stringWithFormat:@"Location: %@",eventName];
    lblLocation.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    lblLocation.textColor = [UIColor purpleColor];
    
    
    self.searchBar.delegate = self;
    
    
    [self loadViewProcess];
}

-(void)loadViewProcess
{
    _mutArrCompareInventoryList = [SharedCompareInventory sharedCompareInventory].compareInventoryList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_runningSetNo = %@",runningSetNo];
    NSArray *arrFilter = [_mutArrCompareInventoryList filteredArrayUsingPredicate:predicate1];
    _mutArrCompareInventoryList = [arrFilter mutableCopy];
    
    [self setData];
}

-(void)setData
{
    if(self.searchBarActive)
    {
        _compareInventoryList = self.dataSourceForSearchResult;
    }
    else
    {
        _compareInventoryList = _mutArrCompareInventoryList;
    }
    
    
    for(CompareInventory *item in _compareInventoryList)
    {
        Product *product = [Utility getProductWithProductCode:item.productCode];
        NSString *productNameGroup = [NSString stringWithFormat:@"%@%@%@",product.productCategory2,product.productCategory1,product.productName];
        
        item.productName = [ProductName getNameWithProductNameGroup:productNameGroup];
        item.color = [Utility getColorName:product.color];
        item.size = [Utility getSizeLabel:product.size];
        item.sizeOrder = [Utility getSizeOrder:product.size];
        
        item.checkOrUnCheck = [item.compareStatus isEqualToString:@"M"] || [item.compareStatus isEqualToString:@"D"]?@"CMark":@"XMark";
    }
    
    
    for(CompareInventory *item in _compareInventoryList)
    {
        //M,D,W,V,N
        if([item.compareStatus isEqualToString:@"M"])
        {
            item.compareStatusForSort = 1;
        }
        else if([item.compareStatus isEqualToString:@"D"])
        {
            item.compareStatusForSort = 2;
        }
        else if([item.compareStatus isEqualToString:@"W"])
        {
            item.compareStatusForSort = 3;
        }
        else if([item.compareStatus isEqualToString:@"V"])
        {
            item.compareStatusForSort = 4;
        }
        else if([item.compareStatus isEqualToString:@"N"])
        {
            item.compareStatusForSort = 5;
        }
    }
    NSArray *arrSort1;
    NSArray *arrSort2;
    NSArray *arrAll;
    {
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_compareStatus = %@ or _compareStatus = %@ or _compareStatus = %@  or _compareStatus = %@ or _compareStatus = %@",@"M",@"N",@"W",@"D",@"V"];
        NSArray *arrFilter1 = [_compareInventoryList filteredArrayUsingPredicate:predicate1];
        
        //sort
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_productName" ascending:YES];
        NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_color" ascending:YES];
        NSSortDescriptor *sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:@"_sizeOrder" ascending:YES];
        NSSortDescriptor *sortDescriptor4 = [[NSSortDescriptor alloc] initWithKey:@"_compareStatusForSort" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2,sortDescriptor3,sortDescriptor4, nil];
        arrSort1 = [arrFilter1 sortedArrayUsingDescriptors:sortDescriptors];
    }
    
    {
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_compareStatus = %@ or _compareStatus = %@",@"E",@"F"];
        NSArray *arrFilter1 = [_compareInventoryList filteredArrayUsingPredicate:predicate1];
        
        //sort
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_productName" ascending:YES];
        NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_color" ascending:YES];
        NSSortDescriptor *sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:@"_sizeOrder" ascending:YES];
        NSSortDescriptor *sortDescriptor4 = [[NSSortDescriptor alloc] initWithKey:@"_compareStatus" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2,sortDescriptor3,sortDescriptor4, nil];
        arrSort2 = [arrFilter1 sortedArrayUsingDescriptors:sortDescriptors];
    }
    
    arrAll = [arrSort1 arrayByAddingObjectsFromArray:arrSort2];
    _compareInventoryList = [arrAll mutableCopy];
    
    
    int i=0;
    for(CompareInventory *item in _compareInventoryList)
    {
        i +=1;
        item.row = [NSString stringWithFormat:@"%d", i];
    }
    
    [colViewProductItem reloadData];
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
    NSInteger rowNo;
    if (self.searchBarActive)
    {
        rowNo = self.dataSourceForSearchResult.count;
    }
    else
    {
        rowNo = [_compareInventoryList count];
    }
    
    NSInteger countColumn = 6;
    return (rowNo+1)*countColumn;
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
    
    NSArray *header = @[@"No",@"Item",@"Color",@"Size",@"QR",@"Status"];
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
        CompareInventory *compareInventory = (CompareInventory *)_compareInventoryList[item/countColumn-1];
        switch (item%countColumn) {
            case 0:
            {
                cell.label.text = compareInventory.row;
            }
                break;
            case 1:
            {
                cell.label.text = compareInventory.productName;
            }
                break;
            case 2:
            {
                cell.label.text = compareInventory.color;
            }
                break;
            case 3:
            {
                cell.label.text = compareInventory.size;
            }
                break;
            case 4:
            {
                cell.imageView.image = [UIImage imageNamed:@"qrcode icon.png"];
                cell.imageView.userInteractionEnabled = YES;
                [cell addSubview:cell.imageView];
                
                CGRect frame = cell.bounds;
                NSInteger imageSize = 26;
                frame.origin.x = (frame.size.width-imageSize)/2;
                frame.origin.y = (frame.size.height-imageSize)/2;
                frame.size.width = imageSize;
                frame.size.height = imageSize;
                cell.imageView.frame = frame;
                
                cell.imageView.tag = item;
                [cell.singleTap removeTarget:self action:@selector(showQRCodeImage:)];
                [cell.singleTap addTarget:self action:@selector(showQRCodeImage:)];
                cell.singleTap.numberOfTapsRequired = 1;
                cell.singleTap.numberOfTouchesRequired = 1;
                [cell.imageView addGestureRecognizer:cell.singleTap];
                
                [cell addSubview:cell.leftBorder];
                [cell addSubview:cell.topBorder];
                [cell addSubview:cell.rightBorder];
                [cell addSubview:cell.bottomBorder];
            }
                break;
            case 5:
            {
                if([compareInventory.compareStatus isEqualToString:@"N"])
                {
                    cell.imageView.image = [UIImage imageNamed:@"cross.png"];
                    cell.imageView.userInteractionEnabled = YES;
                    [cell addSubview:cell.imageView];
                    
                    CGRect frame = cell.bounds;
                    NSInteger imageSize = 16;
                    frame.origin.x = (frame.size.width-imageSize)/2;
                    frame.origin.y = (frame.size.height-imageSize)/2;
                    frame.size.width = imageSize;
                    frame.size.height = imageSize;
                    cell.imageView.frame = frame;
                }
                else if([compareInventory.compareStatus isEqualToString:@"M"])
                {
                    cell.imageView.image = [UIImage imageNamed:@"check.png"];
                    cell.imageView.userInteractionEnabled = YES;
                    [cell addSubview:cell.imageView];
                    
                    CGRect frame = cell.bounds;
                    NSInteger imageSize = 16;
                    frame.origin.x = (frame.size.width-imageSize)/2;
                    frame.origin.y = (frame.size.height-imageSize)/2;
                    frame.size.width = imageSize;
                    frame.size.height = imageSize;
                    cell.imageView.frame = frame;
                }
                else if([compareInventory.compareStatus isEqualToString:@"D"])
                {
                    [cell addSubview:cell.label];
                    cell.label.frame = cell.bounds;
                    cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                    cell.label.textColor= tBlueColor;
                    cell.label.backgroundColor = [UIColor clearColor];
                    cell.label.text = @"Match (duplicate)";
                }
                else if([compareInventory.compareStatus isEqualToString:@"W"])
                {
                    [cell addSubview:cell.label];
                    cell.label.frame = cell.bounds;
                    cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                    cell.label.textColor= tBlueColor;
                    cell.label.backgroundColor = [UIColor clearColor];
                    cell.label.text = @"Match, wrong MFD";
                }
                else if([compareInventory.compareStatus isEqualToString:@"V"])
                {
                    [cell addSubview:cell.label];
                    cell.label.frame = cell.bounds;
                    cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                    cell.label.textColor= tBlueColor;
                    cell.label.backgroundColor = [UIColor clearColor];
                    cell.label.text = @"Match, wrong MFD (duplicate)";
                }
                else if([compareInventory.compareStatus isEqualToString:@"E"])
                {
                    [cell addSubview:cell.label];
                    cell.label.frame = cell.bounds;
                    cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                    cell.label.textColor= [UIColor redColor];
                    cell.label.backgroundColor = [UIColor clearColor];
                    cell.label.text = @"Extra product";
                }
                else if([compareInventory.compareStatus isEqualToString:@"F"])
                {
                    [cell addSubview:cell.label];
                    cell.label.frame = cell.bounds;
                    cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                    cell.label.textColor= [UIColor redColor];
                    cell.label.backgroundColor = [UIColor clearColor];
                    cell.label.text = @"Extra product (duplicate)";
                }
                
                [cell addSubview:cell.leftBorder];
                [cell addSubview:cell.topBorder];
                [cell addSubview:cell.rightBorder];
                [cell addSubview:cell.bottomBorder];
            }
                break;
            
            default:
                break;
        }
    }
    
    return cell;
}

- (void) showQRCodeImage:(UIGestureRecognizer *)gestureRecognizer
{
    NSInteger countColumn = 6;
    UIView* view = gestureRecognizer.view;
    
    _selectedIndexPathForRow = view.tag;
    CompareInventory *compareInventory = ((CompareInventory*)_compareInventoryList[_selectedIndexPathForRow/countColumn-1]);
    _productCode = compareInventory.productCode;
    
    [self performSegueWithIdentifier:@"segQRCodeImage" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segQRCodeImage"])
    {
        QRCodeImageViewController *vc = segue.destinationViewController;
        vc.productCode = _productCode;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width;
    NSInteger countColumn = 6;
    
    //    [@"No",@"Item",@"Color",@"Size",@"Status",@"QR Code"];
    switch (indexPath.item%countColumn) {
        case 0:
            width = 30;
            break;
//        case 2:
//            width = 30;
//            break;
        case 3:
            width = 30;
            break;
        case 4:
            width = 40;
            break;
        case 5:
            width = 110;
            break;
            
        default:
            width = (colViewProductItem.bounds.size.width - 40-30-30-40-110)/2;
            break;
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
- (NSInteger)getCMark
{
    NSArray *dataList = self.searchBarActive?self.dataSourceForSearchResult:_compareInventoryList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_checkOrUnCheck = %@",@"CMark"];
    NSArray *filterArray = [dataList filteredArrayUsingPredicate:predicate1];
    return [filterArray count];
}
- (NSInteger)getXMark
{
    NSArray *dataList = self.searchBarActive?self.dataSourceForSearchResult:_compareInventoryList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_checkOrUnCheck = %@",@"XMark"];
    NSArray *filterArray = [dataList filteredArrayUsingPredicate:predicate1];
    return [filterArray count];
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        CustomUICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        {
            CGRect frame2 = headerView.bounds;
            frame2.origin.x = 20;
            frame2.size.width = frame2.size.width - 20;
            headerView.label.frame = frame2;
            headerView.label.textAlignment = NSTextAlignmentLeft;
            NSString *strLabel = [NSString stringWithFormat:@"CMark/XMark:%ld/%ld",[self getCMark],[self getXMark]];
            headerView.label.text = strLabel;
            [headerView addSubview:headerView.label];
            [self setLabelUnderline:headerView.label underline:headerView.viewUnderlineLeft];
        }
        {
            CGRect frame2 = headerView.bounds;
            frame2.size.width = frame2.size.width - 20;
            headerView.labelAlignRight.frame = frame2;
            headerView.labelAlignRight.textAlignment = NSTextAlignmentRight;
            NSString *strCountItem = [NSString stringWithFormat:@"%ld",self.searchBarActive?self.dataSourceForSearchResult.count:[_compareInventoryList count]];
            strCountItem = [Utility formatBaht:strCountItem];
            headerView.labelAlignRight.text = strCountItem;
            [headerView addSubview:headerView.labelAlignRight];
            [self setLabelUnderline:headerView.labelAlignRight underline:headerView.viewUnderline];
        }
        
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
//    CGSize expectedLabelSize = [label.text sizeWithFont:label.font constrainedToSize:label.frame.size lineBreakMode:label.lineBreakMode];
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
#pragma mark - search
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
    NSPredicate *resultPredicate    = [NSPredicate predicateWithFormat:@"_productName contains[c] %@ || _color contains[c] %@ || _size contains[c] %@ || _checkOrUnCheck contains[c] %@", searchText,searchText,searchText,searchText];
    self.dataSourceForSearchResult = [_mutArrCompareInventoryList filteredArrayUsingPredicate:resultPredicate];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    // user did type something, check our datasource for text that looks the same
    if (searchText.length>0)
    {
        // search and reload data source
        self.searchBarActive = YES;
        [self filterContentForSearchText:searchText scope:@""];
        [self setData];
    }
    else{
        // if text lenght == 0
        // we will consider the searchbar is not active
        //        self.searchBarActive = NO;
        
        [self cancelSearching];
        [self setData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self cancelSearching];
    [self setData];
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
