//
//  AddEditEventViewController.m
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/27/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "AddEditEventViewController.h"
#import "Utility.h"
#import "EventViewController.h"
#import "ProductSalesSetViewController.h"


@interface AddEditEventViewController (){
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    UITextField *_periodFirstResponder;
    NSDateFormatter *_dateFormatter;
    NSString *_productSalesSetID;
}
@end

@implementation AddEditEventViewController
@synthesize txtLocation;
@synthesize txtRemark;
@synthesize txtPeriodFrom;
@synthesize txtPeriodTo;
@synthesize datePickerPeriod;
@synthesize lblStatus;
@synthesize btnSave;
@synthesize btnBack;
@synthesize event;
@synthesize currentAction;
@synthesize txtProductSalesSet;
@synthesize btnLocked;
@synthesize remarkWidth;

- (IBAction)unwindToAddEditEvent:(UIStoryboardSegue *)segue
{
    ProductSalesSetViewController *vc = segue.sourceViewController;
    if(vc.productSalesSetID)
    {
        _productSalesSetID = vc.productSalesSetID;
        txtProductSalesSet.text = [Utility getProductSalesSetName:vc.productSalesSetID];
    }
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
}

- (void)loadView {
    [super loadView];
    // Do any additional setup after loading the view.
    
    {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);        
    }
        
    
    txtPeriodFrom.inputView = datePickerPeriod;
    txtPeriodTo.inputView = datePickerPeriod;
    [datePickerPeriod removeFromSuperview];
    _dateFormatter = [[NSDateFormatter alloc] init];
    
    
    txtLocation.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtLocation.delegate = self;
    
    txtRemark.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtRemark.delegate = self;
    
    txtPeriodFrom.delegate = self;
    txtPeriodTo.delegate = self;
    txtProductSalesSet.delegate = self;
    [btnLocked setTitle:@"Lock" forState:UIControlStateNormal];
    [btnLocked addTarget:self action:@selector(lockStock:) forControlEvents:UIControlEventTouchUpInside];
//    if(event != nil)
    {
        remarkWidth.constant = (self.view.frame.size.width-16*2-8)/2;
    }
//    else
//    {
//        remarkWidth.constant = (self.view.frame.size.width-16*2);
//    }
    
    
    [self loadViewProcess];
}

-(void)loadViewProcess
{
    currentAction = add;
    if(event != nil)
    {
        txtLocation.text = event.location;
        txtRemark.text = event.remark;
        txtPeriodFrom.text = [Utility formatDateForDisplay:event.periodFrom];
        txtPeriodTo.text = [Utility formatDateForDisplay:event.periodTo];
        txtProductSalesSet.text = [Utility getProductSalesSetName:event.productSalesSetID];
        _productSalesSetID = event.productSalesSetID;
        currentAction = edit;
        
        if([[event.remark lowercaseString] isEqualToString:@"locked"])
        {
            [btnLocked setTitle:@"Unlock" forState:UIControlStateNormal];
        }
        else
        {
            [btnLocked setTitle:@"Lock" forState:UIControlStateNormal];
        }
    }
}

- (BOOL)validateData
{
    //location not empty
    txtLocation.text = [Utility trimString:txtLocation.text];
    if([txtLocation.text isEqualToString:@""])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invalid data"
                                                                       message:[Utility msg:locationEmpty]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    //period from-to not empty
    if([txtPeriodFrom.text isEqualToString:@""])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invalid data"
                                                                       message:[Utility msg:periodFromEmpty]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    if([txtPeriodTo.text isEqualToString:@""])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invalid data"
                                                                       message:[Utility msg:periodToEmpty]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
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
    txtProductSalesSet.text = [Utility trimString:txtProductSalesSet.text];
    if([txtProductSalesSet.text isEqualToString:@""])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invalid data"
                                                                       message:@"Product sale set cannot be empty"
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
    NSDate *datePeriodTo = [Utility stringToDate:txtPeriodTo.text fromFormat:[Utility setting:vFormatDateDisplay]];
    NSDate *datePeriodFrom = [Utility stringToDate:txtPeriodFrom.text fromFormat:[Utility setting:vFormatDateDisplay]];
    NSComparisonResult result = [datePeriodFrom compare:datePeriodTo];
    if(result == NSOrderedDescending)
    {
        return YES;
    }
    return NO;
}
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    //validate username must be email
    if([sender isEqual:btnSave]){
        if(![self validateData])
        {
            return NO;
        }
    }
    return YES;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([sender isEqual:btnSave])
    {
        if(currentAction == add)
        {
            event = [[Event alloc] init];
            event.eventID = [Utility getNextID:tblEvent];
        }
        event.location = [Utility trimString:txtLocation.text];
        event.remark = [Utility trimString:txtRemark.text];
        event.periodFrom = [Utility formatDateForDB:txtPeriodFrom.text];
        event.periodTo = [Utility formatDateForDB:txtPeriodTo.text];
        event.productSalesSetID = _productSalesSetID;
        event.modifiedDate = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd HH:mm:ss"];
        event.modifiedUser = [Utility modifiedUser];
    }
    else if([sender isEqual:btnBack])
    {
        event = nil;
    }
    else if([[segue identifier] isEqualToString:@"segProductSalesSet"])
    {
        ProductSalesSetViewController *vc = segue.destinationViewController;
        vc.fromEventMenu = YES;
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if([textField isEqual:txtProductSalesSet])
    {
        [txtPeriodFrom resignFirstResponder];
        [txtPeriodTo resignFirstResponder];
        [self performSegueWithIdentifier:@"segProductSalesSet" sender:self];
        return NO;
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [btnSave sendActionsForControlEvents:UIControlEventTouchUpInside];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([textField isEqual:txtPeriodFrom] || [textField isEqual:txtPeriodTo])
    {
        return NO;
    }
    return YES;
}

// became first responder
- (void)textFieldDidBeginEditing:(UITextField *)textField;
{
    if([textField isEqual:txtPeriodFrom] || [textField isEqual:txtPeriodTo])
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

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if([textField isEqual:txtRemark])
    {
        if([[Utility trimString:[txtRemark.text lowercaseString]] isEqual:@"locked"])
        {
            txtRemark.text = @"locked";
            [btnLocked setTitle:@"Unlock" forState:UIControlStateNormal];
        }
        else
        {
            [btnLocked setTitle:@"Lock" forState:UIControlStateNormal];
        }
    }
}

- (IBAction)dateAction:(id)sender {
    [self setPeriodValue];
}

- (void)setPeriodValue
{
    NSString *formatedDate = [Utility dateToString:datePickerPeriod.date toFormat:[Utility setting:vFormatDateDisplay]];
    
    if([_periodFirstResponder isEqual:txtPeriodFrom])
    {
        txtPeriodFrom.text = formatedDate;
    }
    else if([_periodFirstResponder isEqual:txtPeriodTo])
    {
        txtPeriodTo.text = formatedDate;
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

-(void)lockStock:(id)button
{
    if([[btnLocked.titleLabel.text lowercaseString] isEqualToString:@"lock"])
    {
        txtRemark.text = @"locked";
        [btnLocked setTitle:@"Unlock" forState:UIControlStateNormal];
    }
    else
    {
        txtRemark.text = @"";
        [btnLocked setTitle:@"Lock" forState:UIControlStateNormal];
    }
}
@end
