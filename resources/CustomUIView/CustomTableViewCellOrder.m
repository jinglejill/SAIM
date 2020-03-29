//
//  CustomTableViewCellOrder.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 16/3/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import "CustomTableViewCellOrder.h"

@implementation CustomTableViewCellOrder

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.imgProduct.image = nil;
    self.lblReplaceWidth.constant = 47.5;
    self.lblReplaceLeading.constant = 8;
}
@end
