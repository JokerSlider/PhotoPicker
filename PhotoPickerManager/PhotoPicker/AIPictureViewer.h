//
//  AIPictureViewer.h
//  AIAnimationDemo
//
//  Created by joker on  2017/02/09 .
//  Copyright © 2017 joker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
@class AIPictureViewer;
@protocol AIPictureViewerDelegate <NSObject>

/**
 拖动发送

 @param pictureViewer 照片视图
 @param image 照片
 @param imageWorldRect 坐标
 */
-(void)pictureViewer:(AIPictureViewer*)pictureViewer didGestureSelectedImage:(UIImage *)image withOriginSoure:(ALAsset *)sorueData andImageWorldRect:(CGRect)imageWorldRect;

/**
 点击发送

 @param pictureViewer 照片视图
 @param images 照片
 */
-(void)pictureView:(AIPictureViewer*)pictureViewer didSelectedImage:(NSArray *)images;//点击发送
/**
 打开系统相册

 @param pictureViewer self
 */
-(void)pictureViewOpenSystemPhoto:(AIPictureViewer*)pictureViewer withimageArray:(NSArray *)imageArray;//点击发送
@end

@interface AIPictureViewer : UIView
@property (nonatomic,readonly)CGFloat selfHeight ;

/** 图片数组*/
@property(nonatomic,strong)NSArray *imageArrayM;
/** 代理*/
@property(nonatomic,weak)id<AIPictureViewerDelegate> delegate;
@end
