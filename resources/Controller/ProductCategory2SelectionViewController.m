//
//  ProductCategory2ChoosingViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 1/13/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "ProductCategory2SelectionViewController.h"
#import "Utility.h"
#import "SharedProductCategory2.h"
#import "ProductCategory2.h"
#import "ProductCategory1ViewController.h"
#import "ProductCategory1SelectionViewController.h"

@interface ProductCategory2SelectionViewController ()
{
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSMutableArray *_defaultList;
    NSString *_selectedProductCategory2;
}
@end

@implementation ProductCategory2SelectionViewController
@synthesize tableViewList;
@synthesize fromMenu;
- (IBAction)unwindToProductCategory2Selection:(UIStoryboardSegue *)segue
{
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
}

- (void)loadView
{
    [super loadView];
    
    {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);        
    }
        
    
    [self loadViewProcess];
}

- (void)loadViewProcess
{
    _defaultList = [SharedProductCategory2 sharedProductCategory2].productCategory2List;
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_name" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortArray = [_defaultList sortedArrayUsingDescriptors:sortDescriptors];
    _defaultList = [sortArray mutableCopy];
}

#pragma mark - UITableViewDataSource

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.000001f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_defaultList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"reuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier: cellIdentifier];
    }
    
    NSInteger row = indexPath.row;
    
    ProductCategory2 *productCategory2 = _defaultList[row];
    cell.textLabel.text = productCategory2.name;

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductCategory2 *productCategory2 = _defaultList[indexPath.row];
    _selectedProductCategory2 = productCategory2.code;
    if(fromMenu == 0)
    {
        [self performSegueWithIdentifier:@"segProductCategory1" sender:self];
    }
    else if(fromMenu == 1)
    {
        [self performSegueWithIdentifier:@"segChooseProductCategory1" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"segProductCategory1"])
    {
        ProductCategory1ViewController *vc = segue.destinationViewController;
        vc.productCategory2 = _selectedProductCategory2;
    }
    if ([[segue identifier] isEqualToString:@"segChooseProductCategory1"])
    {
        ProductCategory1SelectionViewController *vc = segue.destinationViewController;
        vc.productCategory2 = _selectedProductCategory2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark - Life Cycle method
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return YES;
}

- (BOOL)validateData
{
    return YES;
}

-(void) loadingOverlayView
{
    [indicator startAnimating];
    indicator.layer.zPosition = 1;
    indicator.alpha = 1;
    
    
    // and just add them to navigationbar view
    [self.navigationController.view addSubview:overlayView];
    [self.navigationController.view addSubview:indicator];
}

-(void) removeOverlayViews{
    UIView *view = overlayView;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         view.alpha = 0.0;
                         indicator.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         dispatch_async(dispatch_get_main_queue(),^ {
                             [view removeFromSuperview];
                             [indicator stopAnimating];
                             [indicator removeFromSuperview];
                         } );
                     }
     ];
}

@end
