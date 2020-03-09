//
//  SharedProductDetail.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/12/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedProductDetail : NSObject
@property (retain, nonatomic) NSMutableArray * productDetailList;

+ (SharedProductDetail *)sharedProductDetail;
@end
