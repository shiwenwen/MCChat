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
#import "ChineseString.h"
@interface FileManagerViewController ()<UITableViewDataSource,UITableViewDelegate>{
    
    NSArray *_filterTitles1;
    NSArray *_filterTitles2;
    NSInteger _currentFilterTag;
}
@property (nonatomic,strong)NSMutableArray *files;
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)UIView *filterBackView;
@property (nonatomic,strong)UIView *blackBackView;
@property (nonatomic,strong)UITableView *filterTableView;

@end

@implementation FileManagerViewController
- (instancetype)init
{
    self = [super init];
    if (self) {
//        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (BOOL)shouldAutorotate{
    return NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"文件管理";
    _filterTitles1 = @[@"全部",@"文档",@"音乐",@"视频",@"图片",@"压缩文件",@"文件夹",@"其他"];
    _filterTitles2 = @[@"默认排序",@"时间",@"大小",@"名称"];
    if (self.contentPaths) {
        
        NSString *title= self.contentPaths.lastObject;
        
        NSRange ranger = [title rangeOfString:@"/" options:NSBackwardsSearch];
        if (ranger.location != NSNotFound) {
            self.title = [title substringFromIndex:ranger.location + 1];    
        }
        
    }
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 100, KScreenWidth, 100)];
    [self.view addSubview:label];
    label.text = @"暂无文件";
    label.font = [UIFont systemFontOfSize:23];
    label.textAlignment = NSTextAlignmentCenter;
    
    [self _creatTableView];
  [self _createFilterViews];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tableViewBeginRefresh) name:@"getFileSuccess" object:nil];

}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
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
        NSString *path1 = [NSString stringWithFormat:@"%@/Documents/MyInBox",NSHomeDirectory()];
        NSString *path2 = [NSString stringWithFormat:@"%@/Documents/Inbox",NSHomeDirectory()];
//        self.contentPaths = @[path1,path2];
        
        NSString *path = [NSString stringWithFormat:@"%@/Documents",NSHomeDirectory()];
         NSArray *subPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil] ;
        
        NSMutableArray *pathAppdenSubpaths = [NSMutableArray array];
        for (NSString *subPath in subPaths) {
            [pathAppdenSubpaths addObject:[path stringByAppendingPathComponent:subPath]];
            
        }
        self.contentPaths = pathAppdenSubpaths;
//        self.contentPaths = @[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/MyInBox"],[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Inbox"]];
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    
    if(!self.files){
        self.files = [NSMutableArray array];
    }else{
        [self.files removeAllObjects];
    }
    
    
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        
        //遍历目录
        for (int i = 0;i < self.contentPaths.count ;i ++) {
            
            NSString *basePath = self.contentPaths[i];
            BOOL isDic;
            BOOL fileExists = [fileManager fileExistsAtPath:basePath isDirectory:&isDic];

            if (fileExists) {
#warning 如果目录存在
                if (isDic) {
                    
                    
#warning 如果目录存在且是目录（非文件）
                    
                    NSMutableArray *subPaths = [[fileManager contentsOfDirectoryAtPath:basePath error:nil] mutableCopy];
                    
                    
                    
#warning 对目录的子目录进行遍历
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
                        model.date = modificationDate;
                        [self.files addObject:model];
                        
                        
                    }
                    
                    if (i == self.contentPaths.count - 1) {
                        {//代码块
                            UIButton *button1 = (UIButton *)[self.filterBackView viewWithTag:2000];
                            UIButton *button2 = (UIButton *)[self.filterBackView viewWithTag:2001];
                            
                            if ([button1.titleLabel.text isEqualToString:@"文档"]) {
                                
                                NSMutableArray *temp1 = [NSMutableArray array];
                                
                                for (FileModel *model in self.files) {
                                    
                                    if (model.fileType == Word || model.fileType == Excel || model.fileType == PowerPoint ||model.fileType == pdf||model.fileType == txt) {
                                        
                                        [temp1 addObject:model];
                                    }
                                    
                                }
                                
                                if (temp1.count > 1) {
                                    if ([button2.titleLabel.text isEqualToString:@"大小"]) {
                                        NSInteger count = temp1.count;
                                        int i, j;
                                        for (j = 0; j < count - 1; j++)
                                            for (i = 0; i < count - 1 - j; i++)
                                            {
                                                FileModel *model1 = temp1[i];
                                                FileModel *model2 = temp1[i+1];
                                                if (model1.realitySize < model2.realitySize) {
                                                    
                                                    [temp1 exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                                                }
                                            }
                                        
                                        
                                        
                                    }else if ([button2.titleLabel.text isEqualToString:@"时间"]){
                                        
                                        NSInteger count = temp1.count;
                                        int i, j;
                                        for (j = 0; j < count - 1; j++)
                                            for (i = 0; i < count - 1 - j; i++)
                                            {
                                                FileModel *model1 = temp1[i];
                                                FileModel *model2 = temp1[i+1];
                                                if (model1.date.timeIntervalSince1970 < model2.date.timeIntervalSince1970) {
                                                    
                                                    [temp1 exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                                                }
                                            }
                                        
                                        
                                    }else if ([button2.titleLabel.text isEqualToString:@"名称"]){
                                        
                                        NSMutableArray *nameArr = [NSMutableArray array];
                                        for (FileModel *model in temp1) {
                                            [nameArr addObject:model.name];
                                        }
                                        NSMutableArray *letterResultArr = [ChineseString LetterSortArray:nameArr];
                                        NSMutableArray *temp2 = [NSMutableArray array];
                                        for (int i = 0;i < letterResultArr.count; i++) {
                                            NSArray *subArr =  letterResultArr[i];
                                            for (NSString *name in subArr) {
                                                
                                                [temp2 addObject:name];
                                            }
                                            
                                        }
                                        NSMutableArray *temp3 = [NSMutableArray array];
                                        
                                        for (int i = 0; i < temp2.count; i++) {
                                            
                                            NSString *name = temp2[i];
                                            
                                            for (FileModel *model in temp1){
                                                
                                                if ([[[[[[model.name stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"《" withString:@""] stringByReplacingOccurrencesOfString:@"》" withString:@""] stringByReplacingOccurrencesOfString:@"_" withString:@""]isEqualToString:name]) {
                                                    
                                                    [temp3 addObject:model];
                                                }
                                            }
                                            
                                            
                                        }
                                        
                                        temp1 = temp3;
                                    }
                                }
                                
                                
                                self.files = temp1;
                            }else if ([button1.titleLabel.text isEqualToString:@"文件夹"]){
                                NSMutableArray *temp1 = [NSMutableArray array];
                                
                                for (FileModel *model in self.files) {
                                    
                                    if (model.fileType == folder) {
                                        
                                        [temp1 addObject:model];
                                    }
                                    
                                }
                                
                                if (temp1.count > 1) {
                                    if ([button2.titleLabel.text isEqualToString:@"大小"]) {
                                        NSInteger count = temp1.count;
                                        int i, j;
                                        for (j = 0; j < count - 1; j++)
                                            for (i = 0; i < count - 1 - j; i++)
                                            {
                                                FileModel *model1 = temp1[i];
                                                FileModel *model2 = temp1[i+1];
                                                if (model1.realitySize < model2.realitySize) {
                                                    
                                                    [temp1 exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                                                }
                                            }
                                        
                                        
                                        
                                    }else if ([button2.titleLabel.text isEqualToString:@"时间"]){
                                        
                                        NSInteger count = temp1.count;
                                        int i, j;
                                        for (j = 0; j < count - 1; j++)
                                            for (i = 0; i < count - 1 - j; i++)
                                            {
                                                FileModel *model1 = temp1[i];
                                                FileModel *model2 = temp1[i+1];
                                                if (model1.date.timeIntervalSince1970 < model2.date.timeIntervalSince1970) {
                                                    
                                                    [temp1 exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                                                }
                                            }
                                        
                                        
                                    }else if ([button2.titleLabel.text isEqualToString:@"名称"]){
                                        
                                        
                                        NSMutableArray *nameArr = [NSMutableArray array];
                                        for (FileModel *model in temp1) {
                                            [nameArr addObject:model.name];
                                        }
                                        NSMutableArray *letterResultArr = [ChineseString LetterSortArray:nameArr];
                                        NSMutableArray *temp2 = [NSMutableArray array];
                                        for (int i = 0;i < letterResultArr.count; i++) {
                                            NSArray *subArr =  letterResultArr[i];
                                            for (NSString *name in subArr) {
                                                
                                                [temp2 addObject:name];
                                            }
                                            
                                        }
                                        NSMutableArray *temp3 = [NSMutableArray array];
                                        
                                        for (int i = 0; i < temp2.count; i++) {
                                            
                                            NSString *name = temp2[i];
                                            
                                            for (FileModel *model in temp1){
                                                
                                                if ([[[[[[model.name stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"《" withString:@""] stringByReplacingOccurrencesOfString:@"》" withString:@""] stringByReplacingOccurrencesOfString:@"_" withString:@""]isEqualToString:name]) {
                                                    
                                                    [temp3 addObject:model];
                                                }
                                            }
                                            
                                            
                                        }
                                        
                                        temp1 = temp3;
                                    }
                                }
                                
                                
                                self.files = temp1;
                                
                            }else if ([button1.titleLabel.text isEqualToString:@"音乐"]){
                                NSMutableArray *temp1 = [NSMutableArray array];
                                
                                for (FileModel *model in self.files) {
                                    
                                    if (model.fileType == music) {
                                        
                                        [temp1 addObject:model];
                                    }
                                    
                                }
                                
                                if (temp1.count > 1) {
                                    if ([button2.titleLabel.text isEqualToString:@"大小"]) {
                                        NSInteger count = temp1.count;
                                        int i, j;
                                        for (j = 0; j < count - 1; j++)
                                            for (i = 0; i < count - 1 - j; i++)
                                            {
                                                FileModel *model1 = temp1[i];
                                                FileModel *model2 = temp1[i+1];
                                                if (model1.realitySize < model2.realitySize) {
                                                    
                                                    [temp1 exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                                                }
                                            }
                                        
                                        
                                        
                                    }else if ([button2.titleLabel.text isEqualToString:@"时间"]){
                                        
                                        NSInteger count = temp1.count;
                                        int i, j;
                                        for (j = 0; j < count - 1; j++)
                                            for (i = 0; i < count - 1 - j; i++)
                                            {
                                                FileModel *model1 = temp1[i];
                                                FileModel *model2 = temp1[i+1];
                                                if (model1.date.timeIntervalSince1970 < model2.date.timeIntervalSince1970) {
                                                    
                                                    [temp1 exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                                                }
                                            }
                                        
                                        
                                    }else if ([button2.titleLabel.text isEqualToString:@"名称"]){
                                        
                                        
                                        NSMutableArray *nameArr = [NSMutableArray array];
                                        for (FileModel *model in temp1) {
                                            [nameArr addObject:model.name];
                                        }
                                        NSMutableArray *letterResultArr = [ChineseString LetterSortArray:nameArr];
                                        NSMutableArray *temp2 = [NSMutableArray array];
                                        for (int i = 0;i < letterResultArr.count; i++) {
                                            NSArray *subArr =  letterResultArr[i];
                                            for (NSString *name in subArr) {
                                                
                                                [temp2 addObject:name];
                                            }
                                            
                                        }
                                        NSMutableArray *temp3 = [NSMutableArray array];
                                        
                                        for (int i = 0; i < temp2.count; i++) {
                                            
                                            NSString *name = temp2[i];
                                            
                                            for (FileModel *model in temp1){
                                                
                                                if ([[[[[[model.name stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"《" withString:@""] stringByReplacingOccurrencesOfString:@"》" withString:@""] stringByReplacingOccurrencesOfString:@"_" withString:@""]isEqualToString:name]) {
                                                    
                                                    [temp3 addObject:model];
                                                }
                                                
                                            }
                                            
                                            
                                        }
                                        
                                        temp1 = temp3;
                                    }
                                }
                                
                                
                                self.files = temp1;
                                
                            }else if ([button1.titleLabel.text isEqualToString:@"视频"]){
                                NSMutableArray *temp1 = [NSMutableArray array];
                                
                                for (FileModel *model in self.files) {
                                    
                                    if (model.fileType == video) {
                                        
                                        [temp1 addObject:model];
                                    }
                                    
                                }
                                
                                if (temp1.count > 1) {
                                    if ([button2.titleLabel.text isEqualToString:@"大小"]) {
                                        NSInteger count = temp1.count;
                                        int i, j;
                                        for (j = 0; j < count - 1; j++)
                                            for (i = 0; i < count - 1 - j; i++)
                                            {
                                                FileModel *model1 = temp1[i];
                                                FileModel *model2 = temp1[i+1];
                                                if (model1.realitySize < model2.realitySize) {
                                                    
                                                    [temp1 exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                                                }
                                            }
                                        
                                        
                                        
                                    }else if ([button2.titleLabel.text isEqualToString:@"时间"]){
                                        
                                        NSInteger count = temp1.count;
                                        int i, j;
                                        for (j = 0; j < count - 1; j++)
                                            for (i = 0; i < count - 1 - j; i++)
                                            {
                                                FileModel *model1 = temp1[i];
                                                FileModel *model2 = temp1[i+1];
                                                if (model1.date.timeIntervalSince1970 < model2.date.timeIntervalSince1970) {
                                                    
                                                    [temp1 exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                                                }
                                            }
                                        
                                        
                                    }else if ([button2.titleLabel.text isEqualToString:@"名称"]){
                                        
                                        NSMutableArray *nameArr = [NSMutableArray array];
                                        for (FileModel *model in temp1) {
                                            [nameArr addObject:model.name];
                                        }
                                        NSMutableArray *letterResultArr = [ChineseString LetterSortArray:nameArr];
                                        NSMutableArray *temp2 = [NSMutableArray array];
                                        for (int i = 0;i < letterResultArr.count; i++) {
                                            NSArray *subArr =  letterResultArr[i];
                                            for (NSString *name in subArr) {
                                                
                                                [temp2 addObject:name];
                                            }
                                            
                                        }
                                        NSMutableArray *temp3 = [NSMutableArray array];
                                        
                                        for (int i = 0; i < temp2.count; i++) {
                                            
                                            NSString *name = temp2[i];
                                            
                                            for (FileModel *model in temp1){
                                                if ([[[[[[model.name stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"《" withString:@""] stringByReplacingOccurrencesOfString:@"》" withString:@""] stringByReplacingOccurrencesOfString:@"_" withString:@""]isEqualToString:name]) {
                                                    
                                                    [temp3 addObject:model];
                                                }
                                            }
                                            
                                            
                                        }
                                        
                                        temp1 = temp3;
                                    }
                                }
                                
                                
                                self.files = temp1;
                                
                            }else if ([button1.titleLabel.text isEqualToString:@"图片"]){
                                NSMutableArray *temp1 = [NSMutableArray array];
                                
                                for (FileModel *model in self.files) {
                                    
                                    if (model.fileType == image) {
                                        
                                        [temp1 addObject:model];
                                    }
                                    
                                }
                                
                                if (temp1.count > 1) {
                                    if ([button2.titleLabel.text isEqualToString:@"大小"]) {
                                        NSInteger count = temp1.count;
                                        int i, j;
                                        for (j = 0; j < count - 1; j++)
                                            for (i = 0; i < count - 1 - j; i++)
                                            {
                                                FileModel *model1 = temp1[i];
                                                FileModel *model2 = temp1[i+1];
                                                if (model1.realitySize < model2.realitySize) {
                                                    
                                                    [temp1 exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                                                }
                                            }
                                        
                                        
                                        
                                    }else if ([button2.titleLabel.text isEqualToString:@"时间"]){
                                        
                                        NSInteger count = temp1.count;
                                        int i, j;
                                        for (j = 0; j < count - 1; j++)
                                            for (i = 0; i < count - 1 - j; i++)
                                            {
                                                FileModel *model1 = temp1[i];
                                                FileModel *model2 = temp1[i+1];
                                                if (model1.date.timeIntervalSince1970 < model2.date.timeIntervalSince1970) {
                                                    
                                                    [temp1 exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                                                }
                                            }
                                        
                                        
                                    }else if ([button2.titleLabel.text isEqualToString:@"名称"]){
                                        
                                        
                                        NSMutableArray *nameArr = [NSMutableArray array];
                                        for (FileModel *model in temp1) {
                                            [nameArr addObject:model.name];
                                        }
                                        NSMutableArray *letterResultArr = [ChineseString LetterSortArray:nameArr];
                                        NSMutableArray *temp2 = [NSMutableArray array];
                                        for (int i = 0;i < letterResultArr.count; i++) {
                                            NSArray *subArr =  letterResultArr[i];
                                            for (NSString *name in subArr) {
                                                
                                                [temp2 addObject:name];
                                            }
                                            
                                        }
                                        NSMutableArray *temp3 = [NSMutableArray array];
                                        
                                        for (int i = 0; i < temp2.count; i++) {
                                            
                                            NSString *name = temp2[i];
                                            
                                            for (FileModel *model in temp1){
                                                
                                                if ([[[[[[model.name stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"《" withString:@""] stringByReplacingOccurrencesOfString:@"》" withString:@""] stringByReplacingOccurrencesOfString:@"_" withString:@""]isEqualToString:name]) {
                                                    
                                                    [temp3 addObject:model];
                                                }
                                            }
                                            
                                            
                                        }
                                        
                                        temp1 = temp3;
                                    }
                                }
                                
                                
                                self.files = temp1;
                                
                            }else if ([button1.titleLabel.text isEqualToString:@"压缩文件"]){
                                NSMutableArray *temp1 = [NSMutableArray array];
                                
                                for (FileModel *model in self.files) {
                                    
                                    if (model.fileType == zip) {
                                        
                                        [temp1 addObject:model];
                                    }
                                    
                                }
                                
                                if (temp1.count > 1) {
                                    if ([button2.titleLabel.text isEqualToString:@"大小"]) {
                                        NSInteger count = temp1.count;
                                        int i, j;
                                        for (j = 0; j < count - 1; j++)
                                            for (i = 0; i < count - 1 - j; i++)
                                            {
                                                FileModel *model1 = temp1[i];
                                                FileModel *model2 = temp1[i+1];
                                                if (model1.realitySize < model2.realitySize) {
                                                    
                                                    [temp1 exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                                                }
                                            }
                                        
                                        
                                        
                                    }else if ([button2.titleLabel.text isEqualToString:@"时间"]){
                                        
                                        NSInteger count = temp1.count;
                                        int i, j;
                                        for (j = 0; j < count - 1; j++)
                                            for (i = 0; i < count - 1 - j; i++)
                                            {
                                                FileModel *model1 = temp1[i];
                                                FileModel *model2 = temp1[i+1];
                                                if (model1.date.timeIntervalSince1970 < model2.date.timeIntervalSince1970) {
                                                    
                                                    [temp1 exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                                                }
                                            }
                                        
                                        
                                    }else if ([button2.titleLabel.text isEqualToString:@"名称"]){
                                        
                                        NSMutableArray *nameArr = [NSMutableArray array];
                                        for (FileModel *model in temp1) {
                                            [nameArr addObject:model.name];
                                        }
                                        NSMutableArray *letterResultArr = [ChineseString LetterSortArray:nameArr];
                                        NSMutableArray *temp2 = [NSMutableArray array];
                                        for (int i = 0;i < letterResultArr.count; i++) {
                                            NSArray *subArr =  letterResultArr[i];
                                            for (NSString *name in subArr) {
                                                
                                                [temp2 addObject:name];
                                            }
                                            
                                        }
                                        NSMutableArray *temp3 = [NSMutableArray array];
                                        
                                        for (int i = 0; i < temp2.count; i++) {
                                            
                                            NSString *name = temp2[i];
                                            
                                            for (FileModel *model in temp1){
                                                
                                                if ([[[[[[model.name stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"《" withString:@""] stringByReplacingOccurrencesOfString:@"》" withString:@""] stringByReplacingOccurrencesOfString:@"_" withString:@""]isEqualToString:name]) {
                                                    
                                                    [temp3 addObject:model];
                                                }
                                            }
                                            
                                            
                                        }
                                        
                                        temp1 = temp3;
                                    }
                                }
                                
                                
                                self.files = temp1;
                                
                            }else if ([button1.titleLabel.text isEqualToString:@"其他"]){
                                
                                NSMutableArray *temp1 = [NSMutableArray array];
                                
                                for (FileModel *model in self.files) {
                                    
                                    if (model.fileType == other) {
                                        
                                        [temp1 addObject:model];
                                    }
                                    
                                }
                                
                                if (temp1.count > 1) {
                                    if ([button2.titleLabel.text isEqualToString:@"大小"]) {
                                        NSInteger count = temp1.count;
                                        int i, j;
                                        for (j = 0; j < count - 1; j++)
                                            for (i = 0; i < count - 1 - j; i++)
                                            {
                                                FileModel *model1 = temp1[i];
                                                FileModel *model2 = temp1[i+1];
                                                if (model1.realitySize < model2.realitySize) {
                                                    
                                                    [temp1 exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                                                }
                                            }
                                        
                                        
                                        
                                    }else if ([button2.titleLabel.text isEqualToString:@"时间"]){
                                        
                                        NSInteger count = temp1.count;
                                        int i, j;
                                        for (j = 0; j < count - 1; j++)
                                            for (i = 0; i < count - 1 - j; i++)
                                            {
                                                FileModel *model1 = temp1[i];
                                                FileModel *model2 = temp1[i+1];
                                                if (model1.date.timeIntervalSince1970 < model2.date.timeIntervalSince1970) {
                                                    
                                                    [temp1 exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                                                }
                                            }
                                        
                                        
                                    }else if ([button2.titleLabel.text isEqualToString:@"名称"]){
                                        
                                        
                                        NSMutableArray *nameArr = [NSMutableArray array];
                                        for (FileModel *model in temp1) {
                                            [nameArr addObject:model.name];
                                        }
                                        NSMutableArray *letterResultArr = [ChineseString LetterSortArray:nameArr];
                                        NSMutableArray *temp2 = [NSMutableArray array];
                                        for (int i = 0;i < letterResultArr.count; i++) {
                                            NSArray *subArr =  letterResultArr[i];
                                            for (NSString *name in subArr) {
                                                
                                                [temp2 addObject:name];
                                            }
                                            
                                        }
                                        NSMutableArray *temp3 = [NSMutableArray array];
                                        
                                        for (int i = 0; i < temp2.count; i++) {
                                            
                                            NSString *name = temp2[i];
                                            
                                            for (FileModel *model in temp1){
                                                if ([[[[[[model.name stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"《" withString:@""] stringByReplacingOccurrencesOfString:@"》" withString:@""] stringByReplacingOccurrencesOfString:@"_" withString:@""]isEqualToString:name]) {
                                                    
                                                    [temp3 addObject:model];
                                                }
                                            }
                                            
                                            
                                        }
                                        
                                        temp1 = temp3;
                                    }
                                }
                                
                                
                                self.files = temp1;
                            }else{
                                NSMutableArray *temp1 = [NSMutableArray array];
                                
                                temp1 = self.files;
                                
                                if (temp1.count > 1) {
                                    if ([button2.titleLabel.text isEqualToString:@"大小"]) {
                                        NSInteger count = temp1.count;
                                        int i, j;
                                        for (j = 0; j < count - 1; j++)
                                            for (i = 0; i < count - 1 - j; i++)
                                            {
                                                FileModel *model1 = temp1[i];
                                                FileModel *model2 = temp1[i+1];
                                                if (model1.realitySize < model2.realitySize) {
                                                    
                                                    [temp1 exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                                                }
                                            }
                                        
                                        
                                        
                                    }else if ([button2.titleLabel.text isEqualToString:@"时间"]){
                                        
                                        NSInteger count = temp1.count;
                                        int i, j;
                                        for (j = 0; j < count - 1; j++)
                                            for (i = 0; i < count - 1 - j; i++)
                                            {
                                                FileModel *model1 = temp1[i];
                                                FileModel *model2 = temp1[i+1];
                                                if (model1.date.timeIntervalSince1970 < model2.date.timeIntervalSince1970) {
                                                    
                                                    [temp1 exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                                                }
                                            }
                                        
                                        
                                    }else if ([button2.titleLabel.text isEqualToString:@"名称"]){
                                        
                                        
                                        NSMutableArray *nameArr = [NSMutableArray array];
                                        for (FileModel *model in temp1) {
                                            [nameArr addObject:model.name];
                                        }
                                        NSMutableArray *letterResultArr = [ChineseString LetterSortArray:nameArr];
                                        NSMutableArray *temp2 = [NSMutableArray array];
                                        for (int i = 0;i < letterResultArr.count; i++) {
                                            NSArray *subArr =  letterResultArr[i];
                                            for (NSString *name in subArr) {
                                                
                                                [temp2 addObject:name];
                                            }
                                            
                                        }
                                        NSMutableArray *temp3 = [NSMutableArray array];
                                        
                                        for (int i = 0; i < temp2.count; i++) {
                                            
                                            FileModel *model = self.files[i];
                                            NSString *name = temp2[i];
                                            if ([model.name isEqualToString:name]) {
                                                
                                                
                                                if ([[[[[[model.name stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"《" withString:@""] stringByReplacingOccurrencesOfString:@"》" withString:@""] stringByReplacingOccurrencesOfString:@"_" withString:@""]isEqualToString:name]) {
                                                    
                                                    [temp3 addObject:model];
                                                }
                                            }
                                        }
                                        
                                        temp1 = temp3;
                                    }
                                }
                                
                                
                                self.files = temp1;
                                
                            }
                            
                        }
                        
                        if (self.files.count > 0) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.tableView reloadData];
                            });
                            self.tableView.hidden = NO;
                        }else{
                            self.tableView.hidden = YES;
                            
                            
                        }
//                        [self.tableView.header endRefreshing];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView.header endRefreshing];
                        });
                        
                        
                    }
                    
                    
                }else{
                    
                    if (i == self.contentPaths.count - 1) {
                        
                        
                        if (self.files.count > 0) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.tableView reloadData];
                            });
                            self.tableView.hidden = NO;
                        }else{
                            self.tableView.hidden = YES;
                            
                            
                        }
//                        [self.tableView.header endRefreshing];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView.header endRefreshing];
                        });
                        
                        
                    }
                }
            }else{
                {//代码块
                    UIButton *button1 = (UIButton *)[self.filterBackView viewWithTag:2000];
                    UIButton *button2 = (UIButton *)[self.filterBackView viewWithTag:2001];
                    
                    if ([button1.titleLabel.text isEqualToString:@"文档"]) {
                        
                        NSMutableArray *temp1 = [NSMutableArray array];
                        
                        for (FileModel *model in self.files) {
                            
                            if (model.fileType == Word || model.fileType == Excel || model.fileType == PowerPoint ||model.fileType == pdf||model.fileType == txt) {
                                
                                [temp1 addObject:model];
                            }
                            
                        }
                        
                        if (temp1.count > 1) {
                            if ([button2.titleLabel.text isEqualToString:@"大小"]) {
                                NSInteger count = temp1.count;
                                int i, j;
                                for (j = 0; j < count - 1; j++)
                                    for (i = 0; i < count - 1 - j; i++)
                                    {
                                        FileModel *model1 = temp1[i];
                                        FileModel *model2 = temp1[i+1];
                                        if (model1.realitySize < model2.realitySize) {
                                            
                                            [temp1 exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                                        }
                                    }
                                
                                
                                
                            }else if ([button2.titleLabel.text isEqualToString:@"时间"]){
                                
                                NSInteger count = temp1.count;
                                int i, j;
                                for (j = 0; j < count - 1; j++)
                                    for (i = 0; i < count - 1 - j; i++)
                                    {
                                        FileModel *model1 = temp1[i];
                                        FileModel *model2 = temp1[i+1];
                                        if (model1.date.timeIntervalSince1970 < model2.date.timeIntervalSince1970) {
                                            
                                            [temp1 exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                                        }
                                    }
                                
                                
                            }else if ([button2.titleLabel.text isEqualToString:@"名称"]){
                                
                                NSMutableArray *nameArr = [NSMutableArray array];
                                for (FileModel *model in temp1) {
                                    [nameArr addObject:model.name];
                                }
                                NSMutableArray *letterResultArr = [ChineseString LetterSortArray:nameArr];
                                NSMutableArray *temp2 = [NSMutableArray array];
                                for (int i = 0;i < letterResultArr.count; i++) {
                                    NSArray *subArr =  letterResultArr[i];
                                    for (NSString *name in subArr) {
                                        
                                        [temp2 addObject:name];
                                    }
                                    
                                }
                                NSMutableArray *temp3 = [NSMutableArray array];
                                
                                for (int i = 0; i < temp2.count; i++) {
                                    
                                    NSString *name = temp2[i];
                                    
                                    for (FileModel *model in temp1){
                                        
                                        if ([[[[[[model.name stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"《" withString:@""] stringByReplacingOccurrencesOfString:@"》" withString:@""] stringByReplacingOccurrencesOfString:@"_" withString:@""]isEqualToString:name]) {
                                            
                                            [temp3 addObject:model];
                                        }
                                    }
                                    
                                    
                                }
                                
                                temp1 = temp3;
                            }
                        }
                        
                        
                        self.files = temp1;
                    }else if ([button1.titleLabel.text isEqualToString:@"文件夹"]){
                        NSMutableArray *temp1 = [NSMutableArray array];
                        
                        for (FileModel *model in self.files) {
                            
                            if (model.fileType == folder) {
                                
                                [temp1 addObject:model];
                            }
                            
                        }
                        
                        if (temp1.count > 1) {
                            if ([button2.titleLabel.text isEqualToString:@"大小"]) {
                                NSInteger count = temp1.count;
                                int i, j;
                                for (j = 0; j < count - 1; j++)
                                    for (i = 0; i < count - 1 - j; i++)
                                    {
                                        FileModel *model1 = temp1[i];
                                        FileModel *model2 = temp1[i+1];
                                        if (model1.realitySize < model2.realitySize) {
                                            
                                            [temp1 exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                                        }
                                    }
                                
                                
                                
                            }else if ([button2.titleLabel.text isEqualToString:@"时间"]){
                                
                                NSInteger count = temp1.count;
                                int i, j;
                                for (j = 0; j < count - 1; j++)
                                    for (i = 0; i < count - 1 - j; i++)
                                    {
                                        FileModel *model1 = temp1[i];
                                        FileModel *model2 = temp1[i+1];
                                        if (model1.date.timeIntervalSince1970 < model2.date.timeIntervalSince1970) {
                                            
                                            [temp1 exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                                        }
                                    }
                                
                                
                            }else if ([button2.titleLabel.text isEqualToString:@"名称"]){
                                
                                
                                NSMutableArray *nameArr = [NSMutableArray array];
                                for (FileModel *model in temp1) {
                                    [nameArr addObject:model.name];
                                }
                                NSMutableArray *letterResultArr = [ChineseString LetterSortArray:nameArr];
                                NSMutableArray *temp2 = [NSMutableArray array];
                                for (int i = 0;i < letterResultArr.count; i++) {
                                    NSArray *subArr =  letterResultArr[i];
                                    for (NSString *name in subArr) {
                                        
                                        [temp2 addObject:name];
                                    }
                                    
                                }
                                NSMutableArray *temp3 = [NSMutableArray array];
                                
                                for (int i = 0; i < temp2.count; i++) {
                                    
                                    NSString *name = temp2[i];
                                    
                                    for (FileModel *model in temp1){
                                        
                                        if ([[[[[[model.name stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"《" withString:@""] stringByReplacingOccurrencesOfString:@"》" withString:@""] stringByReplacingOccurrencesOfString:@"_" withString:@""]isEqualToString:name]) {
                                            
                                            [temp3 addObject:model];
                                        }
                                    }
                                    
                                    
                                }
                                
                                temp1 = temp3;
                            }
                        }
                        
                        
                        self.files = temp1;
                        
                    }else if ([button1.titleLabel.text isEqualToString:@"音乐"]){
                        NSMutableArray *temp1 = [NSMutableArray array];
                        
                        for (FileModel *model in self.files) {
                            
                            if (model.fileType == music) {
                                
                                [temp1 addObject:model];
                            }
                            
                        }
                        
                        if (temp1.count > 1) {
                            if ([button2.titleLabel.text isEqualToString:@"大小"]) {
                                NSInteger count = temp1.count;
                                int i, j;
                                for (j = 0; j < count - 1; j++)
                                    for (i = 0; i < count - 1 - j; i++)
                                    {
                                        FileModel *model1 = temp1[i];
                                        FileModel *model2 = temp1[i+1];
                                        if (model1.realitySize < model2.realitySize) {
                                            
                                            [temp1 exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                                        }
                                    }
                                
                                
                                
                            }else if ([button2.titleLabel.text isEqualToString:@"时间"]){
                                
                                NSInteger count = temp1.count;
                                int i, j;
                                for (j = 0; j < count - 1; j++)
                                    for (i = 0; i < count - 1 - j; i++)
                                    {
                                        FileModel *model1 = temp1[i];
                                        FileModel *model2 = temp1[i+1];
                                        if (model1.date.timeIntervalSince1970 < model2.date.timeIntervalSince1970) {
                                            
                                            [temp1 exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                                        }
                                    }
                                
                                
                            }else if ([button2.titleLabel.text isEqualToString:@"名称"]){
                                
                                
                                NSMutableArray *nameArr = [NSMutableArray array];
                                for (FileModel *model in temp1) {
                                    [nameArr addObject:model.name];
                                }
                                NSMutableArray *letterResultArr = [ChineseString LetterSortArray:nameArr];
                                NSMutableArray *temp2 = [NSMutableArray array];
                                for (int i = 0;i < letterResultArr.count; i++) {
                                    NSArray *subArr =  letterResultArr[i];
                                    for (NSString *name in subArr) {
                                        
                                        [temp2 addObject:name];
                                    }
                                    
                                }
                                NSMutableArray *temp3 = [NSMutableArray array];
                                
                                for (int i = 0; i < temp2.count; i++) {
                                    
                                    NSString *name = temp2[i];
                                    
                                    for (FileModel *model in temp1){
                                        
                                        if ([[[[[[model.name stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"《" withString:@""] stringByReplacingOccurrencesOfString:@"》" withString:@""] stringByReplacingOccurrencesOfString:@"_" withString:@""]isEqualToString:name]) {
                                            
                                            [temp3 addObject:model];
                                        }
                                        
                                    }
                                    
                                    
                                }
                                
                                temp1 = temp3;
                            }
                        }
                        
                        
                        self.files = temp1;
                        
                    }else if ([button1.titleLabel.text isEqualToString:@"视频"]){
                        NSMutableArray *temp1 = [NSMutableArray array];
                        
                        for (FileModel *model in self.files) {
                            
                            if (model.fileType == video) {
                                
                                [temp1 addObject:model];
                            }
                            
                        }
                        
                        if (temp1.count > 1) {
                            if ([button2.titleLabel.text isEqualToString:@"大小"]) {
                                NSInteger count = temp1.count;
                                int i, j;
                                for (j = 0; j < count - 1; j++)
                                    for (i = 0; i < count - 1 - j; i++)
                                    {
                                        FileModel *model1 = temp1[i];
                                        FileModel *model2 = temp1[i+1];
                                        if (model1.realitySize < model2.realitySize) {
                                            
                                            [temp1 exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                                        }
                                    }
                                
                                
                                
                            }else if ([button2.titleLabel.text isEqualToString:@"时间"]){
                                
                                NSInteger count = temp1.count;
                                int i, j;
                                for (j = 0; j < count - 1; j++)
                                    for (i = 0; i < count - 1 - j; i++)
                                    {
                                        FileModel *model1 = temp1[i];
                                        FileModel *model2 = temp1[i+1];
                                        if (model1.date.timeIntervalSince1970 < model2.date.timeIntervalSince1970) {
                                            
                                            [temp1 exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                                        }
                                    }
                                
                                
                            }else if ([button2.titleLabel.text isEqualToString:@"名称"]){
                                
                                NSMutableArray *nameArr = [NSMutableArray array];
                                for (FileModel *model in temp1) {
                                    [nameArr addObject:model.name];
                                }
                                NSMutableArray *letterResultArr = [ChineseString LetterSortArray:nameArr];
                                NSMutableArray *temp2 = [NSMutableArray array];
                                for (int i = 0;i < letterResultArr.count; i++) {
                                    NSArray *subArr =  letterResultArr[i];
                                    for (NSString *name in subArr) {
                                        
                                        [temp2 addObject:name];
                                    }
                                    
                                }
                                NSMutableArray *temp3 = [NSMutableArray array];
                                
                                for (int i = 0; i < temp2.count; i++) {
                                    
                                    NSString *name = temp2[i];
                                    
                                    for (FileModel *model in temp1){
                                        if ([[[[[[model.name stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"《" withString:@""] stringByReplacingOccurrencesOfString:@"》" withString:@""] stringByReplacingOccurrencesOfString:@"_" withString:@""]isEqualToString:name]) {
                                            
                                            [temp3 addObject:model];
                                        }
                                    }
                                    
                                    
                                }
                                
                                temp1 = temp3;
                            }
                        }
                        
                        
                        self.files = temp1;
                        
                    }else if ([button1.titleLabel.text isEqualToString:@"图片"]){
                        NSMutableArray *temp1 = [NSMutableArray array];
                        
                        for (FileModel *model in self.files) {
                            
                            if (model.fileType == image) {
                                
                                [temp1 addObject:model];
                            }
                            
                        }
                        
                        if (temp1.count > 1) {
                            if ([button2.titleLabel.text isEqualToString:@"大小"]) {
                                NSInteger count = temp1.count;
                                int i, j;
                                for (j = 0; j < count - 1; j++)
                                    for (i = 0; i < count - 1 - j; i++)
                                    {
                                        FileModel *model1 = temp1[i];
                                        FileModel *model2 = temp1[i+1];
                                        if (model1.realitySize < model2.realitySize) {
                                            
                                            [temp1 exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                                        }
                                    }
                                
                                
                                
                            }else if ([button2.titleLabel.text isEqualToString:@"时间"]){
                                
                                NSInteger count = temp1.count;
                                int i, j;
                                for (j = 0; j < count - 1; j++)
                                    for (i = 0; i < count - 1 - j; i++)
                                    {
                                        FileModel *model1 = temp1[i];
                                        FileModel *model2 = temp1[i+1];
                                        if (model1.date.timeIntervalSince1970 < model2.date.timeIntervalSince1970) {
                                            
                                            [temp1 exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                                        }
                                    }
                                
                                
                            }else if ([button2.titleLabel.text isEqualToString:@"名称"]){
                                
                                
                                NSMutableArray *nameArr = [NSMutableArray array];
                                for (FileModel *model in temp1) {
                                    [nameArr addObject:model.name];
                                }
                                NSMutableArray *letterResultArr = [ChineseString LetterSortArray:nameArr];
                                NSMutableArray *temp2 = [NSMutableArray array];
                                for (int i = 0;i < letterResultArr.count; i++) {
                                    NSArray *subArr =  letterResultArr[i];
                                    for (NSString *name in subArr) {
                                        
                                        [temp2 addObject:name];
                                    }
                                    
                                }
                                NSMutableArray *temp3 = [NSMutableArray array];
                                
                                for (int i = 0; i < temp2.count; i++) {
                                    
                                    NSString *name = temp2[i];
                                    
                                    for (FileModel *model in temp1){
                                        
                                        if ([[[[[[model.name stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"《" withString:@""] stringByReplacingOccurrencesOfString:@"》" withString:@""] stringByReplacingOccurrencesOfString:@"_" withString:@""]isEqualToString:name]) {
                                            
                                            [temp3 addObject:model];
                                        }
                                    }
                                    
                                    
                                }
                                
                                temp1 = temp3;
                            }
                        }
                        
                        
                        self.files = temp1;
                        
                    }else if ([button1.titleLabel.text isEqualToString:@"压缩文件"]){
                        NSMutableArray *temp1 = [NSMutableArray array];
                        
                        for (FileModel *model in self.files) {
                            
                            if (model.fileType == zip) {
                                
                                [temp1 addObject:model];
                            }
                            
                        }
                        
                        if (temp1.count > 1) {
                            if ([button2.titleLabel.text isEqualToString:@"大小"]) {
                                NSInteger count = temp1.count;
                                int i, j;
                                for (j = 0; j < count - 1; j++)
                                    for (i = 0; i < count - 1 - j; i++)
                                    {
                                        FileModel *model1 = temp1[i];
                                        FileModel *model2 = temp1[i+1];
                                        if (model1.realitySize < model2.realitySize) {
                                            
                                            [temp1 exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                                        }
                                    }
                                
                                
                                
                            }else if ([button2.titleLabel.text isEqualToString:@"时间"]){
                                
                                NSInteger count = temp1.count;
                                int i, j;
                                for (j = 0; j < count - 1; j++)
                                    for (i = 0; i < count - 1 - j; i++)
                                    {
                                        FileModel *model1 = temp1[i];
                                        FileModel *model2 = temp1[i+1];
                                        if (model1.date.timeIntervalSince1970 < model2.date.timeIntervalSince1970) {
                                            
                                            [temp1 exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                                        }
                                    }
                                
                                
                            }else if ([button2.titleLabel.text isEqualToString:@"名称"]){
                                
                                NSMutableArray *nameArr = [NSMutableArray array];
                                for (FileModel *model in temp1) {
                                    [nameArr addObject:model.name];
                                }
                                NSMutableArray *letterResultArr = [ChineseString LetterSortArray:nameArr];
                                NSMutableArray *temp2 = [NSMutableArray array];
                                for (int i = 0;i < letterResultArr.count; i++) {
                                    NSArray *subArr =  letterResultArr[i];
                                    for (NSString *name in subArr) {
                                        
                                        [temp2 addObject:name];
                                    }
                                    
                                }
                                NSMutableArray *temp3 = [NSMutableArray array];
                                
                                for (int i = 0; i < temp2.count; i++) {
                                    
                                    NSString *name = temp2[i];
                                    
                                    for (FileModel *model in temp1){
                                        
                                        if ([[[[[[model.name stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"《" withString:@""] stringByReplacingOccurrencesOfString:@"》" withString:@""] stringByReplacingOccurrencesOfString:@"_" withString:@""]isEqualToString:name]) {
                                            
                                            [temp3 addObject:model];
                                        }
                                    }
                                    
                                    
                                }
                                
                                temp1 = temp3;
                            }
                        }
                        
                        
                        self.files = temp1;
                        
                    }else if ([button1.titleLabel.text isEqualToString:@"其他"]){
                        
                        NSMutableArray *temp1 = [NSMutableArray array];
                        
                        for (FileModel *model in self.files) {
                            
                            if (model.fileType == other) {
                                
                                [temp1 addObject:model];
                            }
                            
                        }
                        
                        if (temp1.count > 1) {
                            if ([button2.titleLabel.text isEqualToString:@"大小"]) {
                                NSInteger count = temp1.count;
                                int i, j;
                                for (j = 0; j < count - 1; j++)
                                    for (i = 0; i < count - 1 - j; i++)
                                    {
                                        FileModel *model1 = temp1[i];
                                        FileModel *model2 = temp1[i+1];
                                        if (model1.realitySize < model2.realitySize) {
                                            
                                            [temp1 exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                                        }
                                    }
                                
                                
                                
                            }else if ([button2.titleLabel.text isEqualToString:@"时间"]){
                                
                                NSInteger count = temp1.count;
                                int i, j;
                                for (j = 0; j < count - 1; j++)
                                    for (i = 0; i < count - 1 - j; i++)
                                    {
                                        FileModel *model1 = temp1[i];
                                        FileModel *model2 = temp1[i+1];
                                        if (model1.date.timeIntervalSince1970 < model2.date.timeIntervalSince1970) {
                                            
                                            [temp1 exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                                        }
                                    }
                                
                                
                            }else if ([button2.titleLabel.text isEqualToString:@"名称"]){
                                
                                
                                NSMutableArray *nameArr = [NSMutableArray array];
                                for (FileModel *model in temp1) {
                                    [nameArr addObject:model.name];
                                }
                                NSMutableArray *letterResultArr = [ChineseString LetterSortArray:nameArr];
                                NSMutableArray *temp2 = [NSMutableArray array];
                                for (int i = 0;i < letterResultArr.count; i++) {
                                    NSArray *subArr =  letterResultArr[i];
                                    for (NSString *name in subArr) {
                                        
                                        [temp2 addObject:name];
                                    }
                                    
                                }
                                NSMutableArray *temp3 = [NSMutableArray array];
                                
                                for (int i = 0; i < temp2.count; i++) {
                                    
                                    NSString *name = temp2[i];
                                    
                                    for (FileModel *model in temp1){
                                        if ([[[[[[model.name stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"《" withString:@""] stringByReplacingOccurrencesOfString:@"》" withString:@""] stringByReplacingOccurrencesOfString:@"_" withString:@""]isEqualToString:name]) {
                                            
                                            [temp3 addObject:model];
                                        }
                                    }
                                    
                                    
                                }
                                
                                temp1 = temp3;
                            }
                        }
                        
                        
                        self.files = temp1;
                    }else{
                        NSMutableArray *temp1 = [NSMutableArray array];
                        
                        temp1 = self.files;
                        
                        if (temp1.count > 1) {
                            if ([button2.titleLabel.text isEqualToString:@"大小"]) {
                                NSInteger count = temp1.count;
                                int i, j;
                                for (j = 0; j < count - 1; j++)
                                    for (i = 0; i < count - 1 - j; i++)
                                    {
                                        FileModel *model1 = temp1[i];
                                        FileModel *model2 = temp1[i+1];
                                        if (model1.realitySize < model2.realitySize) {
                                            
                                            [temp1 exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                                        }
                                    }
                                
                                
                                
                            }else if ([button2.titleLabel.text isEqualToString:@"时间"]){
                                
                                NSInteger count = temp1.count;
                                int i, j;
                                for (j = 0; j < count - 1; j++)
                                    for (i = 0; i < count - 1 - j; i++)
                                    {
                                        FileModel *model1 = temp1[i];
                                        FileModel *model2 = temp1[i+1];
                                        if (model1.date.timeIntervalSince1970 < model2.date.timeIntervalSince1970) {
                                            
                                            [temp1 exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                                        }
                                    }
                                
                                
                            }else if ([button2.titleLabel.text isEqualToString:@"名称"]){
                                
                                
                                NSMutableArray *nameArr = [NSMutableArray array];
                                for (FileModel *model in temp1) {
                                    [nameArr addObject:model.name];
                                }
                                NSMutableArray *letterResultArr = [ChineseString LetterSortArray:nameArr];
                                NSMutableArray *temp2 = [NSMutableArray array];
                                for (int i = 0;i < letterResultArr.count; i++) {
                                    NSArray *subArr =  letterResultArr[i];
                                    for (NSString *name in subArr) {
                                        
                                        [temp2 addObject:name];
                                    }
                                    
                                }
                                NSMutableArray *temp3 = [NSMutableArray array];
                                
                                for (int i = 0; i < temp2.count; i++) {
                                    
                                    FileModel *model = self.files[i];
                                    NSString *name = temp2[i];
                                    if ([model.name isEqualToString:name]) {
                                        
                                        
                                        if ([[[[[[model.name stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"《" withString:@""] stringByReplacingOccurrencesOfString:@"》" withString:@""] stringByReplacingOccurrencesOfString:@"_" withString:@""]isEqualToString:name]) {
                                            
                                            [temp3 addObject:model];
                                        }
                                    }
                                }
                                
                                temp1 = temp3;
                            }
                        }
                        
                        
                        self.files = temp1;
                        
                    }
                    
                }
                if (self.files.count > 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                    
                    self.tableView.hidden = NO;
                }else{
                    self.tableView.hidden = YES;
                    
                    
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                   [self.tableView.header endRefreshing];
                });
                
                
                
            }
            
        }
    });
   
    
}



- (void)_createFilterViews{
    
    self.blackBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    [self.view addSubview:self.blackBackView];
    self.blackBackView.backgroundColor = [UIColor blackColor];
    self.blackBackView.alpha = 0;
    self.filterBackView = [[UIView alloc]initWithFrame:CGRectMake(0, KNavigationBarHeight, KScreenWidth, 40)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenFilterView)];
    [self.blackBackView addGestureRecognizer:tap];

    self.filterBackView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.filterBackView];
//    UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 39.5, KScreenWidth, .5)];
//    line1.backgroundColor = [UIColor colorWithWhite:0.161 alpha:1.000];
//    [self.filterBackView addSubview:line1];
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(KScreenWidth / 2 - .25, 5, .5, 30)];
    line2.backgroundColor = [UIColor colorWithWhite:0.161 alpha:1.000];
    [self.filterBackView addSubview:line2];
    CGFloat width = (KScreenWidth- 80) / 2 ;
    for (int i = 0 ; i < 2; i++) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

        button.frame = CGRectMake(20 + i * (width + 40 ),0,width,40);
        button.tag = 2000 + i;
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"下拉箭头"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"上拉箭头"] forState:UIControlStateSelected];
        if (i == 0) {
            [button setTitle:_filterTitles1.firstObject forState:UIControlStateNormal];
        }else{
            [button setTitle:_filterTitles2.firstObject forState:UIControlStateNormal];
        }
        [button addTarget:self action:@selector(filterClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.filterBackView addSubview:button];

    }
    
    self.filterTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view insertSubview:self.filterTableView belowSubview:self.filterBackView];
    self.filterTableView.delegate = self;
    self.filterTableView.dataSource = self;
    
}
- (void)hiddenFilterView{
    
    
           UIButton *button =(UIButton *) [self.filterBackView viewWithTag:_currentFilterTag];
    button.selected = NO;
        [UIView animateWithDuration:.25 animations:^{
        
        self.filterTableView.transform = CGAffineTransformIdentity;
        self.blackBackView.alpha = 0;
        }];
    
    

    
}
- (void)filterClick:(UIButton *)button{
    button.selected = !button.selected;
        if (button.selected) {
            
            self.filterTableView.transform = CGAffineTransformIdentity;
            _currentFilterTag = button.tag;

        [self.filterTableView reloadData];
        if (button.tag == 2000) {
            
             UIButton *sender =(UIButton *) [self.filterBackView viewWithTag:2001];
            sender.selected = NO;
            NSInteger row = _filterTitles1.count;
            CGFloat y =  - (40.0 * row)+KNavigationBarHeight+40;
            self.filterTableView.frame = CGRectMake(0, y, KScreenWidth, 40 * _filterTitles1.count);
            [UIView animateWithDuration:.25 animations:^{
                self.filterTableView.transform = CGAffineTransformMakeTranslation(0,row * 40.0);
                self.blackBackView.alpha = .6;
            }];
        }else{
            NSInteger row = _filterTitles2.count;
            CGFloat y =  - (40.0 * row)+KNavigationBarHeight+40;
            UIButton *sender =(UIButton *) [self.filterBackView viewWithTag:2000];
            sender.selected = NO;
            self.filterTableView.frame = CGRectMake(0,y, KScreenWidth, 40 * _filterTitles2.count);
            [UIView animateWithDuration:.25 animations:^{
                self.filterTableView.transform = CGAffineTransformMakeTranslation(0,row*40.0);
                self.blackBackView.alpha = .6;
            }];
        }

    }else{
        
        
            [UIView animateWithDuration:.25 animations:^{
                
                self.filterTableView.transform = CGAffineTransformIdentity;
                self.blackBackView.alpha = 0;
            }];
  
        
        
    }

    
    
}
- (void)_creatTableView{
    
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 40+KNavigationBarHeight, KScreenWidth,KScreenHeight - 40-KNavigationBarHeight) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"FileCell" bundle:nil] forCellReuseIdentifier:@"FileCell"];
    self.tableView.backgroundColor = [UIColor colorWithRed:0.848 green:0.879 blue:0.850 alpha:1.000];
   self.tableView.header =  [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getLocationFiles)];
    self.tableView.footer = nil;

}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([tableView isEqual:self.filterTableView]) {
        if (_currentFilterTag == 2000) {
            return _filterTitles1.count;
        }else{
            return _filterTitles2.count;
        }
        
        
    }
    
    return self.files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView isEqual:self.filterTableView]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"filter_cell"];
        if (!cell) {
             cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"filter_cell"];
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            
        }
        UIButton *button = (UIButton *)[self.filterBackView viewWithTag:_currentFilterTag];
        if (_currentFilterTag == 2000) {
            cell.textLabel.text = _filterTitles1[indexPath.row];
          
        }else{
            
            cell.textLabel.text = _filterTitles2[indexPath.row];
            
        }
        if ([cell.textLabel.text isEqualToString:button.titleLabel.text]) {
            cell.textLabel.textColor = [UIColor colorWithRed:0.294 green:0.531 blue:1.000 alpha:1.000];
        }else{
            cell.textLabel.textColor = [UIColor colorWithRed:0.114 green:0.115 blue:0.118 alpha:1.000];
        }
        return cell;
        
    }
    
    FileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileCell" forIndexPath:indexPath];
    
    cell.model = self.files[indexPath.row];
    
    if (cell.model.fileType == image) {
        
        cell.logoImageView.image = [UIImage imageWithContentsOfFile:cell.model.path];
        
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView isEqual:self.filterTableView]) {
        UIButton *button = (UIButton *)[self.filterBackView viewWithTag:_currentFilterTag];

        if (_currentFilterTag == 2000) {
           
            [button setTitle:_filterTitles1[indexPath.row] forState:UIControlStateNormal];
            

        }else{
           
            [button setTitle:_filterTitles2[indexPath.row] forState:UIControlStateNormal];
            
        }
        [self hiddenFilterView];
        _currentFilterTag = 0;
        [self.tableView.header beginRefreshing];
        return;
    }
    
    
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
    if ([tableView isEqual:self.filterTableView]) {
        return 40;
    }
    return 60;
}
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    
//    return 0.000001;
//}
- (CGFloat )tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 2.5;
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
