
//
//  OpenCameraViewController.m
//  CSchool
//
//  Created by mac on 17/3/6.
//  Copyright © 2017年 Joker. All rights reserved.
//

#import "OpenCameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIView+SDAutoLayout.h"

@interface OpenCameraViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate>
//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property(nonatomic)AVCaptureDevice *device;

//AVCaptureDeviceInput 代表输入设备，他使用AVCaptureDevice 来初始化
@property(nonatomic)AVCaptureDeviceInput *input;

//当启动摄像头开始捕获输入
@property(nonatomic)AVCaptureMetadataOutput *output;

@property (nonatomic)AVCaptureStillImageOutput *ImageOutPut;

//session：由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property(nonatomic)AVCaptureSession *session;

//图像预览层，实时显示捕获的图像
@property(nonatomic)AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic)UIButton *PhotoButton;
@property (nonatomic)UIButton *flashButton;
@property (nonatomic)UIImageView *imageView;
@property (nonatomic,strong)NSData *imageData;
@property (nonatomic)UIView *focusView;
@property (nonatomic)BOOL isflashOn;
@property (nonatomic)UIImage *image;


@property (nonatomic,strong) UIButton *closeCameraBtn;
@property (nonatomic,strong)UIButton *changeCameraBtn;
@property (nonatomic,strong)UIButton *takePhoto;//重拍
@property (nonatomic)BOOL canCa;

@property (nonatomic,assign)int  clickNum;//点击次数

@end

@implementation OpenCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _clickNum = 0;
    _canCa = [self canUserCamear];
    if (_canCa) {
        [self customCamera];
        [self customUI];
        
    }else{
        return;
    }

}
- (void)customUI{
    _focusView =[[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
    _focusView.layer.borderWidth = 1.0;
    _focusView.layer.borderColor =[UIColor greenColor].CGColor;
    _focusView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_focusView];
    _focusView.hidden = YES;
    
    
    _PhotoButton =({
        UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
        view.frame = CGRectMake(kScreenWidth*1/2.0-30, kScreenHeight-100, 76, 76);
        [view setImage:[UIImage imageNamed:@"photograph"] forState: UIControlStateNormal];
        [view setImage:[UIImage imageNamed:@"photograph_Select"] forState:UIControlStateSelected];
        [view addTarget:self action:@selector(shutterCamera:) forControlEvents:UIControlEventTouchDown];
        view;
    });
    
    _closeCameraBtn=({
       UIButton *view= [UIButton buttonWithType:UIButtonTypeCustom];
        view.frame = CGRectMake(32, 32, 45, 45);
        [view setImage:[UIImage imageNamed:@"closeCamera"] forState:UIControlStateNormal];
        view.titleLabel.textAlignment = NSTextAlignmentCenter;
        [view addTarget:self action:@selector(cancle) forControlEvents:UIControlEventTouchUpInside];//cancle
        view;
    });
    
    
    _changeCameraBtn  =({
       UIButton *view=[UIButton buttonWithType:UIButtonTypeCustom];
        view.frame = CGRectMake(kScreenWidth-72, 32, 45, 45);
        [view setImage:[UIImage imageNamed:@"changeCamera"] forState:UIControlStateNormal];
        view.titleLabel.textAlignment = NSTextAlignmentCenter;
        [view addTarget:self action:@selector(changeCamera) forControlEvents:UIControlEventTouchUpInside];
        view;
    });
    //重拍
    _takePhoto =({
        UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
        view.hidden = YES;
        [view setImage:[UIImage imageNamed:@"TakeImageAG"] forState:UIControlStateNormal];
        view.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [view setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [view addTarget:self action:@selector(tabkePhotoAgain) forControlEvents:UIControlEventTouchUpInside];
        view;
    });
    [self.view sd_addSubviews:@[_PhotoButton,_closeCameraBtn,_changeCameraBtn,_takePhoto]];
    _closeCameraBtn.sd_layout.leftSpaceToView(self.view,16).topSpaceToView(self.view,16).widthIs(45).heightIs(45);
    _changeCameraBtn.sd_layout.rightSpaceToView(self.view,16).topSpaceToView(self.view,16).widthIs(45).heightIs(45);
    _PhotoButton.sd_layout.centerXIs(self.view.centerX).bottomSpaceToView(self.view,42).widthIs(76).heightIs(76);
    _takePhoto.sd_layout.leftSpaceToView(self.view,53).bottomSpaceToView(self.view,42).widthIs(76).heightIs(76);
    
//    _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_flashButton setTitle:@"闪光灯关" forState:UIControlStateNormal];
//    [_flashButton addTarget:self action:@selector(FlashOn) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_flashButton];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusGesture:)];
    [self.view addGestureRecognizer:tapGesture];
}
- (void)customCamera{
    self.view.backgroundColor = [UIColor whiteColor];
    
    //使用AVMediaTypeVideo 指明self.device代表视频，默认使用后置摄像头进行初始化
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //使用设备初始化输入
    self.input = [[AVCaptureDeviceInput alloc]initWithDevice:self.device error:nil];
    
    //生成输出对象
    self.output = [[AVCaptureMetadataOutput alloc]init];
    self.ImageOutPut = [[AVCaptureStillImageOutput alloc] init];
    
    //生成会话，用来结合输入输出
    self.session = [[AVCaptureSession alloc]init];
    if ([self.session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        
        self.session.sessionPreset = AVCaptureSessionPreset1280x720;
        
    }
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    
    if ([self.session canAddOutput:self.ImageOutPut]) {
        [self.session addOutput:self.ImageOutPut];
    }
    
    //使用self.session，初始化预览层，self.session负责驱动input进行信息的采集，layer负责把图像渲染显示
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    self.previewLayer.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.previewLayer];
    
    //开始启动
    [self.session startRunning];
    if ([_device lockForConfiguration:nil]) {
        if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [_device setFlashMode:AVCaptureFlashModeAuto];
        }
        //自动白平衡
        if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        [_device unlockForConfiguration];
    }
}
- (void)FlashOn{
    if ([_device lockForConfiguration:nil]) {
        if (_isflashOn) {
            if ([_device isFlashModeSupported:AVCaptureFlashModeOff]) {
                [_device setFlashMode:AVCaptureFlashModeOff];
                _isflashOn = NO;
                [_flashButton setTitle:@"闪光灯关" forState:UIControlStateNormal];
            }
        }else{
            if ([_device isFlashModeSupported:AVCaptureFlashModeOn]) {
                [_device setFlashMode:AVCaptureFlashModeOn];
                _isflashOn = YES;
                [_flashButton setTitle:@"闪光灯开" forState:UIControlStateNormal];
            }
        }
        
        [_device unlockForConfiguration];
    }
}
#pragma mark 切换前后摄像头
- (void)changeCamera{
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        NSError *error;
        
        CATransition *animation = [CATransition animation];
        
        animation.duration = .5f;
        
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        animation.type = @"oglFlip";
        AVCaptureDevice *newCamera = nil;
        AVCaptureDeviceInput *newInput = nil;
        AVCaptureDevicePosition position = [[_input device] position];
        if (position == AVCaptureDevicePositionFront){
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            animation.subtype = kCATransitionFromLeft;
        }
        else {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            animation.subtype = kCATransitionFromRight;
        }
        
        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
        [self.previewLayer addAnimation:animation forKey:nil];
        if (newInput != nil) {
            [self.session beginConfiguration];
            [self.session removeInput:_input];
            if ([self.session canAddInput:newInput]) {
                [self.session addInput:newInput];
                self.input = newInput;
                
            } else {
                [self.session addInput:self.input];
            }
            
            [self.session commitConfiguration];
            
        } else if (error) {
            NSLog(@"toggle carema failed, error = %@", error);
        }
        
    }
}
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position ) return device;
    return nil;
}
- (void)focusGesture:(UITapGestureRecognizer*)gesture{
    CGPoint point = [gesture locationInView:gesture.view];
    [self focusAtPoint:point];
}
- (void)focusAtPoint:(CGPoint)point{
    CGSize size = self.view.bounds.size;
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
    NSError *error;
    if ([self.device lockForConfiguration:&error]) {
        
        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.device setFocusPointOfInterest:focusPoint];
            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        
        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose ]) {
            [self.device setExposurePointOfInterest:focusPoint];
            [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        
        [self.device unlockForConfiguration];
        _focusView.center = point;
        _focusView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            _focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                _focusView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                _focusView.hidden = YES;
            }];
        }];
    }
    
}
#pragma mark 重拍
-(void)tabkePhotoAgain
{
    [self.imageView removeFromSuperview];
    [self.session startRunning];
    _changeCameraBtn.hidden = NO;
    _takePhoto.hidden = YES;
    _clickNum =0;
    _PhotoButton.selected = NO;
    [_PhotoButton sd_clearAutoLayoutSettings];

    _PhotoButton.sd_layout.centerXIs(self.view.centerX).bottomSpaceToView(self.view,42).widthIs(76).heightIs(76);
    [_PhotoButton updateLayout];
}
#pragma mark - 截取照片
- (void)shutterCamera:(UIButton *)sender
{
    sender.selected = YES;
    if (_clickNum>0) {
        if (self.imageData.length!=0) {
            [self cancle];//隐藏视图
            if (_sendCameraImageBlock) {
                _sendCameraImageBlock(self.image);
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [self saveImageToPhotoAlbum:self.image];
                });
            }
        }else{
            NSLog(@"照片信息为空");
        }
        return;
    }

    
    AVCaptureConnection * videoConnection = [self.ImageOutPut connectionWithMediaType:AVMediaTypeVideo];
    if (!videoConnection) {
        NSLog(@"take photo failed!");
        return;
    }
    
    [self.ImageOutPut captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == NULL) {
            return;
        }
        NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        self.imageData = imageData;
        self.image = [UIImage imageWithData:imageData];
        [self.session stopRunning];
        
        self.imageView = [[UIImageView alloc]initWithFrame:self.previewLayer.frame];
        [self.view insertSubview:_imageView belowSubview:_PhotoButton];
        self.imageView.layer.masksToBounds = YES;
        self.imageView.image = _image;
        
        //隐藏转换摄像头按钮 显示重拍按钮
        [UIView animateWithDuration:0.5 animations:^{
            _changeCameraBtn.hidden = YES;
            _takePhoto.hidden = NO;
            _takePhoto.sd_layout.leftSpaceToView(self.view,53).bottomSpaceToView(self.view,42).widthIs(76).heightIs(76);
            _PhotoButton.sd_layout.rightSpaceToView(self.view,52).bottomSpaceToView(self.view,42).widthIs(76).heightIs(76);
            [_PhotoButton updateLayout];
        } completion:^(BOOL finished) {
        }];

        _clickNum ++;
        
    }];
}
#pragma - 保存至相册
- (void)saveImageToPhotoAlbum:(UIImage*)savedImage
{
    
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    
}
// 指定回调方法

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo

{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
}
-(void)cancle{
    [self.imageView removeFromSuperview];
    [self.session stopRunning];

    
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"销毁了");
    }];
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}
#pragma mark - 检查相机权限
- (BOOL)canUserCamear{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"请打开相机权限" message:@"设置-隐私-相机" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        alertView.tag = 100;
        [alertView show];
        return NO;
    }
    else{
        return YES;
    }
    return YES;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0 && alertView.tag == 100) {
        
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        
        if([[UIApplication sharedApplication] canOpenURL:url]) {
            
            [[UIApplication sharedApplication] openURL:url];
            
        }
    }
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
