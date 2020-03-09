//
//  SharedSalesByItemData.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/18/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedSalesByItemData : NSObject
@property (retain, nonatomic) NSMutableArray * salesByItemDataList;
+ (SharedSalesByItemData *)sharedSalesByItemData;


@end
