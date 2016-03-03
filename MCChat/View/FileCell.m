//
//  FileCell.m
//  MCChat
//
//  Created by 石文文 on 16/3/1.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import "FileCell.h"

@implementation FileCell

- (void)awakeFromNib {
    self.logoImageView.layer.cornerRadius = 5;
    self.logoImageView.layer.masksToBounds = YES;
    
    
}
-(void)setModel:(FileModel *)model{
    
    _model = model;
    self.logoImageView.image = _model.logoImage;
    self.nameLabel.text = _model.name;
    self.sizeLabel.text = _model.size;
    self.timeDetailLabel.text = _model.detail;
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
