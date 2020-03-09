//
//  RewardProgramSetupViewController.m
//  SAIM_TEST
//
//  Created by Thidaporn Kijkamjai on 4/19/2560 BE.
//  Copyright © 2560 Thidaporn Kijkamjai. All rights reserved.
//

#import "RewardProgramSetupViewController.h"
#import "RewardProgramCollectAddViewController.h"
#import "RewardProgramUseAddViewController.h"
#import "CustomUICollectionViewCellButton2.h"
#import "CustomUICollectionReusableView.h"
#import "Utility.h"
#import "RewardProgram.h"


#define tBlueColor          [UIColor colorWithRed:0/255.0 green:123/255.0 blue:255/255.0 alpha:1]



@interface RewardProgramSetupViewController ()
{
    HomeModel *_homeModel;
    UIActivityIndicatorView *indicator;
    UIView *overlayView;
    NSMutableArray *_rewardProgramCollectList;
    NSMutableArray *_rewardProgramUseList;
    RewardProgram *_selectedRewardProgram;
}

@end

@implementation RewardProgramSetupViewController

static NSString * const reuseIdentifier = @"Cell";
static NSString * const reuseHeaderViewIdentifier = @"HeaderView";
static NSString * const reuseFooterViewIdentifier = @"FooterView";


@synthesize colViewData;
@synthesize dtPicker;
@synthesize txtDateFrom;
@synthesize txtDateTo;

- (IBAction)unwindToRewardProgramSetup:(UIStoryboardSegue *)segue
{
    _rewardProgramCollectList = [RewardProgram getRewardProgramCollectListDateStart:txtDateFrom.text dateEnd:txtDateTo.text];
    _rewardProgramUseList = [RewardProgram getRewardProgramUseListDateStart:txtDateFrom.text dateEnd:txtDateTo.text];
    _rewardProgramCollectList = [RewardProgram getRewardProgramListSortByDateStartDateEnd:_rewardProgramCollectList];
    _rewardProgramUseList = [RewardProgram getRewardProgramListSortByDateStartDateEnd:_rewardProgramUseList];
    
    [colViewData reloadData];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if([textField isEqual:txtDateFrom] || [textField isEqual:txtDateTo])
    {
        [self loadingOverlayView];
        [_homeModel downloadItems:dbRewardProgram condition:@[txtDateFrom.text,txtDateTo.text]];
        
        return;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField;
{
    if([textField isEqual:txtDateFrom])
    {
        NSString *strDate = textField.text;
        NSDate *datePeriod = [Utility stringToDate:strDate fromFormat:@"yyyy-MM-dd"];
        [dtPicker setDate:datePeriod];
    }
    else if([textField isEqual:txtDateTo])
    {
        NSString *strDate = textField.text;
        NSDate *datePeriod = [Utility stringToDate:strDate fromFormat:@"yyyy-MM-dd"];
        [dtPicker setDate:datePeriod];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"segRewardProgramCollectEdit"])
    {
        RewardProgramCollectAddViewController *vc = segue.destinationViewController;
        vc.selectedRewardProgram = _selectedRewardProgram;

    }
    else if([[segue identifier] isEqualToString:@"segRewardProgramUseEdit"])
    {
        RewardProgramUseAddViewController *vc = segue.destinationViewController;
        vc.selectedRewardProgram = _selectedRewardProgram;
        
    }
}

- (IBAction)datePickerChanged:(id)sender
{
    if([txtDateFrom isFirstResponder])
    {
        txtDateFrom.text = [Utility dateToString:dtPicker.date toFormat:@"yyyy-MM-dd"];
        NSString *strDateInMonth = [Utility formatDate:txtDateFrom.text fromFormat:@"yyyy-MM-dd" toFormat:@"yyyy-MM"];
        NSString *strDateToMonth = [Utility formatDate:txtDateTo.text fromFormat:@"yyyy-MM-dd" toFormat:@"yyyy-MM"];
        if(![strDateInMonth isEqualToString:strDateToMonth])//change dateTo -> date end of month
        {
            NSDate *dateIn = [Utility stringToDate:txtDateFrom.text fromFormat:@"yyyy-MM-dd"];
            txtDateTo.text = [NSString stringWithFormat:@"%@-%02ld",strDateInMonth,[Utility getLastDayOfMonth:dateIn]];
        }
    }
    else if([txtDateTo isFirstResponder])
    {
        txtDateTo.text = [Utility dateToString:dtPicker.date toFormat:@"yyyy-MM-dd"];
        NSString *strDateInMonth = [Utility formatDate:txtDateFrom.text fromFormat:@"yyyy-MM-dd" toFormat:@"yyyy-MM"];
        NSString *strDateToMonth = [Utility formatDate:txtDateTo.text fromFormat:@"yyyy-MM-dd" toFormat:@"yyyy-MM"];
        if(![strDateInMonth isEqualToString:strDateToMonth])//change dateFrom -> date start of month
        {
            txtDateFrom.text = [NSString stringWithFormat:@"%@-01",strDateToMonth];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Register cell classes
    [colViewData registerClass:[CustomUICollectionViewCellButton2 class] forCellWithReuseIdentifier:reuseIdentifier];
    [colViewData registerClass:[CustomUICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeaderViewIdentifier];
    [colViewData registerClass:[CustomUICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:reuseFooterViewIdentifier];
    colViewData.delegate = self;
    colViewData.dataSource = self;
    
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
}

- (void)loadView
{
    [super loadView];
    
    
    _homeModel = [[HomeModel alloc] init];
    _homeModel.delegate = self;
    
    
    {
        overlayView = [[UIView alloc] initWithFrame:self.view.frame];
        overlayView.backgroundColor = [UIColor colorWithRed:256 green:256 blue:256 alpha:0];
        
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.frame = CGRectMake(self.view.bounds.size.width/2-indicator.frame.size.width/2,self.view.bounds.size.height/2-indicator.frame.size.height/2,indicator.frame.size.width,indicator.frame.size.height);
    }
    
    
    
    [dtPicker removeFromSuperview];
    txtDateFrom.inputView = dtPicker;
    txtDateFrom.delegate = self;
    txtDateFrom.text = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-01"];//set to first date of current month
    
    
    txtDateTo.inputView = dtPicker;
    txtDateTo.delegate = self;
    txtDateTo.text = [Utility dateToString:[NSDate date] toFormat:@"yyyy-MM-dd"];//set to current date
    
    
    
    [self loadingOverlayView];
    [_homeModel downloadItems:dbRewardProgram condition:@[txtDateFrom.text,txtDateTo.text]];
}

- (void)itemsDownloaded:(NSArray *)items
{
    [self removeOverlayViews];
    int i=0;
    
//    _rewardProgramCollectList = items[i++];
//    _rewardProgramUseList = items[i++];
    [RewardProgram addRewardProgramList:items[i++]];
    [RewardProgram addRewardProgramList:items[i++]];
    _rewardProgramCollectList = [RewardProgram getRewardProgramCollectListDateStart:txtDateFrom.text dateEnd:txtDateTo.text];
    _rewardProgramUseList = [RewardProgram getRewardProgramUseListDateStart:txtDateFrom.text dateEnd:txtDateTo.text];
    _rewardProgramCollectList = [RewardProgram getRewardProgramListSortByDateStartDateEnd:_rewardProgramCollectList];
    _rewardProgramUseList = [RewardProgram getRewardProgramListSortByDateStartDateEnd:_rewardProgramUseList];
    
    
    [colViewData reloadData];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return  2;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger noOfItem = 0;
    NSInteger countColumn = 4;
    if(section == 0)
    {
        noOfItem = ([_rewardProgramCollectList count]+1)*countColumn;
    }
    else
    {
        noOfItem = ([_rewardProgramUseList count]+1)*countColumn;
    }
    
    return noOfItem;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CustomUICollectionViewCellButton2 *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if ([cell.textField isDescendantOfView:cell])
    {
        [cell.textField removeFromSuperview];
    }
    if ([cell.label isDescendantOfView:cell])
    {
        [cell.label removeFromSuperview];
    }
    if ([cell.buttonDetail isDescendantOfView:cell]) {
        [cell.buttonDetail removeFromSuperview];
    }
    if ([cell.imageView isDescendantOfView:cell]) {
        [cell.imageView removeFromSuperview];
    }
    if ([cell.leftBorder isDescendantOfView:cell])
    {
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
    NSInteger section = indexPath.section;
    
    if(section == 0)
    {
        NSArray *header = @[@"Start date",@"End date",@"Sales spent",@"Receive point"];
        NSInteger countColumn = [header count];
        
        if(item/countColumn==0)
        {
            [cell addSubview:cell.leftBorder];
            [cell addSubview:cell.topBorder];
            [cell addSubview:cell.rightBorder];
            [cell addSubview:cell.bottomBorder];
            
            
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
            cell.label.textColor = [UIColor whiteColor];
            cell.label.backgroundColor = tBlueColor;
            
            
            NSInteger remainder = item%countColumn;
            cell.label.text = header[remainder];
            cell.label.textAlignment = NSTextAlignmentCenter;
        }
        else
        {
            [cell addSubview:cell.leftBorder];
            [cell addSubview:cell.topBorder];
            [cell addSubview:cell.rightBorder];
            [cell addSubview:cell.bottomBorder];
            
            
            RewardProgram *rewardProgram = _rewardProgramCollectList[item/countColumn-1];
            if(item%countColumn==0)
            {
                [cell addSubview:cell.buttonDetail];
                [cell.buttonDetail removeTarget:nil
                                         action:NULL
                               forControlEvents:UIControlEventAllEvents];
                [cell.buttonDetail addTarget:self action:@selector(editRewardProgramCollect:)
                            forControlEvents:UIControlEventTouchUpInside];
                
                
                NSString *strDateStart = [Utility formatDate:rewardProgram.dateStart fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd"];
                [cell addSubview:cell.buttonDetail];
                [cell.buttonDetail setTitle:strDateStart forState:UIControlStateNormal];
                [cell.buttonDetail setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [cell.buttonDetail setBackgroundColor:[UIColor clearColor]];
                cell.buttonDetail.frame = cell.bounds;
                cell.buttonDetail.titleLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                cell.buttonDetail.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
                cell.buttonDetail.tag = item;
                cell.buttonDetail.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            }
            else if(item%countColumn==1)
            {
                [cell addSubview:cell.label];
                cell.label.frame = cell.bounds;
                cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                cell.label.textColor = [UIColor blackColor];
                cell.label.backgroundColor = [UIColor clearColor];
                cell.label.textAlignment = NSTextAlignmentCenter;
                cell.label.text = [Utility formatDate:rewardProgram.dateEnd fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd"];
            }
            else if(item%countColumn==2)
            {
                [cell addSubview:cell.label];
                cell.label.frame = cell.bounds;
                cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                cell.label.textColor = [UIColor blackColor];
                cell.label.backgroundColor = [UIColor clearColor];
                cell.label.textAlignment = NSTextAlignmentRight;
                
                NSString *strSalesSpent = [NSString stringWithFormat:@"%ld",rewardProgram.salesSpent];
                strSalesSpent = [Utility formatBaht:strSalesSpent withMinFraction:0 andMaxFraction:2];
                cell.label.text = strSalesSpent;
            }
            else if(item%countColumn==3)
            {
                [cell addSubview:cell.label];
                cell.label.frame = cell.bounds;
                cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                cell.label.textColor = [UIColor blackColor];
                cell.label.backgroundColor = [UIColor clearColor];
                cell.label.textAlignment = NSTextAlignmentRight;
                
                NSString *strReceivePoint = [NSString stringWithFormat:@"%ld",rewardProgram.receivePoint];
                strReceivePoint = [Utility formatBaht:strReceivePoint withMinFraction:0 andMaxFraction:2];
                cell.label.text = strReceivePoint;
            }
        }
    }
    else if(section == 1)
    {
        NSArray *header = @[@"Start date",@"End date",@"Point spent",@"Discount"];
        NSInteger countColumn = [header count];
        
        if(item/countColumn==0)
        {
            [cell addSubview:cell.leftBorder];
            [cell addSubview:cell.topBorder];
            [cell addSubview:cell.rightBorder];
            [cell addSubview:cell.bottomBorder];
            
            
            [cell addSubview:cell.label];
            cell.label.frame = cell.bounds;
            cell.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
            cell.label.textColor = [UIColor whiteColor];
            cell.label.backgroundColor = tBlueColor;
            
            
            NSInteger remainder = item%countColumn;
            cell.label.text = header[remainder];
            cell.label.textAlignment = NSTextAlignmentCenter;
        }
        else
        {
            [cell addSubview:cell.leftBorder];
            [cell addSubview:cell.topBorder];
            [cell addSubview:cell.rightBorder];
            [cell addSubview:cell.bottomBorder];
            
            
            RewardProgram *rewardProgram = _rewardProgramUseList[item/countColumn-1];
            if(item%countColumn==0)
            {
                [cell addSubview:cell.buttonDetail];
                [cell.buttonDetail removeTarget:nil
                                         action:NULL
                               forControlEvents:UIControlEventAllEvents];
                [cell.buttonDetail addTarget:self action:@selector(editRewardProgramUse:)
                            forControlEvents:UIControlEventTouchUpInside];
                
                
                NSString *strDateStart = [Utility formatDate:rewardProgram.dateStart fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd"];
                [cell addSubview:cell.buttonDetail];
                [cell.buttonDetail setTitle:strDateStart forState:UIControlStateNormal];
                [cell.buttonDetail setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [cell.buttonDetail setBackgroundColor:[UIColor clearColor]];
                cell.buttonDetail.frame = cell.bounds;
                cell.buttonDetail.titleLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                cell.buttonDetail.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
                cell.buttonDetail.tag = item;
                cell.buttonDetail.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            }
            else if(item%countColumn==1)
            {
                [cell addSubview:cell.label];
                cell.label.frame = cell.bounds;
                cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                cell.label.textColor = [UIColor blackColor];
                cell.label.backgroundColor = [UIColor clearColor];
                cell.label.textAlignment = NSTextAlignmentCenter;
                cell.label.text = [Utility formatDate:rewardProgram.dateEnd fromFormat:@"yyyy-MM-dd HH:mm:ss" toFormat:@"yyyy-MM-dd"];
            }
            else if(item%countColumn==2)
            {
                [cell addSubview:cell.label];
                cell.label.frame = cell.bounds;
                cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                cell.label.textColor = [UIColor blackColor];
                cell.label.backgroundColor = [UIColor clearColor];
                cell.label.textAlignment = NSTextAlignmentRight;
                
                NSString *strPointSpent = [NSString stringWithFormat:@"%ld",rewardProgram.pointSpent];
                strPointSpent = [Utility formatBaht:strPointSpent withMinFraction:0 andMaxFraction:2];
                cell.label.text = strPointSpent;
            }
            else if(item%countColumn==3)
            {
                [cell addSubview:cell.label];
                cell.label.frame = cell.bounds;
                cell.label.font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:13];
                cell.label.textColor = [UIColor blackColor];
                cell.label.backgroundColor = [UIColor clearColor];
                cell.label.textAlignment = NSTextAlignmentRight;
                
                NSString *strDiscountAmount = [NSString stringWithFormat:@"%f",rewardProgram.discountAmount];
                strDiscountAmount = [Utility formatBaht:strDiscountAmount withMinFraction:0 andMaxFraction:2];
                cell.label.text = rewardProgram.discountType == 0?[NSString stringWithFormat:@"%@ Baht",strDiscountAmount]:[NSString stringWithFormat:@"%@ %%",strDiscountAmount];
            }
        }
    }
    
    return cell;
}

- (void)editRewardProgramCollect:(id)sender
{
    UIButton *button = sender;
    NSInteger item = button.tag;
    NSInteger countColumn = 4;
    _selectedRewardProgram = _rewardProgramCollectList[item/countColumn-1];
    [self performSegueWithIdentifier:@"segRewardProgramCollectEdit" sender:self];
}

- (void)editRewardProgramUse:(id)sender
{
    UIButton *button = sender;
    NSInteger item = button.tag;
    NSInteger countColumn = 4;
    _selectedRewardProgram = _rewardProgramUseList[item/countColumn-1];
    [self performSegueWithIdentifier:@"segRewardProgramUseEdit" sender:self];
}

- (void) addRewardProgram:(UIGestureRecognizer *)gestureRecognizer {
    
    UIView* view = gestureRecognizer.view;
    NSInteger section = view.tag;
    
    if(section == 0)
    {
        [self performSegueWithIdentifier:@"segRewardProgramCollectAdd" sender:self];
    }
    else if(section == 1)
    {
        [self performSegueWithIdentifier:@"segRewardProgramUseAdd" sender:self];
    }    
}

#pragma mark <UICollectionViewDelegate>
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width;
    NSArray *arrSize;
    //@[@"No.",@"Start date",@"End date",@"Point spent",@"Discount"];
    arrSize = @[@80,@80,@85,@0];
    
    
    width = [arrSize[indexPath.item%[arrSize count]] floatValue];
    if(width == 0)
    {
        width = colViewData.bounds.size.width;
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
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.colViewData.collectionViewLayout;
    
    [layout invalidateLayout];
    [colViewData reloadData];
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);//top, left, bottom, right
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
        CustomUICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeaderViewIdentifier forIndexPath:indexPath];
        
        CGFloat height = 20;
        
        {
            headerView.label.text = indexPath.section==0?@"Part: Collect":@"Part: Use";
            [headerView.label setFont:[UIFont fontWithName:@"HelveticaNeue-light" size:13]];
            CGRect frame = headerView.frame;
            frame.origin.x = 0;
            frame.origin.y = 0;
            frame.size.height = height;
            frame.size.width = frame.size.width;
            headerView.label.frame = frame;
            headerView.label.textAlignment = NSTextAlignmentLeft;
            [headerView addSubview:headerView.label];
            [headerView.label sizeToFit];
        }
        {
            headerView.imgView.image = [UIImage imageNamed:@"add active3.png"];
            headerView.imgView.userInteractionEnabled = YES;
            
            
            CGRect frame = headerView.frame;
            NSInteger imageSize = 18;
            frame.origin.x = headerView.label.frame.size.width+8;
            frame.origin.y = 0;
            frame.size.width = imageSize;
            frame.size.height = imageSize;
            headerView.imgView.frame = frame;
//            headerView.imgView.frame = headerView.label.frame;
            
            
            headerView.imgView.tag = indexPath.section;
            [headerView.singleTap addTarget:self action:@selector(addRewardProgram:)];
            headerView.singleTap.numberOfTapsRequired = 1;
            headerView.singleTap.numberOfTouchesRequired = 1;
            [headerView.imgView addGestureRecognizer:headerView.singleTap];
            [headerView addSubview:headerView.imgView];
        }
        
        reusableview = headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:reuseFooterViewIdentifier forIndexPath:indexPath];
        
        reusableview = footerview;
    }
    
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
{
    CGSize headerSize = CGSizeMake(collectionView.bounds.size.width, 20);
    return headerSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section;
{
    CGSize footerSize = CGSizeMake(collectionView.bounds.size.width, 40);
    return footerSize;
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
