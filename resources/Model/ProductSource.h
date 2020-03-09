//
//  ProductSource.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 8/28/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductSource : NSObject
@property (retain, nonatomic) NSString * row;
@property (retain, nonatomic) NSString * productName;
@property (retain, nonatomic) NSString * color;
@property (retain, nonatomic) NSString * size;
@property (nonatomic) NSInteger sizeOrder;
@property (retain, nonatomic) NSString * manufacturingYearMonth;
@property (retain, nonatomic) NSString * eventName;
@property (retain, nonatomic) NSString * quantity;
@property (retain, nonatomic) NSString * productIDGroup;
@property (retain, nonatomic) NSString * eventID;
@property (retain, nonatomic) NSString * status;
@end
