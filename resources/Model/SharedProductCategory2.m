//
//  SharedProductCategory2.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/12/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedProductCategory2.h"

@implementation SharedProductCategory2
@synthesize productCategory2List;

+(SharedProductCategory2 *)sharedProductCategory2 {
    static dispatch_once_t pred;
    static SharedProductCategory2 *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedProductCategory2 alloc] init];
        shared.productCategory2List = [[NSMutableArray alloc]init];
    });
    return shared;
}

@end
