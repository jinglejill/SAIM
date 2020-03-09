//
//  CustomCollectionViewFlowLayout.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 10/20/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCollectionViewFlowLayout : UICollectionViewFlowLayout
- (NSArray *) layoutAttributesForElementsInRect:(CGRect)rect;
@end
