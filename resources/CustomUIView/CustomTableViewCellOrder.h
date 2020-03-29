//
//  CustomTableViewCellOrder.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 16/3/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomTableViewCellOrder : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lblRowNo;
@property (strong, nonatomic) IBOutlet UIImageView *imgProduct;
@property (strong, nonatomic) IBOutlet UIButton *btnProduct;
@property (strong, nonatomic) IBOutlet UILabel *lblPrice;
@property (strong, nonatomic) IBOutlet UIButton *btnPost;
@property (strong, nonatomic) IBOutlet UILabel *lblReplace;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lblReplaceLeading;
@property (strong, nonatomic) IBOutlet UILabel *lblShip;
@property (strong, nonatomic) IBOutlet UILabel *lblDiscountValue;
@property (strong, nonatomic) IBOutlet UILabel *lblDiscountLabel;
@property (strong, nonatomic) IBOutlet UIView *overlayView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lblReplaceWidth;

@end

NS_ASSUME_NONNULL_END
