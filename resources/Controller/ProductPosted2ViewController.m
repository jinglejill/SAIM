//
//  ProductPosted2ViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/19/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "ProductPosted2ViewController.h"
#import "CustomUICollectionViewCellButton2.h"
#import "Utility.h"
#import "SharedReceiptItem.h"
#import "ReceiptProductItem.h"
#import "PostDetail.h"
#import "SharedCustomerReceipt.h"
#import "CustomerReceipt.h"
#import "SharedPostCustomer.h"
#import "PostCustomer.h"
#import "SharedReceipt.h"
#import "Receipt.h"
#import "PreOrderScanUnpostViewController.h"
#import "PreOrderScanUnpost2ViewController.h"
#import "CustomUICollectionReusableView.h"
#import "TrackingNoViewController.h"
#import "ProductName.h"


#define orangeColor         [UIColor colorWithRed:253/255.0 green:182/255.0 blue:103/255.0 alpha:1]
#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]

@interface ProductPosted2ViewController ()<UISearchBarDelegate>
{
    NSArray *_EventSalesSummaryList;
    NSArray *_postDetailList;
    NSMutableArray *_postDetailPortionList;
    NSMutableArray *_mutArrPostDetailList;
    NSString *_preOrderProductID;
    NSString *_preOrderReceiptProductItemID;
    NSMutableArray *_arrSelectedRow;
    UIView *_viewUnderline;
    NSString *_strTrackingNo;
//    NSInteger _receiptID;
    NSInteger _receiptProductItemID;
    NSInteger _postDetailIndex;
    NSInteger _selectedIndexPathForRow;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    BOOL _firstPortion;
    NSArray *_arrSortReceiptDate;
    BOOL _deleteItem;
    NSInteger _countPortion;
    BOOL _selectButtonClicked;
    BOOL _isUnwind;
    UITextView *_txvDetail;
    NSMutableArray *_eventListNowAndFutureAsc;
    NSString *_strSelectedEventID;
    HomeModel *_homeModel;
    NSInteger _page;
    NSInteger _lastItemReached;
}
@property (nonatomic,strong) NSArray        *dataSource;
@property (nonatomic,strong) NSArray        *dataSourceForSearchResult;
@property (nonatomic)        BOOL           searchBarActive;
@property (nonatomic)        float          searchBarBoundsY;
@end

static NSString * const reuseIdentifier = @"Cell";
static NSString * const reuseHeaderViewIdentifier = @"HeaderView";
static NSString * const reuseFooterViewIdentifier = @"FooterView";
@implementation ProductPosted2ViewController
@synthesize colViewSummaryTable;
@synthesize btnUnpost;
@synthesize fromUserMenu;
@synthesize btnAction;
@synthesize btnCancel;
@synthesize btnBack;
@synthesize btnSelectAll;
@synthesize lblLocation;
@synthesize txtPicker;
@synthesize txtLocation;


- (void)textFieldDidBeginEditing:(UITextField *)textField;
{
    if([textField isEqual:txtLocation])
    {
        int i=0;
        for(Event *item in _eventListNowAndFutureAsc)
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
    //[self queryData:NO];
    
    
    
    [_mutArrPostDetailList removeAllObjects];
    _page = 1;
    NSString *strPage = [NSString stringWithFormat:@"%ld",_page];
    [self loadingOverlayView];
    [_homeModel downloadItems:dbPostDetailSearch condition:@[_strSelectedEventID,strPage,_searchBar.text]];
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

- (IBAction)unwindToProductPosted2:(UIStoryboardSegue *)segue
{
    _isUnwind = YES;
    if([[segue sourceViewController] isMemberOfClass:[TrackingNoViewController class]])
    {
        TrackingNoViewController *source = [segue sourceViewController];
        if(source.edit == YES) //ความจริงแค่ reload column ก็พอ
        {
            [colViewSummaryTable reloadData];
        }
    }
    else if([[segue sourceViewController] isMemberOfClass:[PreOrderScanUnpost2ViewController class]])
    {
        if(self.searchBarActive)
        {
            [self searchBar:self.searchBar textDidChange:self.searchBar.text];
        }
        else
        {
            [self setData];
            [self updateButtonShowCountSelect];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
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
        
    
    self.navigationItem.title = [NSString stringWithFormat:@"Posted Product"];
    self.searchBar.delegate = self;
    _postDetailList = [[NSMutableArray alloc]init];
    _postDetailPortionList = [[NSMutableArray alloc]init];
    _mutArrPostDetailList = [[NSMutableArray alloc]init];
    _deleteItem = NO;
    _selectButtonClicked = NO;
    _isUnwind = NO;
    _txvDetail = [[UITextView alloc]init];
    _txvDetail.editable = NO;
    
    
    [self.navigationItem setRightBarButtonItem:nil];
    [self.navigationItem setRightBarButtonItems:@[btnUnpost]];
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationItem setLeftBarButtonItems:@[btnBack]];
    
    
    lblLocation.text = @"Location:";
    lblLocation.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    lblLocation.textColor = [UIColor purpleColor];
    
    
    
    [txtPicker removeFromSuperview];
    txtLocation.delegate = self;
    txtLocation.inputView = txtPicker;
    txtPicker.delegate = self;
    txtPicker.dataSource = self;
    txtPicker.showsSelectionIndicator = YES;
    
    
    
    _eventListNowAndFutureAsc = [Event getEventListNowAndFutureAsc];
    Event *mainStock = [Event getMainEvent];
    [_eventListNowAndFutureAsc insertObject:mainStock atIndex:0];
    
    
    _strSelectedEventID = [Utility getUserDefaultPreOrderEventID];
    Event *event = [Event getEventFromEventList:_eventListNowAndFutureAsc eventID:[_strSelectedEventID integerValue]];
    txtLocation.text = event.location;
    
    
    _homeModel = [[HomeModel alloc] init];
    _homeModel.delegate = self;
    _page = 1;
    NSString *strPage = [NSString stringWithFormat:@"%ld",_page];
    [self loadingOverlayView];
    [_homeModel downloadItems:dbPostDetailSearch condition:@[_strSelectedEventID,strPage,_searchBar.text]];
//    [self loadViewProcess];
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
    if(_page == 1)
    {
        [_mutArrPostDetailList removeAllObjects];
    }
    int i=0;
    [self addToMutArrPostDetail:items[i++]];
    
    
    if(self.searchBarActive)
    {
        _postDetailList = self.dataSourceForSearchResult;
    }
    else
    {
        _postDetailList = _mutArrPostDetailList;
    }
    
    btnUnpost.enabled = [_postDetailList count]>0;
    
    
    //run row no
    int j=0;
    for(PostDetail *item in _postDetailList)
    {
        j +=1;
        item.row = [NSString stringWithFormat:@"%d", j];
    }
    
    [colViewSummaryTable reloadData];
    
    
    if([items[0] count] < 40)
    {
        _lastItemReached = YES;
    }
    else
    {
        _page += 1;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

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
    
  
    
    btnUnpost.enabled = [_postDetailList count]>0;
    
    
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
    [colViewSummaryTable registerClass:[CustomUICollectionViewCellButton2 class] forCellWithReuseIdentifier:reuseIdentifier];
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
    NSArray *header;
    if (_selectButtonClicked)
    {
        header = @[@"SEL",@"No",@"Product",@"Customer name",@"CH",@"Date"];
    }
    else
    {
        header = @[@"TN",@"No",@"Product",@"Customer name",@"CH",@"Date"];
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
    else if(item%countColumn == 2 || item%countColumn == 3 || item%countColumn == 4)
    {
        [cell addSubview:cell.buttonDetail];
        cell.buttonDetail.frame = cell.bounds;
        
        [cell addSubview:cell.leftBorder];
        [cell addSubview:cell.topBorder];
        [cell addSubview:cell.rightBorder];
        [cell addSubview:cell.bottomBorder];
    }
    else if(item%countColumn == 5 )
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
    else if(item%countColumn == 1 )
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
        if (!_lastItemReached && (item/countColumn-1 == [_postDetailList count]-1) && item%countColumn == 5)
        {
            NSString *strPage = [NSString stringWithFormat:@"%ld",_page];
            [_homeModel downloadItems:dbPostDetailSearch condition:@[_strSelectedEventID,strPage,_searchBar.text]];
        }
        
        PostDetail *postDetail;
        postDetail = _postDetailList[item/countColumn-1];
        
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
                    if([postDetail.trackingNo isEqualToString:@""])
                    {
                        cell.imageView.image = [UIImage imageNamed:@"trackingNoEmpty.png"];
                    }
                    else
                    {
                        cell.imageView.image = [UIImage imageNamed:@"trackingNoFill.png"];
                    }
                    
                    [cell.singleTap removeTarget:self action:@selector(editTrackingNo:)];
                    [cell.singleTap removeTarget:self action:@selector(selectRow:)];
                    [cell.singleTap addTarget:self action:@selector(editTrackingNo:)];
                }
                else if([postDetail.editType isEqualToString:@"1"])
                {
                    cell.imageView.image = [UIImage imageNamed:@"unselect.png"];
                    [cell.singleTap removeTarget:self action:@selector(editTrackingNo:)];
                    [cell.singleTap removeTarget:self action:@selector(selectRow:)];
                    [cell.singleTap addTarget:self action:@selector(selectRow:)];
                }
                else if([postDetail.editType isEqualToString:@"2"])
                {
                    cell.imageView.image = [UIImage imageNamed:@"select.png"];
                    [cell.singleTap removeTarget:self action:@selector(editTrackingNo:)];
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
                [cell.buttonDetail setTitle:postDetail.product forState:UIControlStateNormal];
                [cell.buttonDetail setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                cell.buttonDetail.titleLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                cell.buttonDetail.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                
                
                cell.buttonDetail.tag = item;
                [cell.buttonDetail removeTarget:nil
                                         action:NULL
                               forControlEvents:UIControlEventAllEvents];
                [cell.buttonDetail addTarget:self action:@selector(viewProductItemDetail:)
                            forControlEvents:UIControlEventTouchUpInside];
            }
                break;
            case 3:
            {
                [cell.buttonDetail setTitle:postDetail.customerName forState:UIControlStateNormal];
                [cell.buttonDetail setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                cell.buttonDetail.titleLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                cell.buttonDetail.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                
                
                cell.buttonDetail.tag = item;
                [cell.buttonDetail removeTarget:nil
                                         action:NULL
                               forControlEvents:UIControlEventAllEvents];
                [cell.buttonDetail addTarget:self action:@selector(viewCustomerName:)
                            forControlEvents:UIControlEventTouchUpInside];
            }
                break;
            case 4:
            {
                NSString *strChannel = @"";
                switch (postDetail.channel) {
                    case 0:
                        strChannel = @"Ev";
                        break;
                    case 1:
                        strChannel = @"Wb";
                        break;
                    case 2:
                        strChannel = @"Li";
                        break;
                    case 3:
                        strChannel = @"FB";
                        break;
                    case 4:
                        strChannel = @"Sh";
                        break;
                    case 5:
                        strChannel = @"Ot";
                        break;
                    default:
                        break;
                }
                [cell.buttonDetail setTitle:strChannel forState:UIControlStateNormal];
                [cell.buttonDetail setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                cell.buttonDetail.titleLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                cell.buttonDetail.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                
                
                cell.buttonDetail.tag = item;
                [cell.buttonDetail removeTarget:nil
                                         action:NULL
                               forControlEvents:UIControlEventAllEvents];
                [cell.buttonDetail addTarget:self action:@selector(viewChannelUserID:)
                            forControlEvents:UIControlEventTouchUpInside];
            }
                break;
            case 5:
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

- (PostDetail *)getPostDetail:(NSInteger)receiptProductItemID
{
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_receiptProductItemID = %ld",receiptProductItemID];
    NSArray *arrFilter = [_postDetailList filteredArrayUsingPredicate:predicate1];
    return arrFilter[0];
}

- (void) viewChannelUserID:(id)sender
{
    if([_txvDetail isDescendantOfView:self.view])
    {
        [_txvDetail removeFromSuperview];
    }
    else
    {
        NSInteger countColumn = 6;
        UIButton *button = sender;
        NSInteger item = button.tag;
        PostDetail *postDetail = _postDetailList[item/countColumn-1];
        
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        CustomUICollectionViewCellButton2 *cell = (CustomUICollectionViewCellButton2*)[colViewSummaryTable cellForItemAtIndexPath:indexPath];
        
        
        
        CGRect frame = [colViewSummaryTable convertRect:cell.frame toView:self.view];
        _txvDetail.frame = CGRectMake(15+frame.origin.x, frame.size.height*3/4+frame.origin.y, colViewSummaryTable.frame.size.width-20, 30);
        _txvDetail.backgroundColor = [UIColor lightGrayColor];
        _txvDetail.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
        _txvDetail.text = postDetail.channelUserID;
        [self.view addSubview:_txvDetail];
        [_txvDetail sizeToFit];
        CGRect frame2 = _txvDetail.frame;
        frame2.origin.x = frame.origin.x-frame2.size.width+15;
        _txvDetail.frame = frame2;
    }
}

- (void) viewCustomerName:(id)sender
{
    if([_txvDetail isDescendantOfView:self.view])
    {
        [_txvDetail removeFromSuperview];
    }
    else
    {
        NSInteger countColumn = 6;
        UIButton *button = sender;
        NSInteger item = button.tag;
        PostDetail *postDetail = _postDetailList[item/countColumn-1];
        
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        CustomUICollectionViewCellButton2 *cell = (CustomUICollectionViewCellButton2*)[colViewSummaryTable cellForItemAtIndexPath:indexPath];
        
        
        
        CGRect frame = [colViewSummaryTable convertRect:cell.frame toView:self.view];
        _txvDetail.frame = CGRectMake(15+frame.origin.x, frame.size.height*3/4+frame.origin.y, colViewSummaryTable.frame.size.width-20, 30);
        _txvDetail.backgroundColor = [UIColor lightGrayColor];
        _txvDetail.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
        _txvDetail.text = [NSString stringWithFormat:@"%@\n%@", postDetail.customerName,postDetail.telephone];
        [self.view addSubview:_txvDetail];
        [_txvDetail sizeToFit];
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
        NSInteger countColumn = 6;
        UIButton *button = sender;
        NSInteger item = button.tag;
        PostDetail *postDetail = _postDetailList[item/countColumn-1];
        
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        CustomUICollectionViewCellButton2 *cell = (CustomUICollectionViewCellButton2*)[colViewSummaryTable cellForItemAtIndexPath:indexPath];
        
        
        
        CGRect frame = [colViewSummaryTable convertRect:cell.frame toView:self.view];
        _txvDetail.frame = CGRectMake(15+frame.origin.x, frame.size.height*3/4+frame.origin.y, colViewSummaryTable.frame.size.width-20, 30);
        _txvDetail.backgroundColor = [UIColor lightGrayColor];
        _txvDetail.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
        _txvDetail.text = postDetail.product;
        [self.view addSubview:_txvDetail];
        [_txvDetail sizeToFit];
    }
}

- (void) editTrackingNo:(UIGestureRecognizer *)gestureRecognizer
{
    NSInteger countColumn = 6;
    UIView* view = gestureRecognizer.view;
    _selectedIndexPathForRow = view.tag;
    
    PostDetail *postDetail;
    postDetail = _postDetailList[_selectedIndexPathForRow/countColumn-1];
    
//    _receiptID = postDetail.receiptID;
    _receiptProductItemID = postDetail.receiptProductItemID;
    _strTrackingNo = postDetail.trackingNo;
    _postDetailIndex = _selectedIndexPathForRow/countColumn-1;
    
    [self performSegueWithIdentifier:@"segTrackingNo" sender:self];
}

- (void) selectRow:(UIGestureRecognizer *)gestureRecognizer
{
    NSInteger countColumn = 6;
    UIView* view = gestureRecognizer.view;
    
    _selectedIndexPathForRow = view.tag;
    PostDetail *postDetail;
    postDetail = _postDetailList[_selectedIndexPathForRow/countColumn-1];
    
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

- (IBAction)Unpost:(id)sender {
    _searchBar.userInteractionEnabled = NO;
    _selectButtonClicked = YES;
    btnAction.title = @"Scan";
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

- (IBAction)doAction:(id)sender
{
    _arrSelectedRow = [[NSMutableArray alloc]init];
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
                [_arrSelectedRow addObject:item];
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
                [_arrSelectedRow addObject:item];
            }
        }
    }
    
    [self performSegueWithIdentifier:@"segPreOrderScanUnpost2" sender:self];
}

- (IBAction)cancelAction:(id)sender
{
    _searchBar.userInteractionEnabled = YES;
    _selectButtonClicked = NO;
    [self.navigationItem setRightBarButtonItem:nil];
    [self.navigationItem setRightBarButtonItems:@[btnUnpost]];
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationItem setLeftBarButtonItems:@[btnBack]];
    
    
    for(PostDetail *item in _postDetailList)
    {
        item.editType = @"0";
    }
    [colViewSummaryTable reloadData];
}

- (IBAction)selectAllAction:(id)sender {
    if([btnSelectAll.title isEqualToString:@"Select all"])
    {
        btnSelectAll.title = @"Unselect all";
        for(PostDetail *item in _postDetailList)
        {
            item.editType = @"2";
        }
    }
    else
    {
        btnSelectAll.title = @"Select all";
        for(PostDetail *item in _postDetailList)
        {
            item.editType = @"1";
        }
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
        btnAction.title = [NSString stringWithFormat:@"Scan(%ld)",countSelect];
    }
    else
    {
        btnAction.title = @"Scan";
    }
}
- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segPreOrderScanUnpost2"])
    {
        PreOrderScanUnpost2ViewController *vc = segue.destinationViewController;
        
        vc.mutArrPostDetailList = _mutArrPostDetailList;
        vc.arrSelectedPostDetail = _arrSelectedRow;
    }
    else if ([[segue identifier] isEqualToString:@"segTrackingNo"])
    {
        TrackingNoViewController *vc = segue.destinationViewController;
        
        vc.strTrackingNo = _strTrackingNo;
//        vc.receiptID = _receiptID;
        vc.receiptProductItemID = _receiptProductItemID;
        vc.postDetailIndex = _postDetailIndex;
        vc.postDetailList = _postDetailList;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //    @[@"No",@"Product",@"Customer name",@"Tracking no.",@"Order date"];
    
    CGFloat width;
    NSArray *arrSize;
    arrSize = @[@40,@26,@110,@0,@26,@60];

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
#pragma mark - search
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
    NSPredicate *resultPredicate    = [NSPredicate predicateWithFormat:@"_product contains[c] %@ || _customerName contains[c] %@ || _receiptDate contains[c] %@", searchText,searchText,searchText];
    self.dataSourceForSearchResult  = [_mutArrPostDetailList filteredArrayUsingPredicate:resultPredicate];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    // Do the search...
    
    _page = 1;
    NSString *strPage = [NSString stringWithFormat:@"%ld",_page];
    [self loadingOverlayView];
    [_homeModel downloadItems:dbPostDetailSearch condition:@[_strSelectedEventID,strPage,_searchBar.text]];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    // user did type something, check our datasource for text that looks the same

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
        [_homeModel downloadItems:dbPostDetailSearch condition:@[_strSelectedEventID,strPage,_searchBar.text]];
    }
    if(!_selectButtonClicked)
    {
        return;
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

-(void) loadingOverlayView
{
    [indicator startAnimating];
    indicator.layer.zPosition = 1;
    indicator.alpha = 1;
    
    
    // and just add them to navigationbar view
//    [self.navigationController.view addSubview:overlayView];
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
