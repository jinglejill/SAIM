//
//  SharedSalesBySizeData.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/19/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedSalesBySizeData.h"

@implementation SharedSalesBySizeData
@synthesize salesBySizeDataList;

+(SharedSalesBySizeData *)sharedSalesBySizeData {
    static dispatch_once_t pred;
    static SharedSalesBySizeData *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedSalesBySizeData alloc] init];
        shared.salesBySizeDataList = [[NSMutableArray alloc]init];
    });
    return shared;
}
@end
