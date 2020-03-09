//
//  SharedProduct.m
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 8/4/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedProduct.h"

@implementation SharedProduct
@synthesize productList;

+(SharedProduct *)sharedProduct {
    static dispatch_once_t pred;
    static SharedProduct *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedProduct alloc] init];
        shared.productList = [[NSMutableArray alloc]init];
    });
    return shared;
}
@end
