//
//  TransferProductDetailViewController.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 4/7/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import "TransferProductDetailViewController.h"
#import "CustomUICollectionViewCellButton2.h"
#import "CustomUICollectionReusableView.h"
#import "PushSync.h"
#import "SharedPushSync.h"
#import "Utility.h"
#import "ProductCategory2.h"
#import "SharedProductCategory2.h"
#import "SharedProductName.h"
#import "SharedProductSales.h"
#import "ProductWithQuantity.h"
#import "ProductTransfer.h"
#import "ProductName.h"


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


@interface TransferProductDetailViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSMutableArray *_productCategory2List;
    NSInteger _selectedProductCategory2;
    NSMutableArray *_productTransferList;
    NSArray *_productWithQuantity;
    NSMutableArray *_mutArrProductWithQuantity;
    NSMutableDictionary *_dicProductName;
    NSMutableDictionary *_dicColorAndSizeHead;
    NSMutableDictionary *_countItemInProductName;
    NSArray *_sortedProductName;
//    NSMutableArray *_productionOrderAddedByPoNoList;
//    NSMutableDictionary *_sectionAndItemByID;
//    NSInteger _selectedRunningPoNo;
//    NSMutableArray *_selectedProductionOrderList;
}
@end
@implementation TransferProductDetailViewController

static NSString * const reuseIdentifier = @"Cell";
static NSString * const reuseHeaderViewIdentifier = @"HeaderView";
static NSString * const reuseFooterViewIdentifier = @"FooterView";


@synthesize colViewData;
@synthesize txtMainCategory;
@synthesize txtPicker;
@synthesize selectedTransferHistory;
@synthesize lblLocation;


- (IBAction)unwindToProductionOrderAddedList:(UIStoryboardSegue *)segue
{
    [colViewData reloadData];
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
    
    
    _dicColorAndSizeHead = [[NSMutableDictionary alloc]init];
    _selectedProductCategory2 = 0;
    lblLocation.text = [NSString stringWithFormat:@"Location: %@",selectedTransferHistory.eventName];
    
    
    [txtPicker removeFromSuperview];
    txtMainCategory.delegate = self;
    txtMainCategory.inputView = txtPicker;
    txtPicker.delegate = self;
    txtPicker.dataSource = self;
    txtPicker.showsSelectionIndicator = YES;
    

    
    _productCategory2List = [SharedProductCategory2 sharedProductCategory2].productCategory2List;
    _productCategory2List = [ProductCategory2 getProductCategory2SortByOrderNo:_productCategory2List];
    ProductCategory2 *productCategory2 = _productCategory2List[_selectedProductCategory2];
    txtMainCategory.text = productCategory2.name;
    
    
    [self queryProduct:productCategory2.code];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)queryProduct:(NSString *)productCategory2
{
    [self loadingOverlayView];
    NSString *strTransferHistoryID = [NSString stringWithFormat:@"%ld",selectedTransferHistory.transferHistoryID];
    [_homeModel downloadItems:dbProductTransfer condition:@[productCategory2,strTransferHistoryID]];
}

- (void)itemsDownloaded:(NSArray *)items
{
    [self removeOverlayViews];
    int i=0;
    _productTransferList = items[i++];
    
    [self queryProductWithQuantity];
    [self prepareData];
}

-(void)queryProductWithQuantity
{
    NSMutableArray *groupHead = [[NSMutableArray alloc]init];
    NSMutableArray *groupCount = [[NSMutableArray alloc]init];
    NSInteger countData = 0;
    BOOL firstItem = YES;
    ProductTransfer *previousProduct = [[ProductTransfer alloc]init];
    for(ProductTransfer *item in _productTransferList)
    {
        if(![item.productIDGroup isEqualToString:previousProduct.productIDGroup])
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
    
    
    _mutArrProductWithQuantity = [[NSMutableArray alloc]init];
    for(int i=0; i<[groupHead count]; i++)
    {
        ProductTransfer *product = groupHead[i];
        NSString *quantity = groupCount[i];
        NSString *productNameGroup = [NSString stringWithFormat:@"%@%@%@",product.productCategory2,product.productCategory1,product.productName];
        ProductWithQuantity *productWithQuantity = [[ProductWithQuantity alloc]init];
        productWithQuantity.productName = [ProductName getNameWithProductNameGroup:productNameGroup];
        productWithQuantity.color = [Utility getColorName:product.color];
        productWithQuantity.size = product.size;
        productWithQuantity.quantity = quantity;
        productWithQuantity.productIDGroup = product.productIDGroup;
//        productWithQuantity.eventID = strEventID;
//        productWithQuantity.status = product.status;
        productWithQuantity.productCategory2 = product.productCategory2;
        
        [_mutArrProductWithQuantity addObject:productWithQuantity];
    }
}

-(void)prepareData
{
//    if([arrProductCategory2 count]>0)
//    {
//        NSString *productCategory2 = arrProductCategory2[index];
//        NSString *strEventID = [NSString stringWithFormat:@"%ld",[SharedSelectedEvent sharedSelectedEvent].event.eventID];
//        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_eventID = %@ and _status = %@ and _productCategory2 = %@",strEventID,@"I",productCategory2];
//        _productWithQuantity = [mutArrProductWithQuantity filteredArrayUsingPredicate:predicate1];
//    }
    
    
    _productWithQuantity = _mutArrProductWithQuantity;
    
    
    //product name
    _dicProductName = [[NSMutableDictionary alloc]init];
    NSString *previousProductName = @"";
    for(NSInteger i=0; i<_productWithQuantity.count; i++)
    {
        ProductWithQuantity *product = _productWithQuantity[i];
        if(![previousProductName isEqualToString:product.productName])
        {
            NSMutableDictionary *dicColor = [[NSMutableDictionary alloc]init];
            [_dicProductName setValue:dicColor forKey:product.productName];
            previousProductName = product.productName;
        }
    }
    [self setSizeAndColorForEachProductName];
    
    //color
    for(NSInteger i=0; i<_productWithQuantity.count; i++)
    {
        ProductWithQuantity *product = _productWithQuantity[i];
        NSMutableDictionary *dicColor = [_dicProductName objectForKey:product.productName];
        
        if(![dicColor objectForKey:product.color])
        {
            NSMutableDictionary *dicSize = [[NSMutableDictionary alloc]init];
            [dicColor setValue:dicSize forKey:product.color];
        }
    }
    //add color of no exist
    for(id keyProductName in _dicProductName)
    {
        NSMutableDictionary *dicColor = [_dicProductName objectForKey:keyProductName];
        NSArray *arrColor = [_dicColorAndSizeHead objectForKey:keyProductName][0];//0=color,1=size
        
        for(int i=0; i<[arrColor count]; i++)
        {
            if(![dicColor objectForKey:arrColor[i]])
            {
                NSMutableDictionary *dicSize = [[NSMutableDictionary alloc]init];
                [dicColor setValue:dicSize forKey:arrColor[i]];
            }
        }
    }
    //size
    for(NSInteger i=0; i<_productWithQuantity.count; i++)
    {
        ProductWithQuantity *product = _productWithQuantity[i];
        NSMutableDictionary *dicColor = [_dicProductName objectForKey:product.productName];
        NSMutableDictionary *dicSize = [dicColor objectForKey:product.color];
        [dicSize setValue:product.quantity forKey:[Utility getSizeLabel:product.size]];
    }
    //add size of no exist
    for(id keyProductName in _dicProductName)
    {
        NSMutableDictionary *dicColor = [_dicProductName objectForKey:keyProductName];
        for(id keyColor in dicColor)
        {
            NSMutableDictionary *dicSize = [dicColor objectForKey:keyColor];
            NSArray *arrProductSize = [_dicColorAndSizeHead objectForKey:keyProductName][1];//0=color,1=size
            
            for(int i=0; i<[arrProductSize count]; i++)
            {
                ProductSize *productSize = arrProductSize[i];
                if(![dicSize objectForKey:productSize.sizeLabel])
                {
                    [dicSize setValue:@"0" forKey:productSize.sizeLabel];
                }
            }
        }
    }
    
    
    
    
    //count item in productname
    NSInteger count = 0;
    _countItemInProductName = [[NSMutableDictionary alloc]init];
    for(id keyProductName in _dicProductName){
        NSMutableDictionary *dicColor = [_dicProductName objectForKey:keyProductName];
        for(id keyColor in dicColor)
        {
            NSMutableDictionary *dicSize = [dicColor objectForKey:keyColor];
            for(id keySize in dicSize)
            {
                count = count + [[dicSize objectForKey:keySize] intValue];
            }
        }
        [_countItemInProductName setValue:[NSString stringWithFormat:@"%ld", (long)count] forKey:keyProductName];
        count = 0;
    }
    
    [colViewData reloadData];
}

- (void)setSizeAndColorForEachProductName
{
    //put color and size label
    NSMutableArray *productSalesList = [SharedProductSales sharedProductSales].productSalesList;
    for(ProductSales *item in productSalesList)
    {
        item.colorText = [Utility getColorName:item.color];
    }
    
    //get color and size for each productname
    for(id keyProductName in _dicProductName)
    {
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productSalesSetID = %@ and _productNameID = %ld",@"0",[ProductName getProductNameIDWithName:keyProductName]];
        NSArray *filterArray = [productSalesList filteredArrayUsingPredicate:predicate1];
        NSSet *uniqueColor = [NSSet setWithArray:[filterArray valueForKey:@"colorText"]];
        NSSet *uniqueSize = [NSSet setWithArray:[filterArray valueForKey:@"size"]];
        NSArray *arrColor = [uniqueColor allObjects];
        NSArray *arrSize = [uniqueSize allObjects];
        
        
        NSMutableArray *mutArrSize = [[NSMutableArray alloc]init];
        for(NSString *item in arrSize)
        {
            ProductSize *productSize = [[ProductSize alloc]init];
            productSize.code = item;
            productSize.sizeOrder = [NSString stringWithFormat:@"%ld",(long)[Utility getSizeOrder:item]];
            productSize.sizeLabel = [Utility getSizeLabel:item];
            [mutArrSize addObject:productSize];
        }
        
        
        [_dicColorAndSizeHead setObject:@[arrColor,mutArrSize] forKey:keyProductName];
    }
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [_dicProductName count];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSArray *keys = [_dicProductName allKeys];
    _sortedProductName = [keys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    
    NSArray *arrColor = [_dicColorAndSizeHead objectForKey:_sortedProductName[section]][0];
    NSArray *arrProductSize = [_dicColorAndSizeHead objectForKey:_sortedProductName[section]][1];
    
    return ([arrColor count]+1)*([arrProductSize count]+1);
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CustomUICollectionViewCellButton2 *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if ([cell.label isDescendantOfView:cell]) {
        [cell.label removeFromSuperview];
    }
    if ([cell.buttonDetail isDescendantOfView:cell]) {
        [cell.buttonDetail removeFromSuperview];
    }
    if ([cell.buttonDetail2 isDescendantOfView:cell]) {
        [cell.buttonDetail2 removeFromSuperview];
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
    
    [cell addSubview:cell.label];
    cell.label.frame = cell.bounds;
    
    NSInteger section = indexPath.section;
    NSInteger item = indexPath.item;
    
    
    NSDictionary *dicColor = [_dicProductName objectForKey:_sortedProductName[section]];
    NSArray *keys = [dicColor allKeys];
    NSArray *sortedColor = [keys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    
    NSArray *arrProductSize = [_dicColorAndSizeHead objectForKey:_sortedProductName[section]][1];//0=color,1=size
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_sizeOrder" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortedProductSize = [arrProductSize sortedArrayUsingDescriptors:sortDescriptors];
    
    
    
    
    //    NSArray *sortedSize = [arrSize sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSInteger sizeNum = [arrProductSize count];
    
    
    //color label
    if(item == 0)
    {
        cell.label.text = @"";
        cell.label.backgroundColor = tBlueColor;
    }
    else if(item >=1 && item <=sizeNum)
    {
        ProductSize *productSize = sortedProductSize[item-1];
        //        NSString *sizeLabel = sortedSize[item-1];
        cell.label.text = productSize.sizeLabel;
        cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
        cell.label.textColor= [UIColor whiteColor];
        cell.label.backgroundColor = tBlueColor;
        cell.label.textAlignment = NSTextAlignmentCenter;
    }
    else if(item !=0 && item%(sizeNum+1) == 0)
    {
        cell.label.text = sortedColor[(item/(sizeNum+1))-1];
        cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
        cell.label.textColor = [UIColor blackColor];
        cell.label.backgroundColor = [UIColor clearColor];
        cell.label.textAlignment = NSTextAlignmentLeft;
        
        [cell addSubview:cell.leftBorder];
        [cell addSubview:cell.topBorder];
        [cell addSubview:cell.rightBorder];
        [cell addSubview:cell.bottomBorder];
    }
    else if(item >=(sizeNum+1) && item%(sizeNum+1) != 0)
    {
        NSDictionary *dicSize = [dicColor objectForKey:sortedColor[(item/(sizeNum+1))-1]];
        
        //9-15
        ProductSize *productSize = sortedProductSize[item%(sizeNum+1)-1];
        NSString *quantity = [dicSize objectForKey:productSize.sizeLabel];
        
        cell.label.text = quantity;
        cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
        cell.label.textColor = [UIColor blackColor];
        cell.label.backgroundColor = [UIColor clearColor];
        cell.label.textAlignment = NSTextAlignmentCenter;
        
        [cell addSubview:cell.leftBorder];
        [cell addSubview:cell.topBorder];
        [cell addSubview:cell.rightBorder];
        [cell addSubview:cell.bottomBorder];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width;
    NSString *cellSize;
    
    
    NSArray *arrProductSize = [_dicColorAndSizeHead objectForKey:_sortedProductName[indexPath.section]][1];//0=color,1=size
    
    
    NSInteger sizeNum = [arrProductSize count];
    cellSize = [NSString stringWithFormat:@"%f",(colViewData.bounds.size.width-70)/sizeNum];//70=size of colorname
    
    NSMutableArray *arrSize = [[NSMutableArray alloc]init];
    [arrSize addObject:@0];
    for(int i=1; i<=sizeNum; i++)
    {
        [arrSize addObject:cellSize];
    }
    
    width = [arrSize[indexPath.item%[arrSize count]] floatValue];
    if(width == 0)
    {
        width = colViewData.bounds.size.width;
        for(int i=0; i<[arrSize count]; i++)
        {
            width = width - [arrSize[i] floatValue];
        }
        width = width;
    }
    
    CGSize size = CGSizeMake(width, 20);
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
        CustomUICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeaderViewIdentifier forIndexPath:indexPath];
        
        headerView.label.text = _sortedProductName[indexPath.section];
        CGRect frame = headerView.bounds;
        frame.origin.x = 0;
        headerView.label.frame = frame;
        [headerView addSubview:headerView.label];
        
        
        CGRect frame2 = headerView.bounds;
        frame2.size.width = frame2.size.width;
        headerView.labelAlignRight.frame = frame2;
        headerView.labelAlignRight.textAlignment = NSTextAlignmentRight;
        NSString *strCountItemInProductName = [_countItemInProductName objectForKey:_sortedProductName[indexPath.section]];
        strCountItemInProductName = [Utility formatBaht:strCountItemInProductName];
        NSString *strCountItem = [NSString stringWithFormat:@"%@/%@",strCountItemInProductName,[self countAllItem]];
        headerView.labelAlignRight.text = strCountItem;
        [headerView addSubview:headerView.labelAlignRight];
        [self setLabelUnderline:headerView.labelAlignRight underline:headerView.viewUnderline];
        reusableview = headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        
        reusableview = footerview;
    }
    
    return reusableview;
}

-(NSString *)countAllItem
{
    //count all item
    NSInteger countAllItem = 0;
    for(id keyProductName in _countItemInProductName)
    {
        NSString *countItem = [_countItemInProductName objectForKey:keyProductName];
        countAllItem = countAllItem + [countItem intValue];
    }
    NSString *strCountItem = [NSString stringWithFormat:@"%ld",(long)countAllItem];
    strCountItem = [Utility formatBaht:strCountItem];
    return strCountItem;
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

- (void)loadViewProcess
{
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
    
    ProductCategory2 *productCategory2 = _productCategory2List[row];
    txtMainCategory.text = productCategory2.name;
    [self queryProduct:productCategory2.code];
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
                                                              [self removeOverlayViews];
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
