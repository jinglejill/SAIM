//
//  AccountMapping.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 2/9/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountMapping : NSObject

@property (nonatomic) NSInteger accountMappingID;
@property (nonatomic) NSInteger receiptID;
@property (nonatomic) NSInteger receiptProductItemID;
@property (nonatomic) NSInteger runningAccountReceiptHistory;
@property (retain, nonatomic) NSString *modifiedDate;

@property (retain, nonatomic) NSString * modifiedUser;//ใช้ตอน delete row ที่ duplicate key
@property (nonatomic) NSInteger replaceSelf;//ใช้เฉพาะตอน push type = 'd'
@property (nonatomic) NSInteger idInserted;//ใช้ตอน update or delete
    
    
@property (nonatomic) NSInteger maxAccountMappingID;
- (NSDictionary *)dictionary;
-(AccountMapping *)initWithAccountMappingID:(NSInteger)accountMappingID receiptID:(NSInteger)receiptID receiptProductItemID:(NSInteger)receiptProductItemID runningAccountReceiptHistory:(NSInteger)runningAccountReceiptHistory;
@end
