//
//  ProductionOrder.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 3/11/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import "ProductionOrder.h"
#import "Utility.h"


@implementation ProductionOrder


- (ProductionOrder *)initWithProductionOrderID:(NSInteger)productionOrderID runningPoNo:(NSInteger)runningPoNo productNameID:(NSInteger)productNameID color:(NSString *)color size:(NSString *)size quantity:(float)quantity status:(NSInteger)status orderDeliverDate:(NSString *)orderDeliverDate modifiedDate:(NSString *)modifiedDate;
{
    self = [super init];
    if(self)
    {
        self.productionOrderID = productionOrderID;
        self.runningPoNo = runningPoNo;
        self.color = color;
        self.size = size;
        self.productNameID = productNameID;
        self.quantity = quantity;
        self.status = status;
        self.orderDeliverDate = orderDeliverDate;
        self.modifiedDate = modifiedDate;
        self.modifiedUser = [Utility modifiedUser];
    }
    
    return self;
}

+ (ProductionOrder *)getProductionOrderFromRunningPoNo:(NSInteger)runningPoNo productNameID:(NSInteger)productNameID color:(NSString *)color size:(NSString *)size fromProductOrderList:(NSMutableArray *)productOrderList;
{
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"_runningPoNo = %ld and _productNameID = %ld and _color = %@ and _size = %@",runningPoNo,productNameID,color,size];
    NSArray *filterArray = [productOrderList filteredArrayUsingPredicate:predicate1];
    
    if([filterArray count] > 0)
    {
        return filterArray[0];
    }
    return nil;
}
@end
