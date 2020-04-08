//
//  TrackingNoViewController.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 3/2/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"

@interface TrackingNoViewController : UITableViewController<HomeModelProtocol>
{
    UITextField *txtTrackingNo;
}

@property (strong, nonatomic) NSString *strTrackingNo;
//@property (nonatomic) NSInteger receiptID;
@property (nonatomic) NSInteger receiptProductItemID;
@property (nonatomic) NSInteger postDetailIndex;
@property (strong, nonatomic) NSArray *postDetailList;

@property (nonatomic) BOOL edit;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnDone;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnCancel;

- (IBAction)scanTrackingNo:(id)sender;
- (IBAction)saveTrackingNo:(id)sender;

@end
