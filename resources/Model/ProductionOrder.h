//
//  ProductionOrder.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 3/11/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductionOrder : NSObject
@property (nonatomic) NSInteger productionOrderID;
@property (nonatomic) NSInteger runningPoNo;
@property (nonatomic) NSInteger productNameID;
@property (retain, nonatomic) NSString * color;
@property (retain, nonatomic) NSString * size;
@property (nonatomic) float quantity;
@property (nonatomic) NSInteger status;
@property (retain, nonatomic) NSString * orderDeliverDate;
@property (retain, nonatomic) NSString * modifiedDate;
@property (retain, nonatomic) NSString * productName;
@property (retain, nonatomic) NSString * colorName;
@property (retain, nonatomic) NSString * sizeName;
@property (nonatomic) float quantityRemaining;
@property (retain, nonatomic) NSString * modifiedUser;//ใช้ตอน delete row ที่ duplicate key
@property (nonatomic) NSInteger replaceSelf;//ใช้เฉพาะตอน push type = 'd'
@property (nonatomic) NSInteger idInserted;//ใช้ตอน update or delete


- (ProductionOrder *)initWithProductionOrderID:(NSInteger)productionOrderID runningPoNo:(NSInteger)runningPoNo productNameID:(NSInteger)productNameID color:(NSString *)color size:(NSString *)size quantity:(float)quantity status:(NSInteger)status orderDeliverDate:(NSString *)orderDeliverDate modifiedDate:(NSString *)modifiedDate;
+ (ProductionOrder *)getProductionOrderFromRunningPoNo:(NSInteger)runningPoNo productNameID:(NSInteger)productNameID color:(NSString *)color size:(NSString *)size fromProductOrderList:(NSMutableArray *)productOrderList;
@end
