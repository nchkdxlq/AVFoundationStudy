//
//  IETextToolView.m
//  AVFoundationStudy
//
//  Created by nchkdxlq on 2018/6/20.
//  Copyright © 2018年 luoquan. All rights reserved.
//

#import "IETextToolView.h"
#import "IESelectColorView.h"


const CGFloat kTextViewTopY = 60;
const CGFloat kColorViewHeight = 40;
const CGFloat kBottomHeight = 20;
const CGFloat kLeftRightMargin = 6;

@implementation IETextToolView {
    IESelectColorView *_selectColorView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.7];
        
        UIButton *cancel = [UIButton new];
        [self addSubview:cancel];
        cancel.backgroundColor = [UIColor clearColor];
        cancel.titleLabel.font = [UIFont systemFontOfSize:17];
        [cancel setTitle:@"取消" forState:UIControlStateNormal];
        [cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancel sizeToFit];
        cancel.center = CGPointMake(cancel.bounds.size.width/2.0 + 10, 40);
        [cancel addTarget:self action:@selector(cancelHandle:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *done = [UIButton new];
        [self addSubview:done];
        done.backgroundColor = [UIColor clearColor];
        done.titleLabel.font = cancel.titleLabel.font;
        [done setTitle:@"确定" forState:UIControlStateNormal];
        [done setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [done sizeToFit];
        done.center = CGPointMake(frame.size.width - 10 - done.bounds.size.width/2.0, cancel.center.y);
        [done addTarget:self action:@selector(doneHandle:) forControlEvents:UIControlEventTouchUpInside];
    
        CGFloat tWidth = frame.size.width - 2*kLeftRightMargin;
        CGFloat tHeight = frame.size.height - kTextViewTopY - kColorViewHeight - kBottomHeight;
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(kLeftRightMargin, kTextViewTopY, tWidth, tHeight)];
        [self addSubview:_textView];
        _textView.backgroundColor = [UIColor clearColor];
        _textView.font = [UIFont systemFontOfSize:27];
        
        _selectColorView = [[IESelectColorView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_textView.frame), frame.size.width, kColorViewHeight)];
        _selectColorView.backgroundColor = [UIColor clearColor];
        [self addSubview:_selectColorView];
        __weak typeof(self) weakSelf = self;
        _selectColorView.didSelectColorBlock = ^(UIColor *color) {
            weakSelf.textView.textColor = color;
        };
        _selectColorView.colors = [self getColors];
        [_selectColorView setDefaultSelectIndex:2];
        
        [self addKeyboardObserver];
    }
    
    return self;
}

#pragma mark - button action

- (void)cancelHandle:(UIButton *)button {
    self.textView.text = nil;
    !_cancelBlock ?: _cancelBlock();
}

- (void)doneHandle:(UIButton *)button {
    NSString *text = self.textView.text;
    self.textView.text = nil;
    !_doneBlock ?: _doneBlock(text);
}

#pragma mark - keyboarObserver

- (void)addKeyboardObserver {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(keyboardDidShowHandle:)
                   name:UIKeyboardWillShowNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(keyboardDidHideHandle:)
                   name:UIKeyboardWillHideNotification
                 object:nil];
}

- (void)removeKeyboardObserver {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [center removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

/*

 UIKeyboardAnimationCurveUserInfoKey = 7;
 UIKeyboardAnimationDurationUserInfoKey = "0.25";
 UIKeyboardBoundsUserInfoKey = "NSRect: {{0, 0}, {375, 258}}";
 UIKeyboardCenterBeginUserInfoKey = "NSPoint: {187.5, 796}";
 UIKeyboardCenterEndUserInfoKey = "NSPoint: {187.5, 538}";
 UIKeyboardFrameBeginUserInfoKey = "NSRect: {{0, 667}, {375, 258}}";
 UIKeyboardFrameEndUserInfoKey = "NSRect: {{0, 409}, {375, 258}}";
 UIKeyboardIsLocalUserInfoKey = 1;

 */
- (void)keyboardDidShowHandle:(NSNotification *)noti {
    CGFloat keyBoardHeight = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGRect rect = _textView.frame;
    rect.size.height = self.frame.size.height - kTextViewTopY - kColorViewHeight - keyBoardHeight - 10;
    _textView.frame = rect;
    _selectColorView.frame = CGRectMake(0, CGRectGetMaxY(_textView.frame), self.frame.size.width, kColorViewHeight);
}

- (void)keyboardDidHideHandle:(NSNotification *)noti {
    CGRect rect = _textView.frame;
    rect.size.height = self.frame.size.height - kTextViewTopY - kColorViewHeight - kBottomHeight;
    _textView.frame = rect;
    _textView.frame = rect;
    _selectColorView.frame = CGRectMake(0, CGRectGetMaxY(_textView.frame), self.frame.size.width, kColorViewHeight);
}


- (NSArray<UIColor *> *)getColors {
    return @[[UIColor whiteColor],
             [UIColor redColor],
             [UIColor greenColor],
             [UIColor blueColor],
             [UIColor blackColor],
             [UIColor purpleColor]
             ];
}

@end
