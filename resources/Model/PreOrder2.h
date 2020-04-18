//
//  PreOrder2.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 15/4/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PreOrder2 : NSObject

@property (nonatomic) NSInteger preOrder2ID;
@property (nonatomic) NSInteger receiptProductItemID;
@property (nonatomic) NSInteger productNameID;
@property (retain, nonatomic) NSString * color;
@property (retain, nonatomic) NSString * size;
@property (retain, nonatomic) NSString * modifiedDate;
@end

NS_ASSUME_NONNULL_END
