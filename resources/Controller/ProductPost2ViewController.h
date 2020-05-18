//
//  ProductPost2ViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/15/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"

@interface ProductPost2ViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate,HomeModelProtocol>
@property (strong, nonatomic) IBOutlet UICollectionView *colViewSummaryTable;


- (IBAction)unwindToProductPost2:(UIStoryboardSegue *)segue;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnSelectAll;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnBack;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnAction;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnCancel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnAddress;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnScanPost;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnMove;


@property (strong, nonatomic) IBOutlet UILabel *lblLocation;
@property (strong, nonatomic) IBOutlet UITextField *txtLocation;
@property (strong, nonatomic) IBOutlet UIPickerView *txtPicker;
@property (strong, nonatomic) IBOutlet UILabel *lblNotifyMessage;

- (IBAction)selectAllAction:(id)sender;
- (IBAction)doAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)moveAction:(id)sender;
- (IBAction)addressAction:(id)sender;
- (IBAction)scanPostAll:(id)sender;
- (IBAction)backAction:(id)sender;
@end
