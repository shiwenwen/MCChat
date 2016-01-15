//
//  MyChatCell.h
//  MCChat
//
//  Created by 石文文 on 16/1/12.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WPHotspotLabel.h"
#import "ChatItem.h"
#import "ZoomImageView.h"
@interface MyChatCell : UITableViewCell
@property (nonatomic,strong,readonly)UILabel *timeLabel;
@property (nonatomic,strong,readonly)UIImageView *leftHeaderView;
@property (nonatomic,strong,readonly)UIImageView *rightHeaderView;
@property (nonatomic,strong,readonly)UIImageView *leftBgView;
@property (nonatomic,strong,readonly)UIImageView *rightBgView;
@property (nonatomic,strong,readonly)WPHotspotLabel *leftChatLabel;
@property (nonatomic,strong,readonly)WPHotspotLabel *rightChatLabel;
@property (nonatomic,strong,readonly)ZoomImageView *getImageView;
@property (nonatomic,strong,readonly)ZoomImageView *postImageView;
@property (nonatomic,strong,readonly)UIImageView *getVoiceView;
@property (nonatomic,strong,readonly)UIImageView *postVoiceView;
@property (nonatomic,strong)ChatItem *model;
@end
