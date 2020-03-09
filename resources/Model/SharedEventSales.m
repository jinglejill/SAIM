//
//  SharedEventSales.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 10/4/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedEventSales.h"

@implementation SharedEventSales
@synthesize dicEventSales;

+(SharedEventSales *)sharedEventSales {
    static dispatch_once_t pred;
    static SharedEventSales *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedEventSales alloc] init];
        shared.dicEventSales = [[NSMutableDictionary alloc]init];
    });
    return shared;
}
@end
