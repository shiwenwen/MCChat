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
#import <AVFoundation/AVFoundation.h>
#import "DBGuestureLock.h"
#import <LocalAuthentication/LAContext.h>
@interface AppDelegate ()<DBGuestureLockDelegate>
@property (nonatomic,strong)UIView *LockView;
@property (nonatomic,strong)UILabel *lockStatusLabel;
@property (nonatomic,strong)MainTabBarViewController *mainTabBar;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
//    self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:[[RootViewController alloc]init]];
    self.mainTabBar = [[MainTabBarViewController alloc]init];
    self.window.rootViewController = self.mainTabBar;
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
        action2.title = @"回复";
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

//    if (launchOptions[@"UIApplicationLaunchOptionsShortcutItemKey"] == nil) {
//        return YES;
//    } else {
//        return NO;
//    }
    
    
    
//手势锁
    [self showGesLock:.15];
    
    
    
    return YES;
}

- (void)showGesLock:(float)duration{
    
    if (![UserDefaultsGet(KHaveGesturePsd)boolValue]) {
        return;
    }
    
    if (!self.LockView) {
        self.LockView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
        self.LockView.backgroundColor = [UIColor colorWithWhite:0.05 alpha:1];
        self.lockStatusLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, KNavigationBarHeight, KScreenWidth - 40, 80)];
        self.lockStatusLabel.numberOfLines = 0;
        [self.LockView addSubview:self.lockStatusLabel];
        self.lockStatusLabel.font = [UIFont systemFontOfSize:29];
        
        self.lockStatusLabel.textColor = [UIColor whiteColor];
        self.lockStatusLabel.textAlignment = NSTextAlignmentCenter;
        if ([UserDefaultsGet(KHaveFingerprint)boolValue]) {
           
            UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
            dismissButton.frame = CGRectMake(KScreenWidth - 140, KScreenHeight - 60, 120, 40);
            [self.LockView addSubview:dismissButton];
            [dismissButton setTitle:@"使用指纹解锁" forState:UIControlStateNormal];
            [dismissButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            dismissButton.titleLabel.font = [UIFont systemFontOfSize:19];
            [dismissButton addTarget:self action:@selector(evaluatePolicy) forControlEvents:UIControlEventTouchUpInside];

            
        }
        
        
        
        self.LockView.transform = CGAffineTransformMakeTranslation(0,KScreenHeight);
        
    }

        

        
        
        self.lockStatusLabel.text = @"请绘制您解锁图案";
        //Give me a Star: https://github.com/i36lib/DBGuestureLock/
        DBGuestureLock *lock = [DBGuestureLock lockOnView:[UIApplication sharedApplication].keyWindow delegate:self];
        [self.LockView addSubview:lock];
        [[UIApplication sharedApplication].keyWindow addSubview:self.LockView];
        
        
        [UIView animateWithDuration:duration animations:^{
            self.LockView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            
            if (duration > 0) {
                if ([UserDefaultsGet(KHaveFingerprint) boolValue]) {
                    [self evaluatePolicy];
                }
            }
            
            
        }];
    
    
    
}

- (void)hiddenLockView{
    
    
    [UIView animateWithDuration:.35 animations:^{
        
        self.LockView.transform = CGAffineTransformMakeTranslation(0,KScreenHeight);
        
    } completion:^(BOOL finished) {
        
        for (UIView *view in  self.LockView.subviews) {
            
            if ([view isKindOfClass:[DBGuestureLock class]]) {
                [view removeFromSuperview];
            }
        }
    }];
    
    
}
#pragma mark -- DBGuestureLock Delegate
-(void)guestureLock:(DBGuestureLock *)lock didGetCorrectPswd:(NSString *)password {
    //NSLog(@"Pa、ssword correct: %@", password);
    if (lock.firstTimeSetupPassword && ![lock.firstTimeSetupPassword isEqualToString:DBFirstTimeSetupPassword]) {
      
        
    } else {
        NSLog(@"login success");
        self.lockStatusLabel.text = @"解锁成功";
        [self hiddenLockView];
        
    }
    

}




-(void)guestureLock:(DBGuestureLock *)lock didGetIncorrectPswd:(NSString *)password {
    //NSLog(@"Password incorrect: %@", password);
    if (![lock.firstTimeSetupPassword isEqualToString:DBFirstTimeSetupPassword]) {
        NSLog(@"Error: password not equal to first setup!");
     self.lockStatusLabel.text = @"手势错误";
    } else {
        NSLog(@"login failed");
        self.lockStatusLabel.text = @"手势错误";
    }
}
-(void)guestureLock:(DBGuestureLock *)lock didSetPassword:(NSString*)password{
    
    
}

- (void)evaluatePolicy{
    
    LAContext *context = [[LAContext alloc] init];
    __block  NSString *msg;
    
    // show the authentication UI with our reason string
    [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:NSLocalizedString(@"验证指纹解锁您的APP", nil) reply:
     ^(BOOL success, NSError *authenticationError) {
         if (success) {
             
            
             msg =[NSString stringWithFormat:NSLocalizedString(@"验证成功", nil)];
             dispatch_sync(dispatch_get_main_queue(), ^{
                 [self hiddenLockView];
             });
             
             
         } else {
             msg = [NSString stringWithFormat:NSLocalizedString(@"验证错误", nil), authenticationError.localizedDescription];
         }
         
     }];
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self showGesLock:0.0];
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(tik) userInfo:nil repeats:YES];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    if ([UserDefaultsGet(KHaveFingerprint)boolValue]) {
        [self evaluatePolicy];
    }
    
    

    
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



- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if (url != nil) {
        NSString *path = [url absoluteString];
        NSMutableString *string = [[NSMutableString alloc] initWithString:path];
        
        
        if ([path hasPrefix:@"file:///private"]) {
            [string replaceOccurrencesOfString:@"file:///private" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, path.length)];
            NSLog(@"文件的路径%@",string);
            
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:KGetNewFile object:string];
        
        UINavigationController *navi = (UINavigationController *) self.mainTabBar.viewControllers.lastObject;
        if (navi.viewControllers.count > 1) {
            
            [navi popToRootViewControllerAnimated:YES];
            
        }
    }
    return YES;
}


- (void)tik{
    
    if ([[UIApplication sharedApplication] backgroundTimeRemaining] < 61.0) {
        

        
        [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
        
                [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
        
        NSString *path = [[NSBundle mainBundle]pathForResource:@"silent" ofType:@"mp3"];
        NSURL *url = [NSURL URLWithString:path];
        AVAudioPlayer *player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
        [player prepareToPlay];

        player.numberOfLoops = -1; //设置音乐播放次数  -1为一直循环
        [player play];

    
    }
 

    

}






@end
