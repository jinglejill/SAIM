//
//  EventInventorySummaryPageViewController.h
//  SAIM_UPDATING
//
//  Created by Thidaporn Kijkamjai on 4/10/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"

@interface EventInventorySummaryPageViewController : UIViewController<UIPageViewControllerDataSource,HomeModelProtocol>
@property (strong, nonatomic) UIPageViewController *pageController;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnAllOrRemaining;
- (IBAction)allOrRemaining:(id)sender;
- (IBAction)compareInventory:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnCheck;


@end
