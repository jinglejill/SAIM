//
//  SharedProductSize.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 1/1/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedProductSize.h"

@implementation SharedProductSize
@synthesize productSizeList;

+(SharedProductSize *)sharedProductSize {
    static dispatch_once_t pred;
    static SharedProductSize *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedProductSize alloc] init];
        shared.productSizeList = [[NSMutableArray alloc]init];
    });
    return shared;
}
@end
