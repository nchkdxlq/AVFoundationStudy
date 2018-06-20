//
//  IETextToolView.h
//  AVFoundationStudy
//
//  Created by nchkdxlq on 2018/6/20.
//  Copyright © 2018年 luoquan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IETextToolView : UIView

@property (nonatomic, strong, readonly) UITextView *textView;

@property (nonatomic, copy) void(^cancelBlock)(void);

@property (nonatomic, copy) void(^doneBlock)(NSString *text);

- (void)addKeyboardObserver;
- (void)removeKeyboardObserver;

@end
