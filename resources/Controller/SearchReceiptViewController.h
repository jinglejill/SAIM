//
//  SearchReceiptViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 7/4/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import "CustomViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SearchReceiptViewController : CustomViewController
@property (strong, nonatomic) IBOutlet UITextField *txtReceiptNoSearch;
@property (strong, nonatomic) IBOutlet UIButton *btnSearch;
@property (strong, nonatomic) IBOutlet UITableView *tbvData;
- (IBAction)searchReceipt:(id)sender;
- (IBAction)unwindToSearchReceipt:(UIStoryboardSegue *)segue;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segConChannel;
- (IBAction)segConChannelValueChanged:(id)sender;
@end

NS_ASSUME_NONNULL_END
