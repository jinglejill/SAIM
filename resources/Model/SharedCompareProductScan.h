//
//  SharedCompareProductScan.h
//  SAIM_UPDATING
//
//  Created by Thidaporn Kijkamjai on 6/15/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedCompareProductScan : NSObject
@property (retain, nonatomic) NSMutableArray * compareProductScanList;
+ (SharedCompareProductScan *)sharedCompareProductScan;
@end
