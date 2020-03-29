//
//  Receipt2ViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 16/3/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import "CustomViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface Receipt2ViewController : CustomViewController
- (IBAction)unwindToReceipt2:(UIStoryboardSegue *)segue;
@property (strong, nonatomic) IBOutlet UITableView *tbvOrder;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tbvOrderHeight;
@property (strong, nonatomic) IBOutlet UITableView *tbvPay;
@end

NS_ASSUME_NONNULL_END