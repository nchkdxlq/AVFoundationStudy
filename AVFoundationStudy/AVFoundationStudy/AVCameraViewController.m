//
//  AVCameraViewController.m
//  AVFoundationStudy
//
//  Created by nchkdxlq on 2018/5/16.
//  Copyright © 2018年 luoquan. All rights reserved.
//

@import AVFoundation;

#import "AVCameraViewController.h"
#import "AVCameraPreviewView.h"


typedef NS_ENUM(NSInteger, AVCameraSetupResult) {
    AVCameraSetupResultSuccess,
    AVCameraSetupResultCameraNotAuthorized,
    AVCameraSetupResultSessionConfigFailed
};

@interface AVCameraViewController ()

@property (nonatomic, strong) AVCameraPreviewView *previewView;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) dispatch_queue_t sessionQueue;

@property (nonatomic, assign) AVCameraSetupResult camSetupResult;

@end

@implementation AVCameraViewController


- (AVCameraPreviewView *)previewView {
    if (!_previewView) {
        _previewView = [[AVCameraPreviewView alloc] initWithFrame:self.view.bounds];
    }
    return _previewView;
}

- (AVCaptureSession *)session {
    if (!_session) {
        _session = [AVCaptureSession new];
    }
    return _session;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.previewView];
    self.previewView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.previewView.session = self.session;
    
    self.sessionQueue = dispatch_queue_create("config.session.queue", DISPATCH_QUEUE_SERIAL);
    
    [self requestDeviceAccess];
    
    dispatch_async(self.sessionQueue, ^{
        [self configSession];
    });
}

- (void)requestDeviceAccess {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusAuthorized:
        {
            self.camSetupResult = AVCameraSetupResultSuccess;
            break;
        }

        case AVAuthorizationStatusNotDetermined:
        {
            dispatch_suspend(self.sessionQueue);
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    self.camSetupResult = AVCameraSetupResultSuccess;
                } else {
                    self.camSetupResult = AVCameraSetupResultCameraNotAuthorized;
                }
                dispatch_resume(self.sessionQueue);
            }];
            break;
        }
            
        default:
        {
            self.camSetupResult = AVCameraSetupResultCameraNotAuthorized;
            break;
        }
    }
}


- (void)configSession {
    if (self.camSetupResult != AVCameraSetupResultSuccess) {
        return;
    }
    
    [self.session beginConfiguration];
    
    if ([self.session canSetSessionPreset:AVCaptureSessionPresetPhoto]) {
        self.session.sessionPreset = AVCaptureSessionPresetPhoto;
    }
    
    // add video input
    
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:NULL];
    if (videoInput && [self.session canAddInput:videoInput]) {
        [self.session addInput:videoInput];
    } else {
        self.camSetupResult = AVCameraSetupResultSessionConfigFailed;
        [self.session commitConfiguration];
        return;
    }
    
    // add audio input
    
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:NULL];
    if (audioInput && [self.session canAddInput:audioInput]) {
        [self.session addInput:audioInput];
    } else {
        [self.session commitConfiguration];
        return;
    }
    
    [self.session commitConfiguration];
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
