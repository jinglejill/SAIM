//
//  TopSpender.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 31/3/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TopSpender : NSObject

@property (retain, nonatomic) NSString * telephone;
@property (retain, nonatomic) NSString * name;
@property (nonatomic) float sales;
@property (nonatomic) NSInteger orders;
@property (nonatomic) NSInteger countFirstName;



@end

NS_ASSUME_NONNULL_END
