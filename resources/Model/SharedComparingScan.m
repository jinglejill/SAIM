//
//  SharedComparingScan.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/1/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedComparingScan.h"

@implementation SharedComparingScan
@synthesize comparingScan;

+(SharedComparingScan *)sharedComparingScan {
    static dispatch_once_t pred;
    static SharedComparingScan *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedComparingScan alloc] init];
        shared.comparingScan = [[NSMutableArray alloc]init];
    });
    return shared;
}
@end
