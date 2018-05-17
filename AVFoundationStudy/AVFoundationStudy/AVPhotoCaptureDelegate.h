//
//  AVPhotoCaptureDelegate.h
//  AVFoundationStudy
//
//  Created by nchkdxlq on 2018/5/17.
//  Copyright © 2018年 luoquan. All rights reserved.
//

#import <Foundation/Foundation.h>

@import AVFoundation;

@interface AVPhotoCaptureDelegate : NSObject <AVCapturePhotoCaptureDelegate>

- (instancetype)initWithRequestedPhotoSettings:(AVCapturePhotoSettings *)requestedPhotoSettings;

@property (nonatomic, readonly) AVCapturePhotoSettings *requestedPhotoSettings;

@end
