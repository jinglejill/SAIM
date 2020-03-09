//
//  MainInventoryTableCollectionViewController.m
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 8/3/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "MainInventorySummaryViewController.h"
#import "ProductWithQuantity.h"
#import "Utility.h"
#import "CustomUICollectionViewCellButton2.h"
#import "CustomUICollectionReusableView.h"
#import "Product.h"
#import "ProductName.h"
#import "ProductSize.h"
#import "SharedProductSales.h"
#import "ProductSales.h"
#import "SharedProduct.h"
#import "SharedProductSize.h"
#import "SharedProductName.h"
#import "SharedProductCategory2.h"
#import "SharedProductCategory1.h"
#import "SharedColor.h"


#define orangeColor         [UIColor colorWithRed:253/255.0 green:182/255.0 blue:103/255.0 alpha:1]
#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]

@interface MainInventorySummaryViewController (){
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSArray *_productWithQuantity;
    NSMutableArray *_mutArrProductWithQuantity;
    NSMutableDictionary *_dicProductName;
    NSArray *_sortedProductName;
    NSMutableDictionary *_countItemInProductName;
    UIView *_viewUnderline;
    NSMutableDictionary *_dicColorAndSizeHead;
}
@end

@implementation MainInventorySummaryViewController
static NSString * const reuseHeaderViewIdentifier = @"HeaderView";
static NSString * const reuseIdentifier = @"Cell";
@synthesize colViewSummaryTable;
@synthesize btnAllOrRemaining;


- (void)loadView
{
    [super loadView];
    
    // Create new HomeModel object and assign it to _homeModel variable
    _homeModel = [[HomeModel alloc] init];
    _homeModel.delegate = self;
    
    {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);
    }
    
    
    _mutArrProductWithQuantity = [[NSMutableArray alloc]init];
    _dicColorAndSizeHead = [[NSMutableDictionary alloc]init];
    btnAllOrRemaining.title = @"All";
    
    
//    [self loadViewProcess];
    [self loadingOverlayView];    
    [_homeModel downloadItems:dbMainInventory];
}

- (void)itemsDownloaded:(NSArray *)items
{
    [self removeOverlayViews];
    int i=0;
    
//    [self addToMutArrPostDetail:items[i++]];
    [SharedProductName sharedProductName].productNameList = items[i++];
    [SharedColor sharedColor].colorList = items[i++];
    [SharedProductCategory2 sharedProductCategory2].productCategory2List = items[i++];
    [SharedProductCategory1 sharedProductCategory1].productCategory1List = items[i++];
    [SharedProductSize sharedProductSize].productSizeList = items[i++];
    [SharedProduct sharedProduct].productList = items[i++];
    
    
    [self loadViewProcess];
}

- (void)loadViewProcess
{
    [self queryProductWithQuantityAll:NO];
    [self prepareData];
}

-(void)queryProductWithQuantityAll:(BOOL)all
{
    //query data
    //เปลี่บยน status p->i, เรียงลำดับ, สร้าง array ใส่ group กับ count
    
    [_mutArrProductWithQuantity removeAllObjects];
    NSMutableArray *productList = [SharedProduct sharedProduct].productList;
    NSMutableArray *productForQuantityList = [[NSMutableArray alloc]init];
    if(all)
    {
        for(Product *item in productList)
        {
            Product *product = [item copy];
            product.productIDGroup = [Utility getProductIDGroup:item];
            if([item.status isEqualToString:@"P"])
            {
                product.status = @"I";
            }
            [productForQuantityList addObject:product];
        }
    }
    else
    {
        productForQuantityList = productList;
        for(Product *item in productList)
        {
            item.productIDGroup = [Utility getProductIDGroup:item];
        }
    }
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_eventID" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_status" ascending:YES];
    NSSortDescriptor *sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:@"_productIDGroup" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2,sortDescriptor3, nil];
    NSArray *productSort = [productForQuantityList sortedArrayUsingDescriptors:sortDescriptors];
    
    NSMutableArray *groupHead = [[NSMutableArray alloc]init];
    NSMutableArray *groupCount = [[NSMutableArray alloc]init];
    NSInteger countData = 0;
    BOOL firstItem = YES;
    Product *previousProduct = [[Product alloc]init];
    for(Product *item in productSort)
    {
        if(!((item.eventID == previousProduct.eventID) &&
             [item.status isEqualToString:previousProduct.status] &&
             [item.productIDGroup isEqualToString:previousProduct.productIDGroup]))
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
    
    for(int i=0; i<[groupHead count]; i++)
    {
        Product *product = groupHead[i];
        NSString *strEventID = [NSString stringWithFormat:@"%ld",product.eventID];
        NSString *quantity = groupCount[i];
        NSString *productNameGroup = [NSString stringWithFormat:@"%@%@%@",product.productCategory2,product.productCategory1,product.productName];
        ProductWithQuantity *productWithQuantity = [[ProductWithQuantity alloc]init];
        productWithQuantity.productName = [ProductName getNameWithProductNameGroup:productNameGroup];
        productWithQuantity.color = [Utility getColorName:product.color];
        productWithQuantity.size = product.size;
        productWithQuantity.quantity = quantity;
        productWithQuantity.productIDGroup = product.productIDGroup;
        productWithQuantity.eventID = strEventID;
        productWithQuantity.status = product.status;
        
        [_mutArrProductWithQuantity addObject:productWithQuantity];
    }
}
-(void)prepareData
{  
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_eventID = %@ and _status = %@",@"0",@"I"];
    _productWithQuantity = [_mutArrProductWithQuantity filteredArrayUsingPredicate:predicate1];
    
    
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
    
    [colViewSummaryTable reloadData];
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
            productSize.intSizeOrder = [Utility getSizeOrder:item];
            productSize.sizeLabel = [Utility getSizeLabel:item];
            [mutArrSize addObject:productSize];
        }
        
        
        [_dicColorAndSizeHead setObject:@[arrColor,mutArrSize] forKey:keyProductName];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
    // Register cell classes
    [colViewSummaryTable registerClass:[CustomUICollectionViewCellButton2 class] forCellWithReuseIdentifier:reuseIdentifier];
    [colViewSummaryTable registerClass:[CustomUICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeaderViewIdentifier];
    colViewSummaryTable.delegate = self;
    colViewSummaryTable.dataSource = self;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

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
//    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_sizeOrder" ascending:YES];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_intSizeOrder" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortedProductSize = [arrProductSize sortedArrayUsingDescriptors:sortDescriptors];
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
        cell.label.text = [NSString stringWithFormat:@"%@", productSize.sizeLabel];
        cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
        cell.label.textColor= [UIColor whiteColor];
        cell.label.backgroundColor = tBlueColor;
        cell.label.textAlignment = NSTextAlignmentCenter;
    }
    else if(item !=0 && item%(sizeNum+1) == 0)
    {
        cell.label.text = sortedColor[(item/(sizeNum+1))-1];
        cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
        cell.label.textColor= [UIColor blackColor];
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
        cell.label.textColor= [UIColor blackColor];
        cell.label.backgroundColor = [UIColor clearColor];
        cell.label.textAlignment = NSTextAlignmentCenter;
        
        [cell addSubview:cell.leftBorder];
        [cell addSubview:cell.topBorder];
        [cell addSubview:cell.rightBorder];
        [cell addSubview:cell.bottomBorder];
    }
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width;
    NSString *cellSize;
    NSArray *arrProductSize = [_dicColorAndSizeHead objectForKey:_sortedProductName[indexPath.section]][1];//0=color,1=size
    
    
    NSInteger sizeNum = [arrProductSize count];
    cellSize = [NSString stringWithFormat:@"%f",(colViewSummaryTable.bounds.size.width-40-70)/sizeNum];
    
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
    return UIEdgeInsetsMake(0, 20, 20, 20);//top, left, bottom, right
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
        frame.origin.x = 20;
        headerView.label.frame = frame;
        [headerView addSubview:headerView.label];
        
        
        CGRect frame2 = headerView.bounds;
        frame2.size.width = frame2.size.width - 20;
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

- (IBAction)allOrRemaining:(id)sender
{
    if([btnAllOrRemaining.title isEqualToString:@"All"])
    {
        btnAllOrRemaining.title = @"Remaining";
        
        [self queryProductWithQuantityAll:YES];
        [self prepareData];
    }
    else if([btnAllOrRemaining.title isEqualToString:@"Remaining"])
    {
        btnAllOrRemaining.title = @"All";
        
        [self queryProductWithQuantityAll:NO];
        [self prepareData];
    }

    
}
@end
