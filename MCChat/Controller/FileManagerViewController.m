//
//  FileManagerViewController.m
//  MCChat
//
//  Created by 石文文 on 16/3/1.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import "FileManagerViewController.h"
#import "FileModel.h"
@interface FileManagerViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong)NSArray *subFilePaths;
@property (nonatomic,strong)UITableView *tableView;
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
            
            NSArray *subPaths = [fileManager subpathsAtPath:BasePath];
            self.subFilePaths = [NSMutableArray arrayWithCapacity:subPaths.count];
            for (NSString *subPath in subPaths) {
                
                NSLog(@"subPath = %@",subPath);
                NSError *error;
               NSDictionary *fileAttr =  [fileManager attributesOfItemAtPath:subPath error:&error];
               
                FileModel *model = [[FileModel alloc]init];
                
            }
            
        }
        
    }

    
    
    
    
}
- (void)_creatTableView{
    
    
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    return self.subFilePaths.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
}

- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 0;
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
