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
#import "WXLabel.h"
#import "MBProgressHUD.h"
typedef void(^VoiceBlock)( NSURL * _Nonnull url, NSData * _Nullable data,UIImageView *_Nullable imageView);
typedef void(^FileBlock)(FileModel *_Nullable model);
@interface MyChatCell : UITableViewCell<WXLabelDelegate>{
    UITapGestureRecognizer *_tap;
    UIProgressView *_progressView;
}

@property (nonatomic,strong,readonly,nullable)UILabel *timeLabel;
@property (nonatomic,strong,readonly,nullable)ZoomImageView *leftHeaderView;
@property (nonatomic,strong,readonly,nullable)ZoomImageView *rightHeaderView;
@property (nonatomic,strong,readonly,nullable)UIImageView *leftBgView;
@property (nonatomic,strong,readonly,nullable)UIImageView *rightBgView;
@property (nonatomic,strong,readonly,nullable)WXLabel *leftChatLabel;
@property (nonatomic,strong,readonly,nullable)WXLabel *rightChatLabel;
@property (nonatomic,strong,readonly,nullable)ZoomImageView *getImageView;
@property (nonatomic,strong,readonly,nullable)ZoomImageView *postImageView;
@property (nonatomic,strong,readonly,nullable)UIImageView *getVoiceView;
@property (nonatomic,strong,readonly,nullable)UIImageView *postVoiceView;
@property (nonatomic,strong,nullable,readonly)UILabel *leftTimeSecondLabel;
@property (nonatomic,strong,nullable,readonly)UILabel *rightTimeSecondLabel;
@property (nonatomic,strong,readonly,nullable)UIImageView *leftCorner;
@property (nonatomic,strong,nullable)UILabel *NickNameLabel;
@property (nonatomic,strong,nullable)UILabel *voiceTime;
@property (nonatomic,strong,nullable)ChatItem *model;
@property (nonatomic,strong,nullable)NSURL *dataPath;
@property (nonnull,copy)VoiceBlock voiceBlock;

//文件类型的cell
@property(nonatomic,strong,nullable)UILabel *fileNameLabel1;
@property(nonatomic,strong,nullable)UILabel *fileSizeLabel1;
@property(nonatomic,strong,nullable)UIImageView* fileLogo1;
@property (nonatomic,strong,nullable)UIView *fileBackView1;

@property(nonatomic,strong,nullable)UILabel *fileNameLabel2;
@property(nonatomic,strong,nullable)UILabel *fileSizeLabel2;
@property(nonatomic,strong,nullable)UIImageView* fileLogo2;
@property (nonatomic,strong,nullable)UIView *fileBackView2;

@property (nonatomic,copy,nullable)FileBlock fileBlock;

//进度
@property (nonatomic,strong,nullable)UIProgressView *progressView;
@property (nonatomic,strong,nullable)MBProgressHUD *HUD;
@end
