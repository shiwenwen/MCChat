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
@interface FileDetailViewController ()<UIDocumentInteractionControllerDelegate,QLPreviewControllerDelegate,QLPreviewControllerDataSource>

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
            
        }
        
        
    }else{
        
        //发送
        
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
