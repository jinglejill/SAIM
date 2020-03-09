//
//  SharedEventSales.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 10/4/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedEventSales : NSObject
@property (retain, nonatomic) NSDictionary * dicEventSales;
+ (SharedEventSales *)sharedEventSales;
@end
