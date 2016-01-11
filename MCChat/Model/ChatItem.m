//
//  ChatItem.m
//  MCChat
//
//  Created by 石文文 on 16/1/8.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//


#import "ChatItem.h"

@implementation ChatItem

// 此处添加的原因 是iphone 6 和  iphone 5的区别，暂时具体原因不知道
@synthesize recordData = _recordData;
- (void)setRecordData:(NSData *)recordData
{
    _recordData = recordData;
}


- (NSData *)recordData
{
    return _recordData;
}



@end
