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
            channel = @"Ev";
            break;
        case 1:
            channel = @"Wb";
            break;
        case 2:
            channel = @"Ln";
            break;
        case 3:
            channel = @"FB";
            break;
        case 4:
            channel = @"MS";
            break;
        case 5:
            channel = @"Ot";
            break;
        case 6:
            channel = @"Sh";
            break;
        case 7:
            channel = @"Lz";
            break;
        case 8:
            channel = @"JD";
            break;
        case 9:
            channel = @"KP";
            break;
        default:
            break;
    }
    return channel;
}
@end
