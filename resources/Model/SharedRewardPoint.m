//
//  SharedRewardPoint.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 11/8/2559 BE.
//  Copyright © 2559 Appxelent. All rights reserved.
//

#import "SharedRewardPoint.h"

@implementation SharedRewardPoint
@synthesize rewardPointList;

+(SharedRewardPoint *)sharedRewardPoint {
    static dispatch_once_t pred;
    static SharedRewardPoint *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedRewardPoint alloc] init];
        shared.rewardPointList = [[NSMutableArray alloc]init];
    });
    return shared;
}
@end
