//
//  EventStockSummaryViewController.m
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 8/10/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "EventInventorySummaryViewController.h"
#import "ProductWithQuantity.h"
#import "Utility.h"
#import "CustomUICollectionViewCellButton2.h"
#import "SharedSelectedEvent.h"
#import "CustomUICollectionReusableView.h"
#import "SharedProduct.h"
#import "Product.h"
#import "SharedProductSize.h"
#import "ProductSize.h"
#import "SharedProductSales.h"
#import "ProductSales.h"
#import "ProductCategory2.h"
#import "ProductName.h"


#define orangeColor         [UIColor colorWithRed:253/255.0 green:182/255.0 blue:103/255.0 alpha:1]
#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]

@interface EventInventorySummaryViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
//    NSArray *_productWithQuantity;
//    NSMutableDictionary *_dicProductName;
//    NSArray *_sortedProductName;
    NSMutableDictionary *_countItemInProductName;
    UIView *_viewUnderline;
//    NSMutableDictionary *_dicColorAndSizeHead;
    
    
    NSArray *_initial;
}
@end

@implementation EventInventorySummaryViewController
static NSString * const reuseHeaderViewIdentifier = @"HeaderView";
static NSString * const reuseIdentifier = @"Cell";
@synthesize colViewSummaryTable;
@synthesize lblLocation;
@synthesize lblProductCategory2;
@synthesize index;
//@synthesize arrProductCategory2;
//@synthesize mutArrProductWithQuantity;

@synthesize productCategory2List;
@synthesize productNameList;
@synthesize productNameColorList;
@synthesize productNameSizeList;
@synthesize productList;
@synthesize colorList;
@synthesize productSizeList;
@synthesize segConInitial;


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
    
    
//    _productWithQuantity = [[NSArray alloc]init];
//    _dicColorAndSizeHead = [[NSMutableDictionary alloc]init];
//
    
    self.navigationItem.title = [NSString stringWithFormat:@"Event Inventory"];
    lblLocation.text = [NSString stringWithFormat:@"Location: %@",[SharedSelectedEvent sharedSelectedEvent].event.location];
    lblLocation.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    lblLocation.textColor = [UIColor purpleColor];
    
    
    [self loadViewProcess];
}

- (void)loadViewProcess
{
    NSString *strProductCategory2 = @"-";
    if([productCategory2List count]>0)
    {
//        ProductCategory2 *productCategory2 = [Utility getProductCategory2:arrProductCategory2[index]];
//        strProductCategory2 = productCategory2.name;
        ProductCategory2 *productCategory2 = productCategory2List[index];
        strProductCategory2 = productCategory2.name;
    }

    lblProductCategory2.text = [NSString stringWithFormat:@"Main Category: %@", strProductCategory2];
    lblProductCategory2.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    lblProductCategory2.textColor = [UIColor purpleColor];
    

    [colViewSummaryTable reloadData];
//    [self prepareData];
}
//-(void)prepareData
//{
//    if([product count]>0)
//    {
//        NSString *productCategory2 = arrProductCategory2[index];
//        NSString *strEventID = [NSString stringWithFormat:@"%ld",[SharedSelectedEvent sharedSelectedEvent].event.eventID];
//        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_eventID = %@ and _status = %@ and _productCategory2 = %@",strEventID,@"I",productCategory2];
//        _productWithQuantity = [mutArrProductWithQuantity filteredArrayUsingPredicate:predicate1];
//    }
//
//
//
//
//
//    //product name
//    _dicProductName = [[NSMutableDictionary alloc]init];
//    NSString *previousProductName = @"";
//    for(NSInteger i=0; i<_productWithQuantity.count; i++)
//    {
//        ProductWithQuantity *product = _productWithQuantity[i];
//        if(![previousProductName isEqualToString:product.productName])
//        {
//            NSMutableDictionary *dicColor = [[NSMutableDictionary alloc]init];
//            [_dicProductName setValue:dicColor forKey:product.productName];
//            previousProductName = product.productName;
//        }
//    }
//    [self setSizeAndColorForEachProductName];
//
//    //color
//    for(NSInteger i=0; i<_productWithQuantity.count; i++)
//    {
//        ProductWithQuantity *product = _productWithQuantity[i];
//        NSMutableDictionary *dicColor = [_dicProductName objectForKey:product.productName];
//
//        if(![dicColor objectForKey:product.color])
//        {
//            NSMutableDictionary *dicSize = [[NSMutableDictionary alloc]init];
//            [dicColor setValue:dicSize forKey:product.color];
//        }
//    }
//    //add color of no exist
//    for(id keyProductName in _dicProductName)
//    {
//        NSMutableDictionary *dicColor = [_dicProductName objectForKey:keyProductName];
//        NSArray *arrColor = [_dicColorAndSizeHead objectForKey:keyProductName][0];//0=color,1=size
//
//        for(int i=0; i<[arrColor count]; i++)
//        {
//            if(![dicColor objectForKey:arrColor[i]])
//            {
//                NSMutableDictionary *dicSize = [[NSMutableDictionary alloc]init];
//                [dicColor setValue:dicSize forKey:arrColor[i]];
//            }
//        }
//    }
//    //size
//    for(NSInteger i=0; i<_productWithQuantity.count; i++)
//    {
//        ProductWithQuantity *product = _productWithQuantity[i];
//        NSMutableDictionary *dicColor = [_dicProductName objectForKey:product.productName];
//        NSMutableDictionary *dicSize = [dicColor objectForKey:product.color];
//        [dicSize setValue:product.quantity forKey:[Utility getSizeLabel:product.size]];
//    }
//    //add size of no exist
//    for(id keyProductName in _dicProductName)
//    {
//        NSMutableDictionary *dicColor = [_dicProductName objectForKey:keyProductName];
//        for(id keyColor in dicColor)
//        {
//            NSMutableDictionary *dicSize = [dicColor objectForKey:keyColor];
//            NSArray *arrProductSize = [_dicColorAndSizeHead objectForKey:keyProductName][1];//0=color,1=size
//
//            for(int i=0; i<[arrProductSize count]; i++)
//            {
//                ProductSize *productSize = arrProductSize[i];
//                if(![dicSize objectForKey:productSize.sizeLabel])
//                {
//                    [dicSize setValue:@"0" forKey:productSize.sizeLabel];
//                }
//            }
//        }
//    }
//
//
//
//
//    //count item in productname
//    NSInteger count = 0;
//    _countItemInProductName = [[NSMutableDictionary alloc]init];
//    for(id keyProductName in _dicProductName){
//        NSMutableDictionary *dicColor = [_dicProductName objectForKey:keyProductName];
//        for(id keyColor in dicColor)
//        {
//            NSMutableDictionary *dicSize = [dicColor objectForKey:keyColor];
//            for(id keySize in dicSize)
//            {
//                count = count + [[dicSize objectForKey:keySize] intValue];
//            }
//        }
//        [_countItemInProductName setValue:[NSString stringWithFormat:@"%ld", (long)count] forKey:keyProductName];
//        count = 0;
//    }
//
//    [colViewSummaryTable reloadData];
//}
//- (void)setSizeAndColorForEachProductName
//{
//    //put color and size label
//    NSMutableArray *productSalesList = [SharedProductSales sharedProductSales].productSalesList;
//    for(ProductSales *item in productSalesList)
//    {
//        item.colorText = [Utility getColorName:item.color];
//    }
//
//    //get color and size for each productname
//    for(id keyProductName in _dicProductName)
//    {
//        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productSalesSetID = %@ and _productNameID = %ld",@"0",[ProductName getProductNameIDWithName:keyProductName]];
//        NSArray *filterArray = [productSalesList filteredArrayUsingPredicate:predicate1];
//        NSSet *uniqueColor = [NSSet setWithArray:[filterArray valueForKey:@"colorText"]];
//        NSSet *uniqueSize = [NSSet setWithArray:[filterArray valueForKey:@"size"]];
//        NSArray *arrColor = [uniqueColor allObjects];
//        NSArray *arrSize = [uniqueSize allObjects];
//
//
//        NSMutableArray *mutArrSize = [[NSMutableArray alloc]init];
//        for(NSString *item in arrSize)
//        {
//            ProductSize *productSize = [[ProductSize alloc]init];
//            productSize.code = item;
//            productSize.sizeOrder = [NSString stringWithFormat:@"%ld",(long)[Utility getSizeOrder:item]];
//            productSize.sizeLabel = [Utility getSizeLabel:item];
//            [mutArrSize addObject:productSize];
//        }
//
//
//        [_dicColorAndSizeHead setObject:@[arrColor,mutArrSize] forKey:keyProductName];
//    }
//}
- (void)viewDidLoad {
    [super viewDidLoad];

    // Register cell classes
    [colViewSummaryTable registerClass:[CustomUICollectionViewCellButton2 class] forCellWithReuseIdentifier:reuseIdentifier];
    [colViewSummaryTable registerClass:[CustomUICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeaderViewIdentifier];
    colViewSummaryTable.allowsMultipleSelection = YES;
    colViewSummaryTable.delegate = self;
    colViewSummaryTable.dataSource = self;
    
    
    _initial = @[@"ABCD",@"EFGH",@"IJKL",@"MNOPQ",@"RSTU",@"VWXYZ"];    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
//    return [_dicProductName count];
    ProductCategory2 *productCategory2 = productCategory2List[index];
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ and _quantity > 0",productCategory2.code];
    NSArray *filterArray = [productNameList filteredArrayUsingPredicate:predicate1];
    
    
    return [filterArray count];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

//    NSArray *keys = [_dicProductName allKeys];
//    _sortedProductName = [keys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
//
//
//    NSArray *arrColor = [_dicColorAndSizeHead objectForKey:_sortedProductName[section]][0];
//    NSArray *arrProductSize = [_dicColorAndSizeHead objectForKey:_sortedProductName[section]][1];
//
//    return ([arrColor count]+1)*([arrProductSize count]+1);
    ProductCategory2 *productCategory2 = productCategory2List[index];
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ and _quantity > 0",productCategory2.code];
    NSArray *filterArray = [productNameList filteredArrayUsingPredicate:predicate1];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_name" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    productNameList = [[filterArray sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
    ProductName *productName = productNameList[section];
        
    return (productName.colorCount + 1)*(productName.sizeCount + 1);
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
    
    
    ProductName *productName = productNameList[section];
    NSMutableArray *showProductSizeList = [[NSMutableArray alloc]init];
    {
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productNameID = %ld",productName.productNameID];
        NSArray *filterArray = [productNameSizeList filteredArrayUsingPredicate:predicate1];
        
        for(Product *item in filterArray)
        {
            ProductSize *productSize = [self getProductSize:item.size];
            if(productSize)
            {
                [showProductSizeList addObject:productSize];
            }
        }
        
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_intSizeOrder" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
        NSArray *sortArray = [showProductSizeList sortedArrayUsingDescriptors:sortDescriptors];
        showProductSizeList = [sortArray mutableCopy];
    }
    
    
    NSMutableArray *showColorList = [[NSMutableArray alloc]init];
    {
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productNameID = %ld",productName.productNameID];
        NSArray *filterArray = [productNameColorList filteredArrayUsingPredicate:predicate1];
        
        for(Product *item in filterArray)
        {
            Color *color = [self getColor:item.color];
            if(color)
            {
                [showColorList addObject:color];
            }
        }
        
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_name" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
        NSArray *sortArray = [showColorList sortedArrayUsingDescriptors:sortDescriptors];
        showColorList = [sortArray mutableCopy];
    }
    
    NSInteger sizeNum = [showProductSizeList count];
    
    //color label
    if(item == 0)
    {
        cell.label.text = @"";
        cell.label.backgroundColor = tBlueColor;
    }
    else if(item >=1 && item <=sizeNum)
    {
        ProductSize *productSize = showProductSizeList[item-1];
        cell.label.text = productSize.sizeLabel;
        cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
        cell.label.textColor= [UIColor whiteColor];
        cell.label.backgroundColor = tBlueColor;
        cell.label.textAlignment = NSTextAlignmentCenter;
    }
    else if(item !=0 && item%(sizeNum+1) == 0)
    {
        Color *color = showColorList[(item/(sizeNum+1))-1];
        cell.label.text = color.name;
        cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
        cell.label.adjustsFontSizeToFitWidth = YES;        
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
        Color *color = showColorList[(item/(sizeNum+1))-1];
        ProductSize *productSize = showProductSizeList[item%(sizeNum+1)-1];
        NSInteger quantity = [self getSkuQuantityWithProductNameID:productName.productNameID color:color.code size:productSize.code];
        cell.label.text = [NSString stringWithFormat:@"%ld", quantity];
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
    
    
    ProductName *productName = productNameList[indexPath.section];
//    if(productName.quantity == 0)
//    {
//        CGSize size = CGSizeMake(0, 0);
//        return size;
//    }
    NSMutableArray *showProductSizeList = [[NSMutableArray alloc]init];
    {
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productNameID = %ld",productName.productNameID];
        NSArray *filterArray = [productNameSizeList filteredArrayUsingPredicate:predicate1];
        
        for(Product *item in filterArray)
        {
            ProductSize *productSize = [self getProductSize:item.size];
            if(productSize)
            {
                [showProductSizeList addObject:productSize];
            }
        }
        
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_intSizeOrder" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
        NSArray *sortArray = [showProductSizeList sortedArrayUsingDescriptors:sortDescriptors];
        showProductSizeList = [sortArray mutableCopy];
    }
    
    
    NSInteger sizeNum = [showProductSizeList count];
    cellSize = [NSString stringWithFormat:@"%f",(colViewSummaryTable.bounds.size.width-40-70)/sizeNum];//70=size of colorname
    
    NSMutableArray *arrSize = [[NSMutableArray alloc]init];
    [arrSize addObject:@0];
    for(int i=1; i<=sizeNum; i++)
    {
        [arrSize addObject:cellSize];
    }
    
    width = [arrSize[indexPath.item%[arrSize count]] floatValue];
    if(width == 0)
    {
        width = colViewSummaryTable.bounds.size.width;
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
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.colViewSummaryTable.collectionViewLayout;
    
    [layout invalidateLayout];
    [colViewSummaryTable reloadData];
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 20, 20, 20);
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

        ProductName *productName = productNameList[indexPath.section];
        headerView.label.text = productName.name;
        CGRect frame = headerView.bounds;
        frame.origin.x = 20;
        headerView.label.frame = frame;
        [headerView addSubview:headerView.label];
        
        
        CGRect frame2 = headerView.bounds;
        frame2.size.width = frame2.size.width - 20;
        headerView.labelAlignRight.frame = frame2;
        headerView.labelAlignRight.textAlignment = NSTextAlignmentRight;

        NSString *strCountItem = [NSString stringWithFormat:@"%ld/%ld",productName.quantity,[self countAllItem]];
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

-(NSInteger)countAllItem
{
//    //count all item
//    NSInteger countAllItem = 0;
//    for(id keyProductName in _countItemInProductName)
//    {
//        NSString *countItem = [_countItemInProductName objectForKey:keyProductName];
//        countAllItem = countAllItem + [countItem intValue];
//    }
//    NSString *strCountItem = [NSString stringWithFormat:@"%ld",(long)countAllItem];
//    strCountItem = [Utility formatBaht:strCountItem];
//    return strCountItem;
    
    //count all item
    NSInteger allQuantity = 0;
    for(ProductName *item in productNameList)
    {
        allQuantity += item.quantity;
    }
    
    return allQuantity;
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
    ProductName *productName = productNameList[section];
//    if(productName.quantity == 0)
//    {
//        CGSize headerSize = CGSizeMake(collectionView.bounds.size.width, 0);
//        return headerSize;
//    }
    CGSize headerSize = CGSizeMake(collectionView.bounds.size.width, 20);
    return headerSize;
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

-(ProductSize *)getProductSize:(NSString *)code
{
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_code = %@",code];
    NSArray *filterArray = [productSizeList filteredArrayUsingPredicate:predicate1];
    if([filterArray count] > 0)
    {
        return filterArray[0];
    }
    return nil;
}

-(Color *)getColor:(NSString *)code
{
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_code = %@",code];
    NSArray *filterArray = [colorList filteredArrayUsingPredicate:predicate1];
    if([filterArray count] > 0)
    {
        return filterArray[0];
    }
    return nil;
}

-(NSInteger)getSkuQuantityWithProductNameID:(NSInteger)productNameID color:(NSString *)color size:(NSString *)size
{
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productNameID = %ld and _color = %@ and _size = %@",productNameID,color,size];
    NSArray *filterArray = [productList filteredArrayUsingPredicate:predicate1];
    if([filterArray count] > 0)
    {
        Product *product = filterArray[0];
        return product.quantity;
    }
    return 0;
}

- (IBAction)segConInitialDidChanged:(id)sender
{
    NSString *initialLetter = _initial[segConInitial.selectedSegmentIndex];
    NSInteger section = [self getSection:initialLetter];

    [self scrollToSectionHeader:(int)section];
}

-(void) scrollToSectionHeader:(int)section {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    UICollectionViewLayoutAttributes *attribs = [colViewSummaryTable layoutAttributesForSupplementaryElementOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
    CGPoint topOfHeader = CGPointMake(0, attribs.frame.origin.y - colViewSummaryTable.contentInset.top);
    [colViewSummaryTable setContentOffset:topOfHeader animated:YES];
}

-(NSInteger)getSection:(NSString *)initialLetter
{
    for(int j=0; j<[initialLetter length]; j++)
    {
        NSRange needleRange = NSMakeRange(j,1);
        NSString *initial = [initialLetter substringWithRange:needleRange];
        
        for(int i=0; i<[productNameList count]; i++)
        {
            ProductName *productName = productNameList[i];
            NSRange needleRange = NSMakeRange(0,1);
            NSString *productNameInitial = [productName.name substringWithRange:needleRange];
            if([productNameInitial isEqualToString:initial])
            {
                return i;
            }
        }
    }
    
    return 0;
}
@end
