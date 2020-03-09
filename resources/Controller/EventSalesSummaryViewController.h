//
//  EventSalesSummaryViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/20/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"

@interface EventSalesSummaryViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,HomeModelProtocol,UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *colViewSummaryTable;
@property (strong, nonatomic) IBOutlet UILabel *lblLocation;
@property (strong, nonatomic) IBOutlet UITextField *txtStartDate;
@property (strong, nonatomic) IBOutlet UITextField *txtEndDate;
@property (strong, nonatomic) IBOutlet UIDatePicker *dtPicker;
- (IBAction)datePickerChanged:(id)sender;

@end
