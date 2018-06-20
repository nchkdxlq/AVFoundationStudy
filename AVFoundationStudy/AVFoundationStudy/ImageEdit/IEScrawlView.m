//
//  IEScrawlView.m
//  AVFoundationStudy
//
//  Created by nchkdxlq on 2018/6/19.
//  Copyright © 2018年 luoquan. All rights reserved.
//

#import "IEScrawlView.h"
#import "IESelectColorView.h"

@implementation IEScrawlView {
    IESelectColorView *_selectColorView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UIButton *recoverBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [self addSubview:recoverBtn];
        recoverBtn.center = CGPointMake(frame.size.width - 30, frame.size.height/2.0);
        recoverBtn.backgroundColor = [UIColor yellowColor];
        [recoverBtn addTarget:self action:@selector(recoverButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat width = CGRectGetMinX(recoverBtn.frame);
        _selectColorView = [[IESelectColorView alloc] initWithFrame:CGRectMake(0, 0, width, frame.size.height)];
        [self addSubview:_selectColorView];
        __weak typeof(self) weakSelf = self;
        _selectColorView.didSelectColorBlock = ^(UIColor *color) {
            [weakSelf setCurrentColor:color];
            !weakSelf.colorUpdateBlock ?: weakSelf.colorUpdateBlock(color);
        };
        _selectColorView.colors = [self getColors];
        [_selectColorView setDefaultSelectIndex:2];
    }
    return self;
}

- (void)setCurrentColor:(UIColor *)currentColor {
    _currentColor = currentColor;
}

- (void)recoverButtonAction:(UIButton *)button {
    !_recoverBlock ?: _recoverBlock();
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


/////////////////////////////////////////////////////////////////

#import <objc/runtime.h>

static char kColorKey;

@implementation IEScrawlMaskView {
    NSMutableArray<NSMutableArray<NSValue *> *> *_pathArr;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _pathArr = [NSMutableArray new];
    }
    return self;
}

- (UIColor *)scrawlColor {
    return _scrawlColor ? _scrawlColor : [UIColor blackColor];
}


- (void)recoverHandle {
    if (_pathArr.count > 0) {
        [_pathArr removeLastObject];
        [self setNeedsDisplay];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    NSMutableArray *path = [NSMutableArray new];
    objc_setAssociatedObject(path, &kColorKey, self.scrawlColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [_pathArr addObject:path];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    NSMutableArray *path = [_pathArr lastObject];
    CGPoint movePoint = [[touches anyObject] locationInView:self];
    [path addObject:[NSValue valueWithCGPoint:movePoint]];
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 6);
    
    for (NSInteger i = 0; i< _pathArr.count; i++) {
        NSMutableArray *pathPoints = [_pathArr objectAtIndex:i];
        
        UIColor *color = objc_getAssociatedObject(pathPoints, &kColorKey);
        CGContextSetStrokeColorWithColor(ctx, color.CGColor);
        
        CGMutablePathRef path = CGPathCreateMutable();
        for (NSInteger j = 0; j < pathPoints.count; j++) {
            CGPoint point = [[pathPoints objectAtIndex:j] CGPointValue] ;
            if (j == 0) {
                CGPathMoveToPoint(path, &CGAffineTransformIdentity, point.x,point.y);
            } else {
                CGPathAddLineToPoint(path, &CGAffineTransformIdentity, point.x, point.y);
            }
        }
        CGContextAddPath(ctx, path);
        CGContextStrokePath(ctx);
    }
}


@end

