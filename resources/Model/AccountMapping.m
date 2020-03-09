//
//  AccountMapping.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 2/9/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import "AccountMapping.h"

@implementation AccountMapping

- (NSDictionary *)dictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
        [self valueForKey:@"accountMappingID"]?[self valueForKey:@"accountMappingID"]:[NSNull null],@"accountMappingID",
        [self valueForKey:@"receiptID"]?[self valueForKey:@"receiptID"]:[NSNull null],@"receiptID",
        [self valueForKey:@"receiptProductItemID"]?[self valueForKey:@"receiptProductItemID"]:[NSNull null],@"receiptProductItemID",
        [self valueForKey:@"runningAccountReceiptHistory"]?[self valueForKey:@"runningAccountReceiptHistory"]:[NSNull null],@"runningAccountReceiptHistory",        
        nil];
}

-(AccountMapping *)initWithAccountMappingID:(NSInteger)accountMappingID receiptID:(NSInteger)receiptID receiptProductItemID:(NSInteger)receiptProductItemID runningAccountReceiptHistory:(NSInteger)runningAccountReceiptHistory
{
    self = [super init];
    if(self)
    {
        self.accountMappingID = accountMappingID;
        self.receiptID = receiptID;
        self.receiptProductItemID = receiptProductItemID;
        self.runningAccountReceiptHistory = runningAccountReceiptHistory;
    }
    
    return self;
}

@end
