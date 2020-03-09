//
//  PostCustomer.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/13/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostCustomer : NSObject
@property (nonatomic) NSInteger postCustomerID;
@property (nonatomic) NSInteger customerID;
@property (strong, nonatomic) NSString * firstName;
@property (strong, nonatomic) NSString * street1;
@property (strong, nonatomic) NSString * postcode;
@property (strong, nonatomic) NSString * country;
@property (strong, nonatomic) NSString * telephone;
@property (strong, nonatomic) NSString * lineID;
@property (strong, nonatomic) NSString * facebookID;
@property (strong, nonatomic) NSString * emailAddress;
@property (strong, nonatomic) NSString * other;
@property (strong, nonatomic) NSString * modifiedDate;
@property (strong, nonatomic) NSString * row;
@property (strong, nonatomic) NSString * taxCustomerName;
@property (strong, nonatomic) NSString * taxCustomerAddress;
@property (strong, nonatomic) NSString * taxNo;
@property (nonatomic) NSInteger receiptID;
@property (retain, nonatomic) NSString * modifiedUser;//ใช้ตอน delete row ที่ duplicate key
@property (nonatomic) NSInteger replaceSelf;//ใช้เฉพาะตอน push type = 'd'
@property (nonatomic) NSInteger idInserted;//ใช้ตอน update or delete

+(PostCustomer*)getPostCustomer:(NSInteger)postCustomerID;
+(PostCustomer*)getPostCustomerWithReceiptID:(NSInteger)receiptID postCustomerList:(NSMutableArray *)postCustomerList;
+(NSInteger)getCustomerID:(NSString *)telephone;
+(PostCustomer*)getPostCustomerWithPhoneNo:(NSString *)telephone;
+(NSMutableArray*)getPostCustomerSortByModifiedDate:(NSMutableArray *)postCustomerList;
@end

