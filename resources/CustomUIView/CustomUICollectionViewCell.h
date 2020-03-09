//
//  CustomUICollectionViewCell.h
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 8/8/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomUICollectionViewCell : UICollectionViewCell
@property (strong,nonatomic) UILabel *label;
@property (strong,nonatomic) UIButton *buttonAdd;
@property (strong,nonatomic) UIButton *buttonInfo;
@property (strong,nonatomic) UIButton *buttonDetail;

@end
