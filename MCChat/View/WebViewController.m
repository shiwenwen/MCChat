//
//  WebViewController.m
//  GoToSchool
//
//  Created by 蔡连凤 on 15/6/25.
//  Copyright (c) 2015年 UI. All rights reserved.
//

#import "WebViewController.h"
@interface WebViewController ()<UIWebViewDelegate>
{
    UIWebView * _webView;
}
@end

@implementation WebViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _webView  = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0,KScreenWidth, KScreenHeight)];
    _webView.delegate = self;
    
    if (self.data) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:self.httpUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
        request.HTTPMethod = @"POST";


        [request addValue:@"application/json" forHTTPHeaderField:@"content-type"];
        
      NSData *data = [NSJSONSerialization dataWithJSONObject:self.data options:NSJSONWritingPrettyPrinted error:nil];
        
        request.HTTPBody = data;
        
        
        [_webView loadRequest:request];
        
    }else{
        
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.httpUrl]]];
    }
    
   
    _webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_webView];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
 
}
- (void)goBack{
    

[self.navigationController dismissViewControllerAnimated:YES completion:^{
    
}];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
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
