//
//  AppDelegate.m
//  MCChat
//
//  Created by 石文文 on 16/1/8.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import "AppDelegate.h"
#import "MainTabBarViewController.h"
#define UIMutableUserNotificationActionBackground @"UIMutableUserNotificationActionBackground"
#define UIMutableUserNotificationActionForeground @"UIMutableUserNotificationActionForeground"
@interface AppDelegate ()
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
//    self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:[[RootViewController alloc]init]];
    self.window.rootViewController = [[MainTabBarViewController alloc]init];
    //  1.如果是iOS8请求用户权限
    if ([UIDevice currentDevice].systemVersion.doubleValue >= 8.0 && [UIDevice currentDevice].systemVersion.floatValue <= 9.0) {
        
        /*
         UIUserNotificationType:
         
         UIUserNotificationTypeBadge   = 1 << 0, // 接收到通知可更改程序的应用图标
         UIUserNotificationTypeSound   = 1 << 1, // 接收到通知可播放声音
         UIUserNotificationTypeAlert   = 1 << 2, // 接收到通知课提示内容
         如果你需要使用多个类型,可以使用 "|" 来连接
         */
        
        //      向用户请求通知权限
        //      categories暂时传入nil
        
        
        //  2.1创建第一个行为
        UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc] init];
        //  2.1.1 设置行为的唯一标示
        action1.identifier = UIMutableUserNotificationActionBackground;
        //  2.1.2 设置通知按钮的的标题
        action1.title = @"查看";
        //      以什么样模式运行应用
        //        UIUserNotificationActivationModeForeground, // 点击的时候启动应用
        //        UIUserNotificationActivationModeBackground  //当点击的时候不启动程序，在后台处理
        action1.activationMode = UIUserNotificationActivationModeBackground;
        //  2.1.3 是否只有锁屏的锁屏状态下才能显示
        action1.authenticationRequired = NO;
        //  2.1.4 按钮的性质
        action1.destructive = NO;
        
        //  2.1创建第一个行为
        UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];
        //  2.1.1 设置行为的唯一标示
        action2.identifier =UIMutableUserNotificationActionForeground;
        //  2.1.2 设置通知按钮的的标题
        action2.title = @"忽略";

        action2.activationMode = UIUserNotificationActivationModeForeground;
        //  2.1.3 用户必须输入密码才能执行
        action2.authenticationRequired = YES;
        //  2.1.4 按钮的性质(没有效果)
        action2.destructive = YES;

        //  3.创建用户通知分类
        UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory  alloc]  init];
        //  3.1 设置类别的唯一标识
        category.identifier = @"myCategory";
        //  3.2 设置通知的按钮
        //    Context:
        //        UIUserNotificationActionContextDefault,  //默认上下文(情景)下的英文(通常都是)
        //        UIUserNotificationActionContextMinimal   //通知内容区域受限情况下内容
        [category   setActions:@[action1,action2] forContext:UIUserNotificationActionContextDefault];
        
        
        //  4.创建用户通知的设置信息
    
        
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:[NSSet setWithObject:category]];
        
        [application registerUserNotificationSettings:setting];
    }else if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0){
        
              //  2.1创建第一个行为
        UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];
        //  2.1.1 设置行为的唯一标示
        action2.identifier =UIMutableUserNotificationActionForeground;


        action2.behavior = UIUserNotificationActionBehaviorTextInput;
        action2.activationMode = UIUserNotificationActivationModeBackground;
        //  2.1.3 用户必须输入密码才能执行
        action2.authenticationRequired = YES;
        //  2.1.4 按钮的性质(没有效果)
        action2.destructive = YES;
        
        //  3.创建用户通知分类
        UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory  alloc]  init];
        //  3.1 设置类别的唯一标识
        category.identifier = @"myCategory";
        //  3.2 设置通知的按钮
        //    Context:
        //        UIUserNotificationActionContextDefault,  //默认上下文(情景)下的英文(通常都是)
        //        UIUserNotificationActionContextMinimal   //通知内容区域受限情况下内容
        [category   setActions:@[action2] forContext:UIUserNotificationActionContextDefault];
        
        
        //  4.创建用户通知的设置信息
        
        
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:[NSSet setWithObject:category]];
        
        
         [application registerUserNotificationSettings:setting];
        
        
        
        
        
    }

    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
// 本地通知回调函数，当应用程序在前台时调用
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"noti:%@",notification);
    
    // 这里真实需要处理交互的地方
    // 获取通知所带的数据
    
    // 更新显示的徽章个数
//    NSInteger badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
//    badge--;
//    badge = badge >= 0 ? badge : 0;
//    [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
    
    // 在不需要再推送时，可以取消推送
    
   
    [ChatViewController cancelLocalNotificationWithKey:@"key"];
}
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler {
    
    if ([UIDevice currentDevice].systemVersion.floatValue > 9.0) {
        
        return;
    }
    
    //  处理不同行为
    if ([identifier isEqualToString:UIMutableUserNotificationActionBackground]) {
        //查看
        
    }else if ([identifier isEqualToString:UIMutableUserNotificationActionForeground]) {
        //忽略
        
    }else{
        NSLog(@"其他");
    }
    /**
     You should call the completion handler as soon as you've finished handling the action.
     当任务处理完毕时候,你应该尽快的调用completion的block.
     */
    
    // 在当任务完成的时候,调用任务完成的block
    completionHandler();
}
- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forLocalNotification:(UILocalNotification *)notification withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void(^)())completionHandler{
    
//     更新显示的徽章个数
        NSInteger badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
        badge--;
        badge = badge >= 0 ? badge : 0;
        [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
    NSString *content = responseInfo[UIUserNotificationActionResponseTypedTextKey];
    
    MainTabBarViewController *mainTab = (MainTabBarViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    [mainTab.chatVC sendWeNeedNews:content];
    
    completionHandler();
}

@end
