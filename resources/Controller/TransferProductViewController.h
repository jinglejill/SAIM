//
//  TransferProductViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 9/7/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"

@interface TransferProductViewController : UITableViewController<HomeModelProtocol>
- (IBAction)unwindToTransferProduct:(UIStoryboardSegue *)segue;
- (IBAction)transferProduct:(id)sender;
@end
