//
//  AddUserAccountViewController.m
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/27/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "AddUserAccountViewController.h"
#import "Utility.h"
#import "SharedUserAccount.h"
//#import "KeychainWrapper.h"


@interface AddUserAccountViewController ()
{
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
}
@end

@implementation AddUserAccountViewController
@synthesize txtEmailAddress;
@synthesize txtPassword;
@synthesize btnAutoGeneratePassword;
@synthesize btnSave;
@synthesize btnBack;
@synthesize lblStatus;
@synthesize userAccount;

#pragma mark - Life Cycle method

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
}

- (void)loadView {
    [super loadView];
    // Do any additional setup after loading the view.
    
    {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);        
    }
        
    
    userAccount = [[UserAccount alloc]init];
    txtEmailAddress.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtEmailAddress.delegate = self;
    txtPassword.delegate = self;
    
    
    [btnAutoGeneratePassword addTarget:self action:@selector(autoGeneratePasswordButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self loadViewProcess];
}

-(void)loadViewProcess
{
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([sender isEqual:btnSave])
    {
        userAccount.userAccountID = [Utility getNextID:tblUserAccount];
        userAccount.username = txtEmailAddress.text;
        userAccount.password = txtPassword.text;
        userAccount.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
        userAccount.modifiedUser = [Utility modifiedUser];
    }
    else if([sender isEqual:btnBack])
    {
        userAccount = nil;
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    //validate username must be email
    if([sender isEqual:btnSave]){
        if(![self validateData])
        {
            return NO;
        }
    }
    return YES;
}

- (BOOL)validateData
{
    txtEmailAddress.text = [Utility trimString:txtEmailAddress.text];
    if(![Utility validateEmailWithString:txtEmailAddress.text])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invalid data"
                                                                       message:[Utility msg:emailInvalid]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    if([UserAccount checkUsernameExist:txtEmailAddress.text])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invalid data"
                                                                       message:[Utility msg:emailExisted]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    txtPassword.text = [Utility trimString:txtPassword.text];
    if([txtPassword.text isEqualToString:@""])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invalid data"
                                                                       message:[Utility msg:passwordEmpty]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    return YES;
}

- (void) autoGeneratePasswordButtonClicked
{
    txtPassword.text = [Utility randomStringWithLength:6];
}

//-(BOOL) checkUsernameExist
//{
//    UserAccount *userAccount = [UserAccount getUserAccountByUsername:txtEmailAddress.text];
//    if(!userAccount)
//    {
//        return NO;
//    }
//    return YES;
//}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [btnSave sendActionsForControlEvents:UIControlEventTouchUpInside];
    return NO;
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

@end
