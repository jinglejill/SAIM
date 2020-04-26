//
//  Product.h
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 8/4/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Product : NSObject
@property (retain, nonatomic) NSString * productID;
@property (retain, nonatomic) NSString * productCode;
@property (retain, nonatomic) NSString * productCategory2;
@property (retain, nonatomic) NSString * productCategory1;
@property (retain, nonatomic) NSString * productName;
@property (retain, nonatomic) NSString * color;
@property (retain, nonatomic) NSString * size;
@property (retain, nonatomic) NSString * manufacturingDate;
@property (retain, nonatomic) NSString * status;
@property (retain, nonatomic) NSString * remark;
@property (nonatomic) NSInteger eventID;
@property (retain, nonatomic) NSString * modifiedDate;
@property (retain, nonatomic) NSString * productIDGroup;
@property (retain, nonatomic) NSString * productNameGroup;
@property (retain, nonatomic) NSString * manufacturingDateYM;
@property (retain, nonatomic) NSString * productType;
@property (nonatomic) NSInteger eventIDSpare;

@property (nonatomic) NSInteger productNameID;
@property (nonatomic) NSInteger transferHistoryID;
@property (retain, nonatomic) NSString * modifiedUser;//ใช้ตอน delete row ที่ duplicate key
@property (nonatomic) NSInteger replaceSelf;//ใช้เฉพาะตอน push type = 'd'
@property (nonatomic) NSInteger idInserted;//ใช้ตอน update or delete

@property (nonatomic) NSInteger quantity;

- (id)init;
+ (NSMutableArray *)getProductListInMainInventory:(Product *)product;
+ (Product *)getProduct:(NSString *)productID;
+ (NSString *)getProductNameGroup:(Product *)product;
//+ (Product *) getProductWithProductCode:(NSString *)productCode;
@end
