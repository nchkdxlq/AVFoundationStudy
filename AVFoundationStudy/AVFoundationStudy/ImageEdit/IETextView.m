//
//  IETextView.m
//  AVFoundationStudy
//
//  Created by nchkdxlq on 2018/6/20.
//  Copyright © 2018年 luoquan. All rights reserved.
//

#import "IETextView.h"

@interface IETextView()
@property (nonatomic, strong) UITextView *textView;
@end

@implementation IETextView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.7];
        _textView = [[UITextView alloc] initWithFrame:self.bounds];
        [self addSubview:_textView];
        _textView.backgroundColor = [UIColor clearColor];
        
    }
    
    return self;
}


@end
