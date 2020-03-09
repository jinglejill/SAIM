//
//  SharedPostCode.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 10/6/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedPostCode.h"


@implementation SharedPostCode
@synthesize postcodeList;

+(SharedPostCode *)sharedPostCode {
    static dispatch_once_t pred;
    static SharedPostCode *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedPostCode alloc] init];
        shared.postcodeList = [[NSMutableArray alloc]init];
    });
    return shared;
}
@end
