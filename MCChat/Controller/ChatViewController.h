//
//  ChatViewController.h
//  MCChat
//
//  Created by 石文文 on 16/1/14.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  MainTabBarViewController;
@interface ChatViewController : UIViewController
@property (nonatomic,strong)MainTabBarViewController *tabVC;
- (void)makeBlueData;
+ (void)cancelLocalNotificationWithKey:(NSString *)key;
@end
