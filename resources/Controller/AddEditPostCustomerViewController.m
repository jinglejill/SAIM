//
//  AddEditPostCustomerViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/13/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "AddEditPostCustomerViewController.h"
#import "Utility.h"
#import "UserMenuViewController.h"
#import "CustomerReceipt.h"
#import "PostCustomer.h"
#import "SharedPostBuy.h"
#import "SharedCustomerReceipt.h"
#import "SharedPostCustomer.h"
#import "SharedPushSync.h"
#import "PushSync.h"


@interface AddEditPostCustomerViewController ()<UISearchBarDelegate>
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSMutableArray *_postCustomerList;
    PostCustomer *_postCustomer;
    NSInteger _searchResultIndex;
    PostCustomer *_previousSearchPostCustomer;
    BOOL _searchData;
    NSString *_strReceiptID;
    
    
}
@property (nonatomic,strong) NSArray        *dataSource;
@property (nonatomic,strong) NSMutableArray        *dataSourceForSearchResult;
@property (nonatomic)        BOOL           searchBarActive;
@property (nonatomic)        float          searchBarBoundsY;
@property (nonatomic,strong) UISearchBar        *searchBar;
@end

@implementation AddEditPostCustomerViewController
@synthesize btnCancel;
@synthesize booAddOrEdit;
@synthesize btnDelete;
@synthesize action;
@synthesize paid;
@synthesize telephoneNoSearch;
@synthesize postCustomerID;
@synthesize searchView;
@synthesize btnNextCustomer;
@synthesize btnPreviousCustomer;
@synthesize hasPost;
@synthesize receiptID;

@synthesize selectedPostCustomer;
@synthesize selectedCustomerReceipt;

- (void)textFieldDidEndEditing:(UITextField *)textField
{
//    if([textField isEqual:txtFirstName])
    {
        textField.text = [Utility removeApostrophe:textField.text];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
//    if([textView isEqual:txtVwAddress])
    {
        textView.text = [Utility removeApostrophe:textView.text];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
    
//    [self loadingOverlayView];
//    [_homeModel downloadItems:dbPostCustomer];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self prepareUI];
    if(paid)
    {
        if(postCustomerID != 0)
        {
//            PostCustomer *postCustomer = [Utility getPostCustomer:postCustomerID];
            PostCustomer *postCustomer = selectedPostCustomer;
            
            if(postCustomer)
            {
                [self setData:postCustomer];
            }
            else
            {
                if(![telephoneNoSearch isEqualToString:@""])
                {
                    _searchBar.text = telephoneNoSearch;
                    [self searchBar:_searchBar textDidChange:_searchBar.text];
                    txtTelephone.text = telephoneNoSearch;
                }
            }
            


            NSMutableArray *postCustomerSearchList = self.dataSourceForSearchResult;
            for(int i=0; i<[postCustomerSearchList count]; i++)
            {
                PostCustomer *postCustomerSearch = (PostCustomer*)self.dataSourceForSearchResult[_searchResultIndex+i];
                if(postCustomerSearch.postCustomerID == postCustomer.postCustomerID)
                {
                    [self setData:postCustomerSearch];
                    break;
                }
            }
        }
    }
    else
    {
        if(booAddOrEdit)
        {
            //fill search text and do search
            if(![telephoneNoSearch isEqualToString:@""])
            {
                _searchBar.text = telephoneNoSearch;
                [self searchBar:_searchBar textDidChange:_searchBar.text];
                txtTelephone.text = telephoneNoSearch;
            }
        }
        else
        {
            _searchBar.text = telephoneNoSearch;
            [self searchBar:_searchBar textDidChange:_searchBar.text];
            txtTelephone.text = telephoneNoSearch;


            PostCustomer *postCustomer = [SharedPostBuy sharedPostBuy].postBuyList[0];
            if(postCustomer.postCustomerID == 0)
            {
                [self setData:postCustomer];
                [self.dataSourceForSearchResult insertObject:postCustomer atIndex:0];
                btnPreviousCustomer.enabled = _searchResultIndex>0;
                btnNextCustomer.enabled = [self.dataSourceForSearchResult count]-1>_searchResultIndex;
            }
            else
            {
                NSMutableArray *postCustomerSearchList = self.dataSourceForSearchResult;
                for(int i=0; i<[postCustomerSearchList count]; i++)
                {
                    PostCustomer *postCustomerSearch = (PostCustomer*)self.dataSourceForSearchResult[_searchResultIndex+i];
                    if(postCustomerSearch.postCustomerID == postCustomer.postCustomerID)
                    {
                        [self setData:postCustomerSearch];
                        break;
                    }
                }
            }
        }
    }
}

-(void)prepareUI{
    [self addSearchBar];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    return 13;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
            [cell addSubview:txtPostCode];
            break;
        case 4:
            [cell addSubview:txtCountry];
            break;
        case 5:
            [cell addSubview:txtTelephone];
            break;
        case 6:
            [cell addSubview:txtLineID];
            break;
        case 7:
            [cell addSubview:txtFacebookID];
            break;
        case 8:
            [cell addSubview:txtEmailAddress];
            break;
        case 9:
            [cell addSubview:txtTaxCustomerName];
            break;
        case 10:
            [cell addSubview:txtVwTaxCustomerAddress];
            break;
        case 11:
            [cell addSubview:txtTaxNo];
            break;
        case 12:
            [cell addSubview:txtOther];
            break;
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 10?39*2:39;
}

#pragma mark - Life Cycle method
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
    
    
    self.navigationController.toolbarHidden = NO;
    btnNextCustomer.enabled = NO;
    btnPreviousCustomer.enabled = NO;
    _searchResultIndex = 0;
    
    
    _strReceiptID = [NSString stringWithFormat:@"%ld",receiptID];
    _previousSearchPostCustomer = [[PostCustomer alloc]init];
    [self clearPostData];
    _searchData = NO;
    
    _postCustomerList = [SharedPostCustomer sharedPostCustomer].postCustomerList;
    action = 0;
    
    
    float controlWidth = self.tableView.bounds.size.width - 40*2;//minus left, right margin
    float controlXOrigin = 15;
    float controlYOrigin = (self.tableView.rowHeight - 25)/2;//table row height minus control height and set vertical center
    
    
    txtFirstName = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, 25)];
    txtFirstName.placeholder = @"Customer name";
    txtFirstName.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtFirstName.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
    txtFirstName.delegate = self;
    
    
    btnCopyToTaxCustomerName = [[UIButton alloc]initWithFrame:CGRectMake(self.tableView.bounds.size.width-20-18,39-18-20,18,18)];
    [btnCopyToTaxCustomerName setImage:[UIImage imageNamed:@"edit2.png"] forState:UIControlStateNormal];
    [btnCopyToTaxCustomerName addTarget:self action:@selector(copyToTaxCustomerName:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    //change textfield street1 to textview
    txtVwAddress = [[CustomUITextView alloc] initWithFrame:CGRectMake(controlXOrigin-4, controlYOrigin, controlWidth, 25)];
    txtVwAddress.placeholder = @" Address";
    txtVwAddress.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
    [txtVwAddress  setFont: [UIFont fontWithName:@".SFUIText-Regular" size:17]];
    txtVwAddress.delegate = self;
    
    
    btnFillDetail = [[UIButton alloc]initWithFrame:CGRectMake(self.tableView.bounds.size.width-20-18,39*2-18-20,18,18)];
    [btnFillDetail setImage:[UIImage imageNamed:@"edit2.png"] forState:UIControlStateNormal];
    [btnFillDetail addTarget:self action:@selector(fillDetail:) forControlEvents:UIControlEventTouchUpInside];
    
    
    txtVwAddress2 = [[CustomUITextView alloc] initWithFrame:CGRectMake(controlXOrigin-4, controlYOrigin, controlWidth, 25)];
    txtVwAddress2.placeholder = @" Address 2";
    txtVwAddress2.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
    [txtVwAddress2  setFont: [UIFont fontWithName:@".SFUIText-Regular" size:17]];
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
    [txtVwTaxCustomerAddress  setFont: [UIFont fontWithName:@".SFUIText-Regular" size:17]];
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
    
    
    [self loadViewProcess];
}

- (void)loadViewProcess
{
    if(booAddOrEdit)
    {
        [btnDelete removeFromSuperview];
    }
    else
    {
        if(paid)
        {
//            NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_postCustomerID = %ld",postCustomerID];
//            NSArray *filterArray = [_postCustomerList filteredArrayUsingPredicate:predicate1];
//            _postCustomer = (PostCustomer *)filterArray[0];
            _postCustomer = selectedPostCustomer;
            [self setData:_postCustomer];
            
        }
        else
        {
            NSMutableArray *postBuyList = [SharedPostBuy sharedPostBuy].postBuyList;
            _postCustomer = (PostCustomer *)postBuyList[0];
            [self setData:_postCustomer];
        }
    }
}

- (BOOL)validateEmailAddress
{
    txtEmailAddress.text = [Utility trimString:txtEmailAddress.text];
    if([txtEmailAddress.text isEqualToString:@""])
    {
        return YES;
    }
    
    NSArray *arrEmailAddress = [txtEmailAddress.text componentsSeparatedByString:@","];
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
                    if([txtTelephone.text isEqualToString:@""])
                    {
                        txtTelephone.text = telephoneFormat;
                    }
                    else
                    {
                        txtTelephone.text = [NSString stringWithFormat:@"%@,%@",txtTelephone.text,telephoneFormat];
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
    NSString *postcode = [txtPostCode.text isEqualToString:@""]?@"":[NSString stringWithFormat:@" %@",txtPostCode.text];
    NSString *country = [txtCountry.text isEqualToString:@""]?@"":[NSString stringWithFormat:@" %@",txtCountry.text];
    NSString *telephoneNo = [txtTelephone.text isEqualToString:@""]?@"":[NSString stringWithFormat:@" โทร. %@",txtTelephone.text];
    txtVwTaxCustomerAddress.text = [NSString stringWithFormat:@"%@%@%@%@",[Utility removeApostrophe:txtVwAddress.text],postcode,country,telephoneNo];
}

-(void)setData:(PostCustomer *)postCustomer
{
    selectedPostCustomer = postCustomer;
    
    
    txtFirstName.text = postCustomer.firstName;
    txtVwAddress.text = postCustomer.street1;
    txtPostCode.text = postCustomer.postcode;
    txtCountry.text = postCustomer.country;
    txtTelephone.text = [Utility insertDash:postCustomer.telephone];
    txtLineID.text = postCustomer.lineID;
    txtFacebookID.text = postCustomer.facebookID;
    txtEmailAddress.text = postCustomer.emailAddress;
    txtTaxCustomerName.text = postCustomer.taxCustomerName;
    txtVwTaxCustomerAddress.text = postCustomer.taxCustomerAddress;
    txtTaxNo.text = postCustomer.taxNo;
    txtOther.text = postCustomer.other;
    
    
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
}
-(void)showNotFoundSearchData
{
    txtFirstName.text = @"";
    txtVwAddress.text = @"";
    txtPostCode.text = @"";
    txtCountry.text = @"";
    txtTelephone.text = self.searchBar.text;
    txtLineID.text = @"";
    txtFacebookID.text = @"";
    txtEmailAddress.text = @"";
    txtTaxCustomerName.text = @"";
    txtVwTaxCustomerAddress.text = @"";
    txtTaxNo.text = @"";
    txtOther.text = @"";
    
    
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
    postCustomer.postcode = txtPostCode.text;
    postCustomer.country = txtCountry.text;
    postCustomer.telephone = [Utility removeDashAndSpaceAndParenthesis:txtTelephone.text];
    postCustomer.lineID = txtLineID.text;
    postCustomer.facebookID = txtFacebookID.text;
    postCustomer.emailAddress = txtEmailAddress.text;
    postCustomer.taxCustomerName = txtTaxCustomerName.text;
    postCustomer.taxCustomerAddress = txtVwTaxCustomerAddress.text;
    postCustomer.taxNo = txtTaxNo.text;
    postCustomer.other = txtOther.text;
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
    
    telephoneNoSearch = txtTelephone.text;
    
    
    if(!paid)
    {
        if(booAddOrEdit)
        {
            if(![self inputPost])
            {
                action = 0;
                [self performSegueWithIdentifier:@"segUnwindToReceipt" sender:self];
            }
            else
            {
                if(_searchData)
                {
                    if(![self editSearchData])
                    {
                        _postCustomer = (PostCustomer*)self.dataSourceForSearchResult[_searchResultIndex];
                        [[SharedPostBuy sharedPostBuy].postBuyList removeAllObjects];
                        [[SharedPostBuy sharedPostBuy].postBuyList addObject:_postCustomer];//post customer with id
                        
                        action = 1;
                        [self performSegueWithIdentifier:@"segUnwindToReceipt" sender:self];
                    }
                    else
                    {
                        _postCustomer = [[PostCustomer alloc]init];
                        _postCustomer.postCustomerID = 0;
                        [self assignTextToPostCustomer:_postCustomer];
                        _postCustomer.customerID = [self getCustomerID:_postCustomer.telephone];
                        
                        [[SharedPostBuy sharedPostBuy].postBuyList removeAllObjects];
                        [[SharedPostBuy sharedPostBuy].postBuyList addObject:_postCustomer];//post customer with id = @""
                        
                        action = 1;
                        [self performSegueWithIdentifier:@"segUnwindToReceipt" sender:self];
                    }
                }
                else
                {
                    _postCustomer = [[PostCustomer alloc]init];
                    _postCustomer.postCustomerID = 0;
                    [self assignTextToPostCustomer:_postCustomer];
                    _postCustomer.customerID = [self getCustomerID:_postCustomer.telephone];
                    
                    [[SharedPostBuy sharedPostBuy].postBuyList removeAllObjects];
                    [[SharedPostBuy sharedPostBuy].postBuyList addObject:_postCustomer];//post customer with id = @""
                    
                    action = 1;
                    [self performSegueWithIdentifier:@"segUnwindToReceipt" sender:self];
                }
            }
        }
        else
        {
            if(![self changePost])
            {
                action = 0;
                [self performSegueWithIdentifier:@"segUnwindToReceipt" sender:self];
            }
            else
            {
                if(_searchData)
                {
                    if(![self editSearchData])
                    {
                        _postCustomer = (PostCustomer*)self.dataSourceForSearchResult[_searchResultIndex];
                        [[SharedPostBuy sharedPostBuy].postBuyList removeAllObjects];
                        [[SharedPostBuy sharedPostBuy].postBuyList addObject:_postCustomer];//post customer with id
                        
                        action = 2;
                        [self performSegueWithIdentifier:@"segUnwindToReceipt" sender:self];
                    }
                    else
                    {
                        _postCustomer = [[PostCustomer alloc]init];
                        _postCustomer.postCustomerID = 0;
                        [self assignTextToPostCustomer:_postCustomer];
                        _postCustomer.customerID = [self getCustomerID:_postCustomer.telephone];
                        
                        [[SharedPostBuy sharedPostBuy].postBuyList removeAllObjects];
                        [[SharedPostBuy sharedPostBuy].postBuyList addObject:_postCustomer];//post customer with id = @""
                        
                        action = 2;
                        [self performSegueWithIdentifier:@"segUnwindToReceipt" sender:self];
                    }
                }
                else
                {
                    _postCustomer = [[PostCustomer alloc]init];
                    _postCustomer.postCustomerID = 0;
                    [self assignTextToPostCustomer:_postCustomer];
                    _postCustomer.customerID = [self getCustomerID:_postCustomer.telephone];
                    
                    [[SharedPostBuy sharedPostBuy].postBuyList removeAllObjects];
                    [[SharedPostBuy sharedPostBuy].postBuyList addObject:_postCustomer];//post customer with id = @""
                    
                    action = 2;
                    [self performSegueWithIdentifier:@"segUnwindToReceipt" sender:self];
                }
            }
        }
    }
    else
    {
        if(booAddOrEdit)
        {
            if(![self inputPost])
            {
                [self performSegueWithIdentifier:@"segUnwindToReceiptSummary" sender:self];
            }
            else
            {
                if(_searchData)
                {
                    if(![self editSearchData])
                    {
                        PostCustomer *postCustomer = (PostCustomer*)self.dataSourceForSearchResult[_searchResultIndex];
                        CustomerReceipt *customerReceipt = [[CustomerReceipt alloc]init];
                        customerReceipt.receiptID = receiptID;
                        customerReceipt.postCustomerID = postCustomer.postCustomerID;
//                        [self loadingOverlayView];
                        [_homeModel updateItems:dbCustomerReceiptUpdatePostCustomerID withData:customerReceipt];
                        
//                        //update sharedcustomerreceipt
//                        [self updateSharedCustomerReceipt:customerReceipt];
//
//                        [self performSegueWithIdentifier:@"segUnwindToReceiptSummary" sender:self];
                    }
                    else
                    {
                        _postCustomer = [[PostCustomer alloc]init];
//                        _postCustomer.postCustomerID = [Utility getNextID:tblPostCustomer];
                        _postCustomer.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                        _postCustomer.modifiedUser = [Utility modifiedUser];
                        [self assignTextToPostCustomer:_postCustomer];
                        _postCustomer.customerID = [self getCustomerID:_postCustomer.telephone];
                        
                        
                        CustomerReceipt *customerReceipt = [[CustomerReceipt alloc]init];
                        customerReceipt.receiptID = receiptID;
//                        customerReceipt.postCustomerID = _postCustomer.postCustomerID;
                        customerReceipt.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                        customerReceipt.modifiedUser = [Utility modifiedUser];
                        
                        
                        NSMutableArray *data = [[NSMutableArray alloc]init];
                        [data addObject:_postCustomer];
                        [data addObject:_strReceiptID];
                        [self loadingOverlayView];
                        [_homeModel insertItems:dbPostCustomer withData:data];
                        
                        
//                        //update shared
//                        [self updateSharedPostCustomer:_postCustomer];
//                        [self updateSharedCustomerReceipt:customerReceipt];
//                        [self performSegueWithIdentifier:@"segUnwindToReceiptSummary" sender:self];
                    }
                }
                else
                {
                    _postCustomer = [[PostCustomer alloc]init];
//                    _postCustomer.postCustomerID = [Utility getNextID:tblPostCustomer];
                    _postCustomer.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                    _postCustomer.modifiedUser = [Utility modifiedUser];
                    [self assignTextToPostCustomer:_postCustomer];
                    _postCustomer.customerID = [self getCustomerID:_postCustomer.telephone];
                    
                    
                    CustomerReceipt *customerReceipt = [[CustomerReceipt alloc]init];
                    customerReceipt.receiptID = receiptID;
                    customerReceipt.postCustomerID = _postCustomer.postCustomerID;
                    customerReceipt.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                    customerReceipt.modifiedUser = [Utility modifiedUser];
                    
                    
                    NSMutableArray *data = [[NSMutableArray alloc]init];
                    [data addObject:_postCustomer];
                    [data addObject:_strReceiptID];
                    [self loadingOverlayView];
                    [_homeModel insertItems:dbPostCustomer withData:data];
                    
                    
//                    //update shared
//                    [self updateSharedPostCustomer:_postCustomer];
//                    [self updateSharedCustomerReceipt:customerReceipt];
//                    [self performSegueWithIdentifier:@"segUnwindToReceiptSummary" sender:self];
                }
            }
        }
        else
        {
            if(![self changePost])
            {
                [self performSegueWithIdentifier:@"segUnwindToReceiptSummary" sender:self];
            }
            else
            {
                if(_searchData)
                {
                    if(![self editSearchData])
                    {
                        PostCustomer *postCustomer = (PostCustomer*)self.dataSourceForSearchResult[_searchResultIndex];
                        CustomerReceipt *customerReceipt = [[CustomerReceipt alloc]init];
                        customerReceipt.receiptID = receiptID;
                        customerReceipt.postCustomerID = postCustomer.postCustomerID;
//                        [self loadingOverlayView];
                        [_homeModel updateItems:dbCustomerReceiptUpdatePostCustomerID withData:customerReceipt];
                        
//                        //update sharedcustomerreceipt
//                        [self updateSharedCustomerReceipt:customerReceipt];
//
//                        [self performSegueWithIdentifier:@"segUnwindToReceiptSummary" sender:self];
                    }
                    else
                    {
                        _postCustomer = [[PostCustomer alloc]init];
//                        _postCustomer.postCustomerID = [Utility getNextID:tblPostCustomer];
                        _postCustomer.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                        _postCustomer.modifiedUser = [Utility modifiedUser];
                        [self assignTextToPostCustomer:_postCustomer];
                        _postCustomer.customerID = [self getCustomerID:_postCustomer.telephone];
                        
                        
                        CustomerReceipt *customerReceipt = [[CustomerReceipt alloc]init];
                        customerReceipt.receiptID = receiptID;
                        customerReceipt.postCustomerID = _postCustomer.postCustomerID;
                        customerReceipt.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                        customerReceipt.modifiedUser = [Utility modifiedUser];
                        
                        
                        NSMutableArray *data = [[NSMutableArray alloc]init];
                        [data addObject:_postCustomer];
                        [data addObject:_strReceiptID];
                        [self loadingOverlayView];
                        [_homeModel insertItems:dbPostCustomer withData:data];
                        
                        
//                        //update shared
//                        [self updateSharedPostCustomer:_postCustomer];
//                        [self updateSharedCustomerReceipt:customerReceipt];
//                        [self performSegueWithIdentifier:@"segUnwindToReceiptSummary" sender:self];
                    }
                }
                else
                {
                    _postCustomer = [[PostCustomer alloc]init];
//                    _postCustomer.postCustomerID = [Utility getNextID:tblPostCustomer];
                    _postCustomer.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                    _postCustomer.modifiedUser = [Utility modifiedUser];
                    [self assignTextToPostCustomer:_postCustomer];
                    _postCustomer.customerID = [self getCustomerID:_postCustomer.telephone];
                    
                    
                    CustomerReceipt *customerReceipt = [[CustomerReceipt alloc]init];
                    customerReceipt.receiptID = receiptID;
                    customerReceipt.postCustomerID = _postCustomer.postCustomerID;
                    customerReceipt.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
                    customerReceipt.modifiedUser = [Utility modifiedUser];
                    
                    
                    NSMutableArray *data = [[NSMutableArray alloc]init];
                    [data addObject:_postCustomer];
                    [data addObject:_strReceiptID];
                    [_homeModel insertItems:dbPostCustomer withData:data];
                    
                    
//                    //update shared
//                    [self updateSharedPostCustomer:_postCustomer];
//                    [self updateSharedCustomerReceipt:customerReceipt];
//                    [self performSegueWithIdentifier:@"segUnwindToReceiptSummary" sender:self];
                }
            }
        }
    }
}

-(void)itemsInserted
{
}

-(void)itemsInsertedWithReturnData:(NSArray *)data
{
    [self removeOverlayViews];
    
    NSMutableArray *returnPostCustomerList = data[0];
    PostCustomer *returnPostCustomer = returnPostCustomerList[0];
    //update shared add postcustomer to
    selectedPostCustomer = returnPostCustomer;
    selectedCustomerReceipt.postCustomerID = returnPostCustomer.postCustomerID;
    
    [[SharedPostCustomer sharedPostCustomer].postCustomerList addObject:returnPostCustomer];
    [self performSegueWithIdentifier:@"segUnwindToReceiptSummary" sender:self];
}

-(BOOL)changePost
{
    NSString *allText = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@",txtFirstName.text,txtVwAddress.text,txtPostCode.text,txtCountry.text,[Utility removeDashAndSpaceAndParenthesis:txtTelephone.text],txtLineID.text,txtFacebookID.text,txtEmailAddress.text,txtTaxCustomerName.text,txtVwTaxCustomerAddress.text,txtTaxNo.text,txtOther.text];
    NSString *allDBText = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@",_postCustomer.firstName,_postCustomer.street1,_postCustomer.postcode,_postCustomer.country,_postCustomer.telephone,_postCustomer.lineID,_postCustomer.facebookID,_postCustomer.emailAddress,_postCustomer.taxCustomerName,_postCustomer.taxCustomerAddress,_postCustomer.taxNo,_postCustomer.other];
    if([allText isEqualToString:allDBText])
    {
        return NO;
    }
    return YES;
}

-(BOOL)inputPost
{
    NSString *allText = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@",txtFirstName.text,txtVwAddress.text,txtPostCode.text,txtCountry.text,[Utility removeDashAndSpaceAndParenthesis:txtTelephone.text],txtLineID.text,txtFacebookID.text,txtEmailAddress.text,txtTaxCustomerName.text,txtVwTaxCustomerAddress.text,txtTaxNo.text,txtOther.text];
    if([allText isEqualToString:@""])
    {
        return NO;
    }
    return YES;
}

-(BOOL)editSearchData
{
    NSString *allText = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@",txtFirstName.text,txtVwAddress.text,txtPostCode.text,txtCountry.text,[Utility removeDashAndSpaceAndParenthesis:txtTelephone.text],txtLineID.text,txtFacebookID.text,txtEmailAddress.text,txtTaxCustomerName.text,txtVwTaxCustomerAddress.text,txtTaxNo.text,txtOther.text];
    NSString *allSearchDataText = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@",_previousSearchPostCustomer.firstName,_previousSearchPostCustomer.street1,_previousSearchPostCustomer.postcode,_previousSearchPostCustomer.country,_previousSearchPostCustomer.telephone,_previousSearchPostCustomer.lineID,_previousSearchPostCustomer.facebookID,_previousSearchPostCustomer.emailAddress,_previousSearchPostCustomer.taxCustomerName,_previousSearchPostCustomer.taxCustomerAddress,_previousSearchPostCustomer.taxNo,_previousSearchPostCustomer.other];
    if([allText isEqualToString:allSearchDataText])
    {
        return NO;
    }
    return YES;
}

//- (void)updateSharedPostCustomer:(PostCustomer *)postCustomer
//{
//    [[SharedPostCustomer sharedPostCustomer].postCustomerList addObject:postCustomer];
//}

//- (void)updateSharedCustomerReceipt:(CustomerReceipt *)customerReceipt
//{
//    for(CustomerReceipt *item in [SharedCustomerReceipt sharedCustomerReceipt].customerReceiptList)
//    {
//        if(item.receiptID == customerReceipt.receiptID)
//        {
//            item.postCustomerID = customerReceipt.postCustomerID;
//            item.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
//            item.modifiedUser = [Utility modifiedUser];
//            break;
//        }
//    }
//}

- (IBAction)deletePost:(id)sender {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:
     [UIAlertAction actionWithTitle:@"Delete post"
                              style:UIAlertActionStyleDestructive
                            handler:^(UIAlertAction *pAction) {
                                if(paid)
                                {
                                    CustomerReceipt *customerReceipt = [[CustomerReceipt alloc]init];
                                    customerReceipt.receiptID = receiptID;
                                    customerReceipt.postCustomerID = 0;
                                    [_homeModel updateItems:dbCustomerReceiptUpdatePostCustomerID withData:customerReceipt];
                                    
//                                    //update sharedcustomerreceipt
//                                    [self updateSharedCustomerReceipt:customerReceipt];
                                    
                                    
                                    action = 3;
                                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                                                   message:@"Delete post success"
                                                                                            preferredStyle:UIAlertControllerStyleAlert];
                                    
                                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                                          handler:^(UIAlertAction * action){
                                                                                              [self performSegueWithIdentifier:@"segUnwindToReceiptSummary" sender:self];//
                                                                                          }];
                                    [alert addAction:defaultAction];
                                    [self presentViewController:alert animated:YES completion:nil];
                                }
                                else
                                {
                                    [[SharedPostBuy sharedPostBuy].postBuyList removeAllObjects];
                                    action = 3;
                                    [self performSegueWithIdentifier:@"segUnwindToReceipt" sender:self];
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
        //        popPresenter.barButtonItem = _barButtonIpad;
    }
    ///////////////
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)itemsDownloaded:(NSArray *)items
{
    self.dataSourceForSearchResult = items[0];
    
    
    //set data to text
    if([self.dataSourceForSearchResult count]>0)
    {
        [self setData:(PostCustomer*)self.dataSourceForSearchResult[_searchResultIndex]];
        btnPreviousCustomer.enabled = _searchResultIndex>0;
        btnNextCustomer.enabled = [self.dataSourceForSearchResult count]-1>_searchResultIndex;
        _searchData = YES;
    }
    else
    {
        [self showNotFoundSearchData];
        btnPreviousCustomer.enabled = NO;
        btnNextCustomer.enabled = NO;
        _searchData = NO;
    }
}
//-(void)itemsDownloaded:(NSArray *)items
//{
//    [self removeOverlayViews];
//    _postCustomerList = items[0];
//
//
//
//    [self prepareUI];
//    if(paid)
//    {
//        if(postCustomerID != 0)
//        {
////            PostCustomer *postCustomer = [Utility getPostCustomer:postCustomerID];
//            PostCustomer *postCustomer = selectedPostCustomer;
//            [self setData:postCustomer];
//            if(![telephoneNoSearch isEqualToString:@""])
//            {
//                _searchBar.text = telephoneNoSearch;
//                [self searchBar:_searchBar textDidChange:_searchBar.text];
//                txtTelephone.text = telephoneNoSearch;
//            }
//
//
//            NSMutableArray *postCustomerSearchList = self.dataSourceForSearchResult;
//            for(int i=0; i<[postCustomerSearchList count]; i++)
//            {
//                PostCustomer *postCustomerSearch = (PostCustomer*)self.dataSourceForSearchResult[_searchResultIndex+i];
//                if(postCustomerSearch.postCustomerID == postCustomer.postCustomerID)
//                {
//                    [self setData:postCustomerSearch];
//                    break;
//                }
//            }
//        }
//    }
//    else
//    {
//        if(booAddOrEdit)
//        {
//            //fill search text and do search
//            if(![telephoneNoSearch isEqualToString:@""])
//            {
//                _searchBar.text = telephoneNoSearch;
//                [self searchBar:_searchBar textDidChange:_searchBar.text];
//                txtTelephone.text = telephoneNoSearch;
//            }
//        }
//        else
//        {
//            _searchBar.text = telephoneNoSearch;
//            [self searchBar:_searchBar textDidChange:_searchBar.text];
//            txtTelephone.text = telephoneNoSearch;
//
//
//            PostCustomer *postCustomer = [SharedPostBuy sharedPostBuy].postBuyList[0];
//            if(postCustomer.postCustomerID == 0)
//            {
//                [self setData:postCustomer];
//                [self.dataSourceForSearchResult insertObject:postCustomer atIndex:0];
//                btnPreviousCustomer.enabled = _searchResultIndex>0;
//                btnNextCustomer.enabled = [self.dataSourceForSearchResult count]-1>_searchResultIndex;
//            }
//            else
//            {
//                NSMutableArray *postCustomerSearchList = self.dataSourceForSearchResult;
//                for(int i=0; i<[postCustomerSearchList count]; i++)
//                {
//                    PostCustomer *postCustomerSearch = (PostCustomer*)self.dataSourceForSearchResult[_searchResultIndex+i];
//                    if(postCustomerSearch.postCustomerID == postCustomer.postCustomerID)
//                    {
//                        [self setData:postCustomerSearch];
//                        break;
//                    }
//                }
//            }
//        }
//    }
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
    
}
-(void)itemsUpdatedWithReturnID:(NSInteger)ID
{
    if(_homeModel.propCurrentDB == dbCustomerReceiptUpdatePostCustomerID)
    {
        selectedCustomerReceipt.postCustomerID = ID;
        [self performSegueWithIdentifier:@"segUnwindToReceiptSummary" sender:self];
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
        self.searchBar.delegate = self;
        self.searchBar.keyboardType = UIKeyboardTypeNumberPad;
        [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor grayColor]];
    }
    
    if (![self.searchBar isDescendantOfView:searchView]) {
        [searchView addSubview:self.searchBar];
    }
}
#pragma mark - search

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
    NSPredicate *resultPredicate   = [NSPredicate predicateWithFormat:@"_telephone contains[c] %@", searchText];
    self.dataSourceForSearchResult = [[_postCustomerList filteredArrayUsingPredicate:resultPredicate] mutableCopy];
    self.dataSourceForSearchResult = [PostCustomer getPostCustomerSortByModifiedDate:self.dataSourceForSearchResult];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    // user did type something, check our datasource for text that looks the same
    txtTelephone.text = [Utility insertDash:searchText];
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
            [self clearPostData];
            btnPreviousCustomer.enabled = NO;
            btnNextCustomer.enabled = NO;
            _searchData = NO;
        }
//        [self filterContentForSearchText:[Utility removeDashAndSpaceAndParenthesis:searchText] scope:@""];
        
//        //set data to text
//        if([self.dataSourceForSearchResult count]>0)
//        {
//            [self setData:(PostCustomer*)self.dataSourceForSearchResult[_searchResultIndex]];
//            btnPreviousCustomer.enabled = _searchResultIndex>0;
//            btnNextCustomer.enabled = [self.dataSourceForSearchResult count]-1>_searchResultIndex;
//            _searchData = YES;
//        }
//        else
//        {
//            [self showNotFoundSearchData];
//            btnPreviousCustomer.enabled = NO;
//            btnNextCustomer.enabled = NO;
//            _searchData = NO;
//        }
    }
    else
    {
        // if text length == 0
        // we will consider the searchbar is not active
        //        self.searchBarActive = NO;
        
 
        [self cancelSearching];
        
        //clear data
        [self clearPostData];
        btnPreviousCustomer.enabled = NO;
        btnNextCustomer.enabled = NO;
        _searchData = NO;
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self cancelSearching];
    //clear text
    [self clearPostData];
    btnPreviousCustomer.enabled = NO;
    btnNextCustomer.enabled = NO;
    _searchData = NO;
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
    txtCountry.text = @"";
    txtTelephone.text = @"";
    txtLineID.text = @"";
    txtFacebookID.text = @"";
    txtEmailAddress.text = @"";
    txtTaxCustomerName.text = @"";
    txtVwTaxCustomerAddress.text = @"";
    txtTaxNo.text = @"";
    txtOther.text = @"";
    
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
- (IBAction)nextButtonClicked:(id)sender {
    _searchResultIndex +=1;
    btnPreviousCustomer.enabled = _searchResultIndex>0;
    btnNextCustomer.enabled = [self.dataSourceForSearchResult count]-1>_searchResultIndex;
    [self setData:(PostCustomer*)self.dataSourceForSearchResult[_searchResultIndex]];
}

- (IBAction)previousButtonClicked:(id)sender {
    _searchResultIndex -= 1;
    btnPreviousCustomer.enabled = _searchResultIndex>0;
    btnNextCustomer.enabled = [self.dataSourceForSearchResult count]-1>_searchResultIndex;
    [self setData:(PostCustomer*)self.dataSourceForSearchResult[_searchResultIndex]];
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

-(NSInteger)getCustomerID:(NSString *)telephone
{
    NSMutableArray *postCustomerList = _postCustomerList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_telephone = %@",telephone];
    NSArray *filterArray = [postCustomerList filteredArrayUsingPredicate:predicate1];
    
    if([filterArray count] > 0)
    {
        PostCustomer *postCustomer = filterArray[0];
        return postCustomer.customerID;
    }
    
    
    return 0;
}
@end
