//
//  ZoomImageView.h
//  WeiBoS
//
//  Created by mac on 15/10/24.
//  Copyright © 2015年 sww. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIView+UIViewController.h"
@interface ZoomImageView : UIImageView<UIScrollViewDelegate,UIAlertViewDelegate>


@property (nonatomic,strong)UIImageView *lagerImageView;

@end
