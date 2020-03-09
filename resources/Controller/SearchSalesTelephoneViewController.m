//
//  SearchSalesTelephoneViewController.m
//  SAIM_UPDATING
//
//  Created by Thidaporn Kijkamjai on 5/26/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "SearchSalesTelephoneViewController.h"
#import "CustomUICollectionViewCellButton.h"
#import "CustomUICollectionReusableView.h"
#import "Utility.h"
#import "SharedPostCustomer.h"
#import "PostCustomer.h"
#import "QRCodeImageViewController.h"
#import "SalesDetailViewController.h"
#import "SharedCustomerReceipt.h"
#import "CustomerReceipt.h"


#define orangeColor         [UIColor colorWithRed:253/255.0 green:182/255.0 blue:103/255.0 alpha:1]
#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]


@interface SearchSalesTelephoneViewController ()<UISearchBarDelegate>
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSArray *_postCustomerList;
    NSMutableArray *_mutArrPostCustomerList;
    NSMutableSet *_mutSetPostCustomerList;
    NSMutableArray *_mutArrCustomerReceiptList;
    NSInteger _selectedIndexPathForRow;
    NSInteger _postCustomerID;
    
    
    NSInteger _page;
    NSInteger _lastItemReached;
    NSString *_telephone;
}
@property (nonatomic,strong) NSArray        *dataSource;
@property (nonatomic,strong) NSArray        *dataSourceForSearchResult;
@property (nonatomic)        BOOL           searchBarActive;
@property (nonatomic)        float          searchBarBoundsY;

@end

@implementation SearchSalesTelephoneViewController
static NSString * const reuseIdentifier = @"Cell";
static NSString * const reuseHeaderViewIdentifier = @"HeaderView";
static NSString * const reuseFooterViewIdentifier = @"FooterView";


@synthesize colViewProductItem;


- (IBAction)unwindToSearchSalesTelephone:(UIStoryboardSegue *)segue
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
    
    
    self.searchBar.delegate = self;
    self.navigationItem.title = [NSString stringWithFormat:@"Search Sales (Telephone)"];
    
    
    [self loadingOverlayView];
    _mutArrPostCustomerList = [[NSMutableArray alloc]init];
    _page = 1;
    NSString *strPage = [NSString stringWithFormat:@"%ld",_page];
    [_homeModel downloadItems:dbSearchSales condition:@[_searchBar.text,strPage]];
//    [self loadViewProcess];
}

-(void)addToMutArrPostCustomer:(NSArray *)postCustomerList
{
    for(int i=0; i<postCustomerList.count; i++)
    {
        PostCustomer *postCustomer = postCustomerList[i];
//        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_postCustomerID = %ld",postCustomer.postCustomerID];
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_firstName = %@ and _telephone = %@",postCustomer.firstName,postCustomer.telephone];
        NSArray *filterArray = [_mutArrPostCustomerList filteredArrayUsingPredicate:predicate1];
        if(filterArray.count == 0)
        {
            [_mutArrPostCustomerList addObject:postCustomer];
        }
    }
}

- (void)itemsDownloaded:(NSArray *)items
{
    [self removeOverlayViews];
    if(_page == 1)
    {
        [_mutArrPostCustomerList removeAllObjects];
    }
    
    
    int i=0;
    [self addToMutArrPostCustomer:items[i++]];

    
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
//    [self queryData];
//    [self setData];
//}
//-(void)queryData
//{
//    _mutArrCustomerReceiptList = [SharedCustomerReceipt sharedCustomerReceipt].customerReceiptList;
//    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_postCustomerID != %ld",0];
//    NSArray *filterArray = [_mutArrCustomerReceiptList filteredArrayUsingPredicate:predicate1];
//    _mutArrCustomerReceiptList = [filterArray mutableCopy];
//
//
//    _mutSetPostCustomerList = [[NSMutableSet alloc]init];
//    for(CustomerReceipt *item in _mutArrCustomerReceiptList)
//    {
//        PostCustomer *postCustomer = [Utility getPostCustomer:item.postCustomerID];
//        if(postCustomer)
//        {
//            [_mutSetPostCustomerList addObject:postCustomer];
//        }
//        else
//        {
//            NSLog(@"postcustomer id in customer receipt: %ld",item.postCustomerID);
//        }
//    }
//    _mutArrPostCustomerList = [[_mutSetPostCustomerList allObjects] mutableCopy];
//}
-(void)setData
{
    if(self.searchBarActive)
    {
        _postCustomerList = self.dataSourceForSearchResult;
    }
    else
    {
        _postCustomerList = _mutArrPostCustomerList;
    }
    
    
//    {
//        //sort
//        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_firstName" ascending:YES];
//        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
//        NSArray *filterArray = [_postCustomerList sortedArrayUsingDescriptors:sortDescriptors];
//        _postCustomerList = [filterArray mutableCopy];
//    }
    
    
    int i=0;
    for(PostCustomer *item in _postCustomerList)
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
        rowNo = [_postCustomerList count];
    }
    
    
    NSInteger countColumn = 3;
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
    
    NSArray *header = @[@"No",@"Name",@"Sales"];
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
    else if(item%countColumn == 0)
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
    else if(item%countColumn == 1)
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

    
    if(item/countColumn == 0)
    {
        NSInteger remainder = item%countColumn;
        cell.label.text = header[remainder];
    }
    else
    {
        PostCustomer *postCustomer = _postCustomerList[item/countColumn-1];
        
        if (!_lastItemReached && (item/countColumn-1 == [_postCustomerList count]-1) && item%countColumn == 2)
        {
            NSString *strPage = [NSString stringWithFormat:@"%ld",_page];
            [_homeModel downloadItems:dbSearchSales condition:@[_searchBar.text,strPage]];
        }
        
        switch (item%countColumn)
        {
            case 0:
            {
                cell.label.text = postCustomer.row;
            }
                break;
            case 1:
            {
                cell.label.text = postCustomer.firstName;
            }
                break;
            case 2:
            {
                cell.imageView.image = [UIImage imageNamed:@"show.png"];
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
                [cell.singleTap removeTarget:self action:@selector(showSales:)];
                [cell.singleTap addTarget:self action:@selector(showSales:)];
                cell.singleTap.numberOfTapsRequired = 1;
                cell.singleTap.numberOfTouchesRequired = 1;
                [cell.imageView addGestureRecognizer:cell.singleTap];
                
                [cell addSubview:cell.leftBorder];
                [cell addSubview:cell.topBorder];
                [cell addSubview:cell.rightBorder];
                [cell addSubview:cell.bottomBorder];
            }
                break;
            default:
                break;
        }
    }
    
    return cell;
}

- (void) showSales:(UIGestureRecognizer *)gestureRecognizer
{
    NSInteger countColumn = 3;
    UIView* view = gestureRecognizer.view;
    
    _selectedIndexPathForRow = view.tag;
    PostCustomer *postCustomer = _postCustomerList[_selectedIndexPathForRow/countColumn-1];
//    _postCustomerID = postCustomer.postCustomerID;
    _telephone = postCustomer.telephone;
    
    [self performSegueWithIdentifier:@"segSalesDetail" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segSalesDetail"])
    {
        SalesDetailViewController *vc = segue.destinationViewController;
        vc.telephone = _telephone;
//        vc.postCustomerID = _postCustomerID;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //    [@"No",@"Name",@"Sales"];
    CGFloat width;
    NSArray *arrSize;
    arrSize = @[@26,@0,@44];
    
    
    width = [arrSize[indexPath.item%[arrSize count]] floatValue];
    if(width == 0)
    {
        width = colViewProductItem.bounds.size.width;
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
        NSString *strCountItem = [NSString stringWithFormat:@"%ld",self.searchBarActive?self.dataSourceForSearchResult.count:[_postCustomerList count]];
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
    NSPredicate *resultPredicate    = [NSPredicate predicateWithFormat:@"_firstName contains[c] %@ || _telephone contains[c] %@", searchText,searchText,searchText];
    self.dataSourceForSearchResult  = [_mutArrPostCustomerList filteredArrayUsingPredicate:resultPredicate];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    // Do the search...
    
    _page = 1;
    NSString *strPage = [NSString stringWithFormat:@"%ld",_page];
    [self loadingOverlayView];
    [_homeModel downloadItems:dbSearchSales condition:@[_searchBar.text,strPage]];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    // user did type something, check our datasource for text that looks the same
//    if (searchText.length>0)
//    {
//        // search and reload data source
//        self.searchBarActive = YES;
//        [self filterContentForSearchText:searchText scope:@""];
//        [self setData];
//    }
//    else{
//        // if text lenght == 0
//        // we will consider the searchbar is not active
//        //        self.searchBarActive = NO;
//
//        [self cancelSearching];
//        [self setData];
//    }
    if (searchText.length == 0)
    {
        // if text lenght == 0
        // we will consider the searchbar is not active
        //        self.searchBarActive = NO;

        [self cancelSearching];
//        [self setData];
        _page = 1;
        NSString *strPage = [NSString stringWithFormat:@"%ld",_page];
        [self loadingOverlayView];
        [_homeModel downloadItems:dbSearchSales condition:@[_searchBar.text,strPage]];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self cancelSearching];
    [self setData];
}
//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
//    self.searchBarActive = YES;
//    [self.view endEditing:YES];
//}
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
