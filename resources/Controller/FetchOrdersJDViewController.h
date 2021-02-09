//
//  FetchOrdersJDViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/11/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import "CustomViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FetchOrdersJDViewController : CustomViewController
@property (strong, nonatomic) IBOutlet UITableView *tbvData;
- (IBAction)fetchOrder:(id)sender;
@end

NS_ASSUME_NONNULL_END
