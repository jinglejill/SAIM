//
//  ExpenseDaily.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/3/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExpenseDaily : NSObject
@property (nonatomic) NSInteger expenseDailyID;
@property (strong, nonatomic) NSString * eventID;
@property (strong, nonatomic) NSString * name;
@property (strong, nonatomic) NSString * amount;
@property (strong, nonatomic) NSString * inputDate;
@property (strong, nonatomic) NSString * modifiedDate;
@end

NS_ASSUME_NONNULL_END
