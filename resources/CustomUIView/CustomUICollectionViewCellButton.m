//
//  CustomUICollectionViewCellButton.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 8/26/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "CustomUICollectionViewCellButton.h"
@implementation CustomUICollectionViewCellButton
@synthesize label;
//@synthesize button;
@synthesize leftBorder;
@synthesize topBorder;
@synthesize rightBorder;
@synthesize bottomBorder;
//@synthesize buttonDetail;
@synthesize image;
@synthesize imageView;
@synthesize singleTap;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
//        button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        [button sizeToFit]; 
//        buttonDetail = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        [buttonDetail sizeToFit];
        image = [[UIImage alloc]init];
        imageView = [[UIImageView alloc]init];
        singleTap = [[UITapGestureRecognizer alloc]init];
        
        
        label = [[UILabel alloc]init];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
        label.textAlignment = NSTextAlignmentCenter;
        
        leftBorder = [[UIView alloc]init];
        topBorder = [[UIView alloc]init];
        rightBorder = [[UIView alloc]init];
        bottomBorder = [[UIView alloc]init];

        leftBorder.backgroundColor = [UIColor lightGrayColor];
        topBorder.backgroundColor = [UIColor lightGrayColor];
        rightBorder.backgroundColor = [UIColor lightGrayColor];
        bottomBorder.backgroundColor = [UIColor lightGrayColor];
    }
    
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
}
@end
