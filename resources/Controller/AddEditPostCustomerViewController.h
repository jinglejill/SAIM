//
//  AddEditPostCustomerViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/13/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"
#import "CustomUITextView.h"
#import "CustomerReceipt.h"
#import "PostCustomer.h"
#import "ItemTrackingNo.h"

@interface AddEditPostCustomerViewController : UITableViewController<HomeModelProtocol,UITextFieldDelegate,UITextViewDelegate>
{
    UITextField *txtFirstName;
    UITextField *txtPostCode;
    UITextField *txtCountry;
    UITextField *txtTelephone;
    UITextField *txtEmailAddress;
    UITextField *txtLineID;
    UITextField *txtFacebookID;
    UITextField *txtOther;
    UIButton *btnFillDetail;
    UIButton *btnCopyToTaxCustomerName;
    CustomUITextView *txtVwAddress;
    CustomUITextView *txtVwAddress2;
    
    
    UITextField *txtTaxCustomerName;    
    CustomUITextView *txtVwTaxCustomerAddress;
    UITextField *txtTaxNo;
}

@property (nonatomic) BOOL paid;
@property (strong, nonatomic) NSString *telephoneNoSearch;
@property (nonatomic) NSInteger productBuyIndex;

@property (strong, nonatomic) ItemTrackingNo *selectedItemTrackingNo;
@property (strong, nonatomic) NSArray *receiptProductItemList;
@property (strong, nonatomic) PostCustomer *selectedPostCustomer;
- (IBAction)cancelButtonClicked:(id)sender;




//@property (nonatomic) NSInteger receiptID;
//@property (nonatomic) NSInteger receiptProductItemID;
//@property (nonatomic) NSInteger postCustomerID;
//@property (nonatomic) BOOL booAddOrEdit;// YES = add, NO = edit
@property (nonatomic) NSInteger action;////cancel=0,add=1,edit=2,delete=3
@property (nonatomic) BOOL hasPost;

@property (strong, nonatomic) CustomerReceipt *selectedCustomerReceipt;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnCancel;
@property (strong, nonatomic) IBOutlet UIButton *btnDelete;
@property (strong, nonatomic) IBOutlet UIView *searchView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnNextCustomer;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnPreviousCustomer;
- (IBAction)savePost:(id)sender;
- (IBAction)CancelPost:(id)sender;
- (IBAction)deletePost:(id)sender;
- (IBAction)nextButtonClicked:(id)sender;
- (IBAction)previousButtonClicked:(id)sender;
@end
