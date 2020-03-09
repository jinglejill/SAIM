//
//  SharedProductCategory1.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/12/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedProductCategory1 : NSObject
@property (retain, nonatomic) NSMutableArray * productCategory1List;

+ (SharedProductCategory1 *)sharedProductCategory1;
@end
