//
//  SharedProductSales.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/17/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedProductSales.h"

@implementation SharedProductSales
@synthesize productSalesList;

+(SharedProductSales *)sharedProductSales {
    static dispatch_once_t pred;
    static SharedProductSales *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedProductSales alloc] init];
        shared.productSalesList = [[NSMutableArray alloc]init];
    });
    return shared;
}
@end

