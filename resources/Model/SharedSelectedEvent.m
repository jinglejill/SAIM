//
//  SharedSelectedEvent.m
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 8/11/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedSelectedEvent.h"

@implementation SharedSelectedEvent
@synthesize event;

+ (SharedSelectedEvent *)sharedSelectedEvent
{
    static dispatch_once_t pred;
    static SharedSelectedEvent *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedSelectedEvent alloc] init];
        shared.event = [[Event alloc]init];
    });
    return shared;
}

@end
