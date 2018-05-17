//
//  AVCameraPreviewView.h
//  AVFoundationStudy
//
//  Created by nchkdxlq on 2018/5/16.
//  Copyright © 2018年 luoquan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AVCameraPreviewView : UIView

@property (nonatomic, strong, readonly) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property (nonatomic, strong) AVCaptureSession *session;

+ (instancetype)previewViewWithSession:(AVCaptureSession *)session;

- (instancetype)initWithSession:(AVCaptureSession *)session;


@end
