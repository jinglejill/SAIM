//
//  FetchOrdersLazadaViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 18/5/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import "CustomViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FetchOrdersLazadaViewController : CustomViewController
@property (strong, nonatomic) IBOutlet UITableView *tbvData;
- (IBAction)fetchOrder:(id)sender;


@end

NS_ASSUME_NONNULL_END
