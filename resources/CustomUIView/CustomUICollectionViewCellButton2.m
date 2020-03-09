//
//  CustomUICollectionViewCell.m
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 8/8/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "CustomUICollectionViewCellButton2.h"

@implementation CustomUICollectionViewCellButton2
@synthesize label;
@synthesize buttonAdd;
@synthesize buttonInfo;
@synthesize buttonDetail;
@synthesize buttonDetail2;
@synthesize leftBorder;
@synthesize topBorder;
@synthesize rightBorder;
@synthesize bottomBorder;
@synthesize cellBackground;
@synthesize image;
@synthesize imageView;
@synthesize singleTap;
@synthesize textField;
@synthesize btnPrint;
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
        
        
        btnPrint = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        
        
        image = [[UIImage alloc]init];
        imageView = [[UIImageView alloc]init];
        singleTap = [[UITapGestureRecognizer alloc]init];
        
        label = [[UILabel alloc]init];
        
        label.textColor = [UIColor blackColor];
        label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];

        
        leftBorder = [[UIView alloc]init];
        topBorder = [[UIView alloc]init];
        rightBorder = [[UIView alloc]init];
        bottomBorder = [[UIView alloc]init];
        

        leftBorder.backgroundColor = [UIColor lightGrayColor];
        topBorder.backgroundColor = [UIColor lightGrayColor];
        rightBorder.backgroundColor = [UIColor lightGrayColor];
        bottomBorder.backgroundColor = [UIColor lightGrayColor];
        
        cellBackground = [[UIView alloc]init];
        
        
        ////
        textField = [[UITextField alloc]init];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
        [textField setKeyboardType:UIKeyboardTypeDefault];
    }
    
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
}
@end
