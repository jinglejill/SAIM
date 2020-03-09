//
//  MemberAndPoint.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 2/19/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MemberAndPoint : NSObject
@property (nonatomic) NSInteger customerID;
@property (retain, nonatomic) NSString * name;
@property (retain, nonatomic) NSString * phoneNo;
@property (nonatomic) NSInteger pointRemaining;
@property (nonatomic) NSInteger pointSpent;
@property (nonatomic) NSInteger pointAllTime;

@property (nonatomic) NSInteger sumPointRemaining;
@property (nonatomic) NSInteger sumPointSpent;
@property (nonatomic) NSInteger sumPointAllTime;

@property (nonatomic) NSInteger avgPointRemaining;
@property (nonatomic) NSInteger avgPointSpent;
@property (nonatomic) NSInteger avgPointAllTime;

+ (NSMutableArray *)getMemberAndPointSortByPointRemaining:(NSMutableArray *)memberAndPointList;
@end
