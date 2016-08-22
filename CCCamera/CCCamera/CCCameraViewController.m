//
//  CCCameraViewController.m
//  CCCamera
//
//  Created by wsk on 16/8/22.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "CCCameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreMedia/CMMetadata.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "CCVideoPreview.h"
#import "CCImagePreviewController.h"
#import "CCTools+GIF.h"

@interface CCCameraViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AVCaptureSession                    *_captureSession;
    AVCaptureDeviceInput                *_deviceInput;
    
    AVCaptureConnection                 *_videoConnection;
    AVCaptureStillImageOutput           *_imageOutput;
    
    NSURL								*_movieURL;
    AVAssetWriter						*_assetWriter;
    AVAssetWriterInput					*_assetWriterVideoIn;
    AVAssetWriterInput					*_assetWriterMetadataIn;
    AVAssetWriterInputMetadataAdaptor	*_assetWriterMetadataAdaptor;
    
    dispatch_queue_t					_movieWritingQueue;
    BOOL								_readyToRecordVideo;
    BOOL								_readyToRecordMetadata;
}

@property(nonatomic, strong) AVCaptureDevice *activeCamera;     // 当前输入设备
@property(nonatomic, strong) AVCaptureDevice *inactiveCamera;   // 不活跃的设备(这里指前摄像头或后摄像头，不包括外接输入设备)

@property (nonatomic) AVCaptureTorchMode torchMode;
@property (nonatomic) AVCaptureFlashMode flashMode;

// UI
@property(nonatomic, strong) CCVideoPreview *previewView;
@property(nonatomic, strong) UIView *bottomView;
@property(nonatomic, strong) UIView *topView;
@property(nonatomic, strong) UIView *focusView;
@property(nonatomic, strong) UIView *exposureView;

@property (readwrite) AVCaptureVideoOrientation videoOrientation;
@property (readwrite, getter=isRecording) BOOL	recording;
@property AVCaptureVideoOrientation				referenceOrientation;

@end

@implementation CCCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    
    _movieURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"movie.mov"]];
    
    NSError *error;
    if ([self setupSession:&error]) {
        [self.previewView setCaptureSessionsion:_captureSession];
        [self startCaptureSession];
    }
    else{
        NSLog(@"获取捕捉设备出错: %@", [error localizedDescription]);
    }
}

#pragma mark - AVCaptureSession life cycle
- (BOOL)setupSession:(NSError **)error{
    _captureSession = [[AVCaptureSession alloc]init];
    [_captureSession setSessionPreset:AVCaptureSessionPresetPhoto];
    
    // 输入设备
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:error];
    if (videoInput) {
        if ([_captureSession canAddInput:videoInput]){
            [_captureSession addInput:videoInput];
            _deviceInput = videoInput;
        }
    }
    else{
        return NO;
    }
    
    // 视频输出
    AVCaptureVideoDataOutput *videoOut = [[AVCaptureVideoDataOutput alloc] init];
    [videoOut setAlwaysDiscardsLateVideoFrames:YES];
    [videoOut setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]}];
    dispatch_queue_t videoCaptureQueue = dispatch_queue_create("Video Capture Queue", DISPATCH_QUEUE_SERIAL);
    [videoOut setSampleBufferDelegate:self queue:videoCaptureQueue];
    if ([_captureSession canAddOutput:videoOut]){
        [_captureSession addOutput:videoOut];
    }
    _videoConnection = [videoOut connectionWithMediaType:AVMediaTypeVideo];
    self.videoOrientation = _videoConnection.videoOrientation;
    
    // 静态图片输出
    AVCaptureStillImageOutput *imageOutput = [[AVCaptureStillImageOutput alloc] init];            
    imageOutput.outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    if ([_captureSession canAddOutput:imageOutput]) {
        [_captureSession addOutput:imageOutput];
        _imageOutput = imageOutput;
    }
    return YES;
}

// 开启视频捕捉
- (void)startCaptureSession
{
    if (!_movieWritingQueue) {
        _movieWritingQueue = dispatch_queue_create("Movie Writing Queue", DISPATCH_QUEUE_SERIAL);
    }
    
    if (!_captureSession.isRunning){
        [_captureSession startRunning];
    }
}

// 停止视频捕捉
- (void)stopCaptureSession
{
    if (_captureSession.isRunning){
        [_captureSession stopRunning];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - 录制视频
// 开始录制
- (void)startRecording
{
    [self startCaptureSession];
    self.recording = YES;
    
    dispatch_async(_movieWritingQueue, ^{
        [self removeFile:_movieURL];
        if (!_assetWriter) {
            NSError *error;
            _assetWriter = [[AVAssetWriter alloc] initWithURL:_movieURL fileType:AVFileTypeQuickTimeMovie error:&error];
            if (error){
                [self showError:error];
            }
        }
    });
}

// 停止录制
- (void)stopRecording
{
    // 录制完成后 要马上停止视频捕捉 否则写入相册会出错
    [self stopCaptureSession];
    self.recording = NO;
    
    dispatch_async(_movieWritingQueue, ^{
        [_assetWriter finishWritingWithCompletionHandler:^(){
            NSLog(@"停止录制视频");
            AVAssetWriterStatus completionStatus = _assetWriter.status;
            switch (completionStatus)
            {
                case AVAssetWriterStatusCompleted:
                {
                    _readyToRecordVideo = NO;
                    _readyToRecordMetadata = NO;
                    _assetWriter = nil;
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self.view showAlertView:self message:@"是否保存到相册" sure:^(UIAlertAction *act) {
                            [self saveMovieToCameraRoll];
                        } cancel:^(UIAlertAction *act) {
                            
                        }];
                    });
                    break;
                }
                case AVAssetWriterStatusFailed:
                {
                    [self showError:_assetWriter.error];
                    break;
                }
                default:
                    break;
            }
        }];
    });
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    if (self.recording) {
        CFRetain(sampleBuffer);
        dispatch_async(_movieWritingQueue, ^{
            if (_assetWriter)
            {
                if (connection == _videoConnection)
                {
                    if (!_readyToRecordMetadata){
                        _readyToRecordMetadata = [self setupAssetWriterMetadataInputAndMetadataAdaptor];
                    }
                    
                    if (!_readyToRecordVideo){
                        _readyToRecordVideo = [self setupAssetWriterVideoInput:CMSampleBufferGetFormatDescription(sampleBuffer)];
                    }
                    
                    if (_readyToRecordVideo && _readyToRecordMetadata){
                        [self writeSampleBuffer:sampleBuffer ofType:AVMediaTypeVideo];
                    }
                }
            }
            CFRelease(sampleBuffer);
        });
    }
}

- (void)writeSampleBuffer:(CMSampleBufferRef)sampleBuffer ofType:(NSString *)mediaType
{
    if (_assetWriter.status == AVAssetWriterStatusUnknown)
    {
        if ([_assetWriter startWriting]){
            [_assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
        }
        else{
            [self showError:_assetWriter.error];
        }
    }
    
    if (_assetWriter.status == AVAssetWriterStatusWriting)
    {
        if (mediaType == AVMediaTypeVideo)
        {
            if (_assetWriterVideoIn.readyForMoreMediaData)
            {
                if (![_assetWriterVideoIn appendSampleBuffer:sampleBuffer]){
                    [self showError:_assetWriter.error];
                }
            }
        }
    }
}

- (void)showError:(NSError *)error
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:error.localizedDescription
                                                            message:error.localizedFailureReason
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    });
}

// 设置Asset输入
- (BOOL)setupAssetWriterVideoInput:(CMFormatDescriptionRef)currentFormatDescription
{
    CGFloat bitsPerPixel;
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(currentFormatDescription);
    NSUInteger numPixels = dimensions.width * dimensions.height;
    NSUInteger bitsPerSecond;
    
    if (numPixels < (640 * 480)){
        bitsPerPixel = 4.05;
    }
    else{
        bitsPerPixel = 11.4;
    }
    
    bitsPerSecond = numPixels * bitsPerPixel;
    NSDictionary *videoCompressionSettings = @{AVVideoCodecKey  : AVVideoCodecH264,
                                               AVVideoWidthKey  : [NSNumber numberWithInteger:dimensions.width],
                                               AVVideoHeightKey : [NSNumber numberWithInteger:dimensions.height],
                                               AVVideoCompressionPropertiesKey : @{ AVVideoAverageBitRateKey : [NSNumber numberWithInteger:bitsPerSecond],
                                                                                    AVVideoMaxKeyFrameIntervalKey :[NSNumber numberWithInteger:30]}};
    if ([_assetWriter canApplyOutputSettings:videoCompressionSettings forMediaType:AVMediaTypeVideo])
    {
        _assetWriterVideoIn = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoCompressionSettings];
        _assetWriterVideoIn.expectsMediaDataInRealTime = YES;
        _assetWriterVideoIn.transform = [self transformFromCurrentVideoOrientationToOrientation:self.referenceOrientation];
        if ([_assetWriter canAddInput:_assetWriterVideoIn]){
            [_assetWriter addInput:_assetWriterVideoIn];
        }
        else{
            NSLog(@"Couldn't add asset writer video input.");
            return NO;
        }
    }
    else{
        NSLog(@"Couldn't apply video output settings.");
        return NO;
    }
    return YES;
}

- (BOOL)setupAssetWriterMetadataInputAndMetadataAdaptor
{
    CMFormatDescriptionRef metadataFormatDescription = NULL;
    NSArray *specifications = @[@{(__bridge NSString *)kCMMetadataFormatDescriptionMetadataSpecificationKey_Identifier : (__bridge NSString *)kCMMetadataIdentifier_QuickTimeMetadataLocation_ISO6709,
                                  (__bridge NSString *)kCMMetadataFormatDescriptionMetadataSpecificationKey_DataType : (__bridge NSString *)kCMMetadataDataType_QuickTimeMetadataLocation_ISO6709}];
    OSStatus err = CMMetadataFormatDescriptionCreateWithMetadataSpecifications(kCFAllocatorDefault, kCMMetadataFormatType_Boxed, (__bridge CFArrayRef)specifications, &metadataFormatDescription);
    if (!err){
        _assetWriterMetadataIn = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeMetadata outputSettings:nil sourceFormatHint:metadataFormatDescription];
        _assetWriterMetadataAdaptor = [AVAssetWriterInputMetadataAdaptor assetWriterInputMetadataAdaptorWithAssetWriterInput:_assetWriterMetadataIn];
        _assetWriterMetadataIn.expectsMediaDataInRealTime = YES;
        
        if ([_assetWriter canAddInput:_assetWriterMetadataIn]){
            [_assetWriter addInput:_assetWriterMetadataIn];
        }
        else{
            NSLog(@"Couldn't add asset writer metadata input.");
            return NO;
        }
    }
    else{
        NSLog(@"Failed to create format description with metadata specification: %@", specifications);
        return NO;
    }
    return YES;
}

- (CGFloat)angleOffsetFromPortraitOrientationToOrientation:(AVCaptureVideoOrientation)orientation
{
    CGFloat angle = 0.0;
    switch (orientation)
    {
        case AVCaptureVideoOrientationPortrait:
            angle = 0.0;
            break;
        case AVCaptureVideoOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case AVCaptureVideoOrientationLandscapeRight:
            angle = - M_PI_2;
            break;
        case AVCaptureVideoOrientationLandscapeLeft:
            angle = M_PI_2;
            break;
        default:
            break;
    }
    return angle;
}

- (CGAffineTransform)transformFromCurrentVideoOrientationToOrientation:(AVCaptureVideoOrientation)orientation
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGFloat orientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:orientation];
    CGFloat videoOrientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:self.videoOrientation];
    CGFloat angleOffset = orientationAngleOffset - videoOrientationAngleOffset;
    transform = CGAffineTransformMakeRotation(angleOffset);
    return transform;
}

- (void)saveMovieToCameraRoll
{
    ALAssetsLibrary *lab = [[ALAssetsLibrary alloc]init];
    [lab writeVideoAtPathToSavedPhotosAlbum:_movieURL completionBlock:^(NSURL *assetURL, NSError *error) {
        if (!error) {
            NSLog(@"视频:%@",assetURL.path);
        }
    }];
    //    [Video createGIFfromURL:_movieURL loopCount:0 completion:^(NSURL *GifURL) {
    //        
    //    }];
}

- (void)removeFile:(NSURL *)fileURL
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = fileURL.path;
    if ([fileManager fileExistsAtPath:filePath])
    {
        NSError *error;
        BOOL success = [fileManager removeItemAtPath:filePath error:&error];
        if (!success){
            [self showError:error];
        }
        else{
            NSLog(@"删除视频文件成功");
        }
    }
}

#pragma mark - 设备配置
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position { 
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {                              
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

- (AVCaptureDevice *)activeCamera {                                         
    return _deviceInput.device;
}

- (AVCaptureDevice *)inactiveCamera {                                       
    AVCaptureDevice *device = nil;
    if ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 1) {
        if ([self activeCamera].position == AVCaptureDevicePositionBack) {  
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        } 
        else{
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    return device;
}

#pragma mark - 转换前后摄像头
// 点击事件
- (void)switchCameraButtonClick:(UIButton *)btn{
    if ([self switchCameras]) {
        btn.selected = !btn.selected;
    }
    else{
        [self.view showAutoDismissAlert:self message:@"转换摄像头失败"];
    }
}

- (BOOL)canSwitchCameras {                                                  
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 1;
}

- (BOOL)switchCameras{
    if (![self canSwitchCameras]) {                                         
        return NO;
    }
    NSError *error;
    AVCaptureDevice *videoDevice = [self inactiveCamera];                   
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if (videoInput) {
        [_captureSession beginConfiguration];                           
        [_captureSession removeInput:_deviceInput];            
        if ([_captureSession canAddInput:videoInput]) {                 
            [_captureSession addInput:videoInput];
            _deviceInput = videoInput;
        } 
        else{
            [_captureSession addInput:_deviceInput];
        }
        [_captureSession commitConfiguration];                          
    } 
    else{
        NSLog(@"摄像头转换失败:%@",error.localizedDescription);          
        return NO;
    }
    return YES;
}

#pragma mark - 聚焦
-(void)tapAction:(UIGestureRecognizer *)tap{
    if ([self cameraSupportsTapToFocus]) {
        CGPoint point = [tap locationInView:self.previewView];
        [self runFocusAnimation:self.focusView point:point];
        
        CGPoint focusPoint = [self captureDevicePointForPoint:point];
        [self focusAtPoint:focusPoint];
    }
}

- (BOOL)cameraSupportsTapToFocus {                                          
    return [[self activeCamera] isFocusPointOfInterestSupported];
}

- (void)focusAtPoint:(CGPoint)point {                                       
    AVCaptureDevice *device = [self activeCamera];
    if ([self cameraSupportsTapToFocus] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {                         
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        } 
        else{
            NSLog(@"聚焦失败:%@",error.localizedDescription);
        }
    }
}

#pragma mark - 曝光
-(void)doubleTapAction:(UIGestureRecognizer *)tap{
    if ([self cameraSupportsTapToExpose]) {
        CGPoint point = [tap locationInView:self.previewView];
        [self runFocusAnimation:self.exposureView point:point];
        
        CGPoint exposePoint = [self captureDevicePointForPoint:point];
        [self exposeAtPoint:exposePoint];
    }
}

- (BOOL)cameraSupportsTapToExpose {                                         
    return [[self activeCamera] isExposurePointOfInterestSupported];
}

static const NSString *CameraAdjustingExposureContext;
- (void)exposeAtPoint:(CGPoint)point{
    AVCaptureDevice *device = [self activeCamera];
    if ([self cameraSupportsTapToExpose] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {                         
            device.exposurePointOfInterest = point;
            device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            if ([device isExposureModeSupported:AVCaptureExposureModeLocked]) {
                [device addObserver:self                                    
                         forKeyPath:@"adjustingExposure"
                            options:NSKeyValueObservingOptionNew
                            context:&CameraAdjustingExposureContext];
            }
            [device unlockForConfiguration];
        } 
        else{
            NSLog(@"设置曝光——该摄像头不支持AVCaptureExposureModeContinuousAutoExposure曝光模式");
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &CameraAdjustingExposureContext) {                     
        AVCaptureDevice *device = (AVCaptureDevice *)object;
        if (!device.isAdjustingExposure && [device isExposureModeSupported:AVCaptureExposureModeLocked]) {
            [object removeObserver:self                                     
                        forKeyPath:@"adjustingExposure"
                           context:&CameraAdjustingExposureContext];
            dispatch_async(dispatch_get_main_queue(), ^{                    
                NSError *error;
                if ([device lockForConfiguration:&error]) {
                    device.exposureMode = AVCaptureExposureModeLocked;
                    [device unlockForConfiguration];
                } 
                else{
                    NSLog(@"设置曝光——修改设备配置失败:%@",error.localizedDescription);
                }
            });
        }
    } 
    else{
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

#pragma mark - 自动聚焦、曝光
// 点击事件
-(void)focusAndExposureButtonClick:(UIButton *)btn{
    if ([self resetFocusAndExposureModes]) {
        [self.view showAutoDismissAlert:self message:@"自动聚焦、曝光设置成功!"];
        [self runResetAnimation];
    }
    else{
        [self.view showAutoDismissAlert:self message:@"自动聚焦、曝光设置失败"];
    }
}

- (BOOL)resetFocusAndExposureModes{
    AVCaptureDevice *device = [self activeCamera];
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    AVCaptureFocusMode focusMode = AVCaptureFocusModeContinuousAutoFocus;
    BOOL canResetFocus = [device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode];
    BOOL canResetExposure = [device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode];
    CGPoint centerPoint = CGPointMake(0.5f, 0.5f);                          
    NSError *error;
    if ([device lockForConfiguration:&error]) {
        if (canResetFocus) {                                                
            device.focusMode = focusMode;
            device.focusPointOfInterest = centerPoint;
        }
        if (canResetExposure) {                                             
            device.exposureMode = exposureMode;
            device.exposurePointOfInterest = centerPoint;
        }
        [device unlockForConfiguration];
        return YES;
    } 
    else{
        NSLog(@"设置自动曝光——修改设备配置失败:%@",error.localizedDescription);
        return NO;
    }
}

#pragma mark - 闪光灯
// 点击事件
-(void)flashClick:(UIButton *)btn{
    if ([self cameraHasFlash]) {
        btn.selected = !btn.selected;
        if ([self flashMode] == AVCaptureFlashModeOff) {
            self.flashMode = AVCaptureFlashModeOn;
        }
        else if ([self flashMode] == AVCaptureFlashModeOn) {
            self.flashMode = AVCaptureFlashModeOff;
        }
    } 
    else{
        [self.view showAutoDismissAlert:self message:@"你的设备不支持闪光灯"];
    }
}

- (BOOL)cameraHasFlash {
    return [[self activeCamera] hasFlash];
}

- (AVCaptureFlashMode)flashMode{
    return [[self activeCamera] flashMode];
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode{
    AVCaptureDevice *device = [self activeCamera];
    if (device.flashMode != flashMode && [device isFlashModeSupported:flashMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.flashMode = flashMode;
            [device unlockForConfiguration];
        } 
        else{
            [self.view showAutoDismissAlert:self message:[NSString stringWithFormat:@"设置闪光灯失败:%@",error.localizedDescription]];
        }
    }
}

#pragma mark - 手电筒
// 点击事件
- (void)torchClick:(UIButton *)btn{
    if ([self cameraHasTorch]) {
        btn.selected = !btn.selected;
        if ([self torchMode] == AVCaptureTorchModeOff) {
            self.torchMode = AVCaptureTorchModeOn;
        }
        else if ([self torchMode] == AVCaptureTorchModeOn) {
            self.torchMode = AVCaptureTorchModeOff;
        }
    }
    else{
        [self.view showAutoDismissAlert:self message:@"你的设备不支持补光"];
    }
}

- (BOOL)cameraHasTorch {
    return [[self activeCamera] hasTorch];
}

- (AVCaptureTorchMode)torchMode {
    return [[self activeCamera] torchMode];
}

- (void)setTorchMode:(AVCaptureTorchMode)torchMode{
    AVCaptureDevice *device = [self activeCamera];
    if (device.torchMode != torchMode && [device isTorchModeSupported:torchMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.torchMode = torchMode;
            [device unlockForConfiguration];
        } 
        else{
            [self.view showAutoDismissAlert:self message:[NSString stringWithFormat:@"设置手电筒失败:%@",error.localizedDescription]];
        }
    }
}

#pragma mark - 取消拍照
// 点击事件
- (void)cancel:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:YES];
}

// 改变拍照类型
- (void)changePhotoType:(UIButton *)btn{
    
}

// 点击事件
- (void)takePicture:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (btn.selected) {
        [self startRecording];
    }
    else{
        [self stopRecording];
    }
}

-(void)takePictureImage{
    AVCaptureConnection *connection = [_imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (connection.isVideoOrientationSupported) {
        connection.videoOrientation = [self currentVideoOrientation];
    }
    id takePictureSuccess = ^(CMSampleBufferRef sampleBuffer,NSError *error){
        if (sampleBuffer == NULL) {
            NSLog(@"拍照失败:%@",[error localizedDescription]);
            return ;
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
        UIImage *image = [[UIImage alloc]initWithData:imageData];
        CCImagePreviewController *vc = [[CCImagePreviewController alloc]initWithImage:image previewFrame:self.previewView.frame];
        [self.navigationController pushViewController:vc animated:YES];
    };
    [_imageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:takePictureSuccess];
}

// 调整设备取向
- (AVCaptureVideoOrientation)currentVideoOrientation{
    AVCaptureVideoOrientation orientation;
    switch ([UIDevice currentDevice].orientation) {                         
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
    }
    return orientation;
}

// 聚焦、曝光动画
-(void)runFocusAnimation:(UIView *)view point:(CGPoint)point{
    view.center = point;
    view.hidden = NO;
    [UIView animateWithDuration:0.15f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        view.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
    }completion:^(BOOL complete) {
        double delayInSeconds = 0.5f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            view.hidden = YES;
            view.transform = CGAffineTransformIdentity;
        });
    }];
}

// 自动聚焦、曝光动画
- (void)runResetAnimation {
    self.focusView.center = CGPointMake(self.previewView.width/2, self.previewView.height/2);
    self.exposureView.center = CGPointMake(self.previewView.width/2, self.previewView.height/2);;
    self.exposureView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    self.focusView.hidden = NO;
    self.focusView.hidden = NO;
    [UIView animateWithDuration:0.15f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.focusView.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
        self.exposureView.layer.transform = CATransform3DMakeScale(0.7, 0.7, 1.0);
    }completion:^(BOOL complete) {
        double delayInSeconds = 0.5f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.focusView.hidden = YES;
            self.exposureView.hidden = YES;
            self.focusView.transform = CGAffineTransformIdentity;
            self.exposureView.transform = CGAffineTransformIdentity;
        });
    }];
}

// 将屏幕坐标系的点转换为摄像头坐标系的点
- (CGPoint)captureDevicePointForPoint:(CGPoint)point {                      
    AVCaptureVideoPreviewLayer *layer = (AVCaptureVideoPreviewLayer *)self.previewView.layer;
    return [layer captureDevicePointOfInterestForPoint:point];
}

#pragma mark - UI
- (void)setupUI{
    self.previewView = [[CCVideoPreview alloc]initWithFrame:CGRectMake(0, 200, CD_SCREEN_WIDTH, 320)];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapAction:)];
    doubleTap.numberOfTapsRequired = 2;
    
    [self.previewView addGestureRecognizer:tap];
    [self.previewView addGestureRecognizer:doubleTap];
    [tap requireGestureRecognizerToFail:doubleTap];
    
    [self.view addSubview:self.previewView];
    [self.view addSubview:self.topView];
    [self.view addSubview:self.bottomView];
    [self.previewView addSubview:self.focusView];
    [self.previewView addSubview:self.exposureView];
    
    // 拍照
    UIButton *photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [photoButton setTitle:@"拍照" forState:UIControlStateNormal];
    [photoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [photoButton addTarget:self action:@selector(takePicture:) forControlEvents:UIControlEventTouchUpInside];
    [photoButton sizeToFit];
    photoButton.center = CGPointMake(_bottomView.centerX-20, _bottomView.height/2);
    [self.bottomView addSubview:photoButton];
    
    // 取消
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton sizeToFit];
    cancelButton.center = CGPointMake(40, _bottomView.height/2);
    [self.bottomView addSubview:cancelButton];
    
    // 照片类型
    UIButton *typeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [typeButton setTitle:@"拍摄照片类型" forState:UIControlStateNormal];
    [typeButton setTitle:@"拍摄GIF动图" forState:UIControlStateSelected];
    [typeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [typeButton addTarget:self action:@selector(changePhotoType:) forControlEvents:UIControlEventTouchUpInside];
    [typeButton sizeToFit];
    typeButton.center = CGPointMake(_bottomView.width-60, _bottomView.height/2);
    [self.bottomView addSubview:typeButton];
    
    // 转换前后摄像头
    UIButton *switchCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [switchCameraButton setTitle:@"转换摄像头" forState:UIControlStateNormal];
    [switchCameraButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [switchCameraButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [switchCameraButton addTarget:self action:@selector(switchCameraButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [switchCameraButton sizeToFit];
    switchCameraButton.center = CGPointMake(switchCameraButton.width/2+10, _topView.height/2);
    [self.topView addSubview:switchCameraButton];
    
    // 补光
    UIButton *lightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [lightButton setTitle:@"补光" forState:UIControlStateNormal];
    [lightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [lightButton setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [lightButton addTarget:self action:@selector(torchClick:) forControlEvents:UIControlEventTouchUpInside];
    [lightButton sizeToFit];
    lightButton.center = CGPointMake(lightButton.width/2 + switchCameraButton.right+10, _topView.height/2);
    [self.topView addSubview:lightButton];
    
    // 闪光灯
    UIButton *flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [flashButton setTitle:@"闪光灯" forState:UIControlStateNormal];
    [flashButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [flashButton setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [flashButton addTarget:self action:@selector(flashClick:) forControlEvents:UIControlEventTouchUpInside];
    [flashButton sizeToFit];
    flashButton.center = CGPointMake(flashButton.width/2 + lightButton.right+10, _topView.height/2);
    [self.topView addSubview:flashButton];
    
    // 重置对焦、曝光
    UIButton *focusAndExposureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [focusAndExposureButton setTitle:@"自动聚焦/曝光" forState:UIControlStateNormal];
    [focusAndExposureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [focusAndExposureButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [focusAndExposureButton addTarget:self action:@selector(focusAndExposureButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [focusAndExposureButton sizeToFit];
    focusAndExposureButton.center = CGPointMake(focusAndExposureButton.width/2 + flashButton.right+10, _topView.height/2);
    [self.topView addSubview:focusAndExposureButton];
}       

-(UIView *)topView{
    if (_topView == nil) {
        _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CD_SCREEN_WIDTH, 64)];
        _topView.backgroundColor = [UIColor blackColor];
    }
    return _topView;
}

-(UIView *)bottomView{
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, CD_SCREEN_HEIGHT - 100, CD_SCREEN_WIDTH, 100)];
        _bottomView.backgroundColor = [UIColor blackColor];
    }
    return _bottomView;
}

-(UIView *)focusView{
    if (_focusView == nil) {
        _focusView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 150, 150.0f)];
        _focusView.backgroundColor = [UIColor clearColor];
        _focusView.layer.borderColor = [UIColor blueColor].CGColor;
        _focusView.layer.borderWidth = 5.0f;
        _focusView.hidden = YES;
    }
    return _focusView;
}

-(UIView *)exposureView{
    if (_exposureView == nil) {
        _exposureView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 150, 150.0f)];
        _exposureView.backgroundColor = [UIColor clearColor];
        _exposureView.layer.borderColor = [UIColor purpleColor].CGColor;
        _exposureView.layer.borderWidth = 5.0f;
        _exposureView.hidden = YES;
    }
    return _exposureView;
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
