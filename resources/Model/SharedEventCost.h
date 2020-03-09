//
//  SharedEventCost.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/24/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedEventCost : NSObject
@property (retain, nonatomic) NSMutableArray * eventCostList;

+ (SharedEventCost *)sharedEventCost;

@end
