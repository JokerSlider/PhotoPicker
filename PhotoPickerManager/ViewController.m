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
#import <pop/POP.h>

@interface ViewController ()<AIPictureViewerDelegate>
@property (nonatomic, strong) AIPictureViewer *picPikerView;
@property (nonatomic,strong)  UIImageView *endImageV;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getPhotoPriavcy];
    [self.view addSubview:self.endImageV];
    [self.view addSubview:self.picPikerView];
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
    popAnimation.toValue                  =   [NSValue valueWithCGPoint:CGPointMake((kScreenWidth-200)/2, 100)];//锁定图片位置
    popAnimation.duration                 =   0.5;
    popAnimation.timingFunction           =   [CAMediaTimingFunction functionWithName:kCAAnimationLinear];
    [imageView.layer pop_addAnimation:popAnimation forKey:nil];
    //动画完成后赋值
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(popAnimation.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [imageView removeFromSuperview];
        _endImageV.image = image;
   
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
            ALAsset *image = obj;
            
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
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        for (int i =0 ; i<imageArray.count; i++) {
            ALAsset *result =imageArray[i];
            
        }
    });
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

