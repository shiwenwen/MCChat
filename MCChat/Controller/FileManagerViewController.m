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
@interface FileManagerViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong)NSMutableArray *files;
@property (nonatomic,strong)UITableView *tableView;
@end

@implementation FileManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"文件管理";
    [self _creatTableView];

}
- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
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
            self.files = [NSMutableArray arrayWithCapacity:subPaths.count];
            for (NSString *subPath in subPaths) {
                
                NSLog(@"subPath = %@",subPath);
                NSError *error;
               NSDictionary *fileAttr =  [fileManager attributesOfItemAtPath:[BasePath stringByAppendingPathComponent:subPath] error:&error];

                NSLog(@"fileAttr ==== %@",fileAttr);
                
                /*
                 fileAttr ==== {
                 NSFileCreationDate = "2016-03-01 10:46:27 +0000";
                 NSFileExtensionHidden = 0;
                 NSFileGroupOwnerAccountID = 501;
                 NSFileGroupOwnerAccountName = mobile;
                 NSFileModificationDate = "2016-03-01 10:46:27 +0000";
                 NSFileOwnerAccountID = 501;
                 NSFileOwnerAccountName = mobile;
                 NSFilePosixPermissions = 420;
                 NSFileProtectionKey = NSFileProtectionCompleteUntilFirstUserAuthentication;
                 NSFileReferenceCount = 1;
                 NSFileSize = 16220;
                 NSFileSystemFileNumber = 17553603;
                 NSFileSystemNumber = 16777220;
                 NSFileType = NSFileTypeRegular;
                 }
                 */
                
                NSString *fileSize = [self fileSizeTransform:[fileAttr[@"NSFileSize"] floatValue]];
                
                NSDate *modificationDate = fileAttr[@"NSFileModificationDate"];
                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                NSString *dateStr = [formatter stringFromDate:modificationDate];
                
                
                NSRange range = [subPath rangeOfString:@"."];
                
                NSString *extension;
                
                if (range.location != NSNotFound) {
                    
                    extension = [subPath substringFromIndex:range.location + 1];
                    
                    
                }
                
                FileType type = other;
                
                /*
                 Word,//doc,docx
                 Excel,//xls,xlsx
                 PowerPoint,//ppt,pptx
                 music,//mp3,wma,mac,aac,wav...
                 video,//RMVB、WMV、ASF、AVI、3GP、MPG、MKV、MP4、OGM、MOV、MPEG2、MPEG4
                 image,//GIF、JPEG、BMP、TIF、JPG、PCD、QTI、QTF、TIFF
                 txt,
                  zip,//rar,zip,tar,cab,uue,jar,iso,z,7-zip,ace,lzh,arj,gzip,bz2
                 other
                 */
               extension = [extension lowercaseString];
                if ([extension isEqualToString:@"doc"]||[extension isEqualToString:@"docx"]) {
                    type = Word;
                }else if ([extension isEqualToString:@"xls"]||[extension isEqualToString:@"xlsx"]){
                    
                    type = Excel;
                
                }else if ([extension isEqualToString:@"ppt"]||[extension isEqualToString:@"pptx"]){
                    
                    type = PowerPoint;
                }
                else if ([extension isEqualToString:@"mp3"]||[extension isEqualToString:@"wma"]||[extension isEqualToString:@"mac"]||[extension isEqualToString:@"aac"]||[extension isEqualToString:@"wav"]){
                    
                    
                    type = music;
                    
                }else if ([extension isEqualToString:@"rmvb"]||[extension isEqualToString:@"wmv"]||[extension isEqualToString:@"asf"]||[extension isEqualToString:@"avi"]||[extension isEqualToString:@"3gp"]||[extension isEqualToString:@"mpg"]||[extension isEqualToString:@"mkv"]||[extension isEqualToString:@"mp4"]||[extension isEqualToString:@"ogm"]||[extension isEqualToString:@"mov"]||[extension isEqualToString:@"mpeg2"]||[extension isEqualToString:@"mpeg4"]){
                    
                    type = video;
                    
                }else if ([extension isEqualToString:@"gif"]||[extension isEqualToString:@"jpeg"]||[extension isEqualToString:@"bmp"]||[extension isEqualToString:@"tif"]||[extension isEqualToString:@"jpg"]||[extension isEqualToString:@"pcd"]||[extension isEqualToString:@"qti"]||[extension isEqualToString:@"qtf"]||[extension isEqualToString:@"tiff"]){
                    
                    type = image;
                    
                }else if ([extension isEqualToString:@"rar"]||[extension isEqualToString:@"zip"]||[extension isEqualToString:@"tar"]||[extension isEqualToString:@"cab"]||[extension isEqualToString:@"uue"]||[extension isEqualToString:@"jar"]||[extension isEqualToString:@"iso"]||[extension isEqualToString:@"z"]||[extension isEqualToString:@"7-zip"]||[extension isEqualToString:@"gzip"]||[extension isEqualToString:@"bz2"]){
                    
                    type = zip;
                }
                
                FileModel *model = [[FileModel alloc]initWithName:subPath Detail:dateStr size:fileSize FileType:type Path:[BasePath stringByAppendingPathComponent:subPath]];
                
                [self.files addObject:model];
                
            }
            

                [self.tableView reloadData];


        }
        
    }

    
    
    
    
}

- (void)_creatTableView{
    
    
    self.tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"FileCell" bundle:nil] forCellReuseIdentifier:@"FileCell"];
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
    
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
    
    
}

- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
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
