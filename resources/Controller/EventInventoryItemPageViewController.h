//
//  EventInventoryItemPageViewController.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 8/29/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

//#import "ViewController.h"
#import "HomeModel.h"

@interface EventInventoryItemPageViewController : UIViewController
<UIPageViewControllerDataSource,HomeModelProtocol,UIScrollViewDelegate>
@property (strong, nonatomic) UIPageViewController *pageController;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnAllOrRemaining;
- (IBAction)allOrRemaining:(id)sender;
- (IBAction)deleteAllProductInEvent:(id)sender;
@end
