//
//  EventSalesSummary.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/20/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventSalesSummary : NSObject
@property (retain, nonatomic) NSString * eventID;
@property (retain, nonatomic) NSString * noOfDay;
@property (retain, nonatomic) NSString * sumValue;
@property (retain, nonatomic) NSString * noOfPair;
@property (retain, nonatomic) NSString * avgValue;
@property (retain, nonatomic) NSString * avgNoOfPair;
@property (retain, nonatomic) NSString * row;
@property (retain, nonatomic) NSString * periodFrom;
@end
