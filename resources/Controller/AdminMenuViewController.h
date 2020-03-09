//
//  AdminMenuViewController.h
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/29/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APLSectionHeaderView.h"
#import "Homemodel.h"
#import <DropboxSDK/DropboxSDK.h>


@interface AdminMenuViewController : UITableViewController<SectionHeaderViewDelegate,HomeModelProtocol,DBSessionDelegate,DBNetworkRequestDelegate,DBRestClientDelegate>
{
    UIImageView* imageView;
    UIButton* nextButton;
    UIActivityIndicatorView* activityIndicator;
    
    
    BOOL working;
    DBRestClient* restClient;
}


@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnSignIn;
- (IBAction)unwindToAdminMenu:(UIStoryboardSegue *)segue;

@property (nonatomic) NSInteger openSectionIndex;
@property (nonatomic) NSMutableArray *sectionInfoArray;


- (void)setWorking:(BOOL)isWorking;

@property (nonatomic, readonly) DBRestClient* restClient;

@end
