//
//  ProductName.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/13/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Product.h"

@interface ProductName : NSObject
@property (nonatomic) NSInteger productNameID;
@property (retain, nonatomic) NSString * productCategory2;
@property (retain, nonatomic) NSString * productCategory1;
@property (retain, nonatomic) NSString * code;
@property (retain, nonatomic) NSString * name;
@property (retain, nonatomic) NSString * detail;
@property (nonatomic) NSInteger active;
@property (retain, nonatomic) NSString * modifiedDate;
@property (retain, nonatomic) NSString * modifiedUser;//ใช้ตอน delete row ที่ duplicate key
@property (nonatomic) NSInteger replaceSelf;//ใช้เฉพาะตอน push type = 'd'
@property (nonatomic) NSInteger idInserted;//ใช้ตอน update or delete

+ (ProductName *)getProductNameWithProduct:(Product *)product;
+ (ProductName *)getProductName:(NSInteger)productNameID;
+ (NSString *)getProductCode:(NSInteger)productNameID;
+ (NSString *)getNameWithProductID:(NSString *)productID;
+ (NSString *)getName:(NSInteger)productNameID;
+ (ProductName *)getProductNameWithProductID:(NSString *)productID;
+ (ProductName *)getProductNameWithProductNameGroup:(NSString *)productNameGroup;
+ (ProductName *)getProductNameWithProductIDGroup:(NSString *)productIDGroup;
+ (NSInteger)getProductNameIDWithName:(NSString *)name;
+ (NSString *)getNameWithCustomMadeID:(NSInteger)customMadeID;
+ (NSString *)getNameWithProductNameGroup:(NSString *)productNameGroup;
+ (NSString *)getProductNameGroupWithProductName:(ProductName *)productName;
@end
