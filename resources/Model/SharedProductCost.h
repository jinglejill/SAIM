//
//  SharedProductCost.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/23/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedProductCost : NSObject
@property (retain, nonatomic) NSMutableArray * productCostList;

+ (SharedProductCost *)sharedProductCost;

@end
