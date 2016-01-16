//
//  ChatItem.h
//  MCChat
//
//  Created by 石文文 on 16/1/8.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef enum{
    textStates,
    picStates,
    videoStates,
    
}newsStates;

@interface ChatItem : NSObject


@property(nonatomic,assign)BOOL isSelf;//判断是接受，还是发的
@property(nonatomic,assign)newsStates states;
@property(nonatomic,strong)NSString * content;
@property (nonatomic,strong)UIImage *headerImage;
@property(nonatomic, strong)UIImage * picImage;

@property(nonatomic, strong)NSData * data;

@property (nonatomic,strong)UIImage *header;
@property (nonatomic,assign)CGFloat cellHeight;
@property (nonatomic,assign)CGFloat textHeight;
@property (nonatomic,assign)CGFloat textWidth;
@property (nonatomic,assign)CGFloat imageHight;
@property (nonatomic,assign)CGFloat imageWidth;
@end
