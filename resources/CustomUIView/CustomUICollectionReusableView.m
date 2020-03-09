//
//  CustomUICollectionReusableView.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 8/27/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "CustomUICollectionReusableView.h"

@implementation CustomUICollectionReusableView
@synthesize label;
@synthesize label2;
@synthesize label3;
@synthesize label4;
@synthesize label5;
@synthesize labelAlignRight;
@synthesize labelAlignRight2;
@synthesize labelAlignRight3;
@synthesize labelAlignRight4;
@synthesize labelAlignRight5;
@synthesize viewUnderline;
@synthesize viewUnderlineLeft;
@synthesize button;
@synthesize imgView;
@synthesize singleTap;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        label = [[UILabel alloc]init];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
        
        label2 = [[UILabel alloc]init];
        label2.textColor = [UIColor blackColor];
        label2.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
        
        
        label3 = [[UILabel alloc]init];
        label3.textColor = [UIColor blackColor];
        label3.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
        
        
        label4 = [[UILabel alloc]init];
        label4.textColor = [UIColor blackColor];
        label4.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
        
        
        label5 = [[UILabel alloc]init];
        label5.textColor = [UIColor blackColor];
        label5.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
        
        
        labelAlignRight = [[UILabel alloc]init];
        labelAlignRight.textColor = [UIColor blackColor];
        labelAlignRight.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
        
        
        labelAlignRight2 = [[UILabel alloc]init];
        labelAlignRight2.textColor = [UIColor blackColor];
        labelAlignRight2.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
        
        
        labelAlignRight3 = [[UILabel alloc]init];
        labelAlignRight3.textColor = [UIColor blackColor];
        labelAlignRight3.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
        
        
        labelAlignRight4 = [[UILabel alloc]init];
        labelAlignRight4.textColor = [UIColor blackColor];
        labelAlignRight4.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
        
        
        labelAlignRight5 = [[UILabel alloc]init];
        labelAlignRight5.textColor = [UIColor blackColor];
        labelAlignRight5.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
        
        
        viewUnderline = [[UIView alloc]init];
        viewUnderlineLeft = [[UIView alloc]init];
        
        
        button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        imgView = [[UIImageView alloc]init];        
        
        
        singleTap = [[UITapGestureRecognizer alloc]init];
    }
    return self;
}
@end
