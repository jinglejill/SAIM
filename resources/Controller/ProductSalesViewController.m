//
//  ProductSalesViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/26/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "ProductSalesViewController.h"
#import "CustomUICollectionViewCellButton.h"
#import "Utility.h"
#import "ProductSales.h"
#import "SharedProductSales.h"
#import "PricePromotionEditViewController.h"
#import "CustomUICollectionReusableView.h"
#import "ProductName.h"


#define orangeColor         [UIColor colorWithRed:253/255.0 green:182/255.0 blue:103/255.0 alpha:1]
#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]

@interface ProductSalesViewController ()<UISearchBarDelegate>
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSArray *_productSalesList;
    NSMutableArray *_mutArrProductSalesList;
    NSInteger _selectedIndexPathForRow;
    NSString *_strPricePromotion;
    NSMutableArray *_arrSelectedRow;
    BOOL _selectButtonClicked;
    UIView *_viewUnderline;
    
}
@property (nonatomic,strong) NSArray        *dataSource;
@property (nonatomic,strong) NSArray        *dataSourceForSearchResult;
@property (nonatomic)        BOOL           searchBarActive;
@property (nonatomic)        float          searchBarBoundsY;


@end
static NSString * const reuseIdentifier = @"Cell";
static NSString * const reuseHeaderViewIdentifier = @"HeaderView";
static NSString * const reuseFooterViewIdentifier = @"FooterView";
@implementation ProductSalesViewController
@synthesize colViewItem;
@synthesize productSalesSetID;
@synthesize btnCancel;
@synthesize btnEdit;
@synthesize btnSelect;
@synthesize btnSelectAll;
- (IBAction)unwindToProductSales:(UIStoryboardSegue *)segue
{
    PricePromotionEditViewController *source = [segue sourceViewController];
    if(source.edit == YES)
    {
        [self.colViewItem reloadData];
    }
}

- (IBAction)cancelAction:(id)sender {
    _selectButtonClicked = NO;
    [self.navigationItem setRightBarButtonItem:nil];
    [self.navigationItem setRightBarButtonItems:@[btnSelect]];
    [self.navigationItem setLeftBarButtonItem:nil];

    
    for(ProductSales *item in _mutArrProductSalesList)
    {
        item.editType = @"0";
    }
    [self setData];
}

- (IBAction)selectAction:(id)sender {
    _selectButtonClicked = YES;
    [self.navigationItem setRightBarButtonItem:nil];
    [self.navigationItem setRightBarButtonItems:@[btnCancel, btnEdit]];
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationItem setLeftBarButtonItem:btnSelectAll];
    btnSelectAll.title = @"Select all";
    btnEdit.title = @"Edit";
    

    for(ProductSales *item in _mutArrProductSalesList)
    {
        item.editType = @"1";
    }
    [self setData];
}

- (IBAction)editAction:(id)sender {
    
    _arrSelectedRow = [[NSMutableArray alloc]init];
    BOOL valid = NO;
    {
        for(ProductSales *item in _productSalesList)
        {
            if([item.editType isEqualToString:@"2"])
            {
                valid = YES;
                break;
            }
        }
        if(!valid)
        {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                           message:@"Please select item to edit"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        
        for(ProductSales *item in _productSalesList)
        {
            if([item.editType isEqualToString:@"2"])
            {
                NSString *strProductSalesID = [NSString stringWithFormat:@"%ld",item.productSalesID];
                [_arrSelectedRow addObject:strProductSalesID];
            }
        }
    }

    [self performSegueWithIdentifier:@"segPricePromotionEdit" sender:self];
}

- (IBAction)selectAllAction:(id)sender {
    if([btnSelectAll.title isEqualToString:@"Select all"])
    {
        btnSelectAll.title = @"Unselect all";
        for(ProductSales *item in _productSalesList)
        {
            item.editType = @"2";
        }
    }
    else
    {
        btnSelectAll.title = @"Select all";
        for(ProductSales *item in _productSalesList)
        {
            item.editType = @"1";
        }

    }
    
    //    ทุกตัว select all ก้ให้ show unselect
    //    ทุกตัว unselect all ก้ให้ show select
    //    else select all
    [self updateButtonShowCountSelect];
    [colViewItem reloadData];
}
-(void)updateButtonShowCountSelect
{
    NSInteger countSelect = 0;
    NSInteger countUnselect = 0;
    for(ProductSales *item in _productSalesList)
    {
        if([item.editType integerValue] == 1)
        {
            countUnselect++;
        }
        else if([item.editType integerValue] == 2)
        {
            countSelect++;
        }
    }
    if(countUnselect == [_productSalesList count])
    {
        btnSelectAll.title = @"Select all";
    }
    else if(countSelect == [_productSalesList count])
    {
        btnSelectAll.title = @"Unselect all";
    }
    else
    {
        btnSelectAll.title = @"Select all";
    }
    if(countSelect != 0)
    {
        btnEdit.title = [NSString stringWithFormat:@"Edit(%ld)",countSelect];
    }
    else
    {
        btnEdit.title = @"Edit";
    }
}
- (void)loadView
{
    [super loadView];
    
    {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);        
    }
        
    
    self.navigationItem.title = [NSString stringWithFormat:@"Price Offer"];
    self.dataSourceForSearchResult = [NSArray new];
    _arrSelectedRow = [[NSMutableArray alloc]init];
    _selectButtonClicked = NO;
    self.searchBar.delegate = self;
    
    [self.navigationItem setRightBarButtonItem:nil];
    [self.navigationItem setRightBarButtonItems:@[btnSelect]];
    [self.navigationItem setLeftBarButtonItem:nil];
    
    
    [self loadViewProcess];
//    [self loadingOverlayView];
//    _homeModel = [[HomeModel alloc] init];
//    _homeModel.delegate = self;
//    [_homeModel downloadItems:dbProductSales condition:@[productSalesSetID]];
}

- (void)itemsDownloaded:(NSArray *)items
{
    [self removeOverlayViews];
    int i=0;
    
    [SharedProductSales sharedProductSales].productSalesList = items[i++];
    [self loadViewProcess];
}

- (void)loadViewProcess
{
    _mutArrProductSalesList = [SharedProductSales sharedProductSales].productSalesList;
    for(ProductSales *item in _mutArrProductSalesList)
    {
        item.colorText = [Utility getColorName:item.color];
        item.sizeText = [Utility getSizeLabel:item.size];
        item.productNameText = [ProductName getName:item.productNameID];
    }
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productSalesSetID = %@",productSalesSetID];
    NSArray *filterArray = [_mutArrProductSalesList filteredArrayUsingPredicate:predicate1];
    _mutArrProductSalesList = [filterArray mutableCopy];
    
    
    for(ProductSales *item in _mutArrProductSalesList)
    {
        item.editType = @"0";
    }
    [self setData];
}
-(void)setData
{
    if(self.searchBarActive)
    {
        _productSalesList = self.dataSourceForSearchResult;
    }
    else
    {
        _productSalesList = _mutArrProductSalesList;
    }

    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_productNameText" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_colorText" ascending:YES];
    NSSortDescriptor *sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:@"_sizeText" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2,sortDescriptor3, nil];
    _productSalesList = [_productSalesList sortedArrayUsingDescriptors:sortDescriptors];
    
    
    //run row no
    int i=0;
    for(ProductSales *item in _productSalesList)
    {
        i +=1;
        item.row = [NSString stringWithFormat:@"%d", i];
    }
    
    [colViewItem reloadData];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Register cell classes
    [colViewItem registerClass:[CustomUICollectionViewCellButton class] forCellWithReuseIdentifier:reuseIdentifier];
    [colViewItem registerClass:[CustomUICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeaderViewIdentifier];
    [colViewItem registerClass:[CustomUICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:reuseFooterViewIdentifier];
    
    colViewItem.delegate = self;
    colViewItem.dataSource = self;
    
    
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
        rowNo = [_productSalesList count];
    }
    
    
    NSInteger countColumn = 7;
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
    NSArray *header;
    if (_selectButtonClicked)
    {
        header = @[@"SEL",@"No.",@"Item",@"Color",@"Size",@"Price",@"Offer"];
    }
    else
    {
        header = @[@"Edit",@"No.",@"Item",@"Color",@"Size",@"Price",@"Offer"];
    }
    
    NSInteger countColumn = [header count];
    
    if(item/countColumn == 0)
    {
        [cell addSubview:cell.label];
        cell.label.frame = cell.bounds;
        cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
        cell.label.textColor= [UIColor whiteColor];
        cell.label.backgroundColor = tBlueColor;
        cell.label.textAlignment = NSTextAlignmentCenter;
    }
    else if(item%countColumn == 2 || item%countColumn == 3)
    {
        [cell addSubview:cell.label];
        cell.label.frame = cell.bounds;
        cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
        cell.label.textColor= [UIColor blackColor];
        cell.label.backgroundColor = [UIColor clearColor];
        cell.label.textAlignment = NSTextAlignmentLeft;
        
        [cell addSubview:cell.leftBorder];
        [cell addSubview:cell.topBorder];
        [cell addSubview:cell.rightBorder];
        [cell addSubview:cell.bottomBorder];
    }
    else if(item%countColumn == 1 || item%countColumn == 5 || item%countColumn == 6)
    {
        [cell addSubview:cell.label];
        cell.label.frame = cell.bounds;
        cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
        cell.label.textColor= [UIColor blackColor];
        cell.label.backgroundColor = [UIColor clearColor];
        cell.label.textAlignment = NSTextAlignmentRight;
        
        [cell addSubview:cell.leftBorder];
        [cell addSubview:cell.topBorder];
        [cell addSubview:cell.rightBorder];
        [cell addSubview:cell.bottomBorder];
    }
    else if(item%countColumn == 4)
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
    
    
    if(item/countColumn == 0)
    {
        NSInteger remainder = item%countColumn;
        cell.label.text = header[remainder];
    }
    else
    {
        ProductSales *productSales = _productSalesList[item/countColumn-1];
        switch (item%countColumn) {
            case 0:
            {
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
                
                cell.singleTap.numberOfTapsRequired = 1;
                cell.singleTap.numberOfTouchesRequired = 1;
                [cell.imageView addGestureRecognizer:cell.singleTap];
                
                
                if([productSales.editType isEqualToString:@"0"])
                {
                    cell.imageView.image = [UIImage imageNamed:@"edit2.png"];
                    [cell.singleTap removeTarget:self action:@selector(editPricePromotion:)];
                    [cell.singleTap removeTarget:self action:@selector(selectRow:)];
                    [cell.singleTap addTarget:self action:@selector(editPricePromotion:)];
                }
                else if([productSales.editType isEqualToString:@"1"])
                {
                    cell.imageView.image = [UIImage imageNamed:@"unselect.png"];
                    [cell.singleTap removeTarget:self action:@selector(editPricePromotion:)];
                    [cell.singleTap removeTarget:self action:@selector(selectRow:)];
                    [cell.singleTap addTarget:self action:@selector(selectRow:)];
                }
                else if([productSales.editType isEqualToString:@"2"])
                {
                    cell.imageView.image = [UIImage imageNamed:@"select.png"];
                    [cell.singleTap removeTarget:self action:@selector(editPricePromotion:)];
                    [cell.singleTap removeTarget:self action:@selector(selectRow:)];
                    [cell.singleTap addTarget:self action:@selector(selectRow:)];
                }
                
                [cell addSubview:cell.leftBorder];
                [cell addSubview:cell.topBorder];
                [cell addSubview:cell.rightBorder];
                [cell addSubview:cell.bottomBorder];
            }
                break;
            case 1:
            {
                cell.label.text = productSales.row;
            }
                break;
            case 2:
            {
                cell.label.text = productSales.productNameText;
            }
                break;
            case 3:
            {
                cell.label.text = productSales.colorText;
            }
                break;
            case 4:
            {
                cell.label.text = productSales.sizeText;
            }
                break;
            case 5:
            {
                ProductSales *productSalesDefault = [self getProductSalesDefault:productSales];
                NSString *strPrice = productSalesDefault.price;
                cell.label.text = [Utility formatBaht:strPrice withMinFraction:0 andMaxFraction:0];
            }
                break;
            case 6:
            {
                NSString *strPricePromotion = productSales.pricePromotion;
                cell.label.text = [Utility formatBaht:strPricePromotion withMinFraction:0 andMaxFraction:0];
            }
                break;
            default:
                break;
        }
    }
    
    return cell;
}

- (ProductSales *)getProductSalesDefault:(ProductSales*)productSales
{
    NSMutableArray *productSalesList = [SharedProductSales sharedProductSales].productSalesList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productSalesSetID = %@",@"0"];
    NSArray *filterArray = [productSalesList filteredArrayUsingPredicate:predicate1];
    productSalesList = [filterArray mutableCopy];
    for(ProductSales *item in productSalesList)
    {
        if((item.productNameID == productSales.productNameID) && [item.color isEqualToString:productSales.color] && [item.size isEqualToString:productSales.size])
        {
            return item;
        }
    }
    return nil;
}
- (void) editPricePromotion:(UIGestureRecognizer *)gestureRecognizer
{
    NSInteger countColumn = 7;
    UIView* view = gestureRecognizer.view;
    _selectedIndexPathForRow = view.tag;
    
    ProductSales *productSales = _productSalesList[_selectedIndexPathForRow/countColumn-1];
    NSString *strProductSalesID = [NSString stringWithFormat:@"%ld",productSales.productSalesID];
    _strPricePromotion = productSales.pricePromotion;
    _arrSelectedRow = [[NSMutableArray alloc]init];
    [_arrSelectedRow addObject:strProductSalesID];

    
    [self performSegueWithIdentifier:@"segPricePromotionEdit" sender:self];
}
- (void) selectRow:(UIGestureRecognizer *)gestureRecognizer
{
    NSInteger countColumn = 7;
    UIView* view = gestureRecognizer.view;
    
    _selectedIndexPathForRow = view.tag;
    ProductSales *productSales;
    {
        productSales = _productSalesList[_selectedIndexPathForRow/countColumn-1];
    }
    
    if([productSales.editType isEqualToString:@"1"])
    {
        productSales.editType = @"2";
    }
    else if([productSales.editType isEqualToString:@"2"])
    {
        productSales.editType = @"1";
    }
    
    //    ทุกตัว select all ก้ให้ show unselect
    //    ทุกตัว unselect all ก้ให้ show select
    //    else select all
    [self updateButtonShowCountSelect];
    [colViewItem reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segPricePromotionEdit"])
    {
        PricePromotionEditViewController *vc = segue.destinationViewController;
        
        vc.strPricePromotion = _strPricePromotion;
        vc.arrProductSalesID = _arrSelectedRow;
        {
            vc.productSalesList = _productSalesList;
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //    @[@"Select",@"No.",@"Item",@"Color",@"Size",@"Price",@"Price promotion"];
    
    
    CGFloat width;
    NSArray *arrSize = @[@30,@26,@0,@60,@40,@50,@50];
    width = [arrSize[indexPath.item%[arrSize count]] floatValue];
    if(width == 0)
    {
        width = colViewItem.bounds.size.width;
        for(int i=0; i<[arrSize count]; i++)
        {
            width = width - [arrSize[i] floatValue];
        }
        width -= 1;
    }
    
    
    CGSize size = CGSizeMake(width, 30);
    return size;
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.colViewItem.collectionViewLayout;
    
    [layout invalidateLayout];
    [colViewItem reloadData];
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 20, 1);//top, left, bottom, right -> collection view
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
        CustomUICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        
        
        CGRect frame2 = headerView.bounds;
//        frame2.size.width = frame2.size.width - 20;
        headerView.labelAlignRight.frame = frame2;
        headerView.labelAlignRight.textAlignment = NSTextAlignmentRight;
        NSString *strCountItem = [NSString stringWithFormat:@"%ld",self.searchBarActive?self.dataSourceForSearchResult.count:[_productSalesList count]];
        strCountItem = [Utility formatBaht:strCountItem];
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
////    if (section == albumSection) {
//        return CGSizeMake(0, 20);
////    }
//    
//    return CGSizeZero;
//    
//    
    CGSize headerSize = CGSizeMake(collectionView.bounds.size.width, 20);
    return headerSize;
}
#pragma mark - search
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
    NSPredicate *resultPredicate    = [NSPredicate predicateWithFormat:@"_productNameText contains[c] %@ || _colorText contains[c] %@ || _sizeText contains[c] %@ || _price contains[c] %@ || _pricePromotion contains[c] %@", searchText,searchText,searchText,searchText,searchText];
    self.dataSourceForSearchResult  = [_mutArrProductSalesList filteredArrayUsingPredicate:resultPredicate];
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
    
//    BOOL editOrSelect = NO;;
//    if([_productSalesList count]>0)
//    {
//        ProductSales *productSales = _productSalesList[0];
//        editOrSelect = [productSales.editType integerValue]==0;
//    }
//    if(editOrSelect)
//    {
//        return;
//    }
    if(!_selectButtonClicked)
    {
        return;
    }
    
    
    //    ถ้า select all แล้ว narrow search ให้เคลียร์อันที่หลุดออกไป
    //    ถ้า select all แล้ว wider search ไม่ต้องทำไร
    //copy selected row ออกมา
    //clear เป็น o
    //เอา selected row ใส่คืน
    NSMutableArray *copySelectedList = [[NSMutableArray alloc]init];
    for(ProductSales *item in _productSalesList)
    {
        if([item.editType integerValue] == 2)
        {
            [copySelectedList addObject:item];
        }
    }
    
    BOOL match;
    for(ProductSales *item in _mutArrProductSalesList)
    {
        match = NO;
        for(ProductSales *copyItem in copySelectedList)
        {
            if(item.productSalesID == copyItem.productSalesID)
            {
                match = YES;
                item.editType = @"2";
                break;
            }
        }
        if(!match)
        {
            item.editType = @"1";
        }
    }
    
    //    ทุกตัว select all ก้ให้ show unselect
    //    ทุกตัว unselect all ก้ให้ show select
    //    else select all
    [self updateButtonShowCountSelect];
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
@end
