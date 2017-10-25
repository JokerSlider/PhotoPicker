//
//  UIImageView+HighAndLowImageView.m
//  CSchool
//
//  Created by mac on 2017/10/9.
//  Copyright © 2017年 Joker. All rights reserved.
//

#import "UIImageView+HighAndLowImageView.h"
#import <objc/runtime.h>
@implementation UIImageView (HighAndLowImageView)
@dynamic soureData;
static char charKey;

-(void)setSoureData:(ALAsset *)soureData
{
    objc_setAssociatedObject(self, &charKey, soureData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSString *)soureData
{
    return objc_getAssociatedObject(self, &charKey);
}



@end
