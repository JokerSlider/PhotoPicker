//
//  UIImageView+HighAndLowImageView.h
//  PhotoPickerManager
//
//  Created by mac on 2017/10/26.
//  Copyright © 2017年 Joker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface UIImageView (HighAndLowImageView)
@property (nonatomic,strong)ALAsset *sourceData;
@end
