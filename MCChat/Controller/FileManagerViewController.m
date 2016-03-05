//
//  FileManagerViewController.m
//  MCChat
//
//  Created by 石文文 on 16/3/1.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import "FileManagerViewController.h"
#import "FileModel.h"
#import "FileCell.h"
#import "FileDetailViewController.h"
#import "MJRefresh.h"
#import "WWPageController.h"
@interface FileManagerViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong)NSMutableArray *files;
@property (nonatomic,strong)UITableView *tableView;
@end

@implementation FileManagerViewController
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"文件管理";
    if (self.contentPaths) {
        
        NSString *title= self.contentPaths.lastObject;
        
        NSRange ranger = [title rangeOfString:@"/" options:NSBackwardsSearch];
        if (ranger.location != NSNotFound) {
            self.title = [title substringFromIndex:ranger.location + 1];    
        }
        
    }
    [self _creatTableView];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tableViewBeginRefresh) name:@"getFileSuccess" object:nil];

}
- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    [self tableViewBeginRefresh];

}
- (void)tableViewBeginRefresh{
    
    [self.tableView.header beginRefreshing];
}
- (void)getLocationFiles{
    if (!self.contentPaths) {
        self.contentPaths = @[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/MyInbox"],[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/InBox"]];
    }
     NSFileManager *fileManager = [NSFileManager defaultManager];
    
                self.files = [NSMutableArray array];
    for (int i = 0;i < self.contentPaths.count ;i ++) {
        
        NSString *basePath = self.contentPaths[i];
        BOOL isDic;
        if ([fileManager fileExistsAtPath:basePath isDirectory:&isDic]) {

            if (isDic) {
                
                
                //目录存在
                
                NSMutableArray *subPaths = [[fileManager contentsOfDirectoryAtPath:basePath error:nil] mutableCopy];
                
                
                
                
                for (NSString *subPath in subPaths) {
                    
                    NSLog(@"subPath = %@",subPath);
                    NSError *error;
                    NSDictionary *fileAttr =  [fileManager attributesOfItemAtPath:[basePath stringByAppendingPathComponent:subPath] error:&error];
    
                    
                    NSString *fileSize = [self fileSizeTransform:[fileAttr[@"NSFileSize"] floatValue]];
                    
                    NSDate *modificationDate = fileAttr[@"NSFileModificationDate"];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                    NSString *dateStr = [formatter stringFromDate:modificationDate];
                    
                    
                    NSRange range = [subPath rangeOfString:@"." options:NSBackwardsSearch];
                    
                    NSString *extension;
                    
                    if (range.location != NSNotFound) {
                        
                        extension = [subPath substringFromIndex:range.location + 1];
                        
                        
                    }
                    
                    FileType type = other;
                        extension = [extension lowercaseString];
                    if ([extension isEqualToString:@"doc"]||[extension isEqualToString:@"docx"]||[extension isEqualToString:@"pages"]) {
                        type = Word;
                    }else if ([extension isEqualToString:@"xls"]||[extension isEqualToString:@"xlsx"]||[extension isEqualToString:@"numbers"]){
                        
                        type = Excel;
                        
                    }else if ([extension isEqualToString:@"ppt"]||[extension isEqualToString:@"pptx"]||[extension isEqualToString:@"keynote"]){
                        
                        type = PowerPoint;
                    }
                    else if ([extension isEqualToString:@"mp3"]||[extension isEqualToString:@"wma"]||[extension isEqualToString:@"mac"]||[extension isEqualToString:@"aac"]||[extension isEqualToString:@"wav"]){
                        
                        
                        type = music;
                        
                    }else if ([extension isEqualToString:@"rmvb"]||[extension isEqualToString:@"wmv"]||[extension isEqualToString:@"asf"]||[extension isEqualToString:@"avi"]||[extension isEqualToString:@"3gp"]||[extension isEqualToString:@"mpg"]||[extension isEqualToString:@"mkv"]||[extension isEqualToString:@"mp4"]||[extension isEqualToString:@"ogm"]||[extension isEqualToString:@"mov"]||[extension isEqualToString:@"mpeg2"]||[extension isEqualToString:@"mpeg4"]){
                        
                        type = video;
                        
                    }else if ([extension isEqualToString:@"gif"]||[extension isEqualToString:@"jpeg"]||[extension isEqualToString:@"bmp"]||[extension isEqualToString:@"tif"]||[extension isEqualToString:@"jpg"]||[extension isEqualToString:@"pcd"]||[extension isEqualToString:@"qti"]||[extension isEqualToString:@"qtf"]||[extension isEqualToString:@"tiff"]||[extension isEqualToString:@"qtf"]||[extension isEqualToString:@"png"]){
                        
                        type = image;
                        
                    }else if ([extension isEqualToString:@"rar"]||[extension isEqualToString:@"zip"]||[extension isEqualToString:@"tar"]||[extension isEqualToString:@"cab"]||[extension isEqualToString:@"uue"]||[extension isEqualToString:@"jar"]||[extension isEqualToString:@"iso"]||[extension isEqualToString:@"z"]||[extension isEqualToString:@"7-zip"]||[extension isEqualToString:@"gzip"]||[extension isEqualToString:@"bz2"]){
                        
                        type = zip;
                    }else if ([extension isEqualToString:@"pdf"]){
                        
                        type = pdf;
                    }else if ([extension isEqualToString:@"txt"]||[extension isEqualToString:@"m"]||[extension isEqualToString:@"c"]||[extension isEqualToString:@"webarchive"]||[extension isEqualToString:@"plist"]||[extension isEqualToString:@"h"]||[extension isEqualToString:@"html"]){
                        
                        type = txt;
                    }else if (extension.length == 0){
                        type = folder;
                    }
                    
                    FileModel *model = [[FileModel alloc]initWithName:subPath Detail:dateStr size:fileSize FileType:type Path:[basePath stringByAppendingPathComponent:subPath]];
                    model.realitySize = [fileAttr[@"NSFileSize"] doubleValue];
                    [self.files addObject:model];
                    
                }
                
                if (i == self.contentPaths.count - 1) {
                    
                    if (self.files.count > 0) {
                        [self.tableView reloadData];
                    }else{
                        self.tableView.hidden = YES;
                        
                        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 100, KScreenWidth, 100)];
                        [self.view addSubview:label];
                        label.text = @"暂无文件";
                        label.font = [UIFont systemFontOfSize:23];
                        label.textAlignment = NSTextAlignmentCenter;
                    }
                    [self.tableView.header endRefreshing];
                    
                }
                
                
            }else{
                if (i == self.contentPaths.count - 1) {
                    
                    if (self.files.count > 0) {
                        [self.tableView reloadData];
                    }else{
                        self.tableView.hidden = YES;
                        
                        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 100, KScreenWidth, 100)];
                        [self.view addSubview:label];
                        label.text = @"暂无文件";
                        label.font = [UIFont systemFontOfSize:23];
                        label.textAlignment = NSTextAlignmentCenter;
                    }
                    [self.tableView.header endRefreshing];
 
                }
            }
        }
    
    }
    
}

- (void)_creatTableView{
    
    
    self.tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"FileCell" bundle:nil] forCellReuseIdentifier:@"FileCell"];
   self.tableView.header =  [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getLocationFiles)];

}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    return self.files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileCell" forIndexPath:indexPath];
    
    cell.model = self.files[indexPath.row];
    
    if (cell.model.fileType == image) {
        
        cell.logoImageView.image = [UIImage imageWithContentsOfFile:cell.model.path];
        
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FileModel *model = self.files[indexPath.row];
    if (self.isFromChat) {
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"PostFile" object:model];
        
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    
    BOOL isDic;
    if ([[NSFileManager defaultManager] fileExistsAtPath:model.path isDirectory:&isDic]) {
        
        if (isDic) {
            
            FileManagerViewController *fileManegerVC = [[FileManagerViewController alloc]init];
            fileManegerVC.contentPaths = @[model.path];
            [self.navigationController pushViewController:fileManegerVC animated:YES];
        }else{
            FileDetailViewController *fileDetailVC =[[FileDetailViewController alloc]init];
            fileDetailVC.model = model;
            [self.navigationController pushViewController:fileDetailVC animated:YES];
 
        }
    }
    
    
}

- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.000001;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -- 尺寸计算
- (NSString *)fileSizeTransform:(CGFloat )originalSize{
    
    if (originalSize / (1000 * 1000) < 1) {
        
        return [NSString stringWithFormat:@"%.2fKB",originalSize / 1000.0];
    }else if (originalSize / (1000 * 1000) >= 1){
        
        
        return [NSString stringWithFormat:@"%.2fMB",originalSize / (1000.0 * 1000.0)];
        
        
    }else{
        
        return [NSString stringWithFormat:@"%.2fGB",originalSize / (1000.0 * 1000 * 1000)];
    }
    
}

 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

 return YES;
 }



 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
     if (editingStyle == UITableViewCellEditingStyleDelete) {
     // Delete the row from the data source
       
         
         NSError *error;
         FileModel *model = self.files[indexPath.row];
        BOOL result =   [[NSFileManager defaultManager]removeItemAtPath:model.path error:&error];
         
         
         
         if (result) {
             [self.files removeObjectAtIndex:indexPath.row];
               [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
         }else{
            NSLog(@"removeItemAtPathError=%@",error);
         }
         
        } else if (editingStyle == UITableViewCellEditingStyleInsert) {


     }
 }

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
