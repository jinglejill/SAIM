//
//  ReportTopSpenderViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 31/3/2563 BE.
//  Copyright © 2563 Thidaporn Kijkamjai. All rights reserved.
//

#import "ReportTopSpenderViewController.h"
#import "ReportTopSpenderDetailViewController.h"
#import "CustomTableViewCellTopSpender.h"
#import "TopSpender.h"


@interface ReportTopSpenderViewController ()
{
    NSMutableArray *_topSpenderList;
    TopSpender *_selectedTopSpender;
}
@end
static NSString * const reuseIdentifierTopSpender = @"CustomTableViewCellTopSpender";
@implementation ReportTopSpenderViewController

@synthesize dtPicker;
@synthesize txtStartDate;
@synthesize txtEndDate;
@synthesize segConPeriod;
@synthesize tbvData;
@synthesize lblTelephoneCount;


-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self loadData];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField;
{
    NSString *strDate = textField.text;
    NSDate *datePeriod = [Utility stringToDate:strDate fromFormat:@"yyyy-MM-dd"];
    [dtPicker setDate:datePeriod];
}

- (IBAction)datePickerChanged:(id)sender
{
    if([txtStartDate isFirstResponder])
    {
        txtStartDate.text = [Utility dateToString:dtPicker.date toFormat:@"yyyy-MM-dd"];
    }
    else if([txtEndDate isFirstResponder])
    {
        txtEndDate.text = [Utility dateToString:dtPicker.date toFormat:@"yyyy-MM-dd"];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [dtPicker removeFromSuperview];
    txtStartDate.inputView = dtPicker;
    txtStartDate.delegate = self;

    txtEndDate.inputView = dtPicker;
    txtEndDate.delegate = self;
    
    txtStartDate.text = [Utility dateToString:[Utility addDay:[Utility currentDateTime]  numberOfDay:-6] toFormat:@"yyyy-MM-dd"];
    txtEndDate.text = [Utility dateToString:[Utility currentDateTime] toFormat:@"yyyy-MM-dd"];
    txtStartDate.enabled = NO;
    txtEndDate.enabled = NO;
    
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:11];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                           forKey:NSFontAttributeName];
    [segConPeriod setTitleTextAttributes:attributes
                                    forState:UIControlStateNormal];
    segConPeriod.selectedSegmentIndex = 1;


    //Register table
    tbvData.delegate = self;
    tbvData.dataSource = self;
    tbvData.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    
    {
        UINib *nib = [UINib nibWithNibName:reuseIdentifierTopSpender bundle:nil];
        [tbvData registerNib:nib forCellReuseIdentifier:reuseIdentifierTopSpender];
    }
    
    
    [self loadData];
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tapGesture];
    [tapGesture setCancelsTouchesInView:NO];
}

-(void)loadData
{
    [self loadingOverlayView];
    NSString *strOption = [NSString stringWithFormat:@"%ld",segConPeriod.selectedSegmentIndex];
    [self.homeModel downloadItems:dbReportTopSpender condition:@[txtStartDate.text,txtEndDate.text,strOption]];
}

- (void)itemsDownloaded:(NSArray *)items
{
    [self removeOverlayViews];
    _topSpenderList = items[0];
    
    [tbvData reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    NSString *strTelephoneCount = [Utility formatBaht:[NSString stringWithFormat:@"%ld",[_topSpenderList count]]];
    strTelephoneCount = [NSString stringWithFormat:@"All:%@",strTelephoneCount];
    lblTelephoneCount.text = strTelephoneCount;
    
    return [_topSpenderList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTableViewCellTopSpender *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierTopSpender];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    TopSpender *topSpender = _topSpenderList[indexPath.item];
    cell.lblTelLabel.text = [NSString stringWithFormat:@"%ld. Tel:",indexPath.item+1];
    [cell.lblTelLabel sizeToFit];
    cell.lblTelLabelWidth.constant = cell.lblTelLabel.frame.size.width;
    
    cell.lblTelephone.text = topSpender.telephone;
    cell.lblName.text = topSpender.name;
    cell.lblSales.text = [Utility formatBaht:[NSString stringWithFormat:@"%f", topSpender.sales]];
    cell.lblOrders.text = [NSString stringWithFormat:@"%ld", topSpender.orders];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedTopSpender = _topSpenderList[indexPath.item];
    [self performSegueWithIdentifier:@"segReportTopSpenderDetail" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"segReportTopSpenderDetail"])
    {
        
        ReportTopSpenderDetailViewController *vc = segue.destinationViewController;
        vc.txtStartDate = txtStartDate;
        vc.txtEndDate = txtEndDate;
        vc.segConPeriod = segConPeriod;
        vc.selectedTopSpender = _selectedTopSpender;
    }
}

- (IBAction)segConPeriodValueChanged:(id)sender
{
    if(segConPeriod.selectedSegmentIndex == 0)
    {
        txtStartDate.enabled = YES;
        txtEndDate.enabled = YES;
    }
    else
    {
        txtStartDate.enabled = NO;
        txtEndDate.enabled = NO;
    }
    [self loadData];
}
@end
