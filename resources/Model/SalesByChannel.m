//
//  SalesByChannel.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 3/10/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import "SalesByChannel.h"

@implementation SalesByChannel
+(NSString *)getChannel:(NSInteger)channelID
{
    NSString *channel;
    switch (channelID) {
        case 0:
            channel = @"Event";
            break;
        case 1:
            channel = @"Web";
            break;
        case 2:
            channel = @"Line";
            break;
        case 3:
            channel = @"FB";
            break;
        case 4:
            channel = @"Shop";
            break;
        case 5:
            channel = @"Other";
            break;
        default:
            break;
    }
    return channel;
}
@end
