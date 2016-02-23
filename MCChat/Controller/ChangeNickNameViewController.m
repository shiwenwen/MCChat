//
//  ChangeNickNameViewController.m
//  MCChat
//
//  Created by 石文文 on 16/2/15.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import "ChangeNickNameViewController.h"

@interface ChangeNickNameViewController ()<UITextFieldDelegate>


@end

@implementation ChangeNickNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    self.nickNameField.delegate = self;
    self.nickNameField.placeholder = self.placehold;
    [self.nickNameField becomeFirstResponder];
    if (self.style == groupName) {
        
        self.detailLabel.hidden = YES;
        
    }
}
- (void)goBack{
    
    if (self.nickNameField.text.length < 1) {
        
        [[CustomAlertView shareCustomAlertView]showAlertViewWtihTitle:@"未修改" viewController:nil];

    }else{
        
        self.changeBlock(self.nickNameField.text,self.style);
    }
    
    [self.navigationController popViewControllerAnimated:YES];

}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    
    
    
    
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
