//
//  SharedPostBuy.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/13/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedPostBuy : NSObject
@property (retain, nonatomic) NSMutableArray * postBuyList;
+ (SharedPostBuy *)sharedPostBuy;
@end
