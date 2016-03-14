//
//  ImageTools.h
//  GoToSchool
//
//  Created by 蔡连凤 on 15/4/29.
//  Copyright (c) 2015年 UI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@interface ImageTools : NSObject
//返回单例的静态方法
+ (ImageTools *)shareTool;

//返回特定尺寸的UImage  ,  image参数为原图片，size为要设定的图片大小
- (UIImage*)resizeImageToSize:(CGSize)size
                  sizeOfImage:(UIImage*)image;

//在指定的视图内进行截屏操作,返回截屏后的图片
- (UIImage *)imageWithScreenContentsInView:(UIView *)view;

//- (UIImage*)resizeImageToSize:(CGSize)size
//                         rect:(CGRect)rect
//                  sizeOfImage:(UIImage*)image;

- (UIImage*)resizeImageInRect:(CGRect)rect
image:(UIImage*)image;
@end
