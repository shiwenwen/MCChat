//
//  ChangeNickNameViewController.h
//  MCChat
//
//  Created by 石文文 on 16/2/15.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ChangeBlock)(NSString *name);
@interface ChangeNickNameViewController : UIViewController

@property (nonatomic,copy)ChangeBlock changeBlock;

@end
