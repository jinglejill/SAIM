//
//  MemberReceiptViewController.h
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 4/16/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Receipt.h"
#import "HomeModel.h"
#import "MemberAndPoint.h"


@interface MemberReceiptViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,HomeModelProtocol>
@property (strong, nonatomic) IBOutlet UICollectionView *colViewData;
@property (strong, nonatomic) NSMutableArray *selectedReceiptList;
@property (strong, nonatomic) NSMutableArray *selectedReceiptProductItemList;
@property (strong, nonatomic) MemberAndPoint *selectedMemberAndPoint;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblPhoneNo;

@end
