//
//  ZoomImageView.h
//  WeiBoS
//
//  Created by mac on 15/10/24.
//  Copyright © 2015年 sww. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+GIF.h"
#import "UIView+UIViewController.h"
#import "UMSocialShakeService.h"
@interface ZoomImageView : UIImageView<UIScrollViewDelegate,UIAlertViewDelegate,UMSocialUIDelegate>


@property (nonatomic,strong)UIImageView *lagerImageView;

@end
