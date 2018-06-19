//
//  AVVideoPlayerViewController.m
//  AVFoundationStudy
//
//  Created by nchkdxlq on 2018/6/11.
//  Copyright © 2018年 luoquan. All rights reserved.
//

#import "AVVideoPlayerViewController.h"
#import "AVVideoPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import "UIScreen+easy.h"

@interface AVVideoPlayerViewController ()

@property (nonatomic, strong) AVVideoPlayerView *playerView;

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;

@end

@implementation AVVideoPlayerViewController

- (void)dealloc {
    [_playerItem removeObserver:self forKeyPath:@"status"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *playBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
    playBtn.backgroundColor = [UIColor greenColor];
    [playBtn setTitle:@"Play" forState:UIControlStateNormal];
    [playBtn setTitle:@"Stop" forState:UIControlStateSelected];
    playBtn.layer.cornerRadius = 6;
    playBtn.layer.masksToBounds = YES;
    [self.view addSubview:playBtn];
    playBtn.center = CGPointMake(UIScreen.width/2.0, 100);
    [playBtn addTarget:self
                action:@selector(playVideoAction:)
      forControlEvents:UIControlEventTouchUpInside];
    
    _playerView = [[AVVideoPlayerView alloc] initWithFrame:CGRectMake(0, 0, 300, 400)];
    [self.view addSubview:_playerView];
    _playerView.center = self.view.center;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"video1" ofType:@"mp4"];
    NSURL *url = [NSURL fileURLWithPath:path];
    _playerItem = [[AVPlayerItem alloc] initWithURL:url];
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew;
    [_playerItem addObserver:self forKeyPath:@"status" options:options context:NULL];
    
    _player = [[AVPlayer alloc] initWithPlayerItem:_playerItem];
    _playerView.player = _player;
}


- (void)playVideoAction:(UIButton *)button {
    if (button.isSelected) {
        [_player pause];
    } else {
        [_player play];
    }
    button.selected = !button.isSelected;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == _playerItem) {
        if ([keyPath isEqualToString:@"status"]) {
            NSLog(@"change = %@", change);
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
