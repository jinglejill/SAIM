//
//  SharedPostCode.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 10/6/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedPostCode : NSObject
@property (retain, nonatomic) NSMutableArray * postcodeList;
+ (SharedPostCode *)sharedPostCode;

@end
