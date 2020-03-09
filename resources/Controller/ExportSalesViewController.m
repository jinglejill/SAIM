//
//  ExportSalesViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 3/23/2559 BE.
//  Copyright © 2559 Thidaporn Kijkamjai. All rights reserved.
//

#import "ExportSalesViewController.h"
#import "ChartSalesByChannelViewController.h"
#import "ChartSalesByZoneViewController.h"
#import "HomeModel.h"
#import "Utility.h"
#import "RootViewController.h"
#import "SharedSelectedEvent.h"
#import "Event.h"
#import "SharedReceiptItem.h"
#import "SharedReceipt.h"
#import "SharedProduct.h"




#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]
@interface ExportSalesViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    Event *_event;
    
    
    UITextField *_txtPeriodFrom;
    UITextField *_txtPeriodTo;
    UITextField *_periodFirstResponder;
    UIDatePicker *datePickerPeriod;
    Event *_periodCondition;

}
@end
@implementation ExportSalesViewController
static NSString * const reuseIdentifier = @"Cell";
@synthesize tbv;
@synthesize btnExport;
@synthesize btnChart;
@synthesize fromMenu;


- (IBAction)unwindToExportSales:(UIStoryboardSegue *)segue{}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register cell classes
    [tbv registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseIdentifier];
}

- (void)loadView
{
    [super loadView];
    
    // Create new HomeModel object and assign it to _homeModel variable
    _homeModel = [[HomeModel alloc] init];
    _homeModel.delegate = self;
    
    {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);
    }
    
    //communicate dropbox
    [self communicateDropbox];
    
    
    float controlWidth = 150;//cell.c tableView.bounds.size.width - 15*2;//minus left, right margin
    float controlXOrigin = 151;//15;
    float controlYOrigin = (44 - 25)/2;//table row height minus control height and set vertical center
    _txtPeriodFrom = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, 25.0f)];
    _txtPeriodFrom.clearButtonMode = UITextFieldViewModeWhileEditing;
    _txtPeriodFrom.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
    [_txtPeriodFrom setKeyboardType:UIKeyboardTypeDefault];
    
    
    _txtPeriodTo = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, 25.0f)];
    _txtPeriodTo.clearButtonMode = UITextFieldViewModeWhileEditing;
    _txtPeriodTo.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
    [_txtPeriodTo setKeyboardType:UIKeyboardTypeDefault];
    
    
    datePickerPeriod = [[UIDatePicker alloc]init];
    datePickerPeriod.frame = CGRectMake(10,88+64, self.view.frame.size.width, 200);
    datePickerPeriod.datePickerMode = UIDatePickerModeDate;
    [datePickerPeriod addTarget:self action:@selector(dateIsChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    _txtPeriodFrom.inputView = datePickerPeriod;
    _txtPeriodTo.inputView = datePickerPeriod;
    
    
    _txtPeriodFrom.delegate = self;
    _txtPeriodTo.delegate = self;
    [self loadViewProcess];
}

- (void)loadViewProcess
{
    _event = [Event getSelectedEvent];
    if(fromMenu == 0)//all event
    {
        self.navigationItem.title = [NSString stringWithFormat:@"Export Sales"];
        _txtPeriodFrom.text = [Utility dateToString:[NSDate date] toFormat:@"01/MM/yyyy"];
        _txtPeriodTo.text = [Utility dateToString:[NSDate date] toFormat:[Utility setting:vFormatDateDisplay]];
    }
    else if(fromMenu == 1)//selected event
    {
        self.navigationItem.title = [NSString stringWithFormat:@"Export Sales - %@",_event.location];
        _txtPeriodFrom.text = [Utility formatDateForDisplay:_event.periodFrom];
        _txtPeriodTo.text = [Utility formatDateForDisplay:_event.periodTo];
    }
    else if(fromMenu == 2)//sales by zone
    {
        self.navigationItem.title = [NSString stringWithFormat:@"Sales by Zone"];
        _txtPeriodFrom.text = [Utility dateToString:[NSDate date] toFormat:@"01/MM/yyyy"];
        _txtPeriodTo.text = [Utility dateToString:[NSDate date] toFormat:[Utility setting:vFormatDateDisplay]];
    }
    else if(fromMenu == 3)//sales by channel
    {
        self.navigationItem.title = [NSString stringWithFormat:@"Sales by Channel"];
        _txtPeriodFrom.text = [Utility dateToString:[NSDate date] toFormat:@"01/MM/yyyy"];
        _txtPeriodTo.text = [Utility dateToString:[NSDate date] toFormat:[Utility setting:vFormatDateDisplay]];
    }

    [datePickerPeriod setDate:[NSDate date]];
}

-(BOOL) validateData
{
    if([_txtPeriodFrom.text isEqualToString:@""])
    {
        _txtPeriodFrom.text = [Utility dateToString:[NSDate date] toFormat:[Utility setting:vFormatDateDisplay]];
    }
    
    if([_txtPeriodTo.text isEqualToString:@""])
    {
        _txtPeriodTo.text = [Utility dateToString:[NSDate date] toFormat:[Utility setting:vFormatDateDisplay]];
    }
    
    //period to> period from
    if([self isPeriodToLessThanPeriodFrom])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invalid data"
                                                                       message:[Utility msg:periodToLessThanPeriodFrom]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    return YES;
}

- (BOOL)isPeriodToLessThanPeriodFrom
{
    NSDate *datePeriodTo = [Utility stringToDate:_txtPeriodTo.text fromFormat:[Utility setting:vFormatDateDisplay]];
    NSDate *datePeriodFrom = [Utility stringToDate:_txtPeriodFrom.text fromFormat:[Utility setting:vFormatDateDisplay]];
    NSComparisonResult result = [datePeriodFrom compare:datePeriodTo];
    if(result == NSOrderedDescending)
    {
        return YES;
    }
    return NO;
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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    }
    
    if ([_txtPeriodFrom isDescendantOfView:cell]) {
        [_txtPeriodFrom removeFromSuperview];
    }
    if ([_txtPeriodTo isDescendantOfView:cell]) {
        [_txtPeriodTo removeFromSuperview];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSInteger row = indexPath.row;
    
    if(row == 0)
    {
        cell.textLabel.text = @"Period from";
        [cell.textLabel setTextColor:tBlueColor];
        [cell addSubview:_txtPeriodFrom];
    }
    else if(row == 1)
    {
        cell.textLabel.text = @"Period to";
        [cell.textLabel setTextColor:tBlueColor];
        [cell addSubview:_txtPeriodTo];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"segChartSalesByZone"])
    {
        ChartSalesByZoneViewController *vc = segue.destinationViewController;
        vc.periodCondition = _periodCondition;
    }
    else if([[segue identifier] isEqualToString:@"segChartSalesByChannel"])
    {
        ChartSalesByChannelViewController *vc = segue.destinationViewController;
        vc.periodCondition = _periodCondition;
    }
}

- (IBAction)chartButtonClicked:(id)sender
{
    [datePickerPeriod removeFromSuperview];
    [_txtPeriodFrom resignFirstResponder];
    [_txtPeriodTo resignFirstResponder];
    
    if(![self validateData])
    {
        return;
    }
    
    NSString *strPeriodTo = [Utility formatDateForDB:_txtPeriodTo.text];
    NSString *strPeriodFrom = [Utility formatDateForDB:_txtPeriodFrom.text];
    NSString *strEventID = [NSString stringWithFormat:@"%ld",_event.eventID];
    strEventID = fromMenu == 0?@"":strEventID;
    _periodCondition = [[Event alloc]init];
    _periodCondition.periodFrom = [NSString stringWithFormat:@"%@ 00:00:00", strPeriodFrom];
    _periodCondition.periodTo = [NSString stringWithFormat:@"%@ 23:59:59", strPeriodTo];
    

    if(fromMenu == 2)
    {
        [self performSegueWithIdentifier:@"segChartSalesByZone" sender:self];
    }
    else if(fromMenu == 3)
    {
        [self performSegueWithIdentifier:@"segChartSalesByChannel" sender:self];
    }
}

- (IBAction)exportButtonClicked:(id)sender {
    [datePickerPeriod removeFromSuperview];
    [_txtPeriodFrom resignFirstResponder];
    [_txtPeriodTo resignFirstResponder];
    
    if(![self validateData])
    {
        return;
    }
    
    //do export sales to dropbox
    //check link dropbox
    if ([[DBSession sharedSession] isLinked]) {
        [self loadingOverlayView];
        NSLog(@"link already");
        
        
        NSDate *datePeriodTo = [Utility stringToDate:_txtPeriodTo.text fromFormat:[Utility setting:vFormatDateDisplay]];
        int daysToAdd = 1;
        datePeriodTo = [datePeriodTo dateByAddingTimeInterval:60*60*24*daysToAdd-1];
        
        NSString *strPeriodTo = [Utility dateToString:datePeriodTo toFormat:[Utility setting:vFormatDateDB]];
        NSString *strPeriodFrom = [Utility formatDateForDB:_txtPeriodFrom.text];
        NSString *strEventID = [NSString stringWithFormat:@"%ld",_event.eventID];
        strEventID = fromMenu == 0?@"":strEventID;
        [_homeModel generateSalesPeriodFrom:strPeriodFrom periodTo:strPeriodTo eventID:strEventID];
    }
    else
    {
        [self.navigationController pushViewController:[[RootViewController alloc] initWithNibName: @"RootViewController" bundle: nil] animated:YES];
    }
}

-(void)removeOverlayViewConnectionFail
{
    [self removeOverlayViews];
    [self connectionFail];
}

- (void)salesGeneratedFail
{
    [self removeOverlayViews];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Fail"
                                                                   message:@"Generate sales fail"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    dispatch_async(dispatch_get_main_queue(),^ {
        [self presentViewController:alert animated:YES completion:nil];
    } );
}

- (void)salesGenerated:(NSString *)fileName
{
    [self removeOverlayViews];
    NSArray* foo = [fileName componentsSeparatedByString: @"."];
    NSString* firstBit = [foo objectAtIndex: 0];
    
    
    //generate sales เสร็จแล้ว ให้ download file ที่ได้ upload เข้า dropbox
    [_homeModel downloadFileWithFileName:fileName completionBlock:^(BOOL succeeded, NSData *data) {
        if (succeeded) {
            NSLog(@"download file successful");
            NSURL *tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
            NSURL *fileURL = [[tmpDirURL URLByAppendingPathComponent:firstBit] URLByAppendingPathExtension:@"xls"];
            NSLog(@"fileURL: %@", [fileURL path]);
            
            [data writeToFile:[fileURL path] atomically:YES];
            [self.restClient uploadFile:fileName toPath:@"/" withParentRev:nil fromPath:[fileURL path]];
            
            
            
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                           message:@"Generate sales success"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            NSLog(@"download file fail");
            
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Fail"
                                                                           message:@"Generate sales fail"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}

- (void)communicateDropbox
{
    // Set these variables before launching the app
    NSString *appKey = [Utility getAppKey];
    NSString *appSecret = [Utility getAppSecret];
    NSString *root = kDBRootAppFolder; // Should be set to either kDBRootAppFolder or kDBRootDropbox
    // You can determine if you have App folder access or Full Dropbox along with your consumer key/secret
    // from https://dropbox.com/developers/apps
    
    // Look below where the DBSession is created to understand how to use DBSession in your app
    
    NSString* errorMsg = nil;
    if ([appKey rangeOfCharacterFromSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]].location != NSNotFound) {
        errorMsg = @"Make sure you set the app key correctly in DBRouletteAppDelegate.m";
    } else if ([appSecret rangeOfCharacterFromSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]].location != NSNotFound) {
        errorMsg = @"Make sure you set the app secret correctly in DBRouletteAppDelegate.m";
    } else if ([root length] == 0) {
        errorMsg = @"Set your root to use either App Folder of full Dropbox";
    } else {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
        NSData *plistData = [NSData dataWithContentsOfFile:plistPath];
        
        
        
        NSDictionary *loadedPlist = (NSDictionary *)[NSPropertyListSerialization propertyListWithData:plistData options:NSPropertyListMutableContainersAndLeaves format:NULL error:NULL];
        
        
        NSString *scheme = [[[[loadedPlist objectForKey:@"CFBundleURLTypes"] objectAtIndex:0] objectForKey:@"CFBundleURLSchemes"] objectAtIndex:0];
        if ([scheme isEqual:@"db-APP_KEY"]) {
            errorMsg = @"Set your URL scheme correctly in DBRoulette-Info.plist";
        }
    }
    
    DBSession *session =
    [[DBSession alloc] initWithAppKey:appKey appSecret:appSecret root:root];
    session.delegate = self; // DBSessionDelegate methods allow you to handle re-authenticating
    [DBSession setSharedSession:session];
    
    
    [DBRequest setNetworkRequestDelegate:self];
    
    if (errorMsg != nil) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error Configuring Session"
                                                                       message:errorMsg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark -
#pragma mark DBNetworkRequestDelegate methods

static int outstandingRequests;

- (void)networkRequestStarted {
    outstandingRequests++;
    if (outstandingRequests == 1) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}

- (void)networkRequestStopped {
    outstandingRequests--;
    if (outstandingRequests == 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

#pragma mark DBRestClientDelegate methods

- (DBRestClient*)restClient {
    if (restClient == nil) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath
          metadata:(DBMetadata*)metadata
{
    NSLog(@"upload to dropbox successful");
}
- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
    //parse the error data for the file name
    NSString *fullErrorData = [NSString stringWithFormat:@"%@",error];
    NSString *answer;
    NSString *message;
    
    if ([fullErrorData containsString:@"FileBase"]) {
        NSRange range = [fullErrorData rangeOfString:@"FileBase"];
        NSRange newRange = {range.location,21};//the known length
        answer = [fullErrorData substringWithRange:newRange];
        
        message = [NSString stringWithFormat: @"The upload for file %@ failed. The remnants will be automatically deleted. You may receive an error message about the deletion - dismiss it.", answer];
    } else {
        message = @"Could not determine the file upload that failed.";
    }
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(fromMenu == 0 || fromMenu == 1)
    {
        [btnExport.target performSelector:btnExport.action];
    }
    else
    {
        [btnChart.target performSelector:btnChart.action];
    }
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([textField isEqual:_txtPeriodFrom] || [textField isEqual:_txtPeriodTo])
    {
        return NO;
    }
    return YES;
}

// became first responder
- (void)textFieldDidBeginEditing:(UITextField *)textField;
{
    if(![datePickerPeriod isDescendantOfView:tbv])
    {
        [tbv addSubview:datePickerPeriod];
    }
    
    if([textField isEqual:_txtPeriodFrom] || [textField isEqual:_txtPeriodTo])
    {
        _periodFirstResponder = textField;
        
        //set initial value when tap textfield
        if([textField.text isEqualToString:@""])
        {
            [self setPeriodValue];
        }
        //set initial value for datepicker if textfield has value.
        else
        {
            NSString *strPeriod = textField.text;
            NSDate *datePeriod = [Utility stringToDate:strPeriod fromFormat:[Utility setting:vFormatDateDisplay]];
            [datePickerPeriod setDate:datePeriod];
        }
    }
}

- (void)dateIsChanged:(id)sender {
    [self setPeriodValue];
}

- (void)setPeriodValue
{
    NSString *formatedDate = [Utility dateToString:datePickerPeriod.date toFormat:[Utility setting:vFormatDateDisplay]];
    if([_periodFirstResponder isEqual:_txtPeriodFrom])
    {
        _txtPeriodFrom.text = formatedDate;
    }
    else if([_periodFirstResponder isEqual:_txtPeriodTo])
    {
        _txtPeriodTo.text = formatedDate;
    }
}
- (void) connectionFail
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[Utility subjectNoConnection]
                                                                   message:[Utility detailNoConnection]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              //                                                              exit(0);
                                                          }];
    
    [alert addAction:defaultAction];
    
    dispatch_async(dispatch_get_main_queue(),^ {
        [self presentViewController:alert animated:YES completion:nil];
    } );
}

@end
