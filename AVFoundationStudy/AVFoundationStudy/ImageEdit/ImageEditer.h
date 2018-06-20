//
//  ImageEditer.h
//  AVFoundationStudy
//
//  Created by nchkdxlq on 2018/6/19.
//  Copyright © 2018年 luoquan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageEditer : UIView

@property (nonatomic, strong, readonly) UIImage *image;


+ (instancetype)imageEditerWithImage:(UIImage *)image;

- (instancetype)initWithImage:(UIImage *)image;

- (void)show;

@end

NS_ASSUME_NONNULL_END
