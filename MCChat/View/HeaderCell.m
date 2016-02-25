//
//  HeaderCell.m
//  MCChat
//
//  Created by 石文文 on 16/2/25.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import "HeaderCell.h"

@implementation HeaderCell

- (void)awakeFromNib {
    self.headImageVIew.layer.cornerRadius = 5;
    self.headImageVIew.layer.masksToBounds = YES;
    self.headImageVIew.userInteractionEnabled = YES;
    
}

@end
