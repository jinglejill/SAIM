//
//  Receipt2ViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 16/3/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import "Receipt2ViewController.h"
#import "AddEditPostCustomerViewController.h"
#import "CustomTableViewCellReward.h"
#import "SharedPostBuy.h"
#import "SharedProductBuy.h"
#import "SharedCustomMade.h"
#import "SharedSelectedEvent.h"
#import "CustomTableViewCellOrder.h"
#import "CustomTableHeaderFooterViewOrderSummary.h"
#import "CustomTableViewCellDiscount.h"
#import "CustomTableViewCellDiscountReason.h"
#import "CustomTableViewCellSaveCancel.h"
#import "RewardPoint.h"
#import "RewardProgram.h"
#import "ProductDetail.h"
#import "PreOrderEventIDHistory.h"
#import "PreOrder2.h"
#import "WordPressUser.h"
#import "Message.h"
#import "SharedReplaceReceiptProductItem.h"




#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]
#define tPinkColor          [UIColor colorWithRed:255/255.0 green:47/255.0 blue:146/255.0 alpha:1]

@interface Receipt2ViewController ()
{
    NSInteger _selectedIndexPathForRow;
    NSMutableArray *_productBuyList;
    
    UILabel *_lblRewardProgramDetail;
    UILabel *_lblPointUsed;
    UIButton *_btnRedeemPoint;
    UIButton *_btnCancelRedeemPoint;
    UITextField *_txtDiscountValuePercent;
    UISegmentedControl *_segConBahtPercent;
    UISegmentedControl *_segConChannel;
    UISegmentedControl *_segConShip;
    UISegmentedControl *_segConSalesUser;
    UITextField *_txtCashReceive;
    UILabel *_lblChanges;
    UIButton *_btnPay;
    UITextField *_txtCreditAmount;
    UITextField *_txtTransferAmount;
    UITextField *_txtDiscountReason;
    UITextField *_txtSalesRemark;
    UITextField *_txtReferenceOrderNo;
    
    
    NSNumberFormatter *_formatter;
    NSMutableArray *_selectedProductBuy;
    Event *_event;
    NSString *_strDiscount;
    NSString *_strDiscountValuePercent;
    
    RewardProgram *_rewardProgramCollect;
    RewardProgram *_rewardProgramUse;
    NSInteger _time;
    NSInteger _pointSpentActual;

    NSArray *_salesUserList;
    UITableView *_tbvDiscount;
    NSInteger _selectedProductBuyIndex;
    BOOL _booReplaceProduct;
    NSString *_discountText;
    NSInteger _bahtPercentIndex;
    NSString *_discountReason;
    UIView *_vwDimBackground;
    
    NSString *_telephoneNoInput;
    NSMutableArray *_wordPressUserList;
    UITableView *_tbvWordPressRegister;
    NSString *_wordPressEmail;
    NSString *_wordPressPhone;
    
    UITableView *_tbvRedeem;
    NSString *_redeemPoints;
    NSString *_redeemPointsCache;
}
@end
static NSString * const reuseIdentifierOrder = @"CustomTableViewCellOrder";
static NSString * const reuseIdentifierOrderSummary = @"CustomTableHeaderFooterViewOrderSummary";
static NSString * const reuseIdentifierDiscount = @"CustomTableViewCellDiscount";
static NSString * const reuseIdentifierDiscountReason = @"CustomTableViewCellDiscountReason";
static NSString * const reuseIdentifierSaveCancel = @"CustomTableViewCellSaveCancel";
static NSString * const reuseIdentifierReward = @"CustomTableViewCellReward";


@implementation Receipt2ViewController
@synthesize tbvPay;
@synthesize btnBack;

- (IBAction)unwindToReceipt2:(UIStoryboardSegue *)segue
{
    [tbvPay reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.


    _redeemPoints = @"";
    _wordPressUserList = [[NSMutableArray alloc]init];
    _vwDimBackground = [[UIView alloc]initWithFrame:self.view.frame];
    _vwDimBackground.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    
    [[NSNotificationCenter defaultCenter] addObserver:self                                             selector:@selector(keyboardWillShow:)
                                name:UIKeyboardWillShowNotification
                                object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                selector:@selector(keyboardWillHide:)
                                name:UIKeyboardWillHideNotification
                                object:nil];
                                            
    //Register table
    tbvPay.delegate = self;
    tbvPay.dataSource = self;
    tbvPay.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    
    {
        UINib *nib = [UINib nibWithNibName:reuseIdentifierOrder bundle:nil];
        [tbvPay registerNib:nib forCellReuseIdentifier:reuseIdentifierOrder];
    }

    {
        [tbvPay registerNib:[UINib nibWithNibName:reuseIdentifierOrderSummary bundle:nil] forHeaderFooterViewReuseIdentifier:reuseIdentifierOrderSummary];
    }
    
    {
        UINib *nib = [UINib nibWithNibName:reuseIdentifierReward bundle:nil];
        [tbvPay registerNib:nib forCellReuseIdentifier:reuseIdentifierReward];
    }
    
    
    //*****************************************
    //tbvDiscount
    float tbvDiscountWidth = self.view.frame.size.width;
    float tbvDiscountHeight = 44*3+30;
    CGRect tbvDiscountFrame = CGRectMake((self.view.frame.size.width-tbvDiscountWidth)/2, (self.view.frame.size.height-tbvDiscountHeight)/2, tbvDiscountWidth, tbvDiscountHeight);
    
    
    _tbvDiscount = [[UITableView alloc]initWithFrame:tbvDiscountFrame style:UITableViewStylePlain];
    _tbvDiscount.delegate = self;
    _tbvDiscount.dataSource = self;
    _tbvDiscount.scrollEnabled = NO;
    
    {
        UINib *nib = [UINib nibWithNibName:reuseIdentifierDiscount bundle:nil];
        [_tbvDiscount registerNib:nib forCellReuseIdentifier:reuseIdentifierDiscount];
    }
    {
        UINib *nib = [UINib nibWithNibName:reuseIdentifierDiscountReason bundle:nil];
        [_tbvDiscount registerNib:nib forCellReuseIdentifier:reuseIdentifierDiscountReason];
    }
    {
        UINib *nib = [UINib nibWithNibName:reuseIdentifierSaveCancel bundle:nil];
        [_tbvDiscount registerNib:nib forCellReuseIdentifier:reuseIdentifierSaveCancel];
    }
    
    //add dropshadow
    [self addDropShadow:_tbvDiscount];
    //*****************************************
    
    
    //_tbvWordPressRegister
    float tbvWordPressRegisterWidth = self.view.frame.size.width;
    float tbvWordPressRegisterHeight = 44*3+30;
    CGRect tbvWordPressRegisterFrame = CGRectMake((self.view.frame.size.width-tbvWordPressRegisterWidth)/2, (self.view.frame.size.height-tbvWordPressRegisterHeight)/2, tbvWordPressRegisterWidth, tbvWordPressRegisterHeight);
    
    
    _tbvWordPressRegister = [[UITableView alloc]initWithFrame:tbvWordPressRegisterFrame style:UITableViewStylePlain];
    _tbvWordPressRegister.delegate = self;
    _tbvWordPressRegister.dataSource = self;
    _tbvWordPressRegister.scrollEnabled = NO;
    
    {
        UINib *nib = [UINib nibWithNibName:reuseIdentifierDiscountReason bundle:nil];
        [_tbvWordPressRegister registerNib:nib forCellReuseIdentifier:reuseIdentifierDiscountReason];
    }
    {
        UINib *nib = [UINib nibWithNibName:reuseIdentifierSaveCancel bundle:nil];
        [_tbvWordPressRegister registerNib:nib forCellReuseIdentifier:reuseIdentifierSaveCancel];
    }
    
    //add dropshadow
    [self addDropShadow:_tbvWordPressRegister];
    //*****************************************
    
    //_tbvRedeem
    float tbvRedeemWidth = self.view.frame.size.width;
    float tbvRedeemHeight = 44*2+30;
    CGRect tbvRedeemFrame = CGRectMake((self.view.frame.size.width-tbvRedeemWidth)/2, (self.view.frame.size.height-tbvRedeemHeight)/2, tbvRedeemWidth, tbvRedeemHeight);
    
    
    _tbvRedeem = [[UITableView alloc]initWithFrame:tbvRedeemFrame style:UITableViewStylePlain];
    _tbvRedeem.delegate = self;
    _tbvRedeem.dataSource = self;
    _tbvRedeem.scrollEnabled = NO;
    
    {
        UINib *nib = [UINib nibWithNibName:reuseIdentifierDiscountReason bundle:nil];
        [_tbvRedeem registerNib:nib forCellReuseIdentifier:reuseIdentifierDiscountReason];
    }
    {
        UINib *nib = [UINib nibWithNibName:reuseIdentifierSaveCancel bundle:nil];
        [_tbvRedeem registerNib:nib forCellReuseIdentifier:reuseIdentifierSaveCancel];
    }
    
    //add dropshadow
    [self addDropShadow:_tbvRedeem];
    //*****************************************
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tapGesture];
    [tapGesture setCancelsTouchesInView:NO];
                                     
                                     
    //xxxxxx
    _event = [Event getSelectedEvent];
    _strDiscount = @"1";
    _strDiscountValuePercent = @"";
    
    
    _formatter = [[NSNumberFormatter alloc] init];
    [_formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    _productBuyList = [SharedProductBuy sharedProductBuy].productBuyList;
    
    {
        float controlWidth = self.view.frame.size.width-2*40-6;//tableView.bounds.size.width-2*15;// - 40*2;//minus left, right margin
        float controlHeight = 25;
        float controlXOrigin = 15+6;
        float controlYOrigin = (44-25)/2;
        
        
        _lblRewardProgramDetail = [ [UILabel alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, controlHeight)];
        _lblRewardProgramDetail.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:14];
        
        
        _btnRedeemPoint = [[UIButton alloc]initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, controlHeight)];
        [_btnRedeemPoint setTitle:@"Use point" forState:UIControlStateNormal];
        [_btnRedeemPoint setTitleColor:tBlueColor forState:UIControlStateNormal];
        _btnRedeemPoint.titleLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:14];
        [_btnRedeemPoint sizeToFit];
        [_btnRedeemPoint addTarget:self action:@selector(redeemPointButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        
        _btnCancelRedeemPoint = [[UIButton alloc]initWithFrame:CGRectMake(controlXOrigin+_btnRedeemPoint.frame.size.width+8, controlYOrigin, controlWidth, controlHeight)];
        [_btnCancelRedeemPoint setTitle:@"Cancel" forState:UIControlStateNormal];
        [_btnCancelRedeemPoint setTitleColor:tBlueColor forState:UIControlStateNormal];
        _btnCancelRedeemPoint.titleLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:14];
        [_btnCancelRedeemPoint sizeToFit];
        [_btnCancelRedeemPoint addTarget:self action:@selector(cancelRedeemPointButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        
        _lblPointUsed = [ [UILabel alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, controlHeight)];
        _lblPointUsed.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:14];
        _lblPointUsed.text = @"No point used";
    }
    
    {
        float channelWidth = self.view.frame.size.width-2*15;
        float channelHeight = 29;
        float channelXOrigin = 15;
        float channelYOrigin = (39 - 25)/2;
        
        
        float postWidth = 18;
        float postHeight = 18;
        float postXOrigin = self.view.frame.size.width-postWidth-15;
        float postYOrigin = (39 - postHeight - 4)/2;
        
        
        float controlWidth = self.view.frame.size.width-2*40;//tableView.bounds.size.width-2*15;// - 40*2;//minus left, right margin
        float controlHeight = 25;
        float controlXOrigin = 15;
        float controlYOrigin = (39-25)/2;//20+(tableView.rowHeight - 25)/2;//table row height minus control height and set vertical
        
        _txtSalesRemark = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, controlHeight)];
        _txtSalesRemark.placeholder = @"Sales remark";
        _txtSalesRemark.clearButtonMode = UITextFieldViewModeWhileEditing;
        _txtSalesRemark.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
        [_txtSalesRemark  setFont: [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:14]];
        
    
        
        _txtReferenceOrderNo = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, controlHeight)];
        _txtReferenceOrderNo.placeholder = @"Reference order no.";
        _txtReferenceOrderNo.clearButtonMode = UITextFieldViewModeWhileEditing;
        _txtReferenceOrderNo.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
        [_txtReferenceOrderNo  setFont: [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:14]];
        
        
        
        //segConChannel
        NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
        NSString *channelForUserKey = [NSString stringWithFormat:@"channel %@",username];
        NSInteger channelForUserValue = [[NSUserDefaults standardUserDefaults] integerForKey:channelForUserKey];
        
        
        _segConChannel = [[UISegmentedControl alloc]initWithItems:@[@"Event",@"Web",@"Line",@"FB",@"Shop",@"Other"]];
        _segConChannel.tintColor = [UIColor blackColor];
        _segConChannel.frame = CGRectMake(channelXOrigin, channelYOrigin, channelWidth, channelHeight);
        [_segConChannel setSelectedSegmentIndex:channelForUserValue];
        [_segConChannel addTarget:self action:@selector(segConChannelValueDidChange:) forControlEvents:UIControlEventValueChanged];


        //segConShip
        NSString *shipForUserKey = [NSString stringWithFormat:@"ship %@",username];
        NSInteger shipForUserValue = [[NSUserDefaults standardUserDefaults] integerForKey:shipForUserKey];
        
        
        _segConShip = [[UISegmentedControl alloc]initWithItems:@[@"Ship",@"No"]];
        _segConShip.tintColor = [UIColor blackColor];
        _segConShip.frame = CGRectMake(channelXOrigin, channelYOrigin, channelWidth, channelHeight);
        [_segConShip setSelectedSegmentIndex:shipForUserValue];
        [_segConShip addTarget:self action:@selector(segConShipValueDidChange:) forControlEvents:UIControlEventValueChanged];
        
        
        //assign ship to item
        for(int i=0; i<[_productBuyList count]; i++)
        {
            CustomMade *customMade = (CustomMade *)_productBuyList[i][productBuyDetail];
            ProductDetail *productDetail = (ProductDetail *)_productBuyList[i][productBuyDetail];
            if([self isProductInventoryOrPreOrder:i])
            {
                productDetail.ship = _segConShip.selectedSegmentIndex == 0;
            }
            else
            {
                customMade.ship = _segConShip.selectedSegmentIndex == 0;
            }
        }
        
        
        
        
        //segConSalesUser
        NSString *salesUserForUserKey = [NSString stringWithFormat:@"salesUser %@",username];
        NSInteger salesUserForUserValue = [[NSUserDefaults standardUserDefaults] integerForKey:salesUserForUserKey];
        
        
        _salesUserList = @[@"M1",@"M2",@"M3",@"No"];
        _segConSalesUser = [[UISegmentedControl alloc]initWithItems:_salesUserList];
        _segConSalesUser.tintColor = [UIColor blackColor];
        _segConSalesUser.frame = CGRectMake(channelXOrigin, channelYOrigin, channelWidth, channelHeight);
        [_segConSalesUser setSelectedSegmentIndex:salesUserForUserValue];
        [_segConSalesUser addTarget:self action:@selector(segConSalesUserValueDidChange:) forControlEvents:UIControlEventValueChanged];
        
    }
    
    {
        float bahtPercentWidth = 120;
        float bahtPercentHeight = 29;
        float bahtPercentXOrigin = self.view.frame.size.width-bahtPercentWidth-15;
        float bahtPercentYOrigin = (39 - 25)/2;
        
        
        float discountReasonControlWidth = self.view.frame.size.width-2*40;// - 40*2;//minus left, right margin
        float controlWidth = self.view.frame.size.width-bahtPercentWidth-2*40;// - 40*2;//minus left, right margin
        float controlHeight = 25;
        float controlXOrigin = 15;
        float controlYOrigin = (39 - 25)/2;//table row height minus control height and set vertical center
        
        _txtDiscountValuePercent = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, controlHeight)];
        _txtDiscountValuePercent.placeholder = @"Discount value";
        _txtDiscountValuePercent.clearButtonMode = UITextFieldViewModeWhileEditing;
        _txtDiscountValuePercent.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
        _txtDiscountValuePercent.keyboardType = UIKeyboardTypeDecimalPad;
        [_txtDiscountValuePercent  setFont: [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:14]];
//        _txtDiscountValuePercent.delegate = self;
        [_txtDiscountValuePercent addTarget:self action:@selector(txtDiscountValuePercentDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        
        _segConBahtPercent = [[UISegmentedControl alloc]initWithItems:@[@"Baht",@"Percent"]];
        _segConBahtPercent.tintColor = [UIColor blackColor];
        _segConBahtPercent.frame = CGRectMake(bahtPercentXOrigin, bahtPercentYOrigin, bahtPercentWidth, bahtPercentHeight);
        [_segConBahtPercent setSelectedSegmentIndex:0];
        [_segConBahtPercent addTarget:self action:@selector(segConBahtPercentValueDidChange:) forControlEvents:UIControlEventValueChanged];
        
        
        _txtDiscountReason = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, discountReasonControlWidth, controlHeight)];
        _txtDiscountReason.placeholder = @"Discount reason";
        _txtDiscountReason.clearButtonMode = UITextFieldViewModeWhileEditing;
        _txtDiscountReason.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
        [_txtDiscountReason  setFont: [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:14]];
        _txtDiscountReason.delegate = self;
    }
    
    {
        float controlWidth = self.view.frame.size.width-2*40;
        float controlHeight = 25;
        float controlXOrigin = 15;
        float controlYOrigin = (39-25)/2;
        
        _txtCreditAmount = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth/2-30, controlHeight)];
        _txtCreditAmount.placeholder = @"Credit";
        _txtCreditAmount.clearButtonMode = UITextFieldViewModeWhileEditing;
        _txtCreditAmount.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
        _txtCreditAmount.keyboardType = UIKeyboardTypeDecimalPad;
        [_txtCreditAmount  setFont: [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:14]];
        [_txtCreditAmount addTarget:self action:@selector(txtCreditAmountDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        
        _txtCashReceive = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin+controlWidth/2, controlYOrigin, controlWidth/2, controlHeight)];
        _txtCashReceive.placeholder = @"Cash";
        _txtCashReceive.clearButtonMode = UITextFieldViewModeWhileEditing;
        _txtCashReceive.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
        _txtCashReceive.keyboardType = UIKeyboardTypeDecimalPad;
        [_txtCashReceive  setFont: [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:14]];
        [_txtCashReceive addTarget:self action:@selector(txtCashReceiveDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        
        _txtTransferAmount = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth/2-30, controlHeight)];
        _txtTransferAmount.placeholder = @"Transfer";
        _txtTransferAmount.clearButtonMode = UITextFieldViewModeWhileEditing;
        _txtTransferAmount.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
        _txtTransferAmount.keyboardType = UIKeyboardTypeDecimalPad;
        [_txtTransferAmount  setFont: [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:14]];
        [_txtTransferAmount addTarget:self action:@selector(txtTransferAmountDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        
        _lblChanges = [ [UILabel alloc] initWithFrame:CGRectMake(controlXOrigin+6, controlYOrigin, controlWidth-6, controlHeight)];
        _lblChanges.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:14];
//        _lblChanges.text = [NSString stringWithFormat:@"Changes: %@ Baht",[self getStrChanges]];
        
        
        _btnPay = [[UIButton alloc]initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, controlHeight)];
        _btnPay.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_btnPay setTitleColor:_btnPay.tintColor forState:UIControlStateNormal];
        [_btnPay setTitle:@"Pay" forState:UIControlStateNormal];
        [_btnPay addTarget:self action:@selector(payButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }

    _time = 0;
    _pointSpentActual = 0;
    _rewardProgramCollect = [RewardProgram getRewardProgramCurrentCollect];
    _rewardProgramUse = [RewardProgram getRewardProgramCurrentUse];
    
    
    if(_rewardProgramUse)
    {
        NSString *strPointSpent = [NSString stringWithFormat:@"%ld",_rewardProgramUse.pointSpent];
        strPointSpent = [Utility formatBaht:strPointSpent withMinFraction:0 andMaxFraction:2];
        NSString *strDiscountAmount = [NSString stringWithFormat:@"%f",_rewardProgramUse.discountAmount];
        strDiscountAmount = [Utility formatBaht:strDiscountAmount withMinFraction:0 andMaxFraction:2];
        if(_rewardProgramUse.discountType == 0)
        {
            _lblRewardProgramDetail.text = [NSString stringWithFormat:@"Spent %@ point and get %@ baht",strPointSpent, strDiscountAmount];
        }
        else if(_rewardProgramUse.discountType == 1)
        {
            if(_rewardProgramUse.pointSpent == 0)
            {
                _lblRewardProgramDetail.text = [NSString stringWithFormat:@"Spent point equal to total amount and get %@%%", strDiscountAmount];
            }
            else
            {
                _lblRewardProgramDetail.text = [NSString stringWithFormat:@"Spent %@ point and get %@%%",strPointSpent,strDiscountAmount];
            }
        }
    }
    else
    {
        _lblRewardProgramDetail.text = @"No reward promotion";
    }
    
    
    for(int i=0; i<[_productBuyList count]; i++)
    {
        CustomMade *customMade = (CustomMade *)_productBuyList[i][productBuyDetail];
        ProductDetail *productDetail = (ProductDetail *)_productBuyList[i][productBuyDetail];
        if([self isProductInventoryOrPreOrder:i])
        {
            if(productDetail.postCustomerID > 0)
            {
                PostCustomer *postCustomer = [self getPostCustomer:productDetail.postCustomerID];
                _telephoneNoInput = postCustomer.telephone;
                break;
            }
        }
        else
        {
            if(customMade.postCustomerID > 0)
            {
                PostCustomer *postCustomer = [self getPostCustomer:customMade.postCustomerID];
                _telephoneNoInput = postCustomer.telephone;
                break;
            }
        }
    }
    [self searchPostCustomerAndReward];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
}

- (NSInteger)getRewardPoint //edit later
{
//    if([[SharedPostBuy sharedPostBuy].postBuyList count] > 0)
//    {
//        PostCustomer *postCustomer = [SharedPostBuy sharedPostBuy].postBuyList[0];
//        return  [RewardPoint getRewardPointPointWithCustomerID:postCustomer.customerID];
//    }
//    else
    {
        return 0;
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
        
    tbvPay.contentInset = contentInsets;
    tbvPay.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    tbvPay.contentInset = UIEdgeInsetsZero;
    tbvPay.scrollIndicatorInsets = UIEdgeInsetsZero;
}

//-(void)txtTelephoneNoDidChange :(UITextField *)textField
//{
//    if([[Utility trimString:textField.text] length] >= 10)
//    {
//        HomeModel *homeModel = [[HomeModel alloc]init];
//        homeModel.delegate = self;
//        [homeModel downloadItems:dbPostCustomerSearch condition:[Utility removeDashAndSpaceAndParenthesis:textField.text]];
//    }
//}

-(void)itemsDownloaded:(NSArray *)items
{
    NSArray *postCustomerList = items[0];
    _wordPressUserList = items[1];
    if([postCustomerList count]>0)
    {
        //input into sharedPostBuy
        for(PostCustomer *item in postCustomerList)
        {
            PostCustomer *postCustomer = [self getPostCustomer:item.postCustomerID];
            if(postCustomer)
            {
                [[SharedPostBuy sharedPostBuy].postBuyList removeObject:postCustomer];
            }
        }
        [[SharedPostBuy sharedPostBuy].postBuyList addObjectsFromArray:postCustomerList];
        
        
        PostCustomer *postCustomer = postCustomerList[0];
        for(int i=0; i < [_productBuyList count]; i++)
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
        [tbvPay reloadSections:[[NSIndexSet alloc] initWithIndex:1] withRowAnimation:NO];
    }
    else
    {
        [self removePostCustomer];
        [tbvPay reloadSections:[[NSIndexSet alloc] initWithIndex:1] withRowAnimation:NO];
    }
}

-(void)removePostCustomer
{
    for(int i=0; i < [_productBuyList count]; i++)
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

-(float)getCredit
{
    _txtCreditAmount.text = [Utility trimString:_txtCreditAmount.text];
    if([_txtCreditAmount.text isEqualToString:@""])
    {
        return 0;
    }
    else
    {
        return [_txtCreditAmount.text floatValue];
    }
}

-(float)getCash
{
    _txtCashReceive.text = [Utility trimString:_txtCashReceive.text];
    if([_txtCashReceive.text isEqualToString:@""])
    {
        return 0;
    }
    else
    {
        return [_txtCashReceive.text floatValue];
    }
}

-(float)getTransfer
{
    _txtTransferAmount.text = [Utility trimString:_txtTransferAmount.text];
    if([_txtTransferAmount.text isEqualToString:@""])
    {
        return 0;
    }
    else
    {
        return [_txtTransferAmount.text floatValue];
    }
}

- (NSString *)getStrFmtDiscountValue
{
    NSString *strDiscountValue = [_formatter stringFromNumber:[NSNumber numberWithFloat:[self getDiscountValue]]];
    return strDiscountValue;
}

-(float)getDiscountValue
{
    float discountValue = 0;
    
    for(int i=0; i<[_productBuyList count]; i++)
    {
        CustomMade *customMade = (CustomMade *)_productBuyList[i][productBuyDetail];
        ProductDetail *productDetail = (ProductDetail *)_productBuyList[i][productBuyDetail];
        if([self isProductInventoryOrPreOrder:i])
        {
            if(productDetail.discount == 1)//baht
            {
                discountValue += productDetail.discountValue;
            }
            else if(productDetail.discount == 2)//percent
            {
                discountValue += roundf(productDetail.discountPercent*[Utility floatValue:productDetail.pricePromotion]/100);
            }
        }
        else
        {
            if(productDetail.discount == 1)//baht
            {
                discountValue += customMade.discountValue;
            }
            else if(productDetail.discount == 2)//percent
            {
                discountValue += roundf(customMade.discountPercent*[Utility floatValue:_productBuyList[i][productBuyPricePromotion]]/100);
            }
        }
    }
    
    return discountValue;
}

-(NSString *)getSalesUser
{
    NSString *salesUser = _salesUserList[_segConSalesUser.selectedSegmentIndex];
    if([salesUser isEqualToString:@"No"])
    {
        salesUser = [Utility modifiedUser];
    }
    return salesUser;
}

-(NSInteger)getShippingFee
{
    float shippingFee = 0;
    for(int i=0; i<[_productBuyList count]; i++)
    {
        CustomMade *customMade = (CustomMade *)_productBuyList[i][productBuyDetail];
        ProductDetail *productDetail = (ProductDetail *)_productBuyList[i][productBuyDetail];
        if([self isProductInventoryOrPreOrder:i])
        {
            if(productDetail.ship)
            {
                shippingFee += [Utility floatValue:[Utility setting:vShippingFee]];
            }
        }
        else
        {
            if(customMade.ship)
            {
                shippingFee += [Utility floatValue:[Utility setting:vShippingFee]];
            }
        }
    }
    
    
//    NSInteger shippingFee = _segConShip.selectedSegmentIndex==0?[[Utility setting:vShippingFee] integerValue]*[_productBuyList count]:0;
    return shippingFee;
}

-(NSString *)getStrShippingFee
{
    NSString *strShippingFee = [_formatter stringFromNumber:[NSNumber numberWithInteger:[self getShippingFee]]];
    
    return strShippingFee;
}

-(float)getChanges
{
    //credit+cash-(totalAmount+shippingFee)
    
    float changes = [self getCredit]+[self getCash]+[self getTransfer]-([self getAfterDiscountValue]);
    return changes;
}

-(NSString *)getStrChanges
{
    NSString *strChanges = [_formatter stringFromNumber:[NSNumber numberWithFloat:[self getChanges]]];
    
    return strChanges;
}

-(void)segConChannelValueDidChange:(UISegmentedControl *)segment
{
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSString *channelForUserKey = [NSString stringWithFormat:@"channel %@",username];
    [[NSUserDefaults standardUserDefaults] setInteger:segment.selectedSegmentIndex forKey:channelForUserKey];
}

-(void)segConShipValueDidChange:(UISegmentedControl *)segment
{
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSString *shipForUserKey = [NSString stringWithFormat:@"ship %@",username];
    [[NSUserDefaults standardUserDefaults] setInteger:segment.selectedSegmentIndex forKey:shipForUserKey];
    
    
    for(int i=0; i<[_productBuyList count]; i++)
    {
        CustomMade *customMade = (CustomMade *)_productBuyList[i][productBuyDetail];
        ProductDetail *productDetail = (ProductDetail *)_productBuyList[i][productBuyDetail];
        if([self isProductInventoryOrPreOrder:i])
        {
            productDetail.ship = _segConShip.selectedSegmentIndex == 0;
        }
        else
        {
            customMade.ship = _segConShip.selectedSegmentIndex == 0;
        }
    }
    
//    _lblChanges.text = [NSString stringWithFormat:@"Changes: %@ Baht",[self getStrChanges]];
    [tbvPay reloadData];
}

-(void)segConSalesUserValueDidChange:(UISegmentedControl *)segment
{
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSString *salesUserForUserKey = [NSString stringWithFormat:@"salesUser %@",username];
    [[NSUserDefaults standardUserDefaults] setInteger:segment.selectedSegmentIndex forKey:salesUserForUserKey];
}

-(void)segConBahtPercentValueDidChange:(UISegmentedControl *)segment
{
    _strDiscount = segment.selectedSegmentIndex==0?@"1":@"2";
    [self txtDiscountValuePercentDidChange:_txtDiscountValuePercent];
}

-(void)txtCreditAmountDidChange :(UITextField *)textField
{
    _lblChanges.text = [NSString stringWithFormat:@"Changes: %@ Baht",[self getStrChanges]];
}

-(void)txtCashReceiveDidChange :(UITextField *)textField
{
    _lblChanges.text = [NSString stringWithFormat:@"Changes: %@ Baht",[self getStrChanges]];
}

-(void)txtTransferAmountDidChange :(UITextField *)textField
{
    _lblChanges.text = [NSString stringWithFormat:@"Changes: %@ Baht",[self getStrChanges]];
}

-(float)getAfterDiscountValue
{
    return [self getTotalAmount]+[self getShippingFee]-[self getDiscountValue]-[self getRedeemedValue];
}

-(float)getBeforeRedeemedValue
{
    return [self getTotalAmount]+[self getShippingFee]-[self getDiscountValue];
}

-(float)getRedeemedValue
{
    if(![Utility isStringEmpty:_redeemPoints])
    {
        WordPressUser *wordPressUser = _wordPressUserList[0];
        float value = ceil(1.0*[_redeemPoints integerValue]/wordPressUser.pointPerBaht);
        if(value > [self getBeforeRedeemedValue])
        {
            value = [self getBeforeRedeemedValue];
        }
        return value;
    }
    return 0;
}

-(NSString *)getStrFmtAfterDiscountValue
{
    NSString *strAfterDiscountValue = [_formatter stringFromNumber:[NSNumber numberWithFloat:[self getAfterDiscountValue]]];

    return strAfterDiscountValue;
}

-(NSString *)getDiscountLabel
{
    NSString *discountLabel = @"Discount";
    if(_time == 0)
    {
        if([_strDiscount intValue] == 2)
        {
            discountLabel = [NSString stringWithFormat:@"Disc (%@\uFF05)",_strDiscountValuePercent];
        }
        else
        {
            discountLabel = [NSString stringWithFormat:@"Discount"];
        }
    }
    else
    {
        if([_strDiscount intValue] == 2)
        {
            discountLabel = [NSString stringWithFormat:@"Use %ld point for disc (%@\uFF05)",_pointSpentActual,_strDiscountValuePercent];
        }
        else
        {
            discountLabel = [NSString stringWithFormat:@"Use %ld point for discount",_pointSpentActual];
        }
    }
    
    return discountLabel;
}

-(void)txtDiscountValuePercentDidChange:(UITextField *)textField{
    _strDiscountValuePercent = [Utility removeComma:[Utility trimString:textField.text]];
    
    for(int i=0; i<[_productBuyList count]; i++)
    {
        CustomMade *customMade = (CustomMade *)_productBuyList[i][productBuyDetail];
        ProductDetail *productDetail = (ProductDetail *)_productBuyList[i][productBuyDetail];
        if(![Utility isStringEmpty:textField.text] && [Utility floatValue:textField.text]>0)
        {
            if([self isProductInventoryOrPreOrder:i])
            {
                productDetail.discount = _segConBahtPercent.selectedSegmentIndex == 0?1:2;
                productDetail.discountValue = _segConBahtPercent.selectedSegmentIndex == 0?[Utility floatValue:textField.text]:0;
                productDetail.discountPercent = _segConBahtPercent.selectedSegmentIndex == 1?[Utility floatValue:textField.text]:0;
            }
            else
            {
                customMade.discount = _segConBahtPercent.selectedSegmentIndex == 0?1:2;
                customMade.discountValue = _segConBahtPercent.selectedSegmentIndex == 0?[Utility floatValue:textField.text]:0;
                customMade.discountPercent = _segConBahtPercent.selectedSegmentIndex == 1?[Utility floatValue:textField.text]:0;
            }
        }
    }
    [tbvPay reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:NO];
    _lblChanges.text = [NSString stringWithFormat:@"Changes: %@ Baht",[self getStrChanges]];
    
    
    if([self getDiscountValue]/[self getTotalAmount] > 0.5)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                       message:@"Discount > 50%" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action){}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (NSString *)getStrFmtTotalAmount
{
    NSString *total = [_formatter stringFromNumber:[NSNumber numberWithFloat:[self getTotalAmount]]];
    return total;
}

- (float)getTotalAmount
{
    float sumValue=0;
    for(int i=0; i<[_productBuyList count]; i++)
    {
        sumValue += [_productBuyList[i][productBuyPricePromotion] floatValue];
    }
    return sumValue;
}

- (void)updateCalculateParts
{
    //total,discount,afterdiscount,changes
    [tbvPay reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if(tableView == tbvPay)
    {
        return 4;
    }
    else if(tableView == _tbvDiscount)
    {
        return 1;
    }
    else if(tableView == _tbvWordPressRegister)
    {
        return 1;
    }
    else if(tableView == _tbvRedeem)
    {
        return 1;
    }

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger row = 0;
    if(tableView == tbvPay)
    {
        if(section == 0)
        {
            row = [_productBuyList count];
        }
        else if(section == 1)
        {
            row = 5;
        }
        else if(section == 2)
        {
            row = 2;
        }
        else if(section == 3)
        {
            row = 4;
        }
    }
    else if(tableView == _tbvDiscount)
    {
        row = 3;
    }
    else if(tableView == _tbvWordPressRegister)
    {
        row = 3;
    }
    else if(tableView == _tbvRedeem)
    {
        row = 2;
    }
    
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == tbvPay)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if(indexPath.section == 0)
        {
            CustomTableViewCellOrder *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierOrder];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            
            CustomMade *customMade = (CustomMade *)_productBuyList[indexPath.item][productBuyDetail];
            ProductDetail *productDetail = (ProductDetail *)_productBuyList[indexPath.item][productBuyDetail];
            NSString *strImageFileName = _productBuyList[indexPath.item][productBuyImageFileName];
            
            cell.lblRowNo.text = [NSString stringWithFormat:@"%ld.", indexPath.item+1];
            


            //imgProduct
            [cell.activityIndicator startAnimating];
            [self.navigationController.view addSubview:cell.overlayView];
            [self.navigationController.view addSubview:cell.activityIndicator];
            
            
            NSLog(@"download product image");
            NSString *imageFileName = strImageFileName;
            [self.homeModel downloadImageWithFileName:imageFileName completionBlock:^(BOOL succeeded, UIImage *image) {
                if (succeeded) {
                    cell.imgProduct.image = image;
                    [UIView animateWithDuration:0.5
                                    animations:^{
                                        cell.overlayView.alpha = 0.0;
                                        cell.activityIndicator.alpha = 0;
                                    }
                                    completion:^(BOOL finished){
                                        dispatch_async(dispatch_get_main_queue(),^ {
                                            [cell.overlayView removeFromSuperview];
                                            [cell.activityIndicator stopAnimating];
                                            [cell.activityIndicator removeFromSuperview];
                                        } );
                                    }
                    ];
                    NSLog(@"download image successful");
                }else
                {
                    [UIView animateWithDuration:0.5
                                    animations:^{
                                        cell.overlayView.alpha = 0.0;
                                        cell.activityIndicator.alpha = 0;
                                    }
                                    completion:^(BOOL finished){
                                        dispatch_async(dispatch_get_main_queue(),^ {
                                            [cell.overlayView removeFromSuperview];
                                            [cell.activityIndicator stopAnimating];
                                            [cell.activityIndicator removeFromSuperview];
                                        } );
                                    }
                    ];
                    NSLog(@"download image fail");
                }
            }];
            
            
            //lblProduct
            if([self isProductInventoryOrPreOrder:indexPath.item])
            {
                [cell.btnProduct setTitle:[NSString stringWithFormat:@"%@ / %@ / %@",productDetail.productName,productDetail.color,[Utility getSizeLabel:productDetail.size]] forState:UIControlStateNormal];
            }
            else
            {
                NSString *productNameGroup = [NSString stringWithFormat:@"%@%@%@",customMade.productCategory2,customMade.productCategory1,customMade.productName];
                [cell.btnProduct setTitle:[NSString stringWithFormat:@"%@ / %@ / %@",[ProductName getNameWithProductNameGroup:productNameGroup],customMade.body,customMade.size] forState:UIControlStateNormal];
            }
            [cell.btnProduct addTarget:self action:@selector(productTapped:) forControlEvents:UIControlEventTouchUpInside];
            cell.btnProduct.tag = indexPath.item;
            if([self isPreOrder2:indexPath.item])
            {
                cell.btnProduct.tintColor = tPinkColor;
            }
            else
            {
                cell.btnProduct.tintColor = tBlueColor;
            }
            
            
            
            //replace
            if([self isProductInventoryOrPreOrder:indexPath.item])
            {
                cell.lblReplaceWidth.constant = productDetail.replaceProduct?cell.lblReplaceWidth.constant:0;
                cell.lblReplaceLeading.constant = productDetail.replaceProduct?cell.lblReplaceLeading.constant:0;
            }
            else
            {
                cell.lblReplaceWidth.constant = customMade.replaceProduct?cell.lblReplaceWidth.constant:0;
                cell.lblReplaceLeading.constant = customMade.replaceProduct?cell.lblReplaceLeading.constant:0;
            }
            
            
            
            //ship
            if([self isProductInventoryOrPreOrder:indexPath.item])
            {
                cell.lblShip.hidden = !productDetail.ship;
            }
            else
            {
                cell.lblShip.hidden = !customMade.ship;
            }
            
            
            
            
            //btnPost
            if([self isProductInventoryOrPreOrder:indexPath.item])
            {
                cell.btnPost.imageView.image = productDetail.postCustomerID == 0?[UIImage imageNamed:@"postCustomerNo2.png"]:[UIImage imageNamed:@"postCustomer2.png"];
            }
            else
            {
                cell.btnPost.imageView.image = customMade.postCustomerID == 0?[UIImage imageNamed:@"postCustomerNo2.png"]:[UIImage imageNamed:@"postCustomer2.png"];
            }
            cell.btnPost.tag = indexPath.item;
            [cell.btnPost addTarget:self action:@selector(postButtonItemClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            
            
            
            //lblPrice
            NSString *pricePromotion = [_formatter stringFromNumber:[NSNumber numberWithFloat:[_productBuyList[indexPath.item][productBuyPricePromotion] floatValue]]];
            cell.lblPrice.text = pricePromotion;
            
            
            //discountLabel
            if([self isProductInventoryOrPreOrder:indexPath.item])
            {
                if(productDetail.discount == 2)//2=percent,1=baht,0=no
                {
                    cell.lblDiscountLabel.hidden = NO;
                    cell.lblDiscountLabel.text = [NSString stringWithFormat:@"Disc (%@\uFF05)",[Utility formatBaht:[NSString stringWithFormat:@"%f", productDetail.discountPercent]]];
                }
                else
                {
                    cell.lblDiscountLabel.hidden = YES;
                }
            }
            else
            {
                if(customMade.discount == 2)//2=percent,1=baht,0=no
                {
                    cell.lblDiscountLabel.hidden = NO;
                    cell.lblDiscountLabel.text = [NSString stringWithFormat:@"Disc (%@\uFF05)",[Utility formatBaht:[NSString stringWithFormat:@"%f", customMade.discountPercent]]];
                }
                else
                {
                    cell.lblDiscountLabel.hidden = YES;
                }
            }
            
            
            //discountValue
            if([self isProductInventoryOrPreOrder:indexPath.item])
            {
                float discountValue = 0;
                if(productDetail.discount == 1)//baht
                {
                    discountValue = productDetail.discountValue;
                }
                else if(productDetail.discount == 2)//percent
                {
                    discountValue = roundf(productDetail.discountPercent*[Utility floatValue:productDetail.pricePromotion]/100);
                }
                
                if(discountValue == 0)
                {
                    cell.lblDiscountValue.text = @"";
                }
                else
                {
                    cell.lblDiscountValue.text = [NSString stringWithFormat:@"-%@",[Utility formatBaht:[NSString stringWithFormat:@"%f", discountValue]]];
                }
            }
            else
            {
                float discountValue = 0;
                if(customMade.discount == 1)//baht
                {
                    discountValue = customMade.discountValue;
                }
                else if(customMade.discount == 2)//percent
                {
                    discountValue = roundf(customMade.discountPercent*[Utility floatValue:_productBuyList[indexPath.item][productBuyPricePromotion]]/100);
                }
                
                if(discountValue == 0)
                {
                    cell.lblDiscountValue.text = @"";
                }
                else
                {
                    cell.lblDiscountValue.text = [NSString stringWithFormat:@"-%@",[Utility formatBaht:[NSString stringWithFormat:@"%f", discountValue]]];
                }
            }
            
            
            return cell;
        }
        if(indexPath.section == 1)
        {
            switch (indexPath.row) {
                case 0:
                {
                    [cell addSubview:_txtSalesRemark];
                }
                    break;
                case 1:
                {
                    CustomTableViewCellReward *cell = [tbvPay dequeueReusableCellWithIdentifier:reuseIdentifierReward];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    
                    cell.txtTelephoneNo.text = _telephoneNoInput;
                    [cell.btnPost addTarget:self action:@selector(postButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.btnPost setImage:[UIImage imageNamed:@"postCustomerNo.png"] forState:UIControlStateNormal];
                    for(int i=0; i<[_productBuyList count]; i++)
                    {
                        CustomMade *customMade = (CustomMade *)_productBuyList[i][productBuyDetail];
                        ProductDetail *productDetail = (ProductDetail *)_productBuyList[i][productBuyDetail];
                        if([self isProductInventoryOrPreOrder:i])
                        {
                            if(productDetail.postCustomerID > 0)
                            {
                                [cell.btnPost setImage:[UIImage imageNamed:@"postCustomer.png"] forState:UIControlStateNormal];
                                PostCustomer *postCustomer = [self getPostCustomer:productDetail.postCustomerID];
                                cell.txtTelephoneNo.text = [Utility insertDash:postCustomer.telephone];
                                break;
                            }
                        }
                        else
                        {
                            if(customMade.postCustomerID > 0)
                            {
                                [cell.btnPost setImage:[UIImage imageNamed:@"postCustomer.png"] forState:UIControlStateNormal];
                                PostCustomer *postCustomer = [self getPostCustomer:customMade.postCustomerID];
                                cell.txtTelephoneNo.text = [Utility insertDash:postCustomer.telephone];
                                break;
                            }
                        }
                    }
                    
                    
                    
                    
                    
//                    [cell.txtTelephoneNo addTarget:self action:@selector(txtTelephoneNoDidChange:) forControlEvents:UIControlEventEditingChanged];
                    cell.txtTelephoneNo.delegate = self;
                    cell.txtTelephoneNo.tag = 20;
                    
                    
                    
                    if([_wordPressUserList count] > 0)
                    {
                        WordPressUser *wordPressUser = _wordPressUserList[0];
                        cell.lblResult.text = [NSString stringWithFormat:@"Customer's reward points %ld ( ฿%ld )",wordPressUser.totalPoints,wordPressUser.totalBaht];
                        [cell.lblResult sizeToFit];
                        cell.lblResultWidth.constant = cell.lblResult.frame.size.width;
                        cell.lblResult.tintColor = tPinkColor;
                        
                        cell.btnRegisterLeading.constant = 0;
                        cell.btnRegisterWidth.constant = 0;
                        
                        cell.btnRedeemLeading.constant = 8;
                        [cell.btnRedeem sizeToFit];
                        cell.btnRedeemWidth.constant = cell.btnRedeem.frame.size.width;
                        [cell.btnRedeem addTarget:self action:@selector(redeemPoints:) forControlEvents:UIControlEventTouchUpInside];
                    }
                    else
                    {
                        cell.lblResult.text = @"No account found";
                        [cell.lblResult sizeToFit];
                        cell.lblResultWidth.constant = cell.lblResult.frame.size.width;
                        cell.lblResult.tintColor = [UIColor systemGroupedBackgroundColor];
                        
                        cell.btnRegisterLeading.constant = 8;
                        [cell.btnRegister sizeToFit];
                        cell.btnRegisterWidth.constant = cell.btnRegister.frame.size.width;
                        [cell.btnRegister addTarget:self action:@selector(registerWordPressUser:) forControlEvents:UIControlEventTouchUpInside];
                        
                        cell.btnRedeemLeading.constant = 0;
                        cell.btnRedeemWidth.constant = 0;
                    }
                    return cell;
                }
                    break;
                case 2:
                {
                    [cell addSubview:_segConChannel];
                }
                    break;
                case 3:
                {
                    [cell addSubview:_segConShip];
                }
                    break;
                case 4:
                {
                    [cell addSubview:_segConSalesUser];
                }
                    break;
            }
        }
        else if(indexPath.section == 2)
        {
            switch (indexPath.row) {
                case 0:
                {
                    [cell addSubview:_txtDiscountValuePercent];
                    [cell addSubview:_segConBahtPercent];
                }
                    break;
                case 1:
                {
                    [cell addSubview:_txtDiscountReason];
                }
                    break;
            }
        }
        else if(indexPath.section == 3)
        {
            switch (indexPath.row) {
                case 0:
                {
                    [cell addSubview:_txtCreditAmount];
                    [cell addSubview:_txtCashReceive];
                }
                    break;
                case 1:
                {
                    [cell addSubview:_txtTransferAmount];
                }
                    break;
                case 2:
                {
                    _lblChanges.text = [NSString stringWithFormat:@"Changes: %@ Baht",[self getStrChanges]];
                    [cell addSubview:_lblChanges];
                }
                    break;
                case 3:
                {
                    [cell addSubview:_btnPay];
                }
                    break;
            }
        }
        
        return cell;
    }
    else if(tableView == _tbvDiscount)
    {
        if(indexPath.item == 0)
        {
            CustomTableViewCellDiscount *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierDiscount];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.txtDiscount.text = [[Utility formatBaht:_discountText] isEqualToString:@"0"]?@"":[Utility formatBaht:_discountText];
            cell.segConBahtPercent.selectedSegmentIndex = _bahtPercentIndex;
            
            
            return cell;
        }
        else if(indexPath.item == 1)
        {
            CustomTableViewCellDiscountReason *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierDiscountReason];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.txtDiscountReason.text = _discountReason;
            cell.txtDiscountReason.placeholder = @"Discount reason";
            cell.txtDiscountReason.keyboardType = UIKeyboardTypeDefault;
            
            return cell;
        }
        else if(indexPath.item == 2)
        {
            CustomTableViewCellSaveCancel *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierSaveCancel];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            
            cell.btnSave.tag = tableView.tag;
            [cell.btnSave addTarget:self action:@selector(saveDiscount:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnCancel addTarget:self action:@selector(cancelDiscount:) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
    }
    else if(tableView == _tbvWordPressRegister)
    {
        if(indexPath.item == 0)
        {
            CustomTableViewCellDiscountReason *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierDiscountReason];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.txtDiscountReason.text = _wordPressEmail;
            cell.txtDiscountReason.placeholder = @"Email";
            cell.txtDiscountReason.delegate = self;
            cell.txtDiscountReason.tag = 30;
            cell.txtDiscountReason.keyboardType = UIKeyboardTypeEmailAddress;
        
            return cell;
        }
        else if(indexPath.item == 1)
        {
            CustomTableViewCellDiscountReason *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierDiscountReason];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.txtDiscountReason.text = _wordPressPhone;
            cell.txtDiscountReason.placeholder = @"Phone number";
            cell.txtDiscountReason.delegate = self;
            cell.txtDiscountReason.tag = 40;
            cell.txtDiscountReason.keyboardType = UIKeyboardTypeNumberPad;
            
            return cell;
        }
        else if(indexPath.item == 2)
        {
            CustomTableViewCellSaveCancel *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierSaveCancel];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            
            cell.btnSave.tag = tableView.tag;
            [cell.btnSave addTarget:self action:@selector(saveWordPressRegister:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnCancel addTarget:self action:@selector(cancelWordPressRegister:) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
    }
    else if(tableView == _tbvRedeem)
    {
        if(indexPath.item == 0)
        {
            CustomTableViewCellDiscountReason *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierDiscountReason];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.txtDiscountReason.text = _wordPressEmail;
            cell.txtDiscountReason.placeholder = @"Points";
            cell.txtDiscountReason.delegate = self;
            cell.txtDiscountReason.tag = 50;
            cell.txtDiscountReason.keyboardType = UIKeyboardTypeNumberPad;
            
            return cell;
        }
        else if(indexPath.item == 1)
        {
            CustomTableViewCellSaveCancel *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierSaveCancel];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            
            cell.btnSave.tag = tableView.tag;
            [cell.btnSave addTarget:self action:@selector(saveRedeem:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnCancel addTarget:self action:@selector(cancelRedeem:) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == tbvPay)
    {
        if(indexPath.section == 0)
        {
            return 74;
        }
        else if(indexPath.section == 1 && indexPath.item == 1)
        {
            return 73;
        }
        return 39;
    }
    else if(tableView == _tbvDiscount)
    {
        return 44;
    }
    else if(tableView == _tbvWordPressRegister)
    {
        return 44;
    }
    else if(tableView == _tbvRedeem)
    {
        return 44;
    }
    return 0;
}

 - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
 {
    NSString *sectionName;
    if(tableView == tbvPay)
    {
        switch (section)
        {
            case 0:
                sectionName = nil;
                break;
            case 1:
                sectionName = NSLocalizedString(@"Other", @"Other");
                break;
            case 2:
                sectionName = NSLocalizedString(@"Discount", @"Discount");
                break;
            case 3:
                sectionName = NSLocalizedString(@"Pay", @"Pay");
                break;
                // ...
            default:
                sectionName = @"";
                break;
        }
    }
    else if(tableView == _tbvDiscount)
    {
        sectionName = NSLocalizedString(@"Discount", @"Discount");
    }
    else if(tableView == _tbvWordPressRegister)
    {
        sectionName = NSLocalizedString(@"Register", @"Register");
    }
    else if(tableView == _tbvRedeem)
    {
        WordPressUser *wordPressUser = _wordPressUserList[0];
        NSString *strHeader = [NSString stringWithFormat:@"Redeem points [%ld ( ฿%ld )]",wordPressUser.totalPoints,wordPressUser.totalBaht];
        sectionName = NSLocalizedString(strHeader, strHeader);
    }
    
    return sectionName;
 }

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if(tableView == tbvPay)
    {
        if(section == 0)
        {
            CustomTableHeaderFooterViewOrderSummary *cell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:reuseIdentifierOrderSummary];
            
            cell.lblTotal.text = [self getStrFmtTotalAmount];
            cell.lblShippingFee.text = [self getStrShippingFee];
            
            //lblDiscount
            NSString *minusSign = [[self getStrFmtDiscountValue] isEqualToString:@"0"]?@"":@"-";
            cell.lblDiscount.text = [NSString stringWithFormat:@"%@%@",minusSign,[self getStrFmtDiscountValue]];
            
            //redeemed value
            if(![Utility isStringEmpty:_redeemPoints])
            {
                WordPressUser *wordPressUser = _wordPressUserList[0];
                float redeemedValue = ceil(1.0*[_redeemPoints integerValue]/wordPressUser.pointPerBaht);
                NSString *strRedeemedValue = [NSString stringWithFormat:@"%f",redeemedValue];
                cell.lblRedeemedPointValue.text = [NSString stringWithFormat:@"-%@",[Utility formatBaht:strRedeemedValue]];
                cell.lblRedeemedPointValueTop.constant = 8;
                cell.lblRedeemedPointValueHeight.constant = 17;
                cell.lblRedeemedPointValueLabelHeight.constant = 17;
                cell.btnRemoveRedeemedValue.hidden = NO;
                [cell.btnRemoveRedeemedValue addTarget:self action:@selector(removeRedeemedValue:) forControlEvents:UIControlEventTouchUpInside];
            }
            else
            {
                cell.lblRedeemedPointValueTop.constant = 0;
                cell.lblRedeemedPointValueHeight.constant = 0;
                cell.lblRedeemedPointValueLabelHeight.constant = 0;
                cell.btnRemoveRedeemedValue.hidden = YES;
            }
            
            cell.lblAfterDiscount.text = [self getStrFmtAfterDiscountValue];
            return cell;
        }
    }
    
    
    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(tableView == tbvPay)
    {
        if(section == 0)
        {
            if(![Utility isStringEmpty:_redeemPoints])
            {
                return 106+8+17;
            }
            return 106;
        }
    }
    
    return 0.01f;
}

-(void)productTapped:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger productBuyIndex = button.tag;
    CustomMade *customMade = (CustomMade *)_productBuyList[productBuyIndex][productBuyDetail];
    ProductDetail *productDetail = (ProductDetail *)_productBuyList[productBuyIndex][productBuyDetail];
    
    
    if([self isProductInventoryOrPreOrder:productBuyIndex])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
            message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            
            
        //option1 - replace
        NSString *strReplace = @"Replace product";
        if(productDetail.replaceProduct)
        {
            strReplace = @"Buy product";
        }
        
        [alert addAction:
        [UIAlertAction actionWithTitle:strReplace style:UIAlertActionStyleDestructive
        handler:^(UIAlertAction *action)
        {
           if(productDetail.replaceProduct)
           {
                //buy
                productDetail.replaceProduct = 0;
                productDetail.discount = 0;
                productDetail.discountValue = 0;
                productDetail.discountPercent = 0;
                productDetail.discountReason = @"";
                [tbvPay reloadData];
           }
           else
           {
                //show discount view
                _booReplaceProduct = YES;
                [self showDiscountView:productBuyIndex discountText:@"100" bahtPercentIndex:1 discountReason:@""];
           }
        }]];
                    
                   
        //option2 - discount
       [alert addAction:
       [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Discount"] style:UIAlertActionStyleDestructive
        handler:^(UIAlertAction *action)
        {
            //show discount view
            NSString *strDiscountText = @"";
            NSInteger bahtPercentIndex = 0;
            if(productDetail.discount == 2)
            {
                bahtPercentIndex = 1;
                strDiscountText = [NSString stringWithFormat:@"%f",productDetail.discountPercent];
            }
            else
            {
                strDiscountText = [NSString stringWithFormat:@"%f",productDetail.discountValue];
            }

            [self showDiscountView:productBuyIndex discountText:strDiscountText bahtPercentIndex:bahtPercentIndex discountReason:productDetail.discountReason];
        }]];
                
                
        //option3 - ship
        NSString *strShip = productDetail.ship?@"Unship":@"Ship";
        [alert addAction:
        [UIAlertAction actionWithTitle:strShip style:UIAlertActionStyleDestructive
        handler:^(UIAlertAction *action)
        {
            productDetail.ship = !productDetail.ship;
            [tbvPay reloadData];
        }]];
             
             
        //option4 - delete
        [alert addAction:
        [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Delete"] style:UIAlertActionStyleDestructive
        handler:^(UIAlertAction *action)
        {
            UIAlertController* alert2 = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

            [alert2 addAction:
            [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Delete product (No.%ld)",productBuyIndex+1]
                                     style:UIAlertActionStyleDestructive
                                   handler:^(UIAlertAction *action) {
                                       [_productBuyList removeObject:_productBuyList[productBuyIndex]] ;
                                       [tbvPay reloadData];
                                   }]];
            [alert2 addAction:
            [UIAlertAction actionWithTitle:@"Cancel"
                                     style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action) {}]];

            [self presentViewController:alert2 animated:YES completion:nil];
        }]];
                               
        
        [alert addAction:
         [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
        handler:^(UIAlertAction *action) {}]];


        //////////////ipad
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            [alert setModalPresentationStyle:UIModalPresentationPopover];
            
            UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
            CGRect frame = button.imageView.bounds;
            frame.origin.y = frame.origin.y-15;
            popPresenter.sourceView = button.imageView;
            popPresenter.sourceRect = frame;
        }
        ///////////////
        
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else//เหมือน case isProductInventoryOrPreOrder แค่เปลี่ยนไปใช้ object customMade แทน productDetail
    {
         UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
             message:nil preferredStyle:UIAlertControllerStyleActionSheet];
             
             
         //option1 - replace
         NSString *strReplace = @"Replace product";
         if(customMade.replaceProduct)
         {
             strReplace = @"Buy product";
         }
         
         [alert addAction:
         [UIAlertAction actionWithTitle:strReplace style:UIAlertActionStyleDestructive
         handler:^(UIAlertAction *action)
         {
            if(customMade.replaceProduct)
            {
                 //buy
                 customMade.replaceProduct = 0;
                 productDetail.discount = 0;
                 productDetail.discountValue = 0;
                 productDetail.discountPercent = 0;
                 productDetail.discountReason = @"";
                 [tbvPay reloadData];
            }
            else
            {
                 //show discount view
                 [self showDiscountView:productBuyIndex discountText:@"100" bahtPercentIndex:1 discountReason:@""];
            }
         }]];
                     
                    
         //option2 - discount
        [alert addAction:
        [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Discount"] style:UIAlertActionStyleDestructive
         handler:^(UIAlertAction *action)
         {
             //show discount view
             NSString *strDiscountText = @"";
             NSInteger bahtPercentIndex = 0;
             if(customMade.discount == 2)
             {
                 bahtPercentIndex = 1;
                 strDiscountText = [NSString stringWithFormat:@"%f",customMade.discountPercent];
             }
             else
             {
                 strDiscountText = [NSString stringWithFormat:@"%f",customMade.discountValue];
             }

             [self showDiscountView:productBuyIndex discountText:strDiscountText bahtPercentIndex:bahtPercentIndex discountReason:customMade.discountReason];
         }]];
                 
                 
         //option3 - ship
         NSString *strShip = customMade.ship?@"Unship":@"Ship";
         [alert addAction:
         [UIAlertAction actionWithTitle:strShip style:UIAlertActionStyleDestructive
         handler:^(UIAlertAction *action)
         {
             customMade.ship = !customMade.ship;
             [tbvPay reloadData];
         }]];
              
              
         //option4 - delete
         [alert addAction:
         [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Delete"] style:UIAlertActionStyleDestructive
         handler:^(UIAlertAction *action)
         {
             UIAlertController* alert2 = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

             [alert2 addAction:
             [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Delete product (No.%ld)",productBuyIndex+1]
                                      style:UIAlertActionStyleDestructive
                                    handler:^(UIAlertAction *action) {
                                        [_productBuyList removeObject:_productBuyList[productBuyIndex]] ;
                                        [tbvPay reloadData];
                                    }]];
             [alert2 addAction:
             [UIAlertAction actionWithTitle:@"Cancel"
                                      style:UIAlertActionStyleCancel
                                    handler:^(UIAlertAction *action) {}]];

             [self presentViewController:alert2 animated:YES completion:nil];
         }]];
                                
         
         [alert addAction:
          [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
         handler:^(UIAlertAction *action) {}]];


         //////////////ipad
         if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
         {
             [alert setModalPresentationStyle:UIModalPresentationPopover];
             
             UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
             CGRect frame = button.imageView.bounds;
             frame.origin.y = frame.origin.y-15;
             popPresenter.sourceView = button.imageView;
             popPresenter.sourceRect = frame;
         }
         ///////////////
         
         
         [self presentViewController:alert animated:YES completion:nil];

    }
 
}

- (void)showDiscountView:(NSInteger)productBuyIndex discountText:(NSString *)discountText bahtPercentIndex:(NSInteger)bahtPercentIndex discountReason:(NSString *)discountReason
{
    _tbvDiscount.tag = productBuyIndex;
    _discountText = discountText;
    _bahtPercentIndex = bahtPercentIndex;
    _discountReason = discountReason;
    
    [_tbvDiscount reloadData];
    
    
    _tbvDiscount.alpha = 0.0;
    [self.view addSubview:_vwDimBackground];
    [self.view addSubview:_tbvDiscount];
    [UIView animateWithDuration:0.2 animations:^{
        _tbvDiscount.alpha = 1.0;
    }];
}

-(void)saveDiscount:(id)sender
{
    //validate discount reason
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        CustomTableViewCellDiscountReason *cell = [_tbvDiscount cellForRowAtIndexPath:indexPath];
        
        
        if([Utility isStringEmpty:cell.txtDiscountReason.text])
        {
            [self alertMessage:@"Please input Discount reason" title:@"Warning"];
            return;
        }
    }
    
    
    
    
    UIButton *button = (UIButton *)sender;
    NSInteger productBuyIndex = button.tag;
    
    CustomMade *customMade = (CustomMade *)_productBuyList[productBuyIndex][productBuyDetail];
    ProductDetail *productDetail = (ProductDetail *)_productBuyList[productBuyIndex][productBuyDetail];
    
    if([self isProductInventoryOrPreOrder:productBuyIndex])
    {
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            CustomTableViewCellDiscount *cell = [_tbvDiscount cellForRowAtIndexPath:indexPath];
                        
                        
            //discount 0=no, 1=baht, 2=percent
            productDetail.discount = cell.segConBahtPercent.selectedSegmentIndex==0?1:2;
            if(cell.segConBahtPercent.selectedSegmentIndex==0)
            {
                productDetail.discountValue = [Utility floatValue: cell.txtDiscount.text];
            }
            else
            {
                productDetail.discountPercent = [Utility floatValue: cell.txtDiscount.text];
            }
        }
        
        
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
            CustomTableViewCellDiscountReason *cell = [_tbvDiscount cellForRowAtIndexPath:indexPath];
            
            
            productDetail.discountReason = [Utility trimString:cell.txtDiscountReason.text];
        }
        
        
        productDetail.replaceProduct = _booReplaceProduct;
    }
    else
    {
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            CustomTableViewCellDiscount *cell = [_tbvDiscount cellForRowAtIndexPath:indexPath];
                        
                        
            //discount 0=no, 1=baht, 2=percent
            customMade.discount = cell.segConBahtPercent.selectedSegmentIndex==0?1:2;
            if(cell.segConBahtPercent.selectedSegmentIndex==0)
            {
                customMade.discountValue = [Utility floatValue: cell.txtDiscount.text];
            }
            else
            {
                customMade.discountPercent = [Utility floatValue: cell.txtDiscount.text];
            }
        }
        
        
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
            CustomTableViewCellDiscountReason *cell = [_tbvDiscount cellForRowAtIndexPath:indexPath];
            
            
            customMade.discountReason = [Utility trimString:cell.txtDiscountReason.text];
        }
        
        customMade.replaceProduct = _booReplaceProduct;
    }
    
//    _lblChanges.text = [NSString stringWithFormat:@"Changes: %@ Baht",[self getStrChanges]];
    _booReplaceProduct = NO;
    [tbvPay reloadData];
    [_tbvDiscount removeFromSuperview];
    [_vwDimBackground removeFromSuperview];
}

-(void)cancelDiscount:(id)sender
{
    [_tbvDiscount removeFromSuperview];
    [_vwDimBackground removeFromSuperview];
}

-(BOOL)isProductInventoryOrPreOrder:(NSInteger)productBuyIndex
{
    return [_productBuyList[productBuyIndex][productType] isEqualToString:[NSString stringWithFormat:@"%d",productInventory]] || [_productBuyList[productBuyIndex][productType] isEqualToString:[NSString stringWithFormat:@"%d",productPreOrder]] || [_productBuyList[productBuyIndex][productType] isEqualToString:[NSString stringWithFormat:@"%d",productPreOrder2]];
}

-(BOOL)isPreOrder2:(NSInteger)productBuyIndex
{
    return [_productBuyList[productBuyIndex][productType] isEqualToString:[NSString stringWithFormat:@"%d",productPreOrder2]];
}

-(PostCustomer *)getPostCustomer:(NSInteger)postCustomerID
{
    NSArray *postBuyList = [SharedPostBuy sharedPostBuy].postBuyList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_postCustomerID = %ld",postCustomerID];
    NSArray *filterArray = [postBuyList filteredArrayUsingPredicate:predicate1];
    
    if([filterArray count]>0)
    {
        return filterArray[0];
    }
    return nil;
}

-(void)postButtonClicked:(id)sender
{
    _selectedProductBuyIndex = -1;
    [self performSegueWithIdentifier:@"segAddEditPostCustomer" sender:self];
}

-(void)postButtonItemClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    _selectedProductBuyIndex = button.tag;
    [self performSegueWithIdentifier:@"segAddEditPostCustomer" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segAddEditPostCustomer"])
    {
        AddEditPostCustomerViewController *vc = segue.destinationViewController;
        vc.paid = NO;
        if(_selectedProductBuyIndex == -1)
        {
            vc.telephoneNoSearch = [Utility removeDashAndSpaceAndParenthesis:_telephoneNoInput];
        }
        else
        {
            CustomMade *customMade = (CustomMade *)_productBuyList[_selectedProductBuyIndex][productBuyDetail];
            ProductDetail *productDetail = (ProductDetail *)_productBuyList[_selectedProductBuyIndex][productBuyDetail];
            if([self isProductInventoryOrPreOrder:_selectedProductBuyIndex])
            {
                if(productDetail.postCustomerID != 0)
                {
                    PostCustomer *postCustomer = [self getPostCustomer:productDetail.postCustomerID];
                    vc.telephoneNoSearch = postCustomer.telephone;
                }
                else
                {
                    vc.telephoneNoSearch = @"";
                }
            }
            else
            {
                if(productDetail.postCustomerID != 0)
                {
                    PostCustomer *postCustomer = [self getPostCustomer:customMade.postCustomerID];
                    vc.telephoneNoSearch = postCustomer.telephone;
                }
                else
                {
                    vc.telephoneNoSearch = @"";
                }
            }
        }
        vc.productBuyIndex = _selectedProductBuyIndex;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if([textField isEqual:_txtDiscountReason])
    {
        for(int i=0; i<[_productBuyList count]; i++)
        {
            CustomMade *customMade = (CustomMade *)_productBuyList[i][productBuyDetail];
            ProductDetail *productDetail = (ProductDetail *)_productBuyList[i][productBuyDetail];
            if([self isProductInventoryOrPreOrder:i])
            {
                productDetail.discountReason = [Utility trimString:_txtDiscountReason.text];
            }
            else
            {
                customMade.discountReason = [Utility trimString:_txtDiscountReason.text];
            }
        }
    }
    else if(textField.tag == 20)//telephoneNo
    {
        _telephoneNoInput = textField.text;
        if([Utility isStringEmpty:_telephoneNoInput])
        {
            [_wordPressUserList removeAllObjects];
            _redeemPoints = @"";
            [self removePostCustomer];
            [tbvPay reloadData];
        }
        else
        {
            [self searchPostCustomerAndReward];
        }
    }
    else if(textField.tag == 30)//wordPress email
    {
        _wordPressEmail = textField.text;
    }
    else if(textField.tag == 40)//wordPress phone
    {
        _wordPressPhone = textField.text;
    }
    else if(textField.tag == 50)//redeem points
    {
        _redeemPoints = textField.text;
    }
}

-(void)searchPostCustomerAndReward
{
    HomeModel *homeModel = [[HomeModel alloc]init];
    homeModel.delegate = self;
    [homeModel downloadItems:dbPostCustomerSearch condition:[Utility removeDashAndSpaceAndParenthesis:_telephoneNoInput]];
}

- (void)payButtonClicked:(id)sender
{
    if(![self validateData])
    {
        return;
    }
    NSMutableArray *data = [[NSMutableArray alloc]init];
    NSInteger receiptID = [Utility getNextID:tblReceipt];
    ReceiptProductItem *replaceReceiptProductItem = [SharedReplaceReceiptProductItem sharedReplaceReceiptProductItem].replaceReceiptProductItem;
    
    
    //update product inventory
    NSMutableArray *arrProduct = [[NSMutableArray alloc]init];
    NSMutableArray *arrCustomMade = [[NSMutableArray alloc]init];
    NSMutableArray *arrReceiptProductItem = [[NSMutableArray alloc]init];
    NSMutableArray *arrPreOrderEventIDHistory = [[NSMutableArray alloc]init];
    //insert itemTrackingNoList
    NSMutableArray *arrItemTrackingNo = [[NSMutableArray alloc]init];
    NSMutableArray *arrPreOrder2 = [[NSMutableArray alloc]init];
    
    for(int i=0; i<[_productBuyList count]; i++)
    {
        if([_productBuyList[i][productType] intValue] == productInventory)
        {
            ProductDetail *productDetail = (ProductDetail*)_productBuyList[i][productBuyDetail];
//            Product *product = [Product getProduct:productDetail.productID];
            Product *product = [[Product alloc]init];
            product.productID = productDetail.productID;
            product.status = @"S"; //update shared in the same time
            product.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
            product.modifiedUser = [Utility modifiedUser];
            [arrProduct addObject:product];
            
            
            //insert receiptproductitem
            NSInteger receiptProductItemID = [Utility getNextID:tblReceiptProductItem];
            ReceiptProductItem *receiptProductItem = [[ReceiptProductItem alloc]init];
            receiptProductItem.receiptProductItemID = receiptProductItemID;
            receiptProductItem.receiptID = receiptID;
            receiptProductItem.productType = @"I";
            receiptProductItem.preOrderEventID = 0;
            receiptProductItem.productID = product.productID;
            receiptProductItem.priceSales = productDetail.pricePromotion;
            receiptProductItem.customMadeIn = @"0";
            receiptProductItem.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
            receiptProductItem.modifiedUser = [Utility modifiedUser];
            
            receiptProductItem.ship = productDetail.ship;
            receiptProductItem.shippingFee = productDetail.ship?[Utility floatValue:[Utility setting:vShippingFee]]:0;
            receiptProductItem.replaceProduct = productDetail.replaceProduct;
            receiptProductItem.discount = productDetail.discount;
            receiptProductItem.discountValue = productDetail.discountValue;
            receiptProductItem.discountPercent = productDetail.discountPercent;
            receiptProductItem.discountReason = productDetail.discountReason;
            receiptProductItem.replaceReceiptProductItemID = replaceReceiptProductItem.receiptProductItemID;
            [ReceiptProductItem addObject:receiptProductItem];
            [arrReceiptProductItem addObject:receiptProductItem];
            
            
            //insert itemTrackingNo
            ItemTrackingNo *itemTrackingNo = [[ItemTrackingNo alloc]init];
            itemTrackingNo.receiptProductItemID = receiptProductItem.receiptProductItemID;
            itemTrackingNo.postCustomerID = productDetail.postCustomerID;
            [arrItemTrackingNo addObject:itemTrackingNo];
        }
    }
    
    
    //update product preOrder
    for(int i=0; i<[_productBuyList count]; i++)
    {
        if([_productBuyList[i][productType] intValue] == productPreOrder)
        {
            ProductDetail *productDetail = (ProductDetail*)_productBuyList[i][productBuyDetail];
//            Product *product = [Product getProduct:productDetail.productID];
            Product *product = [[Product alloc]init];
            product.productID = productDetail.productID;
            product.status = @"P"; //update shared in the same time
            product.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
            product.modifiedUser = [Utility modifiedUser];
            [arrProduct addObject:product];
            
            
            NSInteger receiptProductItemID = [Utility getNextID:tblReceiptProductItem];
            ReceiptProductItem *receiptProductItem = [[ReceiptProductItem alloc]init];
            receiptProductItem.receiptProductItemID = receiptProductItemID;
            receiptProductItem.receiptID = receiptID;
            receiptProductItem.productType = @"P";
            receiptProductItem.preOrderEventID = product.eventID;
            receiptProductItem.productID = product.productID;
            receiptProductItem.priceSales = productDetail.pricePromotion;
            receiptProductItem.customMadeIn = @"0";
            receiptProductItem.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
            receiptProductItem.modifiedUser = [Utility modifiedUser];
            
            receiptProductItem.ship = productDetail.ship;
            receiptProductItem.shippingFee = productDetail.ship?[Utility floatValue:[Utility setting:vShippingFee]]:0;
            receiptProductItem.replaceProduct = productDetail.replaceProduct;
            receiptProductItem.discount = productDetail.discount;
            receiptProductItem.discountValue = productDetail.discountValue;
            receiptProductItem.discountPercent = productDetail.discountPercent;
            receiptProductItem.discountReason = productDetail.discountReason;
            receiptProductItem.replaceReceiptProductItemID = replaceReceiptProductItem.receiptProductItemID;
            
            //replaceReceiptProductItemID
            ReceiptProductItem *replaceReceiptProductItem = [SharedReplaceReceiptProductItem sharedReplaceReceiptProductItem].replaceReceiptProductItem;
            if(replaceReceiptProductItem.receiptProductItemID > 0)
            {
                receiptProductItem.replaceReceiptProductItemID = replaceReceiptProductItem.receiptProductItemID;
            }
            
            [ReceiptProductItem addObject:receiptProductItem];
            [arrReceiptProductItem addObject:receiptProductItem];
            
            
            //insert itemTrackingNo
            ItemTrackingNo *itemTrackingNo = [[ItemTrackingNo alloc]init];
            itemTrackingNo.receiptProductItemID = receiptProductItem.receiptProductItemID;
            itemTrackingNo.postCustomerID = productDetail.postCustomerID;
            [arrItemTrackingNo addObject:itemTrackingNo];
        }
    }
    
    
    //update product preOrder2
    for(int i=0; i<[_productBuyList count]; i++)
    {
        if([_productBuyList[i][productType] intValue] == productPreOrder2)
        {
            ProductDetail *productDetail = (ProductDetail*)_productBuyList[i][productBuyDetail];
            
            NSInteger receiptProductItemID = [Utility getNextID:tblReceiptProductItem];
            ReceiptProductItem *receiptProductItem = [[ReceiptProductItem alloc]init];
            receiptProductItem.receiptProductItemID = receiptProductItemID;
            receiptProductItem.receiptID = receiptID;
            receiptProductItem.productType = @"C";//@"P";
            receiptProductItem.preOrderEventID = 0;//product.eventID;
            receiptProductItem.productID = 0;//product.productID;
            receiptProductItem.priceSales = productDetail.pricePromotion;
            receiptProductItem.customMadeIn = @"0";
            receiptProductItem.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
            receiptProductItem.modifiedUser = [Utility modifiedUser];
            
            receiptProductItem.ship = productDetail.ship;
            receiptProductItem.shippingFee = productDetail.ship?[Utility floatValue:[Utility setting:vShippingFee]]:0;
            receiptProductItem.replaceProduct = productDetail.replaceProduct;
            receiptProductItem.discount = productDetail.discount;
            receiptProductItem.discountValue = productDetail.discountValue;
            receiptProductItem.discountPercent = productDetail.discountPercent;
            receiptProductItem.discountReason = productDetail.discountReason;
            receiptProductItem.replaceReceiptProductItemID = replaceReceiptProductItem.receiptProductItemID;
            [ReceiptProductItem addObject:receiptProductItem];
            [arrReceiptProductItem addObject:receiptProductItem];
            
            
            //insert itemTrackingNo
            ItemTrackingNo *itemTrackingNo = [[ItemTrackingNo alloc]init];
            itemTrackingNo.receiptProductItemID = receiptProductItem.receiptProductItemID;
            itemTrackingNo.postCustomerID = productDetail.postCustomerID;
            [arrItemTrackingNo addObject:itemTrackingNo];
            
            
            //preOrder2
            NSString *productIDGroup = (NSString*)_productBuyList[i][eProductIDGroup];
            NSRange needleRange = NSMakeRange(0,6);
            NSString *productNameGroup = [productIDGroup substringWithRange:needleRange];
            
            needleRange = NSMakeRange(6,2);
            NSString *strColor = [productIDGroup substringWithRange:needleRange];
            
            needleRange = NSMakeRange(8,2);
            NSString *strSize = [productIDGroup substringWithRange:needleRange];
            
            ProductName *productName = [ProductName getProductNameWithProductNameGroup:productNameGroup];
            PreOrder2 *preOrder2 = [[PreOrder2 alloc]init];
            preOrder2.receiptProductItemID = receiptProductItemID;
            preOrder2.productNameID = productName.productNameID;
            preOrder2.color = strColor;
            preOrder2.size = strSize;
            [arrPreOrder2 addObject:preOrder2];
        }
    }
    
    
    //insert custom made
    for(int i=0; i<[_productBuyList count]; i++)
    {
        if([_productBuyList[i][productType] intValue] == productCustomMade)
        {
            CustomMade *customMade = ((CustomMade*)_productBuyList[i][productBuyDetail]);
            customMade.customMadeID = [Utility getNextID:tblCustomMade];
            customMade.productIDPost = @"";
            customMade.modifiedUser = [Utility modifiedUser];
            [arrCustomMade addObject:customMade];
            
            
            NSInteger receiptProductItemID = [Utility getNextID:tblReceiptProductItem];
            ReceiptProductItem *receiptProductItem = [[ReceiptProductItem alloc]init];
            receiptProductItem.receiptProductItemID = receiptProductItemID;
            receiptProductItem.receiptID = receiptID;
            receiptProductItem.productType = @"C";
            receiptProductItem.preOrderEventID = 0;
            receiptProductItem.productID = [NSString stringWithFormat:@"%ld",(long)customMade.customMadeID];
            receiptProductItem.priceSales = _productBuyList[i][productBuyPricePromotion];
            receiptProductItem.customMadeIn = @"0";
            receiptProductItem.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
            receiptProductItem.modifiedUser = [Utility modifiedUser];
            
            receiptProductItem.ship = customMade.ship;
            receiptProductItem.shippingFee = customMade.ship?[Utility floatValue:[Utility setting:vShippingFee]]:0;
            receiptProductItem.replaceProduct = customMade.replaceProduct;
            receiptProductItem.discount = customMade.discount;
            receiptProductItem.discountValue = customMade.discountValue;
            receiptProductItem.discountPercent = customMade.discountPercent;
            receiptProductItem.discountReason = customMade.discountReason;
            receiptProductItem.replaceReceiptProductItemID = replaceReceiptProductItem.receiptProductItemID;
            [ReceiptProductItem addObject:receiptProductItem];
            [arrReceiptProductItem addObject:receiptProductItem];
            
            
            //insert itemTrackingNo
            ItemTrackingNo *itemTrackingNo = [[ItemTrackingNo alloc]init];
            itemTrackingNo.receiptProductItemID = receiptProductItem.receiptProductItemID;
            itemTrackingNo.postCustomerID = customMade.postCustomerID;
            [arrItemTrackingNo addObject:itemTrackingNo];
        }
    }
    
    
    for(ReceiptProductItem *item in arrReceiptProductItem)
    {
        if([item.productType isEqualToString:@"P"])
        {
            PreOrderEventIDHistory *preOrderEventIDHistory = [[PreOrderEventIDHistory alloc] initWithReceiptProductItemID:item.receiptProductItemID preOrderEventID:item.preOrderEventID];
            [PreOrderEventIDHistory addObject:preOrderEventIDHistory];
            [arrPreOrderEventIDHistory addObject:preOrderEventIDHistory];
        }
    }
    
    
    {
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_productID" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
        NSArray *sortArray = [arrProduct sortedArrayUsingDescriptors:sortDescriptors];
        arrProduct = [sortArray mutableCopy];
    }
    
    [data addObject:arrProduct];
    [data addObject:arrCustomMade];
    [data addObject:arrReceiptProductItem];
    [data addObject:arrPreOrderEventIDHistory];
    
    
    
    //insert receipt
    
    
    NSString *strEventID;
    if(replaceReceiptProductItem.receiptProductItemID > 0)
    {
        strEventID = replaceReceiptProductItem.eventID;
    }
    else
    {
        strEventID = [NSString stringWithFormat:@"%ld",(long)[SharedSelectedEvent sharedSelectedEvent].event.eventID];
    }
    Receipt *receipt = [[Receipt alloc]init];
    receipt.receiptID = receiptID;
    receipt.eventID = strEventID;
    receipt.channel = _segConChannel.selectedSegmentIndex;//[self getChannel];
    receipt.referenceOrderNo = [Utility trimString:_txtReferenceOrderNo.text];
    receipt.payPrice = [Utility removeComma:[self getStrFmtAfterDiscountValue]];
    receipt.paymentMethod = @"";//[_txtCreditAmount.text isEqualToString:@""]?@"CA":[_txtCashReceive.text isEqualToString:@""]?@"CC":@"BO";
    receipt.creditAmount = [self getStrCreditAmount];
    receipt.cashAmount = [self getStrCashAmount];
    receipt.transferAmount = [self getStrTransferAmount];
    receipt.cashReceive = [self getStrCashReceive];
    receipt.remark = [Utility trimString:_txtSalesRemark.text];
    receipt.shippingFee = [self getStrShippingFee];
    receipt.discount = [self getDiscountValue] > 0?@"1":@"0";
    receipt.discountValue = [NSString stringWithFormat:@"%f",[self getDiscountValue]];
//    receipt.discountPercent = _segConBahtPercent.selectedSegmentIndex==percent?_strDiscountValuePercent:@"0";
//    receipt.discountReason = [Utility trimString:_txtDiscountReason.text];
    receipt.redeemedValue = [self getRedeemedValue];
    receipt.receiptDate = [Utility dateToString:[Utility GMTDate:[NSDate date]] toFormat:@"yyyy-MM-dd HH:mm:ss"];
    receipt.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
    receipt.modifiedUser = [Utility modifiedUser];
    receipt.salesUser = [self getSalesUser];
    if([_wordPressUserList count] > 0)
    {
        WordPressUser *wordPressUser = _wordPressUserList[0];
        receipt.wordPressUserID = wordPressUser.iD;
        receipt.redeemPoints = [_redeemPoints integerValue];
    }
    
    [data addObject:receipt];
    
    
    
    //insert rewardpoint
    //จะ add reward ถ้ามี sharedpostbuy หรือ กรอกเบอร์โทร
    BOOL addReward = NO;
    if([[SharedPostBuy sharedPostBuy].postBuyList count]>0)
    {
        addReward = YES;
    }
    else if(![[Utility removeDashAndSpaceAndParenthesis:_telephoneNoInput] isEqualToString:@""])
    {
        //add postcustomer
        PostCustomer *postCustomer = [[PostCustomer alloc]init];
        postCustomer.postCustomerID = 0;
        postCustomer.customerID = 0;
        [[SharedPostBuy sharedPostBuy].postBuyList removeAllObjects];
        [[SharedPostBuy sharedPostBuy].postBuyList addObject:postCustomer];
        addReward = YES;
    }
    
    
    NSMutableArray *rewardPointList = [[NSMutableArray alloc]init];
    if(addReward)
    {

    }
    [data addObject:rewardPointList];
    
    
    
    
    //insert post customer
    NSMutableArray *arrPostCustomer = [[NSMutableArray alloc]init];
    NSMutableArray *postBuyList = [SharedPostBuy sharedPostBuy].postBuyList;
    [arrPostCustomer addObjectsFromArray:postBuyList];
    [data addObject:arrPostCustomer];
    

    
    
    [data addObject:arrItemTrackingNo];
    [data addObject:arrPreOrder2];
    
    
    [self loadingOverlayView];
    [self.homeModel insertItems:dbReceiptAndProductBuyInsert withData:data];
}

-(void)itemsInsertedWithReturnData:(NSArray *)data
{
    [self removeOverlayViews];
    
    if(self.homeModel.propCurrentDB == dbWordPressRegister)
    {
        NSArray *wordPressUserList = data[0];
        if([wordPressUserList count] > 0)
        {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                       message:@"Register successful" preferredStyle:UIAlertControllerStyleAlert];
        
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                handler:^(UIAlertAction * action)
                {
                    [_tbvWordPressRegister removeFromSuperview];
                    [_vwDimBackground removeFromSuperview];
                }];
                
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    else if(self.homeModel.propCurrentDB == dbReceiptAndProductBuyInsert)
    {
        NSMutableArray *messageList = data[0];
        InAppMessage *message = messageList[0];
        if([Utility isStringEmpty: message.message])
        {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                   message:@"Paid successful"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      [self performSegueWithIdentifier:@"segUnwindToUserMenu" sender:self];
                                                                  }];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            [self alertMessage:message.message title:@"Warning"];
        }
    }
}


-(BOOL)validateData
{
    if([self getChanges] < 0)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                       message:@"Pay amount is not enough" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action){}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
    }
    
    NSString *strDiscountReason = [Utility trimString:_txtDiscountReason.text];
    if(![_txtDiscountValuePercent.text isEqualToString:@""] && [strDiscountReason isEqualToString:@""])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                       message:@"Please input discount reason" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action){}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
    }
    
    return YES;
}

- (NSString *)getStrCreditAmount
{
    if([[Utility trimString:_txtCreditAmount.text] isEqualToString:@""])
    {
        return @"0";
    }
    else
    {
        return [Utility removeComma:_txtCreditAmount.text];
    }
}

- (NSString *)getStrCashReceive
{
    if([[Utility trimString:_txtCashReceive.text] isEqualToString:@""])
    {
        return @"0";
    }
    else
    {
        return [Utility removeComma:_txtCashReceive.text];
    }
}

- (NSString *)getStrTransferAmount
{
    if([[Utility trimString:_txtTransferAmount.text] isEqualToString:@""])
    {
        return @"0";
    }
    else
    {
        return [Utility removeComma:_txtTransferAmount.text];
    }
}

- (NSString *)getStrCashAmount
{
    float cashAmount = [self getAfterDiscountValue]-[self getCredit]-[self getTransfer];
    NSString *strCashAmount = [_formatter stringFromNumber:[NSNumber numberWithFloat:cashAmount]];
    
    return [Utility removeComma:strCashAmount];
}

//-(NSInteger)getChannel
//{
//    NSInteger channel = _segConChannel.selectedSegmentIndex;
//    if(channel >= 5 && channel <= 8)
//    {
//        channel += 1;
//    }
//    else if(channel == 9)
//    {
//        channel = 5;
//    }
//    return channel;
//}

-(void)registerWordPressUser:(id)sender
{
    _wordPressEmail = @"";
    _wordPressPhone = @"";
    [_tbvWordPressRegister reloadData];
    
    
    _tbvWordPressRegister.alpha = 0.0;
    [self.view addSubview:_vwDimBackground];
    [self.view addSubview:_tbvWordPressRegister];
    [UIView animateWithDuration:0.2 animations:^{
        _tbvWordPressRegister.alpha = 1.0;
    }];
}

-(void)saveWordPressRegister:(id)sender
{    
    WordPressUser *wordPressUser = [[WordPressUser alloc]init];
    wordPressUser.user_email = [Utility trimString:_wordPressEmail];
    wordPressUser.phone = [Utility removeDashAndSpaceAndParenthesis:_wordPressPhone];

    [self loadingOverlayView];
    [self.homeModel insertItems:dbWordPressRegister withData:wordPressUser];
}

-(void)cancelWordPressRegister:(id)sender
{
    [_tbvWordPressRegister removeFromSuperview];
    [_vwDimBackground removeFromSuperview];
}

-(void)redeemPoints:(id)sender
{
    _redeemPointsCache = _redeemPoints;
    [_tbvRedeem reloadData];
    
    
    _tbvRedeem.alpha = 0.0;
    [self.view addSubview:_vwDimBackground];
    [self.view addSubview:_tbvRedeem];
    [UIView animateWithDuration:0.2 animations:^{
        _tbvRedeem.alpha = 1.0;
    }];
}

-(void)saveRedeem:(id)sender
{
    //validate
    if([Utility isStringEmpty:_redeemPoints])
    {
        [self cancelRedeem:nil];
        return;
    }
    
    WordPressUser *wordPressUser = _wordPressUserList[0];
    if([_redeemPoints integerValue] < wordPressUser.minimumPointSpend)
    {
        NSString *message = [NSString stringWithFormat:@"Please enter points more than %ld",wordPressUser.minimumPointSpend];
        [self alertMessage:message title:@"Warning"];
        return;
    }
    
    if([_redeemPoints integerValue] > wordPressUser.totalPoints)
    {
        [self alertMessage:@"You don't have enough points" title:@"Warning"];
        return;
    }
    
    
    [tbvPay reloadData];
    [_tbvRedeem removeFromSuperview];
    [_vwDimBackground removeFromSuperview];
}

-(void)cancelRedeem:(id)sender
{
    _redeemPoints = _redeemPointsCache;
    [_tbvRedeem removeFromSuperview];
    [_vwDimBackground removeFromSuperview];
}

-(void)removeRedeemedValue:(id)sender
{
    _redeemPoints = @"";
    [tbvPay reloadData];
}
- (IBAction)backButtonClicked:(id)sender
{
    if([SharedReplaceReceiptProductItem sharedReplaceReceiptProductItem].replaceReceiptProductItem.receiptProductItemID > 0)
    {
        [self performSegueWithIdentifier:@"segUnwindToSearchReceipt" sender:self];
    }
    else
    {
        [self performSegueWithIdentifier:@"segUnwindToProductDetail" sender:self];
    }
}
@end
