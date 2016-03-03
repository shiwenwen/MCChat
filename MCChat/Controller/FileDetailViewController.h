//
//  FileDetailViewController.h
//  MCChat
//
//  Created by sww on 16/3/3.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileModel.h"
@interface FileDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UIView *toolBarView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;

@property (nonatomic,strong)FileModel *model;


@end
