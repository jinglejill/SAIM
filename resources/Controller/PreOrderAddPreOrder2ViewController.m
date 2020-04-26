//
//  PreOrderViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/1/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "PreOrderAddPreOrder2ViewController.h"
#import "ProductWithQuantity.h"
#import "Utility.h"
#import "CustomUICollectionViewCellButton2.h"
#import "CustomUICollectionReusableView.h"
#import "ProductDetailViewController.h"
#import "Product.h"
#import "SharedProduct.h"
#import "SharedProductBuy.h"
#import "SharedProductSize.h"
#import "ProductSize.h"
#import "SharedProductSales.h"
#import "ProductSales.h"
#import "SharedSelectedEvent.h"
#import "ProductName.h"
#import "SharedReplaceReceiptProductItem.h"
#import "ProductDetail.h"
#import "SharedProductBuy.h"
#import "SharedPostBuy.h"


#define orangeColor         [UIColor colorWithRed:253/255.0 green:182/255.0 blue:103/255.0 alpha:1]
#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]

@interface PreOrderAddPreOrder2ViewController (){
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSArray *_productWithQuantity;
    NSMutableArray *_mutArrProductWithQuantity;
    NSMutableDictionary *_dicProductNameGroup;
    NSArray *_sortedProductName;
    NSString *_preOrderProductIDGroup;
    NSMutableDictionary *_dicColorAndSizeHead;
    NSMutableArray *_eventListNowAndFutureAsc;
    NSString *_strSelectedEventID;
    
    NSMutableArray *_sortProductNameList;
}


@end

@implementation PreOrderAddPreOrder2ViewController
static NSString * const reuseHeaderViewIdentifier = @"HeaderView";
static NSString * const reuseIdentifier = @"testCell";
@synthesize colViewSummaryTable;
@synthesize lblLocation;
@synthesize lblProductCategory2;
@synthesize index;
//@synthesize arrProductCategory2;
//@synthesize mutArrProductWithQuantity;
@synthesize txtPicker;
@synthesize txtLocation;
@synthesize productIDGroup;
@synthesize productCategory2List;
@synthesize productNameList;
@synthesize productNameColorList;
@synthesize productNameSizeList;
@synthesize productList;
@synthesize colorList;
@synthesize productSizeList;


- (void)textFieldDidBeginEditing:(UITextField *)textField;
{
    if([textField isEqual:txtLocation])
    {
        int i=0;
        for(Event*item in _eventListNowAndFutureAsc)
        {
            if(item.eventID == [_strSelectedEventID integerValue])
            {
                [txtPicker selectRow:i inComponent:0 animated:NO];
            }
            i++;
        }
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
    
    Event *event = _eventListNowAndFutureAsc[row];
    txtLocation.text = event.location;
    _strSelectedEventID = [NSString stringWithFormat:@"%ld",event.eventID];
    [Utility setUserDefaultPreOrderEventID:_strSelectedEventID];
    
    [self loadViewProcess];
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [_eventListNowAndFutureAsc count];
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    Event *event = _eventListNowAndFutureAsc[row];
    return event.location;
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    //    int sectionWidth = 300;
    
    return self.view.frame.size.width;
}

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
//    _mutArrProductWithQuantity = [[NSMutableArray alloc]init];
//    _dicColorAndSizeHead = [[NSMutableDictionary alloc]init];
    
    
    lblLocation.hidden = YES;
    txtLocation.hidden = YES;
//    lblLocation.text = @"Location:";
//    lblLocation.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
//    lblLocation.textColor = [UIColor purpleColor];
//
//
//
//    [txtPicker removeFromSuperview];
//    txtLocation.delegate = self;
//    txtLocation.inputView = txtPicker;
//    txtPicker.delegate = self;
//    txtPicker.dataSource = self;
    
    
    
    _eventListNowAndFutureAsc = [Event getEventListNowAndFutureAsc];
    Event *mainStock = [Event getMainEvent];
    [_eventListNowAndFutureAsc insertObject:mainStock atIndex:0];
//    [_eventListNowAndFutureAsc removeObject:[SharedSelectedEvent sharedSelectedEvent].event];
    
    _strSelectedEventID = [Utility getUserDefaultPreOrderEventID];
    Event *event = [Event getEventFromEventList:_eventListNowAndFutureAsc eventID:[_strSelectedEventID integerValue]];
    txtLocation.text = event.location;


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
    

//    [self prepareData];
    [colViewSummaryTable reloadData];

}

//-(void)prepareData
//{
//    if([arrProductCategory2 count]>0)
//    {
//        NSString *productCategory2 = arrProductCategory2[index];
//        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_eventID = %@ and _status = %@ and _productCategory2 = %@",_strSelectedEventID,@"I",productCategory2];
//        _productWithQuantity = [mutArrProductWithQuantity filteredArrayUsingPredicate:predicate1];
//    }
//
//    //productNameGroup
//    _dicProductNameGroup = [[NSMutableDictionary alloc]init];
//    NSString *previousProductNameGroup = @"";
//    for(NSInteger i=0; i<_productWithQuantity.count; i++)
//    {
//        ProductWithQuantity *product = _productWithQuantity[i];
//        if(![previousProductNameGroup isEqualToString:product.productNameGroup])
//        {
//            NSMutableDictionary *dicColor = [[NSMutableDictionary alloc]init];
//            [_dicProductNameGroup setValue:dicColor forKey:product.productNameGroup];
//            previousProductNameGroup = product.productNameGroup;
//        }
//    }
//
//    [self setSizeAndColorForEachProductNameGroup];
//
//
//    //color
//    for(NSInteger i=0; i<_productWithQuantity.count; i++)
//    {
//        ProductWithQuantity *product = _productWithQuantity[i];
//        NSMutableDictionary *dicColor = [_dicProductNameGroup objectForKey:product.productNameGroup];
//
//        if(![dicColor objectForKey:product.color])
//        {
//            NSMutableDictionary *dicSize = [[NSMutableDictionary alloc]init];
//            [dicColor setValue:dicSize forKey:product.color];
//        }
//    }
//
//
//    //add color of not exist
//    for(id keyProductNameGroup in _dicProductNameGroup)
//    {
//        NSMutableDictionary *dicColor = [_dicProductNameGroup objectForKey:keyProductNameGroup];
//        NSArray *arrColor = [_dicColorAndSizeHead objectForKey:keyProductNameGroup][0];//0=color,1=size
//
//        for(int i=0; i<[arrColor count]; i++)
//        {
//            Color *color = arrColor[i];
//            if(![dicColor objectForKey:color.code])
//            {
//                NSMutableDictionary *dicSize = [[NSMutableDictionary alloc]init];
//                [dicColor setValue:dicSize forKey:color.code];
//            }
//        }
//    }
//
//
//    //size
//    for(NSInteger i=0; i<_productWithQuantity.count; i++)
//    {
//        ProductWithQuantity *product = _productWithQuantity[i];
//        NSMutableDictionary *dicColor = [_dicProductNameGroup objectForKey:product.productNameGroup];
//        NSMutableDictionary *dicSize = [dicColor objectForKey:product.color];
//        [dicSize setValue:product.quantity forKey:product.size];
////        [dicSize setValue:product.quantity forKey:[Utility getSizeLabel:product.size]];
//    }
//
//
//    //add size of not exist
//    for(id keyProductNameGroup in _dicProductNameGroup)
//    {
//        NSMutableDictionary *dicColor = [_dicProductNameGroup objectForKey:keyProductNameGroup];
//        for(id keyColor in dicColor)
//        {
//            NSMutableDictionary *dicSize = [dicColor objectForKey:keyColor];
//            NSArray *arrProductSize = [_dicColorAndSizeHead objectForKey:keyProductNameGroup][1];//0=color,1=size
//
//            for(int i=0; i<[arrProductSize count]; i++)
//            {
//                ProductSize *productSize = arrProductSize[i];
//                if(![dicSize objectForKey:productSize.code])
//                {
//                    [dicSize setValue:@"0" forKey:productSize.code];
//                }
//            }
//        }
//    }
//}

//- (void)setSizeAndColorForEachProductNameGroup
//{
//    //put color and size label
//    NSMutableArray *productSalesList = [SharedProductSales sharedProductSales].productSalesList;
//    for(ProductSales *item in productSalesList)
//    {
//        item.colorText = [Utility getColorName:item.color];
//    }
//
//
//    //get color and size for each productIDGroup
//    for(id keyProductNameGroup in _dicProductNameGroup)
//    {
//        ProductName *productName = [ProductName getProductNameWithProductNameGroup:keyProductNameGroup];
//        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productSalesSetID = %@ and _productNameID = %ld",@"0",productName.productNameID];
//        NSArray *filterArray = [productSalesList filteredArrayUsingPredicate:predicate1];
////        NSSet *uniqueColor = [NSSet setWithArray:[filterArray valueForKey:@"colorText"]];
//        NSSet *uniqueColor = [NSSet setWithArray:[filterArray valueForKey:@"color"]];
//        NSSet *uniqueSize = [NSSet setWithArray:[filterArray valueForKey:@"size"]];
//        NSArray *arrColor = [uniqueColor allObjects];
//        NSArray *arrSize = [uniqueSize allObjects];
//
//
//        NSMutableArray *mutArrColor = [[NSMutableArray alloc]init];
//        for(NSString *item in arrColor)
//        {
//            Color *color = [Color getColor:item];
//            [mutArrColor addObject:color];
//        }
//        NSMutableArray *mutArrSize = [[NSMutableArray alloc]init];
//        for(NSString *item in arrSize)
//        {
//            ProductSize *productSize = [[ProductSize alloc]init];
//            productSize.code = item;
//            productSize.sizeOrder = [NSString stringWithFormat:@"%ld",(long)[Utility getSizeOrder:item]];
//            productSize.intSizeOrder = [Utility getSizeOrder:item];
//            productSize.sizeLabel = [Utility getSizeLabel:item];
//            [mutArrSize addObject:productSize];
//        }
//
//
////        [_dicColorAndSizeHead setObject:@[arrColor,mutArrSize] forKey:keyProductNameGroup];
//        [_dicColorAndSizeHead setObject:@[mutArrColor,mutArrSize] forKey:keyProductNameGroup];
//    }
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Register cell classes
    [colViewSummaryTable registerClass:[CustomUICollectionViewCellButton2 class] forCellWithReuseIdentifier:reuseIdentifier];
    [colViewSummaryTable registerClass:[CustomUICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeaderViewIdentifier];
    colViewSummaryTable.delegate = self;
    colViewSummaryTable.dataSource = self;
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tapGesture];
    [tapGesture setCancelsTouchesInView:NO];
    // Do any additional setup after loading the view.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    ProductCategory2 *productCategory2 = productCategory2List[index];
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@",productCategory2.code];
    NSArray *filterArray = [productNameList filteredArrayUsingPredicate:predicate1];
    
    
    return [filterArray count];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    ProductCategory2 *productCategory2 = productCategory2List[index];
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@",productCategory2.code];
    NSArray *filterArray = [productNameList filteredArrayUsingPredicate:predicate1];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_name" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortArray = [filterArray sortedArrayUsingDescriptors:sortDescriptors];
    ProductName *productName = sortArray[section];
        
    return (productName.colorCount + 1)*(productName.sizeCount + 1);
//    
//    NSMutableArray *productNameList = [[NSMutableArray alloc]init];
//        for(id keyProductNameGroup in _dicProductNameGroup)
//        {
//            ProductName *productName = [ProductName getProductNameWithProductNameGroup:keyProductNameGroup];
//            [productNameList addObject:productName];
//        }
//        
//        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_name" ascending:YES];
//        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
//        NSArray *sortArray = [productNameList sortedArrayUsingDescriptors:sortDescriptors];
//        _sortProductNameList = [sortArray mutableCopy];
//        
//        
//        ProductName *productName = sortArray[section];
//        NSString *productNameGroup = [ProductName getProductNameGroupWithProductName:productName];
//        
//        NSArray *arrColor = [_dicColorAndSizeHead objectForKey:productNameGroup][0];
//        NSArray *arrProductSize = [_dicColorAndSizeHead objectForKey:productNameGroup][1];
//        
//        
//        return ([arrColor count]+1)*([arrProductSize count]+1);
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
    
    
    
//    NSInteger section = indexPath.section;
//    NSInteger item = indexPath.item;
//
//    ProductName *productName = _sortProductNameList[section];
//    NSString *productNameGroup = [ProductName getProductNameGroupWithProductName:productName];
//
////    NSDictionary *dicColor = [_dicProductNameGroup objectForKey:productNameGroup];
////    NSArray *keys = [dicColor allKeys];
////    NSArray *sortedColor = [keys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
//
//
//    NSArray *sortedColor;
//    {
//        NSArray *arrColor = [_dicColorAndSizeHead objectForKey:productNameGroup][0];//0=color,1=size
//        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_name" ascending:YES];
//        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
//        sortedColor = [arrColor sortedArrayUsingDescriptors:sortDescriptors];
//    }
//
//
//    NSArray *sortedProductSize;
//    {
//        NSArray *arrProductSize = [_dicColorAndSizeHead objectForKey:productNameGroup][1];//0=color,1=size
//        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_intSizeOrder" ascending:YES];
//        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
//        sortedProductSize = [arrProductSize sortedArrayUsingDescriptors:sortDescriptors];
//    }
//
//    NSInteger sizeNum = [sortedProductSize count];
    
    
    NSInteger section = indexPath.section;
    NSInteger item = indexPath.item;
    
    
    ProductCategory2 *productCategory2 = productCategory2List[index];
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@",productCategory2.code];
    NSArray *filterArray = [productNameList filteredArrayUsingPredicate:predicate1];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_name" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortArray = [filterArray sortedArrayUsingDescriptors:sortDescriptors];
    ProductName *productName = sortArray[section];
    
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
        
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_sizeLabel" ascending:YES];
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
        [cell addSubview:cell.label];
        cell.label.frame = cell.bounds;
        cell.label.text = @"";
        cell.label.backgroundColor = tBlueColor;
    }
    else if(item >=1 && item <=sizeNum)
    {
        [cell addSubview:cell.label];
        cell.label.frame = cell.bounds;
//        ProductSize *productSize = sortedProductSize[item-1];
        ProductSize *productSize = showProductSizeList[item-1];
        cell.label.text = [NSString stringWithFormat:@"%@", productSize.sizeLabel];
        cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
        cell.label.textColor = [UIColor whiteColor];
        cell.label.backgroundColor = tBlueColor;
        cell.label.textAlignment = NSTextAlignmentCenter;
    }
    if(item !=0 && item%(sizeNum+1) == 0)
    {
        [cell addSubview:cell.label];
        cell.label.frame = cell.bounds;
        
        
//        Color *color = sortedColor[(item/(sizeNum+1))-1];
        Color *color = showColorList[(item/(sizeNum+1))-1];
        cell.label.text = color.name;
        cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
        cell.label.adjustsFontSizeToFitWidth = YES;
        cell.label.textColor= [UIColor blackColor];
        cell.label.textAlignment = NSTextAlignmentLeft;
        cell.label.backgroundColor = [UIColor clearColor];
        
        [cell addSubview:cell.leftBorder];
        [cell addSubview:cell.topBorder];
        [cell addSubview:cell.rightBorder];
        [cell addSubview:cell.bottomBorder];
    }
    else if(item >=(sizeNum+1) && item%(sizeNum+1) != 0)
    {
//        NSDictionary *dicSize = [dicColor objectForKey:sortedColor[(item/(sizeNum+1))-1]];
//
//        ProductSize *productSize = sortedProductSize[item%(sizeNum+1)-1];
//        NSString *quantity = [dicSize objectForKey:productSize.sizeLabel];
//        if([quantity integerValue] > 0)
        {
            cell.imageView.image = [UIImage imageNamed:@"sewingMachine2.png"];
            cell.imageView.userInteractionEnabled = YES;
            [cell addSubview:cell.imageView];
            
            CGRect frame = cell.bounds;
            NSInteger imageSize = 26;
            frame.origin.x = (frame.size.width-imageSize)/2;
            frame.origin.y = (frame.size.height-imageSize)/2;
            frame.size.width = imageSize;
            frame.size.height = imageSize;
            cell.imageView.frame = frame;
        }
        [cell addSubview:cell.leftBorder];
        [cell addSubview:cell.topBorder];
        [cell addSubview:cell.rightBorder];
        [cell addSubview:cell.bottomBorder];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger item = indexPath.item;
    
    
    ProductCategory2 *productCategory2 = productCategory2List[index];
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@",productCategory2.code];
    NSArray *filterArray = [productNameList filteredArrayUsingPredicate:predicate1];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_name" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortArray = [filterArray sortedArrayUsingDescriptors:sortDescriptors];
    ProductName *productName = sortArray[section];
    
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
        
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_sizeLabel" ascending:YES];
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
    Color *color = showColorList[(item/(sizeNum+1))-1];
    ProductSize *productSize = showProductSizeList[item%(sizeNum+1)-1];
    productIDGroup = [NSString stringWithFormat:@"%@%@%@%@%@",productName.productCategory2,productName.productCategory1,productName.code,color.code,productSize.code];
    
    
    //check case replace product - add postCustomerID
    ReceiptProductItem *replaceReceiptProductItem = [SharedReplaceReceiptProductItem sharedReplaceReceiptProductItem].replaceReceiptProductItem;
    if(replaceReceiptProductItem.receiptProductItemID != 0)
    {
        NSRange needleRange = NSMakeRange(0,6);
        NSString *productNameGroup = [productIDGroup substringWithRange:needleRange];
        
        needleRange = NSMakeRange(6,2);
        NSString *strColor = [productIDGroup substringWithRange:needleRange];
        
        needleRange = NSMakeRange(8,2);
        NSString *strSize = [productIDGroup substringWithRange:needleRange];
        
        ProductName *productName = [ProductName getProductNameWithProductNameGroup:productNameGroup];
        
        
        //ราคาขายตาม event, ส่วน รูปและdetail ตาม event = 0
        //productsalessetid = event.productsalessetid
        Event *_event = [Event getEvent:[replaceReceiptProductItem.eventID integerValue]];
        ProductSales *productSalesEvent = [Utility getProductSales:productName.productNameID color:strColor size:strSize  productSalesSetID:_event.productSalesSetID];
        NSString *pricePromotion = productSalesEvent.pricePromotion;
        
        
        ProductSales *productSales = [Utility getProductSales:productName.productNameID color:strColor size:strSize  productSalesSetID:@"0"];
        
        
        ProductDetail *productDetail = [[ProductDetail alloc]init];
//        productDetail.productID = product.productID;
        productDetail.productName = productName.name;
        productDetail.color = [Utility getColorName:strColor];
        productDetail.size = strSize;
        productDetail.price = productSales.price;
        productDetail.pricePromotion = pricePromotion;
        productDetail.detail = productSales.detail;
        productDetail.imageDefault = productSales.imageDefault;
//        productDetail.status = product.status;
        productDetail.productIDGroup = productIDGroup;//[Utility getProductIDGroup:product];
//        productDetail.manufacturingDate = product.manufacturingDate;
        
  
        //case replace product - add postCustomerID
        NSMutableArray *postBuyList = [SharedPostBuy sharedPostBuy].postBuyList;
        if([postBuyList count] > 0)
        {
            PostCustomer *postCustomer = postBuyList[0];
            productDetail.postCustomerID = postCustomer.postCustomerID;
        }
        productDetail.replaceProduct = 1;
        productDetail.discount = 2;
        productDetail.discountValue = 0;
        productDetail.discountPercent = 100;
        productDetail.discountReason = @"replace";
        
            
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        
        NSString *price = [formatter stringFromNumber:[NSNumber numberWithFloat:[productDetail.price floatValue]]];
        NSString *strPricePromotion = [formatter stringFromNumber:[NSNumber numberWithFloat:[productDetail.pricePromotion floatValue]]];
        price = [NSString stringWithFormat:@"%@ baht",price];
        strPricePromotion = [NSString stringWithFormat:@"%@ baht",strPricePromotion];
        NSString *imageFileName = productSales.imageDefault;
        
        
        //                enum enumProductBuy{productType,productDetail,image,price,pricePromotion};
        NSMutableArray  *_productBuyList = [SharedProductBuy sharedProductBuy].productBuyList;
        [_productBuyList addObject:[NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"%d",productPreOrder2], productDetail,imageFileName,price,productDetail.pricePromotion,productIDGroup,nil]];
        [self performSegueWithIdentifier:@"segReceipt2" sender:self];
    }
    else
    {
        [self performSegueWithIdentifier:@"segUnwindToProductDetail" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}

#pragma mark <UICollectionViewDelegate>


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width;
    NSString *cellSize;
    
    ProductCategory2 *productCategory2 = productCategory2List[index];
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@",productCategory2.code];
    NSArray *filterArray = [productNameList filteredArrayUsingPredicate:predicate1];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_name" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortArray = [filterArray sortedArrayUsingDescriptors:sortDescriptors];
    ProductName *productName = sortArray[indexPath.section];
    
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
        
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_sizeLabel" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
        NSArray *sortArray = [showProductSizeList sortedArrayUsingDescriptors:sortDescriptors];
        showProductSizeList = [sortArray mutableCopy];
    }
    
    
    NSInteger sizeNum = [showProductSizeList count];
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

    CGSize size = CGSizeMake(width, 30);
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
        
//        ProductName *productName = _sortProductNameList[indexPath.section];
        ProductCategory2 *productCategory2 = productCategory2List[index];
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@",productCategory2.code];
        NSArray *filterArray = [productNameList filteredArrayUsingPredicate:predicate1];
        
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_name" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
        NSArray *sortArray = [filterArray sortedArrayUsingDescriptors:sortDescriptors];
        ProductName *productName = sortArray[indexPath.section];
        
        
        headerView.label.text = productName.name;
        CGRect frame = headerView.bounds;
        frame.origin.x = 20;
        headerView.label.frame = frame;
        [headerView addSubview:headerView.label];
        
        reusableview = headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        
        reusableview = footerview;
    }
    
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
{
    CGSize headerSize = CGSizeMake(collectionView.bounds.size.width, 20);
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
//                                                              exit(0);
                                                          }];
    
    [alert addAction:defaultAction];
    dispatch_async(dispatch_get_main_queue(),^ {
        [self presentViewController:alert animated:YES completion:nil];
    } );
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
@end
