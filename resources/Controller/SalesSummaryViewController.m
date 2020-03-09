//
//  SalesSummaryViewController.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 11/20/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "SalesSummaryViewController.h"
#import "CustomUICollectionViewCellButton.h"
#import "Utility.h"
#import "EventSalesSummary.h"
#import "CustomUICollectionReusableView.h"
#import "Receipt.h"
#import "SharedReceipt.h"


#define orangeColor         [UIColor colorWithRed:253/255.0 green:182/255.0 blue:103/255.0 alpha:1]
#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]


@interface SalesSummaryViewController ()
{
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSMutableArray *_EventSalesSummaryList;
    UIView *_viewUnderline;
}
@end
static NSString * const reuseIdentifier = @"Cell";
static NSString * const reuseHeaderViewIdentifier = @"HeaderView";
static NSString * const reuseFooterViewIdentifier = @"FooterView";

extern BOOL globalRotateFromSeg;

@implementation SalesSummaryViewController
@synthesize colViewSummaryTable;

- (void)loadView
{
    [super loadView];
    
    {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);
    }
    
    self.navigationItem.title = [NSString stringWithFormat:@"Sales Summary"];
    
    
    [self loadViewProcess];
}

- (void)loadViewProcess
{
    NSMutableArray *receiptList = [SharedReceipt sharedReceipt].receiptList;
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_eventID" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortArray = [receiptList sortedArrayUsingDescriptors:sortDescriptors];
    

    _EventSalesSummaryList = [[NSMutableArray alloc]init]; //sales by event
    float sumValue = 0;
    NSInteger noOfPair = 0;
    NSString *previousEventID = @"";
    for(Receipt *item in sortArray)
    {
        if(![item.eventID isEqualToString:previousEventID])
        {
            if(![previousEventID isEqualToString:@""])
            {
                NSInteger noOfDay = [Utility numberOfDaysInEvent:[previousEventID integerValue]];
                EventSalesSummary *eventSalesSummary = [[EventSalesSummary alloc]init];
                eventSalesSummary.eventID = previousEventID;
                eventSalesSummary.noOfDay = [NSString stringWithFormat:@"%ld",(long)noOfDay];
                eventSalesSummary.sumValue = [NSString stringWithFormat:@"%f",sumValue];
                eventSalesSummary.noOfPair = [NSString stringWithFormat:@"%ld",(long)noOfPair];
                eventSalesSummary.avgValue = [NSString stringWithFormat:@"%f",sumValue/noOfDay];;
                eventSalesSummary.avgNoOfPair = [NSString stringWithFormat:@"%f",(noOfPair+0.0)/noOfDay];;
                [_EventSalesSummaryList addObject:eventSalesSummary];
            }
            
            sumValue = [item.payPrice floatValue];
            noOfPair = [Utility getNoOfPairReceipt:item];
        }
        else
        {
            sumValue += [item.payPrice floatValue];
            noOfPair += [Utility getNoOfPairReceipt:item];
        }
        previousEventID = item.eventID;
    }
    
    //last eventID
    {
        NSInteger noOfDay = [Utility numberOfDaysInEvent:[previousEventID integerValue]];
        EventSalesSummary *eventSalesSummary = [[EventSalesSummary alloc]init];
        eventSalesSummary.eventID = previousEventID;
        eventSalesSummary.noOfDay = [NSString stringWithFormat:@"%ld",(long)noOfDay];
        eventSalesSummary.sumValue = [NSString stringWithFormat:@"%f",sumValue];
        eventSalesSummary.noOfPair = [NSString stringWithFormat:@"%ld",(long)noOfPair];
        eventSalesSummary.avgValue = [NSString stringWithFormat:@"%f",sumValue/noOfDay];;
        eventSalesSummary.avgNoOfPair = [NSString stringWithFormat:@"%f",(noOfPair+0.0)/noOfDay];;
        [_EventSalesSummaryList addObject:eventSalesSummary];
    }
    
    
    [self setData];
}
-(void)setData
{
    for(EventSalesSummary *item in _EventSalesSummaryList)
    {
        Event *event = [Utility getEvent:[item.eventID integerValue]];
        item.periodFrom = event.periodFrom;
    }
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"_periodFrom" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, nil];
    NSArray *sortArray = [_EventSalesSummaryList sortedArrayUsingDescriptors:sortDescriptors];
    _EventSalesSummaryList = [sortArray mutableCopy];
    
    
    //run row no
    NSInteger i = [_EventSalesSummaryList count];
    for(EventSalesSummary *item in _EventSalesSummaryList)
    {
        item.row = [NSString stringWithFormat:@"%ld", (long)i];
        i -=1;
    }
    
    [colViewSummaryTable reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Register cell classes
    [colViewSummaryTable registerClass:[CustomUICollectionViewCellButton class] forCellWithReuseIdentifier:reuseIdentifier];
    [colViewSummaryTable registerClass:[CustomUICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeaderViewIdentifier];
    [colViewSummaryTable registerClass:[CustomUICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:reuseFooterViewIdentifier];
    
    colViewSummaryTable.delegate = self;
    colViewSummaryTable.dataSource = self;
    
}- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger count = [_EventSalesSummaryList count];
    NSInteger countColumn = 8;
    return (count+1)*countColumn;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CustomUICollectionViewCellButton *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if ([cell.label isDescendantOfView:cell]) {
        [cell.label removeFromSuperview];
    }
    
    if ([cell.imageView isDescendantOfView:cell]) {
        [cell.imageView removeFromSuperview];
    }
    if ([cell.leftBorder isDescendantOfView:cell]) {
        [cell.leftBorder removeFromSuperview];
        [cell.topBorder removeFromSuperview];
        [cell.rightBorder removeFromSuperview];
        [cell.bottomBorder removeFromSuperview];
    }
    
    //cell border
    {
        cell.leftBorder.frame = CGRectMake(cell.bounds.origin.x
                                           , cell.bounds.origin.y, 1, cell.bounds.size.height);
        cell.topBorder.frame = CGRectMake(cell.bounds.origin.x
                                          , cell.bounds.origin.y, cell.bounds.size.width, 1);
        cell.rightBorder.frame = CGRectMake(cell.bounds.origin.x+cell.bounds.size.width
                                            , cell.bounds.origin.y, 1, cell.bounds.size.height);
        cell.bottomBorder.frame = CGRectMake(cell.bounds.origin.x
                                             , cell.bounds.origin.y+cell.bounds.size.height, cell.bounds.size.width, 1);
    }
    
    NSInteger item = indexPath.item;
    
    NSArray *header = @[@"No",@"Event",@"Start date",@"No of day",@"Total pair",@"Total amount(Baht)",@"Avg pair",@"Avg amount/day"];
    NSInteger countColumn = [header count];
    
    if(item/countColumn == 0)
    {
        [cell addSubview:cell.label];
        cell.label.frame = cell.bounds;
        cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
        cell.label.textColor = [UIColor whiteColor];
        cell.label.backgroundColor = tBlueColor;
        cell.label.textAlignment = NSTextAlignmentCenter;
    }
    else if(item%countColumn == 1)
    {
        [cell addSubview:cell.label];
        cell.label.frame = cell.bounds;
        cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
        cell.label.textColor= [UIColor blackColor];
        cell.label.backgroundColor = [UIColor clearColor];
        cell.label.textAlignment = NSTextAlignmentLeft;
        
        [cell addSubview:cell.leftBorder];
        [cell addSubview:cell.topBorder];
        [cell addSubview:cell.rightBorder];
        [cell addSubview:cell.bottomBorder];
    }
    else if(item%countColumn == 0 || item%countColumn == 2)
    {
        [cell addSubview:cell.label];
        cell.label.frame = cell.bounds;
        cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
        cell.label.textColor= [UIColor blackColor];
        cell.label.backgroundColor = [UIColor clearColor];
        cell.label.textAlignment = NSTextAlignmentCenter;
        
        [cell addSubview:cell.leftBorder];
        [cell addSubview:cell.topBorder];
        [cell addSubview:cell.rightBorder];
        [cell addSubview:cell.bottomBorder];
    }
    else
    {
        [cell addSubview:cell.label];
        cell.label.frame = cell.bounds;
        cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
        cell.label.textColor= [UIColor blackColor];
        cell.label.backgroundColor = [UIColor clearColor];
        cell.label.textAlignment = NSTextAlignmentRight;
        
        [cell addSubview:cell.leftBorder];
        [cell addSubview:cell.topBorder];
        [cell addSubview:cell.rightBorder];
        [cell addSubview:cell.bottomBorder];
    }
    
    
    if(item/countColumn == 0)
    {
        NSInteger remainder = item%countColumn;
        cell.label.text = header[remainder];
    }
    else
    {
        EventSalesSummary *eventSalesSummary = _EventSalesSummaryList[item/countColumn-1];
        switch (item%countColumn) {
            case 0:
            {
                cell.label.text = eventSalesSummary.row;
            }
                break;
            case 1:
            {
                NSString *strEventID = eventSalesSummary.eventID;
                cell.label.text = [Utility getEventName:[strEventID integerValue]];
            }
                break;
            case 2:
            {
                NSString *strEventID = eventSalesSummary.eventID;
                Event *event = [Utility getEvent:[strEventID integerValue]];
                cell.label.text = [Utility formatDateForDisplay:event.periodFrom];
            }
                break;
            case 3:
            {
                cell.label.text = eventSalesSummary.noOfDay;
            }
                break;
            case 4:
            {
                cell.label.text = eventSalesSummary.noOfPair;
            }
                break;
            case 5:
            {
                NSString *strSumValue = eventSalesSummary.sumValue;
                cell.label.text = [Utility formatBaht:strSumValue withMinFraction:0 andMaxFraction:0];
            }
                break;
            case 6:
            {
                NSString *strAvgNoOfPair = eventSalesSummary.avgNoOfPair;
                cell.label.text = [Utility formatBaht:strAvgNoOfPair withMinFraction:0 andMaxFraction:1];
            }
                break;
            case 7:
            {
                NSString *strAvgValue = eventSalesSummary.avgValue;
                cell.label.text = [Utility formatBaht:strAvgValue withMinFraction:0 andMaxFraction:0];
            }
                break;
            default:
                break;
        }
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
//    @[@"No",@"Event",@"Start date",@"No of day",@"Total pair",@"Total amount",@"Avg pair/day",@"Avg amount/day"];
    
    //    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
//        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
   
    
    NSArray *arrSize;
    CGFloat width;
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
    {
        arrSize = @[@30,@30,@30,@30,@30,@30,@30,@30];
    }
    else if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
    {
        arrSize = @[@26,@100,@80,@60,@60,@0,@60,@100];
    }
    
    width = [arrSize[indexPath.item%[arrSize count]] floatValue];
    if(width == 0)
    {
        width = colViewSummaryTable.bounds.size.width;
        for(int i=0; i<[arrSize count]; i++)
        {
            width = width - [arrSize[i] floatValue];
        }
    }
    
    
    CGSize size = CGSizeMake(width, 20);
    return size;

}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.colViewSummaryTable.collectionViewLayout;
    
    [layout invalidateLayout];
    [colViewSummaryTable reloadData];
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 20, 0);//top, left, bottom, right -> collection view
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        CustomUICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        
        
        CGRect frame2 = headerView.bounds;
//        frame2.size.width = frame2.size.width - 20;
        headerView.labelAlignRight.frame = frame2;
        headerView.labelAlignRight.textAlignment = NSTextAlignmentRight;
        NSString *strCountItem = [NSString stringWithFormat:@"%ld",[_EventSalesSummaryList count]];
        strCountItem = [Utility formatBaht:strCountItem];
        headerView.labelAlignRight.text = strCountItem;
        [headerView addSubview:headerView.labelAlignRight];
        [self setLabelUnderline:headerView.labelAlignRight underline:headerView.viewUnderline];
        
        reusableview = headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        
        reusableview = footerview;
    }
    
    return reusableview;
}

-(UILabel *)setLabelUnderline:(UILabel *)label underline:(UIView *)viewUnderline
{
//    CGSize expectedLabelSize = [label.text sizeWithFont:label.font constrainedToSize:label.frame.size lineBreakMode:label.lineBreakMode];
    
    
    
    CGRect expectedLabelSize = [label.text boundingRectWithSize:label.frame.size
                                             options:NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading
                                          attributes:@{NSFontAttributeName:label.font}
                                             context:nil];
    
    
    CGFloat xOrigin=0;
    switch (label.textAlignment) {
        case NSTextAlignmentCenter:
            xOrigin=(label.frame.size.width - expectedLabelSize.size.width)/2;
            break;
        case NSTextAlignmentLeft:
            xOrigin=0;
            break;
        case NSTextAlignmentRight:
            xOrigin=label.frame.size.width - expectedLabelSize.size.width;
            break;
        default:
            break;
    }
    viewUnderline.frame=CGRectMake(xOrigin,
                                   expectedLabelSize.size.height-1,
                                   expectedLabelSize.size.width,
                                   1);
    viewUnderline.backgroundColor=label.textColor;
    [label addSubview:viewUnderline];
    return label;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
{
    CGSize headerSize = CGSizeMake(collectionView.bounds.size.width, 20);
    return headerSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    CGSize footerSize = CGSizeMake(collectionView.bounds.size.width, 0);
    return footerSize;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    return YES;
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

- (IBAction)backButtonClicked:(id)sender {
    globalRotateFromSeg = YES;
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    [self performSegueWithIdentifier:@"segUnwindToAdminMenu" sender:self];
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
