//
//  SharedReceiptItem.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/18/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedReceiptItem : NSObject
@property (retain, nonatomic) NSMutableArray * receiptItemList;
+ (SharedReceiptItem *)sharedReceiptItem;

@end
