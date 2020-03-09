//
//  SharedProductDelete.m
//  SAIM_UPDATING
//
//  Created by Thidaporn Kijkamjai on 4/25/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedProductDelete.h"

@implementation SharedProductDelete
@synthesize productDeleteList;

+(SharedProductDelete *)sharedProductDelete {
    static dispatch_once_t pred;
    static SharedProductDelete *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedProductDelete alloc] init];
        shared.productDeleteList = [[NSMutableArray alloc]init];
    });
    return shared;
}
@end
