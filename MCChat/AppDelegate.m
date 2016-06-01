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
#import "FileDetailViewController.h"
#import "FileManagerViewController.h"
#import "FileModel.h"
#import "UMSocial.h"



#import "WeiboSDK.h"

#import "UMSocialSinaSSOHandler.h"
#import "UMSocialYiXinHandler.h"
#import "UMSocialWechatHandler.h"

@interface AppDelegate ()<DBGuestureLockDelegate,UIAlertViewDelegate>{
    
   NSInteger _errorIndex;
    NSInteger _errorTime;
    NSInteger _interval;
    NSString *_touchType;
    
}
@property (nonatomic,strong)UIView *LockView;
@property (nonatomic,strong)UILabel *lockStatusLabel;
@property (nonatomic,strong)MainTabBarViewController *mainTabBar;
@property (nonatomic,copy)NSString *getFilePath;
@property (nonatomic,strong)UIView *shade;
@property (nonatomic,strong)DBGuestureLock *lock;
@property (nonatomic,strong)UIButton *dismissButton;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
   /*
    // Override point for customization after application launch.
    桌面icon plist 的文件重压效果可以使用系统的然后进行调取使用Type 当然也可以进行自定义还可以将其进行本地化静态处理存储为一个
    // 系统提供的部分的类型 直接可以使用  并且附带   icon
    UIApplicationShortcutIconTypeCompose,
    UIApplicationShortcutIconTypePlay,
    UIApplicationShortcutIconTypePause,
    UIApplicationShortcutIconTypeAdd,
    UIApplicationShortcutIconTypeLocation,
    UIApplicationShortcutIconTypeSearch,
    UIApplicationShortcutIconTypeShare
*/

    if ([[UIDevice currentDevice].systemVersion floatValue] > 9.0) {
        
        UIApplicationShortcutItem
        *item1 = [[
                   UIApplicationShortcutItem
                   alloc
                   ]
                  initWithType
                  :
                  @"TYShortcut1"
                  localizedTitle
                  :
                  @"添加"
                  localizedSubtitle
                  :
                  @"搜索附近设备"
                  icon
                  :[
                    UIApplicationShortcutIcon
                    iconWithType:UIApplicationShortcutIconTypeAdd] userInfo:nil];
        
        UIApplicationShortcutItem
        *item2 = [[
                   UIApplicationShortcutItem
                   alloc
                   ]
                  initWithType
                  :
                  @"TYShortcut2"
                  localizedTitle
                  :
                  @"打开天线"
                  localizedSubtitle
                  :
                  @"让他人搜索到你"
                  icon
                  :[
                    UIApplicationShortcutIcon
                    iconWithType:UIApplicationShortcutIconTypeShare] userInfo:nil];
        
        UIApplicationShortcutItem
        *item3 = [[
                   UIApplicationShortcutItem
                   alloc
                   ]
                  initWithType
                  :
                  @"TYShortcut3"
                  localizedTitle
                  :
                  @"文件管理"
                  localizedSubtitle
                  :
                  @"管理和查看你的文件"
                  icon
                  :[
                    UIApplicationShortcutIcon
                    iconWithType:UIApplicationShortcutIconTypeCloud] userInfo:nil];
        // 这里是可以自定义的效果  可以自己设置  Icon
        
        UIApplicationShortcutItem
        * item4 = [[
                    UIApplicationShortcutItem
                    alloc
                    ]
                   initWithType
                   :
                   @"TYShortcut4"
                   localizedTitle
                   :
                   @"TYCustom"
                   localizedSubtitle
                   :
                   @"来点一下!(自定义)"
                   icon
                   :[
                     UIApplicationShortcutIcon
                     iconWithTemplateImageName:@"ToolViewEmotion"] userInfo:nil];
        
        [[UIApplication sharedApplication] setShortcutItems: @[item1, item2, item3 ]];


    
    }
    
  
    
    
    
    
    
    
    NSLog(@"NSHomeDirectory == %@",NSHomeDirectory());
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
//    self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:[[RootViewController alloc]init]];
    self.mainTabBar = [[MainTabBarViewController alloc]init];
    self.window.rootViewController = self.mainTabBar;
    ChatViewController *chat = [[ChatViewController alloc]init];
    

    chat.tabVC = _mainTabBar;
    _mainTabBar.chatVC = chat;
    UINavigationController *naviC = [[UINavigationController alloc]initWithRootViewController:chat];
    
    _mainTabBar.viewControllers = @[naviC];

    
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
    
    
    
//----手势锁
    [self showGesLock:.15];
    
//-----社会化分享
    //友盟
    [UMSocialData setAppKey:UMENG_KEY];
    
//    [UMSocialData openLog:YES];
    
    //设置微信AppId，设置分享url，默认使用友盟的网址
//    [UMSocialWechatHandler setWXAppId:@"wxdc1e388c3822c80b" appSecret:@"a393c1527aaccb95f3a4c88d6d1455f6" url:@"http://www.umeng.com/social"];
    
    // 打开新浪微博的SSO开关

    [UMSocialSinaSSOHandler openNewSinaSSOWithAppKey:SINA_APPKEY
                                              secret:SINA_APPSECRET
                                         RedirectURL:SINA_RedirectURL];
    
    //设置易信Appkey和分享url地址
    [UMSocialYixinHandler setYixinAppKey:YINXIN_APPKey url:@"http://open.yixin.im/my"];
    
    //设置微信AppId、appSecret，分享url
    [UMSocialWechatHandler setWXAppId:WeiChat_APPId appSecret:WeiChat_APPSecret url:@"https://open.weixin.qq.com"];
    
    return YES;
}

- (void)showGesLock:(float)duration{
    
    if (![UserDefaultsGet(KHaveGesturePsd)boolValue]) {
        return;
    }
    
    if (!self.LockView) {
        self.LockView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
        self.LockView.backgroundColor = [UIColor colorWithRed:0.308 green:0.730 blue:1.000 alpha:1.000];
        self.lockStatusLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, KNavigationBarHeight-20, KScreenWidth - 30, 120)];
        self.lockStatusLabel.numberOfLines = 0;
        self.lockStatusLabel.font = [UIFont fontWithName:@"DB LCD Temp" size:27];
        [self.LockView addSubview:self.lockStatusLabel];
//        self.lockStatusLabel.font = [UIFont systemFontOfSize:27];
        
        self.lockStatusLabel.textColor = [UIColor whiteColor];
        self.lockStatusLabel.textAlignment = NSTextAlignmentCenter;
       
        self.shade = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 70)];
        
        
        self.LockView.transform = CGAffineTransformMakeTranslation(0,KScreenHeight);
        
    }

    if (!_dismissButton) {
        
        _dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _dismissButton.frame = CGRectMake(KScreenWidth - 140, KScreenHeight - 60, 120, 40);
        [self.LockView addSubview:_dismissButton];
        [_dismissButton setTitle:@"使用指纹解锁" forState:UIControlStateNormal];
        [_dismissButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _dismissButton.titleLabel.font = [UIFont systemFontOfSize:19];
        [_dismissButton addTarget:self action:@selector(evaluatePolicy) forControlEvents:UIControlEventTouchUpInside];
        
        
    }
    if ([UserDefaultsGet(KHaveFingerprint)boolValue]) {
        _dismissButton.hidden = NO;
    }else{
        _dismissButton.hidden = YES;
    }

    

        //Give me a Star: https://github.com/i36lib/DBGuestureLock/
    
        _lock = [DBGuestureLock lockOnView:[UIApplication sharedApplication].keyWindow delegate:self];
        [self.LockView addSubview:_lock];
        [[UIApplication sharedApplication].keyWindow addSubview:self.LockView];
    
    
        self.shade.hidden = YES;
        [[UIApplication sharedApplication].keyWindow addSubview:self.shade];
    
        [UIView animateWithDuration:duration animations:^{
            self.LockView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            
            if (duration > 0) {
                if ([UserDefaultsGet(KHaveFingerprint) boolValue]) {
                    [self evaluatePolicy];
                }
            }
            
            
        }];
    
    if ([UserDefaultsGet(@"errorIndex") integerValue] == 0 || ([[NSDate date] timeIntervalSince1970] - [UserDefaultsGet(@"errorTime")integerValue] > 5*60)) {
        self.lockStatusLabel.text = @"请绘制您解锁图案";
        UserDefaultsSet(@(0), @"errorIndex");
        self.shade.hidden = YES;
    }else {
        
        _errorTime = [UserDefaultsGet(@"errorTime") integerValue];
        _interval = 60 *5 - ( [[NSDate date] timeIntervalSince1970] - _errorTime);
        self.shade.hidden = NO;
        if ([UserDefaultsGet(KHaveFingerprint)boolValue]) {
            self.lockStatusLabel.text =  [NSString stringWithFormat:@"解锁错误次数过多，请稍后重试或使用指纹解锁\n%02ld:%02ld",_interval/60,_interval%60];
        }else{
            
            self.lockStatusLabel.text
            =  [NSString stringWithFormat:@"解锁错误次数过多，请稍后重试\n%02ld:%02ld",_interval/60,_interval%60];
        }
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countdown:) userInfo:nil repeats:YES];
        
        
    }
    
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
        self.shade.hidden = YES;
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"errorTime"];
        
        _errorIndex =0;
        UserDefaultsSet(@(_errorIndex), @"errorIndex");
        [self hiddenLockView];
        
    }
    

}




-(void)guestureLock:(DBGuestureLock *)lock didGetIncorrectPswd:(NSString *)password {
    //NSLog(@"Password incorrect: %@", password);
    
    if (![lock.firstTimeSetupPassword isEqualToString:DBFirstTimeSetupPassword]) {
        NSLog(@"Error: password not equal to first setup!");
     self.lockStatusLabel.text = @"手势错误";
        _errorIndex ++;
        if (_errorIndex > 4) {
            self.shade.hidden = NO;
            self.LockView.userInteractionEnabled = NO;
            
            _errorTime = [[NSDate date] timeIntervalSince1970];
            _interval = 60 *5 - ( [[NSDate date] timeIntervalSince1970] - _errorTime);
            if ([UserDefaultsGet(KHaveFingerprint)boolValue]) {
                self.lockStatusLabel.text =  [NSString stringWithFormat:@"解锁错误次数过多，请稍后重试或使用指纹解锁\n%02ld:%02ld",_interval/60,_interval%60];
            }else{
                
                self.lockStatusLabel.text
                =  [NSString stringWithFormat:@"解锁错误次数过多，请稍后重试\n%02ld:%02ld",_interval/60,_interval%60];
            }
            UserDefaultsSet(@(_errorTime), @"errorTime");
            UserDefaultsSet(@(_errorIndex), @"errorIndex");
            [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countdown:) userInfo:nil repeats:YES];
            

        }
    } else {
        NSLog(@"login failed");
        self.lockStatusLabel.text = @"手势错误";
    }
}
- (void)countdown:(NSTimer *)timer{
    
    _interval = 60 *5 - ( [[NSDate date] timeIntervalSince1970] - _errorTime);

    if ([UserDefaultsGet(KHaveFingerprint)boolValue]) {
       self.lockStatusLabel.text =  [NSString stringWithFormat:@"解锁错误次数过多，请稍后重试或使用指纹解锁\n%02ld:%02ld",_interval/60,_interval%60];
    }else{
    
      self.lockStatusLabel.text
        =  [NSString stringWithFormat:@"解锁错误次数过多，请稍后重试\n%02ld:%02ld",_interval/60,_interval%60];
    }
    if (_interval <= 0) {
        
        [timer invalidate];
         self.shade.hidden = YES;
        self.lockStatusLabel.text = @"请绘制您解锁图案";
        self.LockView.userInteractionEnabled = YES;
         UserDefaultsSet(@(0), @"errorIndex");
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"errorIndex"];

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
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"errorTime"];
                 [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"errorIndex"];
                 _errorIndex =0;
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

       [UMSocialSnsService  applicationDidBecomeActive];
    

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
    NSString *schemeStr = [url scheme];
    
    BOOL result = [UMSocialSnsService handleOpenURL:url];
    if (result == FALSE) {
            //调用其他SDK，例如支付宝SDK等
        
        //文件
        if (url != nil) {
            NSString *path = [url absoluteString];
            
            
            path = [path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSMutableString *string = [[NSMutableString alloc] initWithString:path];
            
            
            if ([path hasPrefix:@"file:///private"]) {
                [string replaceOccurrencesOfString:@"file:///private" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, path.length)];
                NSLog(@"文件的路径%@",string);
                
            }
            
            
            self.getFilePath = string;
            NSRange range = [string rangeOfString:@"/" options:NSBackwardsSearch];
            NSString *name = @"未知";
            if (range.location != NSNotFound) {
                name = [string substringFromIndex:range.location + 1];
            }
            
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"新文件" message:name delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"发送",@"查看", nil];
            [alert show];
        }
        return YES;
        
  
        
    }


    return result;
    
    
    
    
   
}
#pragma mark - 3D Touch
-(void) application:(UIApplication*)application performActionForShortcutItem:(UIApplicationShortcutItem*)shortcutItem completionHandler:(void(^)(BOOL))completionHandler{
    
    _touchType = shortcutItem.type;
//    NSLog(@"%@",shortcutItem.type);
//    /*
//     在此处添加需要跳转到的页面如果不写默认进入程序正常开启页面（不添加3D Touch的效果）
//     */
    
    MainTabBarViewController *main = (MainTabBarViewController *)self.window.rootViewController;
    ChatViewController *chat = main.chatVC;
//    __weak typeof(chat)weakChat;
    if([_touchType isEqualToString:@"TYShortcut1"]) {
    
        [chat performSelector:@selector(lookOtherDevice) withObject:nil afterDelay:.5];
   
        
    }else if([_touchType isEqualToString:@"TYShortcut2"]){
        
      [chat performSelector:@selector(showSelf) withObject:nil afterDelay:.5];
    }else if([_touchType isEqualToString:@"TYShortcut3"]){
        
     [chat performSelector:@selector(showFileManager) withObject:nil afterDelay:.5];
        
    } else if([_touchType isEqualToString:@"TYShortcut4"]){
        
    }
    
//    return;
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
#pragma mark - alrtViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        
    }else if (buttonIndex == 1){
         [[NSNotificationCenter defaultCenter]postNotificationName:KGetNewFile object:[self getFileModelWithPath:self.getFilePath]];
        UINavigationController *navi = (UINavigationController *)self.mainTabBar.viewControllers.lastObject;
        if (navi.viewControllers > 0) {
            
            [navi popToRootViewControllerAnimated:YES];
            
        }
        
    }else{
//         [[NSNotificationCenter defaultCenter]postNotificationName:KGetNewFile object:[self getFileModelWithPath:self.getFilePath]];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"getFileSuccess" object:nil];
         UINavigationController *navi = (UINavigationController *)self.mainTabBar.viewControllers.lastObject;
        FileDetailViewController *fileDetail = [[FileDetailViewController alloc]init];
        fileDetail.model= [self getFileModelWithPath:self.getFilePath];
        [navi pushViewController:fileDetail animated:YES];
        
    }
    
    
}

- (FileModel *)getFileModelWithPath:(NSString *)path{
    
    NSDictionary *fileAttr =  [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    
    NSLog(@"fileAttr ==== %@",fileAttr);
    
    /*
     fileAttr ==== {
     NSFileCreationDate = "2016-03-01 10:46:27 +0000";
     NSFileExtensionHidden = 0;
     NSFileGroupOwnerAccountID = 501;
     NSFileGroupOwnerAccountName = mobile;
     NSFileModificationDate = "2016-03-01 10:46:27 +0000";
     NSFileOwnerAccountID = 501;
     NSFileOwnerAccountName = mobile;
     NSFilePosixPermissions = 420;
     NSFileProtectionKey = NSFileProtectionCompleteUntilFirstUserAuthentication;
     NSFileReferenceCount = 1;
     NSFileSize = 16220;
     NSFileSystemFileNumber = 17553603;
     NSFileSystemNumber = 16777220;
     NSFileType = NSFileTypeRegular;
     }
     */
    
    NSString *fileSize = [self fileSizeTransform:[fileAttr[@"NSFileSize"] floatValue]];
    
    NSDate *modificationDate = fileAttr[@"NSFileModificationDate"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *dateStr = [formatter stringFromDate:modificationDate];
    
    NSRange range = [path rangeOfString:@"." options:NSBackwardsSearch];
    
    NSString *extension;
    
    if (range.location != NSNotFound) {
        
        extension = [path substringFromIndex:range.location + 1];
        
        
    }
    
    FileType type = other;
    
    /*
     Word,//doc,docx
     Excel,//xls,xlsx
     PowerPoint,//ppt,pptx
     music,//mp3,wma,mac,aac,wav...
     video,//RMVB、WMV、ASF、AVI、3GP、MPG、MKV、MP4、OGM、MOV、MPEG2、MPEG4
     image,//GIF、JPEG、BMP、TIF、JPG、PCD、QTI、QTF、TIFF
     txt,
     zip,//rar,zip,tar,cab,uue,jar,iso,z,7-zip,ace,lzh,arj,gzip,bz2
     other
     */
    extension = [extension lowercaseString];
    if ([extension isEqualToString:@"doc"]||[extension isEqualToString:@"docx"]||[extension isEqualToString:@"pages"]) {
        type = Word;
    }else if ([extension isEqualToString:@"xls"]||[extension isEqualToString:@"xlsx"]||[extension isEqualToString:@"numbers"]){
        
        type = Excel;
        
    }else if ([extension isEqualToString:@"ppt"]||[extension isEqualToString:@"pptx"]||[extension isEqualToString:@"keynote"]){
        
        type = PowerPoint;
    }
    else if ([extension isEqualToString:@"mp3"]||[extension isEqualToString:@"wma"]||[extension isEqualToString:@"mac"]||[extension isEqualToString:@"aac"]||[extension isEqualToString:@"wav"]){
        
        
        type = music;
        
    }else if ([extension isEqualToString:@"rmvb"]||[extension isEqualToString:@"wmv"]||[extension isEqualToString:@"asf"]||[extension isEqualToString:@"avi"]||[extension isEqualToString:@"3gp"]||[extension isEqualToString:@"mpg"]||[extension isEqualToString:@"mkv"]||[extension isEqualToString:@"mp4"]||[extension isEqualToString:@"ogm"]||[extension isEqualToString:@"mov"]||[extension isEqualToString:@"mpeg2"]||[extension isEqualToString:@"mpeg4"]){
        
        type = video;
        
    }else if ([extension isEqualToString:@"gif"]||[extension isEqualToString:@"jpeg"]||[extension isEqualToString:@"bmp"]||[extension isEqualToString:@"tif"]||[extension isEqualToString:@"jpg"]||[extension isEqualToString:@"pcd"]||[extension isEqualToString:@"qti"]||[extension isEqualToString:@"qtf"]||[extension isEqualToString:@"tiff"]){
        
        type = image;
        
    }else if ([extension isEqualToString:@"rar"]||[extension isEqualToString:@"zip"]||[extension isEqualToString:@"tar"]||[extension isEqualToString:@"cab"]||[extension isEqualToString:@"uue"]||[extension isEqualToString:@"jar"]||[extension isEqualToString:@"iso"]||[extension isEqualToString:@"z"]||[extension isEqualToString:@"7-zip"]||[extension isEqualToString:@"gzip"]||[extension isEqualToString:@"bz2"]){
        
        type = zip;
    }else if ([extension isEqualToString:@"pdf"]){
        
        type = pdf;
    }else if ([extension isEqualToString:@"txt"]){
        
        type = txt;
    }
    NSString *name = @"未知";
    range = [path rangeOfString:@"/" options:NSBackwardsSearch];
    if (range.location != NSNotFound) {
        name = [path substringFromIndex:range.location + 1];
    }
    
    FileModel *model = [[FileModel alloc]initWithName:name Detail:dateStr size:fileSize FileType:type Path:self.getFilePath];
    
    model.realitySize = [fileAttr[@"NSFileSize"] doubleValue];
    model.date = modificationDate;
    return model;
    
}
#pragma mark -- unicode转中文
+ (NSString *)replaceUnicode:(NSString *)unicodeStr
{
    
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u"withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"" withString:@"\\"];
    NSString *tempStr3 = [[@"" stringByAppendingString:tempStr2] stringByAppendingString:@""];
                          NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
                          NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                                                mutabilityOption:NSPropertyListImmutable
                                                                                          format:NULL
                                                                                errorDescription:NULL];
                          NSLog(@"%@",returnStr);
                          return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
                          }
#pragma mark -- 尺寸计算
- (NSString *)fileSizeTransform:(CGFloat )originalSize{
    
    if (originalSize / (1000 * 1000) < 1) {
        
        return [NSString stringWithFormat:@"%.2fKB",originalSize / 1000.0];
    }else if (originalSize / (1000 * 1000) >= 1){
        
        
        return [NSString stringWithFormat:@"%.2fMB",originalSize / (1000.0 * 1000.0)];
        
        
    }else{
        
        return [NSString stringWithFormat:@"%.2fGB",originalSize / (1000.0 * 1000 * 1000)];
    }
    
}


@end
