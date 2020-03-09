//
//  SharedPreOrderEventIDHistory.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 8/3/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedPreOrderEventIDHistory.h"

@implementation SharedPreOrderEventIDHistory
@synthesize preOrderEventIDHistoryList;

+(SharedPreOrderEventIDHistory *)sharedPreOrderEventIDHistory {
    static dispatch_once_t pred;
    static SharedPreOrderEventIDHistory *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedPreOrderEventIDHistory alloc] init];
        shared.preOrderEventIDHistoryList = [[NSMutableArray alloc]init];
    });
    return shared;
}

@end
