//
//  TitleCell.m
//  WWPageController
//
//  Created by 石文文 on 16/2/4.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import "TitleCell.h"
#import "UIViewExt.h"
@implementation TitleCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI{
    
    _titleLabel = [[UILabel alloc]init];
    _titleLabel.layer.cornerRadius = 10;
//    _titleLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    _titleLabel.layer.masksToBounds = YES;
//    _titleLabel.layer.borderWidth = .5;
    
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:_titleLabel];
    
    
}
- (void)setTitle:(NSString *)title{
    _title = title;
    
    [self setNeedsLayout];
}
- (void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
    
    if (_isSelected) {
        _titleLabel.font = [UIFont boldSystemFontOfSize:KTextFont + 4];
        
    }else{
        _titleLabel.font = [UIFont systemFontOfSize:KTextFont];
        
    }
}
- (void)layoutSubviews{
    [super layoutSubviews];
    _titleLabel.frame = CGRectMake(5, 20, self.width - 10, self.height - 20);
    
}
@end
