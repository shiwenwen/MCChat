//
//  FileCell.h
//  MCChat
//
//  Created by 石文文 on 16/3/1.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileModel.h"
@interface FileCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeDetailLabel;

@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (nonatomic,strong)FileModel *model;

@end
