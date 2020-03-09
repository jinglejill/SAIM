//
//  CompareInventoryPageViewController.h
//  SAIM_UPDATING
//
//  Created by Thidaporn Kijkamjai on 4/10/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"


@interface CompareInventoryPageViewController : UIViewController<UIPageViewControllerDataSource, HomeModelProtocol>
@property (strong, nonatomic) UIPageViewController *pageController;
- (IBAction)unwindToCompareInventoryPage:(UIStoryboardSegue *)segue;

@end
