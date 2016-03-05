//
//  WWPageController.h
//  WWPageController
//
//  Created by 石文文 on 16/2/4.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WWPageControllerDataSource <NSObject>

@required
/**
 *  页数，即自控制器数
 *
 *  @return 页数
 */
- (NSInteger)numberOfPages;
/**
 *  每一个标签的标题
 *  @param page 标签
 *  @return 标题
 */
- (nonnull NSString *)pageTitle:(NSInteger )page;
/**
 *  创建每一个标签的控制器
 *
 *  @param page 标签
 *
 *  @return 每一个标签的控制器
 */
- (nonnull UIViewController *)controllerOfPage:(NSInteger)page;

@end
@protocol WWPageControllerDelegate <NSObject>

@optional
/**
 *  选择某一页的标签
 *
 *  @param page 标签
 */
-(void)didSelectPage:(NSInteger )page;

@end
@interface WWPageController : UIViewController
/**
 *  数据源对象
 */
@property (nonatomic,weak)id<WWPageControllerDataSource> dataSource;
/**
 *  代理对象
 */
@property (nonatomic,weak)id<WWPageControllerDelegate> delegate;
@property (nonatomic,strong,nullable)UIColor *titleTabColor;
@property (nonatomic,strong,nullable)UIColor *titleColor;
@end
