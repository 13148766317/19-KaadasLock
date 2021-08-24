//
//  KDSProductActivationVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/5/14.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSProductActivationVC.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <WebKit/WebKit.h>


@interface KDSProductActivationVC ()<WKNavigationDelegate, WKUIDelegate>

@property (nonatomic,strong)  WKWebView *webView;

@end

@implementation KDSProductActivationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = Localized(@"ProductActivation");
    self.webView = [WKWebView new];
    [self.view addSubview:self.webView];
    //设置自动缩放网页以适应该控件
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.mas_equalTo(0);
    }];
    
    NSString * url = @"http://s.kaadas.com:8989/extFun/regWeb.asp?uiFrm=2";
    ///去掉86区号:手机号码、邮箱
    NSString * telNumStr = [[KDSUserManager sharedManager].user.name substringFromIndex:2];
    //%20替换空格
    self.productId = [self.productId stringByReplacingOccurrencesOfString:@" "withString:@"%20"];
    
    NSString *addressStr = [NSString stringWithFormat:@"%@&id=%@&telnum=%@&mail=%@&nickname=%@",url,self.productId,telNumStr,[KDSUserManager sharedManager].user.name,[KDSUserManager sharedManager].user.name];
    if (![addressStr hasPrefix:@"http://"]) {
        
        addressStr = [NSString stringWithFormat:@"http://%@",addressStr];
        
    }
    NSLog(@"--{Kaadas}--产品激活地址==%@",addressStr);

    //创建URL请求
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:addressStr]];
    
    //加载指定URL对应的网页
    
    [self.webView loadRequest:request];
}

-(void)navBackClick
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
