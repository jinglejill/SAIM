//
//  GenerateQRCodeViewController.m
//  SAIM_UPDATING
//
//  Created by Thidaporn Kijkamjai on 6/25/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "GenerateQRCodeViewController.h"
#import "SharedProductName.h"
#import "SharedProductSales.h"


#import "ProductWithQuantity.h"
#import "Utility.h"
#import "CustomUICollectionViewCellButton2.h"
#import "CustomUICollectionReusableView.h"
#import "SharedProduct.h"
#import "Product.h"
#import "SharedProductSize.h"
#import "ProductSize.h"

#import "ProductSales.h"
#import "PrintQRCodeViewController.h"
#import "SharedGenerateQRCodePage.h"


#define orangeColor         [UIColor colorWithRed:253/255.0 green:182/255.0 blue:103/255.0 alpha:1]
#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]

@interface GenerateQRCodeViewController (){
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSMutableArray *_productSalesList;
    NSInteger _tagTextFieldQuantity;
    NSMutableArray *_mutArrQRCodeQuantity;
    NSString *_productCategory2;    
    
}
@end


@implementation GenerateQRCodeViewController

static NSString * const reuseHeaderViewIdentifier = @"HeaderView";
static NSString * const reuseIdentifier = @"Cell";
@synthesize colViewSummaryTable;
@synthesize txtManufacturingDate;
@synthesize datePickerPeriod;
@synthesize index;
@synthesize arrProductEvent;
@synthesize arrProductCategory2;
@synthesize lblProductCategory2;
@synthesize strMFD;
@synthesize dicGenerateQRCode;
@synthesize dicSectionAndItemToTag;
@synthesize productNameTableList;


- (IBAction)unwindToGenerateQRCode:(UIStoryboardSegue *)segue
{
}
- (void)loadView
{
    [super loadView];
    if(!dicGenerateQRCode)
    {
        dicGenerateQRCode = [[NSMutableDictionary alloc]init];
    }
    if(!dicSectionAndItemToTag)
    {
        dicSectionAndItemToTag = [[NSMutableDictionary alloc]init];
    }
    if(!_mutArrQRCodeQuantity)
    {
        _mutArrQRCodeQuantity = [[NSMutableArray alloc]init];
    }

    [[SharedGenerateQRCodePage sharedGenerateQRCodePage].dicGenerateQRCodePage removeAllObjects];
    productNameTableList = [[NSMutableArray alloc]init];
    txtManufacturingDate.inputView = datePickerPeriod;
    txtManufacturingDate.delegate = self;
    txtManufacturingDate.text = [Utility dateToString:[NSDate date] toFormat:@"dd/MM/yyyy"];
    [datePickerPeriod removeFromSuperview];
    
    
    // Create new HomeModel object and assign it to _homeModel variable
    _homeModel = [[HomeModel alloc] init];
    _homeModel.delegate = self;
    
    {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);        
    }
        
    
    
    [self setPeriodValue];    
    [self loadViewProcess];
}

- (void)loadViewProcess
{
    NSString *strProductCategory2 = @"-";
    if([arrProductCategory2 count]>0)
    {
        ProductCategory2 *productCategory2 = [Utility getProductCategory2:arrProductCategory2[index]];
        strProductCategory2 = productCategory2.name;
    }
    
    lblProductCategory2.text = [NSString stringWithFormat:@"Main Category: %@", strProductCategory2];
    lblProductCategory2.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    lblProductCategory2.textColor = [UIColor purpleColor];
    
    if(strMFD)
    {
        txtManufacturingDate.text = strMFD;
    }
    
    
    if([arrProductCategory2 count]>0)
    {
        _productCategory2 = arrProductCategory2[index];
    }
    [self queryProduct:_productCategory2];
    [colViewSummaryTable reloadData];
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
    
    
    [productNameTableList removeAllObjects];
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
            ProductSize *productSize = [Utility getSize:size];
            productSize.intSizeOrder = [productSize.sizeOrder integerValue];
            [sizeList addObject:productSize];
        }
        
        {
            NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
            NSArray *sortArray = [colorList sortedArrayUsingDescriptors:sortDescriptors];
            colorList = [sortArray mutableCopy];
        }
        {
            NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"intSizeOrder" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
            NSArray *sortArray = [sizeList sortedArrayUsingDescriptors:sortDescriptors];
            sizeList = [sortArray mutableCopy];
        }
        
        [productNameTableList addObject:@[item,colorList,sizeList]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    

    
    // Register cell classes
    [colViewSummaryTable registerClass:[CustomUICollectionViewCellButton2 class] forCellWithReuseIdentifier:reuseIdentifier];
    [colViewSummaryTable registerClass:[CustomUICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeaderViewIdentifier];
    colViewSummaryTable.delegate = self;
    colViewSummaryTable.dataSource = self;
    
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return  [productNameTableList count];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *productNameTable = productNameTableList[section];
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
    
    NSArray *productNameTable = productNameTableList[section];
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
        NSString *strIndex = [NSString stringWithFormat:@"%ld",index];
        NSMutableDictionary *dicGenerateQRCodePage = [SharedGenerateQRCodePage sharedGenerateQRCodePage].dicGenerateQRCodePage;
        NSArray *arrObj = [dicGenerateQRCodePage valueForKey:strIndex];
        if(arrObj)
        {
            dicSectionAndItemToTag = arrObj[0];
        }        
        if([dicSectionAndItemToTag valueForKey:sectionAndItem])
        {
            tag = [dicSectionAndItemToTag valueForKey:sectionAndItem];
        }
        else
        {
            tag = [NSString stringWithFormat:@"%ld",_tagTextFieldQuantity++];
            [dicSectionAndItemToTag setValue:tag forKey:sectionAndItem];
            [dicGenerateQRCodePage setValue:@[dicSectionAndItemToTag,dicGenerateQRCode,productNameTableList] forKey:strIndex];
        }
        cell.textField.tag = [tag integerValue];
        
        
        if([dicGenerateQRCode valueForKey:tag])
        {
            NSString *quantity = [dicGenerateQRCode valueForKey:tag];
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
    //เก็บ section กับ item ใส่ค่า textfield.text (key = [section,item], value = textfield.text)
    NSInteger tag = textField.tag;
    NSString *strTag = [NSString stringWithFormat:@"%ld",tag];
    NSString *strQuantity = [NSString stringWithFormat:@"%ld",[textField.text integerValue]];
    if([textField.text integerValue] > 0)
    {
        [dicGenerateQRCode setValue:strQuantity forKey:strTag];
    }
    else
    {
        [dicGenerateQRCode removeObjectForKey:strTag];
    }
    NSString *strIndex = [NSString stringWithFormat:@"%ld",index];
    NSMutableDictionary *dicGenerateQRCodePage = [SharedGenerateQRCodePage sharedGenerateQRCodePage].dicGenerateQRCodePage;
    [dicGenerateQRCodePage setValue:@[dicSectionAndItemToTag,dicGenerateQRCode,productNameTableList] forKey:strIndex];
}
#pragma mark <UICollectionViewDelegate>


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width;
    NSString *cellSize;
    
    
    NSInteger section = indexPath.section;
    NSArray *productNameTable = productNameTableList[section];
    NSArray *sizeList = productNameTable[2];
    

    cellSize = [NSString stringWithFormat:@"%f",(colViewSummaryTable.bounds.size.width-40-70)/[sizeList count]];
    
    NSMutableArray *arrSize = [[NSMutableArray alloc]init];
    [arrSize addObject:@0];
    for(int i=1; i<=[sizeList count]; i++)
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
        
        
        NSInteger section = indexPath.section;
        NSArray *productNameTable = productNameTableList[section];
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(![textField isEqual:txtManufacturingDate])
    {
        [txtManufacturingDate resignFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([textField isEqual:txtManufacturingDate])
    {
        return NO;
    }
    return YES;
}

// became first responder
- (void)textFieldDidBeginEditing:(UITextField *)textField;
{
    if([textField isEqual:txtManufacturingDate])
    {
        NSString *strPeriod = textField.text;
        NSDate *datePeriod = [Utility stringToDate:strPeriod fromFormat:[Utility setting:vFormatDateDisplay]];
        [datePickerPeriod setDate:datePeriod];
    }
}

- (void)setPeriodValue
{
    NSString *formatedDate = [Utility dateToString:datePickerPeriod.date toFormat:@"dd/MM/yyyy"];
    txtManufacturingDate.text = formatedDate;
    strMFD = formatedDate;
}
- (IBAction)dateAction:(id)sender {
    [self setPeriodValue];
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

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height), 0.0);
    } else {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.width), 0.0);
    }
    
    colViewSummaryTable.contentInset = contentInsets;
    colViewSummaryTable.scrollIndicatorInsets = contentInsets;
//    [colViewSummaryTable scrollToRowAtIndexPath:colViewSummaryTable.editingIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    colViewSummaryTable.contentInset = UIEdgeInsetsZero;
    colViewSummaryTable.scrollIndicatorInsets = UIEdgeInsetsZero;
    
    
//    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
//    [UIView animateWithDuration:rate.floatValue animations:^{
//        self.tableView.contentInset = // insert content inset value here
//        self.tableView.scrollIndicatorInsets = // insert content inset value here
//    }];
}
@end
