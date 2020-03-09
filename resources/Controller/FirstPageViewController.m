//
//  FirstPageViewController.m
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/22/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "FirstPageViewController.h"
#import "Utility.h"
#import "Setting.h"
#import "Message.h"
#import "SharedUserAccount.h"
#import "SharedProductName.h"
#import "SharedColor.h"
#import "SharedProduct.h"
#import "SharedEvent.h"
#import "SharedUserAccountEvent.h"
#import "SharedProductCategory2.h"
#import "SharedProductCategory1.h"
#import "SharedProductSales.h"
#import "SharedCashAllocation.h"
#import "SharedCustomMade.h"
#import "SharedReceipt.h"
#import "SharedReceiptItem.h"
#import "SharedCompareInventoryHistory.h"
#import "SharedCompareInventory.h"
#import "SharedProductSalesSet.h"
#import "SharedCustomerReceipt.h"
#import "SharedPostCustomer.h"
#import "SharedProductCost.h"
#import "SharedEventCost.h"
#import "SharedCostLabel.h"
#import "SharedProductSize.h"
#import "SharedImageRunningID.h"
#import "SharedProductDelete.h"
#import "SharedSetting.h"
#import "SharedPostCode.h"

#import "PushSync.h"
#import "SharedPushSync.h"
#import "KeychainWrapper.h"
#import "Credentials.h"
#import "Device.h"



@interface FirstPageViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
}
@end
extern NSArray *globalMessage;
extern NSNumberFormatter *formatterBaht;
@implementation FirstPageViewController
@synthesize imgVw;
@synthesize progressBar;
@synthesize pinValidated;

- (void)presentAlertViewForPassword
{
    
    // 1
    BOOL hasPin = [[NSUserDefaults standardUserDefaults] boolForKey:PIN_SAVED];
    
    // 2
    if (hasPin)
    {
        [self downloadData];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Setup Credentials"
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Done", nil];
        // 6
        [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
        alert.tag = kAlertTypeSetup;
        UITextField *nameField = [alert textFieldAtIndex:0];
        nameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        nameField.placeholder = @"Name"; // Replace the standard placeholder text with something more applicable
        nameField.delegate = self;
        nameField.tag = kTextFieldName;
        UITextField *passwordField = [alert textFieldAtIndex:1]; // Capture the Password text field since there are 2 fields
        passwordField.delegate = self;
        passwordField.tag = kTextFieldPassword;
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
//    if (alertView.tag == kAlertTypePIN) {
//        if (buttonIndex == 1 && self.pinValidated) { // User selected "Done"
//            [self performSegueWithIdentifier:@"ChristmasTableSegue" sender:self];
//            self.pinValidated = NO;
//        } else { // User selected "Cancel"
//            [self presentAlertViewForPassword];
//        }
//    } else
    if (alertView.tag == kAlertTypeSetup)
    {
        if (buttonIndex == 1)
        { // User selected "Done"
//            [self performSegueWithIdentifier:@"ChristmasTableSegue" sender:self];
            [self credentialsValidated];
        }
        else
        { // User selected "Cancel"
            [self presentAlertViewForPassword];
        }
    }
}

#pragma mark - Text Field + Alert View Methods
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // 1
    switch (textField.tag) {
//        case kTextFieldPIN: // We go here if this is the 2nd+ time used (we've already set a PIN at Setup).
//            NSLog(@"User entered PIN to validate");
//            if ([textField.text length] > 0) {
//                // 2
//                NSUInteger fieldHash = [textField.text hash]; // Get the hash of the entered PIN, minimize contact with the real password
//                // 3
//                if ([KeychainWrapper compareKeychainValueForMatchingPIN:fieldHash]) { // Compare them
//                    NSLog(@"** User Authenticated!!");
//                    self.pinValidated = YES;
//                } else {
//                    NSLog(@"** Wrong Password :(");
//                    self.pinValidated = NO;
//                }
//            }
//            break;
        case kTextFieldName: // 1st part of the Setup flow.
            NSLog(@"User entered name");
            if ([textField.text length] > 0)
            {
                [[NSUserDefaults standardUserDefaults] setValue:[textField.text uppercaseString] forKey:USERNAME];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            break;
        case kTextFieldPassword: // 2nd half of the Setup flow.
            NSLog(@"User entered PIN");
            if ([textField.text length] > 0)
            {
//                NSUInteger fieldHash = [textField.text hash];
//                // 4
//                NSString *fieldString = [KeychainWrapper securedSHA256DigestHashForPIN:fieldHash];
//                NSLog(@"** Password Hash - %@", fieldString);
//                // Save PIN hash to the keychain (NEVER store the direct PIN)
//                if ([KeychainWrapper createKeychainValue:fieldString forIdentifier:PIN_SAVED])
                {
//                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PIN_SAVED];
                    [[NSUserDefaults standardUserDefaults] setValue:textField.text forKey:PASSWORD];
                    [[NSUserDefaults standardUserDefaults] synchronize];
//                    NSLog(@"** Key saved successfully to Keychain!!");
                }
            }
            break;
        default:
            break;
    }
}

// Helper method to congregate the Name and PIN fields for validation.
- (void)credentialsValidated
{
    [self loadingOverlayView];
    
    NSString *name = [[NSUserDefaults standardUserDefaults] stringForKey:USERNAME];
    NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:PASSWORD];
    
    Credentials *credentials = [[Credentials alloc]init];
    credentials.username = name;
    credentials.password = password;
    [_homeModel updateItems:dbCredentials withData:credentials];
}

- (void)itemsUpdated:(NSString *)alertText//if error
{
    [self removeOverlayViews];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:alertText
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
                                                            {
                                                                [self presentAlertViewForPassword];
                                                            }];
    [alert addAction:defaultAction];
    dispatch_async(dispatch_get_main_queue(),^ {
        [self presentViewController:alert animated:YES completion:nil];
    } );
}

- (void)itemsUpdated//if not error
{
    if(_homeModel.propCurrentDB == dbCredentials)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PIN_SAVED];
        
        
        if([Utility dbName])
        {
            Device *device = [[Device alloc]init];
            device.deviceToken = [Utility deviceToken];
            [_homeModel insertItems:dbDevice withData:device];
        }
    }
}

- (void)itemsInsertedWithReturnID:(NSString *)returnID
{
    [[NSUserDefaults standardUserDefaults] setValue:returnID forKey:@"deviceID"];
    [self removeOverlayViews];
    [self loadViewProcess];

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
    
    
    pinValidated = NO;
    [self presentAlertViewForPassword];
    
    
//    [self loadViewProcess];
}

- (void)loadViewProcess
{
    [self presentAlertViewForPassword];
}

- (void)downloadData
{
    formatterBaht = [[NSNumberFormatter alloc] init];
    NSMutableArray *arrItemMessage = [[NSMutableArray alloc] init];
    
    
    
    NSArray *jsonArrayMessage = @[@{@"EnumNo":@"0",@"EnumKey":@"skipMessage1",@"Message":@"-",@"ModifiedDate":@"2015-07-30 15:34:31"},@{@"EnumNo":@"1",@"EnumKey":@"incorrectPasscode",@"Message":@"Incorrect passcode",@"ModifiedDate":@"0000-00-00 00:00:00"},@{@"EnumNo":@"2",@"EnumKey":@"skipMessage2",@"Message":@"-",@"ModifiedDate":@"2015-07-30 15:34:48"},@{@"EnumNo":@"3",@"EnumKey":@"emailSubjectAdd",@"Message":@"Minimalist - your username and password",@"ModifiedDate":@"0000-00-00 00:00:00"},@{@"EnumNo":@"4",@"EnumKey":@"emailBodyAdd",@"Message":@"Your username is %@<br>Your password is %@",@"ModifiedDate":@"0000-00-00 00:00:00"},@{@"EnumNo":@"5",@"EnumKey":@"emailSubjectReset",@"Message":@"Minimalist - you request a new password",@"ModifiedDate":@"0000-00-00 00:00:00"},@{@"EnumNo":@"6",@"EnumKey":@"emailBodyReset",@"Message":@"Your username is %@<br>Your password is %@",@"ModifiedDate":@"0000-00-00 00:00:00"},@{@"EnumNo":@"7",@"EnumKey":@"emailInvalid",@"Message":@"Email address is invalid.",@"ModifiedDate":@"0000-00-00 00:00:00"},@{@"EnumNo":@"8",@"EnumKey":@"emailExisted",@"Message":@"This email address has already existed.",@"ModifiedDate":@"2015-08-11 11:22:52"},@{@"EnumNo":@"9",@"EnumKey":@"wrongEmail",@"Message":@"Wrong registered email",@"ModifiedDate":@"0000-00-00 00:00:00"},@{@"EnumNo":@"10",@"EnumKey":@"wrongPassword",@"Message":@"Wrong old password",@"ModifiedDate":@"0000-00-00 00:00:00"},@{@"EnumNo":@"11",@"EnumKey":@"newPasswordNotMatch",@"Message":@"New passwords do not match.",@"ModifiedDate":@"0000-00-00 00:00:00"},@{@"EnumNo":@"12",@"EnumKey":@"changePasswordSuccess",@"Message":@"Your password has been changed successfully.",@"ModifiedDate":@"0000-00-00 00:00:00"},@{@"EnumNo":@"13",@"EnumKey":@"emailSubjectChangePassword",@"Message":@"Minimalist - Your password has been changed successfully.",@"ModifiedDate":@"0000-00-00 00:00:00"},@{@"EnumNo":@"14",@"EnumKey":@"emailBodyChangePassword",@"Message":@"Your username is %@<br>Your password is %@",@"ModifiedDate":@"0000-00-00 00:00:00"},@{@"EnumNo":@"15",@"EnumKey":@"newPasswordEmpty",@"Message":@"New password cannot be empty.",@"ModifiedDate":@"0000-00-00 00:00:00"},@{@"EnumNo":@"16",@"EnumKey":@"passwordEmpty",@"Message":@"Password cannot be empty.",@"ModifiedDate":@"0000-00-00 00:00:00"},@{@"EnumNo":@"17",@"EnumKey":@"passwordChanged",@"Message":@"Password has changed.",@"ModifiedDate":@"2015-08-11 11:23:49"},@{@"EnumNo":@"18",@"EnumKey":@"emailSubjectForgotPassword",@"Message":@"Minimalist - Your password is reset.",@"ModifiedDate":@"0000-00-00 00:00:00"},@{@"EnumNo":@"19",@"EnumKey":@"emailBodyForgotPassword",@"Message":@"Your username is %@<br>Your password is %@",@"ModifiedDate":@"0000-00-00 00:00:00"},@{@"EnumNo":@"20",@"EnumKey":@"forgotPasswordReset",@"Message":@"Mail sent",@"ModifiedDate":@"0000-00-00 00:00:00"},@{@"EnumNo":@"21",@"EnumKey":@"forgotPasswordMailSent",@"Message":@"Mail sent successfully",@"ModifiedDate":@"0000-00-00 00:00:00"},@{@"EnumNo":@"22",@"EnumKey":@"locationEmpty",@"Message":@"Location cannot be empty.",@"ModifiedDate":@"0000-00-00 00:00:00"},@{@"EnumNo":@"23",@"EnumKey":@"periodFromEmpty",@"Message":@"Period From cannot be empty.",@"ModifiedDate":@"0000-00-00 00:00:00"},@{@"EnumNo":@"24",@"EnumKey":@"periodToEmpty",@"Message":@"Period To cannot be empty.",@"ModifiedDate":@"0000-00-00 00:00:00"},@{@"EnumNo":@"25",@"EnumKey":@"deleteSubject",@"Message":@"Confirm delete",@"ModifiedDate":@"0000-00-00 00:00:00"},@{@"EnumNo":@"26",@"EnumKey":@"confirmDeleteUserAccount",@"Message":@"Delete user account",@"ModifiedDate":@"0000-00-00 00:00:00"},@{@"EnumNo":@"27",@"EnumKey":@"confirmDeleteEvent",@"Message":@"Delete event",@"ModifiedDate":@"0000-00-00 00:00:00"},@{@"EnumNo":@"28",@"EnumKey":@"periodToLessThanPeriodFrom",@"Message":@"Period to is less than Period from.",@"ModifiedDate":@"2015-07-27 01:01:50"},@{@"EnumNo":@"29",@"EnumKey":@"noEventChosenSubject",@"Message":@"No event chosen",@"ModifiedDate":@"2015-08-09 17:31:47"},@{@"EnumNo":@"30",@"EnumKey":@"noEventChosenDetail",@"Message":@"No event chosen, create event in Event menu",@"ModifiedDate":@"2015-08-09 17:31:47"},@{@"EnumNo":@"31",@"EnumKey":@"codeMismatch",@"Message":@"Code mismatch",@"ModifiedDate":@"2015-08-10 18:36:13"},@{@"EnumNo":@"32",@"EnumKey":@"passwordIncorrect",@"Message":@"Incorrect password",@"ModifiedDate":@"2015-08-10 20:46:06"},@{@"EnumNo":@"33",@"EnumKey":@"EmailIncorrect",@"Message":@"Incorrect email",@"ModifiedDate":@"2015-08-11 11:05:00"}];
    
    for (int i = 0; i < jsonArrayMessage.count; i++)
    {
        NSDictionary *jsonElement = jsonArrayMessage[i];
        
        InAppMessage *message = [[InAppMessage alloc] init];
        message.enumNo = jsonElement[@"EnumNo"];
        message.enumKey = jsonElement[@"EnumKey"];
        message.message = jsonElement[@"Message"];
        message.modifiedDate = jsonElement[@"ModifiedDate"];
        
        [arrItemMessage addObject:message];
    }
    globalMessage = arrItemMessage;
    
    
    [_homeModel downloadItems:dbMasterWithProgressBar];
}

- (void)downloadProgress:(float)percent
{
    progressBar.progress = percent;
//    NSLog([NSString stringWithFormat:@"%f",percent]);
}
-(void)itemsDownloaded:(NSArray *)items
{
    if([items count] == 0)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                       message:@"Application is expired"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action)
                                                                {
                                                                    
                                                                }];
        
        [alert addAction:defaultAction];
        dispatch_async(dispatch_get_main_queue(),^ {
            [self presentViewController:alert animated:YES completion:nil];
        } );
        return;
    }
    {
        PushSync *pushSync = [[PushSync alloc]init];
        pushSync.deviceToken = [Utility deviceToken];
        [_homeModel updateItems:dbPushSyncUpdateByDeviceToken withData:pushSync];
    }
    
    
    [Utility itemsDownloaded:items];
        
    [Utility setFinishLoadSharedData:YES];
    dispatch_async(dispatch_get_main_queue(),^ {
        [self performSegueWithIdentifier:@"segSignIn" sender:self];
    } );
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    
    progressBar.center = self.view.center;
    CGRect frame = progressBar.frame;
    frame.origin.y = self.view.frame.size.height-20;
    progressBar.frame = frame;
    [self.view addSubview:progressBar];
}

- (void)itemsFail
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[Utility getConnectionLostTitle]
                                                                   message:[Utility getConnectionLostMessage]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              if(![indicator isAnimating])
                                                              {
                                                                  [self loadingOverlayView];
                                                              }                                                              
                                                              [_homeModel downloadItems:dbMaster];
                                                          }];
    
    [alert addAction:defaultAction];
    dispatch_async(dispatch_get_main_queue(),^ {
        [self presentViewController:alert animated:YES completion:nil];
    } );
}

-(void) loadingOverlayView
{
    [indicator startAnimating];
    indicator.layer.zPosition = 1;
    indicator.alpha = 1;
    indicator.layer.zPosition = 1;
    
    
    // and just add them to navigationbar view
    [self.view addSubview:overlayView];
    [self.view addSubview:indicator];
//    [self.navigationController.view addSubview:overlayView];
//    [self.navigationController.view addSubview:indicator];
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
                                                          handler:^(UIAlertAction * action)
                                                        {
                                                            [_homeModel downloadItems:dbMasterWithProgressBar];
                                                        }];

    [alert addAction:defaultAction];
    dispatch_async(dispatch_get_main_queue(),^ {
        [self presentViewController:alert animated:YES completion:nil];
    } );
}


@end
