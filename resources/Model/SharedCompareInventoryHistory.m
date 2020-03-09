//
//  SharedCompareInventoryHistory.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/3/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedCompareInventoryHistory.h"

@implementation SharedCompareInventoryHistory
@synthesize compareInventoryHistoryList;

+(SharedCompareInventoryHistory *)sharedCompareInventoryHistory {
    static dispatch_once_t pred;
    static SharedCompareInventoryHistory *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedCompareInventoryHistory alloc] init];
        shared.compareInventoryHistoryList = [[NSMutableArray alloc]init];
    });
    return shared;
}
@end
