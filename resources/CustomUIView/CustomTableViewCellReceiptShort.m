//
//  CustomTableViewCellReceiptShort.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 5/3/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import "CustomTableViewCellReceiptShort.h"

@implementation CustomTableViewCellReceiptShort

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
//    NSLog(@"reuse");
    self.lblProduct.text = @"";
    self.lblColor.text = @"";
    self.lblSize.text = @"";
    self.lblCash.text = @"";
    self.lblCredit.text = @"";
    self.lblTransfer.text = @"";
    self.lblProduct.textColor = [UIColor blackColor];
    self.lblProduct.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
    self.lblColor.textColor = [UIColor blackColor];
    self.lblColor.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
    self.lblSize.textColor = [UIColor blackColor];
    self.lblSize.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
    self.lblCash.textColor = [UIColor blackColor];
    self.lblCash.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
    self.lblCredit.textColor = [UIColor blackColor];
    self.lblCredit.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
    self.lblTransfer.textColor = [UIColor blackColor];
    self.lblTransfer.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
}
@end
