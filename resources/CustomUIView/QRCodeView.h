//
//  QRCodeView.h
//  SAIM_UPDATING
//
//  Created by Thidaporn Kijkamjai on 7/10/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRCodeView : UIView
@property (strong, nonatomic) UIView *vwPrint;
@property (strong, nonatomic) UIImageView *imgVwQRCode;
@property (strong, nonatomic) UILabel *lblProductName;
@property (strong, nonatomic) UILabel *lblColor;
@property (strong, nonatomic) UILabel *lblSize;
@property (strong, nonatomic) UILabel *lblPrice;
@end
