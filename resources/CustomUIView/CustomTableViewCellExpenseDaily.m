//
//  CustomTableViewCellExpenseDaily.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/3/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import "CustomTableViewCellExpenseDaily.h"

@implementation CustomTableViewCellExpenseDaily

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

//    self.lblItem.text = @"";
//    self.lblAmount.text = @"";
    
    self.lblItem.textColor = [UIColor blackColor];
    self.lblItem.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    self.lblAmount.textColor = [UIColor blackColor];
    self.lblAmount.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    
}
@end
