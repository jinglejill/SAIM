//
//  CustomUITextView.m
//  SAIM
//
//  Created by Thidaporn Kijkamjai on 9/2/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import "CustomUITextView.h"
@interface CustomUITextView()
@property (nonatomic, retain) UILabel *placeHolderLabel;

@end

@implementation CustomUITextView
@synthesize btnClearTxtRemark;

CGFloat const UI_PLACEHOLDER_TEXT_CHANGED_ANIMATION_DURATION = 0;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#if __has_feature(objc_arc)
#else
    [_placeHolderLabel release]; _placeHolderLabel = nil;
    [_placeholderColor release]; _placeholderColor = nil;
    [_placeholder release]; _placeholder = nil;
    [super dealloc];
#endif
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Use Interface Builder User Defined Runtime Attributes to set
    // placeholder and placeholderColor in Interface Builder.
    if (!self.placeholder) {
        [self setPlaceholder:@""];
    }
    
    if (!self.placeholderColor) {
        [self setPlaceholderColor:[UIColor colorWithRed:199/255.0 green:199/255.0 blue:205/255.0 alpha:1]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textEndEditing:) name:UITextViewTextDidEndEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    if( (self = [super initWithFrame:frame]) )
    {
        [self setPlaceholder:@""];
        [self setPlaceholderColor:[UIColor colorWithRed:199/255.0 green:199/255.0 blue:205/255.0 alpha:1]];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textEndEditing:) name:UITextViewTextDidEndEditingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
    
        btnClearTxtRemark = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width+30,frame.origin.y,18,18)];
        [btnClearTxtRemark setImage:[UIImage imageNamed:@"clearButton.png"] forState:UIControlStateNormal];
        [btnClearTxtRemark addTarget:self action:@selector(clearButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnClearTxtRemark];
    }
    return self;
}

-(void)clearButtonSelected:(id)sender{
    [self setText:@""];
}
- (void)textEndEditing:(NSNotification *)notification
{
    [btnClearTxtRemark setAlpha:0];
}
- (void)textBeginEditing:(NSNotification *)notification
{
    [btnClearTxtRemark setAlpha:1];
}
- (void)textChanged:(NSNotification *)notification
{
    if([[self placeholder] length] == 0)
    {
        return;
    }
    
    [UIView animateWithDuration:UI_PLACEHOLDER_TEXT_CHANGED_ANIMATION_DURATION animations:^{
        if([[self text] length] == 0)
        {
            [[self viewWithTag:999] setAlpha:1];
            [btnClearTxtRemark setAlpha:0];
        }
        else
        {
            [[self viewWithTag:999] setAlpha:0];
            [btnClearTxtRemark setAlpha:1];
        }
    }];
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self textChanged:nil];
}

- (void)drawRect:(CGRect)rect
{
    if( [[self placeholder] length] > 0 )
    {
        if (_placeHolderLabel == nil )
        {
            _placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,8,self.bounds.size.width - 16,0)];
            _placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
            _placeHolderLabel.numberOfLines = 0;
            _placeHolderLabel.font = self.font;
            _placeHolderLabel.backgroundColor = [UIColor clearColor];
            _placeHolderLabel.textColor = self.placeholderColor;
            _placeHolderLabel.alpha = 0;
            _placeHolderLabel.tag = 999;
            [self addSubview:_placeHolderLabel];
        }
        
        _placeHolderLabel.text = self.placeholder;
        [_placeHolderLabel sizeToFit];
        [self sendSubviewToBack:_placeHolderLabel];
    }
    
    if( [[self text] length] == 0 && [[self placeholder] length] > 0 )
    {
        [[self viewWithTag:999] setAlpha:1];
        [btnClearTxtRemark setAlpha:0];
    }
    
    [super drawRect:rect];
}

@end
