//
//  SharedProductSize.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 1/1/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedProductSize : NSObject
@property (retain, nonatomic) NSMutableArray * productSizeList;

+ (SharedProductSize *)sharedProductSize;

@end
