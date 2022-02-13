//
//  AddEditPostCustomerViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/13/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "AddEditPostCustomerViewController.h"
#import "CustomTableHeaderFooterViewDelete.h"
#import "CustomTableViewCellText.h"
#import "CustomTableViewCellTextViewTableViewCell.h"
#import "CustomUITextView.h"
#import "Utility.h"
#import "UserMenuViewController.h"
#import "PostCustomer.h"
#import "SharedPostBuy.h"
#import "SharedPostCustomer.h"
#import "SharedPushSync.h"
#import "PushSync.h"
#import "SharedProductBuy.h"
#import "ProductDetail.h"
#import "ItemTrackingNo.h"


#define kOFFSET_FOR_KEYBOARD 80.0


@interface AddEditPostCustomerViewController ()<UISearchBarDelegate>
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    PostCustomer *_postCustomer;
    PostCustomer *_postCustomerX;
    NSInteger _searchResultIndex;
    PostCustomer *_previousSearchPostCustomer;
    BOOL _searchDataFound;
    NSString *_strReceiptID;
    NSMutableArray *_productBuyList;
    NSInteger _postCustomerID;
    
    
    
    BOOL _viewDidLoadSearch;
    float controlWidth;
    float controlXOrigin;
    float controlYOrigin;
}
@property (nonatomic,strong) NSArray        *dataSource;
@property (nonatomic,strong) NSMutableArray        *dataSourceForSearchResult;
@property (nonatomic)        BOOL           searchBarActive;
@property (nonatomic)        float          searchBarBoundsY;
@property (nonatomic,strong) UISearchBar        *searchBar;
@end
static NSString * const reuseIdentifier = @"CustomTableHeaderFooterViewDelete";
static NSString * const reuseIdentifierText = @"CustomTableViewCellText";
static NSString * const reuseIdentifierTextView = @"CustomTableViewCellTextViewTableViewCell";

@implementation AddEditPostCustomerViewController
@synthesize tbvData;
@synthesize btnCancel;
@synthesize btnDelete;
@synthesize searchView;
@synthesize btnNextCustomer;
@synthesize btnPreviousCustomer;
@synthesize selectedPostCustomer;


@synthesize paid;
@synthesize telephoneNoSearch;
@synthesize productBuyIndex;
@synthesize email;
@synthesize selectedItemTrackingNo;
@synthesize receiptProductItemList;
@synthesize readOnly;
@synthesize pageIndex;

- (void)textViewDidEndEditing:(UITextView *)textView
{
    textView.text = [Utility removeApostrophe:textView.text];
    if(textView.tag == 110)
    {
        _postCustomerX.taxCustomerAddress = textView.text;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.text = [Utility removeApostrophe:textField.text];
    if(textField.tag == 101)
    {
        _postCustomerX.lineID = textField.text;
    }
    else if(textField.tag == 102)
    {
        _postCustomerX.emailAddress = textField.text;
    }
    else if(textField.tag == 103)
    {
        _postCustomerX.taxNo = textField.text;
    }
    else if(textField.tag == 104)
    {
        _postCustomerX.facebookID = textField.text;
    }
    else if(textField.tag == 105)
    {
        _postCustomerX.taxCustomerName = textField.text;
    }
    else if(textField.tag == 106)
    {
        _postCustomerX.postcode = textField.text;
    }
    else if(textField.tag == 107)
    {
        _postCustomerX.country = textField.text;
    }
    else if(textField.tag == 108)
    {
        _postCustomerX.other = textField.text;
    }
    else if(textField.tag == 109)
    {
        _postCustomerX.telephone = textField.text;
    }
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
        
    tbvData.contentInset = contentInsets;
    tbvData.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    tbvData.contentInset = UIEdgeInsetsZero;
    tbvData.scrollIndicatorInsets = UIEdgeInsetsZero;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
   
    _postCustomerX = [[PostCustomer alloc]init];
    tbvData.delegate = self;
    tbvData.dataSource = self;
    
    {
        [tbvData registerNib:[UINib nibWithNibName:reuseIdentifier bundle:nil] forHeaderFooterViewReuseIdentifier:reuseIdentifier];
    }
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
    
    
    [self addSearchBar];
    
    _homeModel = [[HomeModel alloc] init];
    _homeModel.delegate = self;
    
    {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);
    }
    
    
    self.navigationController.toolbarHidden = NO;
    btnNextCustomer.enabled = NO;
    btnPreviousCustomer.enabled = NO;
    
    
    
    _previousSearchPostCustomer = [[PostCustomer alloc]init];
    [self clearPostData];
    _searchDataFound = NO;
    
    
    [self setUI];
    dispatch_async(dispatch_get_main_queue(), ^{

        [tbvData reloadData];
    });
//    [self.view bringSubviewToFront:txtLineID];
    {
        UINib *nib = [UINib nibWithNibName:reuseIdentifierText bundle:nil];
        [tbvData registerNib:nib forCellReuseIdentifier:reuseIdentifierText];
    }
    {
        UINib *nib = [UINib nibWithNibName:reuseIdentifierTextView bundle:nil];
        [tbvData registerNib:nib forCellReuseIdentifier:reuseIdentifierTextView];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self                                             selector:@selector(keyboardWillShow:)
                                name:UIKeyboardWillShowNotification
                                object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                selector:@selector(keyboardWillHide:)
                                name:UIKeyboardWillHideNotification
                                object:nil];
                                            
}

-(void)setUI
{
    [self prepareUI];
    txtEmailAddress.text = email;
    _postCustomerX.emailAddress = email;
    _productBuyList = [SharedProductBuy sharedProductBuy].productBuyList;
    _postCustomerID = 0;
    if(!paid)
    {
        if(productBuyIndex == -1)
        {
            for(int i=0; i<[_productBuyList count]; i++)
            {
                CustomMade *customMade = (CustomMade *)_productBuyList[i][productBuyDetail];
                ProductDetail *productDetail = (ProductDetail *)_productBuyList[i][productBuyDetail];
                if([self isProductInventoryOrPreOrder:i])
                {
                    if(productDetail.postCustomerID != 0)
                    {
                        _postCustomerID = productDetail.postCustomerID;
                        break;
                    }
                }
                else
                {
                    if(customMade.postCustomerID != 0)
                    {
                        _postCustomerID = productDetail.postCustomerID;
                        break;
                    }
                }
            }
        }
        else
        {
            CustomMade *customMade = (CustomMade *)_productBuyList[productBuyIndex][productBuyDetail];
            ProductDetail *productDetail = (ProductDetail *)_productBuyList[productBuyIndex][productBuyDetail];
            if([self isProductInventoryOrPreOrder:productBuyIndex])
            {
                if(productDetail.postCustomerID != 0)
                {
                    _postCustomerID = productDetail.postCustomerID;
                }
            }
            else
            {
                if(customMade.postCustomerID != 0)
                {
                    _postCustomerID = productDetail.postCustomerID;
                }
            }
        }
    }
    else
    {
        if(selectedPostCustomer)
        {
            _postCustomerID = selectedPostCustomer.postCustomerID;
        }
        
    }
    
    
    
    
    
    if(![Utility isStringEmpty:telephoneNoSearch])
    {
        _searchBar.text = telephoneNoSearch;
        txtTelephone.text = telephoneNoSearch;
        _postCustomerX.telephone = telephoneNoSearch;
        [self loadingOverlayView];
        _viewDidLoadSearch = 1;
        [self searchBar:_searchBar textDidChange:_searchBar.text];
        
        
        if(_postCustomerID == 0)
        {
            [btnDelete removeFromSuperview];
        }

    }
    else if(selectedPostCustomer)
    {
        [self setData:selectedPostCustomer];
    }
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    // register for keyboard notifications
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                         selector:@selector(keyboardWillShow)
//                                             name:UIKeyboardWillShowNotification
//                                           object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                         selector:@selector(keyboardWillHide)
//                                             name:UIKeyboardWillHideNotification
//                                           object:nil];
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    // unregister for keyboard notifications while not visible.
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                             name:UIKeyboardWillShowNotification
//                                           object:nil];
//
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                             name:UIKeyboardWillHideNotification
//                                           object:nil];
//}

-(void)prepareUI
{
    
    
    controlWidth = self.view.bounds.size.width - 40*2;//minus left, right margin
    controlXOrigin = 15;
    controlYOrigin = (44 - 25)/2;//table row height minus control height and set vertical center
//    controlYOrigin = 0;
    
    txtFirstName = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, 25)];
    txtFirstName.placeholder = @"Customer name";
    txtFirstName.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtFirstName.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
    txtFirstName.delegate = self;

    NSLog(@"tbvData origin:%f",tbvData.bounds.size.width-20-18);
    NSLog(@"view origin:%f",self.view.frame.size.width-20-18);
    btnCopyToTaxCustomerName = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-20-18-20, controlYOrigin,18,18)];
    [btnCopyToTaxCustomerName setImage:[UIImage imageNamed:@"edit2.png"] forState:UIControlStateNormal];
    [btnCopyToTaxCustomerName addTarget:self action:@selector(copyToTaxCustomerName:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    //change textfield street1 to textview
    txtVwAddress = [[CustomUITextView alloc] initWithFrame:CGRectMake(controlXOrigin-4, controlYOrigin, controlWidth, 25)];
    txtVwAddress.placeholder = @" Address";
    txtVwAddress.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
//    [txtVwAddress  setFont: [UIFont fontWithName:@".SFUIText-Regular" size:17]];
    [txtVwAddress setFont:[UIFont systemFontOfSize:17]];
    txtVwAddress.delegate = self;
    
    
    btnFillDetail = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-20-18-20,39*2-18-20,18,18)];//
    [btnFillDetail setImage:[UIImage imageNamed:@"edit2.png"] forState:UIControlStateNormal];
    [btnFillDetail addTarget:self action:@selector(fillDetail:) forControlEvents:UIControlEventTouchUpInside];
    
    
    txtVwAddress2 = [[CustomUITextView alloc] initWithFrame:CGRectMake(controlXOrigin-4, controlYOrigin, controlWidth, 25)];
    txtVwAddress2.placeholder = @" Address 2";
    txtVwAddress2.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
//    [txtVwAddress2  setFont: [UIFont fontWithName:@".SFUIText-Regular" size:17]];
    [txtVwAddress2 setFont:[UIFont systemFontOfSize:17]];
    txtVwAddress2.delegate = self;
    
    
    txtPostCode = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, 25)];
    txtPostCode.placeholder = @"Postcode";
    txtPostCode.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtPostCode.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
    txtPostCode.delegate = self;
    
    
    txtCountry = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, 25)];
    txtCountry.placeholder = @"Country";
    txtCountry.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtCountry.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
    txtCountry.delegate = self;
    
    
    txtTelephone = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, 25)];
    txtTelephone.placeholder = @"Telephone";
    txtTelephone.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtTelephone.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
    txtTelephone.delegate = self;
    [txtTelephone addTarget:self action:@selector(txtTelephoneNoDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    
    txtLineID = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, 25)];
    txtLineID.placeholder = @"Line ID";
    txtLineID.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtLineID.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
    txtLineID.delegate = self;
    
    
    txtFacebookID = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, 25)];
    txtFacebookID.placeholder = @"Facebook ID";
    txtFacebookID.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtFacebookID.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
    txtFacebookID.delegate = self;
    
    
    txtEmailAddress = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, 25)];
    txtEmailAddress.placeholder = @"Email";
    txtEmailAddress.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtEmailAddress.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
    txtEmailAddress.delegate = self;
    
    
    txtTaxCustomerName = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, 25)];
    txtTaxCustomerName.placeholder = @"Tax customer name";
    txtTaxCustomerName.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtTaxCustomerName.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
    txtTaxCustomerName.delegate = self;
    
    
    //change textfield street1 to textview
    txtVwTaxCustomerAddress = [[CustomUITextView alloc] initWithFrame:CGRectMake(controlXOrigin-4, controlYOrigin, controlWidth, 25)];
    txtVwTaxCustomerAddress.placeholder = @" Tax customer address";
    txtVwTaxCustomerAddress.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
//    [txtVwTaxCustomerAddress  setFont: [UIFont fontWithName:@".SFUIText-Regular" size:17]];
    [txtVwTaxCustomerAddress setFont:[UIFont systemFontOfSize:17]];
    txtVwTaxCustomerAddress.delegate = self;
    
    
    txtTaxNo = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, 25)];
    txtTaxNo.placeholder = @"Tax no.";
    txtTaxNo.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtTaxNo.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
    txtTaxNo.keyboardType = UIKeyboardTypeNumberPad;
    txtTaxNo.delegate = self;
    
    
    
    
    txtOther = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, 25)];
    txtOther.placeholder = @"Other";
    txtOther.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtOther.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
    txtOther.delegate = self;
    
   
    if(readOnly)
    {
        _searchBar.userInteractionEnabled = NO;
        _btnDone.enabled = NO;
        btnPreviousCustomer.enabled = NO;
        btnNextCustomer.enabled = NO;
        
        txtFirstName.enabled = NO;
        btnCopyToTaxCustomerName.enabled = NO;
        txtVwAddress.editable = NO;
        btnFillDetail.enabled = NO;
        txtVwAddress2.editable = NO;
        txtPostCode.enabled = NO;
        txtCountry.enabled = NO;
        txtTelephone.enabled = NO;
        txtLineID.enabled = NO;
        txtFacebookID.enabled = NO;
        txtEmailAddress.enabled = NO;
        txtTaxCustomerName.enabled = NO;
        txtVwTaxCustomerAddress.editable = NO;
        txtTaxNo.enabled = NO;
        txtOther.enabled = NO;
        
        btnDelete.enabled = NO;
        
        
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
//    return 13+6;
    return 13;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    [[cell subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    switch (indexPath.row) {
        case 0:
        {
            [cell addSubview:txtFirstName];
            [cell addSubview:btnCopyToTaxCustomerName];
        }
            break;
        case 1:
        {
            [cell addSubview:txtVwAddress];
            [cell addSubview:btnFillDetail];
        }
            break;
        case 2:
        {
            [cell addSubview:txtVwAddress2];
        }
            break;
        case 3:
        {
            CustomTableViewCellText *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierText];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.txtValue.placeholder = @"Postcode";
            cell.txtValue.tag = 106;
            cell.txtValue.text = _postCustomerX.postcode;
            cell.txtValue.delegate = self;
            cell.txtValue.enabled = !readOnly;
            return  cell;
        }
        case 4:
        {
            CustomTableViewCellText *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierText];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.txtValue.placeholder = @"Country";
            cell.txtValue.tag = 107;
            cell.txtValue.text = _postCustomerX.country;
            cell.txtValue.delegate = self;
            cell.txtValue.enabled = !readOnly;
            return  cell;
        }
        case 5:
        {
            CustomTableViewCellText *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierText];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.txtValue.placeholder = @"Phone no.";
            cell.txtValue.tag = 109;
            cell.txtValue.text = _postCustomerX.telephone;
            cell.txtValue.delegate = self;
            cell.txtValue.enabled = !readOnly;
            return  cell;
        }
        case 6:
        {
            CustomTableViewCellText *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierText];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.txtValue.placeholder = @"Line ID";
            cell.txtValue.tag = 101;
            cell.txtValue.text = _postCustomerX.lineID;
            cell.txtValue.delegate = self;
            cell.txtValue.enabled = !readOnly;
            return  cell;
        }
        case 7:
        {
            CustomTableViewCellText *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierText];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.txtValue.placeholder = @"Facebook ID";
            cell.txtValue.tag = 104;
            cell.txtValue.text = _postCustomerX.facebookID;
            cell.txtValue.delegate = self;
            cell.txtValue.enabled = !readOnly;
            return  cell;
        }
        case 8:
        {
            CustomTableViewCellText *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierText];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.txtValue.placeholder = @"Email";
            cell.txtValue.tag = 102;
            cell.txtValue.text = _postCustomerX.emailAddress;
            cell.txtValue.delegate = self;
            cell.txtValue.enabled = !readOnly;
            return  cell;
        }
        case 9:
        {
            CustomTableViewCellText *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierText];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.txtValue.placeholder = @"Tax Customer Name";
            cell.txtValue.tag = 105;
            cell.txtValue.text = _postCustomerX.taxCustomerName;
            cell.txtValue.delegate = self;
            cell.txtValue.enabled = !readOnly;
            return  cell;
        }
        case 10:
        {
            CustomTableViewCellTextViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierTextView];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textView.placeholder = @"Tax Customer Address";
            cell.textView.tag = 110;
            cell.textView.text = _postCustomerX.taxCustomerAddress;
            cell.textView.delegate = self;
            cell.textView.editable = !readOnly;
            return  cell;
        }
        case 11:
        {
            CustomTableViewCellText *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierText];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.txtValue.placeholder = @"Tax no.";
            cell.txtValue.tag = 103;
            cell.txtValue.text = _postCustomerX.taxNo;
            cell.txtValue.delegate = self;
            cell.txtValue.enabled = !readOnly;
            return  cell;
        }
        case 12:
        {
            CustomTableViewCellText *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierText];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.txtValue.placeholder = @"Other";
            cell.txtValue.tag = 108;
            cell.txtValue.text = _postCustomerX.other;
            cell.txtValue.delegate = self;
            cell.txtValue.enabled = !readOnly;
            return  cell;
        }
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    return indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 10?39*2:39;
//    return indexPath.row == 1 || indexPath.row == 10?44*2:indexPath.row == 2?0:44;
    return indexPath.row == 1 || indexPath.row == 10?39*2:(indexPath.row == 2?0:39);
//    return indexPath.row == 1 || indexPath.row == 10?39*2:39;
//    switch (indexPath.row)
//    {
//        case 0:
//            return 39;
//        case 1:
//            return 39*2;
//        case 2:
//            return 0;
//        case 3:
//        case 4:
//        case 5:
//        case 6:
//        case 7:
//        case 8:
//        case 9:
//            return 39;
//        case 10:
//            return 39*2;
//        case 11:
//        case 12:
//            return 39;
//
//
//    }
//    return 39;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if(tableView == tbvData)
    {
//        if(section == 0)
        {
            CustomTableHeaderFooterViewDelete *cell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:reuseIdentifier];
            cell.backgroundColor = [UIColor clearColor];
            cell.btnDelete.enabled = !readOnly;
            [cell.btnDelete addTarget:self action:@selector(deletePost:) forControlEvents:UIControlEventTouchUpInside];
            
            
            return cell;
        }
    }
    
    
    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(tableView == tbvData)
    {
        return 30;
    }
    
    return 0.01f;
}

#pragma mark - Life Cycle method
- (void)loadView
{
    [super loadView];
    
}

- (BOOL)validateEmailAddress
{
    txtEmailAddress.text = [Utility trimString:txtEmailAddress.text];
    _postCustomerX.emailAddress = [Utility trimString:_postCustomerX.emailAddress];
    if([_postCustomerX.emailAddress isEqualToString:@""])
    {
        return YES;
    }
    
    NSArray *arrEmailAddress = [_postCustomerX.emailAddress componentsSeparatedByString:@","];
    for(int i=0; i<[arrEmailAddress count]; i++)
    {
        NSString *email = [Utility trimString:arrEmailAddress[i]];
        if(![Utility validateEmailWithString:email])
        {
            return NO;
        }
    }
    return YES;
}

-(void)fillDetail:(id)sender
{
    //postcode
    {
        txtVwAddress.text = [NSString stringWithFormat:@"%@ ",txtVwAddress.text];
        NSString *searchedString = txtVwAddress.text;
        NSRange   searchedRange = NSMakeRange(0, [searchedString length]);
        NSString *pattern = @"[^0-9]\\d\\d\\d\\d\\d[^0-9]";
        NSError  *error = nil;
        
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: pattern options:0 error:&error];
        NSArray* matches = [regex matchesInString:searchedString options:0 range: searchedRange];
        for (NSTextCheckingResult* match in matches) {
            NSString* matchText = [searchedString substringWithRange:[match range]];
            txtVwAddress.text = [txtVwAddress.text stringByReplacingOccurrencesOfString:matchText withString:@""];
            
            
            NSRange needleRange = NSMakeRange(1,[matchText length]-2);
            txtPostCode.text = [matchText substringWithRange:needleRange];
            _postCustomerX.postcode = [matchText substringWithRange:needleRange];
            break;
        }
    }
    
    //customer name
    {
        NSString *searchedString = txtVwAddress.text;
        NSRange   searchedRange = NSMakeRange(0, [searchedString length]);
        NSString *pattern = @"(ชื่อ : (\\w|\\W)*เบอร์โทร)|(Name : (\\w|\\W)*Tel)|ชื่อ(\\w|\\W)*ที่อยู่";
        NSError  *error = nil;
        
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: pattern options:0 error:&error];
        NSArray* matches = [regex matchesInString:searchedString options:0 range: searchedRange];
        for (NSTextCheckingResult* match in matches) {
            NSString* matchText = [searchedString substringWithRange:[match range]];
            matchText = [matchText stringByReplacingOccurrencesOfString:@"เบอร์โทร" withString:@""];
            matchText = [matchText stringByReplacingOccurrencesOfString:@"Tel" withString:@""];
            txtVwAddress.text = [txtVwAddress.text stringByReplacingOccurrencesOfString:matchText withString:@""];
            
            
            matchText = [matchText stringByReplacingOccurrencesOfString:@"ชื่อ" withString:@""];
            matchText = [matchText stringByReplacingOccurrencesOfString:@"ชื่อ : " withString:@""];
            matchText = [matchText stringByReplacingOccurrencesOfString:@"Name : " withString:@""];
            matchText = [matchText stringByReplacingOccurrencesOfString:@"ที่อยู่" withString:@""];
            matchText = [matchText stringByTrimmingCharactersInSet:
                         [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            txtFirstName.text = matchText;
            break;
        }
    }
    
    //address
    {
        //delete keyword
        NSArray *arrKeyword = @[@"\n\t\nที่อยู่\t",@"ที่อยู่\t",@"ที่อยู่ : ",@"address : ",@"ที่อยู่ "];
        txtVwAddress.text = [Utility removeKeyword:arrKeyword text:txtVwAddress.text];
    }
    
    //country
    {
        NSString *searchedString = txtVwAddress.text;
        NSRange   searchedRange = NSMakeRange(0, [searchedString length]);
        NSString *pattern = @"Thailand|ไทย";
        NSError  *error = nil;
        
        
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: pattern options:0 error:&error];
        NSArray* matches = [regex matchesInString:searchedString options:0 range: searchedRange];
        for (NSTextCheckingResult* match in matches) {
            NSString* matchText = [searchedString substringWithRange:[match range]];
            NSString* matchTextWithCommaSpaceApostrophe = [NSString stringWithFormat:@", '%@',",matchText];
            NSString* matchTextWithComma = [NSString stringWithFormat:@", %@,",matchText];
            NSString* matchTextWithSpace = [NSString stringWithFormat:@" %@",matchText];
            txtVwAddress.text = [txtVwAddress.text stringByReplacingOccurrencesOfString:matchTextWithCommaSpaceApostrophe withString:@""];
            txtVwAddress.text = [txtVwAddress.text stringByReplacingOccurrencesOfString:matchTextWithComma withString:@""];
            txtVwAddress.text = [txtVwAddress.text stringByReplacingOccurrencesOfString:matchTextWithSpace withString:@""];
            txtCountry.text = matchText;
            _postCustomerX.country = matchText;
        }
    }
    
    //tel
    {
        NSString *searchedString = txtVwAddress.text;
        NSRange   searchedRange = NSMakeRange(0, [searchedString length]);
//        NSString *pattern = @"[-]*[ ,]*(\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d)([, ]*\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d)*([, ]*\\+\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d)*";
        NSString *pattern = @"([ ,]*\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d|[ ,]*\\+\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d)+";
        
        
        
        NSError  *error = nil;
        
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: pattern options:0 error:&error];
        NSArray* matches = [regex matchesInString:searchedString options:0 range: searchedRange];
        for (NSTextCheckingResult* match in matches) {
            NSString* matchText = [searchedString substringWithRange:[match range]];
            txtVwAddress.text = [txtVwAddress.text stringByReplacingOccurrencesOfString:matchText withString:@""];
            
            
            //delete keyword
            NSArray *arrKeyword = @[@",มือถือ : ",@",มือถือ :",@"มือถือ",@"โทรศัพท์",@"เบอร์โทร : ",@"เบอร์โทร :",@"โทร : ",@"โทร :",@"โทร.",@"โทร",@"ติดต่อ\t",@"ติดต่อ ",@"Phone:",@"telephone",@"Tel : ",@"Tel :",@"tel.",@"tel"];
            txtVwAddress.text = [Utility removeKeyword:arrKeyword text:txtVwAddress.text];
            
            
            searchedString = matchText;
            searchedRange = NSMakeRange(0, [searchedString length]);
            pattern = @"\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d|\\+\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d[- ]?\\d";            
            error = nil;
            
            regex = [NSRegularExpression regularExpressionWithPattern: pattern options:0 error:&error];
            NSArray* matches = [regex matchesInString:searchedString options:0 range: searchedRange];
            NSMutableArray *telephoneNoArr = [[NSMutableArray alloc]init];
            
            for (NSTextCheckingResult* match in matches) {
                matchText = [searchedString substringWithRange:[match range]];
                if(![telephoneNoArr containsObject:matchText])
                {
                    [telephoneNoArr addObject:matchText];
                    NSString *telephoneFormat = [Utility removeDashAndSpaceAndParenthesis:matchText];
                    NSRange needleRange = NSMakeRange(0,3);
                    if([[telephoneFormat substringWithRange:needleRange] isEqualToString:@"+66"])
                    {
                        NSRange needleRange = NSMakeRange(3,[telephoneFormat length]-3);
                        telephoneFormat = [NSString stringWithFormat:@"0%@",[telephoneFormat substringWithRange:needleRange]];
                    }
                    telephoneFormat = [Utility insertDash:telephoneFormat];
                    if([_postCustomerX.telephone isEqualToString:@""])
                    {
                        _postCustomerX.telephone = telephoneFormat;
                    }
                    else
                    {
                        _postCustomerX.telephone = [NSString stringWithFormat:@"%@,%@",_postCustomerX.telephone,telephoneFormat];
                    }
                }
                
                
                
            }
            break;
        }
    }
    
    //email
    {
        NSString *searchedString = txtVwAddress.text;
        NSRange   searchedRange = NSMakeRange(0, [searchedString length]);
        NSString *pattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSError  *error = nil;
        
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: pattern options:0 error:&error];
        NSArray* matches = [regex matchesInString:searchedString options:0 range: searchedRange];
        for (NSTextCheckingResult* match in matches) {
            NSString* matchText = [searchedString substringWithRange:[match range]];
            txtVwAddress.text = [txtVwAddress.text stringByReplacingOccurrencesOfString:matchText withString:@""];
            txtEmailAddress.text = matchText;
            _postCustomerX.emailAddress = matchText;
            
            //delete keyword
            NSArray *arrKeyword = @[@",อีเมล์ : ",@",อีเมล์ :",@"อีเมล์ : ",@"อีเมล์ :",@"อีเมล",@"Email : ",@"Email"];
            txtVwAddress.text = [Utility removeKeyword:arrKeyword text:txtVwAddress.text];
            break;
        }
    }
    
    //space
    {
        NSString *searchedString = txtVwAddress.text;
        NSRange   searchedRange = NSMakeRange(0, [searchedString length]);
        NSString *pattern = @"$\\s*|^\\s*";
        NSError  *error = nil;
        
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: pattern options:0 error:&error];
        NSArray* matches = [regex matchesInString:searchedString options:0 range: searchedRange];
        for (NSTextCheckingResult* match in matches) {
            NSString* matchText = [searchedString substringWithRange:[match range]];
            txtVwAddress.text = [txtVwAddress.text stringByReplacingOccurrencesOfString:matchText withString:@""];
            
            break;
        }
    }
    
    txtVwAddress.text = [txtVwAddress.text stringByTrimmingCharactersInSet:
                         [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    //find postcode then put in txtpostcode and delete from vwaddress
    //find postcode -> add space at the end of vwAddress then use regex [^0-9]\d\d\d\d\d[^0-9] postcode is 5 character in the center
    //find telephone then put in txttelephone and delete from vwAddress then delete all keywords (โทร,โทร.,โทรศัพท์,tel,tel.,telephone(ภาษาอังกฤษ ​case insensitive)) then delete use regex \(\s*\)
    //find telephone -> use regex \d-?\d-?\d-?\d-?\d-?\d-?\d-?\d-?\d-?\d[, ]*(\d-?\d-?\d-?\d-?\d-?\d-?\d-?\d-?\d-?\d)*
}

-(void)copyToTaxCustomerName:(id)sender
{
    txtTaxCustomerName.text = [Utility removeApostrophe:txtFirstName.text];
    _postCustomerX.taxCustomerName = [Utility removeApostrophe:txtFirstName.text];
    NSString *postcode = [_postCustomerX.postcode isEqualToString:@""]?@"":[NSString stringWithFormat:@" %@",_postCustomerX.postcode];
    NSString *country = [_postCustomerX.country isEqualToString:@""]?@"":[NSString stringWithFormat:@" %@",_postCustomerX.country];
    NSString *telephoneNo = [_postCustomerX.telephone isEqualToString:@""]?@"":[NSString stringWithFormat:@" โทร. %@",_postCustomerX.telephone];
    txtVwTaxCustomerAddress.text = [NSString stringWithFormat:@"%@%@%@%@",[Utility removeApostrophe:txtVwAddress.text],postcode,country,telephoneNo];
    _postCustomerX.taxCustomerAddress = [NSString stringWithFormat:@"%@%@%@%@",[Utility removeApostrophe:txtVwAddress.text],postcode,country,telephoneNo];

}

-(void)setData:(PostCustomer *)postCustomer
{
    selectedPostCustomer = postCustomer;
    
    txtFirstName.text = postCustomer.firstName;
    txtVwAddress.text = postCustomer.street1;
    txtPostCode.text = postCustomer.postcode;
    _postCustomerX.postcode = postCustomer.postcode;
    txtCountry.text = postCustomer.country;
    _postCustomerX.country = postCustomer.country;
    txtTelephone.text = [Utility insertDash:postCustomer.telephone];
    _postCustomerX.telephone = [Utility insertDash:postCustomer.telephone];
    txtLineID.text = postCustomer.lineID;
    _postCustomerX.lineID = postCustomer.lineID;
    txtFacebookID.text = postCustomer.facebookID;
    _postCustomerX.facebookID = postCustomer.facebookID;
    txtEmailAddress.text = postCustomer.emailAddress;
    _postCustomerX.emailAddress = postCustomer.emailAddress;
    txtTaxCustomerName.text = postCustomer.taxCustomerName;
    _postCustomerX.taxCustomerName = postCustomer.taxCustomerName;
    txtVwTaxCustomerAddress.text = postCustomer.taxCustomerAddress;
    _postCustomerX.taxCustomerAddress = postCustomer.taxCustomerAddress;
    txtTaxNo.text = postCustomer.taxNo;
    _postCustomerX.taxNo = postCustomer.taxNo;
    txtOther.text = postCustomer.other;
    _postCustomerX.other = postCustomer.other;
    
    
    _previousSearchPostCustomer.firstName = postCustomer.firstName;
    _previousSearchPostCustomer.street1 = postCustomer.street1;
    _previousSearchPostCustomer.postcode = postCustomer.postcode;
    _previousSearchPostCustomer.country = postCustomer.country;
    _previousSearchPostCustomer.telephone = postCustomer.telephone;
    _previousSearchPostCustomer.lineID = postCustomer.lineID;
    _previousSearchPostCustomer.facebookID = postCustomer.facebookID;
    _previousSearchPostCustomer.emailAddress = postCustomer.emailAddress;
    _previousSearchPostCustomer.taxCustomerName = postCustomer.taxCustomerName;
    _previousSearchPostCustomer.taxCustomerAddress = postCustomer.taxCustomerAddress;
    _previousSearchPostCustomer.taxNo = postCustomer.taxNo;
    _previousSearchPostCustomer.other = postCustomer.other;
    
    [tbvData reloadData];
}
-(void)showNotFoundSearchData
{
    txtFirstName.text = @"";
    txtVwAddress.text = @"";
    txtPostCode.text = @"";
    _postCustomerX.postcode = @"";
    txtCountry.text = @"";
    _postCustomerX.country = @"";
    txtTelephone.text = self.searchBar.text;
    _postCustomerX.telephone = self.searchBar.text;
    txtLineID.text = @"";
    _postCustomerX.lineID = @"";
    txtFacebookID.text = @"";
    _postCustomerX.facebookID = @"";
    txtEmailAddress.text = @"";
    _postCustomerX.emailAddress = @"";
    txtTaxCustomerName.text = @"";
    _postCustomerX.taxCustomerName = @"";
    txtVwTaxCustomerAddress.text = @"";
    _postCustomerX.taxCustomerAddress = @"";
    txtTaxNo.text = @"";
    _postCustomerX.taxNo = @"";
    txtOther.text = @"";
    _postCustomerX.other = @"";
    
    
    _previousSearchPostCustomer.firstName = @"";
    _previousSearchPostCustomer.street1 = @"";
    _previousSearchPostCustomer.postcode = @"";
    _previousSearchPostCustomer.country = @"";
    _previousSearchPostCustomer.telephone = self.searchBar.text;
    _previousSearchPostCustomer.lineID = @"";
    _previousSearchPostCustomer.facebookID = @"";
    _previousSearchPostCustomer.emailAddress = @"";
    _previousSearchPostCustomer.taxCustomerName = @"";
    _previousSearchPostCustomer.taxCustomerAddress = @"";
    _previousSearchPostCustomer.taxNo = @"";
    _previousSearchPostCustomer.other = @"";
}
- (void)assignTextToPostCustomer:(PostCustomer *)postCustomer
{
    postCustomer.firstName = txtFirstName.text;
    postCustomer.street1 = txtVwAddress.text;
    postCustomer.postcode = _postCustomerX.postcode;
    postCustomer.country = _postCustomerX.country;
    postCustomer.telephone = [Utility removeDashAndSpaceAndParenthesis:_postCustomerX.telephone];
    postCustomer.lineID = txtLineID.text;
    postCustomer.lineID = _postCustomerX.lineID;
    postCustomer.facebookID = _postCustomerX.facebookID;
    postCustomer.emailAddress = txtEmailAddress.text;
    postCustomer.emailAddress = _postCustomerX.emailAddress;
    postCustomer.taxCustomerName = txtTaxCustomerName.text;
    postCustomer.taxCustomerName = _postCustomerX.taxCustomerName;
    postCustomer.taxCustomerAddress = txtVwTaxCustomerAddress.text;
    postCustomer.taxCustomerAddress = _postCustomerX.taxCustomerAddress;
    postCustomer.taxNo = txtTaxNo.text;
    postCustomer.taxNo = _postCustomerX.taxNo;
    postCustomer.other = _postCustomerX.other;
}
- (BOOL)validateData
{
    if(![self validateEmailAddress])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invalid data"
                                                                       message:@"Email address is invalid"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    
    
    
    return YES;
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

- (IBAction)savePost:(id)sender
{
    id responder = [self findFirstResponder:self.view];
    if(responder)
    {
        [responder resignFirstResponder];
    }
    
    if(![self validateData])
    {
        return;
    }
    

    if(!paid)
    {
        if(_postCustomerID == 0)
        {
            if(![self inputPost])
            {
                [self performSegueWithIdentifier:@"segUnwindToReceipt2" sender:self];
            }
            else
            {
                if(_searchDataFound)
                {
                    if(![self editSearchData])
                    {
                        selectedPostCustomer = (PostCustomer*)self.dataSourceForSearchResult[_searchResultIndex];
                        [self segUnwindToReceipt2:selectedPostCustomer];
                    }
                    else
                    {
                        selectedPostCustomer = [[PostCustomer alloc]init];
                        selectedPostCustomer.postCustomerID = 0;
                        [self assignTextToPostCustomer:selectedPostCustomer];
                        
                        
                        [self loadingOverlayView];
                        [_homeModel insertItems:dbPostCustomerAdd withData:selectedPostCustomer];
                    }
                }
                else
                {
                    selectedPostCustomer = [[PostCustomer alloc]init];
                    selectedPostCustomer.postCustomerID = 0;
                    [self assignTextToPostCustomer:selectedPostCustomer];
                    
                    
                    [self loadingOverlayView];
                    [_homeModel insertItems:dbPostCustomerAdd withData:selectedPostCustomer];
                }
            }
        }
        else
        {
            if(![self changePost])
            {
                [self performSegueWithIdentifier:@"segUnwindToReceipt2" sender:self];
            }
            else
            {
                if(![self inputPost])
                {
                    [self deletePost:nil];
                }
                else
                {
                    if(_searchDataFound)
                    {
                        if(![self editSearchData])
                        {
                            selectedPostCustomer = (PostCustomer*)self.dataSourceForSearchResult[_searchResultIndex];
                            [self segUnwindToReceipt2:selectedPostCustomer];
                        }
                        else
                        {
                            selectedPostCustomer = [[PostCustomer alloc]init];
                            selectedPostCustomer.postCustomerID = 0;
                            [self assignTextToPostCustomer:selectedPostCustomer];
                            
                            
                            [self loadingOverlayView];
                            [_homeModel insertItems:dbPostCustomerAdd withData:selectedPostCustomer];
                        }
                    }
                    else
                    {
                        selectedPostCustomer = [[PostCustomer alloc]init];
                        selectedPostCustomer.postCustomerID = 0;
                        [self assignTextToPostCustomer:selectedPostCustomer];
                        
                        
                        [self loadingOverlayView];
                        [_homeModel insertItems:dbPostCustomerAdd withData:selectedPostCustomer];
                    }
                }
            }
        }
    }
    else if(paid)
    {
        if(_postCustomerID == 0)
        {
            if(![self inputPost])
            {
                [self cancelButtonClicked:nil];
//                [self performSegueWithIdentifier:@"segUnwindToReceiptSummary2" sender:self];
            }
            else
            {
                if(_searchDataFound)
                {
                    if(![self editSearchData])
                    {
                        selectedPostCustomer = (PostCustomer*)self.dataSourceForSearchResult[_searchResultIndex];
                        
                        //update db
                        [self loadingOverlayView];
                        [_homeModel updateItems:dbItemTrackingNo withData:@[selectedPostCustomer,receiptProductItemList]];
                        
                    }
                    else
                    {
                        selectedPostCustomer = [[PostCustomer alloc]init];
                        selectedPostCustomer.postCustomerID = 0;
                        [self assignTextToPostCustomer:selectedPostCustomer];
                        
                        
                        [self loadingOverlayView];
                        [_homeModel insertItems:dbItemTrackingNoPostCustomerAdd withData:@[selectedPostCustomer,receiptProductItemList]];
                    }
                }
                else
                {
                    selectedPostCustomer = [[PostCustomer alloc]init];
                    selectedPostCustomer.postCustomerID = 0;
                    [self assignTextToPostCustomer:selectedPostCustomer];
                    
                    
                    [self loadingOverlayView];
                    [_homeModel insertItems:dbItemTrackingNoPostCustomerAdd withData:@[selectedPostCustomer,receiptProductItemList]];
                }
            }
        }
        else
        {
            if(![self changePost])
            {
                [self cancelButtonClicked:nil];
//                [self performSegueWithIdentifier:@"segUnwindToReceiptSummary2" sender:self];
            }
            else
            {
                if(![self inputPost])
                {
                    [self deletePost:nil];
                }
                else
                {
                    if(_searchDataFound)
                    {
                        if(![self editSearchData])
                        {
                            selectedPostCustomer = (PostCustomer*)self.dataSourceForSearchResult[_searchResultIndex];
                            
                            //update db
                            [self loadingOverlayView];
                            [_homeModel updateItems:dbItemTrackingNo withData:@[selectedPostCustomer,receiptProductItemList]];
                            
                        }
                        else
                        {
                            selectedPostCustomer = [[PostCustomer alloc]init];
                            selectedPostCustomer.postCustomerID = 0;
                            [self assignTextToPostCustomer:selectedPostCustomer];
                            
                            
                            [self loadingOverlayView];
                            [_homeModel insertItems:dbItemTrackingNoPostCustomerAdd withData:@[selectedPostCustomer,receiptProductItemList]];
                        }
                    }
                    else
                    {
                        selectedPostCustomer = [[PostCustomer alloc]init];
                        selectedPostCustomer.postCustomerID = 0;
                        [self assignTextToPostCustomer:selectedPostCustomer];
                        
                        
                        [self loadingOverlayView];
                        [_homeModel insertItems:dbItemTrackingNoPostCustomerAdd withData:@[selectedPostCustomer,receiptProductItemList]];
                    }
                }
            }
        }
    }
}

-(BOOL)changePost
{
    NSString *allText = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@",txtFirstName.text,txtVwAddress.text,_postCustomerX.postcode,_postCustomerX.country,[Utility removeDashAndSpaceAndParenthesis:_postCustomerX.telephone],_postCustomerX.lineID,_postCustomerX.facebookID,_postCustomerX.emailAddress,_postCustomerX.taxCustomerName,_postCustomerX.taxCustomerAddress,_postCustomerX.taxNo,_postCustomerX.other];
    NSString *allDBText = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@",_postCustomer.firstName,_postCustomer.street1,_postCustomer.postcode,_postCustomer.country,_postCustomer.telephone,_postCustomer.lineID,_postCustomer.facebookID,_postCustomer.emailAddress,_postCustomer.taxCustomerName,_postCustomer.taxCustomerAddress,_postCustomer.taxNo,_postCustomer.other];
    if([allText isEqualToString:allDBText])
    {
        return NO;
    }
    return YES;
}

-(BOOL)inputPost
{
    NSString *allText = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@",txtFirstName.text,txtVwAddress.text,_postCustomerX.postcode,_postCustomerX.country,[Utility removeDashAndSpaceAndParenthesis:_postCustomerX.telephone],_postCustomerX.lineID,_postCustomerX.facebookID,_postCustomerX.emailAddress,_postCustomerX.taxCustomerName,_postCustomerX.taxCustomerAddress,_postCustomerX.taxNo,_postCustomerX.other];
    if([allText isEqualToString:@""])
    {
        return NO;
    }
    return YES;
}

-(BOOL)editSearchData
{
    NSString *allText = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@",txtFirstName.text,txtVwAddress.text,_postCustomerX.postcode,_postCustomerX.country,[Utility removeDashAndSpaceAndParenthesis:_postCustomerX.telephone],_postCustomerX.lineID,_postCustomerX.facebookID,_postCustomerX.emailAddress,_postCustomerX.taxCustomerName,_postCustomerX.taxCustomerAddress,_postCustomerX.taxNo,_postCustomerX.other];
    NSString *allSearchDataText = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@",_previousSearchPostCustomer.firstName,_previousSearchPostCustomer.street1,_previousSearchPostCustomer.postcode,_previousSearchPostCustomer.country,_previousSearchPostCustomer.telephone,_previousSearchPostCustomer.lineID,_previousSearchPostCustomer.facebookID,_previousSearchPostCustomer.emailAddress,_previousSearchPostCustomer.taxCustomerName,_previousSearchPostCustomer.taxCustomerAddress,_previousSearchPostCustomer.taxNo,_previousSearchPostCustomer.other];
    if([allText isEqualToString:allSearchDataText])
    {
        return NO;
    }
    return YES;
}

- (IBAction)deletePost:(id)sender
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:
     [UIAlertAction actionWithTitle:@"Delete post"
                              style:UIAlertActionStyleDestructive
                            handler:^(UIAlertAction *pAction) {
                                if(paid)
                                {
                                    PostCustomer *postCustomer = [[PostCustomer alloc]init];
                                    postCustomer.postCustomerID = 0;
                                    [self loadingOverlayView];
                                    [_homeModel updateItems:dbItemTrackingNoPostCustomerDelete withData:@[postCustomer,receiptProductItemList]];
                                }
                                else
                                {                            
                                    NSMutableArray *postBuyList = [SharedPostBuy sharedPostBuy].postBuyList;
                                    for(PostCustomer *item in postBuyList)
                                    {
                                        if(item.postCustomerID == _postCustomer.postCustomerID)
                                        {
                                            if(productBuyIndex == -1)
                                            {
                                                CustomMade *customMade = (CustomMade *)_productBuyList[0][productBuyDetail];
                                                ProductDetail *productDetail = (ProductDetail *)_productBuyList[0][productBuyDetail];
                                                if([self isProductInventoryOrPreOrder:0])
                                                {
                                                    productDetail.postCustomerID = 0;
                                                }
                                                else
                                                {
                                                    customMade.postCustomerID = 0;
                                                }
                                            }
                                            else
                                            {
                                                for(int i=0; i<[_productBuyList count]; i++)
                                                {
                                                    CustomMade *customMade = (CustomMade *)_productBuyList[i][productBuyDetail];
                                                    ProductDetail *productDetail = (ProductDetail *)_productBuyList[i][productBuyDetail];
                                                    if([self isProductInventoryOrPreOrder:i])
                                                    {
                                                        productDetail.postCustomerID = 0;
                                                    }
                                                    else
                                                    {
                                                        customMade.postCustomerID = 0;
                                                    }
                                                }
                                            }
                                            [postBuyList removeObject:item];
                                            break;
                                        }
                                    }
                                    [self performSegueWithIdentifier:@"segUnwindToReceipt2" sender:self];
                                }
                                
                            }]];
    [alert addAction:
     [UIAlertAction actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleCancel
                            handler:^(UIAlertAction *action) {}]];
    
    
    ///////////////ipad
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        [alert setModalPresentationStyle:UIModalPresentationPopover];
        
        UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
        popPresenter.sourceView = btnDelete;
        popPresenter.sourceRect = btnDelete.bounds;
    }
    ///////////////
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)itemsDownloaded:(NSArray *)items
{
    [self removeOverlayViews];
    
    self.dataSourceForSearchResult = items[0];
    if(_viewDidLoadSearch)
    {
        _viewDidLoadSearch = 0;
        {
            int i=0;
            for(PostCustomer *item in self.dataSourceForSearchResult)
            {
                if(item.postCustomerID == _postCustomerID)
                {
                    _searchResultIndex = i;
                    _postCustomer = item;
                    [self setData:item];
                    btnPreviousCustomer.enabled = _searchResultIndex>0;
                    btnNextCustomer.enabled = [self.dataSourceForSearchResult count]-1>_searchResultIndex;
                    _searchDataFound = YES;
                    break;
                }
                i++;
            }
        }
    }
    else
    {
        //set data to text
        if([self.dataSourceForSearchResult count]>0)
        {
            _searchResultIndex = 0;
            [self setData:(PostCustomer*)self.dataSourceForSearchResult[_searchResultIndex]];
            btnPreviousCustomer.enabled = _searchResultIndex>0;
            btnNextCustomer.enabled = [self.dataSourceForSearchResult count]-1>_searchResultIndex;
            _searchDataFound = YES;
        }
        else
        {
            [self showNotFoundSearchData];
            btnPreviousCustomer.enabled = NO;
            btnNextCustomer.enabled = NO;
            _searchDataFound = NO;
        }
    }
    
}

- (IBAction)nextButtonClicked:(id)sender {
    _searchResultIndex -=1;
    btnPreviousCustomer.enabled = _searchResultIndex>0;
    btnNextCustomer.enabled = [self.dataSourceForSearchResult count]-1>_searchResultIndex;
    [self setData:(PostCustomer*)self.dataSourceForSearchResult[_searchResultIndex]];
}

- (IBAction)previousButtonClicked:(id)sender {
    _searchResultIndex += 1;
    btnPreviousCustomer.enabled = _searchResultIndex>0;
    btnNextCustomer.enabled = [self.dataSourceForSearchResult count]-1>_searchResultIndex;
    [self setData:(PostCustomer*)self.dataSourceForSearchResult[_searchResultIndex]];
}

- (void)itemsFail
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[Utility getConnectionLostTitle]
                                                                   message:[Utility getConnectionLostMessage]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {

                                                          }];
    
    [alert addAction:defaultAction];
    dispatch_async(dispatch_get_main_queue(),^ {
        [self presentViewController:alert animated:YES completion:nil];
    } );
}

-(void)itemsUpdatedWithReturnData:(NSArray *)data
{
    if(_homeModel.propCurrentDB == dbItemTrackingNo)
    {
        [self removeOverlayViews];
        NSMutableArray *returnPostCustomerList = data[0];
        PostCustomer *returnPostCustomer = returnPostCustomerList[0];
        
        
        selectedPostCustomer = returnPostCustomer;
        
        if(pageIndex == 1)
        {
            [self performSegueWithIdentifier:@"segUnwindToSearchReceipt" sender:self];
        }
        else
        {
            [self performSegueWithIdentifier:@"segUnwindToReceiptSummary2" sender:self];
        }
    }
    else if(_homeModel.propCurrentDB == dbItemTrackingNoPostCustomerDelete)
    {
        [self removeOverlayViews];
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                       message:@"Delete post success"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
        handler:^(UIAlertAction * action)
          {
            if(pageIndex == 1)
            {
                [self performSegueWithIdentifier:@"segUnwindToSearchReceiptDelete" sender:self];//
            }
            else
            {
                [self performSegueWithIdentifier:@"segUnwindToReceiptSummary2Delete" sender:self];//
            }
            
              
          }];

        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)itemsInsertedWithReturnData:(NSArray *)data
{
    if(_homeModel.propCurrentDB == dbPostCustomerAdd)
    {
        [self removeOverlayViews];
        
        NSArray *postCustomerList = data[0];
        PostCustomer *postCustomer = postCustomerList[0];
        
        [self segUnwindToReceipt2:postCustomer];
    }
    else if(_homeModel.propCurrentDB == dbItemTrackingNoPostCustomerAdd)
    {
        [self removeOverlayViews];
        
        
        NSMutableArray *returnPostCustomerList = data[0];
        PostCustomer *returnPostCustomer = returnPostCustomerList[0];
        
        
        //update shared add postcustomer to
        selectedPostCustomer = returnPostCustomer;
        
        if(pageIndex == 1)
        {
            [self performSegueWithIdentifier:@"segUnwindToSearchReceipt" sender:self];
        }
        else
        {
            [self performSegueWithIdentifier:@"segUnwindToReceiptSummary2" sender:self];
        }
    }
}

- (void)itemsDeleted
{
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

- (IBAction)CancelPost:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)addSearchBar{
    if (!self.searchBar) {
        self.searchBarBoundsY = 0;
        self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0,self.searchBarBoundsY, [UIScreen mainScreen].bounds.size.width, 44)];
        self.searchBar.searchBarStyle       = UISearchBarStyleMinimal;
        self.searchBar.tintColor            = [UIColor grayColor];
        self.searchBar.barTintColor         = [UIColor grayColor];
        self.searchBar.delegate             = self;
        self.searchBar.placeholder          = @"search mobile no.";
        self.searchBar.keyboardType = UIKeyboardTypeNumberPad;
        [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor grayColor]];
    }
    
    if (![self.searchBar isDescendantOfView:searchView]) {
        [searchView addSubview:self.searchBar];
    }
}
#pragma mark - search

//- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
//    NSPredicate *resultPredicate   = [NSPredicate predicateWithFormat:@"_telephone contains[c] %@", searchText];
//}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    // user did type something, check our datasource for text that looks the same
    txtTelephone.text = [Utility insertDash:searchText];
    _postCustomerX.telephone = [Utility insertDash:searchText];
    if (searchText.length>0)
    {
        
        // search and reload data source
        self.searchBarActive = YES;
        if(searchText.length>5)
        {
            [_homeModel downloadItems:dbPostCustomerSearch condition:[Utility removeDashAndSpaceAndParenthesis:searchText]];
        }
        else
        {
            //clear data
            [self removeOverlayViews];
            [self clearPostData];
            btnPreviousCustomer.enabled = NO;
            btnNextCustomer.enabled = NO;
            _searchDataFound = NO;
        }
    }
    else
    {
        // if text length == 0
        // we will consider the searchbar is not active
        //        self.searchBarActive = NO;
        
        [self removeOverlayViews];
        [self cancelSearching];
        
        //clear data
        [self clearPostData];
        btnPreviousCustomer.enabled = NO;
        btnNextCustomer.enabled = NO;
        _searchDataFound = NO;
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self cancelSearching];
    //clear text
    [self clearPostData];
    btnPreviousCustomer.enabled = NO;
    btnNextCustomer.enabled = NO;
    _searchDataFound = NO;
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
-(void)clearPostData
{
    txtFirstName.text = @"";
    txtVwAddress.text = @"";
    txtPostCode.text = @"";
    _postCustomerX.postcode = @"";
    txtCountry.text = @"";
    _postCustomerX.country = @"";
    txtTelephone.text = @"";
    _postCustomerX.telephone = @"";
    txtLineID.text = @"";
    _postCustomerX.lineID = @"";
    txtFacebookID.text = @"";
    _postCustomerX.facebookID = @"";
    txtEmailAddress.text = @"";
    _postCustomerX.emailAddress = @"";
    txtTaxCustomerName.text = @"";
    _postCustomerX.taxCustomerName = @"";
    txtVwTaxCustomerAddress.text = @"";
    _postCustomerX.taxCustomerAddress = @"";
    txtTaxNo.text = @"";
    txtOther.text = @"";
    _postCustomerX.other = @"";
    
    _previousSearchPostCustomer.firstName = @"";
    _previousSearchPostCustomer.street1 = @"";
    _previousSearchPostCustomer.postcode = @"";
    _previousSearchPostCustomer.country = @"";
    _previousSearchPostCustomer.telephone = @"";
    _previousSearchPostCustomer.lineID = @"";
    _previousSearchPostCustomer.facebookID = @"";
    _previousSearchPostCustomer.emailAddress = @"";
    _previousSearchPostCustomer.taxCustomerName = @"";
    _previousSearchPostCustomer.taxCustomerAddress = @"";
    _previousSearchPostCustomer.taxNo = @"";
    _previousSearchPostCustomer.other = @"";
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

//-(NSInteger)getCustomerID:(NSString *)telephone
//{
//    NSMutableArray *postCustomerList = _postCustomerList;
//    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_telephone = %@",telephone];
//    NSArray *filterArray = [postCustomerList filteredArrayUsingPredicate:predicate1];
//
//    if([filterArray count] > 0)
//    {
//        PostCustomer *postCustomer = filterArray[0];
//        return postCustomer.customerID;
//    }
//
//
//    return 0;
//}

-(BOOL)isProductInventoryOrPreOrder:(NSInteger)productBuyIndex
{
    return [_productBuyList[productBuyIndex][productType] isEqualToString:[NSString stringWithFormat:@"%d",productInventory]] || [_productBuyList[productBuyIndex][productType] isEqualToString:[NSString stringWithFormat:@"%d",productPreOrder]];
}

-(void)segUnwindToReceipt2:(PostCustomer *)postCustomer
{
    NSMutableArray *postBuyList = [SharedPostBuy sharedPostBuy].postBuyList;
    for(PostCustomer *item in postBuyList)
    {
        if(item.postCustomerID == postCustomer.postCustomerID)
        {
            [postBuyList removeObject:item];
            break;
        }
    }
    [postBuyList addObject:postCustomer];
    
    
    if(productBuyIndex == -1)
    {
        for(int i=0; i<[_productBuyList count]; i++)
        {
            CustomMade *customMade = (CustomMade *)_productBuyList[i][productBuyDetail];
            ProductDetail *productDetail = (ProductDetail *)_productBuyList[i][productBuyDetail];
            if([self isProductInventoryOrPreOrder:i])
            {
                productDetail.postCustomerID = postCustomer.postCustomerID;
            }
            else
            {
                customMade.postCustomerID = postCustomer.postCustomerID;
            }
        }
    }
    else
    {
        CustomMade *customMade = (CustomMade *)_productBuyList[productBuyIndex][productBuyDetail];
        ProductDetail *productDetail = (ProductDetail *)_productBuyList[productBuyIndex][productBuyDetail];
        if([self isProductInventoryOrPreOrder:productBuyIndex])
        {
            productDetail.postCustomerID = postCustomer.postCustomerID;
        }
        else
        {
            customMade.postCustomerID = postCustomer.postCustomerID;
        }
    }
            
    [self performSegueWithIdentifier:@"segUnwindToReceipt2" sender:self];
}

-(void)txtTelephoneNoDidChange :(UITextField *)textField
{
    self.searchBar.text = [Utility trimString:textField.text];
}
- (IBAction)cancelButtonClicked:(id)sender
{
    if(readOnly)
    {
        if(pageIndex == 2)
        {
            [self performSegueWithIdentifier:@"segUnwindToSearchSalesTelephoneDetail" sender:self];
        }
        else if(pageIndex == 0)
        {
            [self performSegueWithIdentifier:@"segUnwindToReportTopSpenderDetail" sender:self];
        }
    }
    else
    {
        if(pageIndex == 1)
        {
            [self performSegueWithIdentifier:@"segUnwindToSearchReceiptCancel" sender:self];
        }
        else
        {
            if(paid)
            {
                [self performSegueWithIdentifier:@"segUnwindToReceiptSummary2Cancel" sender:self];
            }
            else
            {
                [self performSegueWithIdentifier:@"segUnwindToReceipt2" sender:self];
            }
        }
    }
}
@end
