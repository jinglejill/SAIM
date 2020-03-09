//
//  SharedComparingScan.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/1/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedComparingScan : NSObject
@property (retain, nonatomic) NSMutableArray * comparingScan;
+ (SharedComparingScan *)sharedComparingScan;

@end
