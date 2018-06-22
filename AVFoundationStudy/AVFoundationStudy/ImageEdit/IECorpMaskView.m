//
//  IECorpMaskView.m
//  AVFoundationStudy
//
//  Created by nchkdxlq on 2018/6/21.
//  Copyright © 2018年 luoquan. All rights reserved.
//

#import "IECorpMaskView.h"

@interface IECorpMaskView()

@property (nonatomic, strong) UIView *topMaskView;
@property (nonatomic, strong) UIView *leftMaskView;
@property (nonatomic, strong) UIView *bottomMaskView;
@property (nonatomic, strong) UIView *rightMaskView;

@property (nonatomic, strong) UIView *topBorderView;
@property (nonatomic, strong) UIView *leftBorderView;
@property (nonatomic, strong) UIView *bottomBorderView;
@property (nonatomic, strong) UIView *rightBorderView;


@property (nonatomic, strong) UIView *leftTopCorner;
@property (nonatomic, strong) UIView *leftBottomCorner;
@property (nonatomic, strong) UIView *rightTopCorner;
@property (nonatomic, strong) UIView *rightBottomCorner;

@property (nonatomic, strong) UIView *touchView;

@end


@implementation IECorpMaskView

#pragma mark - maskView getter

- (UIView *)topMaskView {
    if (!_topMaskView) {
        _topMaskView = [UIView new];
        [self addSubview:_topMaskView];
    }
    return _topMaskView;
}

- (UIView *)leftMaskView {
    if (!_leftMaskView) {
        _leftMaskView = [UIView new];
        [self addSubview:_leftMaskView];
    }
    return _leftMaskView;
}

- (UIView *)bottomMaskView {
    if (!_bottomMaskView) {
        _bottomMaskView = [UIView new];
        [self addSubview:_bottomMaskView];
    }
    return _bottomMaskView;
}

- (UIView *)rightMaskView {
    if (!_rightMaskView) {
        _rightMaskView = [UIView new];
        [self addSubview:_rightMaskView];
    }
    return _rightMaskView;
}

#pragma mark - borderView getter

- (UIView *)topBorderView {
    if (!_topBorderView) {
        _topBorderView = [UIView new];
        [self addSubview:_topBorderView];
    }
    return _topBorderView;
}

- (UIView *)leftBorderView {
    if (!_leftBorderView) {
        _leftBorderView = [UIView new];
        [self addSubview:_leftBorderView];
    }
    return _leftBorderView;
}

- (UIView *)bottomBorderView {
    if (!_bottomBorderView) {
        _bottomBorderView = [UIView new];
        [self addSubview:_bottomBorderView];
    }
    return _bottomBorderView;
}

- (UIView *)rightBorderView {
    if (!_rightBorderView) {
        _rightBorderView = [UIView new];
        [self addSubview:_rightBorderView];
    }
    return _rightBorderView;
}

#pragma mark - cornerViews getter

- (UIView *)leftTopCorner{
    if (!_leftTopCorner) {
        _leftTopCorner = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [self addSubview:_leftTopCorner];
    }
    return _leftTopCorner;
}

- (UIView *)leftBottomCorner {
    if (!_leftBottomCorner) {
        _leftBottomCorner = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [self addSubview:_leftBottomCorner];
    }
    return _leftBottomCorner;
}

- (UIView *)rightTopCorner {
    if (!_rightTopCorner) {
        _rightTopCorner = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [self addSubview:_rightTopCorner];
    }
    return _rightTopCorner;
}

- (UIView *)rightBottomCorner {
    if (!_rightBottomCorner) {
        _rightBottomCorner = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [self addSubview:_rightBottomCorner];
    }
    return _rightBottomCorner;
}



- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self updateMaskColor];
    }
    return self;
}


- (void)updateMaskColor {
    UIColor *maskColor = [UIColor colorWithWhite:0.4 alpha:0.7];
    self.topMaskView.backgroundColor = maskColor;
    self.leftMaskView.backgroundColor = maskColor;
    self.bottomMaskView.backgroundColor = maskColor;
    self.rightMaskView.backgroundColor = maskColor;
}

- (void)setCorpRect:(CGRect)corpRect {
    _corpRect = corpRect;
    
    CGFloat X = self.bounds.size.width * corpRect.origin.x;
    CGFloat Y = self.bounds.size.height * corpRect.origin.y;
    CGFloat W = self.bounds.size.width * corpRect.size.width;
    CGFloat H = self.bounds.size.height * corpRect.size.height;
    _interestRect = CGRectMake(X, Y, W, H);
    
    self.topMaskView.frame = CGRectMake(0, 0,
                                        self.bounds.size.width,
                                        self.bounds.size.height*corpRect.origin.y);
    
    self.bottomMaskView.frame = CGRectMake(0,
                                           self.bounds.size.height * CGRectGetMaxY(corpRect),
                                           self.bounds.size.width,
                                           self.bounds.size.height * (1 - CGRectGetMaxY(corpRect)));
    self.leftMaskView.frame = CGRectMake(0,
                                         CGRectGetMaxY(self.topMaskView.frame),
                                         self.bounds.size.width * corpRect.origin.x,
                                         H);
    self.rightMaskView.frame = CGRectMake(self.bounds.size.width * CGRectGetMaxX(corpRect),
                                          CGRectGetMaxY(self.topMaskView.frame),
                                          self.bounds.size.width * (1 - CGRectGetMaxX(corpRect)),
                                          H);
    
    self.topBorderView.frame = CGRectMake(CGRectGetMaxX(self.leftMaskView.frame),
                                          CGRectGetMaxY(self.topMaskView.frame)-10,
                                          W, 20);
    self.bottomBorderView.frame = CGRectMake(CGRectGetMaxX(self.leftMaskView.frame),
                                             CGRectGetMinY(self.bottomMaskView.frame)-10,
                                             W, 20);
    
    self.leftBorderView.frame = CGRectMake(CGRectGetMaxX(self.leftMaskView.frame)-10,
                                          CGRectGetMaxY(self.topMaskView.frame),
                                          20, H);
    self.rightBorderView.frame = CGRectMake(CGRectGetMinX(self.rightMaskView.frame)-10,
                                           CGRectGetMaxY(self.topMaskView.frame),
                                           20, H);
    
    self.leftTopCorner.center = CGPointMake(X, Y);
    self.leftBottomCorner.center = CGPointMake(X, Y+H);
    self.rightTopCorner.center = CGPointMake(X+W, Y);
    self.rightBottomCorner.center = CGPointMake(X+W, Y+H);
    
    self.topBorderView.backgroundColor = self.leftBorderView.backgroundColor = self.bottomBorderView.backgroundColor = self.rightBorderView.backgroundColor = [UIColor redColor];
    
    self.leftTopCorner.backgroundColor = self.leftBottomCorner.backgroundColor = self.rightTopCorner.backgroundColor = self.rightBottomCorner.backgroundColor = [UIColor yellowColor];
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    if (CGRectContainsPoint(self.leftTopCorner.frame, point)) {
        _touchView = self.leftTopCorner;
    } else if (CGRectContainsPoint(self.leftBottomCorner.frame, point)) {
        _touchView = self.leftBottomCorner;
    } else if (CGRectContainsPoint(self.rightTopCorner.frame, point)) {
        _touchView = self.rightTopCorner;
    } else if (CGRectContainsPoint(self.rightBottomCorner.frame, point)) {
        _touchView = self.rightBottomCorner;
    }
    else if (CGRectContainsPoint(self.topBorderView.frame, point)) {
        _touchView = self.topBorderView;
    } else if (CGRectContainsPoint(self.leftBorderView.frame, point)) {
        _touchView = self.leftBorderView;
    } else if (CGRectContainsPoint(self.bottomBorderView.frame, point)) {
        _touchView = self.bottomBorderView;
    } else if (CGRectContainsPoint(self.rightBorderView.frame, point)) {
        _touchView = self.rightBorderView;
    } else {
        _touchView = nil;
    }
    return _touchView;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    if (_touchView == nil) return;
    
    UITouch *touch = touches.anyObject;
    CGPoint prePoint = [touch previousLocationInView:self];
    CGPoint curPoint = [touch locationInView:self];
    CGRect corpRect = self.corpRect;
    // 四条边
    if (_touchView == self.topBorderView) {
        CGFloat detal = (curPoint.y - prePoint.y) / self.bounds.size.height;
        corpRect.origin.y += detal;
        corpRect.size.height -= detal;
    } else if (_touchView == self.bottomBorderView) {
        CGFloat detal = (curPoint.y - prePoint.y) / self.bounds.size.height;
        corpRect.size.height += detal;
    } else if (_touchView == self.leftBorderView) {
        CGFloat detal = (curPoint.x - prePoint.x) / self.bounds.size.width;
        corpRect.origin.x += detal;
        corpRect.size.width -= detal;
    } else if (_touchView == self.rightBorderView) {
        CGFloat detal = (curPoint.x - prePoint.x) / self.bounds.size.width;
        corpRect.size.width += detal;
    }
    // 四个顶点
    else if (_touchView == self.leftTopCorner) {
        CGFloat detalX = (curPoint.x - prePoint.x) / self.bounds.size.width;
        CGFloat detalY = (curPoint.y - prePoint.y) / self.bounds.size.height;
        corpRect.origin.x += detalX;
        corpRect.origin.y += detalY;
        corpRect.size.width -= detalX;
        corpRect.size.height -= detalY;
    } else if (_touchView == self.leftBottomCorner) {
        CGFloat detalX = (curPoint.x - prePoint.x) / self.bounds.size.width;
        CGFloat detalY = (curPoint.y - prePoint.y) / self.bounds.size.height;
        corpRect.origin.x += detalX;
        corpRect.size.width -= detalX;
        corpRect.size.height += detalY;
    } else if (_touchView == self.rightTopCorner) {
        CGFloat detalX = (curPoint.x - prePoint.x) / self.bounds.size.width;
        CGFloat detalY = (curPoint.y - prePoint.y) / self.bounds.size.height;
        corpRect.origin.y += detalY;
        corpRect.size.width += detalX;
        corpRect.size.height -= detalY;
    } else if (_touchView == self.rightBottomCorner) {
        CGFloat detalX = (curPoint.x - prePoint.x) / self.bounds.size.width;
        CGFloat detalY = (curPoint.y - prePoint.y) / self.bounds.size.height;
        corpRect.size.width += detalX;
        corpRect.size.height += detalY;
    }
    
    CGFloat x = self.bounds.size.width * corpRect.origin.x;
    CGFloat y = self.bounds.size.height * corpRect.origin.y;
    CGFloat width = self.bounds.size.width * corpRect.size.width;
    CGFloat height = self.bounds.size.height * corpRect.size.height;
    // 宽度限制
    if (width < 60 && width < _interestRect.size.width) {
        corpRect.size.width = self.corpRect.size.width;
    }
    // 高度限制
    if (height < 60 && height < _interestRect.size.height) {
        corpRect.size.height = self.corpRect.size.height;
    }
    
    // 边界限制
    if (x < 10 && x < self.interestRect.origin.x) {
        corpRect.origin.x = self.corpRect.origin.x;
    }
    if (y < 30 && y < self.interestRect.origin.y) {
        corpRect.origin.y = self.corpRect.origin.y;
    }
    if (self.bounds.size.width - (x + width) < 10) {
        corpRect.size.width = self.corpRect.size.width;
    }
    if (self.bounds.size.height - (y + height) < 30) {
        corpRect.size.height = self.corpRect.size.height;
    }
    
    self.corpRect = corpRect;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
}



@end
