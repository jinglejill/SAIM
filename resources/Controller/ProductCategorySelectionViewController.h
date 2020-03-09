//
//  ProductCategorySelectionViewController.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 9/1/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

//#import "ViewController.h"
#import "APLSectionHeaderView.h"

@interface ProductCategorySelectionViewController : UITableViewController<SectionHeaderViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableViewList;
@property (nonatomic) NSInteger openSectionIndex;
@property (nonatomic) NSMutableArray *sectionInfoArray;
- (IBAction)unwindToProductCategorySelection:(UIStoryboardSegue *)segue;
@end
