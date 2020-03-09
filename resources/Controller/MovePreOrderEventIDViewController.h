//
//  MovePreOrderEventIDViewController.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 8/2/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"


@interface MovePreOrderEventIDViewController : UITableViewController<HomeModelProtocol>
@property (strong, nonatomic) NSMutableArray *arrPostDetail;
@end
