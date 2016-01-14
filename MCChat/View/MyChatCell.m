//
//  MyChatCell.m
//  MCChat
//
//  Created by 石文文 on 16/1/12.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import "MyChatCell.h"
#import "UIViewExt.h"
#import "NSDate+DateTools.h"
#define HEIGHT [UIScreen mainScreen].bounds.size.height
#define WIDTH [UIScreen mainScreen].bounds.size.width
@implementation MyChatCell

- (void)awakeFromNib {
    
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake((WIDTH - 150) / 2.0, 5, 150, 15)];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.backgroundColor = [UIColor colorWithWhite:0.268 alpha:1.000];
        _timeLabel.font = [UIFont systemFontOfSize:11];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.layer.cornerRadius = 2;
//        _timeLabel.layer.borderColor = [UIColor grayColor].CGColor;
//        _timeLabel.layer.borderWidth = 0.25;
        _timeLabel.layer.masksToBounds = YES;
        [self.contentView addSubview:_timeLabel];
        //毛玻璃
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        
            UIVisualEffectView *visualEffect = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
            
            visualEffect.frame = CGRectMake(0, 0, _timeLabel.width, _timeLabel.height);
            
            visualEffect.alpha = 0.5;
            
//            [_timeLabel addSubview:visualEffect];
 
            
        }
     
        //左边头像
        _leftHeaderView = [[UIImageView alloc]initWithFrame:CGRectMake(5, _timeLabel.bottom + 5, 45, 45)];
        _leftHeaderView.layer.cornerRadius = 45 * .5;
        _leftHeaderView.layer.borderColor = [UIColor grayColor].CGColor;
        _leftHeaderView.layer.borderWidth = .25;
        
        //右边头像
        _rightHeaderView = [[UIImageView alloc]initWithFrame:CGRectMake(WIDTH - 55, _timeLabel.bottom + 5, 45, 45)];
        _rightHeaderView.layer.cornerRadius = 45 * .5;
        _rightHeaderView.layer.borderColor = [UIColor grayColor].CGColor;
        _rightHeaderView.layer.borderWidth = .25;
        
        [self.contentView addSubview:_leftHeaderView];
        [self.contentView addSubview:_rightHeaderView];
        
        //对话框背景
        _leftBgView = [[UIImageView alloc]init];
        _leftBgView.userInteractionEnabled = YES;
        UIImage *leftImage = [UIImage imageNamed:@"ReceiverTextNodeBkg"];
        leftImage = [leftImage stretchableImageWithLeftCapWidth:leftImage.size.width * .5 topCapHeight:leftImage.size.height *.65];
        _leftBgView.image = leftImage;
        
        _rightBgView = [[UIImageView alloc]init];
        _rightBgView.userInteractionEnabled = YES;
        UIImage *rigthImage = [UIImage imageNamed:@"SenderTextNodeBkg"];
        rigthImage = [rigthImage stretchableImageWithLeftCapWidth:rigthImage.size.width * .5 topCapHeight:rigthImage.size.height *.65];
        _rightBgView.image = rigthImage;
        [self.contentView addSubview:_leftBgView];
        [self.contentView addSubview:_rightBgView];
        
        
    }
    return self;
}

- (void)setModel:(ChatItem *)model{
    _model = model;
    
    if (_model.isSelf) {
        
        self.rightHeaderView.image = [UIImage imageNamed:@"无头像"];
        self.rightHeaderView.hidden = NO;
        self.rightBgView.hidden = NO;
        self.leftHeaderView.hidden = YES;
        self.leftBgView.hidden = YES;
        if (_model.states == textStates) {
            
            self.rightChatLabel.hidden = NO;
            self.postImageView.hidden = YES;
            self.postVoiceView.hidden = YES;
            
            self.rightChatLabel.frame = CGRectMake(15,10,_model.textWidth,_model.textHeight);
            self.rightChatLabel.text = _model.content;
            self.rightBgView.frame = CGRectMake(self.rightHeaderView.left - _model.textWidth - 35,self.rightHeaderView.top, _model.textWidth + 30,_model.textHeight + 25);
            
        }else if (_model.states == picStates){
            
            self.rightChatLabel.hidden = YES;
            self.postImageView.hidden = NO;
            self.postVoiceView.hidden = YES;
            self.postImageView.image = _model.picImage;
            self.postImageView.frame = CGRectMake(10,5,_model.imageWidth,_model.imageHight);

            self.rightBgView.frame = CGRectMake(self.rightHeaderView.left - _model.imageWidth - 30,self.rightHeaderView.top, _model.imageWidth + 20,_model.imageHight + 20);
            
            
        }
        
    }else{
            
        self.leftHeaderView.image = [UIImage imageNamed:@"无头像"];
        self.leftHeaderView.hidden = NO;
        self.leftBgView.hidden = NO;
        self.rightHeaderView.hidden = YES;
        self.rightBgView.hidden = YES;
        
        if (_model.states == textStates) {
            self.leftChatLabel.hidden = NO;
            self.getImageView.hidden = YES;
            self.getImageView.hidden = YES;
            
            self.leftChatLabel.frame = CGRectMake(15,10,_model.textWidth,_model.textHeight);
            self.leftChatLabel.text = _model.content;
            self.leftBgView.frame = CGRectMake(self.leftHeaderView.right + 5,self.leftHeaderView.top, _model.textWidth + 30,_model.textHeight + 25);
        
        
        
        }else if (_model.states == picStates){
            
            self.leftChatLabel.hidden = YES;
            self.getImageView.hidden = NO;
            self.getVoiceView.hidden = YES;
            self.getImageView.image = _model.picImage;
            self.getImageView.frame = CGRectMake(10,5,_model.imageWidth,_model.imageHight);
            
            self.leftBgView.frame = CGRectMake(self.leftHeaderView.right + 5,self.leftHeaderView.top, _model.imageWidth + 20,_model.imageHight + 20);
            
            
        }
    
    
    
    }
    
    
}


@synthesize rightChatLabel = _rightChatLabel;
@synthesize postImageView = _postImageView;
@synthesize postVoiceView = _postVoiceView;
@synthesize leftChatLabel = _leftChatLabel;
@synthesize getImageView = _getImageView;
@synthesize getVoiceView = _getVoiceView;
//----------------------------------------------------------
-(WPHotspotLabel *)rightChatLabel{
    
    if (!_rightChatLabel) {
        
        _rightChatLabel = [[WPHotspotLabel alloc]init];
        _rightChatLabel.font = [UIFont systemFontOfSize:16];
        _rightChatLabel.numberOfLines = 0;
        [_rightBgView addSubview:_rightChatLabel];
        
    }
    
    return _rightChatLabel;
}
-(ZoomInImageView *)postImageView{
    
    if (!_postImageView) {
        _postImageView = [[ZoomInImageView alloc]init];
        _postImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_rightBgView addSubview:_postImageView];
    }
    return _postImageView;
}
-(UIImageView *)postVoiceView{
    if (!_postVoiceView) {
        _postVoiceView = [[UIImageView alloc]init];
        _postVoiceView.userInteractionEnabled = YES;

        [_rightBgView addSubview:_postVoiceView];
        
    }
    return _postVoiceView;
    
}
//-----------------------------------------------------------
-(WPHotspotLabel *)leftChatLabel{
    
    if (!_leftChatLabel) {
        
        _leftChatLabel = [[WPHotspotLabel alloc]init];
        _leftChatLabel.font = [UIFont systemFontOfSize:16];
        _leftChatLabel.numberOfLines = 0;
        [_leftBgView addSubview:_leftChatLabel];
        
    }
    
    return _leftChatLabel;
}
-(ZoomInImageView *)getImageView{
    
    if (!_getImageView) {
        _getImageView = [[ZoomInImageView alloc]init];
        _getImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_leftBgView addSubview:_getImageView];
    }
    return _getImageView;
}
-(UIImageView *)_getVoiceView{
    
    if (!_getVoiceView) {
        _getVoiceView = [[UIImageView alloc]init];
        _getVoiceView.userInteractionEnabled = YES;
        [_leftBgView addSubview:_getVoiceView];
        
    }
    return _postVoiceView;
    
}
- (void)layoutSubviews{
    
    [super layoutSubviews];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yy-MM-dd HH:mm:ss"];
    NSString *dateStr = [formatter stringFromDate:date];
    
    _timeLabel.text = dateStr;
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

 
}

@end
