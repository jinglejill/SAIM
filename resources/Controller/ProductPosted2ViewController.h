//
//  ProductPosted2ViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/19/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"

@interface ProductPosted2ViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate,HomeModelProtocol>
@property (strong, nonatomic) IBOutlet UICollectionView *colViewSummaryTable;
@property (nonatomic) BOOL fromUserMenu;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnUnpost;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnAction;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnCancel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnBack;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnSelectAll;
@property (strong, nonatomic) IBOutlet UILabel *lblLocation;
@property (strong, nonatomic) IBOutlet UITextField *txtLocation;
@property (strong, nonatomic) IBOutlet UIPickerView *txtPicker;
- (IBAction)doAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)selectAllAction:(id)sender;
- (IBAction)unwindToProductPosted2:(UIStoryboardSegue *)segue;
- (IBAction)Unpost:(id)sender;
- (IBAction)backAction:(id)sender;
@end
