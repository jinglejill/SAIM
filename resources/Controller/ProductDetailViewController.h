//
//  ProductDetailViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 8/13/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"
#import "Product.h"
#import "CustomMade.h"

@interface ProductDetailViewController : UIViewController<HomeModelProtocol,UITextFieldDelegate>
@property (strong, nonatomic) Product *product;
@property (strong, nonatomic) IBOutlet UIImageView *imvProduct;
@property (strong, nonatomic) IBOutlet UILabel *lblModel;
@property (strong, nonatomic) IBOutlet UILabel *lblColor;
@property (strong, nonatomic) IBOutlet UILabel *lblSize;
@property (strong, nonatomic) IBOutlet UILabel *lblPrice;
@property (strong, nonatomic) IBOutlet UILabel *lblPromotionPrice;
@property (strong, nonatomic) IBOutlet UITextView *txvDetail;
@property (strong, nonatomic) IBOutlet UIButton *btnViewReceipt;

@property (strong, nonatomic) CustomMade *customMade;
@property (nonatomic) NSInteger productType; //0=productStock, 1=productCustomMade, 2=productBooking, 3=productWaitOrder
@property (strong, nonatomic) NSString *productIDGroup;


@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnDelete;
- (IBAction)deleteProductBuy:(id)sender;
- (IBAction)addScan:(id)sender;
- (IBAction)addCustomMade:(id)sender;
- (IBAction)addPreOrder:(id)sender;
- (IBAction)addPreOrder2:(id)sender;
- (IBAction)viewReceipt:(id)sender;
- (IBAction)unwindToProductDetail:(UIStoryboardSegue *)segue;



@end
