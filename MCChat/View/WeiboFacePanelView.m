//
//  WeiboFacePanelView.m
//  WeiBoS
//
//  Created by mac on 15/10/19.
//  Copyright © 2015年 sww. All rights reserved.
//

#import "WeiboFacePanelView.h"

@implementation WeiboFacePanelView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _createSubViews];
        
    }
    return self;
}

- (void)_createSubViews{
    
    //关闭自动布局子视图
    self.autoresizesSubviews = NO;
    
    _faceView = [[WeiboFaceView alloc]initWithFrame:CGRectZero];
    _faceView.backgroundColor = [UIColor clearColor];
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, _faceView.height)];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.pagingEnabled = YES;
    _scrollView.clipsToBounds = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.contentSize = CGSizeMake(_faceView.width, _faceView.height);
    _scrollView.delegate = self;
    [_scrollView addSubview:_faceView];
    
    [self addSubview:_scrollView];
    
    
    _pageCtrl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, _scrollView.bottom, KScreenWidth, 30)];
    _pageCtrl.currentPage = 0;
    _pageCtrl.numberOfPages = _faceView.items.count;
    
    [self addSubview:_pageCtrl];
    
    self.width = _scrollView.width;
    self.height = _scrollView.height + _pageCtrl.height;
}


- (void)drawRect:(CGRect)rect {

    [[UIImage imageNamed:@"emoticon_keyboard_background"] drawInRect:rect];

}
//结束减速，修改pageCtrl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    _pageCtrl.currentPage = scrollView.contentOffset.x / KScreenWidth;
    
}

@end
