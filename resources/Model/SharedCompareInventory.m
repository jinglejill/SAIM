//
//  SharedCompareInventory.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/30/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedCompareInventory.h"

@implementation SharedCompareInventory
@synthesize compareInventoryList;

+(SharedCompareInventory *)sharedCompareInventory {
    static dispatch_once_t pred;
    static SharedCompareInventory *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedCompareInventory alloc] init];
        shared.compareInventoryList = [[NSMutableArray alloc]init];
    });
    return shared;
}
@end
