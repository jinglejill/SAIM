//
//  SharedCustomMade.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/18/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedCustomMade.h"

@implementation SharedCustomMade
@synthesize customMadeList;

+(SharedCustomMade *)sharedCustomMade {
    static dispatch_once_t pred;
    static SharedCustomMade *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedCustomMade alloc] init];
        shared.customMadeList = [[NSMutableArray alloc]init];
    });
    return shared;
}
@end
