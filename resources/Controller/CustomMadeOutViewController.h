//
//  CustomMadeOutViewController.h
//  SAIM_UPDATING
//
//  Created by Thidaporn Kijkamjai on 6/21/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"

@interface CustomMadeOutViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,HomeModelProtocol>
@property (strong, nonatomic) IBOutlet UICollectionView *colViewSummaryTable;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnCMOut;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnSelectAll;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnAction;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnCancel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnBack;


- (IBAction)unwindToCustomMadeOut:(UIStoryboardSegue *)segue;
- (IBAction)scanPostAll:(id)sender;
- (IBAction)selectAllAction:(id)sender;
- (IBAction)doAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)backAction:(id)sender;





@end
