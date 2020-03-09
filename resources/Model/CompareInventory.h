//
//  CompareInventory.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/30/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CompareInventory : NSObject
@property (nonatomic) NSInteger compareInventoryID;
@property (retain, nonatomic) NSString * runningSetNo;
@property (retain, nonatomic) NSString * productID;
@property (retain, nonatomic) NSString * productCode;
@property (retain, nonatomic) NSString * compareStatus;
//@property (retain, nonatomic) NSString * compareStatusForFilter;
@property (retain, nonatomic) NSString * compareStatusRemark;
@property (nonatomic) NSInteger compareStatusForSort;
@property (retain, nonatomic) NSString * modifiedDate;
@property (retain, nonatomic) NSString * row;
@property (retain, nonatomic) NSString * productName;
@property (retain, nonatomic) NSString * color;
@property (retain, nonatomic) NSString * size;
@property (nonatomic) NSInteger sizeOrder;
@property (retain, nonatomic) NSString * productCategory2;
@property (retain, nonatomic) NSString * checkOrUnCheck;
@property (retain, nonatomic) NSString * productCategory2Code;
@property (retain, nonatomic) NSString * productCategory1Code;
@property (retain, nonatomic) NSString * productNameCode;
@property (retain, nonatomic) NSString * colorCode;
@property (retain, nonatomic) NSString * sizeCode;
@property (retain, nonatomic) NSString * manufacturingDate;


@end
