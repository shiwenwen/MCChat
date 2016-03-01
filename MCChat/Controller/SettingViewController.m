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
#import "HeaderCell.h"
#import "DBGuestureButton.h"
#import "DBGuestureLock.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import <LocalAuthentication/LAContext.h>
#import "FileManagerViewController.h"
@interface SettingViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MLImageCropDelegate,UIAlertViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,DBGuestureLockDelegate>{
    
    UICollectionView *collection;
}
@property (nonatomic,strong)UIImagePickerController *picker;
@property (nonatomic,strong)UIView *LockView;
@property (nonatomic,strong)UILabel *lockStatusLabel;
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

    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    
    NSInteger number;
    switch (section) {
        case 0:
            
            if (self.sessionManager.session.connectedPeers.count > 1) {
                number = 3;
            }else{
                number = 2;
            }

            break;
        case 1:
            number = 2;
            break;
        case 2:
            number = 2;
            break;
        case 3:
        {
            //检查设备是否能用TouchID，返回检查结果BOOL类型success：

            LAContext *context = [[LAContext alloc] init];

            NSError *error;
            BOOL success;
            
            // test if we can evaluate the policy, this test will tell us if Touch ID is available and enrolled
            success = [context canEvaluatePolicy: LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
            if (success) {
                number = 2;
            } else {
                number = 1;
            }
        }
            break;
        default:
            break;
    }
    
    return number;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"setting_cell";
    static NSString *headerId = @"header_cell";
    static NSString *switchIdenti = @"switch_cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (indexPath.section == 0 && indexPath.row == 0) {
        /*
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
         */
        UITableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:headerId];
        
        if (!headerCell) {
            
            
            headerCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:headerId];
            headerCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
            CGFloat size = (KScreenWidth - 10 * 5) / 4;
            layout.itemSize = CGSizeMake(size, size);
            layout.minimumLineSpacing = 10;
            layout.minimumInteritemSpacing = 10;
            layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
            NSInteger line = (self.friendIcon.count + 1) / 4 + ((self.friendIcon.count + 1) % 4 == 0 ? 0:1);
            
            collection = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth,line * (size + 10) + 10 ) collectionViewLayout:layout];
            [collection registerNib:[UINib nibWithNibName:@"HeaderCell" bundle:nil] forCellWithReuseIdentifier:@"HeaderCell"];
            collection.scrollEnabled = NO;
            collection.backgroundColor = [UIColor whiteColor];
            collection.dataSource = self;
            collection.delegate = self;
            [headerCell.contentView addSubview:collection];
            
        }
        
        return headerCell;
    }
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            cell.textLabel.text = UserDefaultsGet(MyNickName)?UserDefaultsGet(MyNickName):[[UIDevice currentDevice]name];
            cell.detailTextLabel.text = @"修改昵称";
        }else if (indexPath.row == 2){
            cell.textLabel.text = @"群聊名称";
            cell.detailTextLabel.text = self.groupName;

        }
        
        
        
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
        if (indexPath.row == 0) {
            cell.textLabel.text = @"聊天背景";
            cell.detailTextLabel.text = @"选择";
        }else{
            cell.textLabel.text = @"文件管理";
            cell.detailTextLabel.text = @"查看";
        }
        
    }
    if (indexPath.section == 3) {
        
        UITableViewCell *switchCell = [tableView dequeueReusableCellWithIdentifier:switchIdenti];
        
        if (!switchCell) {
            switchCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:switchIdenti];
            
            UISwitch *padSwitch = [[UISwitch alloc]initWithFrame:CGRectZero];
            padSwitch.right = KScreenWidth - 25;
            padSwitch.top = (45 - padSwitch.height) / 2.0;
            [switchCell.contentView addSubview:padSwitch];
            padSwitch.tag = 4001;
            
            switchCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        UISwitch *padSwitch = (UISwitch *)[switchCell.contentView viewWithTag:4001];
        
        if (indexPath.row == 0) {
            switchCell.textLabel.text = @"手势锁";
            [padSwitch addTarget:self action:@selector(setGesPsd:) forControlEvents:UIControlEventValueChanged];
            padSwitch.on = [UserDefaultsGet(KHaveGesturePsd) boolValue] ;
            
        }else if (indexPath.row == 1){
            padSwitch.on = [UserDefaultsGet(KHaveFingerprint) boolValue] ;
            switchCell.textLabel.text = @"指纹锁";
            [padSwitch addTarget:self action:@selector(setFingerprint:) forControlEvents:UIControlEventValueChanged];
            
        }

        return switchCell;
        
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
               NSInteger line = (self.friendIcon.count + 1) / 4 + ((self.friendIcon.count + 1) % 4 == 0 ? 0:1);
        CGFloat size = (KScreenWidth - 10 * 5) / 4 + 10;
        return line * size  + 10;
    }
    
    return 45;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        ChangeNickNameViewController *changeName = [[ChangeNickNameViewController alloc]init];
            __weak typeof(self) weakSelf = self;
        if (indexPath.row == 1) {
            

            changeName.style = nickName;
            changeName.placehold = UserDefaultsGet(MyNickName)?UserDefaultsGet(MyNickName):[[UIDevice currentDevice]name];
            changeName.changeBlock = ^(NSString *name, ChangeStyle style){

                    UserDefaultsSet(name, MyNickName);
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    [weakSelf initSessionManager];
                    [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            };
        }else if (indexPath.row == 2){
            changeName.style = groupName;
            changeName.placehold = self.groupName;
             changeName.changeBlock = ^(NSString *name, ChangeStyle style){
                self.groupName = name;
                [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"ChangeGroupName" object:self.groupName];
                
             };
            [self.navigationController pushViewController:changeName animated:YES];
        }

        
    }else if (indexPath.section == 1){
        
        if (indexPath.row == 0) {
            [self.sessionManager advertiseForBrowserViewController];
             [[CustomAlertView shareCustomAlertView]showAlertViewWtihTitle:@"正在扩散..." viewController:nil];
        }else{
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"断开连接" message:@"是否确认断开连接" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            
            [alert show];
        }
        
        
        
    }else if (indexPath.section == 2){
        
        if (indexPath.row == 0) {
            //聊天背景
            [self.navigationController pushViewController:[[ChatBackgroundChoseViewController alloc]init] animated:YES];
        }else{

            [self.navigationController pushViewController:[[FileManagerViewController alloc] init] animated:YES];
                


            
        }
        
        
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
        [collection reloadData];
    }];

    
}

#pragma mark -- alertDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        
        
        [self.sessionManager disconnectSession];
        
        [[CustomAlertView shareCustomAlertView]showAlertViewWtihTitle:@"连接已断开" viewController:nil];
        self.friendIcon  = nil;
        [[NSNotificationCenter defaultCenter]postNotificationName:@"disconnectSession" object:nil];
        [collection reloadData];
    }
    
    
}
#pragma mark -- CollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.friendIcon.count + 1;
    
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    HeaderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HeaderCell" forIndexPath:indexPath];
    if (indexPath.item == 0) {
        
        if (UserDefaultsGet(@"headerIcon")) {
            
            cell.headImageVIew.image = [UIImage imageWithContentsOfFile:UserDefaultsGet(@"headerIcon")];
            
        }else{
            
            
            cell.headImageVIew.image = [UIImage imageNamed:@"无头像"];
            
        }
        cell.headImageVIew.userInteractionEnabled = NO;
        
        
    }else{
        
        cell.headImageVIew.image =[UIImage imageWithData:self.friendIcon[indexPath.item - 1]];
                cell.headImageVIew.userInteractionEnabled = YES;
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (indexPath.item == 0) {
        
        [self chooseHeaderIcon];
        
    }
}

#pragma mark -- 手势锁 指纹锁
- (void)setGesPsd:(UISwitch *)sender{
    
    if (!self.LockView) {
        self.LockView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
        self.LockView.backgroundColor = [UIColor colorWithWhite:0.05 alpha:1];
        self.lockStatusLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, KNavigationBarHeight, KScreenWidth - 40, 80)];
        self.lockStatusLabel.numberOfLines = 0;
        [self.LockView addSubview:self.lockStatusLabel];
        self.lockStatusLabel.font = [UIFont systemFontOfSize:29];
        
        self.lockStatusLabel.textColor = [UIColor whiteColor];
        self.lockStatusLabel.textAlignment = NSTextAlignmentCenter;
        
        UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
        dismissButton.frame = CGRectMake(KScreenWidth - 100, KScreenHeight - 60, 80, 40);
        [self.LockView addSubview:dismissButton];
        [dismissButton setTitle:@"取消" forState:UIControlStateNormal];
        [dismissButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        dismissButton.titleLabel.font = [UIFont systemFontOfSize:21];
        [dismissButton addTarget:self action:@selector(dismissLockView:) forControlEvents:UIControlEventTouchUpInside];
        self.LockView.transform = CGAffineTransformMakeTranslation(0,KScreenHeight);
        
    }
    if (sender.isOn == YES) {
        
        [DBGuestureLock clearGuestureLockPassword]; //just for test
        
       
        self.lockStatusLabel.text = @"绘制解锁图案";
        //Give me a Star: https://github.com/i36lib/DBGuestureLock/
        DBGuestureLock *lock = [DBGuestureLock lockOnView:[UIApplication sharedApplication].keyWindow delegate:self];
        [self.LockView addSubview:lock];
        [[UIApplication sharedApplication].keyWindow addSubview:self.LockView];


        [UIView animateWithDuration:.35 animations:^{
            self.LockView.transform = CGAffineTransformIdentity;
        }];
        
    }else{
        
       
         self.lockStatusLabel.text = @"要关闭手势锁需要先验证解锁图案";
        //Give me a Star: https://github.com/i36lib/DBGuestureLock/
        DBGuestureLock *lock = [DBGuestureLock lockOnView:[UIApplication sharedApplication].keyWindow delegate:self];
        [self.LockView addSubview:lock];
        [[UIApplication sharedApplication].keyWindow addSubview:self.LockView];
        
        
        [UIView animateWithDuration:.35 animations:^{
            self.LockView.transform = CGAffineTransformIdentity;
        }];
        
       
        
        
    }
    
}



- (void)setFingerprint:(UISwitch *)sender{
    
    if (sender.on) {
        if (![UserDefaultsGet(KHaveGesturePsd)boolValue]) {
            [[CustomAlertView shareCustomAlertView]showAlertViewWtihTitle:@"请先开启手势密码" viewController:nil];

            sender.on = NO;
            return;
        }
        [[CustomAlertView shareCustomAlertView]showAlertViewWtihTitle:@"已开启指纹锁" viewController:nil];
        UserDefaultsSet(@(YES), KHaveFingerprint);
    }else{
        
        [sender setOn:YES animated:NO];
        
        //验证
        [self evaluatePolicy];
    }
    
    
}
- (void)dismissLockView:(UIButton *)sender{
    
    
    
    [self.tableView reloadData];
    
    [self hiddenLockView];
    
}


- (void)evaluatePolicy{

    LAContext *context = [[LAContext alloc] init];
    __block  NSString *msg;
    
    // show the authentication UI with our reason string
    [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:NSLocalizedString(@"验证指纹解锁您的APP", nil) reply:
     ^(BOOL success, NSError *authenticationError) {
         if (success) {
             
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
             msg =[NSString stringWithFormat:NSLocalizedString(@"验证成功", nil)];
             
             
             
             UserDefaultsSet(@(NO), KHaveFingerprint);

         } else {
             msg = [NSString stringWithFormat:NSLocalizedString(@"验证错误", nil), authenticationError.localizedDescription];
         }
         
     }];
    
}
#pragma mark - DBGuestureLockDelegate

-(void)guestureLock:(DBGuestureLock *)lock didSetPassword:(NSString *)password {
    //NSLog(@"Password set: %@", password);
    if (lock.firstTimeSetupPassword == nil) {
        lock.firstTimeSetupPassword = password;
        NSLog(@"varify your password");
            self.lockStatusLabel.text = @"请再次绘制解锁图案进行确认";
    }
}

-(void)guestureLock:(DBGuestureLock *)lock didGetCorrectPswd:(NSString *)password {
    //NSLog(@"Pa、ssword correct: %@", password);
    if (lock.firstTimeSetupPassword && ![lock.firstTimeSetupPassword isEqualToString:DBFirstTimeSetupPassword]) {
        lock.firstTimeSetupPassword = DBFirstTimeSetupPassword;
        NSLog(@"password has been setup!");
        self.lockStatusLabel.text = @"设置成功";
        
        [[CustomAlertView shareCustomAlertView]showAlertViewWtihTitle:@"设置成功" viewController:nil];
        UserDefaultsSet(@(YES), KHaveGesturePsd);
        
        [self hiddenLockView];
        
    } else {
        NSLog(@"login success");
    self.lockStatusLabel.text = @"关闭成功";
        
        UserDefaultsSet(@(NO), KHaveGesturePsd);
        [DBGuestureLock clearGuestureLockPassword];
        
        [self hiddenLockView];
        
    }
    
    [self.tableView reloadData];
}
- (void)hiddenLockView{
    
    
    [UIView animateWithDuration:.35 animations:^{
        
        self.LockView.transform = CGAffineTransformMakeTranslation(0,KScreenHeight);
        
    } completion:^(BOOL finished) {
        
        for (UIView *view in  self.LockView.subviews) {
            
            if ([view isKindOfClass:[DBGuestureLock class]]) {
                [view removeFromSuperview];
            }
        }
    }];

    
}

-(void)guestureLock:(DBGuestureLock *)lock didGetIncorrectPswd:(NSString *)password {
    //NSLog(@"Password incorrect: %@", password);
    if (![lock.firstTimeSetupPassword isEqualToString:DBFirstTimeSetupPassword]) {
        NSLog(@"Error: password not equal to first setup!");
    self.lockStatusLabel.text = @"两次绘制图案不一致，请重试";
    } else {
        NSLog(@"login failed");
    self.lockStatusLabel.text = @"手势错误";
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
