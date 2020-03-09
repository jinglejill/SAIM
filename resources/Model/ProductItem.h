//
//  ProductItem.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 8/26/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductItem : NSObject
@property (retain, nonatomic) NSString * row;
@property (retain, nonatomic) NSString * productID;
@property (retain, nonatomic) NSString * productName;
@property (retain, nonatomic) NSString * color;
@property (retain, nonatomic) NSString * size;
@property (nonatomic) NSInteger sizeOrder;
@property (retain, nonatomic) NSString * modifiedDate;
@property (retain, nonatomic) NSString * eventID;
@property (retain, nonatomic) NSString * status;
@property (retain, nonatomic) NSString * modifiedDateNoTime;
@property (retain, nonatomic) NSString * manufacturingDate;
@property (retain, nonatomic) NSString * productCategory2;
@property (retain, nonatomic) NSString * modifiedDateText;

@property (retain, nonatomic) NSString * modifiedTime;
@property (retain, nonatomic) NSString * productCode;
@property (retain, nonatomic) NSString * sortDate;
@property (nonatomic) NSInteger countByDate;
@property (nonatomic) NSInteger count;
@end
