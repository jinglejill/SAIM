//
//  SearchSalesTelephoneDetailViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 8/4/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import "CustomViewController.h"
#import "PostCustomer.h"
NS_ASSUME_NONNULL_BEGIN

@interface SearchSalesTelephoneDetailViewController : CustomViewController
@property (strong, nonatomic) IBOutlet UITableView *tbvData;
@property (strong, nonatomic) NSString *telephone;
@property (strong, nonatomic) PostCustomer *postCustomer;
- (IBAction)unwindToSearchSalesTelephoneDetail:(UIStoryboardSegue *)segue;

@end

NS_ASSUME_NONNULL_END
