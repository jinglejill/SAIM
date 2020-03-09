//
//  SharedGenerateQRCodePage.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 9/11/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "SharedGenerateQRCodePage.h"

@implementation SharedGenerateQRCodePage
@synthesize dicGenerateQRCodePage;

+ (SharedGenerateQRCodePage *)sharedGenerateQRCodePage
{
    static dispatch_once_t pred;
    static SharedGenerateQRCodePage *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SharedGenerateQRCodePage alloc] init];
        shared.dicGenerateQRCodePage = [[NSMutableDictionary alloc]init];
    });
    return shared;
}
@end
