//
//  QRCodeView.m
//  SAIM_UPDATING
//
//  Created by Thidaporn Kijkamjai on 7/10/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "QRCodeView.h"

@implementation QRCodeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        NSInteger margin = frame.origin.x;//print on paper depend on printer size
//        NSInteger imageWidth = 326;
//        NSInteger textWidth = imageWidth - 2*20;//fixed text width
        
        
//        _vwPrint = [[UIView alloc]initWithFrame:CGRectMake(0, 0, imageWidth, 385)];
        _vwPrint = [[UIView alloc]initWithFrame:frame];
        [self addSubview:_vwPrint];
        
        
        
        //        _lblProductName = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, 200, 21)];
        _lblProductName = [[UILabel alloc] init];
        _lblProductName.textColor = [UIColor blackColor];
        _lblProductName.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        _lblProductName.textAlignment = NSTextAlignmentCenter;
        _lblProductName.backgroundColor = [UIColor clearColor];
        _lblProductName.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:45];
        [_vwPrint addSubview:_lblProductName];
        
        
        _lblColor = [[UILabel alloc] init];
        _lblColor.textColor = [UIColor blackColor];
        _lblColor.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        _lblColor.textAlignment = NSTextAlignmentCenter;
        _lblColor.backgroundColor = [UIColor clearColor];
        _lblColor.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:45];
        [_vwPrint addSubview:_lblColor];
        
        
        _lblSize = [[UILabel alloc] init];
        _lblSize.textColor = [UIColor blackColor];
        _lblSize.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        _lblSize.textAlignment = NSTextAlignmentCenter;
        _lblSize.backgroundColor = [UIColor clearColor];
        _lblSize.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:55];
        [_vwPrint addSubview:_lblSize];
        
        
        _lblPrice = [[UILabel alloc] init];
        _lblPrice.textColor = [UIColor blackColor];
        _lblPrice.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        _lblPrice.textAlignment = NSTextAlignmentCenter;
        _lblPrice.backgroundColor = [UIColor clearColor];
        _lblPrice.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:25];
        [_vwPrint addSubview:_lblPrice];
        
        
        _imgVwQRCode =[[UIImageView alloc] init];
        [_vwPrint addSubview:_imgVwQRCode];
    }
    return self;
}
@end
