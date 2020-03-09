//
//  SharedColor.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/13/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedColor.h"

@implementation SharedColor
@synthesize colorList;

+(SharedColor *)sharedColor {
    static dispatch_once_t pred;
    static SharedColor *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedColor alloc] init];
        shared.colorList = [[NSMutableArray alloc]init];
    });
    return shared;
}
@end
