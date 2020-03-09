//
//  SharedCashAllocation.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/18/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedCashAllocation.h"

@implementation SharedCashAllocation
@synthesize cashAllocationList;

+(SharedCashAllocation *)sharedCashAllocation {
    static dispatch_once_t pred;
    static SharedCashAllocation *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedCashAllocation alloc] init];
        shared.cashAllocationList = [[NSMutableArray alloc]init];
    });
    return shared;
}
@end
