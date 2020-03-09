//
//  ProductCategory1SelectionViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 1/15/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductCategory1SelectionViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UITableView *tableViewList;
- (IBAction)unwindToProductCategory1Selection:(UIStoryboardSegue *)segue;
@property (strong, nonatomic) NSString *productCategory2;
@end
