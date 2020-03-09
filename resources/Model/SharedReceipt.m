//
//  SharedReceipt.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/18/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedReceipt.h"

@implementation SharedReceipt
@synthesize receiptList;

+(SharedReceipt *)sharedReceipt {
    static dispatch_once_t pred;
    static SharedReceipt *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedReceipt alloc] init];
        shared.receiptList = [[NSMutableArray alloc]init];
    });
    return shared;
}
@end
