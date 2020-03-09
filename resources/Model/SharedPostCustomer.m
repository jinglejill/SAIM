//
//  SharedPostCustomer.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/13/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedPostCustomer.h"

@implementation SharedPostCustomer
@synthesize postCustomerList;

+(SharedPostCustomer *)sharedPostCustomer {
    static dispatch_once_t pred;
    static SharedPostCustomer *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedPostCustomer alloc] init];
        shared.postCustomerList = [[NSMutableArray alloc]init];
    });
    return shared;
}

@end
