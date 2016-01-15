//
//  CustomAlertView.h
//  GoToSchool
//
//  Created by whe on 15/4/29.
//  Copyright (c) 2015年 UI. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomAlertView;
@protocol CustomAlertViewDelegate <NSObject>
/*
 buttonIndex为0的时候是确定键被点击，1为取消被点击
*/
- (void)CustomAlertViewClickedButtonAtIndex:(NSInteger)buttonIndex;

@end


typedef void(^TapEvent)();
@interface CustomAlertView : UIView

//用单例创建后面有黑色的半透明视图
//alloc出来没有
@property (nonatomic ,weak)__weak id<CustomAlertViewDelegate>delegate;
@property (nonatomic,assign)BOOL isHidden;
+(CustomAlertView *)shareCustomAlertView;
//没有确定
-(void)showAlertViewWtihTitle:(NSString *)title
               viewController:(UIViewController *)viewController;
//有确定取消
#pragma mark - 有确定取消的提示框
-(void)showAlertViewWtihTitle:(NSString *)title
                      content:(NSString *)content
                    sureTitle:(NSString *)sureTitle
                  cancleTitle:(NSString *)cancleTitle
               viewController:(UIViewController *)viewController;


#pragma  mark -- 可以点击的提醒框
- (void)showAlertViewWtihTitle:(NSString *)title
                       content:(NSString *)content
                    tapContent:(NSString *)tapContent
                      tapEvent:(TapEvent)tapEvent
                     sureTitle:(NSString *)sureTitle
                   cancleTitle:(NSString *)cancleTitle
                viewController:(UIViewController *)viewController;
@end
