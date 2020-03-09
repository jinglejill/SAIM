//
//  CustomUICollectionViewCellButton3.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 9/30/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "CustomUICollectionViewCellButton3.h"

@implementation CustomUICollectionViewCellButton3
@synthesize label;
@synthesize buttonAdd;
@synthesize buttonInfo;
@synthesize buttonDetail;
@synthesize buttonDetail2;
@synthesize leftBorder;
@synthesize topBorder;
@synthesize rightBorder;
@synthesize bottomBorder;
@synthesize image;
@synthesize imageView;
@synthesize singleTap;
@synthesize image2;
@synthesize imageView2;
@synthesize singleTap2;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        buttonAdd = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [buttonAdd sizeToFit];
        
        buttonInfo = [UIButton buttonWithType:UIButtonTypeInfoLight];
        [buttonInfo sizeToFit];
        
        buttonDetail = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [buttonDetail sizeToFit];
        
        buttonDetail2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [buttonDetail2 sizeToFit];
        
        image = [[UIImage alloc]init];
        imageView = [[UIImageView alloc]init];
        singleTap = [[UITapGestureRecognizer alloc]init];
        
        image2 = [[UIImage alloc]init];
        imageView2 = [[UIImageView alloc]init];
        singleTap2 = [[UITapGestureRecognizer alloc]init];
        
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
