//
//  SharedProductCost.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/23/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedProductCost.h"

@implementation SharedProductCost
@synthesize productCostList;

+(SharedProductCost *)sharedProductCost {
    static dispatch_once_t pred;
    static SharedProductCost *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedProductCost alloc] init];
        shared.productCostList = [[NSMutableArray alloc]init];
    });
    return shared;
}

@end
