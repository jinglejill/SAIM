//
//  InventorySourceViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 8/28/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "InventorySourceViewController.h"
#import "Utility.h"
#import "CustomUICollectionViewCellButton.h"
#import "ProductSource.h"
#import "CustomUICollectionReusableView.h"
#import "SharedProduct.h"
#import "ProductName.h"


#define orangeColor         [UIColor colorWithRed:253/255.0 green:182/255.0 blue:103/255.0 alpha:1]
#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]

@interface InventorySourceViewController ()<UISearchBarDelegate>
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSArray *_productSourceList;
    NSMutableArray *_mutArrProductSourceList;
    NSMutableArray *_mutArrProductSourcePortionList;
    NSMutableArray *_arrSectionDate;
    NSMutableArray *_arrOfSubProductSourceList;
    NSMutableDictionary *_countItemInSection;
    UIView *_viewUnderline;
    BOOL _firstPortion;
    BOOL _deleteItem;
    NSInteger _countPortion;
}
@property (nonatomic,strong) NSArray        *dataSource;
@property (nonatomic,strong) NSArray        *dataSourceForSearchResult;
@property (nonatomic)        BOOL           searchBarActive;
@property (nonatomic)        float          searchBarBoundsY;
@end

@implementation InventorySourceViewController
static NSString * const reuseIdentifier = @"Cell";
static NSString * const reuseHeaderViewIdentifier = @"HeaderView";
static NSString * const reuseFooterViewIdentifier = @"FooterView";
@synthesize colViewProductSource;

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
    
    
    self.searchBar.delegate = self;
    _mutArrProductSourceList = [[NSMutableArray alloc]init];
    
    
    [self loadViewProcess];
}

- (void)loadViewProcess
{
    [self queryInventorySource:YES];
}
-(void)queryInventorySource:(BOOL)firstTime
{
    //query data
    //เปลี่บยน status p->i, เรียงลำดับ group เดียวกันใกล้กัน, สร้าง array ใส่ group กับ count
    
    [_mutArrProductSourceList removeAllObjects];
    NSMutableArray *productList = [SharedProduct sharedProduct].productList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_status = %@ or _status = %@",@"I",@"P"];
    NSArray *filterArray = [productList filteredArrayUsingPredicate:predicate1];

    NSMutableArray *productPrepareList = [[NSMutableArray alloc]init];
    for(Product *item in filterArray)
    {
        Product *product = [item copy];
        product.productIDGroup = [Utility getProductIDGroup:item];
        product.manufacturingDateYM = [Utility formatDate:item.manufacturingDate fromFormat:@"yyyy-MM-dd" toFormat:@"yyyy-MM"];
        if([item.status isEqualToString:@"P"])
        {
            product.status = @"I";
        }
        
        [productPrepareList addObject:product];
    }
    
    ////////////////////////
    {
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_manufacturingDateYM" ascending:YES];
        NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_productIDGroup" ascending:YES];
        NSSortDescriptor *sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:@"_eventID" ascending:YES];
        NSSortDescriptor *sortDescriptor4 = [[NSSortDescriptor alloc] initWithKey:@"_status" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2,sortDescriptor3,sortDescriptor4, nil];
        NSArray *sortArray = [productPrepareList sortedArrayUsingDescriptors:sortDescriptors];
        productPrepareList = [sortArray mutableCopy];
    }
    
    
    NSMutableArray *groupHead = [[NSMutableArray alloc]init];
    NSMutableArray *groupCount = [[NSMutableArray alloc]init];
    NSInteger countData = 0;
    BOOL firstItem = YES;
    Product *previousProduct = [[Product alloc]init];
    for(Product *item in productPrepareList)
    {
        if(!([item.manufacturingDateYM isEqualToString:previousProduct.manufacturingDateYM] &&
             [item.productIDGroup isEqualToString:previousProduct.productIDGroup] &&
             (item.eventID == previousProduct.eventID) &&
             [item.status isEqualToString:previousProduct.status]))
        {
            previousProduct = item;
            [groupHead addObject:item];
            if(!firstItem)
            {
                [groupCount addObject:[NSString stringWithFormat:@"%ld",(long)countData]];
            }
            else
            {
                firstItem = NO;
            }
            
            countData = 1;
        }
        else
        {
            countData += 1;
        }
    }
    [groupCount addObject:[NSString stringWithFormat:@"%ld",(long)countData]];
    
    
    
    [_mutArrProductSourceList removeAllObjects];
    for(int i=0; i<[groupHead count]; i++)
    {
        Product *product = groupHead[i];
        NSString *strEventID = [NSString stringWithFormat:@"%ld",product.eventID];
        NSString *quantity = groupCount[i];
        NSString *productNameGroup = [NSString stringWithFormat:@"%@%@%@",product.productCategory2,product.productCategory1,product.productName];
        ProductSource *productSource = [[ProductSource alloc]init];
        
        productSource.row = @"0";
        productSource.productName = [ProductName getNameWithProductNameGroup:productNameGroup];
        productSource.color = [Utility getColorName:product.color];
        productSource.size = [Utility getSizeLabel:product.size];
        productSource.sizeOrder = [Utility getSizeOrder:product.size];
        productSource.manufacturingYearMonth = product.manufacturingDateYM;
        productSource.eventName = [Utility getEventName:product.eventID];
        productSource.quantity = quantity;
        productSource.productIDGroup = product.productIDGroup;
        productSource.eventID = strEventID;
        productSource.status = product.status;
        
        [_mutArrProductSourceList addObject:productSource];
        
        
        if([_mutArrProductSourceList count] == [Utility getNumberOfRowForExecuteSql]*8)
        {
            [self setData];
            
            if(firstTime)
            {
                break;
            }
        }
    }
    
    
    if([_mutArrProductSourceList count] != [Utility getNumberOfRowForExecuteSql]*8)
    {
        [self setData];
    }
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self queryInventorySource:NO];
}
-(void)setData
{
    _arrSectionDate = [[NSMutableArray alloc]init];
    _arrOfSubProductSourceList = [[NSMutableArray alloc]init];
    
    
    if(self.searchBarActive)
    {
        _productSourceList = self.dataSourceForSearchResult;
    }
    else
    {
        _productSourceList = _mutArrProductSourceList;
    }
    
    
    {
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_manufacturingYearMonth" ascending:YES];
        NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_productName" ascending:YES];
        NSSortDescriptor *sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:@"_color" ascending:YES];
        NSSortDescriptor *sortDescriptor4 = [[NSSortDescriptor alloc] initWithKey:@"_sizeOrder" ascending:YES];
        NSSortDescriptor *sortDescriptor5 = [[NSSortDescriptor alloc] initWithKey:@"_eventName" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2,sortDescriptor3,sortDescriptor4,sortDescriptor5, nil];
        _productSourceList = [_productSourceList sortedArrayUsingDescriptors:sortDescriptors];
    }
    
    //make section date array for header
    for(ProductSource *item in _productSourceList)
    {
        //group and format to display in app
        NSString *strManufacturingYearMonth = [Utility formatDate:item.manufacturingYearMonth fromFormat:@"yyyy-MM" toFormat:@"MM/yyyy"];
        if(![_arrSectionDate containsObject:strManufacturingYearMonth])
        {
            [_arrSectionDate addObject:strManufacturingYearMonth];
        }
    }
    
    //make array of array of product source
    for(int i=0; i<[_arrSectionDate count]; i++)
    {
        NSMutableArray *arrSubProductSourceList = [[NSMutableArray alloc]init];
        [_arrOfSubProductSourceList addObject:arrSubProductSourceList];
    }
    
    int j = 0;
    for(int i=0; i<[_productSourceList count]; )
    {
        ProductSource *item = _productSourceList[i];
        NSString *strManufacturingYearMonth = [Utility formatDate:item.manufacturingYearMonth fromFormat:@"yyyy-MM" toFormat:@"MM/yyyy"];
        if([strManufacturingYearMonth isEqualToString:(NSString*)_arrSectionDate[j]])
        {
            [_arrOfSubProductSourceList[j] addObject:item];
            i += 1;
        }
        else
        {
            j +=1;
        }
    }
    
    //run row no.
    for(int k=0; k<[_arrOfSubProductSourceList count]; k++)
    {
        //run row no again
        int i=0;
        for(ProductSource *item in _arrOfSubProductSourceList[k])
        {
            i +=1;
            item.row = [NSString stringWithFormat:@"%d", i];
        }
    }
    
    //set count item in section
    _countItemInSection = [[NSMutableDictionary alloc]init];
    for(int k=0; k<[_arrOfSubProductSourceList count]; k++)
    {
        //run row no again
        int countItem = 0;
        for(ProductSource *item in _arrOfSubProductSourceList[k])
        {
            countItem +=[item.quantity intValue];
        }
        NSString *strCountItem = [NSString stringWithFormat:@"%d",countItem];
        [_countItemInSection setValue:strCountItem forKey:_arrSectionDate[k]];
    }
    
    [colViewProductSource reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Register cell classes
    [colViewProductSource registerClass:[CustomUICollectionViewCellButton class] forCellWithReuseIdentifier:reuseIdentifier];
    [colViewProductSource registerClass:[CustomUICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeaderViewIdentifier];
    [colViewProductSource registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:reuseFooterViewIdentifier];
    
    colViewProductSource.delegate = self;
    colViewProductSource.dataSource = self;
    
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return [_arrSectionDate count];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSInteger count = [_arrOfSubProductSourceList[section] count];
    NSInteger countColumn = 6;
    return (count+1)*countColumn;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CustomUICollectionViewCellButton *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if ([cell.label isDescendantOfView:cell]) {
        [cell.label removeFromSuperview];
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
    
    NSArray *header = @[@"No",@"Item",@"Color",@"Size",@"Qty",@"Source"];
    NSInteger countColumn = [header count];
    
    if(item/countColumn==0)
    {
        [cell addSubview:cell.label];
        cell.label.frame = cell.bounds;
        cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
        cell.label.textColor= [UIColor whiteColor];
        cell.label.backgroundColor = tBlueColor;
    }
    else if(item%countColumn == 0 || item%countColumn == 1 || item%countColumn == 2 || item%countColumn == 3 || item%countColumn == 4 || item%countColumn == 5)
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
        ProductSource *productSource = (ProductSource *)_arrOfSubProductSourceList[section][item/countColumn-1];
        switch (item%countColumn) {
            case 0:
            {
                cell.label.text = productSource.row;
            }
                break;
            case 1:
            {
                cell.label.text = productSource.productName;
            }
                break;
            case 2:
            {
                cell.label.text = productSource.color;
            }
                break;
            case 3:
            {
                cell.label.text = productSource.size;
            }
                break;
            case 4:
            {
                cell.label.text = productSource.quantity;
            }
                break;
            case 5:
            {
                cell.label.text = productSource.eventName;

            }
                break;
            
            default:
                break;
        }
    }
  
    return cell;
}

#pragma mark <UICollectionViewDelegate>


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width;
    NSArray *arrSize = @[@30,@60,@0,@30,@30,@60];
    width = [arrSize[indexPath.item%[arrSize count]] floatValue];
    if(width == 0)
    {
        width = colViewProductSource.bounds.size.width;
        for(int i=0; i<[arrSize count]; i++)
        {
            width = width - [arrSize[i] floatValue];
        }
        width = width - 40;
    }
    
    CGSize size = CGSizeMake(width, 20);
    return size;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.colViewProductSource.collectionViewLayout;
    
    [layout invalidateLayout];
    [colViewProductSource reloadData];
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
            NSString *manufacturingYearMonth = (NSString *)_arrSectionDate[indexPath.section];
            headerView.label.text = [NSString stringWithFormat:@"MFD: %@",manufacturingYearMonth];
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
            NSString *strCountItem = [NSString stringWithFormat:@"%@/%@",strCountItemInProductName,[self countAllItem]];
            headerView.labelAlignRight.text = strCountItem;
            [headerView addSubview:headerView.labelAlignRight];
            [self setLabelUnderline:headerView.labelAlignRight underline:headerView.viewUnderline];
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
    NSPredicate *resultPredicate    = [NSPredicate predicateWithFormat:@"_productName contains[c] %@ || _color contains[c] %@ || _size contains[c] %@ || _quantity contains[c] %@ || _eventName contains[c] %@", searchText,searchText,searchText,searchText,searchText];
    self.dataSourceForSearchResult  = [_mutArrProductSourceList filteredArrayUsingPredicate:resultPredicate];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    // user did type something, check our datasource for text that looks the same
    if (searchText.length>0)
    {
        // search and reload data source
        self.searchBarActive = YES;
        [self filterContentForSearchText:searchText scope:@""];
        [self setData];
//        [colViewProductSource reloadData];
    }
    else{
        // if text lenght == 0
        // we will consider the searchbar is not active
        //        self.searchBarActive = NO;
        
        [self cancelSearching];        
        [self setData];
//        [colViewProductSource reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self cancelSearching];
    [self setData];
//    [colViewProductSource reloadData];
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
