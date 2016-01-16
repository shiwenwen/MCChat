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
typedef void(^VoiceBlock)( NSURL * _Nonnull url, NSData * _Nullable data,UIImageView *_Nullable imageView);
@interface MyChatCell : UITableViewCell{
    UITapGestureRecognizer *_tap;
    
}
@property (nonatomic,strong,readonly,nullable)UILabel *timeLabel;
@property (nonatomic,strong,readonly,nullable)UIImageView *leftHeaderView;
@property (nonatomic,strong,readonly,nullable)UIImageView *rightHeaderView;
@property (nonatomic,strong,readonly,nullable)UIImageView *leftBgView;
@property (nonatomic,strong,readonly,nullable)UIImageView *rightBgView;
@property (nonatomic,strong,readonly,nullable)WPHotspotLabel *leftChatLabel;
@property (nonatomic,strong,readonly,nullable)WPHotspotLabel *rightChatLabel;
@property (nonatomic,strong,readonly,nullable)ZoomImageView *getImageView;
@property (nonatomic,strong,readonly,nullable)ZoomImageView *postImageView;
@property (nonatomic,strong,readonly,nullable)UIImageView *getVoiceView;
@property (nonatomic,strong,readonly,nullable)UIImageView *postVoiceView;
@property (nonatomic,strong,nullable)UILabel *voiceTime;
@property (nonatomic,strong,nullable)ChatItem *model;
@property (nonatomic,strong,nullable)NSURL *dataPath;
@property (nonnull,copy)VoiceBlock voiceBlock;
@end