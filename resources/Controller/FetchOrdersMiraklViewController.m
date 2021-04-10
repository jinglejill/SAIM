//
//  FetchOrdersMiraklViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 5/2/2564 BE.
//  Copyright © 2564 BE Thidaporn Kijkamjai. All rights reserved.
//

#import "FetchOrdersMiraklViewController.h"
#import "MiraklOrder.h"
@interface FetchOrdersMiraklViewController ()
{
    MiraklOrder *_miraklOrder;
}
@end

@implementation FetchOrdersMiraklViewController

@synthesize tbvData;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    tbvData.delegate = self;
    tbvData.dataSource = self;
    
    _miraklOrder = [[MiraklOrder alloc]init];
    [self loadingOverlayView];
    [self.homeModel downloadItems:dbMiraklPendingOrders];
}

-(void)itemsDownloaded:(NSArray *)items
{
    [self removeOverlayViews];
    if(self.homeModel.propCurrentDB == dbMiraklPendingOrders)
    {
        NSMutableArray *miraklOrderList = items[0];
        _miraklOrder = miraklOrderList[0];
        [tbvData reloadData];
    }
    else if(self.homeModel.propCurrentDB == dbMiraklFetchOrders)
    {
        NSMutableArray *miraklOrderList = items[0];
        _miraklOrder = miraklOrderList[0];
        [tbvData reloadData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
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
        cell.detailTextLabel.text = [NSString stringWithFormat:@"#%ld",_miraklOrder.pendingOrderCount];
    }
    else if(indexPath.item == 1)
    {
        cell.textLabel.text = @"Waiting debit order";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"#%ld",_miraklOrder.waitingDebitOrderCount];
    }
    else if(indexPath.item == 2)
    {
        cell.textLabel.text = @"Shipping order";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"#%ld",_miraklOrder.shippingOrderCount];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (IBAction)fetchOrder:(id)sender
{
    [self loadingOverlayView];
    [self.homeModel downloadItems:dbMiraklFetchOrders];
}
@end
