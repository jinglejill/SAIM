//
//  ProductSales.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 9/1/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductSales : NSObject
@property (nonatomic) NSInteger productSalesID;
@property (retain, nonatomic) NSString * productSalesSetID;
@property (retain, nonatomic) NSString * productCategory2;
@property (retain, nonatomic) NSString * productCategory1;
@property (retain, nonatomic) NSString * productName;
@property (nonatomic) NSInteger productNameID;
@property (retain, nonatomic) NSString * color;
@property (retain, nonatomic) NSString * size;
@property (retain, nonatomic) NSString * price;
@property (retain, nonatomic) NSString * detail;
@property (retain, nonatomic) NSString * percentDiscountMember;
@property (retain, nonatomic) NSString * percentDiscountFlag;
@property (retain, nonatomic) NSString * percentDiscount;
@property (retain, nonatomic) NSString * pricePromotion;
@property (retain, nonatomic) NSString * shippingFee;
@property (retain, nonatomic) NSString * imageDefault;
@property (retain, nonatomic) NSString * imageID;
@property (retain, nonatomic) NSString * cost;
@property (retain, nonatomic) NSString * modifiedDate;
@property (retain, nonatomic) NSString * row;
@property (retain, nonatomic) NSString * editType;//0=edit,1=unselect,2=select
@property (retain, nonatomic) NSString * productNameText;
@property (retain, nonatomic) NSString * colorText;
@property (retain, nonatomic) NSString * sizeText;
@property (nonatomic) NSInteger sizeOrder;
@property (nonatomic) NSInteger productNameActive;
@property (retain, nonatomic) NSString * modifiedUser;//ใช้ตอน delete row ที่ duplicate key
@property (nonatomic) NSInteger replaceSelf;//ใช้เฉพาะตอน push type = 'd'
@property (nonatomic) NSInteger idInserted;//ใช้ตอน update or delete


+ (ProductSales *)getProductSalesFromProductNameID:(NSInteger)productNameID color:(NSString *)color size:(NSString *)size productSalesSetID:(NSString *)productSalesSetID;
+(void)addProductSalesList:(NSMutableArray *)productSalesList;
@end
