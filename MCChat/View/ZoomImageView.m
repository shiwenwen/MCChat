//
//  ZoomImageView.m
//  WeiBoS
//
//  Created by mac on 15/10/24.
//  Copyright © 2015年 sww. All rights reserved.
//

#import "ZoomImageView.h"
#import "CustomAlertView.h"
#import "UIView+UIViewController.h"
#define KScreenHeight [UIScreen mainScreen].bounds.size.height
#define KScreenWidth [UIScreen mainScreen].bounds.size.width
@implementation ZoomImageView
- (void)awakeFromNib{
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(loadOriginal_pic:)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tap];
    
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(loadOriginal_pic:)];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:tap];

        
    }
    return self;
}
- (void)loadOriginal_pic:(UILongPressGestureRecognizer *)tap{
    

    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    
    
        UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    scrollView.backgroundColor = [UIColor blackColor];

    scrollView.delegate = self;
    
    _lagerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    _lagerImageView.tag = 5000;

    NSLog(@"%@",_lagerImageView.image);
    _lagerImageView.contentMode = UIViewContentModeScaleAspectFit;
    _lagerImageView.backgroundColor = [UIColor clearColor];
    _lagerImageView.image = self.image;
    _lagerImageView.userInteractionEnabled = YES;
    scrollView.userInteractionEnabled = YES;
    scrollView.minimumZoomScale = 1;
    scrollView.maximumZoomScale = 2.5;
    
    UITapGestureRecognizer *tapOne = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    tapOne.numberOfTapsRequired = 1;
    tapOne.numberOfTouchesRequired = 1;
    
    
    [_lagerImageView addGestureRecognizer:tapOne];
    
    [scrollView addSubview:_lagerImageView];
    scrollView.tag = 10000;
    //    keyWindow.userInteractionEnabled = YES;
    
    
    [keyWindow addSubview:scrollView];
    
    
    scrollView.transform = CGAffineTransformMakeScale(0, 0);
    [UIView animateWithDuration:0.25 animations:^{
        scrollView.transform = CGAffineTransformIdentity;
    }];

    
    UITapGestureRecognizer *tapTwo = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    
    tapTwo.numberOfTapsRequired = 2;
    tapTwo.numberOfTouchesRequired = 1;
    
    
    [tapOne requireGestureRecognizerToFail:tapTwo];
    UILongPressGestureRecognizer *longGes = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(saveOriginal_pic:)];
    
    longGes.minimumPressDuration = 1;
    [_lagerImageView addGestureRecognizer:longGes];
    [_lagerImageView addGestureRecognizer:tapTwo];
   
    
    
}
- (void)tapAction:(UITapGestureRecognizer *)tap{
    
    if (tap.numberOfTapsRequired == 1) {
        [self closeOriginal_pic];
    }else if (tap.numberOfTapsRequired == 2){
        
        UIScrollView *scrollView = (UIScrollView *)[[UIApplication sharedApplication].keyWindow viewWithTag:10000];
        
        //修改scrollView的放大比例
        [UIView animateWithDuration:.3 animations:^{
            
            scrollView.zoomScale = scrollView.zoomScale == 1?2.5:1;
            
        }];
        
        
        
    }
}
- (void)closeOriginal_pic{
    

    UIScrollView *scrollView = (UIScrollView *)[[UIApplication sharedApplication].keyWindow viewWithTag:10000];
    
    [UIView animateWithDuration:0.15 animations:^{
        scrollView.transform = CGAffineTransformMakeScale(0.1, 0.1);
        scrollView.alpha = 0;
    } completion:^(BOOL finished) {
        
        [scrollView removeFromSuperview];
        
    }];
    
    
    
    
}

- (void)saveOriginal_pic:(UILongPressGestureRecognizer *)longGes{
    
    
    if (longGes.state == UIGestureRecognizerStateBegan ) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"保存图片" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
    
    
        

    
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{

    if (!error) {
         [[CustomAlertView shareCustomAlertView]showAlertViewWtihTitle:@"保存成功" viewController:self.viewController];
    }else
    {
        [[CustomAlertView shareCustomAlertView]showAlertViewWtihTitle:@"保存失败" viewController:self.viewController];
    }

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (buttonIndex == 1) {
        
        UIImageWriteToSavedPhotosAlbum(self.image, self,@selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);

        
    }else{

        
    }
    
    
    
}
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    //返回放大的视图
    return _lagerImageView;
}

@end
