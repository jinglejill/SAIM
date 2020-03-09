//
//  SharedProductSalesSet.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/23/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedProductSalesSet : NSObject
@property (retain, nonatomic) NSMutableArray * productSalesSetList;

+ (SharedProductSalesSet *)sharedProductSalesSet;
@end
