//
//  SharedEvent.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 8/18/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedEvent.h"

@implementation SharedEvent
@synthesize eventList;

+(SharedEvent *)sharedEvent {
    static dispatch_once_t pred;
    static SharedEvent *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedEvent alloc] init];
        shared.eventList = [[NSMutableArray alloc]init];
    });
    return shared;
}
@end
