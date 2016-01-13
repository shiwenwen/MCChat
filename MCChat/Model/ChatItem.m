//
//  ChatItem.m
//  MCChat
//
//  Created by 石文文 on 16/1/8.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//


#import "ChatItem.h"
#define HEIGHT [UIScreen mainScreen].bounds.size.height
#define WIDTH [UIScreen mainScreen].bounds.size.width
@implementation ChatItem

-(CGFloat)textWidth{
    
    _textWidth = [self sizeOfStr:self.content andFont:[UIFont systemFontOfSize:17] andMaxSize:CGSizeMake(WIDTH * 2 / 3, 1000) andLineBreakMode:NSLineBreakByCharWrapping].width;
    return _textWidth;
    
}
- (CGFloat)textHeight{
    
   _textHeight = [self sizeOfStr:self.content andFont:[UIFont systemFontOfSize:17] andMaxSize:CGSizeMake(WIDTH * 2 / 3, 1000) andLineBreakMode:NSLineBreakByCharWrapping].height;
    _cellHeight = _textHeight
    + 60;
    return _textHeight;
    

}

-(CGSize)sizeOfStr:(NSString *)str andFont:(UIFont *)font andMaxSize:(CGSize)size andLineBreakMode:(NSLineBreakMode)mode
{
    CGSize s;
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0) {
        NSDictionary * dic = @{NSFontAttributeName:font};
        dic = dic;
        NSMutableDictionary * mdic = [NSMutableDictionary dictionary];
        [mdic setObject:[UIColor redColor] forKey:NSForegroundColorAttributeName];
        [mdic setObject:font forKey:NSFontAttributeName];
        NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc]init];
        [para setLineSpacing:5];//调整行间距
        [mdic setObject:para forKey:NSParagraphStyleAttributeName];
        
        s = [str boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                           attributes:mdic context:nil].size;
    }
    
    return s;
}

@end
