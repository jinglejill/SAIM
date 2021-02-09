//
//  FetchOrdersJDViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/11/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import "FetchOrdersJDViewController.h"
#import "JDOrder.h"

@interface FetchOrdersJDViewController ()
{
    JDOrder *_jdOrder;
}
@end

@implementation FetchOrdersJDViewController
@synthesize tbvData;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    tbvData.delegate = self;
    tbvData.dataSource = self;
    
    _jdOrder = [[JDOrder alloc]init];
    [self loadingOverlayView];
    [self.homeModel downloadItems:dbJDPendingOrders];
}

-(void)itemsDownloaded:(NSArray *)items
{
    [self removeOverlayViews];
    if(self.homeModel.propCurrentDB == dbJDPendingOrders)
    {
        NSMutableArray *jdOrderList = items[0];
        _jdOrder = jdOrderList[0];
        [tbvData reloadData];
    }
    else if(self.homeModel.propCurrentDB == dbJDFetchOrders)
    {
        NSMutableArray *jdOrderList = items[0];
        _jdOrder = jdOrderList[0];
        [tbvData reloadData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(indexPath.item == 0)
    {
        cell.textLabel.text = @"Pending order";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"#%ld",_jdOrder.pendingOrderCount];
    }
//    else if(indexPath.item == 1)
//    {
//        cell.textLabel.text = @"Pending return to ship";
//        cell.detailTextLabel.text = [NSString stringWithFormat:@"#%ld",_lazadaOrder.pendingReturnToShipCount];
//    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (IBAction)fetchOrder:(id)sender
{
    [self loadingOverlayView];
    [self.homeModel downloadItems:dbJDFetchOrders];
}

@end
