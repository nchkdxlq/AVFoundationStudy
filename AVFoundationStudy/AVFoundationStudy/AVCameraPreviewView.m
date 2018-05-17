//
//  AVCameraPreviewView.m
//  AVFoundationStudy
//
//  Created by nchkdxlq on 2018/5/16.
//  Copyright © 2018年 luoquan. All rights reserved.
//

@import AVFoundation;

#import "AVCameraPreviewView.h"

@implementation AVCameraPreviewView

+ (Class)layerClass {
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureVideoPreviewLayer *)videoPreviewLayer {
    return (AVCaptureVideoPreviewLayer *)self.layer;
}

+ (instancetype)previewViewWithSession:(AVCaptureSession *)session {
    return [[self alloc] initWithSession:session];
}

- (instancetype)initWithSession:(AVCaptureSession *)session {
    self = [super init];
    if (self) {
        self.session = session;
    }
    return self;
}

- (AVCaptureSession *)session {
    return self.videoPreviewLayer.session;
}

- (void)setSession:(AVCaptureSession *)session {
    self.videoPreviewLayer.session = session;
}

@end
