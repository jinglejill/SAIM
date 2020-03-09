//
//  TransferHistory.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 4/7/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import "TransferHistory.h"

@implementation TransferHistory

+(TransferHistory *)getTransferHistory:(NSInteger)transferHistoryID transferHistoryList:(NSMutableArray *)transferHistoryList
{
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_transferHistoryID = %ld",transferHistoryID];
    NSArray *filterArray = [transferHistoryList filteredArrayUsingPredicate:predicate1];
    
    if([filterArray count]>0)
    {
        return filterArray[0];
    }
    return nil;
}
@end
