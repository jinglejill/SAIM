//
//  Receipt.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/1/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "Receipt.h"
#import "SharedReceipt.h"


@implementation Receipt

+ (Receipt *)getReceipt:(NSInteger)receiptID
{
    NSMutableArray *receiptList = [SharedReceipt sharedReceipt].receiptList;
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_receiptID = %ld",receiptID];
    NSArray *filterArray = [receiptList filteredArrayUsingPredicate:predicate1];
    
    if([filterArray count] > 0)
    {
        return filterArray[0];
    }
    return nil;
}

+ (NSMutableArray *)getReceiptSortByReceiptDate:(NSMutableArray *)receiptList
{
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_receiptDate" ascending:YES];
    NSArray *sortDescriptors1 = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortedArray = [receiptList sortedArrayUsingDescriptors:sortDescriptors1];
    
    return [sortedArray mutableCopy];
}
@end
