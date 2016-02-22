//
//  SettingViewController.m
//  MCChat
//
//  Created by 石文文 on 16/2/15.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingHeaderIconCell.h"
#import "ChatViewController.h"
#import "ChangeNickNameViewController.h"
#import "ChatBackgroundChoseViewController.h"
#import "MLImageCrop.h"
@interface SettingViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MLImageCropDelegate,UIAlertViewDelegate>
@property (nonatomic,strong)UIImagePickerController *picker;
@end

@implementation SettingViewController
- (instancetype)init
{
    self = [super init];
    if (self) {
        

        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    self.title = @"设置";
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor colorWithWhite:0.905 alpha:1.000];
    self.tableView.backgroundColor = self.view.backgroundColor;
 

}
- (void)initSessionManager{
    ChatViewController *chat = (ChatViewController *)self.navigationController.viewControllers.firstObject;
    
    [chat makeBlueData];
}
- (void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    
    NSInteger number;
    switch (section) {
        case 0:
            number = 2;
            break;
        case 1:
            number = 2;
            break;
        case 2:
            number = 1;
            break;
        default:
            break;
    }
    
    return number;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"setting_cell";
    static NSString *headerId = @"header_cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        SettingHeaderIconCell *headerCell = [tableView dequeueReusableCellWithIdentifier:headerId];
        
        if (!headerCell) {
            
            headerCell = [[NSBundle mainBundle]loadNibNamed:@"SettingHeaderIconCell" owner:nil options:nil].lastObject;
            
            headerCell.headerIcon.backgroundColor = [UIColor grayColor];
            headerCell.selectionStyle = UITableViewCellSelectionStyleNone;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(chooseHeaderIcon)];
            [headerCell.headerIcon addGestureRecognizer:tap];
            if (UserDefaultsGet(@"headerIcon")) {
                
                headerCell.headerIcon.image = [UIImage imageWithContentsOfFile:UserDefaultsGet(@"headerIcon")];
            }
            
        }
        return headerCell;
    }
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    if (indexPath.section == 0 && indexPath.row == 1) {
        
        cell.textLabel.text = UserDefaultsGet(MyNickName)?UserDefaultsGet(MyNickName):[[UIDevice currentDevice]name];
        cell.detailTextLabel.text = @"修改昵称";
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"打开天线";
            cell.detailTextLabel.text = @"让别人搜索到您的设备";
        }else{
            cell.textLabel.text = @"断开连接";
            cell.detailTextLabel.text = @"断开连接将无法继续通讯";
            
        }
        
    }
    if (indexPath.section == 2) {
        
        cell.textLabel.text = @"聊天背景";
        cell.detailTextLabel.text = @"选择";
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.00000001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }
    return 25;
}
- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 120;
    }
    
    return 45;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0 && indexPath.row == 1) {
        //修改昵称
        
        ChangeNickNameViewController *changeName = [[ChangeNickNameViewController alloc]init];
        __weak typeof(self) weakSelf = self;
        
        changeName.changeBlock = ^(NSString *name){
          
            UserDefaultsSet(name, MyNickName);
            [[NSUserDefaults standardUserDefaults]synchronize];
            [weakSelf initSessionManager];
//            dispatch_sync(dispatch_get_main_queue(), ^{
            
                [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//            });
        };
        [self.navigationController pushViewController:changeName animated:YES];
        
    }else if (indexPath.section == 1){
        
        if (indexPath.row == 0) {
            [self.sessionManager advertiseForBrowserViewController];
             [[CustomAlertView shareCustomAlertView]showAlertViewWtihTitle:@"正在扩散..." viewController:nil];
        }else{
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"断开连接" message:@"是否确认断开连接" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            
            [alert show];
        }
        
        
        
    }else if (indexPath.section == 2){
        //聊天背景
        [self.navigationController pushViewController:[[ChatBackgroundChoseViewController alloc]init] animated:YES];
        
    }
    
    
}
- (void)chooseHeaderIcon{
    
    UIActionSheet *chooseImageSheet = [[UIActionSheet alloc] initWithTitle:@"设置头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"照相机",@"相册", nil];
    [chooseImageSheet showInView:self.view];

    
    
}
#pragma mark UIActionSheetDelegate Method
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.picker = [[UIImagePickerController alloc] init];
//    self.picker.allowsEditing = YES;
    self.picker.delegate = self;
    
    switch (buttonIndex) {
        case 0://Take picture
            
            
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                
                self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            }
            
            [self presentViewController:self.picker animated:YES completion:nil];
            
            
            
            break;
            
        case 1:
            //From album
            self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            [self presentViewController:self.picker animated:YES completion:^{
                
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent
                 ];
            }];
            break;
            
        default:
            
            break;
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
            
            
                
                MLImageCrop *imageCrop = [[MLImageCrop alloc]init];
                imageCrop.delegate = self;
                imageCrop.ratioOfWidthAndHeight = 120.0f/120.0f;
                imageCrop.image = image;
                [imageCrop showWithAnimation:YES];

        
    }
    
    
}
- (void)cropImage:(UIImage*)cropImage forOriginalImage:(UIImage*)originalImage{
    
    
    NSData *data;
    NSString *type;
    if (UIImagePNGRepresentation(cropImage) == nil)
    {
        data = UIImageJPEGRepresentation(cropImage, 1.0);
        type = @".jpg";
    }
    else
    {
        data = UIImagePNGRepresentation(cropImage);
        type = @".png";
    }
    
    //图片保存的路径
    //这里将图片放在沙盒的documents文件夹中
    NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    //文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //把刚刚图片转换的data对象拷贝至沙盒中 并保存为image.png
    [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
    [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:[NSString stringWithFormat:@"/icon%@",type]] contents:data attributes:nil];
    
    //得到选择后沙盒中图片的完整路径
    NSString * filePath = [[NSString alloc]initWithFormat:@"%@/icon%@",DocumentsPath,type];
    
    
    UserDefaultsSet(filePath, @"headerIcon");
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ChangeHeaderIcon" object:nil];
    

    [self.picker dismissViewControllerAnimated:YES completion:^{

          [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [self.tableView reloadData];
    }];

    
}

#pragma mark -- alertDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        
        
        [self.sessionManager disconnectSession];
        
        [[CustomAlertView shareCustomAlertView]showAlertViewWtihTitle:@"连接已断开" viewController:nil];
    }
    
    
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
