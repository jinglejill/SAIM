//
//  SharedProductBuy.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 9/28/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedProductBuy : NSObject
@property (retain, nonatomic) NSMutableArray * productBuyList;
+ (SharedProductBuy *)sharedProductBuy;
@end
