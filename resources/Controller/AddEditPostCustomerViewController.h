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
#import "CustomViewController.h"

@interface AddEditPostCustomerViewController : CustomViewController<HomeModelProtocol,UITextFieldDelegate,UITextViewDelegate>
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
@property (strong, nonatomic) IBOutlet UITableView *tbvData;
@property (nonatomic) BOOL paid;
@property (strong, nonatomic) NSString *telephoneNoSearch;
@property (nonatomic) NSInteger productBuyIndex;
@property (strong, nonatomic) NSString *email;

@property (strong, nonatomic) ItemTrackingNo *selectedItemTrackingNo;
@property (strong, nonatomic) NSArray *receiptProductItemList;
@property (strong, nonatomic) PostCustomer *selectedPostCustomer;
@property (nonatomic) BOOL readOnly;
@property (nonatomic) NSInteger pageIndex;//1=searchReceipt
- (IBAction)cancelButtonClicked:(id)sender;




@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnCancel;
@property (strong, nonatomic) IBOutlet UIButton *btnDelete;
@property (strong, nonatomic) IBOutlet UIView *searchView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnNextCustomer;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnPreviousCustomer;
- (IBAction)savePost:(id)sender;
- (IBAction)deletePost:(id)sender;
- (IBAction)nextButtonClicked:(id)sender;
- (IBAction)previousButtonClicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnDone;
@end
