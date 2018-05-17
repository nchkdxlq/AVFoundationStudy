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
#import "AVPhotoCaptureDelegate.h"

typedef NS_ENUM(NSInteger, AVCameraSetupResult) {
    AVCameraSetupResultSuccess,
    AVCameraSetupResultCameraNotAuthorized,
    AVCameraSetupResultSessionConfigFailed
};

@interface AVCameraViewController ()

@property (nonatomic, strong) AVCameraPreviewView *previewView;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) dispatch_queue_t sessionQueue;

@property (nonatomic, strong) AVCaptureDeviceInput *videoDeviceInout;
@property (nonatomic, strong) AVCaptureDeviceInput *audioDeviceInout;

@property (nonatomic, strong) AVCapturePhotoOutput *photoOutput;
@property (nonatomic, strong) AVPhotoCaptureDelegate *photoCapDelegate;

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

- (AVCapturePhotoOutput *)photoOutput {
    if (!_photoOutput) {
        _photoOutput = [AVCapturePhotoOutput new];
        _photoOutput.highResolutionCaptureEnabled = YES;
        _photoOutput.livePhotoCaptureEnabled = _photoOutput.livePhotoCaptureSupported;
    }
    return _photoOutput;
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    dispatch_async(self.sessionQueue, ^{
        if (self.camSetupResult == AVCameraSetupResultSuccess) {
            if (!self.session.isRunning) {
                [self.session startRunning];
            }
        } else {
            // config session failed
            dispatch_async(dispatch_get_main_queue(), ^{
                [self configSessionFailedHandle];
            });
        }
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    dispatch_async(self.sessionQueue, ^{
        if (self.session.isRunning) {
            [self.session stopRunning];
        }
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
        self.videoDeviceInout = videoInput;
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
        self.audioDeviceInout = audioInput;
        [self.session addInput:audioInput];
    } else {
        [self.session commitConfiguration];
        return;
    }
    
    if ([self.session canAddOutput:self.photoOutput]) {
        [self.session addOutput:self.photoOutput];
    }
    
    [self.session commitConfiguration];
}

- (void)configSessionFailedHandle {
    
    switch (self.camSetupResult) {
        case AVCameraSetupResultCameraNotAuthorized:
        {
            UIAlertController *alertContr = [UIAlertController alertControllerWithTitle:@"" message:@"没有相机使用权限" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:NULL];
            [alertContr addAction:cancel];

            UIAlertAction *setting = [UIAlertAction actionWithTitle:@"前往设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:url
                                                   options:@{}
                                         completionHandler:NULL];
            }];
            [alertContr addAction:setting];
            
            [self presentViewController:alertContr animated:YES completion:NULL];
            
            break;
        }
        case AVCameraSetupResultSessionConfigFailed:
        {
            UIAlertController *alertContr = [UIAlertController alertControllerWithTitle:@"" message:@"设置相机错误" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:NULL];
            [alertContr addAction:cancel];
            [self presentViewController:alertContr animated:YES completion:NULL];
            break;
        }
        default:
            break;
    }
}

- (void)setupPhotoSettings {
    AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettings];
    if (self.videoDeviceInout.device.flashAvailable) {
        // 设置闪光灯模式
        settings.flashMode = AVCaptureFlashModeAuto;
    }
    _photoCapDelegate = [[AVPhotoCaptureDelegate alloc] initWithRequestedPhotoSettings:settings];
    [self.photoOutput capturePhotoWithSettings:settings delegate:_photoCapDelegate];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    dispatch_async(self.sessionQueue, ^{
        [self setupPhotoSettings];
    });
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
