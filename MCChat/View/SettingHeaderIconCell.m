//
//  SettingHeaderIconCell.m
//  MCChat
//
//  Created by 石文文 on 16/2/15.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import "SettingHeaderIconCell.h"

@implementation SettingHeaderIconCell

- (void)awakeFromNib {
    self.headerIcon.layer.cornerRadius = 5;
    self.headerIcon.layer.masksToBounds = YES;
    self.headerIcon.userInteractionEnabled = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
