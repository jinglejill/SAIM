//
//  CustomUITableViewCell4.m
//  SAIM_UPDATING
//
//  Created by Thidaporn Kijkamjai on 7/9/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "CustomUITableViewCell4.h"

@implementation CustomUITableViewCell4
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        _vwPrint = [[UIView alloc]init];
        [self addSubview:_vwPrint];
        
        
        _lblProductName = [[UILabel alloc] init];
        _lblProductName.textColor = [UIColor blackColor];
        _lblProductName.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        _lblProductName.textAlignment = NSTextAlignmentCenter;
        _lblProductName.backgroundColor = [UIColor clearColor];
        _lblProductName.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:35];
        [_vwPrint addSubview:_lblProductName];
        
        
        _lblColor = [[UILabel alloc] init];
        _lblColor.textColor = [UIColor blackColor];
        _lblColor.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        _lblColor.textAlignment = NSTextAlignmentCenter;
        _lblColor.backgroundColor = [UIColor clearColor];
        _lblColor.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:35];
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
