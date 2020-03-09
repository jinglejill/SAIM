//
//  ProductCategory2ChoosingViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 1/13/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"

@interface ProductCategory2SelectionViewController : UITableViewController<HomeModelProtocol>
@property (strong, nonatomic) IBOutlet UITableView *tableViewList;
- (IBAction)unwindToProductCategory2Selection:(UIStoryboardSegue *)segue;
@property (nonatomic) NSInteger fromMenu;//0=productcategory1, 1=product
@end
