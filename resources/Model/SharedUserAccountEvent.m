//
//  SharedUserAccountEvent.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/12/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedUserAccountEvent.h"

@implementation SharedUserAccountEvent
@synthesize userAccountEventList;

+(SharedUserAccountEvent *)sharedUserAccountEvent {
    static dispatch_once_t pred;
    static SharedUserAccountEvent *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedUserAccountEvent alloc] init];
        shared.userAccountEventList = [[NSMutableArray alloc]init];
    });
    return shared;
}
@end
