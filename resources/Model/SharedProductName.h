//
//  SharedProductName.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/13/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedProductName : NSObject
@property (retain, nonatomic) NSMutableArray * productNameList;
+ (SharedProductName *)sharedProductName;

@end
