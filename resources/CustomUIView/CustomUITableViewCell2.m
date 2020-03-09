//
//  CustomUITableViewCell2.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/27/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "CustomUITableViewCell2.h"

@implementation CustomUITableViewCell2
@synthesize textField;
@synthesize textLabel;
@synthesize imageView;
@synthesize rightBorder;
@synthesize textNewLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //label
        textLabel = [[UILabel alloc]init];
        textLabel.frame = CGRectMake(20.0f, 0.0f, 160.0f, 44.0f);
        textLabel.backgroundColor = [UIColor clearColor];
        
        //arrow
        imageView = [[UIImageView alloc]init];
        imageView.image = [UIImage imageNamed:@"show2.png"];
        imageView.userInteractionEnabled = YES;
        NSInteger imageSize = 26;
        imageView.frame = CGRectMake(130.0f, 9.0f, imageSize, imageSize);
        [self addSubview:imageView];
        
        //border
        rightBorder = [[UIView alloc]init];
        rightBorder.backgroundColor = [UIColor lightGrayColor];
        rightBorder.frame = CGRectMake(160, 0, 1, self.bounds.size.height);
        [self addSubview:rightBorder];
        
        
        float controlWidth = 150;//cell.c tableView.bounds.size.width - 15*2;//minus left, right margin
        float controlXOrigin = 151;//15;
        float controlYOrigin = (44 - 25)/2;//table row height minus control height and set vertical center
        textField = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, 25.0f)];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
        [textField setKeyboardType:UIKeyboardTypeDecimalPad];
        [self addSubview:textField];
        
        
        textNewLabel = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, controlYOrigin, 90.0f, 25.0f)];
        textNewLabel.clearButtonMode = UITextFieldViewModeWhileEditing;
        textNewLabel.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
        [textNewLabel setKeyboardType:UIKeyboardTypeDecimalPad];
//        [self addSubview:textNewLabel];
    }
    return self;
}
@end
