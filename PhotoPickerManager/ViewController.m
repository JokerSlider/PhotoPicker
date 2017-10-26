//
//  ViewController.m
//  PhotoPicker
//
//  Created by mac on 2017/10/25.
//  Copyright © 2017年 Joker. All rights reserved.
//

#import "ViewController.h"
#import "AIPictureViewer.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "OpenCameraViewController.h"
#import <pop/POP.h>

@interface ViewController ()<AIPictureViewerDelegate>
@property (nonatomic, strong) AIPictureViewer *picPikerView;
@property (nonatomic,strong)  UIImageView *endImageV;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getPhotoPriavcy];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *takePhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    takePhotoBtn.frame =CGRectMake((kScreenWidth-200)/2+200, 100, 100,30);
    [takePhotoBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [takePhotoBtn setTitle:@"拍照" forState:UIControlStateNormal];
    [takePhotoBtn addTarget:self action:@selector(openCarmera) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:takePhotoBtn];
    [self.view addSubview:self.endImageV];
    [self.view addSubview:self.picPikerView];
}
-(void)openCarmera
{
    OpenCameraViewController *vc = [[OpenCameraViewController alloc]init];
    vc.sendCameraImageBlock = ^(UIImage *imageData){
      
        self.endImageV.image = imageData;
        
    };
    [self.navigationController presentViewController:vc animated:YES completion:nil];

}

-(void)getPhotoPriavcy
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
    } failureBlock:^(NSError *error) {
        NSLog(@"相册不可用");
    }];
}

-(UIImageView *)endImageV
{
    if (!_endImageV) {
        _endImageV = [[UIImageView alloc]initWithFrame:CGRectMake((kScreenWidth-200)/2, 100, 100, 150)];
        _endImageV.backgroundColor = [UIColor redColor];
    }
    return _endImageV;
}

- (AIPictureViewer *)picPikerView{
    if (!_picPikerView) {
        _picPikerView = [[AIPictureViewer alloc] init];
        _picPikerView.delegate = self;
    }
    return _picPikerView;
}

#pragma mark  ALPictureViewDelegate  此处已经实现发送GIF
-(void)pictureViewer:(AIPictureViewer*)pictureViewer didGestureSelectedImage:(UIImage *)image withOriginSoure:(ALAsset *)sorueData andImageWorldRect:(CGRect)imageWorldRect{
    
    UIImageView *imageView                = [[UIImageView alloc]initWithImage:image];
    imageView.frame                       = imageWorldRect;
    [self.view addSubview:imageView];
    POPBasicAnimation *popAnimation       =   [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPosition];
    popAnimation.toValue                  =   [NSValue valueWithCGPoint:CGPointMake((kScreenWidth-200)/2+50, 100+75)];//锁定图片位置
    popAnimation.duration                 =   0.5;
    popAnimation.timingFunction           =   [CAMediaTimingFunction functionWithName:kCAAnimationLinear];
    [imageView.layer pop_addAnimation:popAnimation forKey:nil];
    //动画完成后赋值
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(popAnimation.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [imageView removeFromSuperview];
        _endImageV.image = image;
        //sorueData  图片的元数据。可以取出来用于上传到服务器
    });
}

/**
 
 发送多张图片
 @param pictureViewer 发送图片的控件
 @param images 照片数组
 */
-(void)pictureView:(AIPictureViewer*)pictureViewer didSelectedImage:(NSArray *)images
{
    
    //点击发送多张图片
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [images enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //                UIImage *image = obj;
            //                NSData *data =  UIImageJPEGRepresentation(image, imageRectRation);
            //                UIImage *newImage = [UIImage imageWithData:data];
            CGImageRef cimg = [obj aspectRatioThumbnail];//[[result defaultRepresentation] fullResolutionImage];//[result aspectRatioThumbnail];
            UIImage *img = [UIImage imageWithCGImage:cimg];//aspectRatioThumbnail
            self.endImageV.image = img;
        }];
        
    });
    
}
/**
 相册选择界面选中图片  点击发送
 
 @param pictureViewer 发送图片的控件
 @param images 照片数组
 */
-(void)pictureViewOpenSystemPhoto:(AIPictureViewer *)pictureViewer withimageArray:(NSArray *)imageArray
{
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(queue, ^{
//
//    });
//
    for (int i =0 ; i<imageArray.count; i++) {
        ALAsset *result =imageArray[i];
        CGImageRef cimg = [result aspectRatioThumbnail];//[[result defaultRepresentation] fullResolutionImage];//[result aspectRatioThumbnail];
        UIImage *img = [UIImage imageWithCGImage:cimg];//aspectRatioThumbnail
        self.endImageV.image = img;
    }
}

/**
 *   发送gif和普通图片的接口
 *
 *
 **/
/*
 [manager POST:[NSString stringWithFormat:@"%@upload_image.php",[AppUserIndex GetInstance].uploadUrl] parameters:newparams constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
 ALAsset *result = image;
 ALAssetRepresentation *rep = [result defaultRepresentation];
 Byte *imageBuffer = (Byte*)malloc(rep.size);
 NSError *error;
 NSUInteger bufferSize = [rep getBytes:imageBuffer fromOffset:0.0 length:rep.size error:&error];
 NSLog(@"%@",error);
 NSData *imageData = [NSData dataWithBytesNoCopy:imageBuffer length:bufferSize freeWhenDone:YES];
 // 获取图片数据
 NSString *type = [self typeForImageData:imageData];
 //不是GIF的话 对图片进行压缩
 if (![type isEqualToString:@"gif"]) {
 CGImageRef cimg =[[result defaultRepresentation] fullResolutionImage];
 UIImage *img = [UIImage imageWithCGImage:cimg];//aspectRatioThumbnail
 // 获取图片数据
 imageData= UIImageJPEGRepresentation(img, 0.6);
 // 设置上传图片的名字
 }else{
 ALAssetRepresentation *re = [result defaultRepresentation];;
 NSUInteger size = (NSUInteger)re.size;
 uint8_t *buffer = malloc(size);
 NSError *error;
 NSUInteger bytes = [re getBytes:buffer fromOffset:0 length:size error:&error];
 NSData *data = [NSData dataWithBytes:buffer length:bytes];//这个就是选取的GIF图片的原二进制数据
 imageData = data;
 free(buffer);
 }
 // 设置上传图片的名字
 
 NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
 formatter.dateFormat = @"yyyyMMddHHmmss";
 NSString *str = [formatter stringFromDate:[NSDate date]];
 NSString *fileName = [NSString stringWithFormat:@"%@.%@", str,type];
 
 [formData appendPartWithFileData:imageData name:@"image" fileName:fileName mimeType:[NSString stringWithFormat:@"image/%@",type]];
 
 } progress:^(NSProgress * _Nonnull uploadProgress) {
 NSLog(@"%@", uploadProgress);
 progress(uploadProgress);
 } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
 // 返回结果
 NSString *decodeStr = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
 
 NSDictionary *dic = [decodeStr objectFromJSONString];
 NSLog(@"%@",dic);
 //        [ProgressHUD showSuccess:@"发布成功!"];
 success(task,dic);
 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
 
 }]
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

