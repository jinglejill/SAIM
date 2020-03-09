//
//  CustomUITableViewCell.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 9/7/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomUITableViewCell : UITableViewCell
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, readonly, strong) UILabel *textLabel;
@property (nonatomic, readonly, strong) UIImageView *imageView;
@property (nonatomic, readonly, strong) UIImage *renderedMark;
@end
