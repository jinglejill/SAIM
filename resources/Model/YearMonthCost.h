//
//  YearMonthCost.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 23/3/2564 BE.
//  Copyright © 2564 BE Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YearMonthCost : NSObject
@property (retain, nonatomic) NSString *yearMonth;
@property (retain, nonatomic) NSString *costLabel;
@property (nonatomic) float cost;
@property (nonatomic) NSInteger yearMonthCostID;
@property (nonatomic) NSInteger costLabelID;
@end

NS_ASSUME_NONNULL_END
