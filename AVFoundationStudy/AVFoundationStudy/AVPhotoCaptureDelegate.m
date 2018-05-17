//
//  AVPhotoCaptureDelegate.m
//  AVFoundationStudy
//
//  Created by nchkdxlq on 2018/5/17.
//  Copyright © 2018年 luoquan. All rights reserved.
//

@import Photos;

#import "AVPhotoCaptureDelegate.h"

@interface AVPhotoCaptureDelegate()

@property (nonatomic) NSData *photoData;
@property (nonatomic) NSURL *livePhotoCompanionMovieURL;

@end

@implementation AVPhotoCaptureDelegate


- (instancetype)initWithRequestedPhotoSettings:(AVCapturePhotoSettings *)requestedPhotoSettings
{
    self = [self init];
    if (self) {
        _requestedPhotoSettings = requestedPhotoSettings;
    }
    return self;
}

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
    
    if ( error != nil ) {
        NSLog( @"Error capturing photo: %@", error );
        return;
    }
    self.photoData = [photo fileDataRepresentation];
}

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishRecordingLivePhotoMovieForEventualFileAtURL:(NSURL *)outputFileURL resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings
{
    NSLog(@"didFinishRecordingLivePhotoMovieForEventualFileAtURL");
}

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingLivePhotoToMovieFileAtURL:(NSURL *)outputFileURL duration:(CMTime)duration photoDisplayTime:(CMTime)photoDisplayTime resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings error:(nullable NSError *)error
{
    NSLog(@"didFinishProcessingLivePhotoToMovieFileAtURL");
}

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishCaptureForResolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings error:(nullable NSError *)error
{
    NSLog(@"didFinishCaptureForResolvedSettings");
    
    [PHPhotoLibrary requestAuthorization:^( PHAuthorizationStatus status ) {
        if ( status == PHAuthorizationStatusAuthorized ) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
                if (@available(iOS 11.0, *)) {
                    options.uniformTypeIdentifier = self.requestedPhotoSettings.processedFileType;
                } else {
                    // Fallback on earlier versions
                }
                PHAssetCreationRequest *creationRequest = [PHAssetCreationRequest creationRequestForAsset];
                [creationRequest addResourceWithType:PHAssetResourceTypePhoto data:self.photoData options:options];
                
                if ( self.livePhotoCompanionMovieURL ) {
                    PHAssetResourceCreationOptions *livePhotoCompanionMovieResourceOptions = [[PHAssetResourceCreationOptions alloc] init];
                    livePhotoCompanionMovieResourceOptions.shouldMoveFile = YES;
                    [creationRequest addResourceWithType:PHAssetResourceTypePairedVideo fileURL:self.livePhotoCompanionMovieURL options:livePhotoCompanionMovieResourceOptions];
                }
            } completionHandler:^( BOOL success, NSError * _Nullable error ) {
                if ( ! success ) {
                    NSLog( @"Error occurred while saving photo to photo library: %@", error );
                }
                
                [self didFinish];
            }];
        }
        else {
            NSLog( @"Not authorized to save photo" );
            [self didFinish];
        }
    }];
}


- (void)didFinish
{
    if ( [[NSFileManager defaultManager] fileExistsAtPath:self.livePhotoCompanionMovieURL.path] ) {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:self.livePhotoCompanionMovieURL.path error:&error];
        
        if ( error ) {
            NSLog( @"Could not remove file at url: %@", self.livePhotoCompanionMovieURL.path );
        }
    }
}

@end
