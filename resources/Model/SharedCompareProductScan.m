//
//  SharedCompareProductScan.m
//  SAIM_UPDATING
//
//  Created by Thidaporn Kijkamjai on 6/15/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedCompareProductScan.h"

@implementation SharedCompareProductScan
@synthesize compareProductScanList;

+(SharedCompareProductScan *)sharedCompareProductScan {
    static dispatch_once_t pred;
    static SharedCompareProductScan *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedCompareProductScan alloc] init];
        shared.compareProductScanList = [[NSMutableArray alloc]init];
    });
    return shared;
}
@end
