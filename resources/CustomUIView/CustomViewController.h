//
//  CustomViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/3/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"
#import "Utility.h"

NS_ASSUME_NONNULL_BEGIN

@interface CustomViewController : UIViewController<HomeModelProtocol,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (nonatomic,retain) HomeModel *homeModel;
@property (nonatomic,retain) UIActivityIndicatorView *indicator;
@property (nonatomic,retain) UIView *overlayView;


-(void)loadingOverlayView;
-(void)removeOverlayViews;
-(void)alertMessage:(NSString *)message title:(NSString *)title;
-(void)addDropShadow:(UIView *)view;
@end

NS_ASSUME_NONNULL_END
