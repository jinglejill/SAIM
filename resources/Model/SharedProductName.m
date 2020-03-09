//
//  SharedProductName.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/13/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedProductName.h"

@implementation SharedProductName
@synthesize productNameList;

+(SharedProductName *)sharedProductName {
    static dispatch_once_t pred;
    static SharedProductName *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedProductName alloc] init];
        shared.productNameList = [[NSMutableArray alloc]init];
    });
    return shared;
}
@end
