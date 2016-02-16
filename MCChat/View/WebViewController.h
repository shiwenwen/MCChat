//
//  WebViewController.h
//  GoToSchool
//
//  Created by 蔡连凤 on 15/6/25.
//  Copyright (c) 2015年 UI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController
@property (nonatomic,copy) NSString * httpUrl;
@property (nonatomic,copy) NSString * httpTitle;
@property (nonatomic,copy)NSDictionary *data;
@property (nonatomic,assign)BOOL isFromQr;
@end
