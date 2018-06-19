//
//  UIScreen+easy.m
//  AVFoundationStudy
//
//  Created by nchkdxlq on 2018/6/10.
//  Copyright © 2018年 luoquan. All rights reserved.
//

#import "UIScreen+easy.h"

@implementation UIScreen (easy)

+ (CGFloat)width {
    return [UIScreen mainScreen].bounds.size.width;
}

+ (CGFloat)height {
    return [UIScreen mainScreen].bounds.size.height;
}

+ (CGSize)size {
    return [UIScreen mainScreen].bounds.size;
}

@end
