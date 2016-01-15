//
//  CustomAlertView.m
//  GoToSchool
//
//  Created by whe on 15/4/29.
//  Copyright (c) 2015年 UI. All rights reserved.
//

#import "CustomAlertView.h"


#import <CoreText/CoreText.h>
#import "NSString+WPAttributedMarkup.h"
#import "WPAttributedStyleAction.h"
#import "WPHotspotLabel.h"
#import "sys/utsname.h"
//#define kCustomViewWidth 240
//#define kCustomViewHight 240
//#define kButtonWidth 120
//#define kButtonHight 30
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kTitlelFont 18
#define kContentFont 16
@implementation CustomAlertView
{
    UIView *_alertView;
}
static CustomAlertView * _shareCustomAlertView;
+ (CustomAlertView *)shareCustomAlertView{
    if (_shareCustomAlertView == nil) {
        _shareCustomAlertView = [[CustomAlertView alloc] initWithFrame:CGRectMake(0,0, kScreenWidth,kScreenHeight)];
                _shareCustomAlertView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        _shareCustomAlertView.isHidden = YES;
    }
    return _shareCustomAlertView;
}

- (NSString*)deviceString
{
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    NSLog(@"%@", platform);
    
    return platform;
}
#pragma mark - 有确定取消的提示框
- (void)showAlertViewWtihTitle:(NSString *)title
                       content:(NSString *)content
                     sureTitle:(NSString *)sureTitle
                   cancleTitle:(NSString *)cancleTitle
                viewController:(UIViewController *)viewController
{
    
    _shareCustomAlertView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    
    [self showAlertViewWtihTitle:title content:content tapContent:nil tapEvent:^{
        
    } sureTitle:sureTitle cancleTitle:cancleTitle viewController:viewController];
    
}

- (void)sureButton:(UIButton *)button{
    
    [_delegate CustomAlertViewClickedButtonAtIndex:button.tag-1000];
    [self removeFromSuperview];
}
- (void)cancleButton:(UIButton *)button{
    
    [_delegate CustomAlertViewClickedButtonAtIndex:button.tag-1000];
    [self removeFromSuperview];
}


#pragma mark - 只显示文字的提示框
- (void)showAlertViewWtihTitle:(NSString *)title viewController:(UIViewController *)viewController{
    
    _shareCustomAlertView.backgroundColor = [UIColor clearColor];
    self.isHidden = NO;
    CGFloat kCustomViewWidth = kScreenWidth - 40*2;
    CGFloat kCustomViewHight = kCustomViewWidth/2.f;
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _alertView = nil;
    _alertView = [[UIView alloc]initWithFrame: CGRectMake((kScreenWidth-kCustomViewWidth)/2, (kCustomViewHight-kCustomViewHight)/2 - 40, kCustomViewWidth,kCustomViewHight)];
    //    _alertView.backgroundColor = [UIColor whiteColor];
    
    _alertView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.8];
    
    _alertView.layer.cornerRadius = 8.f;
    [self addSubview:_alertView];
//    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, kCustomViewWidth, 20)];
//    //    label.textColor = kLightBlue;
//    label.textColor = [UIColor whiteColor];
//    label.font = [UIFont systemFontOfSize:kTitlelFont];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.text = @"提示";
//    [_alertView addSubview:label];
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40 - 20, kCustomViewWidth-20*2, CGFLOAT_MAX)];
    //    titleLabel.textColor = k99Gray;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:kContentFont];
    titleLabel.numberOfLines = 0;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = title;
    [_alertView addSubview:titleLabel];
    //label自适应高度
    CGRect rect = [titleLabel.text boundingRectWithSize:CGSizeMake(kCustomViewWidth-20*2, CGFLOAT_MAX)
                                                options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                             attributes:[NSDictionary dictionaryWithObjectsAndKeys:titleLabel.font,NSFontAttributeName, nil]
                                                context:nil];
    if (rect.size.height <= 20) {
        kCustomViewWidth =  title.length * 16 + 20 * 2;
        
    }
    
    titleLabel.frame =CGRectMake(20, 40 - 35, kCustomViewWidth-20*2, rect.size.height+20);
   
   
    CGFloat alertHeight = titleLabel.frame.origin.y + titleLabel.frame.size.height + 10 - 5 ;
    //    _alertView.frame = CGRectMake((kScreenWidth-kCustomViewWidth)/2, (kScreenHeight-kCustomViewHight)/2, kCustomViewWidth, 50+rect.size.height);
    _alertView.frame = CGRectMake((kScreenWidth-kCustomViewWidth)/2, (kScreenHeight-kCustomViewHight)/2 - 40, kCustomViewWidth, alertHeight );
    
    if (rect.size.height <= 20) {
        
        
    }
    
    
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [self performSelector:@selector(finishShow) withObject:self afterDelay:2];
}

#pragma  mark -- 可以点击的提醒框
- (void)showAlertViewWtihTitle:(NSString *)title
                       content:(NSString *)content
                    tapContent:(NSString *)tapContent
                      tapEvent:(TapEvent)tapEvent
                     sureTitle:(NSString *)sureTitle
                   cancleTitle:(NSString *)cancleTitle
                viewController:(UIViewController *)viewController
{
    CGFloat kCustomViewWidth = kScreenWidth - 40*2;
    CGFloat kCustomViewHight = kCustomViewWidth/2.f;
    CGFloat kButtonWidth = kCustomViewHight;
    CGFloat kButtonHight = 30;
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _alertView = nil;
    _alertView = [[UIView alloc]initWithFrame:CGRectMake((kScreenWidth-kCustomViewWidth)/2 - 40, (kCustomViewHight-kCustomViewHight)/2, kCustomViewWidth,kCustomViewHight)];
    
    _alertView.backgroundColor = [UIColor whiteColor];
    _alertView.layer.cornerRadius = 8.f;
    [self addSubview:_alertView];
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,15, kCustomViewWidth, 20)];
    titleLabel.textColor = [UIColor colorWithRed:0.158 green:0.417 blue:1.000 alpha:1.000];
    titleLabel.font = [UIFont systemFontOfSize:kTitlelFont];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = title;
    [_alertView addSubview:titleLabel];
    
    CGFloat lineY = titleLabel.frame.origin.y + titleLabel.frame.size.height+10;
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(0, lineY , kCustomViewWidth, 0.5)];
    lineView.backgroundColor = [UIColor colorWithWhite:0.203 alpha:1.000];
    [_alertView addSubview:lineView];
    
    CGFloat contetY = lineY + 10;
    WPHotspotLabel * contentLabel = [[WPHotspotLabel alloc] initWithFrame:CGRectMake(20, contetY, kCustomViewWidth-30, 120)];
    contentLabel.textColor = [UIColor colorWithWhite:0.568 alpha:1.000];
    contentLabel.numberOfLines = 0;
    
    if (tapContent) {
        NSDictionary* style3 = @{@"body":[UIFont systemFontOfSize:kContentFont],
                                 @"help":[WPAttributedStyleAction styledActionWithAction:^{
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         tapEvent();
                                     });
                                 }],
                                 @"link": [UIColor colorWithRed:0.158 green:0.417 blue:1.000 alpha:1.000]};
        NSString * str = [NSString stringWithFormat:@"%@<help>%@</help>",content,tapContent];
        contentLabel.attributedText = [str attributedStringWithStyleBook:style3];
    }else{
        contentLabel.font = [UIFont systemFontOfSize:kContentFont];
        contentLabel.text = content;
    }
    
    
    //label自适应高度 0
    CGRect rect = [contentLabel.text boundingRectWithSize:CGSizeMake(kCustomViewWidth-15*2, CGFLOAT_MAX)
                                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                               attributes:[NSDictionary dictionaryWithObjectsAndKeys:contentLabel.font,NSFontAttributeName, nil]
                                                  context:nil];
    CGFloat scaleHeight = kScreenWidth;
    
    if (scaleHeight > 375) {
        scaleHeight = 20;
        kButtonHight = 40;
    }
    else
        scaleHeight = 0;
    
    contentLabel.frame =CGRectMake(20, contetY, kCustomViewWidth-30, rect.size.height+scaleHeight);
    
    [_alertView addSubview:contentLabel];
    UIButton * sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sureButton.tag = 1000;
    sureButton.titleLabel.font = [UIFont systemFontOfSize:kTitlelFont];
    sureButton.frame = CGRectMake(kCustomViewWidth-kButtonWidth,CGRectGetMaxY(contentLabel.frame)+15, kButtonWidth, kButtonHight);
    [sureButton setTitle:sureTitle forState:UIControlStateNormal];
    [sureButton setTitleColor:[UIColor colorWithRed:0.158 green:0.417 blue:1.000 alpha:1.000] forState:UIControlStateNormal];
    [sureButton addTarget:self action:@selector(sureButton:) forControlEvents:UIControlEventTouchUpInside];
    [_alertView addSubview:sureButton];
    UIButton * cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancleButton.tag = 1001;
    cancleButton.titleLabel.font = [UIFont systemFontOfSize:kTitlelFont];
    cancleButton.frame = CGRectMake(0,CGRectGetMaxY(contentLabel.frame)+15, kButtonWidth, kButtonHight);
    [cancleButton setTitle:cancleTitle forState:UIControlStateNormal];
    [cancleButton setTitleColor:[UIColor colorWithRed:0.158 green:0.417 blue:1.000 alpha:1.000] forState:UIControlStateNormal];
    [cancleButton addTarget:self action:@selector(cancleButton:) forControlEvents:UIControlEventTouchUpInside];
    [_alertView addSubview:cancleButton];
    
    UIView * lineView2 = [[UIView alloc] initWithFrame:CGRectMake(0, contentLabel.frame.origin.y + contentLabel.frame.size.height +10 , kCustomViewWidth, 0.5)];
    lineView2.backgroundColor = [UIColor colorWithWhite:0.203 alpha:1.000];
    [_alertView addSubview:lineView2];
    UIView * lineView3 = [[UIView alloc] initWithFrame:CGRectMake(_alertView.frame.size.width/2, contentLabel.frame.origin.y + contentLabel.frame.size.height +10, 0.5, kButtonHight+10)];
    lineView3.backgroundColor = [UIColor colorWithWhite:0.203 alpha:1.000];
    [_alertView addSubview:lineView3];
    CGFloat alertHeight = lineView2.frame.origin.y+lineView3.frame.size.height;
    //    _alertView.frame = CGRectMake((kScreenWidth-kCustomViewWidth)/2, (kScreenHeight-kCustomViewHight)/2, kCustomViewWidth,60+kButtonHight+rect.size.height+10);
    
    _alertView.frame = CGRectMake((kScreenWidth-kCustomViewWidth)/2, (kScreenHeight-kCustomViewHight)/2 - 40, kCustomViewWidth,alertHeight);
    

    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
}
- (void)finishShow{
    [self removeFromSuperview];
    self.isHidden = YES;
}
@end

