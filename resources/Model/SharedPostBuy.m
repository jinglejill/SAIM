//
//  SharedPostBuy.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/13/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedPostBuy.h"

@implementation SharedPostBuy
@synthesize postBuyList;

+(SharedPostBuy *)sharedPostBuy {
    static dispatch_once_t pred;
    static SharedPostBuy *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedPostBuy alloc] init];
        shared.postBuyList = [[NSMutableArray alloc]init];
    });
    return shared;
}
@end
