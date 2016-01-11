//
//  ChatCell.h
//  MCChat
//
//  Created by 石文文 on 16/1/8.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//


#import <UIKit/UIKit.h>

//@protocol CellSelectIndex <NSObject>
//
//- (void)cellSelectIndex;
//
//@end


@interface ChatCell : UITableViewCell



@property(nonatomic,strong)UIImageView * lefeView;
@property(nonatomic,strong)UIImageView * rightView;
@property(nonatomic,strong)UILabel * leftLabel;
@property(nonatomic,strong)UILabel * rightLabel;


@property(nonatomic,strong)UIImageView * leftHeadImage;
@property(nonatomic,strong)UIImageView * rightHeadImage;

@property(nonatomic,strong)UIImageView * leftPicImage;
@property(nonatomic,strong)UIImageView * rightPicImage;


@property(nonatomic ,strong)UIButton * leftVideoButton;
@property(nonatomic, strong)UIButton * rightVideoButton;

//@property(nonatomic,weak)id <CellSelectIndex> delegate;

// 不能用名字相同的属性
//  记住自动的时候，讲一下 weak  and strong 

@end
