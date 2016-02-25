//
//  SettingViewController.h
//  MCChat
//
//  Created by 石文文 on 16/2/15.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlueSessionManager.h"
@interface SettingViewController : UITableViewController
@property (nonatomic,strong)BlueSessionManager *sessionManager;
@property (nonatomic,copy)NSString *groupName;
@property (nonatomic,copy)NSArray *friendIcon;
@end
