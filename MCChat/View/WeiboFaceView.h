//
//  WeiboFaceView.h
//  WeiBoS
//
//  Created by mac on 15/10/19.
//  Copyright © 2015年 sww. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WeiboFaceViewDelegate <NSObject>

- (void)choseFace:(NSString *)faceString;

@end

@interface WeiboFaceView : UIView{
    
    UIImageView *_magnifierView;
    UIImageView *_largeFaceImageView;
}
@property (nonatomic,strong)NSMutableArray *items;
@property (nonatomic,weak)id <WeiboFaceViewDelegate> delegate;


@end
