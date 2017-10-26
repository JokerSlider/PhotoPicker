//
//  OpenCameraViewController.h
//  CSchool
//
//  Created by mac on 17/3/6.
//  Copyright © 2017年 Joker. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^sendCameraImageBlock)(UIImage *imageData);

@interface OpenCameraViewController : UIViewController
@property (nonatomic, copy) sendCameraImageBlock sendCameraImageBlock;

@end
