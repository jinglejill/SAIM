//
//  SharedReplaceReceiptProductItem.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 23/4/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReceiptProductItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface SharedReplaceReceiptProductItem : NSObject
@property (nonatomic) ReceiptProductItem *replaceReceiptProductItem;
+ (SharedReplaceReceiptProductItem *)sharedReplaceReceiptProductItem;
@end

NS_ASSUME_NONNULL_END
