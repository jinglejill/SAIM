//
//  SharedProductSales.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/17/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedProductSales : NSObject
@property (retain, nonatomic) NSMutableArray * productSalesList;
+ (SharedProductSales *)sharedProductSales;
@end
