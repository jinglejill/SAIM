//
//  ChangePasswordViewController.m
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/9/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "SignInViewController.h"
#import "Utility.h"
#import "UserAccount.h"


#import "SharedUserAccount.h"
#import "SharedPushSync.h"
#import "PushSync.h"
#import "KeychainWrapper.h"


@interface ChangePasswordViewController()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    UserAccount *_userAccount;
    NSString *_designatedPassword;
}
@end

@implementation ChangePasswordViewController
@synthesize txtRegisteredEmail;
@synthesize txtOldPassword;
@synthesize txtNewPassword;
@synthesize txtReEnterNewPassword;
@synthesize btnSave;
//@synthesize lblStatus;

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
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [btnSave sendActionsForControlEvents:UIControlEventTouchUpInside];
    return NO;
}

- (BOOL)validateData
{
    //Wrong registered email
    if([self wrongEmail])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invalid data"
                                                                       message:[Utility msg:wrongEmail]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    //Wrong old password
    txtOldPassword.text = [Utility trimString:txtOldPassword.text];
    if([self wrongPassword])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invalid data"
                                                                       message:[Utility msg:wrongPassword]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];

        return NO;
    }
    if([[Utility trimString:txtNewPassword.text] isEqualToString:@""])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invalid data"
                                                                       message:[Utility msg:newPasswordEmpty]
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
                                                                       message:[Utility msg:newPasswordNotMatch]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    
    return YES;
}

-(BOOL)wrongEmail
{
    txtRegisteredEmail.text = [Utility trimString:txtRegisteredEmail.text];
    NSString *email = txtRegisteredEmail.text;
    for(UserAccount *userAccount in [SharedUserAccount sharedUserAccount].userAccountList)
    {
        if([userAccount.username isEqualToString:email])
        {
            _designatedPassword = userAccount.password;
            NSLog(@"designate password: %@",_designatedPassword);
            return NO;
        }
    }
    return YES;
}

-(BOOL)wrongPassword
{
    NSString *oldPassword = txtOldPassword.text;
    NSUInteger fieldHash = [oldPassword hash];
    NSString *fieldString = [KeychainWrapper securedSHA256DigestHashForPIN:fieldHash];
    if([_designatedPassword isEqualToString:fieldString])
    {
        return NO;
    }
    return YES;
}

-(BOOL)newPasswordMatch
{
    txtNewPassword.text = [Utility trimString:txtNewPassword.text];
    txtReEnterNewPassword.text = [Utility trimString:txtReEnterNewPassword.text];
    NSString *password1 = txtNewPassword.text;
    NSString *password2 = txtReEnterNewPassword.text;
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
    
    
    
    NSString *newPassword = txtNewPassword.text;
    NSUInteger fieldHash = [newPassword hash];
    NSString *fieldString = [KeychainWrapper securedSHA256DigestHashForPIN:fieldHash];
    
    
    _userAccount = [UserAccount getUserAccountByUsername:txtRegisteredEmail.text];
    _userAccount.password = fieldString;
    _userAccount.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
    _userAccount.modifiedUser = [Utility modifiedUser];
    [_homeModel updateItems:dbUserAccount withData:_userAccount];
    

    
    //send email
    NSString *subject =[NSString stringWithFormat:[Utility msg:emailSubjectChangePassword]];
    NSString *body = [NSString stringWithFormat:[Utility msg:emailBodyChangePassword],_userAccount.username, newPassword];
    [_homeModel sendEmail:_userAccount.username withSubject:subject andBody:body];
    
    
    // This delegate method will get called when the items are finished downloading
    NSLog(@"email sent successfully");
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[Utility msg:passwordChanged]
                                                                   message:[Utility msg:changePasswordSuccess] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action){
                                                              [self.navigationController popViewControllerAnimated:YES];
                                                          }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)itemsUpdated
{
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

@end
