//
//  TitleCell.h
//  WWPageController
//
//  Created by 石文文 on 16/2/4.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#define KTextFont 16
@interface TitleCell : UICollectionViewCell
@property (nonatomic,strong,readonly)UILabel *titleLabel;
@property (nonatomic,copy)NSString *title;
@property (nonatomic,assign)BOOL isSelected;
@end
