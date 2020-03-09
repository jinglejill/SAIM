//
//  SharedReceiptItem.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/18/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedReceiptItem.h"

@implementation SharedReceiptItem
@synthesize receiptItemList;

+(SharedReceiptItem *)sharedReceiptItem {
    static dispatch_once_t pred;
    static SharedReceiptItem *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedReceiptItem alloc] init];
        shared.receiptItemList = [[NSMutableArray alloc]init];
    });
    return shared;
}
@end
