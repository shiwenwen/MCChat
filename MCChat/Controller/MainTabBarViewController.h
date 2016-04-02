//
//  MainTabBarViewController.h
//  MCChat
//
//  Created by 石文文 on 16/1/14.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatViewController.h"

@interface MainTabBarViewController : UITabBarController
@property (nonatomic,weak)ChatViewController *chatVC;


@end
