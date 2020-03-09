//
//  CustomCollectionViewFlowLayout.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/20/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "CustomCollectionViewFlowLayout.h"

@implementation CustomCollectionViewFlowLayout
- (NSArray *) layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *answer = [super layoutAttributesForElementsInRect:rect];
    
    for(int i = 1; i < [answer count]; ++i) {
        UICollectionViewLayoutAttributes *currentLayoutAttributes = answer[i];
        UICollectionViewLayoutAttributes *prevLayoutAttributes = answer[i - 1];
        NSInteger maximumSpacing = 0;
//        NSInteger maximumSpacing = 4;
        NSInteger origin = CGRectGetMaxX(prevLayoutAttributes.frame);
        
        if(origin + maximumSpacing + currentLayoutAttributes.frame.size.width < self.collectionViewContentSize.width) {
            CGRect frame = currentLayoutAttributes.frame;
            frame.origin.x = origin + maximumSpacing;
            currentLayoutAttributes.frame = frame;
        }
    }
    return answer;
}

@end
