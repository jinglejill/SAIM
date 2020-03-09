//
//  SharedSalesByColorData.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/19/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedSalesByColorData : NSObject
@property (retain, nonatomic) NSMutableArray * salesByColorDataList;
+ (SharedSalesByColorData *)sharedSalesByColorData;

@end
