//
//  SharedRewardProgram.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 1/2/2560 BE.
//  Copyright © 2560 Appxelent. All rights reserved.
//

#import "SharedRewardProgram.h"

@implementation SharedRewardProgram
@synthesize rewardProgramList;

+(SharedRewardProgram *)sharedRewardProgram {
    static dispatch_once_t pred;
    static SharedRewardProgram *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedRewardProgram alloc] init];
        shared.rewardProgramList = [[NSMutableArray alloc]init];
    });
    return shared;
}
@end
