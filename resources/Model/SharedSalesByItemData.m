//
//  SharedSalesByItemData.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/18/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedSalesByItemData.h"

@implementation SharedSalesByItemData
@synthesize salesByItemDataList;

+(SharedSalesByItemData *)sharedSalesByItemData {
    static dispatch_once_t pred;
    static SharedSalesByItemData *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedSalesByItemData alloc] init];
        shared.salesByItemDataList = [[NSMutableArray alloc]init];
    });
    return shared;
}
@end
