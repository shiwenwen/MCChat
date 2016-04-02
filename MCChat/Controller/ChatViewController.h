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
typedef  void(^TouchBlock)();
@property (nonatomic,strong)MainTabBarViewController *tabVC;
- (void)makeBlueData;
+ (void)cancelLocalNotificationWithKey:(NSString *)key;
- (void)sendWeNeedNews:(NSString *)content;
//搜索设备
- (void)lookOtherDevice;
- (void)showFileManager;
- (void)showSelf;
@property (nonatomic,copy)TouchBlock touchBlock;
@end
