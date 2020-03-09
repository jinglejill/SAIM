//
//  SharedCustomerReceipt.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/11/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedCustomerReceipt.h"

@implementation SharedCustomerReceipt
@synthesize customerReceiptList;

+(SharedCustomerReceipt *)sharedCustomerReceipt {
    static dispatch_once_t pred;
    static SharedCustomerReceipt *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedCustomerReceipt alloc] init];
        shared.customerReceiptList = [[NSMutableArray alloc]init];
    });
    return shared;
}
@end


