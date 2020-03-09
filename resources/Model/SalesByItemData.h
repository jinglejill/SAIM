//
//  SalesByItemData.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/18/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SalesByItemData : NSObject
@property (retain, nonatomic) NSString * eventID;
@property (retain, nonatomic) NSString * item;
@property (retain, nonatomic) NSString * noOfPair;
@property (retain, nonatomic) NSString * sumValue;
@property (nonatomic) NSInteger intNoOfPair;
@property (nonatomic) float floatSumValue;
@property (nonatomic) float floatSumMargin;
@property (nonatomic) float floatPercent;
@end
