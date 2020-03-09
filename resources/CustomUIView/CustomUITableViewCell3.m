//
//  CustomUITableViewCell3.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 2/29/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "CustomUITableViewCell3.h"

@implementation CustomUITableViewCell3
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSInteger margin = 20;//to show on screen margin = 20
        NSInteger imageWidth = 326;
        NSInteger textWidth = imageWidth - 2*20;//fixed text width
        
        
//        _vwPrint = [[UIView alloc]initWithFrame:CGRectMake(20, 0, 316, 374)];
        _vwPrint = [[UIView alloc]initWithFrame:CGRectMake(0, 0, imageWidth, 385)];
        [self addSubview:_vwPrint];
        
        
        
//        _lblHeaderAddress = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, 200, 21)];
        _lblHeaderAddress = [[UILabel alloc] initWithFrame:CGRectMake(margin, 8, textWidth, 21)];
//        _lblHeaderAddress = [[UILabel alloc] initWithFrame:CGRectMake(margin, 30, textWidth, 21)];
        _lblHeaderAddress.textColor = [UIColor blackColor];
        _lblHeaderAddress.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        _lblHeaderAddress.textAlignment = NSTextAlignmentLeft;
        _lblHeaderAddress.backgroundColor = [UIColor clearColor];
        _lblHeaderAddress.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
//        [_vwPrint addSubview:_lblHeaderAddress];
        
        
        
        _viewUnderline = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];//change size later to match the text
//        [_vwPrint addSubview:_viewUnderline];
        
        
        
        //        _txtVwAddress = [[UITextView alloc] initWithFrame:CGRectMake(0, 30, 310, 218)];
        _txtVwAddress = [[UITextView alloc] initWithFrame:CGRectMake(margin, 8, textWidth, 218)];
        _txtVwAddress.editable = NO;
        _txtVwAddress.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
        [_vwPrint addSubview:_txtVwAddress];

        
        
        
//        _lblRemark = [[UILabel alloc] initWithFrame:CGRectMake(0, 344, 300, 21)];
        _lblRemark = [[UILabel alloc] initWithFrame:CGRectMake(margin, 344, textWidth, 21)];
        _lblRemark.textColor = [UIColor blackColor];
        _lblRemark.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        _lblRemark.textAlignment = NSTextAlignmentLeft;
        _lblRemark.backgroundColor = [UIColor clearColor];
        _lblRemark.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
        [_vwPrint addSubview:_lblRemark];
 
    }
    return self;
}

@end
