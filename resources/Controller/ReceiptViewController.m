//
//  ReceiptViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 9/28/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "ReceiptViewController.h"
#import "Utility.h"
#import "CustomUICollectionViewCellButton3.h"
#import "SharedSelectedEvent.h"
#import "AddEditPostCustomerViewController.h"
#import "CustomMade.h"
#import "SharedProductBuy.h"
#import "ProductDetail.h"
#import "Receipt.h"
#import "ReceiptProductItem.h"
#import "UserMenuViewController.h"
#import "CustomerReceipt.h"
#import "PostCustomer.h"
#import "SharedPostBuy.h"
#import "SharedProduct.h"
#import "SharedCashAllocation.h"
#import "SharedCustomMade.h"
#import "SharedReceipt.h"
#import "SharedReceiptItem.h"
#import "SharedCustomerReceipt.h"
#import "SharedPostCustomer.h"
#import "SharedPushSync.h"
#import "PushSync.h"
#import "RewardPoint.h"
#import "RewardProgram.h"
#import "SharedRewardPoint.h"
#import "PreOrderEventIDHistory.h"
#import "SignInViewController.h"
#import "ProductName.h"


/* Macro for background colors */
#define orangeColor         [UIColor colorWithRed:253/255.0 green:182/255.0 blue:103/255.0 alpha:1]
#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]
#define tYellow          [UIColor colorWithRed:251/255.0 green:188/255.0 blue:5/255.0 alpha:1]
#define tTheme          [UIColor colorWithRed:196/255.0 green:164/255.0 blue:168/255.0 alpha:1]

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



@interface ReceiptViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
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
    UITextField *_txtTelephoneNo;
    UIButton *_btnPost;
    
    
    NSNumberFormatter *_formatter;
    NSMutableArray *_selectedProductBuy;
    Event *_event;
    NSString *_strDiscount;
    NSString *_strDiscountValuePercent;
    UICollectionReusableView *_footerview;
    
    RewardProgram *_rewardProgramCollect;
    RewardProgram *_rewardProgramUse;
    NSInteger _time;
    NSInteger _pointSpentActual;
 
    NSArray *_salesUserList;
}
@end

@implementation ReceiptViewController
static NSString * const reuseIdentifier = @"Cell";
static NSString * const reuseHeaderViewIdentifier = @"HeaderView";
static NSString * const reuseFooterViewIdentifier = @"FooterView";
@synthesize colViewSummaryTable;


- (IBAction)unwindToReceipt:(UIStoryboardSegue *)segue
{
    AddEditPostCustomerViewController *source = [segue sourceViewController];

    if([[SharedPostBuy sharedPostBuy].postBuyList count] == 0)
    {
        [_btnPost setImage:[UIImage imageNamed:@"postCustomerNo.png"] forState:UIControlStateNormal];
    }
    else
    {
        [_btnPost setImage:[UIImage imageNamed:@"postCustomer.png"] forState:UIControlStateNormal];
        _txtTelephoneNo.text = [Utility insertDash:source.telephoneNoSearch];
        
        
        NSInteger countColumn = 7;
        {
            NSInteger memberCodeIndexPathItem = ([_productBuyList count]+1)*countColumn+8+1-1;
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:memberCodeIndexPathItem inSection:0];
            CustomUICollectionViewCellButton3 *cell = (CustomUICollectionViewCellButton3*)[colViewSummaryTable cellForItemAtIndexPath:indexPath];
            
            
            PostCustomer *postCustomer = [SharedPostBuy sharedPostBuy].postBuyList[0];
            cell.label.text = [NSString stringWithFormat:@"Member code: %@",postCustomer.telephone];
        }
        
        {
            NSInteger rewardPointIndexPathItem = ([_productBuyList count]+1)*countColumn+8+3-1;
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:rewardPointIndexPathItem inSection:0];
            CustomUICollectionViewCellButton3 *cell = (CustomUICollectionViewCellButton3*)[colViewSummaryTable cellForItemAtIndexPath:indexPath];
            
            
            NSInteger rewardPoint = [self getRewardPoint];
            if(rewardPoint == 0)
            {
                cell.label.text = @"-";
            }
            else
            {
                NSString *strRewardPoint = [NSString stringWithFormat:@"%ld",(long)rewardPoint];
                strRewardPoint = [Utility formatBaht:strRewardPoint withMinFraction:0 andMaxFraction:2];
                cell.label.text = strRewardPoint;
            }
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
    // Register cell classes
    [colViewSummaryTable registerClass:[CustomUICollectionViewCellButton3 class] forCellWithReuseIdentifier:reuseIdentifier];
    [colViewSummaryTable registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeaderViewIdentifier];
    
    colViewSummaryTable.delegate = self;
    colViewSummaryTable.dataSource = self;
    
    
    UITableView *tbvPay = (UITableView *)[_footerview viewWithTag:19];
    tbvPay.delegate = self;
    tbvPay.dataSource = self;
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
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

    
    _event = [Event getSelectedEvent];
    colViewSummaryTable.backgroundColor = [UIColor whiteColor];
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
        float channelWidth = self.view.frame.size.width-2*40;
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
        
        
        _txtTelephoneNo = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth-40, controlHeight)];
        _txtTelephoneNo.placeholder = @"Mobile phone no.";
        _txtTelephoneNo.clearButtonMode = UITextFieldViewModeWhileEditing;
        _txtTelephoneNo.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
        [_txtTelephoneNo  setFont: [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:14]];
        [_txtTelephoneNo addTarget:self action:@selector(txtTelephoneNoDidChange:) forControlEvents:UIControlEventEditingChanged];
        _txtTelephoneNo.delegate = self;
        if([[SharedPostBuy sharedPostBuy].postBuyList count] == 0)
        {
            _txtTelephoneNo.text = @"";
        }
        else
        {
            PostCustomer *postCustomer = [SharedPostBuy sharedPostBuy].postBuyList[0];
            _txtTelephoneNo.text = [Utility insertDash:postCustomer.telephone];
        }
        
        
        _btnPost = [[UIButton alloc]initWithFrame:CGRectMake(postXOrigin, postYOrigin, postWidth, postHeight)];
        _btnPost.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_btnPost addTarget:self action:@selector(postButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        if([[SharedPostBuy sharedPostBuy].postBuyList count] == 0)
        {
            [_btnPost setImage:[UIImage imageNamed:@"postCustomerNo.png"] forState:UIControlStateNormal];
        }
        else
        {
            [_btnPost setImage:[UIImage imageNamed:@"postCustomer.png"] forState:UIControlStateNormal];
        }
        
        
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
        _lblChanges.text = [NSString stringWithFormat:@"Changes: %@ Baht",[self getStrChanges]];
        
        
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
    
    [self loadViewProcess];
}

- (void)loadViewProcess
{
}

-(BOOL)isMember
{
    PostCustomer *postCustomer = [PostCustomer getPostCustomerWithPhoneNo:[self getMemberCode]];
    if(postCustomer)
    {
        return YES;
    }
    return  NO;
}

-(void)txtTelephoneNoDidChange :(UITextField *)textField
{
    //update membercode, reward point
    NSInteger countColumn = 7;
    
    {
        NSInteger memberCodeIndexPathItem = ([_productBuyList count]+1)*countColumn+8+1-1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:memberCodeIndexPathItem inSection:0];
        CustomUICollectionViewCellButton3 *cell = (CustomUICollectionViewCellButton3*)[colViewSummaryTable cellForItemAtIndexPath:indexPath];
        
        
        if([self isMember])
        {
            NSString *memberCode = [self getMemberCode];
            PostCustomer *postCustomer = [PostCustomer getPostCustomerWithPhoneNo:memberCode];
            [[SharedPostBuy sharedPostBuy].postBuyList removeAllObjects];
            [[SharedPostBuy sharedPostBuy].postBuyList addObject:postCustomer];
            [_btnPost setImage:[UIImage imageNamed:@"postCustomer.png"] forState:UIControlStateNormal];
            
            
            cell.label.text = [NSString stringWithFormat:@"Member code: %@",memberCode];
        }
        else
        {
            [[SharedPostBuy sharedPostBuy].postBuyList removeAllObjects];
            [_btnPost setImage:[UIImage imageNamed:@"postCustomerNo.png"] forState:UIControlStateNormal];
            
            
            cell.label.text = @"Member code: -";
        }
    }
    
    {
        NSInteger rewardPointIndexPathItem = ([_productBuyList count]+1)*countColumn+8+3-1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:rewardPointIndexPathItem inSection:0];
        CustomUICollectionViewCellButton3 *cell = (CustomUICollectionViewCellButton3*)[colViewSummaryTable cellForItemAtIndexPath:indexPath];
        
        
        NSInteger rewardPoint = [self getRewardPoint];
        if(rewardPoint == 0)
        {
            cell.label.text = @"-";
        }
        else
        {
            NSString *strRewardPoint = [NSString stringWithFormat:@"%ld",(long)rewardPoint];
            strRewardPoint = [Utility formatBaht:strRewardPoint withMinFraction:0 andMaxFraction:2];            
            cell.label.text = strRewardPoint;
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
    float discountValue;
    if([_strDiscount integerValue] == 1)
    {
        if([_strDiscountValuePercent isEqualToString:@""])
        {
            discountValue = 0;
        }
        else
        {
            discountValue = [_strDiscountValuePercent floatValue];
        }
    }
    else if([_strDiscount integerValue] == 2)
    {
        if([_strDiscountValuePercent isEqualToString:@""])
        {
            discountValue = 0;
        }
        else
        {
            discountValue = [_strDiscountValuePercent floatValue]*[self getTotalAmount]/100;
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
    NSInteger shippingFee = _segConShip.selectedSegmentIndex==0?[[Utility setting:vShippingFee] integerValue]*[_productBuyList count]:0;
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
    
    [self updateCalculateParts];
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
    return [self getTotalAmount]+[self getShippingFee]-[self getDiscountValue];
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

-(void)txtDiscountValuePercentDidChange :(UITextField *)textField{
    _strDiscountValuePercent = [Utility removeComma:[Utility trimString:textField.text]];
    

    [self updateCalculateParts];
    
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
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    NSInteger itemNo = 0;
    NSInteger countColumn = 7;
    if([_productBuyList count] != 0)
    {
        itemNo =([_productBuyList count]+1)*countColumn+8+3;//เพิ่ม shipping fee 2 cells
    }
    return itemNo;
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

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CustomUICollectionViewCellButton3 *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    NSInteger item = indexPath.item;
    NSArray *productBuyHeader = @[@"DEL",@"No.",@"Picture",@"Item",@"Color",@"Size",@"Baht"];
    NSInteger countColumn = [productBuyHeader count];
    
    
    if ([cell.label isDescendantOfView:cell]) {
        [cell.label removeFromSuperview];
    }
    if ([cell.buttonAdd isDescendantOfView:cell]) {
        [cell.buttonAdd removeFromSuperview];
    }
    if ([cell.buttonInfo isDescendantOfView:cell]) {
        [cell.buttonInfo removeFromSuperview];
    }
    if ([cell.buttonDetail isDescendantOfView:cell]) {
        [cell.buttonDetail removeFromSuperview];
    }
    if ([cell.buttonDetail2 isDescendantOfView:cell]) {
        [cell.buttonDetail2 removeFromSuperview];
    }
    if ([cell.imageView isDescendantOfView:cell]) {
        [cell.imageView removeFromSuperview];
    }
    if ([cell.imageView2 isDescendantOfView:cell]) {
        [cell.imageView2 removeFromSuperview];
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
        [cell addSubview:cell.leftBorder];
        [cell addSubview:cell.topBorder];
        [cell addSubview:cell.rightBorder];
        [cell addSubview:cell.bottomBorder];
    }
    
    
    if(item/countColumn==0)
    {
        [cell addSubview:cell.label];
        cell.label.frame = cell.bounds;
        cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
        cell.label.textColor= [UIColor whiteColor];
        cell.label.backgroundColor = tBlueColor;
        cell.label.textAlignment = NSTextAlignmentCenter;
    }
    else if(item/countColumn==[_productBuyList count]+1 && (item%countColumn == 0 || item%countColumn == 1 || item%countColumn == 2 || item%countColumn == 3 || item%countColumn == 4 || item%countColumn == 5))
    {
        [cell addSubview:cell.label];
        cell.label.frame = cell.bounds;
        cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
        cell.label.textColor= [UIColor blackColor];
        cell.label.backgroundColor = [UIColor clearColor];
        cell.label.textAlignment = NSTextAlignmentRight;
    }
    else if(
        ((item/countColumn==[_productBuyList count]+1) && (item%countColumn == 6)) ||
        ((item/countColumn==[_productBuyList count]+2) && (item%countColumn == 0)) )
    {
        [cell addSubview:cell.label];
        cell.label.frame = cell.bounds;
        cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
        cell.label.textColor= [UIColor blackColor];
        cell.label.backgroundColor = [UIColor clearColor];
        cell.label.textAlignment = NSTextAlignmentRight;
    }
    else if(item/countColumn==[_productBuyList count]+2 && (item%countColumn == 1))
    {
        [cell addSubview:cell.label];
        cell.label.frame = cell.bounds;
        cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
        cell.label.textColor= [UIColor blackColor];
        cell.label.backgroundColor = [UIColor clearColor];
        cell.label.textAlignment = NSTextAlignmentLeft;
    }
    else if(item/countColumn==[_productBuyList count]+2 && (item%countColumn == 2 || item%countColumn == 3))
    {
        [cell addSubview:cell.label];
        cell.label.frame = cell.bounds;
        cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
        cell.label.textColor= [UIColor blackColor];
        cell.label.backgroundColor = [UIColor clearColor];
        cell.label.textAlignment = NSTextAlignmentRight;
    }
    else if(item%countColumn == 1 || item%countColumn == 3 || item%countColumn == 4 || item%countColumn == 5)
    {
        [cell addSubview:cell.label];
        cell.label.frame = cell.bounds;
        cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
        cell.label.textColor= [UIColor blackColor];
        cell.label.backgroundColor = [UIColor clearColor];
        cell.label.textAlignment = NSTextAlignmentCenter;
    }
    else if(item%countColumn == 6)
    {
        [cell addSubview:cell.label];
        cell.label.frame = cell.bounds;
        cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
        cell.label.textColor= [UIColor blackColor];
        cell.label.backgroundColor = [UIColor clearColor];
        cell.label.textAlignment = NSTextAlignmentRight;
    }
    else if(item%countColumn == 2)
    {
        cell.imageView2.userInteractionEnabled = NO;
        [cell addSubview:cell.imageView2];
        
        CGRect frame = cell.bounds;
        NSInteger imageSize = 75;
        frame.origin.x = (frame.size.width-imageSize)/2;
        frame.origin.y = (frame.size.height-imageSize)/2;
        frame.size.width = imageSize;
        frame.size.height = imageSize;
        cell.imageView2.frame = frame;
        cell.label.textAlignment = NSTextAlignmentCenter;
        
    }
    else if(item%countColumn == 0)
    {
        cell.imageView.image = [self renderMark];
        cell.imageView.userInteractionEnabled = YES;
        [cell addSubview:cell.imageView];
        
        CGRect frame = cell.bounds;
        NSInteger imageSize = 18;
        frame.origin.x = (frame.size.width-imageSize)/2;
        frame.origin.y = (frame.size.height-imageSize)/2;
        frame.size.width = imageSize;
        frame.size.height = imageSize;
        cell.imageView.frame = frame;
        cell.label.textAlignment = NSTextAlignmentCenter;
    }
    
    
    
    
    if(item/countColumn == 0)
    {
        NSInteger remainder = item%countColumn;
        cell.label.text = productBuyHeader[remainder];
    }
    else if(item/countColumn==[_productBuyList count]+1)
    {
        [cell.leftBorder removeFromSuperview];
        [cell.topBorder removeFromSuperview];
        [cell.rightBorder removeFromSuperview];
        [cell.bottomBorder removeFromSuperview];
        switch (item%countColumn) {
            case 0:
                cell.label.text = @"Total";
                break;
            case 1:
                cell.label.text = [self getStrFmtTotalAmount];
                break;
            case 2:
                cell.label.text = @"Shipping Fee";
                break;
            case 3:
                cell.label.text = [self getStrShippingFee];
                break;
            case 4:
                cell.label.text = [self getDiscountLabel];
                break;
            case 5:
            {
                NSString *minusSign = [[self getStrFmtDiscountValue] isEqualToString:@"0"]?@"":@"-";
                cell.label.text = [NSString stringWithFormat:@"%@%@",minusSign,[self getStrFmtDiscountValue]];
                
            }
                
                break;
            case 6:
                cell.label.text = @"Aft. discount";
                break;
            
            default:
                break;
        }
    }
    else if(item/countColumn==[_productBuyList count]+2)
    {
        [cell.leftBorder removeFromSuperview];
        [cell.topBorder removeFromSuperview];
        [cell.rightBorder removeFromSuperview];
        [cell.bottomBorder removeFromSuperview];
        switch (item%countColumn) {
            case 0:
                cell.label.text = [self getStrFmtAfterDiscountValue];
                break;
            case 1:
            {
                [cell addSubview:cell.leftBorder];
                [cell addSubview:cell.topBorder];
                [cell addSubview:cell.bottomBorder];
                if([[SharedPostBuy sharedPostBuy].postBuyList count] > 0)
                {
                    PostCustomer *postCustomer = [SharedPostBuy sharedPostBuy].postBuyList[0];
                    cell.label.text = [NSString stringWithFormat:@"Member code: %@",postCustomer.telephone];
                }
                else
                {
                    cell.label.text = [NSString stringWithFormat:@"Member code: %@",[self getMemberCode]];
                }
            }
                break;
            case 2:
            {
                [cell addSubview:cell.topBorder];
                [cell addSubview:cell.bottomBorder];
                cell.label.text = @"Point";
            }
                break;
            case 3:
            {
                [cell addSubview:cell.topBorder];
                [cell addSubview:cell.rightBorder];
                [cell addSubview:cell.bottomBorder];
                NSInteger rewardPoint = [self getRewardPoint];
                if(rewardPoint == 0)
                {
                    cell.label.text = @"-";
                }
                else
                {
                    NSString *strRewardPoint = [NSString stringWithFormat:@"%ld",(long)rewardPoint];
                    strRewardPoint = [Utility formatBaht:strRewardPoint withMinFraction:0 andMaxFraction:2];
                    cell.label.text = strRewardPoint;
                }
            }
                break;
            default:
                break;
        }
    }
    else
    {
        CustomMade *customMade = (CustomMade *)_productBuyList[item/countColumn-1][productBuyDetail];
        ProductDetail *productDetail = (ProductDetail *)_productBuyList[item/countColumn-1][productBuyDetail];
        NSString *strImageFileName = _productBuyList[item/countColumn-1][productBuyImageFileName];
        switch (item%countColumn) {
            case 0:
            {
                cell.imageView.tag = item;
                
                [cell.singleTap addTarget:self action:@selector(deleteSales:)];
                cell.singleTap.numberOfTapsRequired = 1;
                cell.singleTap.numberOfTouchesRequired = 1;
                [cell.imageView addGestureRecognizer:cell.singleTap];
            }
                break;
            case 1:
            {
                cell.label.text = [NSString stringWithFormat:@"%ld",item/countColumn];
            }
                break;
            case 2:
            {
                //download product image
                [self loadingOverlayViewForImage:indexPath];
                NSLog(@"download product image");
                NSString *imageFileName = strImageFileName;
                [_homeModel downloadImageWithFileName:imageFileName completionBlock:^(BOOL succeeded, UIImage *image) {
                    if (succeeded) {
                        cell.imageView2.image = image;
                        [self removeOverlayViewsForImage:indexPath];
                        NSLog(@"download image successful");
                    }else
                    {
                        NSLog(@"download image fail");
                        [self removeOverlayViewsForImage:indexPath];
                    }
                }];
            }
                break;
            case 3:
            {
                if([_productBuyList[item/countColumn-1][productType] isEqualToString:[NSString stringWithFormat:@"%d",productInventory]] || [_productBuyList[item/countColumn-1][productType] isEqualToString:[NSString stringWithFormat:@"%d",productPreOrder]])
                {
                    cell.label.text = productDetail.productName;
                }
                else
                {
                    NSString *productNameGroup = [NSString stringWithFormat:@"%@%@%@",customMade.productCategory2,customMade.productCategory1,customMade.productName];
                    cell.label.text = [ProductName getNameWithProductNameGroup:productNameGroup];
                }
            }
                break;
            case 4:
            {
                if([_productBuyList[item/countColumn-1][productType] isEqualToString:[NSString stringWithFormat:@"%d",productInventory]] || [_productBuyList[item/countColumn-1][productType] isEqualToString:[NSString stringWithFormat:@"%d",productPreOrder]])
                {
                    cell.label.text = productDetail.color;
                }
                else
                {
                    cell.label.text = customMade.body;
                }
            }
                break;
            case 5:
            {
                if([_productBuyList[item/countColumn-1][productType] isEqualToString:[NSString stringWithFormat:@"%d",productInventory]] || [_productBuyList[item/countColumn-1][productType] isEqualToString:[NSString stringWithFormat:@"%d",productPreOrder]])
                {
                    cell.label.text = [Utility getSizeLabel:productDetail.size];
                }
                else
                {
                    cell.label.text = customMade.size;
                }
            }
                break;
            case 6:
            {
                NSString *pricePromotion = [_formatter stringFromNumber:[NSNumber numberWithFloat:[_productBuyList[item/countColumn-1][productBuyPricePromotion] floatValue]]];
                
                cell.label.text = pricePromotion;
            }
                break;
            default:
                break;
        }
    }
    
    return cell;
}


- (NSString *)getMemberCode
{
    NSString *memberCode = [Utility removeDashAndSpaceAndParenthesis:[Utility trimString:_txtTelephoneNo.text]];
    if([memberCode isEqualToString:@""])
    {
        memberCode = @"-";
    }
    return memberCode;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        return 0;//reward not use
    }
    return 39;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger row;
    if(section == 0)//reward
    {
        row = 3;
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
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(indexPath.section == 0)
    {
    //reward not use
//        switch (indexPath.row) {
//            case 0:
//            {
//                [cell addSubview:_lblRewardProgramDetail];
//            }
//                break;
//            case 1:
//            {
//                [cell addSubview:_btnRedeemPoint];
//                [cell addSubview:_btnCancelRedeemPoint];
//            }
//                break;
//            case 2:
//            {
//                [cell addSubview:_lblPointUsed];
//            }
//                break;
//        }
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
                [cell addSubview:_txtTelephoneNo];
                [cell addSubview:_btnPost];
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
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = nil;//NSLocalizedString(@"Reward", @"Reward"); not use
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
    return sectionName;
}

- (NSInteger)getCurrentRewardPoint
{
    if(_rewardProgramCollect)
    {
        return floorf([self getAfterDiscountValue]/_rewardProgramCollect.salesSpent*_rewardProgramCollect.receivePoint);
    }
    
    return 0;
}

- (void)cancelRedeemPointButtonClicked:(id)sender
{
    _time = 0;
    _txtDiscountValuePercent.text = @"";
    _lblPointUsed.text = @"No point used";
    _pointSpentActual = 0;
    [self txtDiscountValuePercentDidChange:_txtDiscountValuePercent];
    
    _txtDiscountReason.text = [_txtDiscountReason.text stringByReplacingOccurrencesOfString:@"Use point" withString:@""];
    _txtDiscountReason.text = [Utility trimString:_txtDiscountReason.text];
//    [self updateTimeRewardUsedInCustomerTable:_time];
}

- (NSInteger)getCurrentPointSpent
{
    return _pointSpentActual;
}

- (void)redeemPointButtonClicked:(id)sender
{
    if(!_rewardProgramUse)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning"//
                                                                       message:@"No reward promotion"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    
    if(_rewardProgramUse.discountType == 0)//0=baht,1=percent
    {
        _time +=1;
        _pointSpentActual = _time*_rewardProgramUse.pointSpent;
        if(_pointSpentActual > [self getRewardPoint])
        {
            if(_time == 1)
            {
                _time -= 1;
                _pointSpentActual = _time*_rewardProgramUse.pointSpent;
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"No enough point"
                                                                               message:@"Cannot join the promotion"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {
                                                                          
                                                                      }];
                
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
                return;
            }
            else
            {
                _time -= 1;
                _pointSpentActual = _time*_rewardProgramUse.pointSpent;
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"No enough point"
                                                                               message:[NSString stringWithFormat:@"Maximum spent is %ld point",_pointSpentActual]
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {
                                                                          
                                                                      }];
                
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
                return;
            }
        }
        else if(_time*_rewardProgramUse.discountAmount > [self getTotalAmount])
        {
            _time -= 1;
            _pointSpentActual = _time*_rewardProgramUse.pointSpent;
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Cannot redeem point to cash"
                                                                           message:[NSString stringWithFormat:@"Maximum spent is %ld point",_pointSpentActual]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      
                                                                  }];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        else
        {
            NSString *strPointSpentActual = [NSString stringWithFormat:@"%ld",_pointSpentActual];
            strPointSpentActual = [Utility formatBaht:strPointSpentActual withMinFraction:0 andMaxFraction:2];
            NSString * strDiscountAmount = [NSString stringWithFormat:@"%f",_rewardProgramUse.discountAmount*_time];
            strDiscountAmount = [Utility formatBaht:strDiscountAmount withMinFraction:0 andMaxFraction:2];
            _segConBahtPercent.selectedSegmentIndex = 0;
            _txtDiscountValuePercent.text = strDiscountAmount;
            _lblPointUsed.text = [NSString stringWithFormat:@"Spent %@ point and get %@ baht",strPointSpentActual,strDiscountAmount];
            [self txtDiscountValuePercentDidChange:_txtDiscountValuePercent];
            _txtDiscountReason.text = @"Use point";
        }
    }
    else if(_rewardProgramUse.discountType == 1)//0=baht,1=percent
    {
        _time +=1;
        if(_rewardProgramUse.pointSpent == 0)//0=use point equal to sales amount
        {
            _pointSpentActual = ceilf([self getAfterDiscountValue]);
            
        }
        else
        {
            _pointSpentActual = _rewardProgramUse.pointSpent;
        }
        
        if(_pointSpentActual > [self getRewardPoint])
        {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"No enough point"
                                                                           message:@"Cannot join the promotion"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      
                                                                  }];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        else
        {
            NSString *strPointSpentActual = [NSString stringWithFormat:@"%ld",_pointSpentActual];
            strPointSpentActual = [Utility formatBaht:strPointSpentActual withMinFraction:0 andMaxFraction:2];
            NSString * strDiscountAmount = [NSString stringWithFormat:@"%f",_rewardProgramUse.discountAmount];
            strDiscountAmount = [Utility formatBaht:strDiscountAmount withMinFraction:0 andMaxFraction:2];
            _segConBahtPercent.selectedSegmentIndex = 1;
            _txtDiscountValuePercent.text = strDiscountAmount;
            _lblPointUsed.text = [NSString stringWithFormat:@"Spent %@ point and get %@%%",strPointSpentActual,strDiscountAmount];
            [self txtDiscountValuePercentDidChange:_txtDiscountValuePercent];
            _txtDiscountReason.text = @"Use point";
        }
    }
    
//    [self updateTimeRewardUsedInCustomerTable:_time];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segAddPostCustomer"])
    {
        if([[SharedPostBuy sharedPostBuy].postBuyList count] == 0)
        {
            AddEditPostCustomerViewController *vc = segue.destinationViewController;
//            vc.booAddOrEdit = YES;
            vc.telephoneNoSearch = [Utility removeDashAndSpaceAndParenthesis:_txtTelephoneNo.text];
        }
        else
        {
            AddEditPostCustomerViewController *vc = segue.destinationViewController;
//            vc.booAddOrEdit = NO;
            vc.telephoneNoSearch = [Utility removeDashAndSpaceAndParenthesis:_txtTelephoneNo.text];
        }
    }
}


- (void) deleteSales:(UIGestureRecognizer *)gestureRecognizer
{
    
    UIView* view = gestureRecognizer.view;
    NSInteger countColumn = 7;
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:
     [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Delete product (No.%ld)",view.tag/countColumn]
                              style:UIAlertActionStyleDestructive
                            handler:^(UIAlertAction *action) {
                                [_productBuyList removeObject:_productBuyList[view.tag/countColumn-1]] ;
                                [colViewSummaryTable reloadData];
                                [self updateCalculateParts];
                            }]];
    [alert addAction:
     [UIAlertAction actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleCancel
                            handler:^(UIAlertAction *action) {}]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width;
    CGFloat height;
    NSInteger countColumn = 7;
    //    @[@"No",@"Picture",@"Item",@"Color",@"Size",@"Baht",@"DEL"];
    if(indexPath.item/countColumn == [_productBuyList count]+1)
    {
        switch (indexPath.item%countColumn) {
            case 0:
                width = 30+26+80+2*(colViewSummaryTable.bounds.size.width - 30 - 26 - 80 - 30 - 44)/2;
                break;
            case 1:
                width = 30+44;
                break;
            case 2:
                width = 30+26+80+2*(colViewSummaryTable.bounds.size.width - 30 - 26 - 80 - 30 - 44)/2;
                break;
            case 3:
                width = 30+44;
                break;
            case 4:
                width = 30+26+80+2*(colViewSummaryTable.bounds.size.width - 30 - 26 - 80 - 30 - 44)/2;
                break;
            case 5:
                width = 30+44;
                break;
            case 6:
                width = 30+26+80+2*(colViewSummaryTable.bounds.size.width - 30 - 26 - 80 - 30 - 44)/2;
                break;
            default:
                width = 0;
                break;
        }
    }
    else if(indexPath.item/countColumn == [_productBuyList count]+2)
    {
        switch (indexPath.item%countColumn) {
            case 0:
                width = 30+44;
                break;
            case 1:
                width = 30+26+80+(colViewSummaryTable.bounds.size.width - 30 - 26 - 80 - 30 - 44)/2;
                break;
            case 2:
                width = (colViewSummaryTable.bounds.size.width - 30 - 26 - 80 - 30 - 44)/2;
                break;
            case 3:
                width = 30+44;
                break;
            default:
                width = 0;
                break;
        }
    }
    else
    {
        switch (indexPath.item%countColumn) {
            case 0:
                width = 30;
                break;
            case 1:
                width = 26;
                break;
            case 2:
                width = 80;
                break;
            case 5:
                width = 30;
                break;
            case 6:
                width = 44;
                break;
            default:
                width = (colViewSummaryTable.bounds.size.width - 30 - 26 - 80 - 30 - 44)/2;
                break;
        }
    }
    
    
    if(indexPath.row/countColumn == 0 || indexPath.row/countColumn == [_productBuyList count]+1 || indexPath.row/countColumn == [_productBuyList count]+2)
    {
        height = 20;
    }    
    else
    {
        height = 80;
    }
    
    CGSize size = CGSizeMake(width, height);
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
    //    return UIEdgeInsetsMake(0, 20, 0, 20);//top, left, bottom, right -> collection view
    return UIEdgeInsetsMake(0, 0, 0, 0);//top, left, bottom, right -> collection view
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
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        
        reusableview = headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footerPayment" forIndexPath:indexPath];
        _footerview = footerview;
        UITableView *tbvPay = (UITableView *)[_footerview viewWithTag:19];
        tbvPay.delegate = self;
        tbvPay.dataSource = self;
        
        
        
        reusableview = footerview;
    }
    
    return reusableview;
}

- (void)updateCalculateParts
{
    //total,discount,afterdiscount,changes
    
    NSInteger countColumn = 7;
    {
        NSInteger item = ([_productBuyList count]+1)*countColumn+1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        CustomUICollectionViewCellButton3 *cell = (CustomUICollectionViewCellButton3*)[colViewSummaryTable cellForItemAtIndexPath:indexPath];
    
        
        cell.label.text = [self getStrFmtTotalAmount];
    }
    {
        NSInteger item = ([_productBuyList count]+1)*countColumn+3;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        CustomUICollectionViewCellButton3 *cell = (CustomUICollectionViewCellButton3*)[colViewSummaryTable cellForItemAtIndexPath:indexPath];
    
        
        cell.label.text = [self getStrShippingFee];
    }
    {
        NSInteger item = ([_productBuyList count]+1)*countColumn+4;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        CustomUICollectionViewCellButton3 *cell = (CustomUICollectionViewCellButton3*)[colViewSummaryTable cellForItemAtIndexPath:indexPath];
        
        
        cell.label.text = [self getDiscountLabel];
    }
    {
        NSInteger item = ([_productBuyList count]+1)*countColumn+5;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        CustomUICollectionViewCellButton3 *cell = (CustomUICollectionViewCellButton3*)[colViewSummaryTable cellForItemAtIndexPath:indexPath];
        
        
        NSString *minusSign = [[self getStrFmtDiscountValue] isEqualToString:@"0"]?@"":@"-";
        cell.label.text = [NSString stringWithFormat:@"%@%@",minusSign,[self getStrFmtDiscountValue]];
    }
    {
        NSInteger item = ([_productBuyList count]+1)*countColumn+7;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        CustomUICollectionViewCellButton3 *cell = (CustomUICollectionViewCellButton3*)[colViewSummaryTable cellForItemAtIndexPath:indexPath];
        
        
        cell.label.text = [self getStrFmtAfterDiscountValue];
    }
    
    _lblChanges.text = [NSString stringWithFormat:@"Changes: %@ Baht",[self getStrChanges]];
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

-(NSInteger)getCustomerIDFromSharedPostBuy
{
    PostCustomer *postCustomer = [SharedPostBuy sharedPostBuy].postBuyList[0];
    return postCustomer.customerID;
}

- (void)payButtonClicked:(id)sender {
    if(![self validateData])
    {
        return;
    }
    NSMutableArray *data = [[NSMutableArray alloc]init];
    NSInteger receiptID = [Utility getNextID:tblReceipt];
    
    
    
    //update product inventory
    NSMutableArray *arrProduct = [[NSMutableArray alloc]init];
    NSMutableArray *arrCustomMade = [[NSMutableArray alloc]init];
    NSMutableArray *arrReceiptProductItem = [[NSMutableArray alloc]init];
    NSMutableArray *arrPreOrderEventIDHistory = [[NSMutableArray alloc]init];
    for(int i=0; i<[_productBuyList count]; i++)
    {
        if([_productBuyList[i][productType] intValue] == productInventory)
        {
            ProductDetail *productDetail = (ProductDetail*)_productBuyList[i][productBuyDetail];
            Product *product = [Product getProduct:productDetail.productID];
            if(product.idInserted==0)//เช็คว่าได้ id ที่แท้จริงแล้วหรือยัง (คือ ไม่ duplicate entry ใน database)
            {
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                               message:@"Cannot pay, please try again later"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {
                                                                          [self loadingOverlayView];
                                                                          PushSync *pushSync = [[PushSync alloc]init];
                                                                          pushSync.deviceToken = [Utility deviceToken];
                                                                          [_homeModel syncItems:dbPushSync withData:pushSync];
                                                                      }];
                
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
                return;
            }
        }
        else if([_productBuyList[i][productType] intValue] == productPreOrder)
        {
            ProductDetail *productDetail = (ProductDetail*)_productBuyList[i][productBuyDetail];
            Product *product = [Product getProduct:productDetail.productID];
            if(product.idInserted==0)//เช็คว่าได้ id ที่แท้จริงแล้วหรือยัง (คือ ไม่ duplicate entry ใน database)
            {
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                               message:@"Cannot pay, please try again later"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {
                                                                          [self loadingOverlayView];
                                                                          PushSync *pushSync = [[PushSync alloc]init];
                                                                          pushSync.deviceToken = [Utility deviceToken];
                                                                          [_homeModel syncItems:dbPushSync withData:pushSync];
                                                                      }];
                
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
                return;
            }
        }
    }
    for(int i=0; i<[_productBuyList count]; i++)
    {
        if([_productBuyList[i][productType] intValue] == productInventory)
        {
            ProductDetail *productDetail = (ProductDetail*)_productBuyList[i][productBuyDetail];
            Product *product = [Product getProduct:productDetail.productID];
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
            [ReceiptProductItem addObject:receiptProductItem];
            [arrReceiptProductItem addObject:receiptProductItem];
        }
    }
    
    
    //update product preOrder
    for(int i=0; i<[_productBuyList count]; i++)
    {
        if([_productBuyList[i][productType] intValue] == productPreOrder)
        {
            ProductDetail *productDetail = (ProductDetail*)_productBuyList[i][productBuyDetail];
            Product *product = [Product getProduct:productDetail.productID];
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
            [ReceiptProductItem addObject:receiptProductItem];
            [arrReceiptProductItem addObject:receiptProductItem];
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
            [[SharedCustomMade sharedCustomMade].customMadeList addObject:customMade];
            
            
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
            [ReceiptProductItem addObject:receiptProductItem];
            [arrReceiptProductItem addObject:receiptProductItem];
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
    NSString *strEventID = [NSString stringWithFormat:@"%ld",(long)[SharedSelectedEvent sharedSelectedEvent].event.eventID];
    Receipt *receipt = [[Receipt alloc]init];
    receipt.receiptID = receiptID;
    receipt.eventID = strEventID;
    receipt.channel = _segConChannel.selectedSegmentIndex;//0=event,1=web,2=line,3=fb,4=shop,5=other
    receipt.payPrice = [Utility removeComma:[self getStrFmtAfterDiscountValue]];
    receipt.paymentMethod = @"";//[_txtCreditAmount.text isEqualToString:@""]?@"CA":[_txtCashReceive.text isEqualToString:@""]?@"CC":@"BO";
    receipt.creditAmount = [self getStrCreditAmount];
    receipt.cashAmount = [self getStrCashAmount];
    receipt.transferAmount = [self getStrTransferAmount];
    receipt.cashReceive = [self getStrCashReceive];
    receipt.remark = [Utility trimString:_txtSalesRemark.text];
    receipt.shippingFee = [self getStrShippingFee];
    receipt.discount = [self getDiscountValue] == 0?@"0":_segConBahtPercent.selectedSegmentIndex==baht?@"1":@"2";
    receipt.discountValue = _segConBahtPercent.selectedSegmentIndex==baht?[Utility removeComma:[self getStrFmtDiscountValue]]:@"0";
    receipt.discountPercent = _segConBahtPercent.selectedSegmentIndex==percent?_strDiscountValuePercent:@"0";
    receipt.discountReason = [Utility trimString:_txtDiscountReason.text];
    receipt.receiptDate = [Utility dateToString:[Utility GMTDate:[NSDate date]] toFormat:@"yyyy-MM-dd HH:mm:ss"];
    receipt.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
    receipt.modifiedUser = [Utility modifiedUser];
    receipt.salesUser = [self getSalesUser];
    [[SharedReceipt sharedReceipt].receiptList addObject:receipt];
    [data addObject:receipt];
    
    
    
    //insert rewardpoint
    //จะ add reward ถ้ามี sharedpostbuy หรือ กรอกเบอร์โทร
    BOOL addReward = NO;
    if([[SharedPostBuy sharedPostBuy].postBuyList count]>0)
    {
        addReward = YES;
    }
    else if(![[Utility removeDashAndSpaceAndParenthesis:_txtTelephoneNo.text] isEqualToString:@""])
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
        NSInteger rewardPointID = [Utility getNextID:tblRewardPoint];
        if([self getCurrentRewardPoint] != 0)
        {
            RewardPoint *rewardPoint = [[RewardPoint alloc]init];
            rewardPoint.rewardPointID = rewardPointID++;
            rewardPoint.customerID = 0;//[self getCustomerIDFromSharedPostBuy];
            rewardPoint.receiptID = receiptID;
            rewardPoint.point = [self getCurrentRewardPoint];
            rewardPoint.status = 1;
            rewardPoint.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
            rewardPoint.modifiedUser = [Utility modifiedUser];
            [rewardPointList addObject:rewardPoint];
        }
        if([self getCurrentPointSpent] != 0)
        {
            RewardPoint *rewardPoint = [[RewardPoint alloc]init];
            rewardPoint.rewardPointID = rewardPointID++;
            rewardPoint.customerID = 0;//[self getCustomerIDFromSharedPostBuy];
            rewardPoint.receiptID = receiptID;
            rewardPoint.point = [self getCurrentPointSpent];
            rewardPoint.status = -1;
            rewardPoint.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
            rewardPoint.modifiedUser = [Utility modifiedUser];
            [rewardPointList addObject:rewardPoint];
        }
    }
    [[SharedRewardPoint sharedRewardPoint].rewardPointList addObjectsFromArray:rewardPointList];
    [data addObject:rewardPointList];
    
    
    
    
    //insert post customer
    NSMutableArray *arrPostCustomer = [[NSMutableArray alloc]init];
    PostCustomer *postCustomerInsert;
    NSMutableArray *postBuyList = [SharedPostBuy sharedPostBuy].postBuyList;
    if([postBuyList count]>0)
    {
        PostCustomer *postCustomer = postBuyList[0];
        if(postCustomer.postCustomerID == 0)
        {
            postCustomer.postCustomerID = [Utility getNextID:tblPostCustomer];
            postCustomer.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
            postCustomer.modifiedUser = [Utility modifiedUser];
            [arrPostCustomer addObject:postCustomer];
            [[SharedPostCustomer sharedPostCustomer].postCustomerList addObjectsFromArray:arrPostCustomer];
        }
    }
    [data addObject:arrPostCustomer];
    

    
    //insert customerReceipt
    CustomerReceipt *customerReceipt = [[CustomerReceipt alloc]init];
    customerReceipt.customerReceiptID = [Utility getNextID:tblCustomerReceipt];
    customerReceipt.receiptID = receipt.receiptID;
    customerReceipt.postCustomerID = [postBuyList count]==0?0:[self isNewPostCustomer]?postCustomerInsert.postCustomerID:[self getExistedPostCustomerID];//ถ้าไม่ได้ใส่ post จะเป็น 0, หรือถ้าใส่ post ที่สร้างขึ้นใหม่ จะเป็น newID, ถ้าไม่งั้นจะเป็น existedID
    customerReceipt.trackingNo = @"";
    customerReceipt.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
    customerReceipt.modifiedUser = [Utility modifiedUser];
    [data addObject:customerReceipt];
    [[SharedCustomerReceipt sharedCustomerReceipt].customerReceiptList addObject:customerReceipt];
    
    
    [self loadingOverlayView];
    [_homeModel insertItems:dbReceiptAndProductBuyInsert withData:data];
}

//สำหรับกรณี เลือก postcustomer ที่มีอยู่ในระบบ เลยไม่ต้อง create postcustomer ขึ้นมาใหม่
- (NSInteger)getExistedPostCustomerID
{
    NSMutableArray *postBuy = [SharedPostBuy sharedPostBuy].postBuyList;
    PostCustomer *postCustomer = postBuy[0];
    
    return postCustomer.postCustomerID;
}

- (BOOL)isNewPostCustomer
{
    NSMutableArray *postBuy = [SharedPostBuy sharedPostBuy].postBuyList;
    PostCustomer *postCustomer = postBuy[0];
    if(postCustomer.postCustomerID == 0)//สร้าง post ขึ้นใหม่
    {
        return YES;
    }
    else// เลือก post ที่มีอยู่แล้ว
    {
        return NO;
    }
}

-(void)itemsDownloaded:(NSArray *)items
{
    {
        PushSync *pushSync = [[PushSync alloc]init];
        pushSync.deviceToken = [Utility deviceToken];
        [_homeModel updateItems:dbPushSyncUpdateByDeviceToken withData:pushSync];
    }
    
    
    [Utility itemsDownloaded:items];
    [self removeOverlayViews];
    [self loadViewProcess];
}

- (void)itemsFail
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[Utility getConnectionLostTitle]
                                                                   message:[Utility getConnectionLostMessage]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [self loadingOverlayView];
                                                              [_homeModel downloadItems:dbMaster];
                                                          }];
    
    [alert addAction:defaultAction];
    dispatch_async(dispatch_get_main_queue(),^ {
        [self presentViewController:alert animated:YES completion:nil];
    } );
}

- (void)itemsUpdated
{
    
}

- (void)itemsInserted
{
    [self removeOverlayViews];
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

- (void)emailSent
{
    
}

enum enumPaymentMethod
{
    cash,
    creditCard,
    bothCashCredit
};

enum enumDiscountType
{
    baht,
    percent
};

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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
{
    CGSize headerSize = CGSizeMake(collectionView.bounds.size.width, 0);
    return headerSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    CGSize footerSize = CGSizeMake(collectionView.bounds.size.width, 736);
    return footerSize;
}

-(void) loadingOverlayViewForImage:(NSIndexPath *)indexPath
{
    
    CustomUICollectionViewCellButton3 *cell = (CustomUICollectionViewCellButton3*)[colViewSummaryTable cellForItemAtIndexPath:indexPath];
    cell.overlayView = [[UIView alloc] initWithFrame:cell.imageView2.frame];
    cell.overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
    
    
    cell.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    cell.indicator.frame = CGRectMake(cell.imageView2.bounds.size.width/2-indicator.frame.size.width/2,cell.imageView2.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);
    [cell.indicator startAnimating];
    
    // and just add them to navigationbar view
    [self.navigationController.view addSubview:cell.overlayView];
    [self.navigationController.view addSubview:cell.indicator];
}

-(void) removeOverlayViewsForImage:(NSIndexPath *)indexPath
{
    CustomUICollectionViewCellButton3 *cell = (CustomUICollectionViewCellButton3*)[colViewSummaryTable cellForItemAtIndexPath:indexPath];
    
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         //                         cell.overlayView.alpha = 0.0;
                         cell.indicator.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         dispatch_async(dispatch_get_main_queue(),^ {
                             //                             [cell.overlayView removeFromSuperview];
                             [indicator stopAnimating];
                             [indicator removeFromSuperview];
                         } );
                     }
     ];
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

-(UIImage*)resizeImage:(UIImage *)image imageSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    //here is the scaled image which has been changed to the size specified
    UIGraphicsEndImageContext();
    return newImage;
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


- (void)postButtonClicked:(id)sender {
    
    [self performSegueWithIdentifier:@"segAddPostCustomer" sender:self];
    
}

- (void)itemsSynced:(NSArray *)items
{
    NSMutableArray *pushSyncList = [[NSMutableArray alloc]init];
    for(int j=0; j<[items count]; j++)
    {
        NSDictionary *payload = items[j];
        NSString *type = [payload objectForKey:@"type"];
        NSString *action = [payload objectForKey:@"action"];
        NSString *strPushSyncID = [payload objectForKey:@"pushSyncID"];
        NSArray *data = [payload objectForKey:@"data"];
        
        
        //เช็คว่าเคย sync pushsyncid นี้ไปแล้วยัง
        if([Utility alreadySynced:[strPushSyncID integerValue]])
        {
            continue;
        }
        else
        {
            //update shared ใช้ในกรณี เรียก homemodel > 1 อันต่อหนึ่ง click คำสั่ง ซึ่งทำให้เกิดการ เรียก function syncitems ตัวที่ 2 ก่อนเกิดการ update timesynced จึงทำให้เกิดการเบิ้ล sync
            PushSync *pushSync = [[PushSync alloc]initWithPushSyncID:[strPushSyncID integerValue]];
            [PushSync addObject:pushSync];
            [pushSyncList addObject:pushSync];
        }
        
        if([type isEqualToString:@"usernameconflict"])
        {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Conflict"
                                                                           message:@"Another device log in with this username"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action)
                                            {
                                                for (UIViewController *vc in self.navigationController.viewControllers) {
                                                    if ([vc isKindOfClass:[SignInViewController class]]) {
                                                        [self.navigationController popToViewController:vc animated:YES];
                                                    }
                                                }
                                            }];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else if([type isEqualToString:@"alert"])
        {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:[Utility getSqlFailTitle]
                                                                           message:[Utility getSqlFailMessage]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action)
                                            {
                                                [self loadingOverlayView];
                                                [_homeModel downloadItems:dbMaster];
                                            }];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else if([type isEqualToString:@"alertUploadPhotoFail"])
        {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Fail"
                                                                           message:@"Upload photo fail"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action)
                                            {
                                            }];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            [Utility itemsSynced:type action:action data:data];
        }
    }
    //update pushsync ที่ sync แล้ว
    [_homeModel updateItems:dbPushSyncUpdateTimeSynced withData:pushSyncList];
    
//    [self loadViewProcess];ไม่ต้องเรียก loadviewprocess เพราะเป็นการ sync column idinserted ซึ่งไม่ได้เกี่ยวกับการแสดงผลที่หน้าจอ เป็นเพียงหลังบ้านเท่านั้น
    [self removeOverlayViews];
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
    
    UITableView *tbvPay = (UITableView *)[_footerview viewWithTag:19];
    tbvPay.contentInset = contentInsets;
    tbvPay.scrollIndicatorInsets = contentInsets;
    //    [colViewSummaryTable scrollToRowAtIndexPath:colViewSummaryTable.editingIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    UITableView *tbvPay = (UITableView *)[_footerview viewWithTag:19];
    tbvPay.contentInset = UIEdgeInsetsZero;
    tbvPay.scrollIndicatorInsets = UIEdgeInsetsZero;
    
    
    //    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    //    [UIView animateWithDuration:rate.floatValue animations:^{
    //        self.tableView.contentInset = // insert content inset value here
    //        self.tableView.scrollIndicatorInsets = // insert content inset value here
    //    }];
}
@end

