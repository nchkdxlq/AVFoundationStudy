//
//  IETextElementView.h
//  AVFoundationStudy
//
//  Created by nchkdxlq on 2018/6/21.
//  Copyright © 2018年 luoquan. All rights reserved.
//

#import "IEElementView.h"

@interface IETextElementView : IEElementView

@property (nonatomic, assign) CGFloat maxWith;

@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) UIColor *textColor;

@end
