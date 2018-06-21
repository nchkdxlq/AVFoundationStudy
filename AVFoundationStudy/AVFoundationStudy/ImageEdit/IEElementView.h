//
//  IEElementView.h
//  AVFoundationStudy
//
//  Created by nchkdxlq on 2018/6/21.
//  Copyright © 2018年 luoquan. All rights reserved.
//

#import <UIKit/UIKit.h>


@class IEElementView;

@protocol IEElementViewDelegate <NSObject>

@optional
- (void)elementViewBeginMove:(IEElementView *)elementView;
- (void)elementViewMoveing:(IEElementView *)elementView;
- (void)elementViewEndMove:(IEElementView *)elementView;

@end


@interface IEElementView : UIView

@property (nonatomic, strong, readonly) UIView *contentView;

@property (nonatomic, weak) id<IEElementViewDelegate> delegete;

@end
