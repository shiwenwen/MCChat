//
//  FileDetailViewController.m
//  MCChat
//
//  Created by sww on 16/3/3.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import "FileDetailViewController.h"
#import <QuickLook/QuickLook.h>
@interface FileDetailViewController ()<UIDocumentInteractionControllerDelegate,QLPreviewControllerDelegate,QLPreviewControllerDataSource>

@end

@implementation FileDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.logoImage.image = self.model.logoImage;
    self.nameLabel.text = self.model.name;
    self.timeLabel.text = self.model.detail;
    self.sizeLabel.text = self.model.size;
    CGFloat width = (KScreenWidth -45)/4;
    CGFloat height = (self.toolBarView.height - 20);
    for (int i = 0; i < 3; i++) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        
        button.layer.cornerRadius = 5;
        button.tag = 1000+i;
        button.layer.masksToBounds = YES;
        button.layer.borderColor = [UIColor grayColor].CGColor;
        button.layer.borderWidth = .5;
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button addTarget:self action:@selector(fileButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        if (i == 0) {
            button.frame = CGRectMake(15 + i * width, 10, width*2, height);
            [button setTitle:@"使用其他程序打开" forState:UIControlStateNormal];
            button.backgroundColor = [UIColor colorWithRed:0.109 green:0.463 blue:1.000 alpha:1.000];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
        }else if (i == 1){
            button.frame = CGRectMake(15*i + (i+1) * width, 10, width, height);
            
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
                    title = @"查看";
                }
                    break;
                default:{
                    title = @"暂不支持";
                }
                    break;
            }
            
            [button setTitle:title forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithRed:0.109 green:0.463 blue:1.000 alpha:1.000] forState:UIControlStateNormal];
        }else{
            button.frame = CGRectMake(15*i + (i+1) * width, 10, width, height);
            [button setTitle:@"发送" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithRed:0.109 green:0.463 blue:1.000 alpha:1.000] forState:UIControlStateNormal];
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
          
        [self presentViewController:myQlPreViewController animated:YES completion:^{
            
        }];
        
        }
        
        
    }else{
        
        //发送
        
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
