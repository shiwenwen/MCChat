//
//  MainTabBarViewController.m
//  MCChat
//
//  Created by 石文文 on 16/1/14.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import "MainTabBarViewController.h"

@interface MainTabBarViewController ()

@end

@implementation MainTabBarViewController
- (BOOL)shouldAutorotate{
    return NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (UIView * view in self.tabBar.subviews) {
        
        [view removeFromSuperview];
        
    }
    
    ChatViewController *chat = [[ChatViewController alloc]init];
    chat.tabVC = self;
    self.chatVC = chat;
    UINavigationController *naviC = [[UINavigationController alloc]initWithRootViewController:chat];
    
    self.viewControllers = @[naviC];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
