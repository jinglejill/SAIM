//
//  ProductNameDetailEditViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 3/13/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"
#import "CustomUITextView.h"

@interface ProductNameDetailEditViewController : UITableViewController<HomeModelProtocol,UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIScrollViewDelegate>
{
    UITextField *txtPrice;
    CustomUITextView *txVwDetail;
    UIButton *btnImage;
    UIImageView *imgVwProductImage;
    UIScrollView *scrVwProductImage;
    
    UISwitch *swtPrice;
    UISwitch *swtDetail;
    UISwitch *swtImage;
    
}

@property (strong, nonatomic) NSMutableArray *arrProductSalesID;
@property (strong, nonatomic) NSMutableArray *productNameDetailList;
@property (nonatomic) BOOL edit;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnDone;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnCancel;

@end
