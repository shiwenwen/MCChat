//
//  WeiboFacePanelView.h
//  WeiBoS
//
//  Created by mac on 15/10/19.
//  Copyright © 2015年 sww. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiboFaceView.h"

@interface WeiboFacePanelView : UIView<UIScrollViewDelegate>{
    
//    WeiboFaceView *_faceView;
    UIScrollView *_scrollView;
    UIPageControl *_pageCtrl;


}
@property (nonatomic,strong)WeiboFaceView *faceView;
/**
 *  发送按钮
 *
 *  @param sel 发送按钮执行的方法
 */
- (void)showSendWithTarget:(id)target Action:(SEL)sel;
@end

