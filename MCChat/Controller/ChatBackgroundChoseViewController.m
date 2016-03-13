//
//  ChatBackgroundChoseViewController.m
//  MCChat
//
//  Created by 石文文 on 16/2/15.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import "ChatBackgroundChoseViewController.h"
#import "CLImageEditor.h"
@interface ChatBackgroundChoseViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,CLImageEditorDelegate, CLImageEditorTransitionDelegate, CLImageEditorThemeDelegate>{
    UIImagePickerController *_picker;
}

@end

@implementation ChatBackgroundChoseViewController
- (BOOL)shouldAutorotate{
    return NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择聊天背景";
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.scrollEnabled = NO;
    self.view.backgroundColor = [UIColor colorWithWhite:0.905 alpha:1.000];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent
     ];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 20;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.000001;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"setting_cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.section == 0 ) {
        
        cell.textLabel.text = @"默认背景";
    }
    if (indexPath.section == 1&& indexPath.row == 0) {
        
        cell.textLabel.text = @"相机";

    }
    if (indexPath.section == 1&& indexPath.row == 1) {
        
        cell.textLabel.text = @"从相册选择";

    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0 ) {
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"ChangeDefaultBackground" object:nil];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"bgPath"];
        if ([NSUserDefaults standardUserDefaults].synchronize) {
            [[CustomAlertView shareCustomAlertView]showAlertViewWtihTitle:@"已切换为默认背景" viewController:nil];
            return;
        }
        
    }
    
    _picker = [[UIImagePickerController alloc] init];
    _picker.delegate = self;
    
    if (indexPath.section == 1&& indexPath.row == 0) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            
            _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        
        [self presentViewController:_picker animated:YES completion:nil];
        

        
        
    }
    if (indexPath.section == 1&& indexPath.row == 1) {
        _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:_picker animated:YES completion:^{
            
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }];

       
        
    }
    
    
    
    
}


// 相册
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"])
    {
        
        UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        CLImageEditor *editor = [[CLImageEditor alloc] initWithImage:image];
        
        editor.delegate = self;
        
        [picker pushViewController:editor animated:YES];

        
        
    }
    
    
}
#pragma mark- CLImageEditor delegate

- (void)imageEditor:(CLImageEditor *)editor didFinishEdittingWithImage:(UIImage *)image
{
    
    
    
    [_picker dismissViewControllerAnimated:YES completion:^{
        
        // 改变状态栏的颜色  改变为白色
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
        //先把图片转成NSData
        
        
        
        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
            NSData *data;
            
            NSString *type;
            
            if (UIImagePNGRepresentation(image) == nil)
            {
                data = UIImageJPEGRepresentation(image, 1.0);
                type = @".jpg";
            }
            else
            {
                data = UIImagePNGRepresentation(image);
                type = @".png";
            }
            
            //图片保存的路径
            //这里将图片放在沙盒的documents文件夹中
            NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            
            //文件管理器
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            //把刚刚图片转换的data对象拷贝至沙盒中 并保存为image.png
            [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:NO attributes:nil error:nil];
            BOOL succeed =  [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:[NSString stringWithFormat:@"/背景%@",type]] contents:data attributes:nil];
            
            //得到选择后沙盒中图片的完整路径
            NSString * filePath = [[NSString alloc]initWithFormat:@"%@/背景%@",DocumentsPath,type];
            
            if (succeed) {
                
                UserDefaultsSet(filePath, @"bgPath");
                [[NSUserDefaults standardUserDefaults]synchronize];
                
                [[NSNotificationCenter defaultCenter]postNotificationName:@"changeBg" object:nil];
                
            }else{
                
                
                [[CustomAlertView shareCustomAlertView]showAlertViewWtihTitle:@"切换失败" viewController:nil];
            }
            
            
        });
        
        
        
    }];
    [editor dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageEditor:(CLImageEditor *)editor willDismissWithImageView:(UIImageView *)imageView canceled:(BOOL)canceled
{
    
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
