//
//  ImageTools.m
//  GoToSchool
//
//  Created by 蔡连凤 on 15/4/29.
//  Copyright (c) 2015年 UI. All rights reserved.
//

#import "ImageTools.h"

@implementation ImageTools

static ImageTools *_shareImageTool =nil;
//返回单例的静态方法
+ (ImageTools *)shareTool
{
    //确保线程安全
    @synchronized(self){
        //确保只返回一个实例
        if (_shareImageTool == nil) {
            _shareImageTool = [[ImageTools alloc] init];
        }
    }
    return _shareImageTool;
}

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

//在指定的视图内进行截屏操作,返回截屏后的图片
- (UIImage *)imageWithScreenContentsInView:(UIView *)view
{
    //根据屏幕大小，获取上下文
    UIGraphicsBeginImageContext([[UIScreen mainScreen] bounds].size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return viewImage;
}


- (UIImage*)resizeImageToSize:(CGSize)size
                  sizeOfImage:(UIImage*)image
{
    
    UIGraphicsBeginImageContext(size);
    //获取上下文内容
    CGContextRef ctx= UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, 0.0, size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    //重绘image
    CGContextDrawImage(ctx,CGRectMake(0.0f, 0.0f, size.width, size.height), image.CGImage);
    //根据指定的size大小得到新的image
    UIImage* scaled= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaled;
}

- (UIImage*)resizeImageInRect:(CGRect)rect
                  image:(UIImage*)image
{

    CGImageRef imageRef = image.CGImage;
    CGImageRef imageRefRect =CGImageCreateWithImageInRect(imageRef, rect);
    
    UIImage * ret = [[UIImage alloc] initWithCGImage:imageRefRect];
    CGImageRelease(imageRefRect);
    return ret
    ;
}

//- (UIImage*)resizeImageToSize:(CGSize)size
//                         rect:(CGRect)rect
//                  sizeOfImage:(UIImage*)image
//{
//    CGSize imageSize = image.size;
//    CGSize image2Size;
//    if (rect.size.width/imageSize.width > rect.size.height/imageSize.height) {
//        image2Size = CGSizeMake(imageSize.width*(size.width/imageSize.width), imageSize.height*(size.width/imageSize.width));
//    }else {
//        image2Size = CGSizeMake(imageSize.width*(size.height/imageSize.height), imageSize.height*(size.height/imageSize.height));
//    }
//    
//    UIGraphicsBeginImageContext(image2Size);
//    
//    //获取上下文内容
//    CGContextRef ctx= UIGraphicsGetCurrentContext();
//    CGContextTranslateCTM(ctx, 0.0, size.height);
//    CGContextScaleCTM(ctx, 1.0, -1.0);
//    
//    //    100 * 300  10 * 40
//    //重绘image
//    if (rect.size.width/imageSize.width > rect.size.height/imageSize.height) {
//        //h基准
////        CGContextDrawImage(ctx,CGRectMake(0.0f, 0.0f, rect.size.height*(imageSize.width/imageSize.height), rect.size.height), image.CGImage);
////        CGContextDrawImage(ctx,CGRectMake(0.0f, 0.0f, imageSize.height*(imageSize.width/imageSize.height), imageSize.height), image.CGImage);
//        CGContextDrawImage(ctx,CGRectMake(0.0f, 0.0f, imageSize.width*(size.width/imageSize.width), imageSize.height*(size.width/imageSize.width)), image.CGImage);
////        CGContextDrawImage(ctx,CGRectMake(0.0f, 0.0f, imageSize.width*(size.height/imageSize.height), imageSize.height*(size.height/imageSize.height)), image.CGImage);
//    }else {
////        CGContextDrawImage(ctx,CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.width*(imageSize.height/imageSize.width)), image.CGImage);
////        CGContextDrawImage(ctx,CGRectMake(0.0f, 0.0f, imageSize.height*(imageSize.width/imageSize.height), imageSize.height), image.CGImage);
////        CGContextDrawImage(ctx,CGRectMake(0.0f, 0.0f, imageSize.width*(size.width/imageSize.width), imageSize.height*(size.width/imageSize.width)), image.CGImage);
//        CGContextDrawImage(ctx,CGRectMake(0.0f, 0.0f, imageSize.width*(size.height/imageSize.height), imageSize.height*(size.height/imageSize.height)), image.CGImage);
//    }
//    
//    
//    //根据指定的size大小得到新的image
//    UIImage* scaled= UIGraphicsGetImageFromCurrentImageContext();
//    NSLog(@"%@", NSStringFromCGSize(scaled.size));
//    UIGraphicsEndImageContext();
//    
//    CGImageRef imageRef = scaled.CGImage;
//    CGImageRef imageRefRect =CGImageCreateWithImageInRect(imageRef, rect);
//    CGImageRelease(imageRefRect);
//    
//    
//    return [[UIImage alloc] initWithCGImage:imageRefRect];
//}

@end
