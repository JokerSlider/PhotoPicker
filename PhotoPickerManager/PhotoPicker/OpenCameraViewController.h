//
//  OpenCameraViewController.h
//  CSchool
//
//  Created by mac on 17/3/6.
//  Copyright © 2017年 Joker. All rights reserved.
//

#import "BaseViewController.h"
typedef void(^sendCameraImageBlock)(UIImage *imageData);

@interface OpenCameraViewController : BaseViewController
@property (nonatomic, copy) sendCameraImageBlock sendCameraImageBlock;

@end
