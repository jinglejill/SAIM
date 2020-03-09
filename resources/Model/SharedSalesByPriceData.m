//
//  SharedSalesByPriceData.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/19/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedSalesByPriceData.h"

@implementation SharedSalesByPriceData
@synthesize salesByPriceDataList;

+(SharedSalesByPriceData *)sharedSalesByPriceData {
    static dispatch_once_t pred;
    static SharedSalesByPriceData *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedSalesByPriceData alloc] init];
        shared.salesByPriceDataList = [[NSMutableArray alloc]init];
    });
    return shared;
}

@end
