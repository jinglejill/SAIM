//
//  SharedCompareInventory.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/30/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedCompareInventory : NSObject
@property (retain, nonatomic) NSMutableArray * compareInventoryList;
+ (SharedCompareInventory *)sharedCompareInventory;

@end
