//
//  PostDetail.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/16/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostDetail : NSObject
@property (retain, nonatomic) NSString * row;
@property (retain, nonatomic) NSString * product;
@property (retain, nonatomic) NSString * customerName;
@property (retain, nonatomic) NSString * trackingNo;
@property (retain, nonatomic) NSString * productType;
@property (nonatomic) NSInteger receiptID;
@property (retain, nonatomic) NSString * receiptDate;
@property (retain, nonatomic) NSString * productID;
@property (nonatomic) NSInteger receiptProductItemID;
@property (retain, nonatomic) NSString * productName;
@property (retain, nonatomic) NSString * color;
@property (retain, nonatomic) NSString * size;
@property (nonatomic) NSInteger sizeOrder;
@property (retain, nonatomic) NSString * editType;//0=edit,1=unselect,2=select
@property (retain, nonatomic) NSString * receiptDateSort;
@property (nonatomic) NSInteger channel;
@property (retain, nonatomic) NSString * channelUserID;

@property (nonatomic) NSInteger hasPostCustomer;
@property (retain, nonatomic) NSString * telephone;
@property (retain, nonatomic) NSString * street1;
@property (retain, nonatomic) NSString * postcode;
@property (retain, nonatomic) NSString * country;
@property (retain, nonatomic) NSString * location;


@end
