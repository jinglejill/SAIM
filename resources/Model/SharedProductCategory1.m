//
//  SharedProductCategory1.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/12/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedProductCategory1.h"

@implementation SharedProductCategory1
@synthesize productCategory1List;

+(SharedProductCategory1 *)sharedProductCategory1 {
    static dispatch_once_t pred;
    static SharedProductCategory1 *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedProductCategory1 alloc] init];
        shared.productCategory1List = [[NSMutableArray alloc]init];
    });
    return shared;
}
@end
