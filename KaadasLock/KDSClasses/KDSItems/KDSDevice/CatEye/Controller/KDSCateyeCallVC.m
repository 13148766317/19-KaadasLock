//
//  KDSCateyeCallVC.m
//  KaadasLock
//
//  Created by wzr on 2019/4/26.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSCateyeCallVC.h"
#import "CYLineLayout.h"
#import "CYPhotoCell.h"
#import "MBProgressHUD+MJ.h"
#import "LinphoneManager.h"
#import "AppDelegate.h"
#import "KDSFTIndicator.h"
#import "ReactiveObjC.h"
#import <NSObject+RACKVOWrapper.h>

#define TopBgViewHeightNormal   299

//#define TopBgViewHeightPlaying   230

static NSString * const CYPhotoId = @"photo";

@interface KDSCateyeCallVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    float zoomLevel, cx, cy;
}
///用collectionview来展示已经绑定的门锁
@property (weak, nonatomic) IBOutlet UIView *deviceSupView;
///用来展示视频流
@property (weak, nonatomic) IBOutlet UIImageView *videoBgImg;
///app呼叫按钮
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
///用来展示猫眼所在的网关下的网关锁
@property (nonatomic,readwrite,strong)UICollectionView * collectionView;
///网关锁的数据源
@property (nonatomic, strong) NSMutableArray *cateyeLockArr;
///父视图：截图、静音、免提、录屏
@property (weak, nonatomic) IBOutlet UIView *bottomView;
///通话时长的LB
@property (weak, nonatomic) IBOutlet UILabel *callTimeLab;
///通话时长的定时器
@property (nonatomic, strong) NSTimer *callTimer;
@property (nonatomic, strong) KDSLock *lock;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topBgViewHeightConstraint;
///切换横竖屏的按钮
@property (weak, nonatomic) IBOutlet UIButton *landscapBtn;
///父视图：截图、静音、免提、录屏
@property (weak, nonatomic) IBOutlet UIView *bottmView2;
///截图按钮
@property (weak, nonatomic) IBOutlet UIButton *jietu1Btn;
///截图按钮
@property (weak, nonatomic) IBOutlet UIButton *jietu2Btn;
///静音
@property (weak, nonatomic) IBOutlet UIButton *silence1Btn;
///静音
@property (weak, nonatomic) IBOutlet UIButton *silence2Btn;
///免提
@property (weak, nonatomic) IBOutlet UIButton *mianti1Btn;
///免提
@property (weak, nonatomic) IBOutlet UIButton *mainti2Btn;
///录屏
@property (weak, nonatomic) IBOutlet UIButton *luping1Btn;
///录屏
@property (weak, nonatomic) IBOutlet UIButton *luping2Btn;
///猫眼离线的icon
@property (nonatomic, assign) float topBgViewHeightPlaying;
@property (weak, nonatomic) IBOutlet UIImageView *offlineImgView;
///网关锁的父视图到底部的距离
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deviceSupViewBottomConstraint;
@property (nonatomic,copy) NSString *imgVideoNameStr;
@property (nonatomic,assign) BOOL stopRecordEnable;
@end

@implementation KDSCateyeCallVC
- (void)viewDidLoad {
    NSLog(@"viewDidLoad");
    [super viewDidLoad];
    self.stopRecordEnable = NO;
    self.navigationTitleLabel.text = self.gatewayDeviceModel.nickName ?: self.gatewayDeviceModel.deviceId;
    [self setUI];
    KDSWeakSelf(self)
    [[KDSUserManager sharedManager].cateyes enumerateObjectsUsingBlock:^(KDSCatEye * _Nonnull cateye, NSUInteger idx, BOOL * _Nonnull stop) {
           if ([cateye.gatewayDeviceModel.deviceId isEqualToString:[KDSUserManager sharedManager].getCurrentCateyeId]) {
               *stop = YES;
               if (!cateye.isCalling) {
                   [weakself displayVideoToImg];
               }
           }
       }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localeLanguageDidChange:) name:KDSLocaleLanguageDidChangeNotification object:nil];
    //通话状态的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callUpdateEvent:) name:kLinphoneCallUpdate object:nil];
}
    
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self getCateyeGWLock];
    NSLog(@"viewWillAppear");
    //设置屏幕常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
//    KDSWeakSelf(self)
//    [[KDSUserManager sharedManager].cateyes enumerateObjectsUsingBlock:^(KDSCatEye * _Nonnull cateye, NSUInteger idx, BOOL * _Nonnull stop) {
//        if ([cateye.gatewayDeviceModel.deviceId isEqualToString:[KDSUserManager sharedManager].getCurrentCateyeId]) {
//            *stop = YES;
//            if (!cateye.isCalling) {
//                [weakself displayVideoToImg];
//            }
//        }
//    }];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    LinphoneCall *call = [LinphoneManager instance].currentCall;
    if (call){
        if (_luping1Btn.selected ||_luping2Btn.selected) {
            linphone_call_stop_recording(call);
            [self p_setupFileRename:[KDSUserManager sharedManager].currentCallRecordPathName];
        }
        [LinphoneManager.instance hangUpCall];
    }
    if (_callTimer) {
        [_callTimer invalidate];
        _callTimer = nil;
    }
    //关闭屏幕常亮设置
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}
-(void)navBackClick{
    if (self.luping1Btn.selected || self.luping2Btn.selected) {
        [MBProgressHUD showError:@"请先终止录屏"];
        return;
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
// 允许自动旋转
-(BOOL)shouldAutorotate{
    return NO;
}
// 横屏时是否将状态栏隐藏
-(BOOL)prefersStatusBarHidden{
    return NO;
}
-(void)setUI{
    if (KDSScreenWidth > 375) {
        _topBgViewHeightPlaying = 230;
    }else{
        _topBgViewHeightPlaying = 211;
    }
    [self.jietu1Btn setTitle:Localized(@"截图") forState:UIControlStateNormal];
    [self.jietu2Btn setTitle:Localized(@"截图") forState:UIControlStateNormal];
    
    [self.silence1Btn setTitle:Localized(@"静音") forState:UIControlStateNormal];
    [self.silence2Btn setTitle:Localized(@"静音") forState:UIControlStateNormal];
    
    [self.mianti1Btn setTitle:Localized(@"免提") forState:UIControlStateNormal];
    [self.mainti2Btn setTitle:Localized(@"免提") forState:UIControlStateNormal];
    
    [self.luping1Btn setTitle:Localized(@"录屏") forState:UIControlStateNormal];
    [self.luping2Btn setTitle:Localized(@"录屏") forState:UIControlStateNormal];
    if (KDSScreenHeight <= 568) {
        self.deviceSupViewBottomConstraint.constant = 30;
    }
    // 创建布局
    CYLineLayout *layout = [[CYLineLayout alloc] init];
    layout.itemSize = CGSizeMake(100, 100);
    // 创建CollectionView
    CGFloat collectionW = KDSScreenWidth-40;
    CGFloat collectionH = 100;
    CGRect frame = CGRectMake(0, 0, collectionW, collectionH);
    _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    self.topBgViewHeightConstraint.constant = TopBgViewHeightNormal;
    _collectionView.backgroundColor = UIColor.clearColor;
    [self.deviceSupView addSubview:_collectionView];
  
    // 注册
    [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([CYPhotoCell class]) bundle:nil] forCellWithReuseIdentifier:CYPhotoId];
    if ([self.gatewayDeviceModel.event_str isEqualToString:@"online"]) {
        _offlineImgView.hidden = YES;
        _collectionView.hidden = NO;
    }else{
        _offlineImgView.hidden = NO;
        _collectionView.hidden = YES;
    }

}
#pragma  mark -按钮点击事件执行
//播放按钮点击
- (IBAction)playerClick:(id)sender {
    if ([self.gatewayDeviceModel.event_str isEqualToString:@"offline"]) {
        [MBProgressHUD showError:@"猫眼不在线"];
        return;
    }else if (![LinphoneManager instance].SIPAcountLoginSuccess){
        [MBProgressHUD showError:@"视频通道繁忙，请稍后再试"];
        return;
    }
    
    [KDSFTIndicator showProgressWithMessage:Localized(@"正在连接") userInteractionEnable:NO];
    [[KDSUserManager sharedManager].cateyes enumerateObjectsUsingBlock:^(KDSCatEye * _Nonnull cateye, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([cateye.gatewayDeviceModel.deviceId isEqualToString:self.gatewayDeviceModel.deviceId]) {
            *stop = YES;
            if (*stop == YES) {
                cateye.isCalling = YES;
            }
            [[KDSUserManager sharedManager].cateyes replaceObjectAtIndex:idx withObject:cateye];
        }
    }];
    
    [[KDSMQTTManager sharedManager] cyWakeup:self.gatewayDeviceModel completion:^(NSError * _Nullable error, BOOL success) {
        [KDSFTIndicator dismissProgress];
        if (success) {
    
        }else if(error.code == KDSGatewayErrorExecuteTimeout){
            [MBProgressHUD showError:Localized(@"猫眼可能已关机")];
        }else{
            [MBProgressHUD showError:@"连接超时"];
        }
    }];
}
//横屏按钮点击
- (IBAction)lanscapeBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self forceOrientationLandscapeWith:self];
    }else{
        [self forceOrientationPortraitWith:self];
    }
}
//挂断电话按钮点击
- (IBAction)hanupClick:(id)sender {
    if (self.luping1Btn.selected || self.luping2Btn.selected) {
        [MBProgressHUD showError:@"请先终止录屏"];
        return;
    }
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [LinphoneManager.instance hangUpCall];
//    });
}
//截图按钮点击
- (IBAction)jietuBtnClick:(id)sender {
    KDSLog(@"截图按钮点击了");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self screenhotImplement:YES];
    });
}
//静音按钮点击(猫眼没声音)
- (IBAction)silenceBtnClick:(id)sender {
    KDSLog(@"静音按钮点击了");
    _silence1Btn.selected = !_silence1Btn.selected;
    _silence2Btn.selected = !_silence2Btn.selected;
    
    if (_silence1Btn.selected || _silence2Btn.selected) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [LinphoneManager.instance closeOrOnSpeak:NO];
        });
    }else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [LinphoneManager.instance closeOrOnSpeak:YES];
        });
    }
}
//免提按钮点击
- (IBAction)waifangBtnClcik:(id)sender {
    KDSLog(@"免提按钮点击了");
    _mianti1Btn.selected = !_mianti1Btn.selected;
    _mainti2Btn.selected = !_mainti2Btn.selected;
    if (_mianti1Btn.selected ||_mainti2Btn.selected) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [LinphoneManager.instance setVoiceEnabled:YES];
        });
    }else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [LinphoneManager.instance setVoiceEnabled:NO];
        });
    }
}
//录屏按钮点击
- (IBAction)recordScreenBtnClick:(id)sender {
    LinphoneCall *call = [LinphoneManager instance].currentCall;
    if (_luping1Btn.selected||_luping2Btn.selected) {
        if(!self.stopRecordEnable) {
            //5秒内不能重复点击录像
            [MBProgressHUD showError:@"录像中"];
            self.luping1Btn.userInteractionEnabled = NO;
            self.luping2Btn.userInteractionEnabled = NO;
            return;
        }
        [MBProgressHUD showSuccess:@"已保存到回看"];
        self.imgVideoNameStr = [KDSTool getNowTimeTimestamp];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *snapPath = [KDSUserManager sharedManager].currentCallRecordPath?:nil;
            [self saveSnipImageWithName:self.imgVideoNameStr filePath:snapPath isSnapClick:NO];
            linphone_call_stop_recording(call);
            [self p_setupFileRename:[KDSUserManager sharedManager].currentCallRecordPathName];
            // 开启返回手势
            if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
                self.navigationController.interactivePopGestureRecognizer.enabled = YES;
            }
        });
    }else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            linphone_call_start_recording(call);
        });
        self.stopRecordEnable = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.stopRecordEnable = YES;
            self.luping1Btn.userInteractionEnabled = YES;
            self.luping2Btn.userInteractionEnabled = YES;
        });
//        关闭侧滑返回手势
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }

    }
    _luping1Btn.selected = !_luping1Btn.selected;
    _luping2Btn.selected = !_luping2Btn.selected;
}

#pragma  mark -接受通知事件执行
//通话状态通知
- (void)callUpdateEvent:(NSNotification*)notif {
    KDSLog(@"callUpdateEvent:%@",notif);
    LinphoneCallState state = [[notif.userInfo objectForKey: @"state"] intValue];
    switch (state) {
        case LinphoneCallIncomingReceived://收到来电
        {
            [[LinphoneManager instance] sendInfoMessage];
            //sip - invite
            NSLog(@"{KAADAS}--Linphone收到呼叫--LinphoneCallIncomingReceived");
            [[KDSUserManager sharedManager].cateyes enumerateObjectsUsingBlock:^(KDSCatEye * _Nonnull cateye, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([cateye.gatewayDeviceModel.deviceId isEqualToString:self.gatewayDeviceModel.deviceId]) {
                    *stop = YES;
                    if (cateye.isCalling) {
                        [LinphoneManager.instance acceptCall: LinphoneManager.instance.currentCall evenWithVideo:YES];
                    }
                }
            }];
            break;
        }
        case LinphoneCallUpdatedByRemote:
        {
            KDSLog(@"收到视频");
            break;
        }
        case LinphoneCallOutgoingInit:{
            KDSLog(@"开始发出呼叫");
            break;
        }
        case LinphoneCallOutgoingProgress:{
            KDSLog(@"呼叫进行中");
            break;
        }
        case LinphoneCallOutgoingRinging:{
            KDSLog(@"对方收到呼叫");
            break;
        }
        case LinphoneCallConnected:{
            KDSLog(@"会话连接");
            //这个方法判断当前是否在主线程
            if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {
                // do something in main thread
                NSLog(@"当前在主线程");
                [self displayVideoToImg];
                [_collectionView reloadData];
            }
            break;
        }
        case LinphoneCallStreamsRunning:{
            KDSLog(@"流媒体建立");
            break;
        }
        case LinphoneCallError:
            KDSLog(@"会话报错");
            break;
        case LinphoneCallEnd:{
            KDSLog(@"会话结束");
            if (_callTimer) {
                [_callTimer invalidate];
                _callTimer = nil;
            }
            //此种情况为通话异常挂断的录屏保存机制
            if (_luping1Btn.selected || _luping2Btn.selected) {
                self.imgVideoNameStr = [KDSTool getNowTimeTimestamp];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self p_setupFileRename:[KDSUserManager sharedManager].currentCallRecordPathName];
                });
            }
            
            [[KDSUserManager sharedManager].cateyes enumerateObjectsUsingBlock:^(KDSCatEye * _Nonnull cateye, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([cateye.gatewayDeviceModel.deviceId isEqualToString:self.gatewayDeviceModel.deviceId]) {
                    *stop = YES;
                    if (*stop == YES) {
                        cateye.isCalling = NO;
                    }
                    [[KDSUserManager sharedManager].cateyes replaceObjectAtIndex:idx withObject:cateye];
                }
            }];
            [self forceOrientationPortraitWith:self];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case LinphoneCallReleased:{
            KDSLog(@"会话释放");
            break;
        }
        default:
            break;
    }
}
///根据锁状态自动设置开锁按钮的标题。
- (void)setUnlockBtnTitleAutomatically
{
    switch (self.lock.state)
    {
        case KDSLockStateDefence:
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:Localized(@"defenceMode")];
            break;
        case KDSLockStateLockInside:
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:Localized(@"lockInside")];
            break;
        case KDSLockStateSecurityMode:
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:Localized(@"securityMode")];
            break;
        case KDSLockStateUnlocking:
            [MBProgressHUD hideHUD];
            [KDSFTIndicator showProgressWithMessage:Localized(@"unlocking") userInteractionEnable:NO];
            break;
        case KDSLockStateUnlocked:
            [KDSFTIndicator dismissProgress];
            [MBProgressHUD showSuccess:Localized(@"unlocked")];
            break;
        case KDSLockStateClosed:
            [KDSFTIndicator dismissProgress];
//            [MBProgressHUD showSuccess:Localized(@"closeed")];
            break;
        case KDSLockStateFailed:
            [KDSFTIndicator dismissProgress];
            [MBProgressHUD showError:Localized(@"开锁失败")];
            break;
        case KDSLockStateNormal:
            [MBProgressHUD hideHUD];
            break;
        default:
            break;
    }
}
#pragma  mark 一些事件的实现
//视频展示
-(void)displayVideoToImg{
    NSLog(@"视频展示");
    self.playBtn.hidden = YES;
    self.bottomView.hidden = NO;
    self.landscapBtn.hidden = NO;
    self.callTimeLab.hidden = NO;
    self.topBgViewHeightConstraint.constant = _topBgViewHeightPlaying;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            linphone_core_set_native_video_window_id([LinphoneManager getLc],(__bridge void *)(self.videoBgImg));
        });
    });
    //设置全屏
    cx = 0.5;
    cy = 0.5;
    if (LC == nil) {
        [LinphoneManager.instance hangUpCall];
        return;
    }
    (linphone_core_get_current_call(LC), 0.75, &cx, &cy);
    _callTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(caculateCallTime) userInfo:nil repeats:YES];
}
- (void)caculateCallTime{
    int time = [[LinphoneManager instance] getCallDuration];
    KDSLog(@"time:%d",time);
    NSString *showTime = [self durationToString:time];
    _callTimeLab.text = showTime;
}
/**将int转为标准格式的NSString时间*/
- (NSString *)durationToString:(int)duration {
    NSMutableString *result = [[NSMutableString alloc] init];
    if (duration / 3600 > 0) {
        [result appendString:[NSString stringWithFormat:@"%02i:", duration / 3600]];
        duration = duration % 3600;
    }
    return [result stringByAppendingString:[NSString stringWithFormat:@"%02i:%02i", (duration / 60), (duration % 60)]];
}
//强制横屏
-(void)forceOrientationLandscapeWith:(UIViewController *)VC{
    self.navigationController.navigationBar.hidden = YES;
    self.bottmView2.hidden = NO;
    self.bottomView.hidden = YES;
    self.deviceSupView.hidden = YES;
    self.callTimeLab.hidden = YES;
    self.topBgViewHeightConstraint.constant = KDSScreenWidth;
    self.bottmView2.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.2f];
    NSLog(@"KDSScreenHeight1 = %f",KDSScreenHeight);
    AppDelegate *appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appdelegate.isForcePortrait=NO;
    appdelegate.isForceLandscape=YES;
    [appdelegate application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:VC.view.window];
    
    //强制翻转屏幕，Home键在右边。
    [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
    //刷新
    [UIViewController attemptRotationToDeviceOrientation];
}
//强制竖屏
- (void)forceOrientationPortraitWith:(UIViewController *)VC{
    self.navigationController.navigationBar.hidden = NO;
    self.topBgViewHeightConstraint.constant = _topBgViewHeightPlaying;
    self.bottmView2.hidden = YES;
    self.bottomView.hidden = NO;
    self.deviceSupView.hidden = NO;
    self.callTimeLab.hidden = NO;
    AppDelegate *appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appdelegate.isForcePortrait=YES;
    appdelegate.isForceLandscape=NO;
    [appdelegate application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:VC.view.window];
    
    //强制翻转屏幕
    [[UIDevice currentDevice] setValue:@(UIDeviceOrientationPortrait) forKey:@"orientation"];
    //刷新
    [UIViewController attemptRotationToDeviceOrientation];
}
//获取此猫眼所在网关下的网关锁
-(void)getCateyeGWLock{
    for (KDSLock *lc in [KDSUserManager sharedManager].locks) {
        if ([lc.gwDevice.gatewayId isEqualToString:self.gatewayDeviceModel.gatewayId]) {
            [self.cateyeLockArr addObject:lc];
        }
    }
}
//截屏方法
-(void)screenhotImplement:(BOOL)isSnapClick{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask, YES).firstObject;
    NSString *snapDirectory = [documentsDirectory stringByAppendingPathComponent:@"snapImage"];
    NSError *error;
    [fileManager createDirectoryAtPath:snapDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    //创建文件路径
    NSString *timeStamp = [KDSTool getNowTimeTimestamp];
    [self saveSnipImageWithName:timeStamp filePath:snapDirectory isSnapClick:YES];
}
- (void)saveSnipImageWithName:(NSString *)fileName filePath:(NSString*)filePath isSnapClick:(BOOL)isSnapClick{
    LinphoneCall *call = [LinphoneManager instance].currentCall;
    if (call == nil) {return;}
    // 创建目录:NSDocumentDirectory/snipImage
    NSString *snapFileNamePath = [NSString stringWithFormat:@"%@/%@.jpg",filePath,fileName];
    KDSLog(@"snapFileNamePath:%@",snapFileNamePath);
    //保存截图到文件路径
    int a =  linphone_call_take_video_snapshot([LinphoneManager instance].currentCall, [snapFileNamePath UTF8String]);
    KDSLog(@"截图结果:%d",a);
    if (isSnapClick) {
        KDSWeakSelf(self)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIImage *resultImage =[UIImage imageWithContentsOfFile:snapFileNamePath];
            KDSLog(@"resultImage:%@",resultImage);
            if (resultImage) {
                ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
                if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied){
                    KDSLog(@"没有权限访问相册");
                }else {
                    [weakself loadImageFinished:resultImage];
                }
            }
        });
    }
}
- (void)loadImageFinished:(UIImage *)image{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    KDSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
    if (!error) {
        [MBProgressHUD showSuccess:Localized(@"已保存到系统相册")];
    }
}
//修改文件名称
- (NSString *)p_setupFileRename:(NSString *)filePath {
    NSString *lastPathComponent = [NSString new];
    //获取文件名： 视频.MP4
    lastPathComponent = [filePath lastPathComponent];
    //获取后缀：mkv
    NSString *pathExtension = [filePath pathExtension];
    //用传过来的路径创建新路径 首先去除文件名
    NSString *pathNew = [filePath stringByReplacingOccurrencesOfString:lastPathComponent withString:@""];
    //然后拼接新文件名：新文件名为当前的：年月日时分秒 yyyyMMddHHmmss
    NSString *moveToPath = [NSString stringWithFormat:@"%@%@.mkv",pathNew,self.imgVideoNameStr];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //通过移动该文件对文件重命名
    BOOL isSuccess = [fileManager moveItemAtPath:filePath toPath:moveToPath error:nil];
    if (isSuccess) {
        NSLog(@"rename success");
    }else{
        NSLog(@"rename fail");
    }
    return moveToPath;
}
#pragma  mark - UICollectionViewDelegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.cateyeLockArr.count == 0) {
        return 1;
    }else{
         return self.cateyeLockArr.count;
    }
    
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return  CGSizeMake(90, 100);
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CYPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CYPhotoId forIndexPath:indexPath];
    [cell.lockImg setImage:[UIImage imageNamed:@"开锁 不在线"] forState:UIControlStateNormal];
    if (self.cateyeLockArr.count == 0) {
        cell.LockNameLab.text = Localized(@"暂无联动门锁");
    }else{
        KDSLock *lc = self.cateyeLockArr[indexPath.row];
        cell.LockNameLab.text = lc.gwDevice.nickName? :lc.gwDevice.deviceId ;
        if ([LinphoneManager instance].currentCall) {
            if ([lc.gwDevice.event_str isEqualToString:@"online"]) {
                NSLog(@"当前锁在线%@",lc.gwDevice.deviceId);
                [cell.lockImg setImage:[UIImage imageNamed:@"开锁 在线 拷贝 3"] forState:UIControlStateNormal];
            }else{
                [cell.lockImg setImage:[UIImage imageNamed:@"开锁 不在线"] forState:UIControlStateNormal];
                NSLog(@"当前锁不在线%@",lc.gwDevice.deviceId);
            }
        }
    }
    if (cell.frame.size.width > 80) {
        cell.userInteractionEnabled = YES;
    }else{
        cell.userInteractionEnabled = NO;
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.lock removeObserver:self forKeyPath:@"state" context:nil];
    if (_cateyeLockArr.count == 0) {
        return;
    }

    
    self.lock = _cateyeLockArr[indexPath.row];
    [self.lock addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
//    [[self.lock rac_valuesAndChangesForKeyPath:@"state" options:NSKeyValueObservingOptionNew observer:self] subscribeNext:^(RACTwoTuple<id,NSDictionary *> * _Nullable x) {
//        [self setUnlockBtnTitleAutomatically];
//        [self.lock rac_deallocDisposable];
//    }];
//    [self.lock rac_observeKeyPath:@"state" options:NSKeyValueObservingOptionNew observer:nil block:^(id value, NSDictionary *change, BOOL causedByDealloc, BOOL affectedOnlyLastComponent) {
//
//    }];
//    [[self.lock rac_valuesForKeyPath:@"state" observer:nil] subscribeNext:^(id  _Nullable x) {
//        [self setUnlockBtnTitleAutomatically];
//    }];
    
    if(![LinphoneManager instance].currentCall){
        [MBProgressHUD showError:@"必须猫眼呼叫通才可以开锁"];
        return;
    }else if ((self.lock.state == KDSLockStateUnlocked)){
        [MBProgressHUD showError:@"正在开锁"];
        return;
    }else if ((self.lock.state == KDSLockStateOffline)){
        [MBProgressHUD showError:@"设备不在线"];
        return;
    }
//    else if (self.lock.state == KDSLockStateDefence){
//        [MBProgressHUD showError:@"布防状态，不支持开锁"];
//        return;
//    }
    [[NSNotificationCenter defaultCenter] postNotificationName:KDSUserUnlockNotification object:nil userInfo:@{@"lock" : self.lock}];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self.collectionView reloadData];
}

- (void)localeLanguageDidChange:(NSNotification *)noti
{
    
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"state"] && object == self.lock)
    {
        [self setUnlockBtnTitleAutomatically];
    }
}
#pragma arguments  ---- 懒加载 ----
- (NSMutableArray *)cateyeLockArr
{
    if (_cateyeLockArr == nil)
    {
        _cateyeLockArr = [NSMutableArray array];
    }
    return _cateyeLockArr;
}
- (void)dealloc
{
    KDSLog(@"执行了dealloc------KDSCateyeCallVC");
    [self.lock removeObserver:self forKeyPath:@"state" context:nil];
}

@end
