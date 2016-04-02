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
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(showUMSocial:)];
        longPress.minimumPressDuration = 1;
        
        [self addGestureRecognizer:tap];
        [self addGestureRecognizer:longPress];
        
    }
    return self;
}
- (void)showUMSocial:(UILongPressGestureRecognizer *)longPress{
    
    if (longPress.state == UIGestureRecognizerStateBegan) {
        NSString *shareText = @"~分享自MCChat";             //分享内嵌文字
        //    UIImage *shareImage = [UIImage imageNamed:@"UMS_social_demo"];          //分享内嵌图片
        UIImage *shareImage = self.image;
        //调用快速分享接口
        [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
        [UMSocialData defaultData].extConfig.yxsessionData.yxMessageType = UMSocialYXMessageTypeImage;
         [UMSocialData defaultData].extConfig.yxtimelineData.yxMessageType = UMSocialYXMessageTypeImage;
        [UMSocialSnsService presentSnsIconSheetView:self.viewController
                                             appKey:UMENG_KEY
                                          shareText:shareText
                                         shareImage:shareImage
                                    shareToSnsNames:@[UMShareToSina,UMShareToYXSession,UMShareToYXTimeline,UMShareToWechatSession,UMShareToWechatTimeline,UMShareToWechatFavorite]
                                           delegate:self];
        
   
    }
    
    
}

#pragma mark -- UM 
/**
 自定义关闭授权页面事件
 
 @param navigationCtroller 关闭当前页面的navigationCtroller对象
 
 */
//-(BOOL)closeOauthWebViewController:(UINavigationController *)navigationCtroller socialControllerService:(UMSocialControllerService *)socialControllerService;

/**
 关闭当前页面之后
 
 @param fromViewControllerType 关闭的页面类型
 
 */
-(void)didCloseUIViewController:(UMSViewControllerType)fromViewControllerType{
 
    
}

/**
 各个页面执行授权完成、分享完成、或者评论完成时的回调函数
 
 @param response 返回`UMSocialResponseEntity`对象，`UMSocialResponseEntity`里面的viewControllerType属性可以获得页面类型
 */
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response{
    
    NSLog(@"didFinishGetUMSocialDataInViewController with response is %@",response);
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
//        [[CustomAlertView shareCustomAlertView]showBottomAlertViewWtihTitle:response.message viewController:nil];
        
    }else{
         NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
//        [[CustomAlertView shareCustomAlertView]showBottomAlertViewWtihTitle:response.message viewController:nil];
        
    }
    
    
}

/**
 点击分享列表页面，之后的回调方法，你可以通过判断不同的分享平台，来设置分享内容。
 例如：
 
 -(void)didSelectSocialPlatform:(NSString *)platformName withSocialData:(UMSocialData *)socialData
 {
 if (platformName == UMShareToSina) {
 socialData.shareText = @"分享到新浪微博的文字内容";
 }
 else{
 socialData.shareText = @"分享到其他平台的文字内容";
 }
 }
 
 @param platformName 点击分享平台
 
 @prarm socialData   分享内容
 */
//-(void)didSelectSocialPlatform:(NSString *)platformName withSocialData:(UMSocialData *)socialData;


/**
 配置点击分享列表后是否弹出分享内容编辑页面，再弹出分享，默认需要弹出分享编辑页面
 
 @result 设置是否需要弹出分享内容编辑页面，默认需要
 
 */
- (BOOL)isDirectShareInIconActionSheet{
    
    return YES;
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
    CGPoint point = [self convertPoint:self.center toView:[UIApplication sharedApplication].keyWindow];
    scrollView.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:0.35 animations:^{
        
        CGAffineTransform transfrom1 = CGAffineTransformMakeScale( self.width / KScreenWidth , self.width/KScreenWidth );
        scrollView.transform = transfrom1;
//
        CGAffineTransform transfrom2 = CGAffineTransformMakeTranslation(point.x - KScreenWidth / 2, point.y - KScreenHeight / 2);
//
        CGAffineTransform transfrom3 = CGAffineTransformConcat(transfrom1, transfrom2);
        CGAffineTransform transfrom4 = CGAffineTransformMakeRotation(-M_PI );
        scrollView.transform = CGAffineTransformConcat(transfrom4, transfrom3);
        scrollView.alpha = 0.1;

        
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
