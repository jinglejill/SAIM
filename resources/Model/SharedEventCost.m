//
//  SharedEventCost.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/24/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedEventCost.h"

@implementation SharedEventCost
@synthesize eventCostList;

+(SharedEventCost *)sharedEventCost {
    static dispatch_once_t pred;
    static SharedEventCost *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedEventCost alloc] init];
        shared.eventCostList = [[NSMutableArray alloc]init];
    });
    return shared;
}
@end
