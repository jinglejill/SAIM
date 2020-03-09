//
//  RootViewController.m
//  DBRoulette
//
//  Created by Brian Smith on 6/29/10.
//  Copyright Dropbox, Inc. 2010. All rights reserved.
//

#import "RootViewController.h"
#import <DropboxSDK/DropboxSDK.h>


@interface RootViewController ()

- (void)updateButtons;

@end


@implementation RootViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        self.title = @"Link Account";
    }
    return self;
}

- (void)didPressLink {
    if (![[DBSession sharedSession] isLinked]) {
		[[DBSession sharedSession] linkFromController:self];
    } else {
        [[DBSession sharedSession] unlinkAll];
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Account Unlinked!"
                                                                       message:@"Your dropbox account has been unlinked"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        
        [self updateButtons];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateButtons];
    if([[DBSession sharedSession] isLinked])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                       message:@"Log in dropbox successful"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  //back to admin menu
                                                                  [self.navigationController popViewControllerAnimated:YES];
                                                              }];
        
        [alert addAction:defaultAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Link Account";
}

- (void)viewDidUnload {
    linkButton = nil;
}

- (void)dealloc {

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return toInterfaceOrientation == UIInterfaceOrientationPortrait;
    } else {
        return YES;
    }
}


#pragma mark private methods

@synthesize linkButton;
//@synthesize photoViewController;

- (void)updateButtons {
    NSString* title = [[DBSession sharedSession] isLinked] ? @"Unlink Dropbox" : @"Link Dropbox";
    [linkButton setTitle:title forState:UIControlStateNormal];
    
    self.navigationItem.rightBarButtonItem.enabled = [[DBSession sharedSession] isLinked];
}

@end

