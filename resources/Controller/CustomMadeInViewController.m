//
//  CustomMadeInViewController.m
//  SAIM_UPDATING
//
//  Created by Thidaporn Kijkamjai on 6/19/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "CustomMadeInViewController.h"
#import "CustomUICollectionViewCellButton.h"
#import "Utility.h"
#import "ReceiptProductItem.h"
#import "PostDetail.h"
#import "CustomerReceipt.h"
#import "PostCustomer.h"
#import "Receipt.h"
#import "PreOrderScanPostViewController.h"
#import "CustomUICollectionReusableView.h"
#import "PrintAddressViewController.h"

#import "SharedReceipt.h"
#import "SharedReceiptItem.h"
#import "SharedCustomerReceipt.h"
#import "SharedPostCustomer.h"

#import "SharedPushSync.h"
#import "PushSync.h"
#import "ProductName.h"



#define orangeColor         [UIColor colorWithRed:253/255.0 green:182/255.0 blue:103/255.0 alpha:1]
#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]

@interface CustomMadeInViewController ()<UISearchBarDelegate,UISearchControllerDelegate>
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSMutableArray *_postDetailList;
    NSMutableArray *_mutArrPostDetailList;
    NSMutableArray *_selectedPostDetailList;
    UIView *_viewUnderline;
    BOOL _selectButtonClicked;
    NSMutableArray *_arrSelectedRow;
    NSInteger _selectedIndexPathForRow;
    
    NSInteger _page;
    NSInteger _lastItemReached;
    PostDetail *_updatePostDetail;
}
@property (nonatomic,strong) NSArray        *dataSource;
@property (nonatomic,strong) NSMutableArray *dataSourceForSearchResult;
@property (nonatomic)        BOOL           searchBarActive;
@property (nonatomic)        float          searchBarBoundsY;
@end

static NSString * const reuseIdentifier = @"Cell";
static NSString * const reuseHeaderViewIdentifier = @"HeaderView";
static NSString * const reuseFooterViewIdentifier = @"FooterView";


@implementation CustomMadeInViewController

@synthesize colViewSummaryTable;
@synthesize btnSelectAll;
@synthesize btnCMIn;
@synthesize btnAction;
@synthesize btnCancel;

@synthesize btnBack;

- (IBAction)unwindToCustomMadeIn:(UIStoryboardSegue *)segue
{

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
    
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
    
    
    self.navigationItem.title = [NSString stringWithFormat:@"Custom-made in"];
    self.dataSourceForSearchResult = [NSMutableArray new];
    self.searchBar.delegate = self;
    _arrSelectedRow = [[NSMutableArray alloc]init];
    _selectButtonClicked = NO;
    
    [self.navigationItem setRightBarButtonItem:nil];
    [self.navigationItem setRightBarButtonItems:@[btnCMIn]];
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationItem setLeftBarButtonItems:@[btnBack]];
    
    _postDetailList = [[NSMutableArray alloc]init];
    _mutArrPostDetailList = [[NSMutableArray alloc]init];
    _selectedPostDetailList = [[NSMutableArray alloc]init];
    
    
//    [self loadViewProcess];
    [self loadingOverlayView];
    _page = 1;
    NSString *strPage = [NSString stringWithFormat:@"%ld",_page];
    [_homeModel downloadItems:dbCustomMadeIn condition:@[strPage]];
}

-(void)addToMutArrPostDetail:(NSArray *)postDetailList
{
    for(int i=0; i<postDetailList.count; i++)
    {
        PostDetail *postDetail = postDetailList[i];
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_receiptProductItemID = %ld",postDetail.receiptProductItemID];
        NSArray *filterArray = [_mutArrPostDetailList filteredArrayUsingPredicate:predicate1];
        if(filterArray.count == 0)
        {
            postDetail.editType = _selectButtonClicked?@"1":postDetail.editType;
            [_mutArrPostDetailList addObject:postDetail];
        }
    }
}

- (void)itemsDownloaded:(NSArray *)items
{
    [self removeOverlayViews];
    
    int i=0;
    [self addToMutArrPostDetail:items[i++]];
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

-(void)setData
{
    if(self.searchBarActive)
    {
        _postDetailList = self.dataSourceForSearchResult;
    }
    else
    {
        _postDetailList = _mutArrPostDetailList;
    }
    
    
    btnCMIn.enabled = [_postDetailList count]>0;
    
    
    //run row no
    int i=0;
    for(PostDetail *item in _postDetailList)
    {
        i +=1;
        item.row = [NSString stringWithFormat:@"%d", i];
    }
    
    [colViewSummaryTable reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Register cell classes
    [colViewSummaryTable registerClass:[CustomUICollectionViewCellButton class] forCellWithReuseIdentifier:reuseIdentifier];
    [colViewSummaryTable registerClass:[CustomUICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeaderViewIdentifier];
    [colViewSummaryTable registerClass:[CustomUICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:reuseFooterViewIdentifier];
    
    colViewSummaryTable.delegate = self;
    colViewSummaryTable.dataSource = self;
    
    
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
        rowNo = [_postDetailList count];
    }
    
    
    NSInteger countColumn = 5;
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
        header = @[@"SEL",@"No",@"Product",@"Customer name",@"Order date"];
    }
    else
    {
        header = @[@"CM In",@"No",@"Product",@"Customer name",@"Order date"];
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
    else if(item%countColumn == 1)
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
    
    
    if(item/countColumn == 0)
    {
        NSInteger remainder = item%countColumn;
        cell.label.text = header[remainder];
    }
    else
    {
        PostDetail *postDetail = _postDetailList[item/countColumn-1];
        
        if (!_lastItemReached && (item/countColumn-1 == [_postDetailList count]-1) && item%countColumn == 4)
        {
            NSString *strPage = [NSString stringWithFormat:@"%ld",_page];
            [_homeModel downloadItems:dbCustomMadeIn condition:@[strPage]];
        }
        
        
        switch (item%countColumn) {
            case 0:
            {
                cell.imageView.userInteractionEnabled = YES;
                [cell addSubview:cell.imageView];
                
                CGRect frame = cell.bounds;
                NSInteger imageSize = 18;
                frame.origin.x = (frame.size.width-imageSize)/2;
                frame.origin.y = (frame.size.height-imageSize)/2;
                frame.size.width = imageSize;
                frame.size.height = imageSize;
                cell.imageView.frame = frame;
                cell.imageView.tag = item;
                
                cell.singleTap.numberOfTapsRequired = 1;
                cell.singleTap.numberOfTouchesRequired = 1;
                [cell.imageView addGestureRecognizer:cell.singleTap];
                
                
                if([postDetail.editType isEqualToString:@"0"])
                {
                    cell.imageView.image = [UIImage imageNamed:@"customMadeIn.png"];
                    [cell.singleTap removeTarget:self action:@selector(updateCustomMadeIn:)];
                    [cell.singleTap removeTarget:self action:@selector(selectRow:)];
                    [cell.singleTap addTarget:self action:@selector(updateCustomMadeIn:)];
                }
                else if([postDetail.editType isEqualToString:@"1"])
                {
                    cell.imageView.image = [UIImage imageNamed:@"unselect.png"];
                    [cell.singleTap removeTarget:self action:@selector(updateCustomMadeIn:)];
                    [cell.singleTap removeTarget:self action:@selector(selectRow:)];
                    [cell.singleTap addTarget:self action:@selector(selectRow:)];
                }
                else if([postDetail.editType isEqualToString:@"2"])
                {
                    cell.imageView.image = [UIImage imageNamed:@"select.png"];
                    [cell.singleTap removeTarget:self action:@selector(updateCustomMadeIn:)];
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
                cell.label.text = postDetail.row;
            }
                break;
            case 2:
            {
                cell.label.text = postDetail.product;
            }
                break;
            case 3:
            {
                cell.label.text = postDetail.customerName;
            }
                break;
            case 4:
            {
                cell.label.text = postDetail.receiptDate;
            }
                break;
            default:
                break;
        }
    }
    
    return cell;
}

- (void) updateCustomMadeIn:(UIGestureRecognizer *)gestureRecognizer
{
    NSInteger countColumn = 5;
    UIView* view = gestureRecognizer.view;
    _selectedIndexPathForRow = view.tag;
    
    _updatePostDetail = _postDetailList[_selectedIndexPathForRow/countColumn-1];
    NSMutableArray *selectedPostDetailList = [[NSMutableArray alloc]init];
    [selectedPostDetailList addObject:_updatePostDetail];
    
//    NSMutableArray *receiptProductItemList = [[NSMutableArray alloc]init];
////    ReceiptProductItem *receiptProductItem = [Utility getReceiptProductItem:postDetail.receiptProductItemID];
//    ReceiptProductItem *receiptProductItem = [[ReceiptProductItem alloc]init];
//    receiptProductItem.receiptProductItemID = _updatePostDetail.receiptProductItemID;
//    receiptProductItem.customMadeIn = @"1";
//    receiptProductItem.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
//    receiptProductItem.modifiedUser = [Utility modifiedUser];
//    [receiptProductItemList addObject:receiptProductItem];
    
    [self loadingOverlayView];
    [_homeModel updateItems:dbReceiptProductItemUpdateCMIn withData:@[selectedPostDetailList,@"1"]];
    
    
//    [self queryData];
//    [self setData];
//    if(self.searchBarActive)
//    {
//        [self searchBar:self.searchBar textDidChange:self.searchBar.text];
//    }
}
- (void) selectRow:(UIGestureRecognizer *)gestureRecognizer
{
    NSInteger countColumn = 5;
    UIView* view = gestureRecognizer.view;
    
    _selectedIndexPathForRow = view.tag;
    PostDetail *postDetail = _postDetailList[_selectedIndexPathForRow/countColumn-1];
    
    if([postDetail.editType isEqualToString:@"1"])
    {
        postDetail.editType = @"2";
    }
    else if([postDetail.editType isEqualToString:@"2"])
    {
        postDetail.editType = @"1";
    }
    
    //    ทุกตัว select all ก้ให้ show unselect
    //    ทุกตัว unselect all ก้ให้ show select
    //    else select all
    [self updateButtonShowCountSelect];
    [colViewSummaryTable reloadData];
}
-(void)updateButtonShowCountSelect
{
    NSInteger countSelect = 0;
    NSInteger countUnselect = 0;
    for(PostDetail *item in _postDetailList)
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
    if(countUnselect == [_postDetailList count])
    {
        btnSelectAll.title = @"Select all";
    }
    else if(countSelect == [_postDetailList count])
    {
        btnSelectAll.title = @"Unselect all";
    }
    else
    {
        btnSelectAll.title = @"Select all";
    }
    
    if(countSelect != 0)
    {
        {
            btnAction.title = [NSString stringWithFormat:@"CM in(%ld)",countSelect];
        }
    }
    else
    {
        {
            btnAction.title = @"CM in";
        }
    }
}
- (IBAction)scanPostAll:(id)sender {
    _selectButtonClicked = YES;
    btnAction.title = @"CM in";
    [self.navigationItem setRightBarButtonItem:nil];
    [self.navigationItem setRightBarButtonItems:@[btnCancel, btnAction]];
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationItem setLeftBarButtonItem:btnSelectAll];
    
    
    for(PostDetail *item in _postDetailList)
    {
        item.editType = @"1";
    }
    [colViewSummaryTable reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //    @[@"No",@"Product",@"Customer name",@"Tracking no.",@"Order date"];
    
    CGFloat width;
    NSArray *arrSize;
    arrSize = @[@44,@26,@110,@0,@80];
    
    
    width = [arrSize[indexPath.item%[arrSize count]] floatValue];
    if(width == 0)
    {
        width = colViewSummaryTable.bounds.size.width;
        for(int i=0; i<[arrSize count]; i++)
        {
            width = width - [arrSize[i] floatValue];
        }
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
        headerView.labelAlignRight.frame = frame2;
        headerView.labelAlignRight.textAlignment = NSTextAlignmentRight;
        NSString *strCountItem = [NSString stringWithFormat:@"%ld",self.searchBarActive?self.dataSourceForSearchResult.count:[_postDetailList count]];
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

- (IBAction)cancelAction:(id)sender {
    _selectButtonClicked = NO;
    [self.navigationItem setRightBarButtonItem:nil];
    [self.navigationItem setRightBarButtonItems:@[btnCMIn]];
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationItem setLeftBarButtonItems:@[btnBack]];
    
    
    for(PostDetail *item in _postDetailList)
    {
        item.editType = @"0";
    }
    [colViewSummaryTable reloadData];
}

- (IBAction)doAction:(id)sender
{
    
//    _arrSelectedRow = [[NSMutableArray alloc]init];
    [_selectedPostDetailList removeAllObjects];
    BOOL valid = NO;
    if (self.searchBarActive)
    {
        for(PostDetail *item in self.dataSourceForSearchResult)
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
        }
        
        
        
        
        for(PostDetail *item in self.dataSourceForSearchResult)
        {
            if([item.editType isEqualToString:@"2"])
            {
//                ReceiptProductItem *receiptProductItem = [Utility getReceiptProductItem:item.receiptProductItemID];
//                receiptProductItem.customMadeIn = @"1";
//                receiptProductItem.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
//                receiptProductItem.modifiedUser = [Utility modifiedUser];
//                [receiptProductItemList addObject: receiptProductItem];
                [_selectedPostDetailList addObject:item];
            }
        }
    }
    else
    {
        for(PostDetail *item in _postDetailList)
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
        }
        
        for(PostDetail *item in _postDetailList)
        {
            if([item.editType isEqualToString:@"2"])
            {
//                ReceiptProductItem *receiptProductItem = [Utility getReceiptProductItem:item.receiptProductItemID];
//                receiptProductItem.customMadeIn = @"1";
//                receiptProductItem.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
//                receiptProductItem.modifiedUser = [Utility modifiedUser];
                                                   
                [_selectedPostDetailList addObject: item];
            }
        }
    }
    
    
    //set customMadeIn = 1
//    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_receiptProductItemID" ascending:YES];
//    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
//    NSArray *sortArray = [receiptProductItemList sortedArrayUsingDescriptors:sortDescriptors];
//
//
//    float itemsPerConnection = [Utility getNumberOfRowForExecuteSql]+0.0;
//    float countUpdate = ceil([sortArray count]/itemsPerConnection);
//    for(int i=0; i<countUpdate; i++)
//    {
//        NSInteger startIndex = i * itemsPerConnection;
//        NSInteger count = MIN([sortArray count] - startIndex, itemsPerConnection );
//        NSArray *subArray = [sortArray subarrayWithRange: NSMakeRange( startIndex, count )];
//
//        [_homeModel updateItems:dbReceiptProductItemUpdateCMIn withData:subArray];
//    }
    [_homeModel updateItems:dbReceiptProductItemUpdateCMIn withData:@[_selectedPostDetailList,@"1"]];
    
//    [self queryData];
//    [self setData];
//    [colViewSummaryTable reloadData];
}

- (IBAction)selectAllAction:(id)sender {
    if([btnSelectAll.title isEqualToString:@"Select all"])
    {
        btnSelectAll.title = @"Unselect all";
        if (self.searchBarActive)
        {
            for(ProductCost *item in self.dataSourceForSearchResult)
            {
                item.editType = @"2";
            }
        }
        else
        {
            for(PostDetail *item in _postDetailList)
            {
                item.editType = @"2";
            }
        }
        
    }
    else
    {
        btnSelectAll.title = @"Select all";
        if (self.searchBarActive)
        {
            for(ProductCost *item in self.dataSourceForSearchResult)
            {
                item.editType = @"1";
            }
        }
        else
        {
            for(PostDetail *item in _postDetailList)
            {
                item.editType = @"1";
            }
        }
    }
    
    //    ทุกตัว select all ก้ให้ show unselect
    //    ทุกตัว unselect all ก้ให้ show select
    //    else select all
    [self updateButtonShowCountSelect];
    [colViewSummaryTable reloadData];
}
#pragma mark - search
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
    NSPredicate *resultPredicate    = [NSPredicate predicateWithFormat:@"_product contains[c] %@ || _customerName contains[c] %@ || _receiptDate contains[c] %@", searchText,searchText,searchText];
    NSArray *filterArray  = [_mutArrPostDetailList filteredArrayUsingPredicate:resultPredicate];
    self.dataSourceForSearchResult = [filterArray mutableCopy];
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
//    if([_postDetailList count]>0)
//    {
//        PostDetail *postDetail = _postDetailList[0];
//        editOrSelect = [postDetail.editType integerValue]==0;
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
    for(PostDetail *item in _postDetailList)
    {
        if([item.editType integerValue] == 2)
        {
            [copySelectedList addObject:item];
        }
    }
    
    BOOL match;
    for(PostDetail *item in _mutArrPostDetailList)
    {
        match = NO;
        for(PostDetail *copyItem in copySelectedList)
        {
            if([item.productType isEqualToString:copyItem.productType] && ([item.productID integerValue]==[copyItem.productID integerValue]))
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

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//-(void)itemsDownloaded:(NSArray *)items
//{
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
//}
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
    if(_homeModel.propCurrentDB == dbReceiptProductItemUpdateCMIn)
    {
        [self removeOverlayViews];
//        [self queryData];
        [_mutArrPostDetailList removeObject:_updatePostDetail];
        [_mutArrPostDetailList removeObjectsInArray:_selectedPostDetailList];
        
        [self setData];
        if(self.searchBarActive)
        {
            [self searchBar:self.searchBar textDidChange:self.searchBar.text];
        }
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
