//
//  EventInventoryItemViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 9/7/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "EventInventoryItemViewController.h"
#import "Utility.h"
#import "CustomUICollectionViewCellButton2.h"
#import "SharedSelectedEvent.h"
#import "CustomUICollectionReusableView.h"
#import "QRCodeImageViewController.h"
#import "SharedProduct.h"
#import "SharedPushSync.h"
#import "PushSync.h"
#import "ProductItem.h"
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



@interface EventInventoryItemViewController ()<UISearchBarDelegate>
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSArray *_productItemList;
    NSMutableArray *_mutArrProductItemList;
    Event *_event;
    UITextView *_txvDetail;
    NSMutableArray *_productListTemp;
    NSInteger _countScanProduct;
    UIView *_viewUnderline;
    NSString *_productCode;
    
    NSString *_productIDDelete;
}

@property (nonatomic,strong) NSArray        *dataSource;
@property (nonatomic,strong) NSArray        *dataSourceForSearchResult;
@property (nonatomic)        BOOL           searchBarActive;
@property (nonatomic)        float          searchBarBoundsY;
@end

@implementation EventInventoryItemViewController
static NSString * const reuseIdentifier = @"Cell";
static NSString * const reuseHeaderViewIdentifier = @"HeaderView";
static NSString * const reuseFooterViewIdentifier = @"FooterView";
@synthesize colViewProductItem;
@synthesize lblLocation;
@synthesize index;
@synthesize arrProductEvent;
@synthesize arrProductCategory2;
@synthesize lblProductCategory2;

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
        
    
    
    self.searchBar.delegate = self;
    _productListTemp = [[NSMutableArray alloc]init];
    _mutArrProductItemList = [[NSMutableArray alloc]init];
    
    self.navigationItem.title = [NSString stringWithFormat:@"Event - Inventory Item"];
    lblLocation.text = [NSString stringWithFormat:@"Location: %@",[SharedSelectedEvent sharedSelectedEvent].event.location];
    lblLocation.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    lblLocation.textColor = [UIColor purpleColor];
    
    _event = [Event getSelectedEvent];
    
    
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
    
    
    if([arrProductCategory2 count]>0)
    {
        NSString *productCategory2 = arrProductCategory2[index];
        NSInteger eventID = [SharedSelectedEvent sharedSelectedEvent].event.eventID;
        NSString *strEventID = [NSString stringWithFormat:@"%ld",eventID];
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_eventID = %ld and _status = %@ and _productCategory2 = %@",eventID,@"I",productCategory2];
        NSArray *filterArray = [arrProductEvent filteredArrayUsingPredicate:predicate1];
        
        
        _mutArrProductItemList = [[NSMutableArray alloc]init];
        for(Product *item in filterArray)
        {
            NSString *productNameGroup = [NSString stringWithFormat:@"%@%@%@",item.productCategory2,item.productCategory1,item.productName];
            ProductItem *productItem = [[ProductItem alloc]init];
            productItem.productID = item.productID;
            productItem.productName = [ProductName getNameWithProductNameGroup:productNameGroup];
            productItem.color = [Utility getColorName:item.color];
            productItem.size = [Utility getSizeLabel:item.size];
            productItem.sizeOrder = [Utility getSizeOrder:item.size];
            productItem.modifiedDate = item.modifiedDate;
            productItem.modifiedDateNoTime = [Utility formatDate:item.modifiedDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd"];
            productItem.modifiedDateText = [Utility formatDate:productItem.modifiedDate fromFormat:[Utility setting:vFormatDateTimeDB] toFormat:@"dd/MM/yyyy HH:mm:ss"];
            productItem.eventID = strEventID;
            productItem.status = item.status;
            [_mutArrProductItemList addObject:productItem];
        }
    }
    
    [self setData];
}

-(void)setData
{
    if(self.searchBarActive)
    {
        _productItemList = self.dataSourceForSearchResult;
    }
    else
    {
        _productItemList = _mutArrProductItemList;
    }
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_modifiedDateNoTime" ascending:NO];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_productName" ascending:YES];
    NSSortDescriptor *sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:@"_color" ascending:YES];
    NSSortDescriptor *sortDescriptor4 = [[NSSortDescriptor alloc] initWithKey:@"_sizeOrder" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2,sortDescriptor3,sortDescriptor4, nil];
    _productItemList = [_productItemList sortedArrayUsingDescriptors:sortDescriptors];
    
    
    
    //run row no
    int i=0;
    for(ProductItem *item in _productItemList)
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
    [colViewProductItem registerClass:[CustomUICollectionViewCellButton2 class] forCellWithReuseIdentifier:reuseIdentifier];
    [colViewProductItem registerClass:[CustomUICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeaderViewIdentifier];
    [colViewProductItem registerClass:[CustomUICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:reuseFooterViewIdentifier];
    
    colViewProductItem.delegate = self;
    colViewProductItem.dataSource = self;

    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
}

#pragma mark <UICollectionViewDataSource>

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
        rowNo = [_productItemList count];
    }
    
    NSInteger countColumn = 6;
    return (rowNo+1)*countColumn;
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
    
    NSInteger item = indexPath.item;
    
    NSArray *header = @[@"No.",@"Item",@"Color",@"Size",@"Datetime",@"Del"];
    NSInteger countColumn = [header count];
    
    if(item/countColumn==0)
    {
        [cell addSubview:cell.label];
        cell.label.frame = cell.bounds;
        cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
        cell.label.textColor= [UIColor whiteColor];
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
        ProductItem *productItem = _productItemList[item/countColumn-1];
        switch (item%countColumn) {
            case 0:
            {
                [cell.buttonDetail setTitle:productItem.row forState:UIControlStateNormal];
                [cell.buttonDetail setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                cell.buttonDetail.titleLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                
                
                
                cell.buttonDetail.tag = item;
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
                
                
                
                cell.buttonDetail.tag = item;
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
                cell.label.text = productItem.modifiedDateText;
            }
                break;
            case 5:
            {
                cell.imageView.tag = [productItem.row integerValue];
                
                [cell.singleTap addTarget:self action:@selector(updateProductEventID:)];
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
    NSInteger item = button.tag;
    NSInteger countColumn = 6;
    if(item/countColumn != 0 && item%countColumn == 1)
    {
        ProductItem *productItem;
        productItem = _productItemList[item/countColumn-1];
        Product *product = [Product getProduct:productItem.productID];
        _productCode = [Utility getProductCode:product];        
        
        [self performSegueWithIdentifier:@"segQRCodeImage" sender:self];
    }
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
        NSInteger item = button.tag;
        NSInteger countColumn = 6;
        ProductItem *productItem = _productItemList[item/countColumn-1];
        NSString *productIDLabel = [NSString stringWithFormat:@"ProductID: %@",productItem.productID];
        
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        CustomUICollectionViewCellButton2 *cell = (CustomUICollectionViewCellButton2*)[self.colViewProductItem cellForItemAtIndexPath:indexPath];
        
        
        _txvDetail = [[UITextView alloc]init];
        _txvDetail.frame = CGRectMake(cell.frame.size.height*3/4+cell.frame.origin.x, cell.frame.size.height*3/4+cell.frame.origin.y+self.colViewProductItem.frame.origin.y, 120, 30);
        _txvDetail.backgroundColor = [UIColor lightGrayColor];//[UIColor colorWithRed:0.901961 green:0.901961 blue:0.901961 alpha:1];
        _txvDetail.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
        _txvDetail.text = productIDLabel;
        [self.view addSubview:_txvDetail];
    }
}

- (void) updateProductEventID:(UIGestureRecognizer *)gestureRecognizer {
    UIView* view = gestureRecognizer.view;
    
    NSString *row = [NSString stringWithFormat:@"%lu", (long)view.tag];
    ProductItem *productItem = (ProductItem *)_productItemList[[row integerValue]-1];
    NSString *productID = productItem.productID;
    _productIDDelete = productID;
    
    NSInteger countColumn = 6;
    NSInteger indexPathItem = ([row integerValue]+1)*countColumn-1;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:indexPathItem inSection:0];
    CustomUICollectionViewCellButton2 *cell = (CustomUICollectionViewCellButton2*)[self.colViewProductItem cellForItemAtIndexPath:indexPath];
    
    //delete with product id -> confirm delete -> delete -> reload collectionview
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:
     [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Delete event product (No.%@)",row]
                              style:UIAlertActionStyleDestructive
                            handler:^(UIAlertAction *action) {
                                [self loadingOverlayView];
                                
                                NSMutableArray *arrProduct = [[NSMutableArray alloc]init];
                                Product *productTemp = [Product getProduct:productID];
                                productTemp.eventID = 0;
                                productTemp.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                                productTemp.modifiedUser = [Utility modifiedUser];
                                
                                
                                [arrProduct addObject:productTemp];
                                [_homeModel updateItems:dbProduct withData:arrProduct];
                            

                                
                
//                                NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productID = %@",productID];
//                                NSArray *filterArray = [_mutArrProductItemList filteredArrayUsingPredicate:predicate1];
//
//                                [_mutArrProductItemList removeObjectsInArray:filterArray];
//                                if(self.searchBarActive)
//                                {
//                                    [self searchBar:self.searchBar textDidChange:self.searchBar.text];
//                                }
//                                else
//                                {
//                                    [self setData];
//                                }
////                                [self removeOverlayViews];
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

- (void)updateSharedProduct:(Product*)product
{
    NSMutableArray *productList = [SharedProduct sharedProduct].productList;
    if(productList != nil)
    {
        for(Product *item in productList)
        {
            if ([item.productID isEqualToString:product.productID])
            {
                item.eventID = 0;
                item.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                item.modifiedUser = [Utility modifiedUser];
                break;
            }
        }
    }
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width;
    NSInteger countColumn = 6;

    //    [@"No",@"Item",@"Color",@"Size",@"Datetime",@"Delete"];
    switch (indexPath.item%countColumn) {
        case 0:
            width = 30;
            break;
        case 3:
            width = 30;
            break;
        case 4:
            width = 130;
            break;
        case 5:
            width = 30;
            break;
        default:
        {
            width = (colViewProductItem.bounds.size.width-30-30-130-30)/2;
        }
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
    return UIEdgeInsetsMake(0, 0, 20, 0);//top, left, bottom, right -> collection view
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
        frame2.size.width = frame2.size.width;
        headerView.labelAlignRight.frame = frame2;
        headerView.labelAlignRight.textAlignment = NSTextAlignmentRight;
        NSString *strCountItem = [NSString stringWithFormat:@"%ld",self.searchBarActive?self.dataSourceForSearchResult.count:[_productItemList count]];
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
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
    NSPredicate *resultPredicate    = [NSPredicate predicateWithFormat:@"_productName contains[c] %@ || _color contains[c] %@ || _size contains[c] %@ || _modifiedDateText contains[c] %@", searchText,searchText,searchText,searchText];
    self.dataSourceForSearchResult  = [_mutArrProductItemList filteredArrayUsingPredicate:resultPredicate];
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

-(void)itemsDownloaded:(NSArray *)items
{
//    {
//        PushSync *pushSync = [[PushSync alloc]init];
//        pushSync.deviceToken = [Utility deviceToken];
//        [_homeModel updateItems:dbPushSyncUpdateByDeviceToken withData:pushSync];
//    }
//
//
//    [Utility itemsDownloaded:items];
//    [self removeOverlayViews];
//    [self loadViewProcess];
}

- (void)itemsFail
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[Utility getConnectionLostTitle]
                                                                   message:[Utility getConnectionLostMessage]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
//                                                              [self loadingOverlayView];
//                                                              [_homeModel downloadItems:dbMaster];
                                                          }];
    
    [alert addAction:defaultAction];
    dispatch_async(dispatch_get_main_queue(),^ {
        [self presentViewController:alert animated:YES completion:nil];
    } );
}
- (void)itemsUpdated
{
    [self removeOverlayViews];
    
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productID = %@",_productIDDelete];
    NSArray *filterArray = [_mutArrProductItemList filteredArrayUsingPredicate:predicate1];
    
    [_mutArrProductItemList removeObjectsInArray:filterArray];
    if(self.searchBarActive)
    {
        [self searchBar:self.searchBar textDidChange:self.searchBar.text];
    }
    else
    {
        [self setData];
    }                        
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
