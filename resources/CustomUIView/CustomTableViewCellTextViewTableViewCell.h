//
//  CustomTableViewCellTextViewTableViewCell.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/11/2564 BE.
//  Copyright © 2564 BE Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomUITextView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CustomTableViewCellTextViewTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet CustomUITextView *textView;

@end

NS_ASSUME_NONNULL_END
