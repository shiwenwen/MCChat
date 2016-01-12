//
//  MyChatCell.m
//  MCChat
//
//  Created by 石文文 on 16/1/12.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import "MyChatCell.h"
#define HEIGHT [UIScreen mainScreen].bounds.size.height
#define WIDTH [UIScreen mainScreen].bounds.size.width
@implementation MyChatCell

- (void)awakeFromNib {
    
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //左边头像
        _leftHeaderView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 50, 50)];
        _leftHeaderView.layer.cornerRadius = 25.0;
        _leftHeaderView.layer.borderColor = [UIColor grayColor].CGColor;
        _leftHeaderView.layer.borderWidth = .5;
        
        //右边头像
        _rightHeaderView = [[UIImageView alloc]initWithFrame:CGRectMake(WIDTH - 55, 5, 50, 50)];
        _rightHeaderView.layer.cornerRadius = 25.0;
        _rightHeaderView.layer.borderColor = [UIColor grayColor].CGColor;
        _rightHeaderView.layer.borderWidth = .5;
        
        [self.contentView addSubview:_leftHeaderView];
        [self.contentView addSubview:_leftHeaderView];
        
        //对话框背景
        _leftBgView = [[UIImageView alloc]init];
        _rightBgView.userInteractionEnabled = YES;
        
        _rightBgView = [[UIImageView alloc]init];
        _rightBgView.userInteractionEnabled = YES;
        [self.contentView addSubview:_leftBgView];
        [self.contentView addSubview:_rightBgView];
        
        
    }
    return self;
}

- (void)setModel:(ChatItem *)model{
    _model = model;
    
    if (self.isSelf) {
        
        self.rightHeaderView.image = [UIImage imageNamed:@"无头像"];
        if (_model.content) {
            
            
            
        }
        
        
        
    }
    
    
}


@synthesize rightChatLabel = _rightChatLabel;
-(WPHotspotLabel *)rightChatLabel{
    
    if (!_rightChatLabel) {
        
        _rightChatLabel = [[WPHotspotLabel alloc]init];
        [self.contentView addSubview:_rightChatLabel];
        
    }
    
    return _rightChatLabel;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

 
}

@end
