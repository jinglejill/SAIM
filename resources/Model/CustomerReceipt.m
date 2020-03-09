//
//  CustomerReceipt.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/8/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "CustomerReceipt.h"
#import "SharedCustomerReceipt.h"


@implementation CustomerReceipt
+(CustomerReceipt *)getCustomerReceiptWithReceiptID:(NSInteger)receiptID
{
    NSMutableArray *customerReceiptList = [SharedCustomerReceipt sharedCustomerReceipt].customerReceiptList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_receiptID = %ld",receiptID];
    NSArray *filterArray = [customerReceiptList filteredArrayUsingPredicate:predicate1];
    
    if([filterArray count]>0)
    {
        return filterArray[0];
    }
    return nil;
}
@end
