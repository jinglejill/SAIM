//
//  FirstPageViewController.h
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/22/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"
#import "ChristmasConstants.h"

@interface FirstPageViewController : UIViewController<HomeModelProtocol,NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate,UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imgVw;
@property (nonatomic, strong) UIProgressView *progressBar;
@property (nonatomic) BOOL pinValidated;
@end
