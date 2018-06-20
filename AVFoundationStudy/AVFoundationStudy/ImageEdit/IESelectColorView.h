//
//  IESelectColorView.h
//  AVFoundationStudy
//
//  Created by nchkdxlq on 2018/6/19.
//  Copyright © 2018年 luoquan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IESelectColorView : UIView

@property (nonatomic, strong) NSArray<UIColor *> *colors;

@property (nonatomic, copy) void(^didSelectColorBlock)(UIColor *color);

- (void)setDefaultSelectIndex:(NSInteger)defaultIndex;

@end
