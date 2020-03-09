
//
//  SignInViewController.m
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/29/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "SignInViewController.h"
#import "ChangePasswordViewController.h"
#import "ForgotPasswordViewController.h"
#import "AdminMenuViewController.h"
#import "Utility.h"
#import "EventSelectionViewController.h"
#import "AppDelegate.h"
#import "Login.h"
#import "SharedPushSync.h"
#import "PushSync.h"
#import "KeychainWrapper.h"


@interface SignInViewController()
{
    UserAccount *_userAccount;
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
}
@end

@implementation SignInViewController

@synthesize btnSignIn;
@synthesize btnForgotPassword;
@synthesize btnChangePassword;

@synthesize txtEmailAddress;
@synthesize txtPassword;
//@synthesize userAccount;
@synthesize lblStatus;



-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [btnSignIn sendActionsForControlEvents:UIControlEventTouchUpInside];
    return NO;
}

- (IBAction)unwindToSignIn:(UIStoryboardSegue *)segue
{
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
    
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.navController = self.navigationController;
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    txtEmailAddress.text = [defaults stringForKey:@"username"];
    txtPassword.text = @"";
    
    
    txtEmailAddress.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtEmailAddress.delegate = self;
    
    txtPassword.secureTextEntry = YES;
    txtPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtPassword.delegate = self;
    [self loadViewProcess];
}

- (void)loadViewProcess
{
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
}

- (void)itemsInserted
{
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
            
            [Utility itemsSynced:type action:action data:data];
        }


}


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    //validate username must be email
    if([sender isEqual:btnSignIn])
    {
        if(![self validateData])
        {
            return NO;
        }
        
        
        [Utility setModifiedUser:txtEmailAddress.text];
        [self doLoginProcess];
    }
    return YES;
}


- (void)doLoginProcess
{
    //check device token ในระบบ ว่าตรงกับตัวเองมั๊ย ถ้าไม่ตรงให้ไป alert ที่อีกเครื่องหนึ่ง
    if(![[Utility getDeviceTokenFromUsername:[Utility modifiedUser]] isEqualToString:[Utility deviceToken]])
    {
        UserAccount *userAccount = [UserAccount getUserAccountByUsername:[Utility modifiedUser]];
        userAccount.deviceToken = [Utility deviceToken];
        userAccount.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
        userAccount.modifiedUser = [Utility modifiedUser];
        
        [_homeModel updateItems:dbUserAccountDeviceToken withData:userAccount];
    }
    
    Login *login = [[Login alloc]init];
    login.username = [Utility modifiedUser];
    login.status = @"1";
    login.deviceToken = [Utility deviceToken];
    [_homeModel insertItems:dbLogin withData:login];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([sender isEqual:btnSignIn])
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:txtEmailAddress.text forKey:@"username"];
        
        
        EventSelectionViewController *vc = segue.destinationViewController;
        vc.username = [txtEmailAddress.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
}


- (BOOL)validateData
{
    txtEmailAddress.text = [Utility trimString:txtEmailAddress.text];
    txtPassword.text = [Utility trimString:txtPassword.text];
    
    if(![UserAccount checkUsernameExist:txtEmailAddress.text])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invalid data"
                                                                       message:[Utility msg:emailIncorrect]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    if(![self checkPassword])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invalid data"
                                                                       message:[Utility msg:passwordIncorrect]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    
    return YES;
}

-(BOOL) checkPassword
{
    NSString *password = txtPassword.text;
    NSUInteger fieldHash = [password hash];
    NSString *fieldString = [KeychainWrapper securedSHA256DigestHashForPIN:fieldHash];
    
    
    UserAccount *userAccount = [UserAccount getUserAccountByUsername:txtEmailAddress.text];
    if([userAccount.password isEqualToString:fieldString])
    {
        return YES;
    }
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
