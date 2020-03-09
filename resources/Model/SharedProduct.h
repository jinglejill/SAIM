//
//  SharedProduct.h
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 8/4/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedProduct : NSObject
@property (retain, nonatomic) NSMutableArray * productList;
+ (SharedProduct *)sharedProduct;
@end
