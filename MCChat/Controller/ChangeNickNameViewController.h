//
//  ChangeNickNameViewController.h
//  MCChat
//
//  Created by 石文文 on 16/2/15.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ChangeStyle){
    nickName,
    groupName,
};
typedef void(^ChangeBlock)(NSString *name, ChangeStyle Style);
@interface ChangeNickNameViewController : UIViewController

@property (nonatomic,copy)ChangeBlock changeBlock;
@property (weak, nonatomic) IBOutlet UITextField *nickNameField;

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (nonatomic,assign)ChangeStyle style;
@property (nonatomic,copy)NSString *placehold;
@end
