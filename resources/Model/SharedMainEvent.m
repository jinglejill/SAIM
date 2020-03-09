//
//  SharedMainEvent.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 7/22/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedMainEvent.h"

@implementation SharedMainEvent
@synthesize event;

+ (SharedMainEvent *)sharedMainEvent
{
    static dispatch_once_t pred;
    static SharedMainEvent *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedMainEvent alloc] init];
        shared.event = [[Event alloc]init];
//        shared.event.eventID = 0;
//        shared.event.location = @"Main stock";
//        shared.event.periodFrom = @"2000-01-01";
//        shared.event.periodTo = @"2100-12-31";
//        shared.event.remark = @"";
//        shared.event.modifiedDate = @"2000-01-01 00:00:00";
//        shared.event.productSalesSetID = @"0";
    });
    return shared;
}

@end
