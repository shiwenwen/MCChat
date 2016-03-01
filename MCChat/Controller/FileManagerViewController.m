//
//  FileManagerViewController.m
//  MCChat
//
//  Created by 石文文 on 16/3/1.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import "FileManagerViewController.h"

@interface FileManagerViewController ()
@property (nonatomic,strong)NSArray *subFilePaths;
@end

@implementation FileManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"文件管理";
    
    [self getLocationFiles];
}

- (void)getLocationFiles{
    
    NSString *BasePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Inbox"];
    NSLog(@"FileBasepath ===== %@",BasePath);
   NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDic;
    if ([fileManager fileExistsAtPath:BasePath isDirectory:&isDic]) {
        
        if (isDic) {
            
            
            //目录存在
            self.subFilePaths = [fileManager subpathsAtPath:BasePath];
            
            for (NSString *subPath in self.subFilePaths) {
                
                NSLog(@"subPath = %@",subPath);
                
            }
            
        }
        
    }

    
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
