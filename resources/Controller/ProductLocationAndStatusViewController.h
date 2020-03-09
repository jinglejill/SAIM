//
//  ProductLocationAndStatusViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/9/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Homemodel.h"
#import "Product.h"


@interface ProductLocationAndStatusViewController : UIViewController<HomeModelProtocol,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) Product *product;
@property (strong, nonatomic) IBOutlet UIImageView *imvProduct;
@property (strong, nonatomic) IBOutlet UILabel *lblModel;
@property (strong, nonatomic) IBOutlet UILabel *lblColor;
@property (strong, nonatomic) IBOutlet UILabel *lblSize;
@property (strong, nonatomic) IBOutlet UILabel *lblManufacturingDate;
@property (strong, nonatomic) IBOutlet UILabel *lblPrice;

@property (strong, nonatomic) IBOutlet UITextView *txvDetail;
@property (strong, nonatomic) IBOutlet UICollectionView *colVwData;


@end
