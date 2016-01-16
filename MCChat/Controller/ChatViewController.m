//
//  ChatViewController.m
//  MCChat
//
//  Created by 石文文 on 16/1/14.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import "ChatViewController.h"
#import "BlueSessionManager.h"
#import "ChatItem.h"
#import "UIViewExt.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "MyChatCell.h"
#import "CustomAlertView.h"
#define HEIGHT [UIScreen mainScreen].bounds.size.height
#define WIDTH [UIScreen mainScreen].bounds.size.width
#define ChatHeight 49.0
#define TextDefaultheight 36.5
#define kRecordAudioFile @"myRecord.caf"
#import "RecordingView.h"
@interface ChatViewController ()<NSStreamDelegate,UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate>{
    
    float _sendBackViewHeight;
    float _keyboardHeight;
    
    UIButton * _emotionButton;
    UIButton *_addButton;
    UIImagePickerController * _picker;
    UIView * _backRemindRecordView;
    CGRect _tabBarFrame;
    NSTimeInterval _puaseTime;
    BOOL _recordCancel;
    UIImageView *_currentVoiceView;
}


// DataAndBlue
@property(strong, nonatomic) BlueSessionManager *sessionManager;

@property(strong, nonatomic) NSMutableArray *datasource;
@property(strong, nonatomic) NSMutableArray * myDataArray;

@property(strong, nonatomic) NSMutableData *streamData;
@property(strong, nonatomic) NSOutputStream *outputStream;
@property(strong, nonatomic) NSInputStream *inputStream;

// UI
@property(strong, nonatomic) UITableView * tableView;
@property(strong, nonatomic) UIView * sendBackView;
@property(strong, nonatomic) UITextView * sendTextView;
@property (strong,nonatomic) UIButton *voiceButton;
@property (strong,nonatomic) UIButton *recorderButton;
@property (nonatomic,strong)RecordingView *recordingView;
// 语音播放
@property (nonatomic,strong) AVAudioRecorder *audioRecorder;//音频录音机
//音频播放器，用于播放录音文件
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;

@property (nonatomic,strong) NSTimer *timer;//录音声波监控（注意这里暂时不对播放进行监控）



@property (strong, nonatomic) UIProgressView *audioPower;//音频波动




@end

@implementation ChatViewController
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"壁纸1.jpg"]];
    
    UIImage *image = [UIImage imageNamed:@"壁纸1.jpg"];
    self.view.layer.contents = (id) image.CGImage;
    self.navigationController.navigationBar.titleTextAttributes =@{
                                                                   NSForegroundColorAttributeName:[UIColor whiteColor]
                                                                   
                                                                   };
//    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
//    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithWhite:0.127 alpha:1.000];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithWhite:0.01 alpha:0.800];
    
    
    [self makeBlueData];
    
    [self readyUI];
    
    [self buildVideoForWe];
    
    //监听键盘通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(fitKeyboardSize:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(fitKeyboardSize:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(fitKeyboardSize:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenKeyboard)];
    [self.view addGestureRecognizer:tap];
    
}


- (void)viewDidAppear:(BOOL)animated{
    
    _tabBarFrame = self.tabVC.view.frame;
   
}
- (void)viewWillAppear:(BOOL)animated{
    
     [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
}
- (void)hiddenKeyboard{
    
    [self.view endEditing:YES];
    [self.tabVC.view endEditing:YES];
    
}
#pragma mark -- 准备UI
- (void)readyUI
{
    self.title = @"MC_Chat";

//    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(lookOtherDevice)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"扩散" style:UIBarButtonItemStyleDone target:self action:@selector(showSelfAdvertiser)];
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    [self makeUIView];
    
}
#pragma mark -- 搜错其它设备
- (void)lookOtherDevice
{
    
    
     [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    [self.sessionManager browseWithControllerInViewController:self connected:^{
        
        NSLog(@"connected");
        
        
    }canceled:^{
        
        NSLog(@"cancelled");
        
    }];
}

#pragma mark -- 扩散
- (void)showSelfAdvertiser
{
    [self.sessionManager advertiseForBrowserViewController];
}

#pragma mark 制作页面UI
- (void)makeUIView
{
    
    self.myDataArray = [NSMutableArray arrayWithCapacity:0];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    self.navigationController.navigationBar.translucent = YES;

    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
//    self.tableView.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.tableView];
    //-------------------------------------------------------------------------//


    self.sendBackView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height, WIDTH, ChatHeight)];
    self.sendBackView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.95];
    self.sendBackView.frame = CGRectMake(0, self.view.height - ChatHeight, WIDTH, ChatHeight);
    
    UIView *backLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, .5)];
    backLine.backgroundColor = [UIColor colorWithWhite:0.078 alpha:1.000];
    [self.sendBackView addSubview:backLine];
    
    for (UIView * view in self.tabVC.tabBar.subviews) {
        
        [view removeFromSuperview];
        
    }
    self.tabVC.tabBar.hidden = YES;
    
    [self.tabVC.view addSubview:self.sendBackView];
    
    //语音
    self.voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.voiceButton.frame = CGRectMake(2.5,5, TextDefaultheight, TextDefaultheight);
    [self.voiceButton setImage:[UIImage imageNamed:@"ToolViewInputVoice"] forState:UIControlStateNormal];
    [self.voiceButton setImage:[UIImage imageNamed:@"ToolViewKeyboard"] forState:UIControlStateSelected];
    [self.voiceButton addTarget:self action:@selector(clickVoiceButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.sendBackView addSubview:self.voiceButton];
    
    //输入框
    self.sendTextView = [[UITextView alloc] initWithFrame:CGRectMake(self.voiceButton.right + 5, 5, WIDTH - 20 - 3 * TextDefaultheight, TextDefaultheight)];
    
    self.sendTextView.returnKeyType = UIReturnKeySend;
    self.sendTextView.font = [UIFont systemFontOfSize:17];
    self.sendTextView.layer.cornerRadius = 5;
    self.sendTextView.layer.borderColor =[UIColor colorWithWhite:0.449 alpha:1.000].CGColor;
    self.sendTextView.layer.borderWidth = .5;
    self.sendTextView.layer.masksToBounds = YES;
    self.sendTextView.editable = YES;
    self.sendTextView.delegate = self;
    [self.sendBackView addSubview:self.sendTextView];
    
    //按住录音
    self.recorderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.recorderButton.frame = self.sendTextView.frame;
    self.recorderButton.layer.cornerRadius = 5;
    [self.recorderButton setBackgroundImage:[UIImage imageNamed:@"DeviceRankMiddle"] forState:UIControlStateNormal];
    [self.recorderButton setTitleColor:[UIColor colorWithWhite:.1 alpha:1.0] forState:UIControlStateNormal];
    self.recorderButton.layer.borderColor =[UIColor colorWithWhite:0.449 alpha:1.000].CGColor;
    [self.recorderButton setTitle:@"按住 录音" forState:UIControlStateNormal];
    [self.recorderButton setTitle:@"松开 结束" forState:UIControlStateHighlighted];
    self.recorderButton.layer.borderWidth = .5;
    self.recorderButton.layer.masksToBounds = YES;
    self.recorderButton.hidden = YES;
    [self.recorderButton addTarget:self action:@selector(BeginRecordClick:) forControlEvents:UIControlEventTouchDown];
    
    [self.recorderButton addTarget:self action:@selector(OkStopClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.recorderButton addTarget:self action:@selector(StopPauseClick:) forControlEvents:UIControlEventTouchDragOutside];
    [self.recorderButton addTarget:self action:@selector(recordContinue:) forControlEvents:UIControlEventTouchDragInside];
    [self.recorderButton addTarget:self action:@selector(cancelRecord:) forControlEvents:UIControlEventTouchUpOutside];
    
    [self.sendBackView addSubview:self.recorderButton];
    
    _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _addButton.frame = CGRectMake(WIDTH - TextDefaultheight - 2.5, 5, TextDefaultheight, TextDefaultheight);
    [_addButton setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
    [_addButton addTarget:self action:@selector(addNextImage) forControlEvents:UIControlEventTouchUpInside];
    [self.sendBackView addSubview:_addButton];
    
     _emotionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _emotionButton.frame = CGRectMake(_addButton.left - TextDefaultheight - 5, 5, TextDefaultheight, TextDefaultheight);
    [_emotionButton setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
//    [addButton addTarget:self action:@selector() forControlEvents:UIControlEventTouchUpInside];
    [self.sendBackView addSubview:_emotionButton];
    
    self.tabVC.tabBar.translucent = YES;
    self.navigationController.navigationBar.translucent = YES;
    
    
}

- (void)MakerecordingView{
    if (!self.recordingView) {
        self.recordingView = [[RecordingView alloc]init];
    }

    self.recordingView.sliderCancel = NO;
    [self.recordingView show];
    
    
}

#pragma mark -- 切换语音，文字
- (void)clickVoiceButton:(UIButton *)sender{
    
    sender.selected = !sender.selected;
    if (sender.selected) {
        
        
        
        //显示录音按钮
        self.recorderButton.hidden = NO;
        self.sendTextView.hidden = YES;
        [self.sendTextView resignFirstResponder];
        
        [UIView animateWithDuration:.25 animations:^{
            self.tableView.frame = self.view.frame;
            self.sendBackView.frame = CGRectMake(0, self.view.height - ChatHeight, WIDTH, ChatHeight);
            _addButton.bottom = self.recorderButton.bottom;
            _emotionButton.bottom = self.recorderButton.bottom;
            self.voiceButton.bottom = self.recorderButton.bottom;
            
        }];
        
    }else{
        //显示输入框
        self.recorderButton.hidden = YES;
        self.sendTextView.hidden = NO;
        [self.sendTextView becomeFirstResponder];
    }
    
    
    
}
#pragma mark -- 视图随键盘调整
- (void)fitKeyboardSize:(NSNotification *)notification{
    
    NSLog(@"%@",notification.userInfo);
    /**
     {
     UIKeyboardAnimationCurveUserInfoKey = 7;
     UIKeyboardAnimationDurationUserInfoKey = "0.4";
     UIKeyboardBoundsUserInfoKey = "NSRect: {{0, 0}, {375, 216}}";
     UIKeyboardCenterBeginUserInfoKey = "NSPoint: {187.5, 775}";
     UIKeyboardCenterEndUserInfoKey = "NSPoint: {187.5, 559}";
     UIKeyboardFrameBeginUserInfoKey = "NSRect: {{0, 667}, {375, 216}}";
     UIKeyboardFrameEndUserInfoKey = "NSRect: {{0, 451}, {375, 216}}";
     
     */
    
    CGRect frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat height = frame.size.height;
    _keyboardHeight = height;
//    if ([notification.name isEqualToString:UIKeyboardWillChangeFrameNotification]){
//        
//        
//        height = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height - height;
//        
//    }
//    
    
    CGFloat duration = [[notification.userInfo
                         objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    NSUInteger option = [[notification.userInfo
                          objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView animateKeyframesWithDuration:duration delay:0 options:option animations:^{
        
        if ([notification.name isEqualToString:UIKeyboardWillHideNotification]) {
            _keyboardHeight = 0;
//            self.sendBackView.bottom = self.view.bottom;
//            
//            self.tableView.frame = CGRectMake(0, 0, WIDTH, self.view.height - _keyboardHeight - self.sendBackView.height + 49);
//
            
            float textHeight = [self heightForString:self.sendTextView.text fontSize:17 andWidth:self.sendTextView.frame.size.width];
            
            
            self.sendTextView.height = textHeight;
            
            self.voiceButton.bottom = self.sendTextView.bottom;
            _addButton.bottom = self.sendTextView.bottom;
            _emotionButton.bottom = self.sendTextView.bottom;
            self.sendBackView.frame = CGRectMake(0, self.view.height - textHeight - 14 - _keyboardHeight, WIDTH, textHeight + 14);
            
            
            self.tableView.frame = CGRectMake(0, 0, WIDTH, self.view.height - _keyboardHeight - self.sendBackView.height + 49);
            
            if (self.datasource.count >= 1) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.datasource.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }

            
            
        }else{
            if (self.sendTextView.text.length > 0) {
                
                float textHeight = [self heightForString:self.sendTextView.text fontSize:17 andWidth:self.sendTextView.frame.size.width];
                
                
                self.sendTextView.height = textHeight;
                
                self.voiceButton.bottom = self.sendTextView.bottom;
                _addButton.bottom = self.sendTextView.bottom;
                _emotionButton.bottom = self.sendTextView.bottom;
                self.sendBackView.frame = CGRectMake(0, self.view.height - textHeight - 14 - _keyboardHeight, WIDTH, textHeight + 14);
                
                
                self.tableView.frame = CGRectMake(0, 0, WIDTH, self.view.height - _keyboardHeight - self.sendBackView.height + 49);
                
            }else{
                self.sendBackView.bottom = self.view.height - height ;
                self.tableView.frame = CGRectMake(0, 0, WIDTH, self.view.height - height - self.sendBackView.height + 49);
            }
            
            
            if (self.datasource.count >= 1) {
                // 滑动到底部  第二个参数是滑动到底部
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.datasource.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }
           
        }
        
        
    } completion:NULL];
    
}

#pragma mark 图片的传输---------///////

- (void)addNextImage
{
    [self hiddenKeyboard];
    UIActionSheet *chooseImageSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"照相机",@"相册", nil];
    [chooseImageSheet showInView:self.view];
}




#pragma mark UIActionSheetDelegate Method
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    _picker = [[UIImagePickerController alloc] init];
    _picker.delegate = self;
    
    switch (buttonIndex) {
        case 0://Take picture
            
            
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                
                _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            }
            
            [self presentViewController:_picker animated:YES completion:nil];
            
            
            
            break;
            
        case 1:
            //From album
            _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            [self presentViewController:_picker animated:YES completion:^{
                
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
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
        
        
        
        
        [_picker dismissViewControllerAnimated:YES completion:^{
            
            // 改变状态栏的颜色  改变为白色
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
       
            //先把图片转成NSData
            UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
            NSData *data;
            if (UIImagePNGRepresentation(image) == nil)
            {
                data = UIImageJPEGRepresentation(image, 1.0);
            }
            else
            {
                data = UIImagePNGRepresentation(image);
            }
            
            //图片保存的路径
            //这里将图片放在沙盒的documents文件夹中
            NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            
            //文件管理器
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            //把刚刚图片转换的data对象拷贝至沙盒中 并保存为image.png
            [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
            [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:@"/image.png"] contents:data attributes:nil];
            
            //得到选择后沙盒中图片的完整路径
            NSString * filePath = [[NSString alloc]initWithFormat:@"%@%@",DocumentsPath,  @"/image.png"];
            
            
            // 这边是真正的发送
            if(!self.sessionManager.isConnected)
            {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"连接已经断开了，请重新连接！" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"知道了", nil];
                [alertView show];
                return;
            }
            
            ChatItem * chatItem = [[ChatItem alloc] init];
            chatItem.isSelf = YES;
            chatItem.states = picStates;
            chatItem.picImage = image;
            [self.datasource addObject:chatItem];
            
            
            [self insertTheTableToButtom];
            
            
            [self sendAsResource:filePath];
            
        }];
    }
    
    
}


- (void)sendAsResource:(NSString *)path
{
    
    NSLog(@"dispaly ====%@",self.sessionManager.firstPeer.displayName);
    NSString * name = [NSString stringWithFormat:@"%@ForPic",[[UIDevice currentDevice] name]];
    NSURL * url = [NSURL fileURLWithPath:path];
    
    NSProgress *progress = [self.sessionManager sendResourceWithName:name atURL:url toPeer:self.sessionManager.firstPeer complete:^(NSError *error) {
        if(!error) {
            NSLog(@"finished sending resource");
        }
        else {
            NSLog(@"%@", error);
        }
    }];
    
    NSLog(@"%@", @(progress.fractionCompleted));
    
}


#pragma mark 普通数据的传输
- (void)sendWeNeedNews
{
    if(!self.sessionManager.isConnected)
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"连接已经断开了，请重新连接！" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"知道了", nil];
                [alertView show];
                return;
    }
    if([self.sendTextView.text isEqualToString:@""])
    {
        return;
    }
    
    
    ChatItem * chatItem = [[ChatItem alloc] init];
    chatItem.isSelf = YES;
    chatItem.states = textStates;
    chatItem.content = self.sendTextView.text;
    [self.datasource addObject:chatItem];
    // 加到数组里面
    
    // 添加行   indexPath描述位置的具体信息
    [self insertTheTableToButtom];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.sendTextView.text];
    NSError *error = [self.sessionManager sendDataToAllPeers:data];
    if(!error) {
        //there was no error.
    }
    else {
        NSLog(@"%@", error);
    }
    
    [self returnTheNewBack];
}
- (void)returnTheNewBack
{
    // 归零
    self.sendTextView.text = @"";
  
}

// 这是一种很好的键盘下移方式
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"]) {
        
//        float textHeight = TextDefaultheight;
        
        [UIView animateWithDuration:.25 animations:^{
            self.sendTextView.height = TextDefaultheight;
            self.sendBackView.frame = CGRectMake(0, self.view.height - ChatHeight - _keyboardHeight, WIDTH, ChatHeight);
            self.tableView.frame = CGRectMake(0, 0, WIDTH, self.view.height - _keyboardHeight - self.sendBackView.height + ChatHeight);
            self.voiceButton.bottom = self.sendTextView.bottom;
            _addButton.bottom = self.sendTextView.bottom;
            _emotionButton.bottom = self.sendTextView.bottom;
            
            [self sendWeNeedNews];
            
        }];
        

        
        return NO;
    }
    
    
    
    
    return YES;
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
   
    
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView
{
    
    
    if (self.sendBackView.height > 90) {
        return;
    }
    
   
    
    [UIView animateWithDuration:.25 animations:^{
        float textHeight = [self heightForString:textView.text fontSize:17 andWidth:textView.frame.size.width];
        
        
        self.sendTextView.height = textHeight;
        
        self.voiceButton.bottom = self.sendTextView.bottom;
        _addButton.bottom = self.sendTextView.bottom;
        _emotionButton.bottom = self.sendTextView.bottom;
        self.sendBackView.frame = CGRectMake(0, self.view.height - textHeight - 14 - _keyboardHeight, WIDTH, textHeight + 14);
        
        
        self.tableView.frame = CGRectMake(0, 0, WIDTH, self.view.height - _keyboardHeight - self.sendBackView.height + 49);
    }];
    
    if (self.datasource.count >= 1) {
      [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.datasource.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    
    
}

- (float) heightForString:(NSString *)value fontSize:(float)fontSize andWidth:(float)width
{
    UITextView *detailTextView = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, width, 0)];
    detailTextView.font = [UIFont systemFontOfSize:fontSize];
    detailTextView.text = value;
    CGSize deSize = [detailTextView sizeThatFits:CGSizeMake(width,CGFLOAT_MAX)];
    return deSize.height;
}



/*--------------------------------------------------------------------------------------------*/
- (void)insertTheTableToButtom
{
    // 哪一组 哪一段
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:self.datasource.count- 1 inSection:0];
    // 添加新的一行
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    // 滑动到底部  第二个参数是滑动到底部
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark tableView 代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasource.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatItem *model = self.datasource[indexPath.row];
    return model.cellHeight;
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Chat_Cell";
    
    MyChatCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        
        cell = [[MyChatCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle =     UITableViewCellSelectionStyleNone;

        cell.backgroundColor = [UIColor clearColor];
    }
    
    cell.model = self.datasource[indexPath.row];
    cell.voiceBlock = ^(NSURL *url,NSData *data,UIImageView *imageView){
        if (_currentVoiceView) {
            [_currentVoiceView stopAnimating];
            self.audioPlayer = nil;
        }
        _currentVoiceView = imageView;
        
        
        [_currentVoiceView startAnimating];
        [self makeVideoPlayer:data];
        
    };
    return cell;
}

- (void)cellSelectIndex:(UIButton *)cellBtn
{
    
    ChatItem *chatIden = [self.datasource objectAtIndex:cellBtn.tag - 300];
    if(chatIden.states == videoStates)
    {
        NSLog(@"realy play");
        //        [self makeVideoPlayer:[self getVideoStremData]];
        [self makeVideoPlayer:chatIden.data];
    }
}


#pragma mark 下面是核心的连接MCSession 和  数据返回的地方

/***************************-------**********************************************/
- (void)makeBlueData
{

    __weak typeof (self) weakSelf = self;
    self.datasource = [NSMutableArray arrayWithCapacity:0];
    
    // 初始化  会议室
    self.sessionManager = [[BlueSessionManager alloc]initWithDisplayName:[NSString stringWithFormat:@" %@",  [[UIDevice currentDevice] name]]];
    
    //
    [self.sessionManager didReceiveInvitationFromPeer:^void(MCPeerID *peer, NSData *context) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"是否连接？" message:[NSString stringWithFormat:@"同 %@%@", peer.displayName, @" 连接?"] delegate:strongSelf cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }];
    
    [self.sessionManager peerConnectionStatusOnMainQueue:YES block:^(MCPeerID *peer, MCSessionState state) {
        if(state == MCSessionStateConnected) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"已经连接" message:[NSString stringWithFormat:@"现在连接 %@了！", peer.displayName] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"知道了", nil];
            [alertView show];
            self.title = peer.displayName;
        }
    }];
    
    // 收到正常数据的返回
    [self.sessionManager receiveDataOnMainQueue:YES block:^(NSData *data, MCPeerID *peer) {
        
        __strong typeof (weakSelf) strongSelf = weakSelf;
        
        NSString *string = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        [self playSoundEffect:@"5097.mp3"];
        ChatItem * chatItem = [[ChatItem alloc] init];
        chatItem.isSelf = NO;
        chatItem.states = textStates;
        chatItem.content = string;
        [strongSelf.datasource addObject:chatItem];
        // 加到数组里面
        
        [strongSelf insertTheTableToButtom];
        
        
    }];
    
    // 收到图片之后的返回
    [self.sessionManager receiveFinalResourceOnMainQueue:YES complete:^(NSString *name, MCPeerID *peer, NSURL *url, NSError *error) {
        
        __strong typeof (weakSelf) strongSelf = weakSelf;
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        [self playSoundEffect:@"5097.mp3"];
        ChatItem * chatItem = [[ChatItem alloc] init];
        chatItem.isSelf = NO;
        chatItem.states = picStates;
        chatItem.content = name;
        chatItem.picImage = [UIImage imageWithData:data];
        [strongSelf.datasource addObject:chatItem];
        [strongSelf insertTheTableToButtom];
        
    }];
    
    
    
    // 流
    [self.sessionManager didReceiveStreamFromPeer:^(NSInputStream *stream, MCPeerID *peer, NSString *streamName) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        strongSelf.inputStream = stream;
        strongSelf.inputStream.delegate = self;
        [strongSelf.inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [strongSelf.inputStream open];
        
        NSLog(@"we need");
        
    }];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.sessionManager connectToPeer:buttonIndex == 1];
}





#pragma mark 下面是流的传输

/***********--------------------- 下面是流的传输 ------------------------***********************************/


- (void)sendAsStream
{
    if(!self.sessionManager.isConnected)
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"连接已经断开了，请重新连接！" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"知道了", nil];
        [alertView show];
        return;
        
    }
    
    NSError *err;
    self.outputStream = [self.sessionManager streamWithName:@"super stream" toPeer:self.sessionManager.firstPeer error:&err];
    self.outputStream.delegate = self;
    [self.outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    if(err || !self.outputStream) {
        NSLog(@"%@", err);
        [[CustomAlertView shareCustomAlertView]showAlertViewWtihTitle:@"发送失败" viewController:nil];
    }
    else
    {
        
        [self.outputStream open];
    }
    
}

// 下面是一个代理
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    
    if(eventCode == NSStreamEventHasBytesAvailable)
    {
        // 有可读的字节，接收到了数据
        NSInputStream *input = (NSInputStream *)aStream;
        uint8_t buffer[1024];
        NSInteger length = [input read:buffer maxLength:1024];
        [self.streamData appendBytes:(const void *)buffer length:(NSUInteger)length];
        // 记住这边的数据陆陆续续的
    }
    else if(eventCode == NSStreamEventHasSpaceAvailable)
    {
        // 可以使用输出流的空间，此时可以发送数据给服务器
        // 发送数据的
        NSData *data = [self getVideoStremData];
        ChatItem * chatItem = [[ChatItem alloc] init];
        chatItem.isSelf = YES;
        chatItem.states = videoStates;
        chatItem.data = data;
        
        [self.datasource addObject:chatItem];
        [self insertTheTableToButtom];
        
        NSOutputStream *output = (NSOutputStream *)aStream;
        [output write:data.bytes maxLength:data.length];
        [output close];
    }
    if(eventCode == NSStreamEventEndEncountered)
    {
        // 流结束事件，在此事件中负责做销毁工作
        // 同时也是获得最终数据的好地方
        [self playSoundEffect:@"5097.mp3"];
        ChatItem * chatItem = [[ChatItem alloc] init];
        chatItem.isSelf = NO;
        chatItem.states = videoStates;
        chatItem.data = self.streamData;
        
        [self.datasource addObject:chatItem];
        [self insertTheTableToButtom];
        
        [aStream close];
        [aStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        if([aStream isKindOfClass:[NSInputStream class]])
        {
            self.streamData = nil;
        }
        
    }
    if(eventCode == NSStreamEventErrorOccurred)
    {
        // 发生错误
        NSLog(@"error");
    }
}

- (NSMutableData *)streamData
{
    if(!_streamData) {
        _streamData = [NSMutableData data];
    }
    return _streamData;
}

/***********-----------------------  公用的数据 --------------------***********************************/

- (NSData *)imageData
{
    return [NSData dataWithContentsOfURL:[self imageURL]];
}

- (NSURL *)imageURL {
    NSString *path = [[NSBundle mainBundle]pathForResource:@"301-alien-ship@2x" ofType:@"png"];
    // 这儿有个技术点
    // 那个如何将 image转化成 路径
    
    NSURL *url = [NSURL fileURLWithPath:path];
    return url;
}

/***********----------------------------------------------***********************************/
#pragma mark 尝试空白处的连接

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [[event allTouches] anyObject];
    if(touch.tapCount >= 1)
    {
        [self.sendTextView resignFirstResponder];
    }
}


/***********-------------------语音---------------------------***********************************/

#pragma mark 尝试语音的录制和播出

- (void)buildVideoForWe
{
    // 设置录音会话
    [self setAudioSession];
}



#pragma mark - 私有方法
/**
 *  设置音频会话
 */
-(void)setAudioSession
{
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    //设置为播放和录音状态，以便可以在录制完之后播放录音
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
}

/**
 *  取得录音文件保存路径
 *
 *  @return 录音文件路径
 */
-(NSURL *)getSavePath
{
    NSString *urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    urlStr=[urlStr stringByAppendingPathComponent:kRecordAudioFile];
    NSLog(@"file path:%@",urlStr);
    NSURL *url=[NSURL fileURLWithPath:urlStr];
    return url;
}

- (NSData *)getVideoStremData
{
    return [NSData dataWithContentsOfURL:[self getSavePath]];
}


/**
 *  取得录音文件设置
 *
 *  @return 录音设置
 */
-(NSDictionary *)getAudioSetting{
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    //设置录音格式
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
//    [dicM setObject:@(8000) forKey:AVSampleRateKey];
    [dicM setObject:@(44100) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    [dicM setObject:@(16) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    //....其他设置等
    return dicM;
}

/**
 *  获得录音机对象
 *
 *  @return 录音机对象
 */
-(AVAudioRecorder *)audioRecorder
{
    if (!_audioRecorder) {
        //创建录音文件保存路径
        NSURL *url=[self getSavePath];
        //创建录音格式设置
        NSDictionary *setting=[self getAudioSetting];
        //创建录音机
        NSError *error=nil;
        _audioRecorder=[[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
        _audioRecorder.delegate=self;
        _audioRecorder.meteringEnabled=YES;//如果要监控声波则必须设置为YES
        if (error) {
            NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}

/**
 *  创建播放器
 *
 *  @return 播放器
 */


- (void)makeVideoPlayer:(NSData *)data
{
    
    [self handleNotification:YES];
     [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    NSError *error=nil;
    self.audioPlayer=[[AVAudioPlayer alloc]initWithData:data error:&error];
    self.audioPlayer.delegate = self;
    self.audioPlayer.numberOfLoops=0;
    [self.audioPlayer prepareToPlay];
    if (error)
    {
        NSLog(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
        
    }
    else
    {
        if (![self.audioPlayer isPlaying]) {
            NSLog(@"play");
            [self.audioPlayer play];
        }
        
    }
}







/**
 *  录音声波状态设置
 */
-(void)audioPowerChange:(NSTimer *)timer{
    [self.audioRecorder updateMeters];//更新测量值
    float power= [self.audioRecorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0

//    NSLog(@"%f",power);
    [self.recordingView setVolume:power];
    
}
#pragma mark - UI事件
/**
 *  点击录音按钮
 *
 *  @param sender 录音按钮
 */
- (void)BeginRecordClick:(UIButton *)sender
{
    
    if (![self.audioRecorder isRecording])
    {
        [self.audioRecorder record];//首次使用应用时如果调用record方法会询问用户是否允许使用麦克风
        self.timer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(audioPowerChange:) userInfo:nil repeats:YES];
        [self MakerecordingView];
    }

}
- (void)recordContinue:(UIButton *)sender{
    
    if (![self.audioRecorder isRecording])
    {
        NSTimeInterval time = [NSDate date].timeIntervalSince1970;
        [self.audioRecorder recordAtTime:time - _puaseTime];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(audioPowerChange:) userInfo:nil repeats:YES];

            NSLog(@"int");
        self.recordingView.sliderCancel = NO;
    }

    
    
    
}
/**
 *  点击暂定按钮
 *
 *  @param sender 暂停按钮
 */
- (void)StopPauseClick:(UIButton *)sender
{
    if ([self.audioRecorder isRecording]) {
        [self.audioRecorder pause];
        _puaseTime = [NSDate date].timeIntervalSince1970;
         NSLog(@"out");
        [self.timer invalidate];
        self.timer = nil;

        self.recordingView.sliderCancel = YES;

    }
    

}
- (void)cancelRecord:(UIButton *)button{
    
    _recordCancel = YES;
    [self.audioRecorder stop];
    [self.recordingView hidden];
    [self.timer invalidate];
    self.timer = nil;
    
}

/**
 *  点击停止按钮
 *
 *  @param sender 停止按钮
 */
- (void)OkStopClick:(UIButton *)sender
{
    _recordCancel = NO;
    [self.audioRecorder stop];
    [self.recordingView hidden];
    [self.timer invalidate];
    self.timer = nil;

}

#pragma mark - 录音机代理方法
/**
    *  录音完成
 *
 *  @param recorder 录音机对象
 *  @param flag     是否成功
 */
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
//        if (![self.audioPlayer isPlaying]) {
//            [self.audioPlayer play];
//        }
    if (_recordCancel) {
        return;
    }
    [self  sendAsStream];
    NSLog(@"录音完成!");
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
     [_currentVoiceView stopAnimating];
    // 每次完成后都将这个对象释放
    player =nil;
    [self handleNotification:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- 提示音


/**
 *  播放完成回调函数
 *
 *  @param soundID    系统声音ID
 *  @param clientData 回调时传递的数据
 */
void soundCompleteCallback(SystemSoundID soundID,void * clientData){
    NSLog(@"播放完成...");
}

/**
 *  播放音效文件
 *
 *  @param name 音频文件名称
 */
-(void)playSoundEffect:(NSString *)name{
    NSString *audioFile=[[NSBundle mainBundle] pathForResource:name ofType:nil];
    NSURL *fileUrl=[NSURL fileURLWithPath:audioFile];
    //1.获得系统声音ID
    SystemSoundID soundID=0;
    /**
     * inFileUrl:音频文件url
     * outSystemSoundID:声音id（此函数会将音效文件加入到系统音频服务中并返回一个长整形ID）
     */
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    //如果需要在播放完之后执行某些操作，可以调用如下方法注册一个播放完成回调函数
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
    //2.播放音频
//    AudioServicesPlaySystemSound(soundID);//播放音效
        AudioServicesPlayAlertSound(soundID);//播放音效并震动
}

#pragma mark - 监听听筒or扬声器
- (void) handleNotification:(BOOL)state
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:state]; //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
    
    if(state)//添加监听
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sensorStateChange:) name:UIDeviceProximityStateDidChangeNotification
                                                   object:nil];
    else//移除监听
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
}

//处理监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
        NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }else
    {
        NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
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
