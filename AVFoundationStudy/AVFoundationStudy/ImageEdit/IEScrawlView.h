//
//  IEScrawlView.h
//  AVFoundationStudy
//
//  Created by nchkdxlq on 2018/6/19.
//  Copyright © 2018年 luoquan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IEScrawlView : UIView

@property (nonatomic, strong, readonly) UIColor *currentColor;

@property (nonatomic, copy) void(^colorUpdateBlock)(UIColor *color);

@property (nonatomic, copy) void(^backBlock)(void);

@end

/////////////////////////////////////////////////////////////////

@interface IEScrawlMaskView : UIView

@property (nonatomic, strong) UIColor *scrawlColor;

- (void)recoverHandle;

@end
