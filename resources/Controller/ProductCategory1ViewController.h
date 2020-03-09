//
//  ProductCategory1ViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 1/13/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"


@interface ProductCategory1ViewController : UITableViewController<HomeModelProtocol>
@property (strong, nonatomic) IBOutlet UITableView *tableViewList;
- (IBAction)unwindToProductCategory1:(UIStoryboardSegue *)segue;
- (IBAction)addItem:(id)sender;
- (IBAction)doneButtonClicked:(id)sender;

@property (strong, nonatomic) NSString *productCategory2;

@end
