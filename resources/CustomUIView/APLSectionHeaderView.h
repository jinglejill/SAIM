//
//  APLSectionHeaderView.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 12/21/2558 BE.
//  Copyright © 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol SectionHeaderViewDelegate;

@interface APLSectionHeaderView : UITableViewHeaderFooterView

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIButton *disclosureButton;
@property (nonatomic, weak) IBOutlet id <SectionHeaderViewDelegate> delegate;

@property (nonatomic) NSInteger section;

- (void)toggleOpenWithUserAction:(BOOL)userAction;

@end

#pragma mark -

/*
 Protocol to be adopted by the section header's delegate; the section header tells its delegate when the section should be opened and closed.
 */
@protocol SectionHeaderViewDelegate <NSObject>

@optional
- (void)sectionHeaderView:(APLSectionHeaderView *)sectionHeaderView sectionOpened:(NSInteger)section;
- (void)sectionHeaderView:(APLSectionHeaderView *)sectionHeaderView sectionClosed:(NSInteger)section;

@end