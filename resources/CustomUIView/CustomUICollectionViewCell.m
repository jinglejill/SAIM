//
//  CustomUICollectionViewCell.m
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 8/8/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "CustomUICollectionViewCell.h"

@implementation CustomUICollectionViewCell
@synthesize label;
@synthesize buttonAdd;
@synthesize buttonInfo;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        buttonAdd = [UIButton buttonWithType:UIButtonTypeContactAdd];
        buttonAdd.frame = self.bounds;

        buttonInfo = [UIButton buttonWithType:UIButtonTypeInfoLight];
        buttonInfo.frame = self.bounds;
        
        label = [[UILabel alloc]init];
        label.frame = self.bounds;
        
        label.textColor = [UIColor blackColor];
        label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
        label.textAlignment = NSTextAlignmentCenter;
        
        
        UIView *leftBorder = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.origin.x
                                                                     , self.bounds.origin.y, 1, self.bounds.size.height)];
        
        UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.origin.x
                                                                        , self.bounds.origin.y, self.bounds.size.width, 1)];
        
        UIView *rightBorder = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.origin.x+self.bounds.size.width
                                                                      , self.bounds.origin.y, 1, self.bounds.size.height)];
        
        UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.origin.x
                                                                     , self.bounds.origin.y+self.bounds.size.height, self.bounds.size.width, 1)];
        leftBorder.backgroundColor = [UIColor lightGrayColor];
        topBorder.backgroundColor = [UIColor lightGrayColor];
        rightBorder.backgroundColor = [UIColor lightGrayColor];
        bottomBorder.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:leftBorder];
        [self.contentView addSubview:topBorder];
        [self.contentView addSubview:rightBorder];
        [self.contentView addSubview:bottomBorder];
    }
    
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
//    self.label = nil;
}
@end
