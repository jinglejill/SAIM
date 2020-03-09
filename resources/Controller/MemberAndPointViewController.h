//
//  MemberAndPointViewController.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 2/19/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"
#import <MessageUI/MFMailComposeViewController.h>


@interface MemberAndPointViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,HomeModelProtocol>//,MFMailComposeViewControllerDelegate
@property (strong, nonatomic) IBOutlet UICollectionView *colViewData;
//- (IBAction)sendEmail:(id)sender;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end
