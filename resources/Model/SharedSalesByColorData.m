//
//  SharedSalesByColorData.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/19/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedSalesByColorData.h"

@implementation SharedSalesByColorData
@synthesize salesByColorDataList;

+(SharedSalesByColorData *)sharedSalesByColorData {
    static dispatch_once_t pred;
    static SharedSalesByColorData *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedSalesByColorData alloc] init];
        shared.salesByColorDataList = [[NSMutableArray alloc]init];
    });
    return shared;
}
@end
