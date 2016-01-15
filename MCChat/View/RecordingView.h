//
//  RecordingView.h
//  MCChat
//
//  Created by 石文文 on 16/1/15.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordingView : UIView

@property (nonatomic,strong)UIImageView *recorderView;
@property (nonatomic,strong)UIImageView *recordingAnimationView;
@property (nonatomic,strong)UIImageView *cancelView;
@property (nonatomic,strong)UILabel *cancelLabel;
@property (nonatomic,copy)NSMutableArray *images;
@property (nonatomic,assign)BOOL sliderCancel;
@property (nonatomic,assign)float volume;
- (void)show;
- (void)hidden;
@end
