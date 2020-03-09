//
//  CustomUICollectionViewCell.h
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 8/8/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
//เพิ่ม bg,textfield,button

@interface CustomUICollectionViewCellButton2 : UICollectionViewCell
@property (strong,nonatomic) UILabel *label;
@property (strong,nonatomic) UIButton *buttonAdd;
@property (strong,nonatomic) UIButton *buttonInfo;
@property (strong,nonatomic) UIButton *buttonDetail;
@property (strong,nonatomic) UIButton *buttonDetail2;
@property (strong,nonatomic) UIView *leftBorder;
@property (strong,nonatomic) UIView *topBorder;
@property (strong,nonatomic) UIView *rightBorder;
@property (strong,nonatomic) UIView *bottomBorder;
@property (strong,nonatomic) UIView *cellBackground;
@property (strong,nonatomic) UITapGestureRecognizer *singleTap;
@property (strong,nonatomic) UIImage *image;
@property (strong,nonatomic) UIImageView *imageView;
@property (nonatomic, readonly, strong) UITextField *textField;
@property (strong,nonatomic) UIButton *btnPrint;

@end
