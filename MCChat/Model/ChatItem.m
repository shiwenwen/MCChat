//
//  ChatItem.m
//  MCChat
//
//  Created by 石文文 on 16/1/8.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//


#import "ChatItem.h"
#import "WXLabel.h"
#import "RegexKitLite.h"
#define HEIGHT [UIScreen mainScreen].bounds.size.height
#define WIDTH [UIScreen mainScreen].bounds.size.width

@implementation ChatItem

-(CGFloat)textWidth{
    
    _textWidth = [self sizeOfStr:_content andFont:[UIFont systemFontOfSize:17] andMaxSize:CGSizeMake(WIDTH * 2 / 3, 1000) andLineBreakMode:NSLineBreakByCharWrapping].width;
    

    
    return _textWidth;
    
}
- (CGFloat)textHeight{
    
//   _textHeight = [self sizeOfStr:self.content andFont:[UIFont systemFontOfSize:16] andMaxSize:CGSizeMake(WIDTH * 2 / 3, 1000) andLineBreakMode:NSLineBreakByCharWrapping].height + 10;
    
    _textHeight = [WXLabel getTextHeight:17 width:WIDTH * 2 / 3 text:self.content linespace:6];
    _cellHeight = _textHeight
    + 60;
    return _textHeight;
    

}
- (NSString *)content{
    
    NSString *attrContent = _content;
    //正文表情处理
    
    //正则表达式 ［微笑］ －－>  <image url = '001.png'>
    
    NSString *regx1 = @"\\[\\w+\\]";
    
    NSArray *faceTextArr = [_content componentsMatchedByRegex:regx1];
    
    //取出表情数据
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"emoticons.plist" ofType:nil];
    
    NSArray *faceArr = [NSArray arrayWithContentsOfFile:path];
    
    
    for (NSString *faceStr in faceTextArr) {
        
        
        //使用谓词过滤
        
        NSString *str = [NSString stringWithFormat:@"chs = '%@'",faceStr];
        
        //根据sr过滤出对应的数组 （数组中只有一个元素）
        NSArray *result = [faceArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:str]];
        NSDictionary *dic1 = [result firstObject];
        
        //取出相应图片
        NSString *imageName = dic1[@"png"];
        
        //拼接图片
        
        NSString *imageStr = [NSString stringWithFormat:@"<image url = '%@'>",imageName];
        
        attrContent = [attrContent stringByReplacingOccurrencesOfString:faceStr withString:imageStr];
    }
    return attrContent;
    
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
- (CGFloat)imageHight{
    
    
    _imageHight = self.picImage.size.height;
    
    if (_imageHight > 180) {
        
        _imageHight = 180.0;
    }
    if (self.imageWidth > KScreenWidth -100) {
        
        _imageHight = self.imageWidth * self.picImage.size.height / self.picImage.size.width;
    }
    
    
    _cellHeight = _imageHight + 60;
    
    return _imageHight;
    
}

-(CGFloat)imageWidth{
    
    if (self.picImage.size.height > 180) {
        
     _imageWidth = 180 * self.picImage.size.width / self.picImage.size.height ;
    }else{
        _imageWidth =  self.picImage.size.width;
    }
    
    
    if (_imageWidth >= KScreenWidth - 100) {
        
        _imageWidth = KScreenWidth -100;
        
        _imageHight = _imageWidth * self.picImage.size.height / self.picImage.size.width;
        _cellHeight = _imageHight + 60;
    }
    
    return _imageWidth;
    

}
- (void)setStates:(newsStates)states{
    
    _states = states;
    if (_states == videoStates) {
        
        _cellHeight = 45 + 60;
        
    }
    
    
}

@end
