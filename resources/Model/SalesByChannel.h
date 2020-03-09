//
//  SalesByChannel.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 3/10/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SalesByChannel : NSObject
@property (nonatomic) NSInteger channel;
@property (nonatomic) float sales;

+(NSString *)getChannel:(NSInteger)channelID;
@end
