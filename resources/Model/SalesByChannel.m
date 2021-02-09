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
        case 10:
            channel = @"CT";
            break;
        case 11:
            channel = @"Rb";
            break;
        case 12:
            channel = @"Ig";
            break;
        default:
            break;
    }
    return channel;
}

+(UIColor *)getColor:(NSInteger)channelID
{
    NSString *channel;
    UIColor *color = [UIColor clearColor];
    switch (channelID) {
        case 0:
            channel = @"Ev";
            break;
        case 1:
            color = [UIColor colorWithRed:247/255.0 green:204/255.0 blue:212/255.0 alpha:0.2];
            channel = @"Wb";
            break;
        case 2:
            color = [UIColor colorWithRed:87/255.0 green:188/255.0 blue:55/255.0 alpha:0.2];
            channel = @"Ln";
            break;
        case 3:
            color = [UIColor colorWithRed:68/255.0 green:155/255.0 blue:240/255.0 alpha:0.2];
            channel = @"FB";
            break;
        case 4:
            channel = @"MS";
            break;
        case 5:
            channel = @"Ot";
            break;
        case 6:
            color = [UIColor colorWithRed:238/255.0 green:109/255.0 blue:67/255.0 alpha:0.2];
            channel = @"Sh";
            break;
        case 7:
            color = [UIColor colorWithRed:26/255.0 green:75/255.0 blue:184/255.0 alpha:0.2];
            channel = @"Lz";
            break;
        case 8:
            color = [UIColor colorWithRed:200/255.0 green:42/255.0 blue:38/255.0 alpha:0.2];
            channel = @"JD";
            break;
        case 9:
            color = [UIColor colorWithRed:75/255.0 green:165/255.0 blue:90/255.0 alpha:0.2];
            channel = @"KP";
            break;
        case 10:
            color = [UIColor colorWithRed:161/255.0 green:39/255.0 blue:47/255.0 alpha:0.2];
            channel = @"CT";
            break;
        case 11:
            color = [UIColor colorWithRed:132/255.0 green:188/255.0 blue:86/255.0 alpha:0.2];
            channel = @"Rb";
            break;
        case 12:
            color = [UIColor colorWithRed:250/255.0 green:179/255.0 blue:2/255.0 alpha:0.2];
            channel = @"Rb";
            break;
        default:
            break;
    }
    return color;
}

@end
