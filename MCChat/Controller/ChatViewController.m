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
#import "WeiboFacePanelView.h"
#import "MainTabBarViewController.h"
#define HEIGHT [UIScreen mainScreen].bounds.size.height
#define WIDTH [UIScreen mainScreen].bounds.size.width
#define ChatHeight 49.0
#define TextDefaultheight 36.5
#define kRecordAudioFile @"myRecord.caf"
#import "RecordingView.h"
#import "SettingViewController.h"
#import "HeaderCell.h"
@interface ChatViewController ()<NSStreamDelegate,UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate,WeiboFaceViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate>{
    
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
    MCPeerID *_curretConnect;
    BOOL _showFacePanel;
    BOOL _showAttachment;
}

@property (nonatomic,strong)NSMutableDictionary *otherHeaderImages;
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
@property (nonatomic,strong)WeiboFacePanelView *facePanelView;
@property (nonatomic,strong)UICollectionView *attachmentCollectionView;

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
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIView animateWithDuration:.25 animations:^{
        self.sendBackView.hidden = NO;
        self.facePanelView.hidden = NO;
    }];

    
    
      [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];   
}
- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    self.sendBackView.hidden = YES;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    

    
    if (UserDefaultsGet(@"bgPath")) {
        
        UIImage *image = [UIImage imageWithContentsOfFile:UserDefaultsGet(@"bgPath")];
        self.view.layer.contents = (id) image.CGImage;
        self.navigationController.navigationBar.titleTextAttributes =@{
                                                                       NSForegroundColorAttributeName:[UIColor whiteColor]
                                                                       
                                                                       };
    }else{
        [self setDefaultBackground];

    }
    
//    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
//    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithWhite:0.127 alpha:1.000];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithWhite:0.01 alpha:0.600];
    
    
    [self makeBlueData];
    
    [self readyUI];
    
    [self buildVideoForWe];
    
    //监听键盘通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(fitKeyboardSize:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(fitKeyboardSize:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(fitKeyboardSize:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    //监听背景切换
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setDefaultBackground) name:@"ChangeDefaultBackground" object:nil];
    
    
}

#pragma mark -- 切换背景
- (void)setDefaultBackground{
    //    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"壁纸1.jpg"]];
    
    UIImage *image = [UIImage imageNamed:@"壁纸1.jpg"];
    self.view.layer.contents = (id) image.CGImage;
    self.navigationController.navigationBar.titleTextAttributes =@{
                                                                   NSForegroundColorAttributeName:[UIColor whiteColor]
                                                                   
                                                                   };

    
}
- (void)changeBackground{
    
    
    UIImage *image = [UIImage imageWithContentsOfFile:UserDefaultsGet(@"bgPath")];
    self.view.layer.contents = (id) image.CGImage;
    self.navigationController.navigationBar.titleTextAttributes =@{
                                                                   NSForegroundColorAttributeName:[UIColor whiteColor]
                                                                   
                                                                   };
    
    [[CustomAlertView shareCustomAlertView]showAlertViewWtihTitle:@"背景切换成功" viewController:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    
    _tabBarFrame = self.tabVC.view.frame;

    

}

- (void)hiddenKeyboard{
    
    [self.view endEditing:YES];
    [self.tabVC.view endEditing:YES];
    if (_showFacePanel) {

        [UIView animateWithDuration:.25 animations:^{
            _keyboardHeight = 0;
            self.facePanelView.top = KScreenHeight;
            _showFacePanel = NO;
            
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
            _emotionButton.selected = NO;
        }];
   
    }
    if (_showAttachment) {
        
        [UIView animateWithDuration:.25 animations:^{
            _keyboardHeight = 0;
            self.attachmentCollectionView.top = KScreenHeight;
            
            
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
            _showAttachment = NO;
        }];
        
    }
}
#pragma mark -- 准备UI
- (void)readyUI
{
    if (!self.sessionManager.isConnected) {
        self.title = @"未连接";        
    }


//    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(lookOtherDevice)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 40, 40);
    rightButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [rightButton addTarget:self action:@selector(showSelfAdvertiser) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setImage:[UIImage imageNamed:@"barbuttonicon_InfoSingle"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    
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

#pragma mark -- 设置
- (void)showSelfAdvertiser
{
    [self.sendBackView endEditing:YES];
    SettingViewController *setting =  [[SettingViewController alloc]init];
    setting.sessionManager = self.sessionManager;
    
    NSArray *peers = self.sessionManager.session.connectedPeers;
    
    NSMutableDictionary *imagesDic = [NSMutableDictionary dictionary];
    for (MCPeerID *peer in peers) {
        
        [imagesDic setObject:self.otherHeaderImages[peer.displayName] forKey:peer];
        
    }
    self.otherHeaderImages = imagesDic;
    setting.friendIcon = [self.otherHeaderImages allValues];
    if (self.sessionManager.session.connectedPeers.count > 1) {
        setting.groupName = self.title;
        
    }
    
    [self.navigationController pushViewController:setting animated:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeBackground) name:@"changeBg" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(ChangeHeaderIcon) name:@"ChangeHeaderIcon" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(ChangeGroupName:) name:@"ChangeGroupName" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(haveDisconnectSession) name:@"disconnectSession" object:nil];
    
    if (_showFacePanel) {
        self.facePanelView.hidden = YES;
    }
    
}

#pragma mark -- 断开连接
- (void)haveDisconnectSession{
    
    self.otherHeaderImages = nil;
    
    
}
#pragma mark -- 更换头像
- (void)ChangeHeaderIcon{
    
    
    [self.tableView reloadData];
    
    
    NSLog(@"dispaly ====%@",self.sessionManager.firstPeer.displayName);
    NSString * name = [NSString stringWithFormat:@"%@ForIcon",UserDefaultsGet(MyNickName)?UserDefaultsGet(MyNickName):[UIDevice currentDevice].name];
    NSURL * url = [NSURL fileURLWithPath:UserDefaultsGet(@"headerIcon")];
        for (MCPeerID *peer in self.sessionManager.connectedPeers) {
            
            NSProgress *progress = [self.sessionManager sendResourceWithName:name atURL:url toPeer:peer complete:^(NSError *error) {
                if(!error) {
                    NSLog(@"finished sending resource");
                }
                else {
                    NSLog(@"%@", error);
                }
            }];
            
            NSLog(@"%@", @(progress.fractionCompleted));
        }
   

    
}
#pragma mark -- 更换群名称
- (void)ChangeGroupName:(NSNotification *)noti{
    self.title = (NSString *)noti.object;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:@{
                                                                 @"GroupName":self.title
                                                                 }];
    [self.sessionManager sendDataToAllPeers:data];

    
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
    [_addButton addTarget:self action:@selector(addNextImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendBackView addSubview:_addButton];
    
     _emotionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _emotionButton.frame = CGRectMake(_addButton.left - TextDefaultheight - 5, 5, TextDefaultheight, TextDefaultheight);
    [_emotionButton setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
    [_emotionButton setImage:[UIImage imageNamed:@"ToolViewKeyboard"] forState:UIControlStateSelected];
    [_emotionButton addTarget:self action:@selector(clickEmotion:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendBackView addSubview:_emotionButton];
    
    
    //表情面板
    self.facePanelView = [[WeiboFacePanelView alloc]initWithFrame:CGRectMake(0,KScreenHeight, 0, 0)];
    self.facePanelView.faceView.delegate = self;
    [self.tabBarController.view addSubview:self.facePanelView];
    [self.facePanelView showSendWithTarget:self Action:@selector(sendFace)];
    
    
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
    
    if (![self canRecord]) {
        
        [[CustomAlertView shareCustomAlertView]showAlertViewWtihTitle:[NSString stringWithFormat:@"%@需要访问您的麦克风。\n请启用麦克风-设置/隐私/麦克风", @"MMChat"] viewController:nil];
        return;
    }
    
    
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
        
        [self hiddenKeyboard];
    }else{
        //显示输入框
        self.recorderButton.hidden = YES;
        self.sendTextView.hidden = NO;
        [self.sendTextView becomeFirstResponder];
    }
    
    
    
}
///新增api,获取录音权限. 返回值,YES为无拒绝,NO为拒绝录音.

- (BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                if (granted) {
                    bCanRecord = YES;
                } else {
                    bCanRecord = NO;
                }
            }];
        }
    }
    
    return bCanRecord;
}

#pragma mark -- 切换表情键盘

- (void)clickEmotion:(UIButton *)sender{
    
    sender.selected = !sender.isSelected;
    
    if (sender.isSelected) {
        
        [self hiddenKeyboard];
        
        _showFacePanel = YES;
        
        if (self.voiceButton.selected) {
            self.voiceButton.selected = NO;
            self.recorderButton.hidden = YES;
            self.sendTextView.hidden = NO;
        }
        


            [UIView animateWithDuration:.25 animations:^{
                
                if (_showAttachment) {
                    
                    self.attachmentCollectionView.top = KScreenHeight;
                    _showAttachment = NO;
                }
                
                    _keyboardHeight = self.facePanelView.height;
                    self.facePanelView.bottom = KScreenHeight;
                
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
 
            }];

        
        

    }else{
        
        _showFacePanel = NO;
        [self.sendTextView becomeFirstResponder];

    }
    
    
    
}

- (void)sendFace{
    [UIView animateWithDuration:.25 animations:^{
        self.sendTextView.height = TextDefaultheight;
        self.sendBackView.frame = CGRectMake(0, self.view.height - ChatHeight - _keyboardHeight, WIDTH, ChatHeight);
        self.tableView.frame = CGRectMake(0, 0, WIDTH, self.view.height - _keyboardHeight - self.sendBackView.height + ChatHeight);
        self.voiceButton.bottom = self.sendTextView.bottom;
        _addButton.bottom = self.sendTextView.bottom;
        _emotionButton.bottom = self.sendTextView.bottom;
        
        [self sendWeNeedNews:nil];
        
    }];
    
    
    
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
            if (_showFacePanel == YES || _showAttachment == YES) {
                _keyboardHeight = self.facePanelView.height;
//                if (_showFacePanel) {
//                  self.facePanelView.bottom = KScreenHeight;
//                    
//                }
//                if (_showAttachment) {
//                    self.attachmentCollectionView.bottom = KScreenHeight;
//
//                }
            }
            
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
            


                 self.facePanelView.top = KScreenHeight;
                    _showFacePanel = NO;

            

                 self.attachmentCollectionView.top = KScreenHeight;
                    _showFacePanel = NO;

            
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

#pragma mark 图片 文件的传输---------///////

- (void)addNextImage:(UIButton *)sender
{
    [self hiddenKeyboard];
//    UIActionSheet *chooseImageSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"照相机",@"相册", nil];
//    [chooseImageSheet showInView:self.view];


        
        if (!self.attachmentCollectionView) {
            
            
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
            CGFloat size = (KScreenWidth - 20 * 5) / 4;
            layout.itemSize = CGSizeMake(size, size);
            layout.minimumLineSpacing = 20;
            layout.minimumInteritemSpacing = 20;
            layout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
            
            
            self.attachmentCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, KScreenHeight, KScreenWidth,self.facePanelView.height) collectionViewLayout:layout];
            [self.attachmentCollectionView registerNib:[UINib nibWithNibName:@"HeaderCell" bundle:nil] forCellWithReuseIdentifier:@"HeaderCell"];
            self.attachmentCollectionView.scrollEnabled = NO;
            self.attachmentCollectionView.backgroundColor = [UIColor whiteColor];
            self.attachmentCollectionView.dataSource = self;
            self.attachmentCollectionView.delegate = self;
            self.attachmentCollectionView.backgroundColor  = [UIColor colorWithWhite:.8 alpha:.95];
            [self.tabBarController.view addSubview:self.attachmentCollectionView];
            
            
            
            
            
        }
    if (_showAttachment) {
        return;
    }
        _showAttachment = YES;
        [UIView animateWithDuration:.25 animations:^{

                self.facePanelView.top = KScreenHeight;
                _showFacePanel = NO;

            
            _keyboardHeight = self.attachmentCollectionView.height;
            self.attachmentCollectionView.bottom = KScreenHeight;
            
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
            
        }];
        
    
    
    
    
    
    
    
}


#pragma mark --UICollectionViewDataSource,UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return 3;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    HeaderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HeaderCell" forIndexPath:indexPath];
    cell.headImageVIew.userInteractionEnabled = NO;    
    switch (indexPath.item) {
        case 0:
        {

            cell.headImageVIew.image = [UIImage imageNamed:@"sharemore_video"];
        }
            break;
        case 1:
        {

            cell.headImageVIew.image = [UIImage imageNamed:@"sharemore_pic"];
        }
            break;
        case 2:
        {

            cell.headImageVIew.image = [UIImage imageNamed:@"sharemore_wallet"];
        }
            break;
            
        default:
            break;
    }
        
    

    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    _picker = [[UIImagePickerController alloc] init];
    _picker.delegate = self;

    switch (indexPath.item) {
        case 0:
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                
                _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            }
            
            [self presentViewController:_picker animated:YES completion:nil];
            

        }
            break;
        case 1:
        {
            //From album
            _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            [self presentViewController:_picker animated:YES completion:^{
                
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent
                 ];
            }];
        }
            break;
        case 2:
        {
            //发送文件
        }
            break;
            
        default:
            break;
    }

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
        
        
        
        
        [_picker dismissViewControllerAnimated:YES completion:^{
            
            // 改变状态栏的颜色  改变为白色
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
       
            //先把图片转成NSData
            UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];

            
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
                [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
                [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:[NSString stringWithFormat:@"/image%@",type]] contents:data attributes:nil];
                
                //得到选择后沙盒中图片的完整路径
                NSString * filePath = [[NSString alloc]initWithFormat:@"%@/image%@",DocumentsPath,type];
                
                
                
                if(self.sessionManager.isConnected)
                {
                  [self sendAsResource:filePath];
                }

                
            });
         
            
            
      
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
            NSDate *date = [NSDate date];
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"yy-MM-dd HH:mm:ss"];
            NSString *dateStr = [formatter stringFromDate:date];
            chatItem.timeStr = dateStr;
            [self.datasource addObject:chatItem];
            
            
            [self insertTheTableToButtom];
            
            

            
        }];
    }
    
    
}


- (void)sendAsResource:(NSString *)path
{
    
    NSLog(@"dispaly ====%@",self.sessionManager.firstPeer.displayName);
    NSString * name = [NSString stringWithFormat:@"%@ForPic",UserDefaultsGet(MyNickName)?UserDefaultsGet(MyNickName):[UIDevice currentDevice].name];
    
    NSURL * url = [NSURL fileURLWithPath:path];
    for (MCPeerID *peer in self.sessionManager.connectedPeers) {
        
        NSProgress *progress = [self.sessionManager sendResourceWithName:name atURL:url toPeer:peer complete:^(NSError *error) {
            if(!error) {
                NSLog(@"finished sending resource");
            }
            else {
                NSLog(@"%@", error);
            }
        }];
        
        NSLog(@"%@", @(progress.fractionCompleted));
    }
    
    
}
#pragma mark -- 群聊语音
- (void)sendGroupChatVideoAsResource:(NSURL *)path
{
   
    
    
    for (MCPeerID *peer in self.sessionManager.connectedPeers) {
        
        NSProgress *progress = [self.sessionManager sendResourceWithName:@"video" atURL:path toPeer:peer complete:^(NSError *error) {
            if(!error) {
                NSLog(@"finished sending resource");
            }
            else {
                NSLog(@"%@", error);
            }
        }];
        
        NSLog(@"%@", @(progress.fractionCompleted));
    }
    
    
}

#pragma mark 普通数据的传输
- (void)sendWeNeedNews:(NSString *)content
{
    if(!self.sessionManager.isConnected)
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"连接已经断开了，请重新连接！" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"知道了", nil];
                [alertView show];
                return;
    }
    if([self.sendTextView.text isEqualToString:@""]&& content.length < 1)
    {
        return;
    }
    
    
    ChatItem * chatItem = [[ChatItem alloc] init];
    chatItem.isSelf = YES;
    chatItem.states = textStates;
    if (content) {
        chatItem.content = content;
    }else{
        chatItem.content = self.sendTextView.text;
    }
    
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yy-MM-dd HH:mm:ss"];
    NSString *dateStr = [formatter stringFromDate:date];
    chatItem.timeStr = dateStr;
    
    [self.datasource addObject:chatItem];
    // 加到数组里面
    
    // 添加行   indexPath描述位置的具体信息
    [self insertTheTableToButtom];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:content?content:self.sendTextView.text];
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
            
            [self sendWeNeedNews:nil];
            
        }];
        

        
        return NO;
    }
    
    
    
    
    return YES;
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
    _emotionButton.selected = NO;
    _showFacePanel = NO;
    

    
    return YES;
    
    
}
- (void)textViewDidBeginEditing:(UITextView *)textView{
    [UIView animateWithDuration:.25 animations:^{
        float textHeight = [self heightForString:self.sendTextView.text fontSize:17 andWidth:self.sendTextView.frame.size.width];
        if (textHeight > 90) {
            textHeight = 90;
        }
        
        self.sendTextView.height = textHeight;
        
        self.voiceButton.bottom = self.sendTextView.bottom;
        _addButton.bottom = self.sendTextView.bottom;
        _emotionButton.bottom = self.sendTextView.bottom;
        self.sendBackView.frame = CGRectMake(0, self.view.height - textHeight - 14 - _keyboardHeight, WIDTH, textHeight + 14);
        
        
        self.tableView.frame = CGRectMake(0, 0, WIDTH, self.view.height - _keyboardHeight - self.sendBackView.height + 49);
        [self.sendTextView scrollRangeToVisible:self.sendTextView.selectedRange];
    }];
    
    if (self.datasource.count >= 1) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.datasource.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }

    
}
- (void)textViewDidChange:(UITextView *)textView
{
    

    
    [UIView animateWithDuration:.25 animations:^{
        float textHeight = [self heightForString:textView.text fontSize:17 andWidth:textView.frame.size.width];
        if (textHeight > 90) {
            textHeight = 90;
        }
        
        self.sendTextView.height = textHeight;
        
        self.voiceButton.bottom = self.sendTextView.bottom;
        _addButton.bottom = self.sendTextView.bottom;
        _emotionButton.bottom = self.sendTextView.bottom;
        self.sendBackView.frame = CGRectMake(0, self.view.height - textHeight - 14 - _keyboardHeight, WIDTH, textHeight + 14);
        
        
        self.tableView.frame = CGRectMake(0, 0, WIDTH, self.view.height - _keyboardHeight - self.sendBackView.height + 49);
        [self.sendTextView scrollRangeToVisible:self.sendTextView.selectedRange];
    }];
    
    if (self.datasource.count >= 1) {
      [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.datasource.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    
    
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    [UIView animateWithDuration:.25 animations:^{
        float textHeight = [self heightForString:textView.text fontSize:17 andWidth:textView.frame.size.width];
        if (textHeight > 90) {
            textHeight = 90;
        }
        
        self.sendTextView.height = textHeight;
        
        self.voiceButton.bottom = self.sendTextView.bottom;
        _addButton.bottom = self.sendTextView.bottom;
        _emotionButton.bottom = self.sendTextView.bottom;
        self.sendBackView.frame = CGRectMake(0, self.view.height - textHeight - 14 - _keyboardHeight, WIDTH, textHeight + 14);
        
        
        self.tableView.frame = CGRectMake(0, 0, WIDTH, self.view.height - _keyboardHeight - self.sendBackView.height + 49);
        [self.sendTextView scrollRangeToVisible:self.sendTextView.selectedRange];
    }];
    
    if (self.datasource.count >= 1) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.datasource.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    

    
    
    
    
}
#pragma mark -- 表情面板代理
- (void)choseFace:(NSString *)faceString{
    
    NSRange selectedRange = [self.sendTextView selectedRange];
    
    NSMutableString *str = [NSMutableString stringWithString:self.sendTextView.text];
    
    [str replaceCharactersInRange:selectedRange withString:faceString];
    self.sendTextView.text = str;
    self.sendTextView.selectedRange = NSMakeRange(selectedRange.location + str.length,0);
    [UIView animateWithDuration:.25 animations:^{
        float textHeight = [self heightForString:self.sendTextView.text fontSize:17 andWidth:self.sendTextView.frame.size.width];
        if (textHeight > 90) {
            textHeight = 90;
        }
        
        self.sendTextView.height = textHeight;
        
        self.voiceButton.bottom = self.sendTextView.bottom;
        _addButton.bottom = self.sendTextView.bottom;
        _emotionButton.bottom = self.sendTextView.bottom;
        self.sendBackView.frame = CGRectMake(0, self.view.height - textHeight - 14 - _keyboardHeight, WIDTH, textHeight + 14);
        
        
        self.tableView.frame = CGRectMake(0, 0, WIDTH, self.view.height - _keyboardHeight - self.sendBackView.height + 49);
        [self.sendTextView scrollRangeToVisible:self.sendTextView.selectedRange];
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
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
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
    static NSString *identifier = @"MyChatCell";
    
    MyChatCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        
        cell = [[MyChatCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle =     UITableViewCellSelectionStyleNone;

        cell.backgroundColor = [UIColor clearColor];
    }
    
    cell.model = self.datasource[indexPath.row];
    
//    [self makeVideoPlayer:cell.model.data];
    
    if (self.otherHeaderImages[cell.model.displayName]) {
        
        NSData *data = self.otherHeaderImages[cell.model.displayName];
        cell.leftHeaderView.image = [UIImage imageWithData:data];
    }
    
   
        if (cell.model.states == videoStates) {
//            [self makeVideoPlayer:cell.model.data];
             self.audioPlayer=[[AVAudioPlayer alloc]initWithData:cell.model.data error:nil];
            if (cell.model.isSelf) {
                cell.rightTimeSecondLabel.text = [NSString stringWithFormat:@"%.0f''",self.audioPlayer.duration];

                
            }else{
                cell.leftTimeSecondLabel.text = [NSString stringWithFormat:@"%.0f''",self.audioPlayer.duration];
 
                
            }
                NSLog(@"--------%f",self.audioPlayer.duration);        
        
    }
    
    
    __weak __typeof(cell)weakCell = cell;
    cell.voiceBlock = ^(NSURL *url,NSData *data,UIImageView *imageView){
        if (_currentVoiceView.isAnimating) {
            
            [_currentVoiceView stopAnimating];
            self.audioPlayer = nil;
        }
        _currentVoiceView = imageView;
        
        
        [_currentVoiceView startAnimating];
    
        weakCell.leftCorner.hidden = YES;
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
    NSString *nickName = UserDefaultsGet(MyNickName);
    if (!nickName) {
        nickName = [[UIDevice currentDevice]name];
        
    }
    
    self.sessionManager = [[BlueSessionManager alloc]initWithDisplayName:nickName];
    
    //
    [self.sessionManager didReceiveInvitationFromPeer:^void(MCPeerID *peer, NSData *context) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        if (_curretConnect == peer) {
            
            [self.sessionManager connectToPeer:YES];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"是否连接？" message:[NSString stringWithFormat:@"同 %@%@", peer.displayName, @" 连接?"] delegate:strongSelf cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alertView show];
        }
        
    }];
    
    [self.sessionManager peerConnectionStatusOnMainQueue:YES block:^(MCPeerID *peer, MCSessionState state) {
        if(state == MCSessionStateConnected) {
            
            if (UserDefaultsGet(@"headerIcon")) {
                [self ChangeHeaderIcon];
            }
            
         
            if (_curretConnect == peer) {
                
                
                
            }else{
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"连接成功" message:[NSString stringWithFormat:@"已连接 %@！", peer.displayName] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"知道了", nil];
                
                _curretConnect = peer;
                
                [alertView show];
                
                if (self.sessionManager.session.connectedPeers.count == 2) {
                    
                    self.title = @"群聊";
                    
                }else if(self.sessionManager.session.connectedPeers.count == 1) {
                    
                   self.title = peer.displayName;
                    
                }
                if (self.sessionManager.session.connectedPeers.count > 2) {
                    
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:@{
                                                                                 @"GroupName":self.title
                                                                                 }];
                    [self.sessionManager sendDataToAllPeers:data];
                    
                }
                
                [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(preventDisconnect:) userInfo:nil repeats:YES];
            }
            
        }
    }];
    
    // 收到正常数据的返回
    [self.sessionManager receiveDataOnMainQueue:YES block:^(NSData *data, MCPeerID *peer) {
        
        
        
        __strong typeof (weakSelf) strongSelf = weakSelf;
        
        
       id unarchiver = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        if ([unarchiver isKindOfClass:[NSDictionary class]]) {
            
        
            if (unarchiver[@"GroupName"]) {
                
                self.title = unarchiver[@"GroupName"];
                
                [[CustomAlertView shareCustomAlertView]showAlertViewWtihTitle:[NSString stringWithFormat:@"%@修改群聊名称为“%@”",peer.displayName,unarchiver[@"GroupName"]] viewController:nil];
            }
            
            return ;
        }
        
        NSString *string = unarchiver;
        if (string.length < 1) {
            return;
        }
        NSString *name = peer.displayName;
        
        [self playSoundEffect:@"5097.mp3"];
        ChatItem * chatItem = [[ChatItem alloc] init];
        chatItem.isSelf = NO;
        chatItem.states = textStates;
        chatItem.content = string;
        chatItem.displayName = name;
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yy-MM-dd HH:mm:ss"];
        NSString *dateStr = [formatter stringFromDate:date];
        chatItem.timeStr = dateStr;
        [strongSelf.datasource addObject:chatItem];
        // 加到数组里面
        
        [strongSelf insertTheTableToButtom];
        
        if (![UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            [self registerLocalNotification:0 message:[NSString stringWithFormat:@"%@:%@",name,string]];
        }

        
    }];
    
    // 收到图片之后的返回
    [self.sessionManager receiveFinalResourceOnMainQueue:YES complete:^(NSString *name, MCPeerID *peer, NSURL *url, NSError *error) {
        
        __strong typeof (weakSelf) strongSelf = weakSelf;
        NSData *data = [NSData dataWithContentsOfURL:url];
    
        if ([name hasSuffix:@"Icon"] && peer.displayName) {
            if (!self.otherHeaderImages) {
                self.otherHeaderImages = [@{}mutableCopy];
            }
//           UIImage *image = [UIImage imageWithData:data];
            
            [self.otherHeaderImages setObject:data forKey:peer.displayName];
            
            [self.tableView reloadData];
            
        }else if([name isEqualToString:@"video"]){
            
            [self playSoundEffect:@"5097.mp3"];
            ChatItem * chatItem = [[ChatItem alloc] init];
            chatItem.isSelf = NO;
            chatItem.displayName = peer.displayName;
            chatItem.states = videoStates;
            chatItem.data = data;
            NSDate *date = [NSDate date];
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"yy-MM-dd HH:mm:ss"];
            NSString *dateStr = [formatter stringFromDate:date];
            chatItem.timeStr = dateStr;
            [self.datasource addObject:chatItem];
            [self insertTheTableToButtom];
            if (![UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
                [self registerLocalNotification:0 message:[NSString stringWithFormat:@"%@:%@",chatItem.displayName,@"发送了一段语音"]];
            }
            
                
        }else{
            
            [self playSoundEffect:@"5097.mp3"];
            ChatItem * chatItem = [[ChatItem alloc] init];
            chatItem.isSelf = NO;
            chatItem.displayName = peer.displayName;
            chatItem.states = picStates;
            chatItem.content = name;
            chatItem.picImage = [UIImage imageWithData:data];
            NSDate *date = [NSDate date];
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"yy-MM-dd HH:mm:ss"];
            NSString *dateStr = [formatter stringFromDate:date];
            chatItem.timeStr = dateStr;
            [strongSelf.datasource addObject:chatItem];
            [strongSelf insertTheTableToButtom];
            if (![UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
                [self registerLocalNotification:0 message:[NSString stringWithFormat:@"%@:%@",chatItem.displayName,@"发送了一张图片"]];
            }

        }
        
        
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
        [[CustomAlertView shareCustomAlertView]showAlertViewWtihTitle:@"发送失败，连接已断开" viewController:nil];
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
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yy-MM-dd HH:mm:ss"];
        NSString *dateStr = [formatter stringFromDate:date];
        chatItem.timeStr = dateStr;
        [self.datasource addObject:chatItem];
        [self insertTheTableToButtom];
        
        NSOutputStream *output = (NSOutputStream *)aStream;
        [output write:data.bytes maxLength:data.length];
        [output close];
    }
    if(eventCode == NSStreamEventEndEncountered)
    {
        // 流结束事件，在此事件中负责做销毁工作
//        // 同时也是获得最终数据的好地方
//        [self playSoundEffect:@"5097.mp3"];
//        ChatItem * chatItem = [[ChatItem alloc] init];
//        chatItem.isSelf = NO;
//        chatItem.displayName = _curretConnect.displayName;
//        chatItem.states = videoStates;
//        chatItem.data = self.streamData;
//        NSDate *date = [NSDate date];
//        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//        [formatter setDateFormat:@"yy-MM-dd HH:mm:ss"];
//        NSString *dateStr = [formatter stringFromDate:date];
//        chatItem.timeStr = dateStr;
//        [self.datasource addObject:chatItem];
//        [self insertTheTableToButtom];
//        if (![UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
//            [self registerLocalNotification:0 message:[NSString stringWithFormat:@"%@:%@",chatItem.displayName,@"发送了一段语音"]];
//        }
//        [aStream close];
//        [aStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
//        if([aStream isKindOfClass:[NSInputStream class]])
//        {
//            self.streamData = nil;
//        }
        
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
    [dicM setObject:@(8000) forKey:AVSampleRateKey];
//    [dicM setObject:@(44100) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
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
//    float power= [self.audioRecorder peakPowerForChannel:0];
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
    [self setAudioSession];
    
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
//    if (self.sessionManager.session.connectedPeers.count > 1) {
        [self sendGroupChatVideoAsResource:[self getSavePath]];
//    }else{
        [self  sendAsStream];
//    }

//    NSLog(@"录音完成!");
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
//    NSLog(@"播放完成...");
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

#pragma mark -- 通知
// 设置本地通知
- (void)registerLocalNotification:(NSInteger)alertTime message:(NSString *)content{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    // 设置触发通知的时间
    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:alertTime];
    NSLog(@"fireDate=%@",fireDate);
    
    notification.fireDate = fireDate;
    // 时区
    notification.timeZone = [NSTimeZone defaultTimeZone];
    // 设置重复的间隔
//    notification.repeatInterval = kCFCalendarUnitSecond;
    
    // 通知内容
    notification.alertBody =  content;
//    notification.alertAction = @"滑动来查看";
    notification.applicationIconBadgeNumber  = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
    // 通知被触发时播放的声音
    notification.soundName = @"5097.mp3"; //UILocalNotificationDefaultSoundName;
    // 通知参数
    NSDictionary *userDict = [NSDictionary dictionaryWithObject:content forKey:@"key"];
    notification.userInfo = userDict;
    

    if ([UIDevice currentDevice].systemVersion.doubleValue >= 8.0) {
            //
        notification.alertTitle = @"新消息";
        notification.category = @"myCategory";
    }
        // 执行通知注册
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

// 取消某个本地推送通知
+ (void)cancelLocalNotificationWithKey:(NSString *)key {
    // 获取所有本地通知数组
    NSArray *localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    
    for (UILocalNotification *notification in localNotifications) {
        NSDictionary *userInfo = notification.userInfo;
        if (userInfo) {
            // 根据设置通知参数时指定的key来获取通知参数
            NSString *info = userInfo[key];
            
            // 如果找到需要取消的通知，则取消
            if (info != nil) {
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
                break;
            }
        }
    }
}
#pragma mark -- 不断发送数据 防止连接断开
- (void)preventDisconnect:(NSTimer *)timer{
    
    if (self.sessionManager.connectedPeers.count > 1) {
        return;
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:@{
                                                                 @"info":@"preventDisconnect"
                                                                 }];
    [self.sessionManager sendDataToAllPeers:data];
    
    
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
