//
//  SharedProductDelete.h
//  SAIM_UPDATING
//
//  Created by Thidaporn Kijkamjai on 4/25/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedProductDelete : NSObject
@property (retain, nonatomic) NSMutableArray * productDeleteList;
+ (SharedProductDelete *)sharedProductDelete;
@end
