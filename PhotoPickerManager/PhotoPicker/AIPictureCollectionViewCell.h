//
//  AIPictureCollectionViewCell.h
//  AIAnimationDemo
//
//  Created by joker on 2016/10/23.
//  Copyright © 2017 joker All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCFireworksButton.h"
#import "UIImageView+HighAndLowImageView.h"
#import <AssetsLibrary/AssetsLibrary.h>
@class AIPictureCollectionViewCell;
@protocol AIPictureCollectionCellDelegate <NSObject>
-(void)sendImage:(UIButton *)sender event:(id)event;
/**
 在图片拉出的时候调用

 @param pictureCollectionCell 当前cell
 @param image             被拉出的那张图片
 @param imageWorldRect   选中的图片的世界坐标rect
 */
-(void)pictureCollection:(AIPictureCollectionViewCell*)pictureCollectionCell didGestureSelectedImage:(UIImage*)image  withOriginSoure:(ALAsset *)sorueData andImageWorldRect:(CGRect)imageWorldRect;

/**
 通过图片是否在window上来控制Scollview是否可以滑动

 @param pictureCollectionCell 当前cell
 @param isOnWindow            相片是否在window上
 */
-(void)pictureCollection:(AIPictureCollectionViewCell *)pictureCollectionCell lockScollViewWithOnWindow:(BOOL)isOnWindow;

@end

@interface AIPictureCollectionViewCell : UICollectionViewCell
@property (nonatomic,strong)MCFireworksButton *cicleView;//圆圈

@property (nonatomic,strong)UILabel  *GIFIdeL;//GIF标识
/** 图片*/
@property(nonatomic,strong)UIImageView *imageV;
/** 代理*/
@property(nonatomic,weak)id<AIPictureCollectionCellDelegate> delegate;
/**
  重设选中状态
 */
-(void)resetCircleView;
///**
// 判断选择框的选中状态
// */
//-(void)resetCircleViewSelected;
@end
