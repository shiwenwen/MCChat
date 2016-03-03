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
#endif /* UICommons_h */
