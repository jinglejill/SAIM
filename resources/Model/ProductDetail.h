//
//  ProductDetail.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 8/13/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductDetail : NSObject
@property (retain, nonatomic) NSString * productID;
@property (retain, nonatomic) NSString * productName;
@property (retain, nonatomic) NSString * color;
@property (retain, nonatomic) NSString * size;
@property (retain, nonatomic) NSString * price;
@property (retain, nonatomic) NSString * pricePromotion;
@property (retain, nonatomic) NSString * detail;
@property (retain, nonatomic) NSString * imageDefault;
@property (retain, nonatomic) NSString * status;
@property (retain, nonatomic) NSString * productIDGroup;
@property (retain, nonatomic) NSString * manufacturingDate;
@property (retain, nonatomic) NSString * receiptNo;
@property (retain, nonatomic) NSString * receiptDate;
@property (retain, nonatomic) NSString * priceSold;
@property (nonatomic) NSInteger eventID;

@property (nonatomic) NSInteger replaceProduct;
@property (nonatomic) NSInteger ship;
@property (nonatomic) NSInteger discount;
@property (nonatomic) float discountValue;
@property (nonatomic) float discountPercent;
@property (retain, nonatomic) NSString * discountReason;
@property (nonatomic) NSInteger postCustomerID;
@property (nonatomic) NSInteger productNameID;

@end
