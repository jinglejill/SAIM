//
//  SharedReplaceReceiptProductItem.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 23/4/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedReplaceReceiptProductItem.h"

@implementation SharedReplaceReceiptProductItem
@synthesize replaceReceiptProductItem;

+(SharedReplaceReceiptProductItem *)sharedReplaceReceiptProductItem {
    static dispatch_once_t pred;
    static SharedReplaceReceiptProductItem *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedReplaceReceiptProductItem alloc] init];
        shared.replaceReceiptProductItem = [[ReceiptProductItem alloc]init];
    });
    return shared;
}
@end
