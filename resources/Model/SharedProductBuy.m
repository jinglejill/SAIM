//
//  SharedProductBuy.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 9/28/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedProductBuy.h"

@implementation SharedProductBuy
@synthesize productBuyList;

+(SharedProductBuy *)sharedProductBuy {
    static dispatch_once_t pred;
    static SharedProductBuy *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedProductBuy alloc] init];
        shared.productBuyList = [[NSMutableArray alloc]init];
    });
    return shared;
}
@end
