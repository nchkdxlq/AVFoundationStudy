//
//  AVVideoPlayerView.m
//  AVFoundationStudy
//
//  Created by nchkdxlq on 2018/6/11.
//  Copyright © 2018年 luoquan. All rights reserved.
//

#import "AVVideoPlayerView.h"
#import <AVFoundation/AVPlayerLayer.h>
#import <AVFoundation/AVPlayer.h>

@implementation AVVideoPlayerView


+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayerLayer *)layer {
    return (AVPlayerLayer *)[super layer];
}

- (AVPlayer *)player {
    return self.layer.player;
}

- (void)setPlayer:(AVPlayer *)player {
    self.layer.player = player;
}

@end
