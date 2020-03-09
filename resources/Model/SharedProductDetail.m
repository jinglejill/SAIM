//
//  SharedProductDetail.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/12/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedProductDetail.h"

@implementation SharedProductDetail
@synthesize productDetailList;

+(SharedProductDetail *)sharedProductDetail {
    static dispatch_once_t pred;
    static SharedProductDetail *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedProductDetail alloc] init];
        shared.productDetailList = [[NSMutableArray alloc]init];
    });
    return shared;
}
@end
