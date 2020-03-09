//
//  ChangePasscodeViewController.m
//  SAIM_UPDATING
//
//  Created by Thidaporn Kijkamjai on 4/30/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "ChangePasscodeViewController.h"
#import "Utility.h"
#import "Setting.h"

#import "SharedPushSync.h"
#import "PushSync.h"
#import "KeychainWrapper.h"

@interface ChangePasscodeViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
}
@end

@implementation ChangePasscodeViewController
@synthesize txtRegisteredEmail;
@synthesize txtOldPassword;
@synthesize txtNewPassword;
@synthesize txtReEnterNewPassword;
@synthesize btnSave;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
}

- (void)loadView
{
    [super loadView];
    
    // Create new HomeModel object and assign it to _homeModel variable
    _homeModel = [[HomeModel alloc] init];
    _homeModel.delegate = self;
    
    {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);
    }
    
    
    [Utility setModifiedUser:[NSString stringWithFormat:@"Not define yet, page: %@",NSStringFromClass([self class])]];
    txtRegisteredEmail.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtRegisteredEmail.delegate = self;
    txtRegisteredEmail.tag = kTextFieldRegisterEamil;
    
    txtOldPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtOldPassword.secureTextEntry = YES;
    txtOldPassword.delegate = self;
    
    txtNewPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtNewPassword.secureTextEntry = YES;
    txtNewPassword.delegate = self;
    
    txtReEnterNewPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtReEnterNewPassword.secureTextEntry = YES;
    txtReEnterNewPassword.delegate = self;
    
    [btnSave addTarget:self action:@selector(saveNewPasswordButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self loadViewProcess];
}

- (void)loadViewProcess
{
    txtRegisteredEmail.text = [Utility setting:vAdminEmail];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [btnSave sendActionsForControlEvents:UIControlEventTouchUpInside];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //เก็บ section กับ item ใส่ค่า textfield.text (key = [section,item], value = textfield.text)
//    NSInteger tag = textField.tag;
    if(textField.tag == kTextFieldRegisterEamil)
    {
        //validate
        textField.text = [Utility trimString:textField.text];
        if(![Utility validateEmailWithString:textField.text])
        {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invalid"
                                                                           message:@"Email is invalid"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                    
                                                                  }];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            
            
            return;
        }
        
        
        //homemodel update
        Setting *setting = [Utility getSetting:vAdminEmail];
        setting.value = textField.text;
        setting.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
        setting.modifiedUser = [Utility modifiedUser];
        [_homeModel updateItems:dbSetting withData:setting];
        
    }
}

- (BOOL)validateData
{
    //Wrong old password
    txtOldPassword.text = [Utility trimString:txtOldPassword.text];
    if([self wrongPassword])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invalid data"
                                                                       message:@"Wrong old passcode"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    
    txtNewPassword.text = [Utility trimString:txtNewPassword.text];
    if([txtNewPassword.text isEqualToString:@""])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invalid data"
                                                                       message:@"New passcode cannot be empty"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    //New passwords does not match.
    if(![self newPasswordMatch])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invalid data"
                                                                       message:@"New passcodes do not match"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    
    return YES;
}

-(BOOL)wrongPassword
{
    NSString *oldPasscode = txtOldPassword.text;
    NSUInteger fieldHash = [oldPasscode hash];
    NSString *fieldString = [KeychainWrapper securedSHA256DigestHashForPIN:fieldHash];
    if([[Utility setting:vPasscode] isEqualToString:fieldString])
    {
        return NO;
    }
    return YES;
}

-(BOOL)newPasswordMatch
{
    NSString *password1 = [Utility trimString:txtNewPassword.text];
    NSString *password2 = [Utility trimString:txtReEnterNewPassword.text];
    if([password1 isEqualToString:password2])
    {
        return YES;
    }
    return NO;
}

-(void) saveNewPasswordButtonClicked
{
    if(![self validateData])
    {
        return;
    }
    
    
    //save
    //update admin passcode
    {
        NSString *newPasscode = txtNewPassword.text;
        NSUInteger fieldHash = [newPasscode hash];
        NSString *fieldString = [KeychainWrapper securedSHA256DigestHashForPIN:fieldHash];
        
        
        Setting *setting = [Utility getSetting:vPasscode];
        setting.value = fieldString;
        setting.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
        setting.modifiedUser = [Utility modifiedUser];
        [_homeModel updateItems:dbSetting withData:setting];
    }
    
    //update admin email
    {
        Setting *setting = [Utility getSetting:vAdminEmail];
        setting.value = [Utility trimString:txtRegisteredEmail.text];
        setting.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
        setting.modifiedUser = [Utility modifiedUser];
        [_homeModel updateItems:dbSetting withData:setting];       
    }
    

    
    //send email
    NSString *subject =[NSString stringWithFormat:@"%@ - Your passcode has been changed successfully.",[Utility makeFirstLetterUpperCaseOtherLower:[Utility dbName]]];
    NSString *body = [NSString stringWithFormat:@"Your new passcode is %@", txtNewPassword.text];
    [_homeModel sendEmail:txtRegisteredEmail.text withSubject:subject andBody:body];//txtRegisteredEmail
    
    
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Passcode has changed"
                                                                   message:@"Your passcode has been changed successfully." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action){
                                                              [self.navigationController popViewControllerAnimated:YES];
                                                          }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)emailSent
{
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

- (IBAction)resetPasscode:(id)sender {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:
     [UIAlertAction actionWithTitle:@"Are you sure you want to reset passcode?"
                              style:UIAlertActionStyleDestructive
                            handler:^(UIAlertAction *action) {
                                
                                //reset passcode
                                [self resetPasscode];
                            }]];
    [alert addAction:
     [UIAlertAction actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleCancel
                            handler:^(UIAlertAction *action) {}]];
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void)resetPasscode
{
    NSString *newPasscode = [Utility randomStringWithLength:6];
    NSUInteger fieldHash = [newPasscode hash];
    NSString *fieldString = [KeychainWrapper securedSHA256DigestHashForPIN:fieldHash];
    //update admin passcode
    {
        Setting *setting = [Utility getSetting:vPasscode];
        setting.value = fieldString;//--->sha hash
        setting.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
        setting.modifiedUser = [Utility modifiedUser];
        [_homeModel updateItems:dbSetting withData:setting];
    }
    
    //send email
    NSString *subject =[NSString stringWithFormat:@"%@ - Your passcode has been reset successfully.",[Utility makeFirstLetterUpperCaseOtherLower:[Utility dbName]]];
    NSString *body = [NSString stringWithFormat:@"Your new passcode is %@", newPasscode];
    [_homeModel sendEmail:[Utility setting:vAdminEmail] withSubject:subject andBody:body];
    
    

    
    NSString *msg = [NSString stringWithFormat:@"Passcode is reset successfully, new passcode is sent to your email: %@",[Utility setting:vAdminEmail]];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action){
                                                              [self.navigationController popViewControllerAnimated:YES];
                                                          }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
