//
//  IETextElementView.m
//  AVFoundationStudy
//
//  Created by nchkdxlq on 2018/6/21.
//  Copyright © 2018年 luoquan. All rights reserved.
//

#import "IETextElementView.h"

@implementation IETextElementView {
    UILabel *_label;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _label = [UILabel new];
        _label.numberOfLines = 0;
//        _label.textAlignment = NSTextAlignmentCenter;
        _label.font = [UIFont systemFontOfSize:27];
        [self.contentView addSubview:_label];
        _maxWith = [UIScreen mainScreen].bounds.size.width - 20;
    }
    return self;
}


- (void)setText:(NSString *)text {
    _text = [text copy];
    _label.text = text;
    [self updateSize];
}

- (void)setTextFont:(UIFont *)textFont {
    _label.font = textFont;
    [self updateSize];
}

- (void)setTextColor:(UIColor *)textColor {
    _label.textColor = textColor;
}

- (void)updateSize {
    if (_text.length == 0) {
        
        return;
    }
    
    NSAttributedString *attr = [[NSAttributedString alloc] initWithString:_text
                                                               attributes:@{NSFontAttributeName:_label.font}];
    CGSize size = [attr boundingRectWithSize:CGSizeMake(_maxWith, MAXFLOAT)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                     context:NULL].size;
    size.width = ceil(size.width);
    size.height = ceil(size.height);
    
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
    _label.frame = CGRectMake(0, 0, size.width, size.height);
}




@end
