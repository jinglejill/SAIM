//
//  ProductPostViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/15/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "ProductPostViewController.h"
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
#import "PreOrderScanPostViewController.h"
#import "CustomUICollectionReusableView.h"
#import "PrintAddressViewController.h"
#import "MovePreOrderEventIDViewController.h"
#import "ProductName.h"


#define orangeColor         [UIColor colorWithRed:253/255.0 green:182/255.0 blue:103/255.0 alpha:1]
#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]

@interface ProductPostViewController ()<UISearchBarDelegate,UISearchControllerDelegate>
{
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSMutableArray *_postDetailList;
    NSMutableArray *_mutArrPostDetailList;
    UIView *_viewUnderline;
    BOOL _selectButtonClicked;
    NSMutableArray *_arrSelectedRow;
    NSInteger _selectedIndexPathForRow;
//    BOOL _isUnwind;
    BOOL _isFirstLoad;
    UITextView *_txvDetail;
    NSMutableArray *_eventListNowAndFutureAsc;
    NSString *_strSelectedEventID;
    
}
@property (nonatomic,strong) NSArray        *dataSource;
@property (nonatomic,strong) NSMutableArray        *dataSourceForSearchResult;
@property (nonatomic)        BOOL           searchBarActive;
@property (nonatomic)        float          searchBarBoundsY;

@end

static NSString * const reuseIdentifier = @"Cell";
static NSString * const reuseHeaderViewIdentifier = @"HeaderView";
static NSString * const reuseFooterViewIdentifier = @"FooterView";
@implementation ProductPostViewController
@synthesize colViewSummaryTable;
@synthesize btnSelectAll;
@synthesize btnBack;
@synthesize btnScanPost;
@synthesize btnAddress;
@synthesize btnMove;
@synthesize btnAction;
@synthesize btnCancel;
@synthesize lblLocation;
@synthesize txtPicker;
@synthesize txtLocation;



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
    [self queryData:NO];
    [self cancelClicked];
    
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

- (IBAction)unwindToProductPost:(UIStoryboardSegue *)segue
{
//    _isUnwind = YES;
    if([[segue sourceViewController] isMemberOfClass:[PreOrderScanPostViewController class]])
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
    else if([[segue sourceViewController] isMemberOfClass:[MovePreOrderEventIDViewController class]])
    {
        [self cancelClicked];
        [self queryData:NO];
//        [self updateButtonShowCountSelect];        
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
        
    
    self.navigationItem.title = [NSString stringWithFormat:@"To Post Product"];
    self.dataSourceForSearchResult = [NSMutableArray new];
    self.searchBar.delegate = self;
    _selectButtonClicked = NO;
    _isFirstLoad = YES;
    
    
    [self.navigationItem setRightBarButtonItem:nil];
    [self.navigationItem setRightBarButtonItems:@[btnScanPost, btnAddress, btnMove]];
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationItem setLeftBarButtonItems:@[btnBack]];
    
    _postDetailList = [[NSMutableArray alloc]init];
    _mutArrPostDetailList = [[NSMutableArray alloc]init];
    _txvDetail = [[UITextView alloc]init];
    _txvDetail.editable = NO;
    
    
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
    
    
    [self loadViewProcess];
}

- (void)loadViewProcess
{
    [self queryData:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(_isFirstLoad)
    {
        [self queryData:NO];
        _isFirstLoad = NO;
    }
}

-(void)queryData:(BOOL)firstTime
{
    [_mutArrPostDetailList removeAllObjects];
    NSMutableArray *receiptProductItemList = [SharedReceiptItem sharedReceiptItem].receiptItemList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"(_productType = %@ or (_productType = %@ and _customMadeIn = %@)) and _preOrderEventID = %ld ",@"P",@"C",@"1",[_strSelectedEventID integerValue]];
    NSArray *arrFilter = [receiptProductItemList filteredArrayUsingPredicate:predicate1];
    
    for(ReceiptProductItem *item in arrFilter)
    {
        Receipt *receipt = [Utility getReceipt:item.receiptID];
        item.receiptDate = receipt.receiptDate;
    }
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_receiptDate" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *arrSort = [arrFilter sortedArrayUsingDescriptors:sortDescriptors];
    
    for(ReceiptProductItem *item in arrSort)
    {
        NSMutableArray *customerReceiptList = [SharedCustomerReceipt sharedCustomerReceipt].customerReceiptList;
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_receiptID = %ld",item.receiptID];
        NSArray *arrFilterCustomerReceipt = [customerReceiptList filteredArrayUsingPredicate:predicate1];
        CustomerReceipt *customerReceipt = arrFilterCustomerReceipt[0];
        
        
        PostCustomer *postCustomer = [[PostCustomer alloc]init];
        postCustomer.firstName = @"";
        if(customerReceipt.postCustomerID != 0)
        {
            NSMutableArray *postCustomerList = [SharedPostCustomer sharedPostCustomer].postCustomerList;
            NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"_postCustomerID = %ld",customerReceipt.postCustomerID];
            NSArray *arrFilterPostCustomer = [postCustomerList filteredArrayUsingPredicate:predicate2];
            postCustomer = arrFilterPostCustomer[0];
        }
        
        
        Receipt *receipt = [Receipt getReceipt:item.receiptID];
        if([item.productType isEqualToString:@"P"])
        {
            Product *product = [Product getProduct:item.productID];
            
            PostDetail *postDetail = [[PostDetail alloc]init];
            postDetail.productName = [ProductName getNameWithProductID:product.productID];
            postDetail.color = [Utility getColorName:product.color];
            postDetail.size = [Utility getSizeLabel:product.size];
            postDetail.sizeOrder = [Utility getSizeOrder:product.size];
            postDetail.product = [NSString stringWithFormat:@"%@/%@/%@",postDetail.productName,postDetail.color,postDetail.size];
            postDetail.customerName = postCustomer.firstName;
            postDetail.trackingNo = customerReceipt.trackingNo;
            postDetail.productType = item.productType;
            postDetail.receiptID = item.receiptID;
            postDetail.receiptDate = [Utility formatDate:receipt.receiptDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"dd/MM/yy"];
            postDetail.productID = product.productID;
            postDetail.receiptProductItemID = item.receiptProductItemID;
            postDetail.editType = @"0";
            postDetail.receiptDateSort = receipt.receiptDate;
            postDetail.channel = receipt.channel;
            postDetail.channelUserID = receipt.channel == 2?postCustomer.lineID:receipt.channel == 3?postCustomer.facebookID:@"";
            [_mutArrPostDetailList addObject:postDetail];
        }
        else if([item.productType isEqualToString:@"C"])
        {
            CustomMade *customMade = [Utility getCustomMade:[item.productID integerValue]];
            PostDetail *postDetail = [[PostDetail alloc]init];
            postDetail.productName = [ProductName getNameWithCustomMadeID:customMade.customMadeID];
            postDetail.color = customMade.body;
            postDetail.size = customMade.size;
            postDetail.sizeOrder = 0;
            postDetail.product = [NSString stringWithFormat:@"%@/%@/%@",postDetail.productName,postDetail.color,postDetail.size];
            postDetail.customerName = postCustomer.firstName;
            postDetail.trackingNo = customerReceipt.trackingNo;
            postDetail.productType = item.productType;
            postDetail.receiptID = item.receiptID;
            postDetail.receiptDate = [Utility formatDate:receipt.receiptDate fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"dd/MM/yy"];
            postDetail.productID = [NSString stringWithFormat:@"%ld",customMade.customMadeID];
            postDetail.receiptProductItemID = item.receiptProductItemID;
            postDetail.editType = @"0";
            postDetail.receiptDateSort = receipt.receiptDate;
            postDetail.channel = receipt.channel;
            postDetail.channelUserID = receipt.channel == 2?postCustomer.lineID:receipt.channel == 3?postCustomer.facebookID:@"";
            [_mutArrPostDetailList addObject:postDetail];
        }
        if([_mutArrPostDetailList count] == [Utility getNumberOfRowForExecuteSql])
        {
            [self setData];
            
            if(firstTime)//เพื่อให้โหลดมาก่อน ไม่ต้องรอทั้งหมด เมื่อ viewdidappear แล้วโหลดที่เหลือ
            {
                return;
            }
        }
    }
    if([_mutArrPostDetailList count] == 0)
    {
        [self setData];
        return;
    }
    if([_mutArrPostDetailList count] != [Utility getNumberOfRowForExecuteSql])//กรณีน้อยกว่า หรือ มากกว่า [Utility getNumberOfRowForExecuteSql] ก็จะทำตัวนี้เพิ่ม
    {
        [self setData];
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

    
    //sort
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_receiptDateSort" ascending:NO];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_productName" ascending:YES];
    NSSortDescriptor *sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:@"_color" ascending:YES];
    NSSortDescriptor *sortDescriptor4 = [[NSSortDescriptor alloc] initWithKey:@"_sizeOrder" ascending:YES];
    NSSortDescriptor *sortDescriptor5 = [[NSSortDescriptor alloc] initWithKey:@"_customerName" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2,sortDescriptor3,sortDescriptor4,sortDescriptor5, nil];
    NSArray *arrSort1 = [_postDetailList sortedArrayUsingDescriptors:sortDescriptors];
    _postDetailList = [arrSort1 mutableCopy];
    
    
    btnAddress.enabled = [_postDetailList count]>0;
    btnScanPost.enabled = [_postDetailList count]>0;
    btnMove.enabled = [_postDetailList count]>0;
    
    
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
        header = @[@"PRNT",@"No",@"Product",@"Customer name",@"CH",@"Date"];
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
    else if(item%countColumn == 5)
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
                    cell.imageView.image = [UIImage imageNamed:@"print.png"];
                    [cell.singleTap removeTarget:self action:@selector(printAddress:)];
                    [cell.singleTap removeTarget:self action:@selector(selectRow:)];
                    [cell.singleTap addTarget:self action:@selector(printAddress:)];
                }
                else if([postDetail.editType isEqualToString:@"1"])
                {
                    cell.imageView.image = [UIImage imageNamed:@"unselect.png"];
                    [cell.singleTap removeTarget:self action:@selector(printAddress:)];
                    [cell.singleTap removeTarget:self action:@selector(selectRow:)];
                    [cell.singleTap addTarget:self action:@selector(selectRow:)];
                }
                else if([postDetail.editType isEqualToString:@"2"])
                {
                    cell.imageView.image = [UIImage imageNamed:@"select.png"];
                    [cell.singleTap removeTarget:self action:@selector(printAddress:)];
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
        _txvDetail.text = postDetail.customerName;
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

- (void) printAddress:(UIGestureRecognizer *)gestureRecognizer
{
    NSInteger countColumn = 6;
    UIView* view = gestureRecognizer.view;
    _selectedIndexPathForRow = view.tag;
    
    
    PostDetail *postDetail;
    postDetail = _postDetailList[_selectedIndexPathForRow/countColumn-1];
    
    
    _arrSelectedRow = [[NSMutableArray alloc]init];
    [_arrSelectedRow addObject:postDetail];
    [self performSegueWithIdentifier:@"segPrintAddressLot" sender:self];
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

- (IBAction)scanPostAll:(id)sender {
    _selectButtonClicked = YES;
    btnAction.title = @"Scan";
    [self.navigationItem setRightBarButtonItem:nil];
    [self.navigationItem setRightBarButtonItems:@[btnCancel, btnAction]];
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationItem setLeftBarButtonItem:btnSelectAll];
    
    
    for(PostDetail *item in _mutArrPostDetailList)
    {
        item.editType = @"1";
    }
    [colViewSummaryTable reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segPreOrderScanAllPost"])
    {
        PreOrderScanPostViewController *vc = segue.destinationViewController;
        vc.mutArrPostDetailList = _mutArrPostDetailList;
        vc.arrSelectedPostDetail = _arrSelectedRow;
        vc.selectedPreOrderEventID = [_strSelectedEventID integerValue];
    }
    else if ([[segue identifier] isEqualToString:@"segPrintAddressLot"])
    {
        PrintAddressViewController *vc = segue.destinationViewController;
        vc.arrPostDetail = _arrSelectedRow;
    }
    else if ([[segue identifier] isEqualToString:@"segMovePreOrderEventID"])
    {
        MovePreOrderEventIDViewController *vc = segue.destinationViewController;
        vc.arrPostDetail = _arrSelectedRow;
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

- (void)cancelClicked
{
    _selectButtonClicked = NO;
    [self.navigationItem setRightBarButtonItem:nil];
    [self.navigationItem setRightBarButtonItems:@[btnScanPost, btnAddress, btnMove]];
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationItem setLeftBarButtonItems:@[btnBack]];
    
    btnSelectAll.title = @"Select all";
    for(PostDetail *item in _mutArrPostDetailList)
    {
        item.editType = @"0";
    }
    [colViewSummaryTable reloadData];
}

- (IBAction)cancelAction:(id)sender
{
    [self cancelClicked];
}

- (IBAction)moveAction:(id)sender {
    _selectButtonClicked = YES;
    btnAction.title = @"Move";
    [self.navigationItem setRightBarButtonItem:nil];
    [self.navigationItem setRightBarButtonItems:@[btnCancel, btnAction]];
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationItem setLeftBarButtonItem:btnSelectAll];
    
    
    for(PostDetail *item in _mutArrPostDetailList)
    {
        item.editType = @"1";
    }
    [colViewSummaryTable reloadData];
}

- (IBAction)addressAction:(id)sender {
    _selectButtonClicked = YES;
    btnAction.title = @"Print";
    [self.navigationItem setRightBarButtonItem:nil];
    [self.navigationItem setRightBarButtonItems:@[btnCancel, btnAction]];
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationItem setLeftBarButtonItem:btnSelectAll];
    
    
    for(PostDetail *item in _mutArrPostDetailList)
    {
        item.editType = @"1";
    }
    [colViewSummaryTable reloadData];
}

- (IBAction)doAction:(id)sender {
    
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
    
    if([btnAction.title rangeOfString:@"Print"].location != NSNotFound)
    {
        [self performSegueWithIdentifier:@"segPrintAddressLot" sender:self];
    }
    else if([btnAction.title rangeOfString:@"Scan"].location != NSNotFound)
    {
        [self performSegueWithIdentifier:@"segPreOrderScanAllPost" sender:self];
    }
    else if([btnAction.title rangeOfString:@"Move"].location != NSNotFound)
    {
        [self performSegueWithIdentifier:@"segMovePreOrderEventID" sender:self];
    }
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
        if ([btnAction.title rangeOfString:@"Print"].location != NSNotFound)
        {
            btnAction.title = [NSString stringWithFormat:@"Print(%ld)",countSelect];
        }
        else if([btnAction.title rangeOfString:@"Scan"].location != NSNotFound)
        {
            btnAction.title = [NSString stringWithFormat:@"Scan(%ld)",countSelect];
        }
        else if([btnAction.title rangeOfString:@"Move"].location != NSNotFound)
        {
            btnAction.title = [NSString stringWithFormat:@"Move(%ld)",countSelect];
        }
    }
    else
    {
        if ([btnAction.title rangeOfString:@"Print"].location != NSNotFound)
        {
            btnAction.title = @"Print";
        }
        else if ([btnAction.title rangeOfString:@"Scan"].location != NSNotFound)
        {
            btnAction.title = @"Scan";
        }
        else if ([btnAction.title rangeOfString:@"Move"].location != NSNotFound)
        {
            btnAction.title = @"Move";
        }
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

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
