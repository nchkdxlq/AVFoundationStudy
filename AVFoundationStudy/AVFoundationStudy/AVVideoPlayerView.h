//
//  AVVideoPlayerView.h
//  AVFoundationStudy
//
//  Created by nchkdxlq on 2018/6/11.
//  Copyright © 2018年 luoquan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlayer, AVPlayerLayer;

@interface AVVideoPlayerView : UIView

@property (nonatomic, strong) AVPlayer *player;

- (AVPlayerLayer *)layer;


@end
