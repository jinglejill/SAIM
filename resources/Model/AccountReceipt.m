//
//  AccountReceipt.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 2/8/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import "AccountReceipt.h"
#import "Utility.h"

@implementation AccountReceipt

- (NSDictionary *)dictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
        [self valueForKey:@"accountReceiptID"]?[self valueForKey:@"accountReceiptID"]:[NSNull null],@"accountReceiptID",
        [self valueForKey:@"receiptID"]?[self valueForKey:@"receiptID"]:[NSNull null],@"receiptID",
        [self valueForKey:@"receiptDiscount"]?[self valueForKey:@"receiptDiscount"]:[NSNull null],@"receiptDiscount",
        [self valueForKey:@"runningAccountReceiptHistory"]?[self valueForKey:@"runningAccountReceiptHistory"]:[NSNull null],@"runningAccountReceiptHistory",
        [self valueForKey:@"runningReceiptNo"]?[self valueForKey:@"runningReceiptNo"]:[NSNull null],@"runningReceiptNo",
        [self valueForKey:@"accountReceiptHistoryDate"]?[self valueForKey:@"accountReceiptHistoryDate"]:[NSNull null],@"accountReceiptHistoryDate",
//        [Utility dateToString:[self valueForKey:@"accountReceiptHistoryDate"] toFormat:@"yyyy-MM-dd HH:mm:ss"],@"accountReceiptHistoryDate",
        [self valueForKey:@"receiptNo"]?[self valueForKey:@"receiptNo"]:[NSNull null],@"receiptNo",
        [self valueForKey:@"receiptDate"]?[self valueForKey:@"receiptDate"]:[NSNull null],@"receiptDate",
//        [Utility dateToString:[self valueForKey:@"receiptDate"] toFormat:@"yyyy-MM-dd HH:mm:ss"],@"receiptDate",
        [self valueForKey:@"taxCustomerName"]?[self valueForKey:@"taxCustomerName"]:[NSNull null],@"taxCustomerName",
        [self valueForKey:@"taxCustomerAddress"]?[self valueForKey:@"taxCustomerAddress"]:[NSNull null],@"taxCustomerAddress",
        [self valueForKey:@"taxNo"]?[self valueForKey:@"taxNo"]:[NSNull null],@"taxNo",        
        nil];
}

-(AccountReceipt *)initWithAccountReceiptID:(NSInteger)accountReceiptID runningAccountReceiptHistory:(NSInteger)runningAccountReceiptHistory runningReceiptNo:(NSInteger)runningReceiptNo accountReceiptHistoryDate:(NSString*)accountReceiptHistoryDate receiptNo:(NSString*)receiptNo receiptDate:(NSString*)receiptDate receiptID:(NSInteger)receiptID receiptDiscount:(float)receiptDiscount
{
    self = [super init];
    if(self)
    {
        self.accountReceiptID = accountReceiptID;
        self.runningAccountReceiptHistory = runningAccountReceiptHistory;
        self.runningReceiptNo = runningReceiptNo;
        self.accountReceiptHistoryDate = accountReceiptHistoryDate;
        self.receiptNo = receiptNo;
        self.receiptDate = receiptDate;
        self.receiptID = receiptID;
        self.receiptDiscount = receiptDiscount;
    }
    
    return self;
}

+(NSMutableArray *)getAccountReceiptSortByAccountReceiptID:(NSMutableArray *)accountReceiptList
{
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_accountReceiptID" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortArray = [accountReceiptList sortedArrayUsingDescriptors:sortDescriptors];
    accountReceiptList = [sortArray mutableCopy];
    return accountReceiptList;
}
@end
