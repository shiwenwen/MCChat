//
//  FileListViewController.h
//  MCChat
//
//  Created by sww on 16/3/4.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileListViewController : UITableViewController
@property (nonatomic,strong)NSMutableArray* data;
@property (nonatomic,assign)BOOL isFromChat;
@end
