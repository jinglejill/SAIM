//
//  AccountInventoryAddViewController.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 2/1/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import "AccountInventoryAddViewController.h"
#import "CustomUICollectionViewCellButton2.h"
#import "CustomUICollectionReusableView.h"
#import "PushSync.h"
#import "SharedPushSync.h"
#import "Utility.h"
#import "ProductCategory2.h"
#import "SharedProductCategory2.h"
#import "SharedProductName.h"
#import "SharedProductSales.h"
#import "AccountInventory.h"


#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]


@interface AccountInventoryAddViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSMutableArray *_productCategory2List;
    NSInteger _selectedProductCategory2;
    NSMutableArray *_productSalesList;
    NSMutableArray *_productNameTableList;
    NSMutableDictionary *_dicSectionAndItemToTag;
    NSInteger _tagTextFieldQuantity;
    NSMutableDictionary *_dicGenerateQRCode;
}
@end


@implementation AccountInventoryAddViewController
static NSString * const reuseIdentifier = @"Cell";
static NSString * const reuseHeaderViewIdentifier = @"HeaderView";
static NSString * const reuseFooterViewIdentifier = @"FooterView";


@synthesize colViewData;
@synthesize txtDateIn;
@synthesize dtPicker;
@synthesize txtMainCategory;
@synthesize txtPicker;


- (void)textFieldDidBeginEditing:(UITextField *)textField;
{
    if([textField isEqual:txtDateIn])
    {
        NSString *strDate = textField.text;
        NSDate *datePeriod = [Utility stringToDate:strDate fromFormat:@"yyyy-MM-dd"];
        [dtPicker setDate:datePeriod];
    }
}

- (IBAction)datePickerChanged:(id)sender
{
    if([txtDateIn isFirstResponder])
    {
        txtDateIn.text = [Utility dateToString:dtPicker.date toFormat:@"yyyy-MM-dd"];
    }
}

- (id)findFirstResponder:(UIView *)view
{
    if (view.isFirstResponder) {
        return view;
    }
    for (UIView *subView in view.subviews) {
        id responder = [self findFirstResponder:subView];//[subView findFirstResponder];
        if (responder) return responder;
    }
    return nil;
}

- (IBAction)addInventory:(id)sender {
    id responder = [self findFirstResponder:self.view];
    if(responder)
    {
        [responder resignFirstResponder];
    }
    
    
    if([_dicGenerateQRCode count] == 0)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                       message:@"No input inventory"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    
//    _dicGenerateQRCode tag:quantity
//    _dicSectionAndItemToTag section and item:tag
    NSMutableArray *accountInventoryList = [[NSMutableArray alloc]init];
    for(id key in _dicGenerateQRCode)
    {
        NSString *quantity = [_dicGenerateQRCode valueForKey:key];
        NSArray *arrSectionAndItem = [_dicSectionAndItemToTag allKeysForObject:key];
        
        NSString *sectionAndItem = arrSectionAndItem[0];
        NSArray *arrPartSectionAndItem = [sectionAndItem componentsSeparatedByString:@";"];
        
        NSInteger section = [[arrPartSectionAndItem objectAtIndex: 0] integerValue];
        
        
        NSArray *productNameTable = _productNameTableList[section];
        ProductName *productName = productNameTable[0];

        
        AccountInventory *accountInventory = [[AccountInventory alloc]initWithAccountInventoryID:0 productNameID:productName.productNameID quantity:[Utility floatValue:quantity] status:1 inOutDate:[Utility formatDate:txtDateIn.text fromFormat:@"yyyy-MM-dd" toFormat:@"yyyy-MM-dd HH:mm:ss"] runningAccountReceiptHistory:0 modifiedDate:[Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"]];
        
        [accountInventoryList addObject:accountInventory];
    }
    
    [_homeModel insertItems:dbAccountInventory withData:accountInventoryList];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                   message:@"Add inventory success"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              
                                                          }];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
    
    
    [_dicGenerateQRCode removeAllObjects];
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
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);
    }

    
    _dicGenerateQRCode = [[NSMutableDictionary alloc]init];
    _dicSectionAndItemToTag = [[NSMutableDictionary alloc]init];
    _productNameTableList = [[NSMutableArray alloc]init];
    _selectedProductCategory2 = 0;
    
    
    [txtPicker removeFromSuperview];
    txtMainCategory.delegate = self;
    txtMainCategory.inputView = txtPicker;
    txtPicker.delegate = self;
    txtPicker.dataSource = self;
//    txtPicker.showsSelectionIndicator = YES;
    
    
    [dtPicker removeFromSuperview];
    txtDateIn.inputView = dtPicker;
    txtDateIn.delegate = self;
   
    
    txtDateIn.text = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd"];
    
    
    _productCategory2List = [SharedProductCategory2 sharedProductCategory2].productCategory2List;
    _productCategory2List = [ProductCategory2 getProductCategory2SortByOrderNo:_productCategory2List];
    
    
    ProductCategory2 *productCategory2 = _productCategory2List[_selectedProductCategory2];
    txtMainCategory.text = productCategory2.name;

    
    [self queryProduct:productCategory2.code];
}

-(void)queryProduct:(NSString *)productCategory2
{
    _productSalesList = [SharedProductSales sharedProductSales].productSalesList;
    
    for(ProductSales *item in _productSalesList)
    {
        ProductName *productName = [ProductName getProductName:item.productNameID];
        item.productCategory2 = productName.productCategory2;
        item.productNameActive = productName.active;
    }
    
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productCategory2 = %@ and _productNameActive = 1",productCategory2];
    NSArray *filterArray = [_productSalesList filteredArrayUsingPredicate:predicate1];
    
    
    NSSet *uniqueProductNameID = [NSSet setWithArray:[filterArray valueForKey:@"_productNameID"]];
    NSArray *arrProductNameID = [uniqueProductNameID allObjects];
    NSMutableArray *arrProductName = [[NSMutableArray alloc]init];
    for(NSNumber *item in arrProductNameID)
    {
        ProductName *productName = [ProductName getProductName:[item integerValue]];
        [arrProductName addObject:productName];
    }
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortArray = [arrProductName sortedArrayUsingDescriptors:sortDescriptors];
    arrProductName = [sortArray mutableCopy];
    
    
    [_productNameTableList removeAllObjects];
    for(ProductName *item in arrProductName)
    {
        NSInteger productNameID = item.productNameID;
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productNameID = %ld",productNameID];
        NSArray *filterArray = [_productSalesList filteredArrayUsingPredicate:predicate1];
        NSSet *uniqueColor = [NSSet setWithArray:[filterArray valueForKey:@"color"]];
        NSSet *uniqueSize = [NSSet setWithArray:[filterArray valueForKey:@"size"]];
        NSMutableArray *colorList = [[NSMutableArray alloc]init];
        NSMutableArray *sizeList = [[NSMutableArray alloc]init];
        
        for(NSString *color in uniqueColor)
        {
            [colorList addObject:[Utility getColor:color]];
        }
        for(NSString *size in uniqueSize)
        {
            [sizeList addObject:[Utility getSize:size]];
        }
        
        {
            NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
            NSArray *sortArray = [colorList sortedArrayUsingDescriptors:sortDescriptors];
            colorList = [sortArray mutableCopy];
        }
        {
            NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"sizeOrder" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
            NSArray *sortArray = [sizeList sortedArrayUsingDescriptors:sortDescriptors];
            sizeList = [sortArray mutableCopy];
        }
        
        [_productNameTableList addObject:@[item,colorList,sizeList]];
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return  [_productNameTableList count];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *productNameTable = _productNameTableList[section];
    NSArray *colorList = productNameTable[1];
    NSArray *sizeList = productNameTable[2];
    
    return ([colorList count]+1)*([sizeList count]+1);
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
    
    
    NSInteger section = indexPath.section;
    NSInteger item = indexPath.item;
    
    NSArray *productNameTable = _productNameTableList[section];
    NSArray *colorList = productNameTable[1];
    NSArray *sizeList = productNameTable[2];
    NSInteger sizeNum = [sizeList count];
    
    
    //color label
    if(item == 0)
    {
        cell.label.text = @"";
        cell.label.backgroundColor = tBlueColor;
        [cell addSubview:cell.label];
        cell.label.frame = cell.bounds;
    }
    else if(item >= 1 && item <= sizeNum)
    {
        ProductSize *productSize = sizeList[item-1];
        cell.label.text = productSize.sizeLabel;
        cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
        cell.label.textColor= [UIColor whiteColor];
        cell.label.backgroundColor = tBlueColor;
        cell.label.textAlignment = NSTextAlignmentCenter;
        [cell addSubview:cell.label];
        cell.label.frame = cell.bounds;
    }
    else if(item != 0 && item%(sizeNum+1) == 0)
    {
        Color *color = colorList[item/(sizeNum+1)-1];
        cell.label.text = color.name;
        cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
        cell.label.textColor= [UIColor blackColor];
        cell.label.backgroundColor = [UIColor clearColor];
        cell.label.textAlignment = NSTextAlignmentLeft;
        [cell addSubview:cell.label];
        cell.label.frame = cell.bounds;
        
        
        [cell addSubview:cell.leftBorder];
        [cell addSubview:cell.topBorder];
        [cell addSubview:cell.rightBorder];
        [cell addSubview:cell.bottomBorder];
    }
    else if(item >= (sizeNum+1) && item%(sizeNum+1) != 0)
    {
        [cell addSubview:cell.textField];
        cell.textField.frame = cell.bounds;
        cell.textField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
        cell.textField.delegate = self;
        [cell.textField setKeyboardType:UIKeyboardTypeNumberPad];
        
        //key = section;item, value = tag
        NSString *tag;
        NSString *sectionAndItem = [NSString stringWithFormat:@"%ld;%ld",section,item];
        
        if([_dicSectionAndItemToTag valueForKey:sectionAndItem])
        {
            tag = [_dicSectionAndItemToTag valueForKey:sectionAndItem];
        }
        else
        {
            tag = [NSString stringWithFormat:@"%ld",_tagTextFieldQuantity++];
            [_dicSectionAndItemToTag setValue:tag forKey:sectionAndItem];
        }
        cell.textField.tag = [tag integerValue];
        
        
        if([_dicGenerateQRCode valueForKey:tag])
        {
            NSString *quantity = [_dicGenerateQRCode valueForKey:tag];
            cell.textField.text = quantity;
        }
        else
        {
            cell.textField.text = @"";
        }
        
        
        [cell addSubview:cell.leftBorder];
        [cell addSubview:cell.topBorder];
        [cell addSubview:cell.rightBorder];
        [cell addSubview:cell.bottomBorder];
    }
    
    return cell;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if([textField isEqual:txtDateIn])
    {
        return;
    }
    //เก็บ section กับ item ใส่ค่า textfield.text (key = [section,item], value = textfield.text)
    NSInteger tag = textField.tag;
    NSString *strTag = [NSString stringWithFormat:@"%ld",tag];
    NSString *strQuantity = [NSString stringWithFormat:@"%ld",[textField.text integerValue]];
    if([textField.text integerValue] > 0)
    {
        [_dicGenerateQRCode setValue:strQuantity forKey:strTag];
    }
    else
    {
        [_dicGenerateQRCode removeObjectForKey:strTag];
    }
}
#pragma mark <UICollectionViewDelegate>


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width;
    NSString *cellSize;
    
    
    NSInteger section = indexPath.section;
    NSArray *productNameTable = _productNameTableList[section];
    NSArray *sizeList = productNameTable[2];
    
    
    cellSize = [NSString stringWithFormat:@"%f",(colViewData.bounds.size.width-70)/[sizeList count]];
    
    NSMutableArray *arrSize = [[NSMutableArray alloc]init];
    [arrSize addObject:@0];
    for(int i=1; i<=[sizeList count]; i++)
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
        
        
        NSInteger section = indexPath.section;
        NSArray *productNameTable = _productNameTableList[section];
        ProductName *productName = productNameTable[0];
        
        
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
@end
