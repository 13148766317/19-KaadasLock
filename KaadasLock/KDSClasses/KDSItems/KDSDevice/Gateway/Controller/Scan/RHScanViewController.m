//
//  RHScanViewController.m
//  RHScan
//
//  Created by river on 2018/2/1.
//  Copyright © 2018年 richinfo. All rights reserved.
//

#import "RHScanViewController.h"
#import "RHScanPermissions.h"
#import "RHScanNative.h"
#import "RHScanView.h"
#import <AudioToolbox/AudioToolbox.h> //声音提示
#import "KDSAddGWThreVC.h"
#import "KDSProductActivationVC.h"
#import "KDSAddNewWiFiLockStep1VC.h"
#import "MBProgressHUD+MJ.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <WebKit/WebKit.h>
#import "KDSAddBleAndWiFiLockStep1.h"
#import "KDSAddVideoWifiLockStep1VC.h"
#import "KDSAddSmartHangerStep1VC.h"

@interface RHScanViewController ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate,backBtnDelegate,WKNavigationDelegate, WKUIDelegate>

#pragma mark -----  扫码使用的库对象 -------
@property (nonatomic,strong) RHScanNative* scanObj;
/// 扫码区域视图,二维码一般都是框
@property (nonatomic,strong) RHScanView* qRScanView;
///记录开始的缩放比例
@property(nonatomic,assign)CGFloat beginGestureScale;
///最后的缩放比例
@property(nonatomic,assign)CGFloat effectiveScale;
///上个导航控制器的代理。
@property (nonatomic, weak)id<UINavigationControllerDelegate> preDelegate;
@property (nonatomic,strong)WKWebView *webView;
///请求web页面超时
@property (nonatomic,strong)NSTimer * timeOut;
///获取开锁记录时转的菊花。
@property (nonatomic, strong)UIActivityIndicatorView *nodataActivity;
@property (nonatomic,strong)UIView * supView;


@end

@implementation RHScanViewController

#pragma mark - life

- (UIActivityIndicatorView *)nodataActivity
{
    if (!_nodataActivity)
    {
        _nodataActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        CGPoint center = CGPointMake(kScreenWidth / 2.0, self.view.bounds.size.height / 2.0);
        _nodataActivity.center = center;
        [self.view addSubview:_nodataActivity];
    }
    return _nodataActivity;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.view.backgroundColor = UIColor.blackColor;
    _effectiveScale = 1;
    [self cameraInitOver];
    [self drawScanView];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.preDelegate = self.navigationController.delegate;
    self.navigationController.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [RHScanPermissions requestCameraPemissionWithResult:^(BOOL granted) {
        if (granted) {
            //不延时，可能会导致界面黑屏并卡住一会
            [self performSelector:@selector(startScan) withObject:nil afterDelay:0.1];
        }else{
            [_qRScanView stopDeviceReadying];
            [self showError:@"请到设置隐私中开启本程序相机权限" withReset:NO];
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.delegate = self.preDelegate;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self stopScan];
    [_qRScanView stopScanAnimation];
    self.navigationController.navigationBar.barTintColor = UIColor.whiteColor;
    
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


//绘制扫描区域
- (void)drawScanView
{
    if (!_qRScanView)
    {
        CGRect rect = self.view.frame;
        rect.origin = CGPointMake(0, 0);
        if (_style == nil) {
            _style = [RHScanViewStyle new];
        }
        self.qRScanView = [[RHScanView alloc]initWithFrame:rect style:_style];
        self.qRScanView.delegate = self;
        [self.view addSubview:_qRScanView];
    }
    [_qRScanView startDeviceReadyingWithText:_cameraInvokeMsg];
}

#pragma mark 增加拉近/远视频界面
- (void)cameraInitOver
{
    if (self.isVideoZoom) {
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchDetected:)];
        pinch.delegate = self;
        [self.view addGestureRecognizer:pinch];
    }
}

- (void)pinchDetected:(UIPinchGestureRecognizer*)recogniser
{
    self.effectiveScale = self.beginGestureScale * recogniser.scale;
    if (self.effectiveScale < 1.0){
        self.effectiveScale = 1.0;
    }
    [self.scanObj setVideoScale:self.effectiveScale];
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        _beginGestureScale = _effectiveScale;
    }
    return YES;
}

- (void)reStartDevice
{
    [_scanObj startScan];
}

//启动设备
- (void)startScan
{
    if ( ![RHScanPermissions cameraPemission] )
    {
        [_qRScanView stopDeviceReadying];
        [self showError:@"请到设置隐私中开启本程序相机权限" withReset:NO];
        return;
    }
    
    UIView *videoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    videoView.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:videoView atIndex:0];
    __weak __typeof(self) weakSelf = self;
    
    if (!_scanObj )
    {
        CGRect cropRect = CGRectZero;
        if (_isOpenInterestRect) {
            //设置只识别框内区域
            cropRect = [RHScanView getScanRectWithPreView:self.view style:_style];
        }
        //AVMetadataObjectTypeITF14Code 扫码效果不行,另外只能输入一个码制，虽然接口是可以输入多个码制
        self.scanObj = [[RHScanNative alloc]initWithPreView:videoView ObjectType:nil cropRect:cropRect success:^(NSArray<NSString *> *array) {
            [weakSelf scanResultWithArray:array];
        }];
        [_scanObj setNeedCaptureImage:NO];
        [_scanObj setNeedAutoVideoZoom:YES];
    }
    [_scanObj startScan];
    [_qRScanView stopDeviceReadying];
    [_qRScanView startScanAnimation];
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)stopScan
{
    [_scanObj stopScan];
}

#pragma mark - 扫码结果处理

- (void)scanResultWithArray:(NSArray<NSString*>*)array
{
    //经测试，可以同时识别2个二维码，不能同时识别二维码和条形码
    if (array.count < 1)
    {
        [self showError:@"识别失败了" withReset:YES];
        return;
    }
    if (!array[0] || [array[0] isEqualToString:@""] ) {
        [self showError:@"识别失败了" withReset:YES];
        return;
    }
    NSString *scanResult = array[0];
    NSLog(@"%@",scanResult);
    [self showError:scanResult withReset:YES];
    //TODO: 这里可以根据需要自行添加震动或播放声音提示相关代码
    NSURL *url=[[NSBundle mainBundle]URLForResource:@"scanSuccess.wav" withExtension:nil];
    //2.加载音效文件，创建音效ID（SoundID,一个ID对应一个音效文件）
    SystemSoundID soundID=8787;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
    //3.播放音效文件
    //下面的两个函数都可以用来播放音效文件，第一个函数伴随有震动效果
    AudioServicesPlayAlertSound(soundID);
    AudioServicesPlaySystemSound(8787);
}



#pragma mark - 提示语
- (void)showError:(NSString*)str withReset:(BOOL)isRest
{
    if (str==nil || [str isEqualToString:@""]) {
        str =@"扫码失败，请重新扫一扫";
    }else{
        if ([self.fromWhereVC isEqualToString:@"GatewayVC"]) {///网关
            KDSAddGWThreVC *vc = [[KDSAddGWThreVC alloc] init];
            vc.dataStr = str;
            [self.navigationController pushViewController:vc animated:YES];
        }if ([self.fromWhereVC isEqualToString:@"MineVC"]) {///产品激活
            KDSProductActivationVC * vc = [KDSProductActivationVC new];
            vc.productId = str;
            [self.navigationController pushViewController:vc animated:YES];
            
        }
        if ([self.fromWhereVC isEqualToString:@"AddDeviceVC"]) {///扫一扫
            if ([str containsString:@"GW"]) {//扫描的网关
                KDSAddGWThreVC *vc = [[KDSAddGWThreVC alloc] init];
                vc.dataStr = str;
                [self.navigationController pushViewController:vc animated:YES];
            }else if ([str containsString:@"_WiFi_1"] || [str containsString:@"_WiFi_master"] || [str containsString:@"_WiFi_2"] || [str containsString:@"_WiFi_fast"] ||  [str containsString:@"_WiFi_Fast"]){
                ///wifi配网
                KDSAddNewWiFiLockStep1VC * vc = [KDSAddNewWiFiLockStep1VC new];
                [self.navigationController pushViewController:vc animated:YES];
                
            }else if ([str containsString:@"_WiFi&BLE_"]){
                if ([str containsString:@"SmartHanger"]){///晾衣机：kaadas_M8-E1_WiFi&BLE_SmartHanger
                    //晾衣机：kaadas_M8-E1_WiFi&BLE_Fast

                    NSArray *array = [str componentsSeparatedByString:@"_"]; //从字符_中分隔成2个元素的数组
//                    NSLog(@"array:%@",array[1]);
                    NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@晾衣机，是否进入配网？",array[1]] attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 15], NSForegroundColorAttributeName: [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0]}];
//                    NSString *message = [NSString stringWithFormat:@"%@晾衣机，是否进入配网？",array[1]];
                    UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:nil message:@"message" preferredStyle:UIAlertControllerStyleAlert];

                    [alerVC setValue:message forKey:@"attributedMessage"];

                    UIAlertAction * sureAction = [UIAlertAction actionWithTitle:Localized(@"yes") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        KDSAddSmartHangerStep1VC * vc = [KDSAddSmartHangerStep1VC new];
                        [self.navigationController pushViewController:vc animated:YES];
                    }];
                    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:Localized(@"no") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        //不延时，可能会导致界面黑屏并卡住一会
                        [self performSelector:@selector(startScan) withObject:nil afterDelay:0.1];
                    }];
                    [alerVC addAction:cancleAction];
                    [alerVC addAction:sureAction];
                    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
                    [rootViewController presentViewController:alerVC animated:YES completion:nil];
                   
                }else{
                    ///锁
                    KDSAddBleAndWiFiLockStep1 * vc = [KDSAddBleAndWiFiLockStep1 new];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }else if ([str containsString:@"kaadas_WiFi_camera"]){
                ///video+wifi
                KDSAddVideoWifiLockStep1VC * vc = [KDSAddVideoWifiLockStep1VC new];
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                if ([str hasPrefix:@"http://"] || [str hasPrefix:@"https://"]) {///这里是有个产品经理搞错二维码的代价
                    
                    self.supView = [UIView new];
                    self.supView.backgroundColor = UIColor.whiteColor;
                    self.supView.layer.cornerRadius = 4;
                    self.supView.layer.masksToBounds = YES;
                    [self.view addSubview:self.supView];
                    [self.supView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.width.equalTo(@200);
                        make.height.equalTo(@100);
                        make.centerX.centerY.equalTo(self.view);
                    }];
                    
                    [self.nodataActivity startAnimating];
                    if (self.webView == nil) {
                        self.webView = [[WKWebView alloc] init];
                    }
                    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
                    self.webView.UIDelegate = self;
                    self.webView.navigationDelegate = self;
                    [self.supView addSubview:self.webView];
                    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.width.equalTo(@150);
                        make.height.equalTo(@50);
                        make.top.equalTo(self.supView.mas_top).offset(0);
                        make.centerX.equalTo(self.supView);
                    }];
                    UILabel * lb = [UILabel new];
                    lb.text = @"加载中。。。。";
                    lb.textColor = UIColor.blackColor;
                    lb.textAlignment = NSTextAlignmentCenter;
                    lb.font = [UIFont systemFontOfSize:15];
                    [self.supView addSubview:lb];
                    [lb mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.height.equalTo(@20);
                        make.centerX.equalTo(self.supView);
                        make.bottom.equalTo(self.supView.mas_bottom).offset(-5);
                        
                    }];
                    self.timeOut = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(timeOutClick:) userInfo:nil repeats:NO];
                }else{
                    [self.navigationController popViewControllerAnimated:YES];
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
                    hud.mode =MBProgressHUDModeText;
                    hud.detailsLabel.text = str;
                    hud.bezelView.backgroundColor = [UIColor blackColor];
                    hud.detailsLabel.textColor = [UIColor whiteColor];
                    hud.detailsLabel.font = [UIFont systemFontOfSize:15];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [hud hideAnimated:YES];
                    });
                }
            }
        }
    }
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    //根据标识符获取不同内容
    [webView evaluateJavaScript:@"document.documentElement.innerHTML" completionHandler:^(NSString *result, NSError * _Nullable error) {
        NSLog(@"当前扫描的结果：%@",result);
        if (![result containsString:@"jump_url"]) {
            [self.nodataActivity stopAnimating];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.timeOut invalidate];
                self.timeOut = nil;
                if ([result containsString:@"_WiFi_2"] || [result containsString:@"_WiFi_fast"] || [result containsString:@"_WiFi_1"] || [result containsString:@"_WiFi_master"]){
                    
                    //新的添加Wi-Fi锁流程 目前新旧配网合成一个
                    KDSAddNewWiFiLockStep1VC * vc = [KDSAddNewWiFiLockStep1VC new];
                    [self.navigationController pushViewController:vc animated:YES];
                    [self.webView removeFromSuperview];
                    
                }else{
                    [self.navigationController popViewControllerAnimated:YES];
                    [self.webView removeFromSuperview];
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
                    hud.mode =MBProgressHUDModeText;
                    hud.detailsLabel.text = @"扫描的二维码不符合规定";
                    hud.bezelView.backgroundColor = [UIColor blackColor];
                    hud.detailsLabel.textColor = [UIColor whiteColor];
                    hud.detailsLabel.font = [UIFont systemFontOfSize:15];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [hud hideAnimated:YES];
                    });
                }
            });
        }
        
    }];
    
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    //根据标识符获取不同内容
    [webView evaluateJavaScript:@"document.documentElement.innerHTML" completionHandler:^(id result, NSError * _Nullable error) {
        NSLog(@"当前扫描的结果：%@",result);
        NSString *attach_title = @"";
        if ([result isKindOfClass:[NSString class]]) {
            attach_title = result;
        }
    }];
    
}


#pragma mark - UINavigationControllerDelegate



- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [navigationController setNavigationBarHidden:YES animated:YES];//!iOS 9
}



-(void)popViewControl
{
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark 定时器响应事件
-(void)timeOutClick:(NSTimer *)overTimer
{
    [self.navigationController popViewControllerAnimated:YES];
    [MBProgressHUD showError:@"请检查网络或扫描正确的二维码！"];
}

@end

