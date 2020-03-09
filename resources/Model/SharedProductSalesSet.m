//
//  SharedProductSalesSet.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/23/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedProductSalesSet.h"

@implementation SharedProductSalesSet
@synthesize productSalesSetList;

+(SharedProductSalesSet *)sharedProductSalesSet {
    static dispatch_once_t pred;
    static SharedProductSalesSet *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedProductSalesSet alloc] init];
        shared.productSalesSetList = [[NSMutableArray alloc]init];
    });
    return shared;
}
@end
