//
//  IEMosaicView.m
//  AVFoundationStudy
//
//  Created by nchkdxlq on 2018/6/20.
//  Copyright © 2018年 luoquan. All rights reserved.
//

#import "IEMosaicView.h"

@interface IEMosaicView()

@property (nonatomic, strong) CALayer *mosaicLayer;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@property (nonatomic, assign) CGMutablePathRef path;

@end

@implementation IEMosaicView {
    NSMutableArray<NSMutableArray<NSValue *> *> *_pointsArr;
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.frame = self.bounds;
        _shapeLayer.lineCap = kCALineCapRound;
        _shapeLayer.lineJoin = kCALineJoinRound;
        _shapeLayer.lineWidth = 20;
        _shapeLayer.strokeColor = [UIColor blueColor].CGColor;
        _shapeLayer.fillColor = nil;//此处必须设为nil，否则后边添加addLine的时候会自动填充
    
        _mosaicLayer = [CALayer layer];
        [self.layer addSublayer:_mosaicLayer];
        _mosaicLayer.frame = self.bounds;
        _mosaicLayer.mask = _shapeLayer;
        
        self.path = CGPathCreateMutable();
        
        _pointsArr = [NSMutableArray new];
    }
    
    return self;
}

- (void)setMosaicImage:(UIImage *)mosaicImage {
    _mosaicImage = mosaicImage;
    _mosaicLayer.contents = (id)mosaicImage.CGImage;
}

- (void)recoverHandle {
    if (_pointsArr.count == 0) return;
    [_pointsArr removeLastObject];
    CGPathRelease(self.path);
    self.path = CGPathCreateMutable();
    if (_pointsArr.count > 0) {
        for (NSArray<NSValue *> *points in _pointsArr) {
            BOOL first = YES;
            for (NSValue *value in points) {
                CGPoint point = [value CGPointValue];
                if (first) {
                    first = NO;
                    CGPathMoveToPoint(self.path, nil, point.x, point.y);
                } else {
                    CGPathAddLineToPoint(self.path, nil, point.x, point.y);
                }
            }
        }
    }
    self.shapeLayer.path = self.path;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];

    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGPathMoveToPoint(self.path, nil, point.x, point.y);
    self.shapeLayer.path = self.path;
    NSMutableArray<NSValue *> *points = [NSMutableArray new];
    [_pointsArr addObject:points];
    [points addObject:[NSValue valueWithCGPoint:point]];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGPathAddLineToPoint(self.path, nil, point.x, point.y);
    self.shapeLayer.path = self.path;
    NSMutableArray<NSValue *> *points = [_pointsArr lastObject];
    [points addObject:[NSValue valueWithCGPoint:point]];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
}


- (void)dealloc {
     CGPathRelease(self.path);
}

@end
