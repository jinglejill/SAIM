//
//  SalesCustomMadeViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 8/30/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "SalesCustomMadeViewController.h"
#import "Utility.h"
#import "CustomMade.h"
#import "ProductDetailViewController.h"
#import "MasterListViewController.h"
#import "SharedSelectedEvent.h"
#import "ProductDetailViewController.h"
#import "SharedProductBuy.h"
#import "SharedPostBuy.h"
#import "SharedProductSize.h"
#import "ProductSize.h"
#import "ProductSales.h"


@interface SalesCustomMadeViewController ()
{
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    CustomMade *_customMade;
    NSString *_productCategory2;
    NSString *_productCategory1;
    NSString *_productCategory2Value;
    NSString *_productCategory1Value;
    NSMutableArray *_eventListNowAndFutureAsc;
    NSString *_strSelectedEventID;
    UITextField *txtLocation;
}
@end

@implementation SalesCustomMadeViewController
@synthesize btnCancel;
@synthesize customMade;
@synthesize txtPicker;


- (void)textFieldDidBeginEditing:(UITextField *)textField;
{
    if([textField isEqual:txtLocation])
    {
        int i=0;
        for(Event*item in _eventListNowAndFutureAsc)
        {
            if(item.eventID == [_strSelectedEventID integerValue])
            {
                [txtPicker selectRow:i inComponent:0 animated:NO];
            }
            i++;
        }
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
    
    Event *event = _eventListNowAndFutureAsc[row];
    txtLocation.text = event.location;
    _strSelectedEventID = [NSString stringWithFormat:@"%ld",event.eventID];
    [Utility setUserDefaultPreOrderEventID:_strSelectedEventID];
    [self loadViewProcess];
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [_eventListNowAndFutureAsc count];
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    Event *event = _eventListNowAndFutureAsc[row];
    return event.location;
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    //    int sectionWidth = 300;
    
    return self.view.frame.size.width;
}

- (IBAction)unwindToCustomMade:(UIStoryboardSegue *)segue
{
    if([[segue sourceViewController] isMemberOfClass:[MasterListViewController class]])
    {
        MasterListViewController *source = [segue sourceViewController];
        if ([source respondsToSelector:NSSelectorFromString(@"selectedItem")])
        {
            NSDictionary *selectedItem = source.selectedItem;
            
            if ([selectedItem count] > 0) {
                
                NSString *selectedValue;
                NSString *selectedKey;
                for(id key in selectedItem){
                    selectedKey = key;
                    selectedValue = [selectedItem objectForKey:key];
                }
                
                
                if(source.masterType == productCategory2)
                {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                    cell.detailTextLabel.text = selectedValue;
                    _productCategory2 = selectedKey;
                    _productCategory2Value = selectedValue;
                    
                    
                    NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:2 inSection:0];
                    [self.tableView cellForRowAtIndexPath:indexPath2].detailTextLabel.text = @"";
                    _productCategory1 = nil;
                    _productCategory1Value = nil;
                    
                }
                else if(source.masterType == productCategory1)
                {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                    cell.detailTextLabel.text = selectedValue;
                    _productCategory1 = selectedKey;
                    _productCategory1Value = selectedValue;
                }
            }
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tapGesture];
    [tapGesture setCancelsTouchesInView:NO];
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.000001f;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = @"Event";
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            [cell addSubview:txtLocation];
            cell.detailTextLabel.text = [SharedSelectedEvent sharedSelectedEvent].event.location;
        }
            break;

        case 1:
        {
            cell.textLabel.text = @"Product Category 2";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.detailTextLabel.text = _productCategory2Value == nil?@"":_productCategory2Value;
        }
            break;
        case 2:
        {
            cell.textLabel.text = @"Product Category 1";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.detailTextLabel.text = _productCategory1Value == nil?@"":_productCategory1Value;

        }
            break;
        case 3:
        {
            cell.textLabel.text = @"";
            cell.detailTextLabel.text = @"";
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            [cell addSubview:lblSize];
            [cell addSubview:txtSize];
        }
            break;
        case 4:
        {
            cell.textLabel.text = @"";
            cell.detailTextLabel.text = @"";
            cell.accessoryType = UITableViewCellAccessoryNone;
            [cell addSubview:txtToe];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
        case 5:
        {
            cell.textLabel.text = @"";
            cell.detailTextLabel.text = @"";
            cell.accessoryType = UITableViewCellAccessoryNone;
            [cell addSubview:txtBody];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
        case 6:
        {
            cell.textLabel.text = @"";
            cell.detailTextLabel.text = @"";
            cell.accessoryType = UITableViewCellAccessoryNone;
            [cell addSubview:txtAccessory];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
        case 7:
        {
            cell.textLabel.text = @"";
            cell.detailTextLabel.text = @"";
            cell.accessoryType = UITableViewCellAccessoryNone;
            [cell addSubview:txtRemark];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 1:
        {
            [self performSegueWithIdentifier:@"segProductCategory2" sender:self];
        }
            break;
        case 2:
        {
            if(_productCategory2 == nil)
            {
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Missing"
                                                                               message:@"Please select product category2"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {}];
                
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
            else
            {
                [self performSegueWithIdentifier:@"segProductCategory1" sender:self];
            }
        }
            break;
        default:
        {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
            break;
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if([identifier isEqualToString:@"segProductDetailFromCustomMade"])
    {
        //validate
        if(![self validateDataWithSeg:@"segProductDetailFromCustomMade"])
        {
            return NO;
        }
        
        //prepare custom made
        _customMade = [[CustomMade alloc]init];
        _customMade.productCategory2 = _productCategory2;
        _customMade.productCategory1 = _productCategory1;
        _customMade.productName = @"00";
        _customMade.size = txtSize.text;
        _customMade.toe = txtToe.text;
        _customMade.body = txtBody.text;
        _customMade.accessory = txtAccessory.text;
        _customMade.remark = txtRemark.text;
    }
    else if([identifier isEqualToString:@"segUnwindToProductDetail"])
    {
        //validate
        if(![self validateDataWithSeg:@"segUnwindToProductDetail"])
        {
            return NO;
        }
        
        //prepare custom made
        _customMade = [[CustomMade alloc]init];
        _customMade.productCategory2 = _productCategory2;
        _customMade.productCategory1 = _productCategory1;
        _customMade.productName = @"00";
        _customMade.size = txtSize.text;
        _customMade.toe = txtToe.text;
        _customMade.body = txtBody.text;
        _customMade.accessory = txtAccessory.text;
        _customMade.remark = txtRemark.text;
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"segProductCategory2"])
    {
        MasterListViewController *vc = segue.destinationViewController;
        vc.masterType = productCategory2;
    }
    else if([[segue identifier] isEqualToString:@"segProductCategory1"])
    {
        MasterListViewController *vc = segue.destinationViewController;
        vc.masterType = productCategory1;
        vc.strProductCategory2 = _productCategory2;
    }

    else if([[segue identifier] isEqualToString:@"segProductDetailFromCustomMade"])
    {
        ProductDetailViewController *vc = segue.destinationViewController;
        vc.customMade = _customMade;
        vc.productType = productCustomMade;
    }
    else if([[segue identifier] isEqualToString:@"segUnwindToProductDetail"])
    {
        customMade = _customMade;
    }
    else if(sender == btnCancel)
    {
        _customMade = nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row == 7?132:44;
//    return 44;
}

#pragma mark - Life Cycle method
- (void)loadView
{
    [super loadView];
    
    {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);        
    }
        
    
    [[SharedProductBuy sharedProductBuy].productBuyList removeAllObjects];
    [[SharedPostBuy sharedPostBuy].postBuyList removeAllObjects];
    
    float controlWidth = self.tableView.bounds.size.width - 40*2;//minus left, right margin
    float controlXOrigin = 15;
    float controlYOrigin = (44 - 25)/2;//table row height minus control height and set vertical center
    
    
    txtSize = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, 25)];
    txtSize.placeholder = @"Size";
    txtSize.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtSize.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
    
    
    txtToe = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, 25)];
    txtToe.placeholder = @"Toe";
    txtToe.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtToe.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
    
    txtBody = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, 25)];
    txtBody.placeholder = @"Body";
    txtBody.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtBody.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
    
    txtAccessory = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, 25)];
    txtAccessory.placeholder = @"Accessory";
    txtAccessory.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtAccessory.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
    
    txtRemark = [[CustomUITextView alloc] initWithFrame:CGRectMake(controlXOrigin-4
                                                                   , controlYOrigin, controlWidth, 25)];
    txtRemark.placeholder = @" Remark";
    txtRemark.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
    txtRemark.font = txtAccessory.font;
    
    
    {
        float controlWidth = 120;
        float controlXOrigin = self.view.frame.size.width - 120 - 20;
        float controlYOrigin = (44 - 25)/2;
        txtLocation = [[UITextField alloc] initWithFrame:CGRectMake(controlXOrigin, controlYOrigin, controlWidth, 25.0f)];
    }
    {
        txtPicker = [[UIPickerView alloc] initWithFrame:(CGRect){{0, self.view.frame.size.height-216}, self.view.frame.size.width, 216}];
        [self.view addSubview:txtPicker];
    }
    
    [txtPicker removeFromSuperview];
    txtLocation.delegate = self;
    txtLocation.inputView = txtPicker;
    txtPicker.delegate = self;
    txtPicker.dataSource = self;
    txtPicker.showsSelectionIndicator = YES;
    
    
    _eventListNowAndFutureAsc = [Event getEventListNowAndFutureAsc];
    Event *mainStock = [Event getMainEvent];
    [_eventListNowAndFutureAsc insertObject:mainStock atIndex:0];
    
    
    _strSelectedEventID = [Utility getUserDefaultPreOrderEventID];
    Event *event = [Event getEventFromEventList:_eventListNowAndFutureAsc eventID:[_strSelectedEventID integerValue]];
    txtLocation.text = event.location;
    
    
    [self loadViewProcess];
}

- (void)loadViewProcess
{
}

- (BOOL)validateDataWithSeg:(NSString *)seg
{
    if(!_productCategory2)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Missing"
                                                                       message:@"Please fill in product category 2"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
    }

    if(!_productCategory1)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Missing"
                                                                       message:@"Please fill in product category 1"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
    }
    
    txtSize.text = [Utility trimString:txtSize.text];
    if([txtSize.text isEqualToString:@""])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Missing"
                                                                       message:@"Please fill in size"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
    }
    
    txtBody.text = [Utility trimString:txtBody.text];
    if([txtBody.text isEqualToString:@""])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Missing"
                                                                       message:@"Please fill in body"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
    }
    
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
