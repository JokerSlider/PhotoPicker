//
//  UIImageView+HighAndLowImageView.m
//  PhotoPickerManager
//
//  Created by mac on 2017/10/26.
//  Copyright © 2017年 Joker. All rights reserved.
//

#import "UIImageView+HighAndLowImageView.h"
#import <objc/runtime.h>

@implementation UIImageView (HighAndLowImageView)
-(void)setSourceData:(ALAsset *)sourceData
{
    SEL key = @selector(sourceData);
    objc_setAssociatedObject(self, key, sourceData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(ALAsset *)sourceData
{
    return objc_getAssociatedObject(self, _cmd);
}
@end
