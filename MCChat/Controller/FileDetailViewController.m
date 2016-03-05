//
//  FileDetailViewController.m
//  MCChat
//
//  Created by sww on 16/3/3.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import "FileDetailViewController.h"
#import <QuickLook/QuickLook.h>
#import "PreviewViewController.h"
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SSZipArchive.h"
#import "MBProgressHUD.h"
@interface FileDetailViewController ()<UIDocumentInteractionControllerDelegate,QLPreviewControllerDelegate,QLPreviewControllerDataSource,UIAlertViewDelegate>

@end

@implementation FileDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.model.name;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.logoImage.contentMode = UIViewContentModeScaleAspectFit;

    self.logoImage.image = self.model.logoImage;
    self.nameLabel.text = self.model.name;
    self.timeLabel.text = self.model.detail;
    self.sizeLabel.text = self.model.size;
    CGFloat width = (KScreenWidth -60)/4;
    CGFloat height = (self.toolBarView.height - 10);
    for (int i = 0; i < 3; i++) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        
        button.layer.cornerRadius = 5;
        button.tag = 2000+i;
        button.layer.masksToBounds = YES;
        button.layer.borderColor = [UIColor colorWithWhite:0.763 alpha:1.000].CGColor;
        button.layer.borderWidth = .25;
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button addTarget:self action:@selector(fileButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.toolBarView addSubview:button];
        if (i == 0) {
            button.frame = CGRectMake(15 + i * width, 5, width*2, height);
            [button setTitle:@"使用其他程序打开" forState:UIControlStateNormal];
            button.backgroundColor = [UIColor colorWithRed:0.165 green:0.631 blue:1.000 alpha:1.000];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
        }else if (i == 1){
            button.frame = CGRectMake( (i+1) * (width+15), 5, width, height);
            
            NSString *title;
            
            switch (self.model.fileType) {
                case Word:{
                    
                };
                case Excel:{
                    
                };
                case PowerPoint:{
                    
                    
                };
                case txt:{
                    
                };
                case pdf:{
                    title = @"预览";
                }
                    break;
                case music:{
                    title = @"播放";
                }
                case video:{
                    title = @"播放";
                }
                    break;
                case image:{
                    title = @"保存到相册";
                }
                    break;
                default:{
                    
                    title = @"暂不支持";
                    if ([[self.model.name pathExtension]isEqualToString:@"zip"]) {
                        
                        title = @"解压";
                    }
                }
                    break;
            }
            
            [button setTitle:title forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithRed:0.165 green:0.631 blue:1.000 alpha:1.000] forState:UIControlStateNormal];
            
            if ([title isEqualToString:@"暂不支持"]) {
                button.alpha = 0.5;
            
            }
            if ([title isEqualToString:@"保存到相册"]) {
                self.logoImage.userInteractionEnabled = YES;
                self.logoImage.frame = CGRectMake(self.logoImage.left - 50, self.logoImage.top + 100, self.logoImage.width + 100, self.logoImage.height+100);
            }else{
                self.logoImage.userInteractionEnabled = NO;
            }
            
        }else{
            button.frame = CGRectMake((i+1) * (width+15), 5, width, height);
            [button setTitle:@"发送" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithRed:0.165 green:0.631 blue:1.000 alpha:1.000] forState:UIControlStateNormal];
        }
    }

    
    
}

- (void)fileButtonClick:(UIButton *)button{
    if (button.tag == 2000) {
        //使用其他程序打开
        
        NSString *cachePath = self.model.path;
        
        
        
        UIDocumentInteractionController *documentController =
        
        
        [UIDocumentInteractionController
         
         interactionControllerWithURL:[NSURL fileURLWithPath:cachePath]];
        
        documentController.delegate = self;
        
        
        
        [documentController presentOpenInMenuFromRect:CGRectZero
         
                                               inView:self.view
         
                                             animated:YES];
        
        
    }else if (button.tag == 2001){
        //打开 预留 播放
        if ([button.titleLabel.text isEqualToString:@"预览"]) {
            QLPreviewController *myQlPreViewController = [[QLPreviewController alloc]init];
           
            myQlPreViewController.delegate =self;
           
            myQlPreViewController.dataSource =self;
          
            [myQlPreViewController setCurrentPreviewItemIndex:0];
          
//        [self presentViewController:myQlPreViewController animated:YES completion:^{
//            
//        }];
//
            [self.navigationController pushViewController:myQlPreViewController animated:YES];
        }else if ([button.titleLabel.text isEqualToString:@"保存到相册"]){
            
            
            UIImageWriteToSavedPhotosAlbum(self.logoImage.image, self,@selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
            
        }else if (self.model.fileType == video||self.model.fileType == music){


            MPMoviePlayerViewController *playerVC = [[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL fileURLWithPath:self.model.path]];
            
            
            [self presentMoviePlayerViewControllerAnimated:playerVC];
            
            [playerVC.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
            
            [playerVC.view setBackgroundColor:[UIColor clearColor]];
            
            [playerVC.view setFrame:self.view.bounds];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
             
                                                    selector:@selector(movieFinishedCallback:)
             
                                                        name:MPMoviePlayerPlaybackDidFinishNotification
             
                                                      object:playerVC.moviePlayer];
            
            
        }else if(self.model.fileType == zip){
            NSString *destination = [self.model.path stringByReplacingOccurrencesOfString:@".zip" withString:@""];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            // Set the label text.
            hud.label.text = @"解压中";
            // Set the details label text. Let's make it multiline this time.
            hud.detailsLabel.text = @"文件\n(1/1)";
            


                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                // 解压(文件大, 会比较耗时，所以放到子线程中解压)
              BOOL archiveResult =  [SSZipArchive unzipFileAtPath:self.model.path toDestination:destination progressHandler:^(NSString *entry, unz_file_info zipInfo, long entryNumber, long total) {
                       dispatch_async(dispatch_get_main_queue(), ^{
                           hud.detailsLabel.text = [NSString stringWithFormat:@"文件\n(%ld/%ld)",entryNumber,total];

                       });
                    
                } completionHandler:^(NSString *path, BOOL succeeded, NSError *error) {
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [hud hideAnimated:YES];
                        
                        if (succeeded) {
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"解压成功" message:self.model.name delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"查看", nil];
                            [alert show];
                        }else{
                            
                            [[CustomAlertView shareCustomAlertView]showAlertViewWtihTitle:[NSString stringWithFormat:@"解压失败\n%@",error] viewController:nil];
                            NSLog(@"%@",error);
                        }
                        
                        
                    });
                   }];
                        
                        
            });
            
        }
        
    }else{
        
        //发送
         [[NSNotificationCenter defaultCenter]postNotificationName:@"PostFile" object:self.model];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        
        
    }else{
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    
    if (!error) {
        [[CustomAlertView shareCustomAlertView]showAlertViewWtihTitle:@"保存成功" viewController:nil];
    }else
    {
        [[CustomAlertView shareCustomAlertView]showAlertViewWtihTitle:@"保存失败" viewController:nil];
    }
    
}



#pragma mark - UIDocumentInteractionControllerDelegate
-(void)documentInteractionController:(UIDocumentInteractionController *)controller

didEndSendingToApplication:(NSString *)application

{
    
    
    
}


-(void)documentInteractionControllerDidDismissOpenInMenu:

(UIDocumentInteractionController *)controller

{
    
    
    
}
#pragma mark - QuickLook Delegate DataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller

{
   
    return 1;
   
}
- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index

{
    
    
    return [NSURL fileURLWithPath:self.model.path];
    
    
}
#pragma mark - moviePlayerNotification
-(void)movieStateChangeCallback:(NSNotification*)notify  {
    
    //点击播放器中的播放/ 暂停按钮响应的通知
    
}

-(void)movieFinishedCallback:(NSNotification*)notify{
    
    // 视频播放完或者在presentMoviePlayerViewControllerAnimated下的Done按钮被点击响应的通知。
    
    MPMoviePlayerController* theMovie = [notify object];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
     
                                                   name:MPMoviePlayerPlaybackDidFinishNotification
     
                                                 object:theMovie];
    
    [self dismissMoviePlayerViewControllerAnimated];
    
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
