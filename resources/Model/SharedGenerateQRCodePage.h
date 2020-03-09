//
//  SharedGenerateQRCodePage.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 9/11/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedGenerateQRCodePage : NSObject
@property (retain, nonatomic) NSMutableDictionary *dicGenerateQRCodePage;

+ (SharedGenerateQRCodePage *)sharedGenerateQRCodePage;

@end
