//
//  RootViewController.h
//  DBRoulette
//
//  Created by Brian Smith on 6/29/10.
//  Copyright Dropbox, Inc. 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBRestClient;


@interface RootViewController : UIViewController {
    UIButton* linkButton;
//    UIViewController* photoViewController;
	DBRestClient* restClient;
}

- (IBAction)didPressLink;

@property (nonatomic, retain) IBOutlet UIButton* linkButton;
//@property (nonatomic, retain) UIViewController* photoViewController;

@end
