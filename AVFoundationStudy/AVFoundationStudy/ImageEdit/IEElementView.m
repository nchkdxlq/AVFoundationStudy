//
//  IEElementView.m
//  AVFoundationStudy
//
//  Created by nchkdxlq on 2018/6/21.
//  Copyright © 2018年 luoquan. All rights reserved.
//

#import "IEElementView.h"

@implementation IEElementView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_contentView];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [self addGestureRecognizer:pan];
        
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
        [self addGestureRecognizer:pinch];
        
        UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationAction:)];
        [self addGestureRecognizer:rotation];
        
    }
    return self;
}


#pragma mark - 手势

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    // 如果父视图也实现了Pan手势，放到子视图后可能会造成子视图Pan手势失效，需要特殊处理一下
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]
        && ![gestureRecognizer.view isEqual:self])
    {
        return NO;
    }
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

- (void)panAction:(UIPanGestureRecognizer *)gestureRecognizer
{
    UIView *piece = [gestureRecognizer view];
    UIGestureRecognizerState state = gestureRecognizer.state;
    if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:[piece superview]];
        piece.center = CGPointMake(piece.center.x + translation.x, piece.center.y + translation.y);
        [gestureRecognizer setTranslation:CGPointZero inView:[piece superview]];
    }
    
    if (state == UIGestureRecognizerStateBegan) {
        if ([self.delegete respondsToSelector:@selector(elementViewBeginMove:)]) {
            [self.delegete elementViewBeginMove:self];
        }
    } else if (state == UIGestureRecognizerStateChanged) {
        if ([self.delegete respondsToSelector:@selector(elementViewMoveing:)]) {
            [self.delegete elementViewMoveing:self];
        }
    } else if (state == UIGestureRecognizerStateEnded) {
        if ([self.delegete respondsToSelector:@selector(elementViewEndMove:)]) {
            [self.delegete elementViewEndMove:self];
        }
    }
}

- (void)pinchAction:(UIPinchGestureRecognizer *)gestureRecognizer
{
    self.transform = CGAffineTransformScale(self.transform, gestureRecognizer.scale, gestureRecognizer.scale);
    gestureRecognizer.scale = 1.0f;
}

- (void)rotationAction:(UIRotationGestureRecognizer *)gestureRecognizer
{
    self.transform = CGAffineTransformRotate(self.transform, gestureRecognizer.rotation);
    gestureRecognizer.rotation = 0;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    _contentView.frame = self.bounds;
}

@end
