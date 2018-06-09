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
@property (nonatomic, strong) AVCaptureDeviceDiscoverySession *discoverySession;


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
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setupUI];
        });
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
            [self removeObserver];
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
    [self configVideoDevice:videoDevice];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:NULL];
    if (videoInput && [self.session canAddInput:videoInput]) {
        self.videoDeviceInout = videoInput;
        [self.session addInput:videoInput];
    } else {
        self.camSetupResult = AVCameraSetupResultSessionConfigFailed;
        [self.session commitConfiguration];
        return;
    }
    NSArray<AVCaptureDeviceType> *types = @[AVCaptureDeviceTypeBuiltInWideAngleCamera];
    _discoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:types mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified];
    
    // add audio input
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:NULL];
    if (audioInput && [self.session canAddInput:audioInput]) {
        self.audioDeviceInout = audioInput;
        [self.session addInput:audioInput];
    } else {
        self.camSetupResult = AVCameraSetupResultSessionConfigFailed;
        [self.session commitConfiguration];
        return;
    }
    
    if ([self.session canAddOutput:self.photoOutput]) {
        [self.session addOutput:self.photoOutput];
    } else {
        self.camSetupResult = AVCameraSetupResultSessionConfigFailed;
        [self.session commitConfiguration];
        return;
    }
    
    [self.session commitConfiguration];
    
    [self addObserver];
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
    if (self.videoDeviceInout.device.position == AVCaptureDevicePositionBack &&
        self.videoDeviceInout.device.flashAvailable) {
        // 设置闪光灯模式
        settings.flashMode = AVCaptureFlashModeAuto;
    }
    _photoCapDelegate = [[AVPhotoCaptureDelegate alloc] initWithRequestedPhotoSettings:settings];
    [self.photoOutput capturePhotoWithSettings:settings delegate:_photoCapDelegate];
}


- (void)setupUI
{
    if (self.camSetupResult != AVCameraSetupResultSuccess) return;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [button setTitle:@"switch" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    button.backgroundColor = [UIColor colorWithRed:68/255.0 green:168/255.0 blue:242/255.0 alpha:1.0];
    [self.view addSubview:button];
    button.center = CGPointMake(50, 150);
    [button addTarget:self
               action:@selector(switchCamera:)
     forControlEvents:UIControlEventTouchUpInside];
}

- (void)switchCamera:(UIButton *)button {
    dispatch_async(self.sessionQueue, ^{
        AVCaptureDevicePosition position = self.videoDeviceInout.device.position;
        AVCaptureDevice *targetDevice = nil;
        if (position == AVCaptureDevicePositionBack) { // // 后置 --> 前置
            for (AVCaptureDevice *device in self.discoverySession.devices) {
                if (device.position == AVCaptureDevicePositionFront) {
                    targetDevice = device;
                    break;
                }
            }
        } else { // 前置 --> 后置
            for (AVCaptureDevice *device in self.discoverySession.devices) {
                if (device.position == AVCaptureDevicePositionBack) {
                    targetDevice = device;
                    break;
                }
            }
        }
        
        if (targetDevice) {
            [self configVideoDevice:targetDevice];

            NSError *error = nil;
            AVCaptureDeviceInput *videoDeviceInout = [AVCaptureDeviceInput deviceInputWithDevice:targetDevice error:&error];
            if (error) {
                NSLog(@"AVCaptureDeviceInput error = %@", error);
                return;
            }
            
            [self.session beginConfiguration];
            [self.session removeInput:self.videoDeviceInout];
            self.videoDeviceInout = nil;
            if ([self.session canAddInput:videoDeviceInout]) {
                [self.session addInput:videoDeviceInout];
                self.videoDeviceInout = videoDeviceInout;
            }
            [self.session commitConfiguration];
        }
    });
}


- (void)configVideoDevice:(AVCaptureDevice *)device {
    if ([device lockForConfiguration:NULL] == NO) return;
    /*
     1. 对焦模式
     AVCaptureFocusModeLocked   // 锁定当前的焦距
     AVCaptureFocusModeAutoFocus   // 只自动对焦一次，对焦一次后，切换到AVCaptureFocusModeLocked模式
     AVCaptureFocusModeContinuousAutoFocus // 在需要的时候就会自动对焦
     */
    if ([device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        device.focusMode = AVCaptureFocusModeAutoFocus;
    }
    
#if 0
    // 可以对焦指定位置，例如拍照时，点击屏幕某个点，就对焦到对应位置。
    if ([device isFocusPointOfInterestSupported]) {
        device.focusPointOfInterest = CGPointMake(0.5, 0.5);
    }
#endif
    
    /*
     设置曝光模式
     AVCaptureExposureModeLocked    // 锁定当前曝光值
     AVCaptureExposureModeAutoExpose // 自动调整一次曝光值，然后切换到AVCaptureExposureModeLocked模式，锁定当前曝光值
     AVCaptureExposureModeContinuousAutoExposure // 在需要调整曝光值得时候会自动调整
     AVCaptureExposureModeCustom // 自定义曝光值
     */
    if ([device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
        device.exposureMode = AVCaptureExposureModeAutoExpose;
    }
    
#if 0
    // 如果exposureMode == AVCaptureExposureModeCustom, 还可以自定义曝光参数，
    [device setExposureTargetBias:AVCaptureExposureTargetBiasCurrent
                completionHandler:^(CMTime syncTime) {
    }];
#endif
    
    /*
     设置白平衡模式
     AVCaptureWhiteBalanceModeLocked
     AVCaptureWhiteBalanceModeAutoWhiteBalance
     AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance
     */
    if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
        device.whiteBalanceMode = AVCaptureWhiteBalanceModeLocked;
    }
#if 0
    // 还可以自定义白平衡值
    AVCaptureWhiteBalanceGains gains;
    gains.redGain = 0.0;
    gains.greenGain = 0.0;
    gains.blueGain = 0.0;
    [device setWhiteBalanceModeLockedWithDeviceWhiteBalanceGains:gains
                                               completionHandler:^(CMTime syncTime) {
                                               }];
#endif
    /*
     在拍视频时闪光灯的模式
     AVCaptureTorchModeOff  = 0,
     AVCaptureTorchModeOn   = 1,
     AVCaptureTorchModeAuto = 2,
     */
    if ([device isTorchModeSupported:AVCaptureTorchModeOff]) {
        device.torchMode = AVCaptureTorchModeOff;
    }
#if 0
    // 还可以设置闪光灯的亮度
    device.torchLevel = 0.2;
#endif
    
    /*
     拍照时的闪光灯模式设置
     */
#if 0
    device.flashMode
    AVCapturePhotoSettings.flashMode
#endif
    
    [device unlockForConfiguration];
}

#pragma mark - observer

/*
 AVCaptureSessionRuntimeErrorNotification // 拍摄过程中出现错误通知
 AVCaptureSessionDidStartRunningNotification    // 开始运行通知
 AVCaptureSessionDidStopRunningNotification     // 停止运行通知
 AVCaptureSessionWasInterruptedNotification     // 被打断通知
 AVCaptureSessionInterruptionEndedNotification
 */

- (void)addObserver {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(sessionRuntimeError:)
                   name:AVCaptureSessionRuntimeErrorNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(sessionDidStartRunning:)
                   name:AVCaptureSessionDidStartRunningNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(sessionDidStopRunning:)
                   name:AVCaptureSessionDidStopRunningNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(sessionWasInterrupted:)
                   name:AVCaptureSessionWasInterruptedNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(sessionWasInterrupted:)
                   name:AVCaptureSessionInterruptionEndedNotification
                 object:nil];
}


- (void)removeObserver {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:AVCaptureSessionRuntimeErrorNotification object:nil];
    [center removeObserver:self name:AVCaptureSessionDidStartRunningNotification object:nil];
    [center removeObserver:self name:AVCaptureSessionDidStopRunningNotification object:nil];
    [center removeObserver:self name:AVCaptureSessionWasInterruptedNotification object:nil];
    [center removeObserver:self name:AVCaptureSessionInterruptionEndedNotification object:nil];
}

#pragma mark - notification handle

- (void)sessionRuntimeError:(NSNotification *)notification {
    NSError *error = notification.userInfo[AVCaptureSessionErrorKey];
    NSLog(@"%s, error = %@", __FUNCTION__, error);
}

- (void)sessionDidStartRunning:(NSNotification *)notification {
    NSLog(@"%s", __FUNCTION__);
}

- (void)sessionDidStopRunning:(NSNotification *)notification {
    NSLog(@"%s", __FUNCTION__);
}

- (void)sessionWasInterrupted:(NSNotification *)notification {
    NSLog(@"%s", __FUNCTION__);
    NSNumber *reason = notification.userInfo[AVCaptureSessionInterruptionReasonKey];
    if (reason) {
        NSLog(@"InterruptionReason = %@", reason);
    }
}

- (void)sessionInterruptionEnded:(NSNotification *)notification {
    NSLog(@"%s", __FUNCTION__);
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
