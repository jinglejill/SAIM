//
//  ProductDeleteHistoryViewController.m
//  SAIM_UPDATING
//
//  Created by Thidaporn Kijkamjai on 4/25/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "ProductDeleteHistoryViewController.h"
#import "CustomUICollectionViewCellButton.h"
#import "Utility.h"
#import "SharedProductDelete.h"
#import "ProductDelete.h"
#import "QRCodeImageViewController.h"
#import "CustomUICollectionReusableView.h"
#import "ProductName.h"


#define orangeColor         [UIColor colorWithRed:253/255.0 green:182/255.0 blue:103/255.0 alpha:1]
#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]

@interface ProductDeleteHistoryViewController ()<UISearchBarDelegate>
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSMutableArray *_productDeleteList;
    NSMutableArray *_mutArrProductDeleteList;
    NSInteger _selectedIndexPathForRow;
    NSString *_productCode;
    
    NSInteger _page;
    NSInteger _lastItemReached;
}
@property (nonatomic,strong) NSArray        *dataSource;
@property (nonatomic,strong) NSMutableArray        *dataSourceForSearchResult;
@property (nonatomic)        BOOL           searchBarActive;
@property (nonatomic)        float          searchBarBoundsY;
@end


@implementation ProductDeleteHistoryViewController
static NSString * const reuseIdentifier = @"Cell";
static NSString * const reuseHeaderViewIdentifier = @"HeaderView";
static NSString * const reuseFooterViewIdentifier = @"FooterView";


@synthesize colViewProductItem;


- (IBAction)unwindToProductDeleteHistory:(UIStoryboardSegue *)segue
{
    
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
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);
    }
    
    self.navigationItem.title = [NSString stringWithFormat:@"Product Delete History"];
    self.searchBar.delegate = self;
    
//    [self loadViewProcess];
    _mutArrProductDeleteList = [[NSMutableArray alloc]init];
    [self loadingOverlayView];
    _page = 1;
    NSString *strPage = [NSString stringWithFormat:@"%ld",_page];
    [_homeModel downloadItems:dbProductDelete condition:@[@"0",strPage]];
    
}

-(void)addToMutArrProductDeleteItem:(NSArray *)productDeleteList
{
    for(int i=0; i<productDeleteList.count; i++)
    {
        ProductDelete *productDelete = productDeleteList[i];
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_productDeleteID = %ld",productDelete.productDeleteID];
        NSArray *filterArray = [_mutArrProductDeleteList filteredArrayUsingPredicate:predicate1];
        if(filterArray.count == 0)
        {
            [_mutArrProductDeleteList addObject:productDelete];
        }
    }
}

- (void)itemsDownloaded:(NSArray *)items
{
    [self removeOverlayViews];
    
    int i=0;
    [self addToMutArrProductDeleteItem:items[i++]];
    [self setData];
    
    if([items[0] count] < 40)
    {
        _lastItemReached = YES;
    }
    else
    {
        _page += 1;
    }
}

//- (void)loadViewProcess
//{
//        
//    
//    
//    _mutArrProductDeleteList = [SharedProductDelete sharedProductDelete].productDeleteList;
//    for(ProductDelete *item in _mutArrProductDeleteList)
//    {
//        NSString *productNameGroup = [NSString stringWithFormat:@"%@%@%@",item.productCategory2,item.productCategory1,item.productName];
//        
//        item.productNameText = [ProductName getNameWithProductNameGroup:productNameGroup];
//        item.colorText = [Utility getColorName:item.color];
//        item.sizeText = [Utility getSizeLabel:item.size];
//        item.sizeOrder = [Utility getSizeOrder:item.size];
//        item.modifiedDateText = [Utility formatDate:item.modifiedDate fromFormat:[Utility setting:vFormatDateTimeDB] toFormat:@"dd/MM/yyyy HH:mm"];
//    }
//    
//    [self setData];
//}

-(void)setData
{
    if(self.searchBarActive)
    {
        _productDeleteList = self.dataSourceForSearchResult;
    }
    else
    {
        _productDeleteList = _mutArrProductDeleteList;
    }
    
    
//    {
//        //sort
//        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_modifiedDate" ascending:NO];
//        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
//        NSArray *filterArray = [_productDeleteList sortedArrayUsingDescriptors:sortDescriptors];
//        _productDeleteList = [filterArray mutableCopy];
//    }
    
    
    int i=0;
    for(ProductDelete *item in _productDeleteList)
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
    [colViewProductItem registerClass:[CustomUICollectionViewCellButton class] forCellWithReuseIdentifier:reuseIdentifier];
    [colViewProductItem registerClass:[CustomUICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeaderViewIdentifier];
    [colViewProductItem registerClass:[CustomUICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:reuseFooterViewIdentifier];
    
    colViewProductItem.delegate = self;
    colViewProductItem.dataSource = self;
    
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        rowNo = [_productDeleteList count];
    }
    
    
    NSInteger countColumn = 6;
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
    
    NSArray *header = @[@"No",@"Item",@"Color",@"Size",@"QR",@"Delete Date"];
    NSInteger countColumn = [header count];
    
    if(item/countColumn==0)
    {
        [cell addSubview:cell.label];
        cell.label.frame = cell.bounds;
        cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
        cell.label.textColor= [UIColor whiteColor];
        cell.label.backgroundColor = tBlueColor;
    }
    else if(item%countColumn == 0 || item%countColumn == 1 || item%countColumn == 2 || item%countColumn == 3 || item%countColumn == 5)
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
        ProductDelete *productDelete = _productDeleteList[item/countColumn-1];
        
        if (!_lastItemReached && (item/countColumn-1 == [_productDeleteList count]-1) && item%countColumn == 5)
        {
            NSString *strPage = [NSString stringWithFormat:@"%ld",_page];
            [_homeModel downloadItems:dbProductDelete condition:@[@"0",strPage]];
        }
        
        
        switch (item%countColumn) {
            case 0:
            {
                cell.label.text = productDelete.row;
            }
                break;
            case 1:
            {
                cell.label.text = productDelete.productNameText;
            }
                break;
            case 2:
            {
                cell.label.text = productDelete.colorText;
            }
                break;
            case 3:
            {
                cell.label.text = productDelete.sizeText;
            }
                break;
            case 4:
            {
                cell.imageView.image = [UIImage imageNamed:@"qrcode icon.png"];
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
                [cell.singleTap removeTarget:self action:@selector(showQRCodeImage:)];
                [cell.singleTap addTarget:self action:@selector(showQRCodeImage:)];
                cell.singleTap.numberOfTapsRequired = 1;
                cell.singleTap.numberOfTouchesRequired = 1;
                [cell.imageView addGestureRecognizer:cell.singleTap];
                
                [cell addSubview:cell.leftBorder];
                [cell addSubview:cell.topBorder];
                [cell addSubview:cell.rightBorder];
                [cell addSubview:cell.bottomBorder];
            }
                break;
            case 5:
            {
                cell.label.text = productDelete.modifiedDateText;
            }
                break;
            default:
                break;
        }
    }
    
    return cell;
}

- (void) showQRCodeImage:(UIGestureRecognizer *)gestureRecognizer
{
    NSInteger countColumn = 6;
    UIView* view = gestureRecognizer.view;
    
    _selectedIndexPathForRow = view.tag;
    ProductDelete *productDelete = ((ProductDelete*)_productDeleteList[_selectedIndexPathForRow/countColumn-1]);
    _productCode = [NSString stringWithFormat:@"%@%@%@%@%@%@%@",productDelete.productCategory2,productDelete.productCategory1,productDelete.productName,productDelete.color,productDelete.size,[Utility formatDate:productDelete.manufacturingDate fromFormat:@"yyyy-MM-dd" toFormat:@"yyyyMMdd"],productDelete.productID];
    
    [self performSegueWithIdentifier:@"segQRCodeImage" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segQRCodeImage"])
    {
        QRCodeImageViewController *vc = segue.destinationViewController;
        vc.productCode = _productCode;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width;
    NSInteger countColumn = 6;
    
    //    [@"No",@"Item",@"Color",@"Size",@"Status",@"QR Code"];
    switch (indexPath.item%countColumn) {
        case 0:
            width = 30;
            break;
            //        case 2:
            //            width = 30;
            //            break;
        case 3:
            width = 30;
            break;
        case 4:
            width = 40;
            break;
        case 5:
            width = 110;
            break;
            
        default:
            width = (colViewProductItem.bounds.size.width - 40-30-30-40-110)/2;
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
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        CustomUICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        
        CGRect frame2 = headerView.bounds;
        frame2.size.width = frame2.size.width - 20;
        headerView.labelAlignRight.frame = frame2;
        headerView.labelAlignRight.textAlignment = NSTextAlignmentRight;
        NSString *strCountItem = [NSString stringWithFormat:@"%ld",self.searchBarActive?self.dataSourceForSearchResult.count:[_productDeleteList count]];
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
    NSPredicate *resultPredicate    = [NSPredicate predicateWithFormat:@"_productNameText contains[c] %@ || _colorText contains[c] %@ || _sizeText contains[c] %@ || _modifiedDateText contains[c] %@", searchText,searchText,searchText,searchText];
    self.dataSourceForSearchResult  = [_mutArrProductDeleteList filteredArrayUsingPredicate:resultPredicate];
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
