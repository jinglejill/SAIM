//
//  SharedProductCategory2.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/12/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedProductCategory2 : NSObject
@property (retain, nonatomic) NSMutableArray * productCategory2List;

+ (SharedProductCategory2 *)sharedProductCategory2;
@end
