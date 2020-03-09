//
//  CustomUICollectionViewCellButton.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 8/26/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomUICollectionViewCellButton : UICollectionViewCell
@property (strong,nonatomic) UILabel *label;
@property (strong,nonatomic) UITapGestureRecognizer *singleTap;
@property (strong,nonatomic) UIImage *image;
@property (strong,nonatomic) UIImageView *imageView;
@property (strong,nonatomic) UIView *leftBorder;
@property (strong,nonatomic) UIView *topBorder;
@property (strong,nonatomic) UIView *rightBorder;
@property (strong,nonatomic) UIView *bottomBorder;



@end
