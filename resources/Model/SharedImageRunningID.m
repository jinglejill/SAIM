//
//  SharedImageRunningID.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 3/16/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedImageRunningID.h"

@implementation SharedImageRunningID
@synthesize imageRunningIDList;

+(SharedImageRunningID *)sharedImageRunningID {
    static dispatch_once_t pred;
    static SharedImageRunningID *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedImageRunningID alloc] init];
        shared.imageRunningIDList = [[NSMutableArray alloc]init];
    });
    return shared;
}
@end
