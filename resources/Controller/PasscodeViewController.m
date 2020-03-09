//
//  PasscodeViewController.m
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/9/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "PasscodeViewController.h"
#import "UserAccountViewController.h"
#import "Utility.h"
#import "Setting.h"
#import "Login.h"

#import "SharedPushSync.h"
#import "PushSync.h"
#import "KeychainWrapper.h"


@interface PasscodeViewController (){
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
}
@end

@implementation PasscodeViewController
@synthesize txtPasscode;
@synthesize lblStatus;
@synthesize btnAccess;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
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
    
    
    txtPasscode.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtPasscode.secureTextEntry = YES;
    txtPasscode.delegate = self;
    

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    txtPasscode.text = [defaults stringForKey:@"passcode"];
    
    
    [self loadViewProcess];
}

- (void)loadViewProcess
{
}

- (BOOL)validateData
{
    txtPasscode.text = [Utility trimString:txtPasscode.text];
    NSString *passcode = [Utility setting:vPasscode];
    NSString *passcodeEnter = txtPasscode.text;
    NSUInteger fieldHash = [passcodeEnter hash];
    NSString *fieldString = [KeychainWrapper securedSHA256DigestHashForPIN:fieldHash];
    
    
    if(![passcode isEqualToString:fieldString])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invalid data"
                                                                       message:[Utility msg:incorrectPasscode]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
    }
    return YES;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:txtPasscode.text forKey:@"passcode"];
    
    if ([sender isEqual:btnAccess]) {
        if(![self validateData])
        {
            return NO;
        }
        
        //check device token ในระบบ ว่าตรงกับตัวเองมั๊ย ถ้าไม่ตรงให้ไป alert ที่อีกเครื่องหนึ่ง
        [Utility setModifiedUser:@"admin"];
        if(![[Utility setting:vAdminDeviceToken] isEqualToString:[Utility deviceToken]])
        {
            Setting *setting = [Utility getSetting:vAdminDeviceToken];
            setting.value = [Utility deviceToken];
            setting.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
            setting.modifiedUser = [Utility modifiedUser];
            [_homeModel updateItems:dbSettingDeviceToken withData:setting];
        }
        
        
        Login *login = [[Login alloc]init]; //ไม่มี model sharedLogin เก็บเป็น Log ไว้ดูเท่านั้น
        login.username = [Utility modifiedUser];
        login.status = @"1";
        login.deviceToken = [Utility deviceToken];
        [_homeModel insertItems:dbLogin withData:login];
        
        
        
//        Setting *setting = [Utility getSetting:vAdminEmail];
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        [defaults setObject:setting.value forKey:@"username"];
    }

    return YES;
}

- (void)itemsInserted
{
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [btnAccess sendActionsForControlEvents:UIControlEventTouchUpInside];
    return NO;
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

@end
