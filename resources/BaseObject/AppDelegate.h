//
//  AppDelegate.h
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/7/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"
@import UserNotifications;


@interface AppDelegate : UIResponder <UIApplicationDelegate,HomeModelProtocol,UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIWindow *alertWindow;
@property (nonatomic, strong) UINavigationController *navController; //set navController in SigninViewController


@end

