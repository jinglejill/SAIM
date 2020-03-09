//
//  CustomUITextView.h
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 9/2/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomUITextView : UITextView
@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;
@property (nonatomic, retain) UIButton *btnClearTxtRemark;

-(void)textChanged:(NSNotification*)notification;
-(void)textEndEditing:(NSNotification*)notification;
-(void)textBeginEditing:(NSNotification*)notification;
@end
