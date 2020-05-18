//
//  FetchOrdersLazadaViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 18/5/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import "FetchOrdersLazadaViewController.h"
#import "LazadaOrder.h"
@interface FetchOrdersLazadaViewController ()
{
    LazadaOrder *_lazadaOrder;
}
@end

@implementation FetchOrdersLazadaViewController
@synthesize tbvData;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    tbvData.delegate = self;
    tbvData.dataSource = self;
    
    _lazadaOrder = [[LazadaOrder alloc]init];
    [self loadingOverlayView];
    [self.homeModel downloadItems:dbLazadaPendingOrders];
}

-(void)itemsDownloaded:(NSArray *)items
{
    [self removeOverlayViews];
    if(self.homeModel.propCurrentDB == dbLazadaPendingOrders)
    {
        NSMutableArray *lazadaOrderList = items[0];
        _lazadaOrder = lazadaOrderList[0];
        [tbvData reloadData];
    }
    else if(self.homeModel.propCurrentDB == dbLazadaFetchOrders)
    {
        NSMutableArray *lazadaOrderList = items[0];
        _lazadaOrder = lazadaOrderList[0];
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
        cell.detailTextLabel.text = [NSString stringWithFormat:@"#%ld",_lazadaOrder.pendingOrderCount];
    }
    else if(indexPath.item == 1)
    {
        cell.textLabel.text = @"Pending return to ship";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"#%ld",_lazadaOrder.pendingReturnToShipCount];
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
    [self.homeModel downloadItems:dbLazadaFetchOrders];
}
@end
