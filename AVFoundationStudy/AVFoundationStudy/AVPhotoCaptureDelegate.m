//
//  AVPhotoCaptureDelegate.m
//  AVFoundationStudy
//
//  Created by nchkdxlq on 2018/5/17.
//  Copyright © 2018年 luoquan. All rights reserved.
//

#import "AVPhotoCaptureDelegate.h"

@implementation AVPhotoCaptureDelegate


- (void)captureOutput:(AVCapturePhotoOutput *)output willBeginCaptureForResolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings
{
    NSLog(@"willBeginCaptureForResolvedSettings");
}

- (void)captureOutput:(AVCapturePhotoOutput *)output willCapturePhotoForResolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings {
     NSLog(@"willCapturePhotoForResolvedSettings");
}

- (void)captureOutput:(AVCapturePhotoOutput *)output didCapturePhotoForResolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings
{
    NSLog(@"didCapturePhotoForResolvedSettings");
}

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(nullable NSError *)error  API_AVAILABLE(ios(11.0))
{
    NSLog(@"didFinishProcessingPhoto");
}

@end
