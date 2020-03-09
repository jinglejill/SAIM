//
//  ProductStatusSummary.h
//  SAIM_UPDATING
//
//  Created by Thidaporn Kijkamjai on 7/24/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductStatusSummary : NSObject
@property (nonatomic) NSInteger eventID;
@property (nonatomic) NSInteger amount;
@property (retain, nonatomic) NSString * row;
@property (retain, nonatomic) NSString * status;
@property (strong, nonatomic) NSString * location;
@property (strong, nonatomic) NSString * periodTo;

@end
