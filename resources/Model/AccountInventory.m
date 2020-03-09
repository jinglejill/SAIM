//
//  AccountInventory.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 2/2/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import "AccountInventory.h"
#import "Utility.h"


@implementation AccountInventory

- (NSDictionary *)dictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
        [self valueForKey:@"accountInventoryID"]?[self valueForKey:@"accountInventoryID"]:[NSNull null],@"accountInventoryID",
        [self valueForKey:@"productNameID"]?[self valueForKey:@"productNameID"]:[NSNull null],@"productNameID",
        [self valueForKey:@"quantity"]?[self valueForKey:@"quantity"]:[NSNull null],@"quantity",
        [self valueForKey:@"status"]?[self valueForKey:@"status"]:[NSNull null],@"status",
        [self valueForKey:@"inOutDate"]?[self valueForKey:@"inOutDate"]:[NSNull null],@"inOutDate",
//        [Utility dateToString:[self valueForKey:@"inOutDate"] toFormat:@"yyyy-MM-dd HH:mm:ss"],@"inOutDate",
        [self valueForKey:@"runningAccountReceiptHistory"]?[self valueForKey:@"runningAccountReceiptHistory"]:[NSNull null],@"runningAccountReceiptHistory",        
        nil];
}

- (AccountInventory *)initWithAccountInventoryID:(NSInteger)accountInventoryID productNameID:(NSInteger)productNameID quantity:(float)quantity status:(NSInteger)status inOutDate:(NSString *)inOutDate runningAccountReceiptHistory:(NSInteger)runningAccountReceiptHistory modifiedDate:(NSString *)modifiedDate
{
    self = [super init];
    if(self)
    {
        self.accountInventoryID = accountInventoryID;
        self.productNameID = productNameID;
        self.quantity = quantity;
        self.status = status;
        self.inOutDate = inOutDate;
        self.runningAccountReceiptHistory = runningAccountReceiptHistory;
        self.modifiedDate = modifiedDate;
        self.modifiedUser = [Utility modifiedUser];
    }
    
    return self;
}

+ (NSMutableArray *)getAccountInventorySortedByUsed:(NSMutableArray *)accountInventoryList
{
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_productName" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_inOutDate" ascending:NO];
    NSSortDescriptor *sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:@"_used" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2,sortDescriptor3, nil];
    
    NSArray *sortArray = [accountInventoryList sortedArrayUsingDescriptors:sortDescriptors];
    accountInventoryList = [sortArray mutableCopy];
    return accountInventoryList;
}
@end
