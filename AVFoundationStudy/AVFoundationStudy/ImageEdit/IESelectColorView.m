//
//  IESelectColorView.m
//  AVFoundationStudy
//
//  Created by nchkdxlq on 2018/6/19.
//  Copyright © 2018年 luoquan. All rights reserved.
//

#import "IESelectColorView.h"

@interface IESelectColorView()

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation IESelectColorView {
    NSMutableArray<UIButton *> *_colorButtons;
    UIButton *_selectedBtn;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.showsVerticalScrollIndicator = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_scrollView];
        
        _colorButtons = [NSMutableArray new];
    }
    return self;
}


- (void)setColors:(NSArray<UIColor *> *)colors {
    _colors = [colors copy];
    [_colorButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    __block CGFloat lastBtnRight = 0;
    CGFloat margin = 24;
    const CGFloat size = 20;
    CGFloat totalWidth = (margin + size) * colors.count + margin;
    if (totalWidth < self.bounds.size.width) {
        margin = (self.bounds.size.width - size * colors.count) / (colors.count + 1);
    }
    [colors enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, size, size)];
        [self->_colorButtons addObject:button];
        button.backgroundColor = obj;
        button.layer.cornerRadius = size / 2.0;
        button.layer.borderWidth = 2;
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        button.layer.masksToBounds = YES;
        button.tag = 0xff + idx;
        [button addTarget:self
                   action:@selector(buttonClickHandle:)
         forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:button];
        button.center = CGPointMake(lastBtnRight+margin, self.bounds.size.height/2.0);
        lastBtnRight = CGRectGetMaxX(button.frame);
    }];
    if (totalWidth > self.bounds.size.width) {
        _scrollView.contentSize = CGSizeMake(totalWidth, _scrollView.bounds.size.height);
    }
    [self setDefaultSelectIndex:0];
}


- (void)buttonClickHandle:(UIButton *)button {
    if (_selectedBtn) {
        _selectedBtn.transform = CGAffineTransformIdentity;
    }
    
    button.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    _selectedBtn = button;
    UIColor *color = _colors[button.tag-0xff];
    !_didSelectColorBlock ?: _didSelectColorBlock(color);
}

- (void)setDefaultSelectIndex:(NSInteger)defaultIndex {
    if (defaultIndex < _colorButtons.count) {
        UIButton *btn = _colorButtons[defaultIndex];
        [btn sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

@end
