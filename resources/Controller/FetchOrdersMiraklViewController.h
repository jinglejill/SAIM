//
//  FetchOrdersMiraklViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 5/2/2564 BE.
//  Copyright © 2564 BE Thidaporn Kijkamjai. All rights reserved.
//

#import "CustomViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FetchOrdersMiraklViewController : CustomViewController
@property (strong, nonatomic) IBOutlet UITableView *tbvData;
- (IBAction)fetchOrder:(id)sender;
@end

NS_ASSUME_NONNULL_END
