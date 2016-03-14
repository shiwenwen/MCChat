//
//  UICommons.h
//  WeiBoS
//
//  Created by mac on 15/10/9.
//  Copyright © 2015年 sww. All rights reserved.
//

#ifndef UICommons_h
#define UICommons_h

#define KScreenHeight [UIScreen mainScreen].bounds.size.height
#define KScreenWidth [UIScreen mainScreen].bounds.size.width
#define KTabBarHeight 49
#define KNavigationBarHeight 64
#define proportation  (KScreenWidth / 375)
#define UserDefaultsGet(a)  [[NSUserDefaults standardUserDefaults] objectForKey:a]
#define UserDefaultsSet(a,b) [[NSUserDefaults standardUserDefaults] setObject:a forKey:b]
#define MyNickName @"myNickName"
#define KHaveGesturePsd @"haveGesturePsd"
#define KHaveFingerprint @"haveFingerprint"
#define KGetNewFile @"getNewFile"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
// 颜色(RGB)
#define RGBColor(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RGBACOLOR(r, g, b, a)   [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

// 常用颜色
#define k99Gray [UIColor colorWithRed:153.f/255 green:153.f/255 blue:153.f/255 alpha:1.00f]
#define kb5Gray [UIColor colorWithRed:181.f/255 green:181.f/255 blue:181.f/255 alpha:1.00f]
#define kd9Gray [UIColor colorWithRed:217.f/255 green:217.f/255 blue:217.f/255 alpha:1.00f]
#define klineGray [UIColor colorWithRed:208.f/255 green:208.f/255 blue:208.f/255 alpha:1.00f]
#define kLightBlue [UIColor colorWithRed:9.f/255 green:150.f/255 blue:255.f/255 alpha:1.00f]
#define kBgGray [UIColor colorWithRed:243.f/255 green:242.f/255 blue:241.f/255 alpha:1.00f]
#define KMoneyRed [UIColor colorWithRed:0.961 green:0.271 blue:0.278 alpha:1.000]

#define BlueFontColor [UIColor colorWithRed:38.f/255 green:143.f/255 blue:254.f/255 alpha:1.0]
//社会化分享

#define UMENG_KEY  @"56e682aee0f55a65e5000e0c"
//新浪
#define SINA_APPKEY @"3914267365"
#define SINA_APPSECRET @"0b98291d8c114162bdd1b984aa885621"
#define SINA_RedirectURL @"http://sns.whalecloud.com/sina2/callback"
#endif /* UICommons_h */
