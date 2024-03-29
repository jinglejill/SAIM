//
//  MainInventoryListViewControllerCollectionViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 8/26/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "MainInventoryItemViewController.h"
#import "Utility.h"
#import "CustomUICollectionViewCellButton2.h"
#import "CustomUICollectionReusableView.h"
#import "QRCodeImageViewController.h"
#import "ProductDelete.h"
#import "SharedProduct.h"
#import "SharedProductDelete.h"
#import "SharedPushSync.h"
#import "PushSync.h"
#import "ProductItem.h"
#import "ProductName.h"
#import "SharedProductName.h"
#import "SharedProductCategory2.h"
#import "SharedProductCategory1.h"
#import "SharedColor.h"
#import "SharedProductSize.h"



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



@interface MainInventoryItemViewController ()<UISearchBarDelegate>
{
//    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSArray *_productItemList;
    NSMutableArray *_mutArrProductItemList;
    NSMutableArray *_mutArrProductItemPortionList;
    NSMutableArray *_arrSectionDate;
    NSMutableArray *_arrOfSubProductItemList;
    UITextView *_txvDetail;
    NSMutableDictionary *_dicSectionDate;
    NSInteger _countScanProduct;
    NSString *_productCode;
    NSMutableDictionary *_countItemInSection;
    UIView *_viewUnderline;
    BOOL _firstPortion;
    BOOL _deleteItem;
    NSInteger _countPortion;
    NSDictionary *_selectedSectionAndItem;
    NSDictionary *_selectedSectionAndItemColumn1;
    
    ProductDelete *_productDelete;
    NSInteger _page;
    NSInteger _lastItemReached;
    
    
}
@property (nonatomic,strong) NSArray        *dataSource;
@property (nonatomic,strong) NSArray        *dataSourceForSearchResult;
@property (nonatomic)        BOOL           searchBarActive;
@property (nonatomic)        float          searchBarBoundsY;
@end

@implementation MainInventoryItemViewController

static NSString * const reuseIdentifier = @"Cell";
static NSString * const reuseHeaderViewIdentifier = @"HeaderView";
static NSString * const reuseFooterViewIdentifier = @"FooterView";
@synthesize colViewProductItem;
@synthesize btnAllOrRemaining;


- (void)loadView
{
    [super loadView];
    
}

-(void)addToMutArrProductItem:(NSArray *)productItemList
{
    for(int i=0; i<productItemList.count; i++)
    {
        ProductItem *productItem = productItemList[i];
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productID = %@",productItem.productID];
        NSArray *filterArray = [_mutArrProductItemList filteredArrayUsingPredicate:predicate1];
        if(filterArray.count == 0)
        {
            [_mutArrProductItemList addObject:productItem];
        }
    }
}

- (void)itemsDownloaded:(NSArray *)items
{
    [self removeOverlayViews];
    if(_page == 1)
    {
        [_mutArrProductItemList removeAllObjects];
    }
    
    
    int i=0;
    [self addToMutArrProductItem:items[i++]];

    
    if(self.searchBarActive)
    {
        _productItemList = self.dataSourceForSearchResult;
    }
    else
    {
        _productItemList = _mutArrProductItemList;
    }
    
    [colViewProductItem reloadData];
    
    
    if([items[0] count] < 40)
    {
        _lastItemReached = YES;
    }
    else
    {
        _page += 1;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)setData
{
    _arrSectionDate = [[NSMutableArray alloc]init];
    _arrOfSubProductItemList = [[NSMutableArray alloc]init];
    
    
    if(self.searchBarActive)
    {
        _productItemList = self.dataSourceForSearchResult;
    }
    else
    {
        _productItemList = _mutArrProductItemList;
    }
    
    [colViewProductItem reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Register cell classes
    [colViewProductItem registerClass:[CustomUICollectionViewCellButton2 class] forCellWithReuseIdentifier:reuseIdentifier];
    [colViewProductItem registerClass:[CustomUICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeaderViewIdentifier];
    [colViewProductItem registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:reuseFooterViewIdentifier];
    
    colViewProductItem.delegate = self;
    colViewProductItem.dataSource = self;
    
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
    
    
    self.searchBar.delegate = self;
    _deleteItem = NO;
    _mutArrProductItemList = [[NSMutableArray alloc]init];
    _dicSectionDate = [[NSMutableDictionary alloc]init];
    _selectedSectionAndItem = [[NSMutableDictionary alloc]init];
    _selectedSectionAndItemColumn1 = [[NSMutableDictionary alloc]init];
    _txvDetail = [[UITextView alloc]init];
    btnAllOrRemaining.title = @"All";
    _productDelete = [[ProductDelete alloc]init];
    

    [self loadingOverlayView];
    _page = 1;
    NSString *strPage = [NSString stringWithFormat:@"%ld",_page];
    [self.homeModel downloadItems:dbMainInventoryItem condition:@[@"0",@"0",strPage,_searchBar.text]];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    _arrSectionDate = [[NSMutableArray alloc]init];
    NSSet *uniqueSortDate = [NSSet setWithArray:[_productItemList valueForKey:@"sortDate"]];
    NSArray *arrSortDate = [uniqueSortDate allObjects];
    
    

    NSMutableArray *productItemSortDateList = [[NSMutableArray alloc]init];
    for(int i=0; i<[arrSortDate count]; i++)
    {
        ProductItem *productItemSortDate = [[ProductItem alloc]init];
        productItemSortDate.sortDate = arrSortDate[i];
        productItemSortDate.modifiedDate = [Utility formatDate:arrSortDate[i] fromFormat:@"yyyy-MM-dd" toFormat:@"dd/MM/yyyy"] ;
        [productItemSortDateList addObject:productItemSortDate];
    }
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_sortDate" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    _arrSectionDate = [[productItemSortDateList sortedArrayUsingDescriptors:sortDescriptors] copy];
    

    return [_arrSectionDate count];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger countColumn = 6;
    ProductItem *productItemSection = _arrSectionDate[section];
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_modifiedDate = %@",productItemSection.modifiedDate];
    NSArray *filterArray = [_productItemList filteredArrayUsingPredicate:predicate1];
    return ([filterArray count]+1)*countColumn;
    
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
    
    NSInteger section = indexPath.section;
    NSInteger item = indexPath.item;
    
    NSArray *header = @[@"No.",@"Item",@"Color",@"Size",@"Time",@"Delete"];
    NSInteger countColumn = [header count];
    
    if(item/countColumn==0)
    {
        [cell addSubview:cell.label];
        cell.label.frame = cell.bounds;
        cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
        cell.label.textColor = [UIColor whiteColor];
        cell.label.backgroundColor = tBlueColor;
        cell.label.textAlignment = NSTextAlignmentCenter;
    }
    else if(item%countColumn == 0 || item%countColumn == 1)
    {
        [cell addSubview:cell.buttonDetail];
        cell.buttonDetail.frame = cell.bounds;
        
        [cell addSubview:cell.leftBorder];
        [cell addSubview:cell.topBorder];
        [cell addSubview:cell.rightBorder];
        [cell addSubview:cell.bottomBorder];
    }
    else if(item%countColumn == 2 || item%countColumn == 3 || item%countColumn == 4)
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
    else if(item%countColumn == 5)
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
        ProductItem *productItemSection = _arrSectionDate[section];
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_modifiedDate = %@",productItemSection.modifiedDate];
        NSArray *filterArray = [_productItemList filteredArrayUsingPredicate:predicate1];
        ProductItem *productItem = filterArray[item/countColumn-1];
        
        
        if (!_lastItemReached && (section == [_arrSectionDate count]-1) && (item/countColumn-1 == [filterArray count]-1) && item%countColumn == 5)
        {
            
            NSString *all = @"";
            if([btnAllOrRemaining.title isEqualToString:@"All"])
            {
                all = @"0";
            }
            else if([btnAllOrRemaining.title isEqualToString:@"Remaining"])
            {
                all = @"1";
            }
            
            NSString *strPage = [NSString stringWithFormat:@"%ld",_page];
            [self.homeModel downloadItems:dbMainInventoryItem condition:@[@"0",all,strPage,_searchBar.text]];
        }
        switch (item%countColumn) {
        case 0:
            {
                [cell.buttonDetail setTitle:[NSString stringWithFormat:@"%ld", item/countColumn] forState:UIControlStateNormal];
                [cell.buttonDetail setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                cell.buttonDetail.titleLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                
                
                NSString *strSection = [NSString stringWithFormat:@"%ld",section];
                NSString *strItem = [NSString stringWithFormat:@"%ld",item];
                [_selectedSectionAndItem setValue:@[strSection,strItem] forKey:productItem.productID];
                cell.buttonDetail.tag = [productItem.productID integerValue];
                [cell.buttonDetail removeTarget:nil
                                   action:NULL
                         forControlEvents:UIControlEventAllEvents];
                [cell.buttonDetail addTarget:self action:@selector(viewProductItemDetail:)
                            forControlEvents:UIControlEventTouchUpInside];
            }
                break;
            case 1:
            {
                [cell.buttonDetail setTitle:productItem.productName forState:UIControlStateNormal];
                [cell.buttonDetail setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                cell.buttonDetail.titleLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                
                
                
                NSString *strSection = [NSString stringWithFormat:@"%ld",section];
                NSString *strItem = [NSString stringWithFormat:@"%ld",item];
                [_selectedSectionAndItemColumn1 setValue:@[strSection,strItem] forKey:productItem.productID];
                cell.buttonDetail.tag = [productItem.productID integerValue];
                [cell.buttonDetail removeTarget:nil
                                         action:NULL
                               forControlEvents:UIControlEventAllEvents];
                [cell.buttonDetail addTarget:self action:@selector(showQRCodeImage:)
                            forControlEvents:UIControlEventTouchUpInside];
                
            }
                break;
            case 2:
            {
                cell.label.text = productItem.color;
            }
                break;
            case 3:
            {
                cell.label.text = productItem.size;
            }
                break;
            case 4:
            {
//                NSString *title = productItem.modifiedDate;
//                NSString *time = [Utility formatDate:title fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"HH:mm:ss"];
//                cell.label.text = time;
                cell.label.text = productItem.modifiedTime;
                NSLog(@"cell.label : %@",cell.label.text);
                NSLog(@"modified date : %@",productItem.modifiedTime);
            }
                break;
            case 5:
            {
                cell.imageView.tag = [productItem.productID integerValue];
                [_dicSectionDate setValue:[NSString stringWithFormat:@"%ld",(long)section] forKey:[NSString stringWithFormat:@"%ld",(long)item]];
                
                [cell.singleTap addTarget:self action:@selector(deleteProductWith:)];
                cell.singleTap.numberOfTapsRequired = 1;
                cell.singleTap.numberOfTouchesRequired = 1;
                [cell.imageView addGestureRecognizer:cell.singleTap];
            }
                break;
            default:
                break;
        }
    }

    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segQRCodeImage"])
    {
        QRCodeImageViewController *vc = segue.destinationViewController;
        vc.productCode = _productCode;
    }
}

- (void) showQRCodeImage:(id)sender
{
    UIButton *button = sender;
    NSInteger intProductID = button.tag;
    NSString *strProductID = [NSString stringWithFormat:@"%06ld", intProductID];
    
    
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productID = %@",strProductID];
    NSArray *filterArray = [_productItemList filteredArrayUsingPredicate:predicate1];
    ProductItem *productItem = filterArray[0];
    _productCode = productItem.productCode;
    [self performSegueWithIdentifier:@"segQRCodeImage" sender:self];
    
}

- (void) viewProductItemDetail:(id)sender
{
    if([_txvDetail isDescendantOfView:self.view])
    {
        [_txvDetail removeFromSuperview];
    }
    else
    {
        UIButton *button = sender;
        NSInteger intProductID = button.tag;
        NSString *strProductID = [NSString stringWithFormat:@"%06ld", intProductID];
        NSString *productIDLabel = [NSString stringWithFormat:@"ProductID: %@",strProductID];
        
        
        NSInteger section = [[_selectedSectionAndItem valueForKey:strProductID][0] integerValue];
        NSInteger item = [[_selectedSectionAndItem valueForKey:strProductID][1] integerValue];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
        CustomUICollectionViewCellButton2 *cell = (CustomUICollectionViewCellButton2*)[self.colViewProductItem cellForItemAtIndexPath:indexPath];
        
        
        
        CGRect frame = [colViewProductItem convertRect:cell.frame toView:self.view];
        _txvDetail.frame = CGRectMake(frame.size.width*3/4+frame.origin.x, frame.size.height*3/4+frame.origin.y, 120, 30);
        _txvDetail.backgroundColor = [UIColor lightGrayColor];
        _txvDetail.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
        _txvDetail.text = productIDLabel;
        [self.view addSubview:_txvDetail];
    }
}
-(NSString*)getRowNo:(NSString *)productID
{
    for(int k=0; k<[_arrOfSubProductItemList count]; k++)
    {
        //run row no again
        for(ProductItem *item in _arrOfSubProductItemList[k])
        {
            if([item.productID isEqualToString:productID])
            {
                return item.row;
            }
        }
    }
    return @"";
}

- (void) deleteProductWith:(UIGestureRecognizer *)gestureRecognizer {
//    UIView* view = gestureRecognizer.view;
    CGPoint point = [gestureRecognizer locationInView:colViewProductItem];
    NSIndexPath * tappedIP = [colViewProductItem indexPathForItemAtPoint:point];
    CustomUICollectionViewCellButton2 *cell = (CustomUICollectionViewCellButton2 *)[colViewProductItem cellForItemAtIndexPath:tappedIP];
    
    
    NSInteger countColumn = 6;
    ProductItem *productItemSection = _arrSectionDate[tappedIP.section];
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_modifiedDate = %@",productItemSection.modifiedDate];
    NSArray *filterArray = [_productItemList filteredArrayUsingPredicate:predicate1];
    ProductItem *productItem = filterArray[tappedIP.item/countColumn-1];
    

    //delete with product id -> confirm delete -> delete -> reload collectionview
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:
     [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Delete product (No.%ld)",tappedIP.item/countColumn]
                              style:UIAlertActionStyleDestructive
                            handler:^(UIAlertAction *action) {
                                //check status == i -> delete
                                if([productItem.status isEqualToString:@"P"])
                                {
                                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Cannot delete"
                                                                                                   message:@"This item is booked for preorder"
                                                                                            preferredStyle:UIAlertControllerStyleAlert];
                                    
                                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                                          handler:^(UIAlertAction * action) {}];
                                    
                                    [alert addAction:defaultAction];
                                    [self presentViewController:alert animated:YES completion:nil];
                                    return ;
                                }
                                
                                
                                
                                [self loadingOverlayView];
                               
                                //************
                                _productDelete.productID = productItem.productID;
                                [self.homeModel deleteItems:dbMainInventoryItem withData:productItem];
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
        CGRect frame = cell.imageView.bounds;
        frame.origin.y = frame.origin.y-15;
        popPresenter.sourceView = cell.imageView;
        popPresenter.sourceRect = frame;
//        popPresenter.barButtonItem = _barButtonIpad;
    }
    ///////////////
    
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)itemsDeletedWithReturnID:(NSInteger)ID
{
    [self removeOverlayViews];
    if(ID == 0)
    {
        [self alertMessage:@"No scan-product to delete in main inventory." title:@"Warning"];
    }
    else
    {
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productID = %@",_productDelete.productID];
        NSArray *filterArray = [_mutArrProductItemList filteredArrayUsingPredicate:predicate1];

        [_mutArrProductItemList removeObjectsInArray:filterArray];


        //adjust countPerDate/countAll
        for(ProductItem *item in _mutArrProductItemList)
        {
           ProductItem *itemDelete = filterArray[0];
           if(item.sortDate == itemDelete.sortDate)
           {
               item.countByDate -= 1;
           }
           item.count -= 1;
        }


        //reload data
        if(self.searchBarActive)
        {
           [self searchBar:self.searchBar textDidChange:self.searchBar.text];
        }
        else
        {
           [self setData];
        }
    }
}

- (void)itemsDeleted
{
    [self removeOverlayViews];
    
    
   
}
#pragma mark <UICollectionViewDelegate>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width;
    NSInteger countColumn = 6;
    if(indexPath.item%countColumn == 0 || indexPath.item%countColumn == 3)
    {
        width = 30;
    }
    else
    {
        width = (colViewProductItem.bounds.size.width - 30 - 30 - 40)/4;
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
    CustomUICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        CustomUICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        
        if([_arrSectionDate count]>0)
        {
            ProductItem *productItemModifiedDate = _arrSectionDate[indexPath.section];
            NSString *modifiedDate = productItemModifiedDate.modifiedDate;
            headerView.label.text = [NSString stringWithFormat:@"Modified date: %@",modifiedDate];
            
            
            NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_modifiedDate = %@",modifiedDate];
            NSArray *filterArray = [_productItemList filteredArrayUsingPredicate:predicate1];
            if([filterArray count]>0)
            {
                ProductItem *productItem = filterArray[0];
                            
                CGRect frame = headerView.bounds;
                frame.origin.x = 20;
                headerView.label.frame = frame;
                [headerView addSubview:headerView.label];
                
                CGRect frame2 = headerView.bounds;
                frame2.size.width = frame2.size.width - 20;
                headerView.labelAlignRight.frame = frame2;
                headerView.labelAlignRight.textAlignment = NSTextAlignmentRight;
                NSString *strCountItemInProductName = [_countItemInSection objectForKey:_arrSectionDate[indexPath.section]];
                strCountItemInProductName = [Utility formatBaht:strCountItemInProductName];

                NSString *strCountItem = [NSString stringWithFormat:@"%ld/%ld",productItem.countByDate,productItem.count];
                headerView.labelAlignRight.text = strCountItem;
                [headerView addSubview:headerView.labelAlignRight];
                [self setLabelUnderline:headerView.labelAlignRight underline:headerView.viewUnderline];
            }
            
        }
        
        reusableview = headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        CustomUICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        
        reusableview = footerview;
    }
    
    return reusableview;
}

-(NSString *)countAllItem
{
    //count all item
    NSInteger countAllItem = 0;
    for(id keySectionName in _countItemInSection)
    {
        NSString *countItem = [_countItemInSection objectForKey:keySectionName];
        countAllItem = countAllItem + [countItem intValue];
    }
    NSString *strCountItem = [NSString stringWithFormat:@"%ld",(long)countAllItem];
    strCountItem = [Utility formatBaht:strCountItem];
    return strCountItem;
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

#pragma mark - search

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    // Do the search...
    
    _page = 1;
    NSString *strPage = [NSString stringWithFormat:@"%ld",_page];
    [self loadingOverlayView];
    [self.homeModel downloadItems:dbMainInventoryItem condition:@[@"0",@"0",strPage,_searchBar.text]];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    // user did type something, check our datasource for text that looks the same

    if (searchText.length == 0)
    {
        // if text lenght == 0
        // we will consider the searchbar is not active
        //        self.searchBarActive = NO;

        [self cancelSearching];
//        [self setData];
        _page = 1;
        NSString *strPage = [NSString stringWithFormat:@"%ld",_page];
        [self loadingOverlayView];
        [self.homeModel downloadItems:dbMainInventoryItem condition:@[@"0",@"0",strPage,_searchBar.text]];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self cancelSearching];
    [self setData];
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

- (void)itemsFail
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[Utility getConnectionLostTitle]
                                                                   message:[Utility getConnectionLostMessage]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {

        [self loadingOverlayView];
        [self.homeModel downloadItems:dbMainInventory];
                                                          }];
    
    [alert addAction:defaultAction];
    dispatch_async(dispatch_get_main_queue(),^ {
        [self presentViewController:alert animated:YES completion:nil];
    } );
}

- (void)itemsUpdated
{
    
}

-(void) loadingOverlayView
{
    [indicator startAnimating];
    indicator.layer.zPosition = 1;
    indicator.alpha = 1;
    
    
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

- (IBAction)allOrRemaining:(id)sender
{
    if([btnAllOrRemaining.title isEqualToString:@"All"])
    {
        btnAllOrRemaining.title = @"Remaining";
        
        [_mutArrProductItemList removeAllObjects];
        _page = 1;
        NSString *strPage = [NSString stringWithFormat:@"%ld",_page];
        [self.homeModel downloadItems:dbMainInventoryItem condition:@[@"0",@"1",strPage,_searchBar.text]];
    }
    else if([btnAllOrRemaining.title isEqualToString:@"Remaining"])
    {
        btnAllOrRemaining.title = @"All";

        [_mutArrProductItemList removeAllObjects];
        _page = 1;
        NSString *strPage = [NSString stringWithFormat:@"%ld",_page];
        [self.homeModel downloadItems:dbMainInventoryItem condition:@[@"0",@"0",strPage,_searchBar.text]];
    }
}
@end
