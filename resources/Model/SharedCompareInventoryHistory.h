//
//  SharedCompareInventoryHistory.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/3/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedCompareInventoryHistory : NSObject
@property (retain, nonatomic) NSMutableArray * compareInventoryHistoryList;
+ (SharedCompareInventoryHistory *)sharedCompareInventoryHistory;


@end
