//
//  RecordingView.m
//  MCChat
//
//  Created by 石文文 on 16/1/15.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import "RecordingView.h"
#define bgSize 150 * proportation
#define VolumeLevelBase 4
@implementation RecordingView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.frame = CGRectMake((KScreenWidth - bgSize) / 2.0, (KScreenHeight - bgSize) / 2.0, bgSize, bgSize);
        self.layer.cornerRadius = 10;
        self.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.820];
        self.layer.masksToBounds = YES;
        self.recorderView = [[UIImageView alloc]initWithFrame:CGRectMake(20 * proportation, 25 * proportation, 62 * proportation, 100 * proportation)];
        self.recorderView.image = [UIImage imageNamed:@"RecordingBkg"];
        [self addSubview:self.recorderView];
        
        self.recordingAnimationView =[[UIImageView alloc]initWithFrame:CGRectMake(self.recorderView.right + 10 *proportation , self.recorderView.top, 38 * proportation, 100 * proportation)];
        
        [self addSubview:self.recordingAnimationView];
        //test
//        self.recordingAnimationView.animationImages = self.images;
//        [self.recordingAnimationView startAnimating];
        
        self.cancelLabel = [[UILabel alloc]initWithFrame:CGRectMake(20*proportation,self.recorderView.bottom, self.width - 40 *proportation,20*proportation)];
        self.cancelLabel.font = [UIFont systemFontOfSize:11];
        self.cancelLabel.textAlignment = NSTextAlignmentCenter;
        self.cancelLabel.textColor = [UIColor whiteColor];
        self.cancelLabel.layer.cornerRadius = 5;
        self.cancelLabel.layer.masksToBounds = YES;

        [self addSubview:self.cancelLabel];
        
        
    }
    return self;
}
- (void)setSliderCancel:(BOOL)sliderCancel{
    
    _sliderCancel = sliderCancel;
    
    if (_sliderCancel) {
        self.cancelLabel.backgroundColor = [UIColor colorWithRed:1.000 green:0.141 blue:0.000 alpha:0.500];
                self.cancelLabel.text = @"手指松开 取消发送";
    }else{
        self.cancelLabel.backgroundColor = [UIColor clearColor];
                self.cancelLabel.text = @"手指上滑 取消发送";
        
    }
    
}


-(NSMutableArray *)images{
    
    _images = [NSMutableArray arrayWithCapacity:8];
    for (int i = 1; i <= 8 ; i ++) {
        
        NSString *imageName = [NSString stringWithFormat:@"RecordingSignal00%d",i];
        UIImage *image = [UIImage imageNamed:imageName];
        [_images addObject:image];
        
    }
    return _images;
    
}
- (void)show{
 
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    
}
- (void)hidden{
    
    
    [self removeFromSuperview];
    
}
-(void)setVolume:(float)volume{
    
    NSInteger level = (volume + 160) / 160 * 8 - VolumeLevelBase;
    NSLog(@"%ld",(long)level);
    self.recordingAnimationView.image = self.images[level];
    
}
@end
