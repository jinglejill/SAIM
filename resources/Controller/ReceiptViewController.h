//
//  ReceiptViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 9/28/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"
#import "CustomUITextView.h"
#import <MessageUI/MFMessageComposeViewController.h>


@interface ReceiptViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,HomeModelProtocol,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *colViewSummaryTable;
- (IBAction)unwindToReceipt:(UIStoryboardSegue *)segue;
@property (strong, nonatomic) IBOutlet UIView *vwMain;
@end
