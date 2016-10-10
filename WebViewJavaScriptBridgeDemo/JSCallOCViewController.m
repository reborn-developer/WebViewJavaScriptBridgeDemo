//
//  JSCallOCViewController.m
//  JavaScriptCoreDemo
//
//  Created by reborn on 16/9/12.
//  Copyright © 2016年 reborn. All rights reserved.
//

#import "JSCallOCViewController.h"
#import "WebViewJavascriptBridge.h"

#define kScreenWidth                [UIScreen mainScreen].bounds.size.width
#define kScreenHeight               [UIScreen mainScreen].bounds.size.height

@interface JSCallOCViewController ()<UIWebViewDelegate>
@property(nonatomic, strong) UIWebView *webView;
@property(nonatomic, strong) WebViewJavascriptBridge *bridge;
@end

@implementation JSCallOCViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"js call oc";
    self.view.backgroundColor = [UIColor whiteColor];

    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    [self.view addSubview:self.webView];
    
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"WebViewJavaScriptBridge" ofType:@"html"];
    NSString *appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [self.webView loadHTMLString:appHtml baseURL:baseURL];
    
    // 开启日志
    [WebViewJavascriptBridge enableLogging];
    
    // 给webview建立JS与OjbC的沟通桥梁
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    
    [self.bridge setWebViewDelegate:self];
    
    
    // JS调用OjbC的方法
    // 这是JS会调用callme方法，这是OC注册给JS调用的
    // JS需要回调，当然JS也可以传参数过来。data就是JS所传的参数，不一定需要传
    // OC端通过responseCallback回调JS端，JS就可以得到所需要的数据
    
    [self.bridge registerHandler:@"callme" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSLog(@"执行任务了, data from js is %@", data);
        
        if (responseCallback) {
            
            //OC反馈给JS
            responseCallback(@"这是OC给JS的反馈哦~");

        }
    }];
    
    
    [self.bridge registerHandler:@"callAlert" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"执行弹框任务了, data from js is %@", data);
        if (responseCallback) {
            
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"this is a message" message:[data objectForKey:@"title"] preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alertControl addAction:cancelAction];
            [self.navigationController presentViewController:alertControl animated:YES completion:nil];
            
            //OC反馈给JS
            responseCallback(@{@"success": @"本地反馈给js"});
        }
    }];
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"webViewDidFinishLoad");
}



@end
