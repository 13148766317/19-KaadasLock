//
//  XMPlayController.m
//  XMDemo
//
//  Created by TixXie on 2020/8/31.
//  Copyright © 2020 xmitech. All rights reserved.
//

#import "XMPlayController.h"
#import "XmMovieViewController.h"
#import <XMStreamComCtrl/XMStreamComCtrl.h>
#import "XMPlayBarView.h"
#import "XMUtil.h"
#import "XMRecordFileListItem.h"
#import "KDSMyAlbumVC.h"
#import "UIBarButtonItem+DyBtnItem.h"
#import "KDSRealTimeVideoSettingsVC.h"
#import "KDSAllPhotoShowImgModel.h"
#import "KDSDBManager+XMMediaLock.h"
#import <Photos/Photos.h>
#import <MessageUI/MessageUI.h>
#import "MBProgressHUD+MJ.h"
#import "UIView+Extension.h"
#import "NSString+extension.h"
#import "KDSBleAssistant.h"
#import "KDSTabBarController.h"
#import "AppDelegate.h"
#import "KDSAlertView.h"

@interface XMPlayController () <StreamDelegate, DecoderDelegate, XMPlayBarViewDelegate, UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate>
/// 音视频流的管理
@property (nonatomic, strong) XMStreamComCtrl *streamManager;
/// 解码并播放的控制器
@property (nonatomic, strong) XmMovieViewController *movieViewController;
/// 菊花loading
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UILabel * tipsLb;
/// 播放控制条
@property (nonatomic, strong) XMPlayBarView *playBar;
/// 初始化音视频流的标记
@property (nonatomic, assign, getter=isInitStream) BOOL initStream;
/// 当前页面显示的标记
@property (nonatomic, assign, getter=isViewActivated) BOOL viewActivated;
/// 视频已经显示的标记
@property (nonatomic, assign, getter=isVideoLoaded) BOOL videoLoaded;
/// 第一帧的标记
@property (nonatomic, assign, getter=isFirstFrame) BOOL firstFrame;
/// 断开重连的标记
@property (nonatomic, assign, getter=isCanReconnect) BOOL canReconnect;
/// 音频开启的标记
@property (nonatomic, assign, getter=isVoiceOn) BOOL voiceOn;
/// 对讲开启的标记
@property (nonatomic, assign, getter=isTalkOn) BOOL talkOn;
/// 对音视频正在录像中的标记
@property (nonatomic, assign, getter=isRecording) BOOL recording;
/// 重连的连接次数
@property (nonatomic, assign) NSInteger connectCount;
/// 视频播放movieViewController的view的frame
@property (nonatomic, assign) CGRect liveViewFrame;
/// 视频帧率
@property (nonatomic, assign) int videoFrameRate;
/// 视频分辨率
@property (nonatomic, assign) CGSize videoResSize;
/// 保存的视频文件路径
@property (nonatomic, copy) NSString *filePath;
/// 显示录像文件列表
@property (nonatomic, strong) UITableView *tableView;
/// 录像文件模型
@property (nonatomic, strong) XMRecordFileListItem *fileListItem;
/// 播放文件PlayDeviceRecordVideo回调产生的Token，可以用来控制这个录像，目前暂不支持RECORD_CTRL_PAUSE这个暂停操作。
@property (nonatomic, assign) NSInteger playRecordToken;
/// 选中的行
@property (nonatomic, assign) NSInteger selectedIndex;
/// 检查回放流解码完成的定时器，可以参考这里做自动播放下一个文件。
@property (nonatomic, strong) NSTimer *timer;
/// 解码时的时间
@property (nonatomic, assign) NSTimeInterval decodeTimestamp;
///视频接通之前弹出的提示视图
@property (nonatomic, strong) UIView * tipsView;
///显示离线密码的父视图
@property (nonatomic, strong) UIView * pwdLbSupView;
///定时，30秒超时
@property (nonatomic,strong)NSTimer * changeTimer;
///上个导航控制器的代理。
@property (nonatomic, weak) id<UINavigationControllerDelegate> preDelegate;
///录屏时闪烁提示
@property (nonatomic,strong)UIView * recView;
///秒表计时器
@property (nonatomic, strong)NSTimer * myTimer;
///初始秒数
@property (nonatomic, assign)int seconds;
///展示秒数的lb
@property (nonatomic, strong)UILabel * timerLabel;
///提示语REC
@property (nonatomic, strong)UILabel * rcrlb;
///视频时间：OSD
@property (nonatomic, strong)UILabel * currentTimeLb;
///接听按钮
@property (nonatomic, strong)UIButton *answerbutton;
///取消按钮
@property (nonatomic, strong)UIButton *cancelbutton;
///当前页面离开时保留的最后一帧的图片
@property (nonatomic, strong)UIImage * temporaryDocumentsImg;
///展示页面离开时的最后一帧图的视图
@property (nonatomic, strong)UIImageView * tempImg;
@property (nonatomic, strong)MBProgressHUD *hud;

@end

@implementation XMPlayController

- (instancetype)initWithType:(XMPlayType)type {
    if (self = [super init]) {
        _type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.seconds = 0;
    [self setupUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wifiUnlockChangeNotification:) name:KDSMQTTEventNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.preDelegate = self.navigationController.delegate;
    self.navigationController.delegate = self;
    if (self.temporaryDocumentsImg) {
        [self createSubviews];
        self.viewActivated = true;
        [self connectDevice];
        self.hud = [MBProgressHUD showMessage:@"视频连接中，请稍后" toView:self.view];
    }else{
        [self showCallPage];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    CGFloat height = KDSScreenHeight-87-kBottomSafeHeight;  //SIZE_SCREEN_WIDTH * 9 / 16;
    _liveViewFrame = CGRectMake(0, 0, SIZE_SCREEN_WIDTH, KDSScreenHeight);
    
    CGFloat Y = CGRectGetMaxY(self.liveViewFrame);
    self.playBar.frame= CGRectMake(0, height, SIZE_SCREEN_WIDTH, 87+kBottomSafeHeight);
    self.playBar.backgroundColor =[UIColor colorWithRed:35/255.0 green:35/255.0 blue:35/255.0 alpha:0.9];
    if (self.type == XMPlayTypeReplay) {
        Y = CGRectGetMaxY(self.playBar.frame);
        height = SIZE_SCREEN_HEIGHT - Y;
        self.tableView.frame = CGRectMake(0, Y, SIZE_SCREEN_WIDTH, height);
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.viewActivated = false;
    self.navigationController.delegate = self.preDelegate;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self releaseLive];
}

- (void)prepare {
    _voiceOn = true;
    // 默认帧率
    _videoFrameRate = 15;
    _playRecordToken = 0;
}
 
- (void)setupUI {
    if (@available(iOS 13.0, *)) {
        UIUserInterfaceStyle mode = UITraitCollection.currentTraitCollection.userInterfaceStyle;
        if (mode == UIUserInterfaceStyleDark) {
            self.view.backgroundColor = [UIColor blackColor];
        } else if (mode == UIUserInterfaceStyleLight) {
            self.view.backgroundColor = [UIColor whiteColor];
        }
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
    }
}

- (void)showCallPage
{
    self.tipsView = [UIView new];
    self.tipsView.backgroundColor = KDSRGBColor(147, 145, 139);
    [self.view addSubview:self.tipsView];
    [self.tipsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(self.view);
    }];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"whiteBack"] forState:UIControlStateNormal];
    backBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    backBtn.frame = CGRectMake(0, kStatusBarHeight, 44, 44);
    [backBtn addTarget:self action:@selector(backBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    ///锁型号对应的图片
    [KDSAllPhotoShowImgModel shareModel].device = self.lock.wifiDevice;
    UIImageView * devIconImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lock_pic"]];
    for (NSString * imgName in [[KDSAllPhotoShowImgModel shareModel].adminImgName allKeys]) {
        if ([imgName isEqualToString:self.lock.wifiDevice.productModel]) {
            if ([[[KDSAllPhotoShowImgModel shareModel].adminImgName objectForKey:self.lock.wifiDevice.productModel] hasPrefix:@"http://"]) {
                NSLog(@"设备列表图片下载地址：%@",[KDSAllPhotoShowImgModel shareModel].adminImgName);
                [[KDSAllPhotoShowImgModel shareModel] getDeviceImgWithImgName:[[KDSAllPhotoShowImgModel shareModel].adminImgName objectForKey:self.lock.wifiDevice.productModel] completion:^(UIImage * _Nullable image) {
                    if (image) {
                        devIconImgView.image = image;
                    }
                }];
            }else{
                devIconImgView.image = [UIImage imageNamed:[[KDSAllPhotoShowImgModel shareModel].adminImgName objectForKey:self.lock.wifiDevice.productModel]];
            }
        }
    }
    
    [self.tipsView addSubview:devIconImgView];
    [devIconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(KDSScreenHeight <= 667 ? @100: @150);
        make.top.equalTo(self.tipsView.mas_top).offset(KDSScreenHeight <= 667 ? 50 : kNavBarHeight + kStatusBarHeight + 30);
        make.centerX.equalTo(self.tipsView.mas_centerX);
    }];
    
    UILabel * devNickNameLb = [UILabel new];
    devNickNameLb.text = self.lock.wifiDevice.lockNickname ?: self.lock.wifiDevice.wifiSN;
    devNickNameLb.font = [UIFont systemFontOfSize:15];
    devNickNameLb.textColor = UIColor.whiteColor;
    devNickNameLb.textAlignment = NSTextAlignmentLeft;
    devNickNameLb.numberOfLines = 0;
    [self.tipsView addSubview:devNickNameLb];
    [devNickNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(devIconImgView.mas_bottom).offset(0);
        make.height.equalTo(@20);
        make.centerX.equalTo(self.tipsView.mas_centerX);
    }];
    self.tipsLb = [UILabel new];
    self.tipsLb.text = @"视频连接中，请稍后";
    self.tipsLb.font = [UIFont systemFontOfSize:12];
    self.tipsLb.textColor = UIColor.whiteColor;
    self.tipsLb.hidden = YES;
    self.tipsLb.textAlignment = NSTextAlignmentCenter;
    [self.tipsView addSubview:self.tipsLb];
    [self.tipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.tipsView.mas_centerX);
        make.centerY.equalTo(self.tipsView.mas_centerY).offset(KDSScreenHeight <= 667 ? 30 : 10);
        make.height.equalTo(@20);
    }];
    
    [self.tipsView addSubview:self.indicatorView];
    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(20, 20));
        make.centerX.equalTo(self.tipsView.mas_centerX);
        make.bottom.equalTo(self.tipsLb.mas_top).offset(-15);
    }];
    
    if (!self.isActive) {
        
        self.tipsLb.text = @"有人按门铃啦~";
        self.tipsLb.hidden = NO;
        self.cancelbutton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.cancelbutton.backgroundColor = UIColor.clearColor;
        [self.cancelbutton setImage:[UIImage imageNamed:@"Refuse_icon"] forState:UIControlStateNormal];
        [self.cancelbutton setTitle:@"取消" forState:UIControlStateNormal];
        self.cancelbutton.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.cancelbutton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [self.tipsView addSubview:self.cancelbutton];
        [self.cancelbutton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@70);
            make.height.equalTo(@110);
            make.bottom.equalTo(self.tipsView.mas_bottom).offset(-(kBottomSafeHeight + 60));
            make.left.equalTo(self.tipsView.mas_left).offset((KDSScreenWidth - 140)/3);
        }];
        CGFloat    space = 30;// 图片和文字的间距
        CGFloat    imageHeight = self.cancelbutton.currentImage.size.height;
        CGFloat    imageWidth = self.cancelbutton.currentImage.size.width;
        CGFloat    titleHeight = [self.cancelbutton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].height;
        CGFloat    titleWidth = [self.cancelbutton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width;
        [self.cancelbutton setImageEdgeInsets:UIEdgeInsetsMake(-(imageHeight*0.25 + space*0.25), titleWidth*0.25, imageHeight*0.25 + space*0.25, -titleWidth*0.25)];
        
        //文字
        [self.cancelbutton setTitleEdgeInsets:UIEdgeInsetsMake(titleHeight + space*1.5, -imageWidth*0.75, -(titleHeight*0.25 + space*0.25), imageWidth*0.25)];
        
        [self.cancelbutton addTarget:self action:@selector(cancelbuttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        self.answerbutton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.answerbutton.backgroundColor = UIColor.clearColor;
        [self.answerbutton setImage:[UIImage imageNamed:@"Answer_icon"] forState:UIControlStateNormal];
        [self.answerbutton setTitle:@"接听" forState:UIControlStateNormal];
        self.answerbutton.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.answerbutton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [self.tipsView addSubview:self.answerbutton];
        [self.answerbutton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@70);
            make.height.equalTo(@110);
            make.bottom.equalTo(self.tipsView.mas_bottom).offset(-(kBottomSafeHeight + 60));
            make.right.equalTo(self.tipsView.mas_right).offset(-(KDSScreenWidth - 140)/3);
        }];
        CGFloat    imageHeight1 = self.answerbutton.currentImage.size.height;
        CGFloat    imageWidth1 = self.answerbutton.currentImage.size.width;
        CGFloat    titleHeight1 = [self.answerbutton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].height;
        CGFloat    titleWidth1 = [self.answerbutton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width;
        [self.answerbutton setImageEdgeInsets:UIEdgeInsetsMake(-(imageHeight1*0.25 + space*0.25), titleWidth1*0.25, imageHeight1*0.25 + space*0.25, -titleWidth1*0.25)];
        //文字
        [self.answerbutton setTitleEdgeInsets:UIEdgeInsetsMake(titleHeight1 + space*1.5, -imageWidth1*0.75, -(titleHeight1*0.25 + space*0.25), imageWidth1*0.25)];
        
        [self.answerbutton addTarget:self action:@selector(answerbuttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        self.viewActivated = true;
        [self connectDevice];
        self.changeTimer = [NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(callOutTime:) userInfo:nil repeats:YES];
    }
}

- (void)addOfflinePwdSupView
{
    UIView * navView = [UIView new];
    navView.backgroundColor = UIColor.clearColor;// [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.2];
    [self.movieViewController.view addSubview:navView];
    [navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.movieViewController.view);
        make.height.equalTo(@(kNavBarHeight+kStatusBarHeight+15));
    }];
    //返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"xmPlay-icon_back"] forState:UIControlStateNormal];
    backBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    backBtn.frame = CGRectMake(0, kStatusBarHeight, 44, 44);
    [backBtn addTarget:self action:@selector(backBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:backBtn];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.textColor = UIColor.whiteColor;
    titleLabel.text = @"实时视频";
    titleLabel.hidden = YES;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [navView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kStatusBarHeight + 11);
        make.centerX.equalTo(self.view);
        make.left.mas_equalTo(self.movieViewController.view.mas_left).offset(44);
        make.right.mas_equalTo(self.movieViewController.view.mas_right).offset(-44);
    }];
    
    //设置按钮
    UIButton *settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingBtn setImage:[UIImage imageNamed:@"xmPlay-icon_setting"] forState:UIControlStateNormal];
    settingBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    settingBtn.frame = CGRectMake(KDSScreenWidth-44, kStatusBarHeight, 44, 44);
    [settingBtn addTarget:self action:@selector(rightitemClick:) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:settingBtn];
    
    self.currentTimeLb = [UILabel new];
    self.currentTimeLb.font = [UIFont systemFontOfSize:12];
    self.currentTimeLb.textColor = UIColor.whiteColor;
    self.currentTimeLb.hidden = YES;
    self.currentTimeLb.textAlignment = NSTextAlignmentCenter;
    [navView addSubview:self.currentTimeLb];
    [self.currentTimeLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(navView);
        make.height.equalTo(@15);
        make.bottom.equalTo(navView.mas_bottom).offset(-10);
    }];
    
    self.recView = [UIView new];
    self.recView.backgroundColor = [UIColor redColor];
    self.recView.layer.cornerRadius = 5;
    self.recView.layer.masksToBounds = YES;
    self.recView.hidden = YES;
    [self.movieViewController.view addSubview:self.recView];
    [self.recView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@10);
        make.left.mas_equalTo(self.movieViewController.view.mas_left).offset(23);
        make.top.mas_equalTo(navView.mas_bottom).offset(19);
    }];
    self.rcrlb = [UILabel new];
    self.rcrlb.text = @"REC";
    self.rcrlb.hidden = YES;
    self.rcrlb.font = [UIFont systemFontOfSize:17];
    self.rcrlb.textColor = UIColor.whiteColor;
    self.rcrlb.textAlignment = NSTextAlignmentLeft;
    [self.movieViewController.view addSubview:self.rcrlb];
    [self.rcrlb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@50);
        make.height.equalTo(@20);
        make.top.mas_equalTo(navView.mas_bottom).offset(15);
        make.left.mas_equalTo(self.recView.mas_right).offset(8);
    }];
    
    self.timerLabel = [UILabel new];
    self.timerLabel.font = [UIFont systemFontOfSize:17];
    self.timerLabel.textColor = UIColor.whiteColor;
    self.timerLabel.textAlignment = NSTextAlignmentCenter;
    self.timerLabel.text = @"00:00:00";
    self.timerLabel.hidden = YES;
    [self.movieViewController.view addSubview:self.timerLabel];
    [self.timerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@200);
        make.height.equalTo(@20);
        make.top.mas_equalTo(navView.mas_bottom).offset(15);
        make.centerX.equalTo(self.movieViewController.view.mas_centerX);
    }];
    
    //呼叫成功之后的离线密码相关的UI
    UIView * offlinePwdSupView = [UIView new];
    offlinePwdSupView.backgroundColor = UIColor.clearColor;
    [self.movieViewController.view addSubview:offlinePwdSupView];
    [offlinePwdSupView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.movieViewController.view);
        make.bottom.mas_equalTo(self.movieViewController.view.mas_bottom).offset(-87-kBottomSafeHeight-40);
        make.height.equalTo(@80);
    }];
    
    UIButton *offlineBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [offlineBtn setImage:[UIImage imageNamed:@"offlinePwd-call"] forState:UIControlStateNormal];
    [offlineBtn setImage:[UIImage imageNamed:@"offlinePwd-callSelect"] forState:UIControlStateSelected];
    [offlinePwdSupView addSubview:offlineBtn];
    [offlineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@50);
        make.top.equalTo(offlinePwdSupView);
        make.right.equalTo(offlinePwdSupView.mas_right).offset(-20);
    }];
    [offlineBtn addTarget:self action:@selector(offlineBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel * offlinePwdTipsLb = [UILabel new];
    offlinePwdTipsLb.text = @"临时密码";
    offlinePwdTipsLb.textColor = UIColor.whiteColor;
    offlinePwdTipsLb.font = [UIFont systemFontOfSize:15];
    offlinePwdTipsLb.textAlignment = NSTextAlignmentCenter;
    [offlinePwdSupView addSubview:offlinePwdTipsLb];
    [offlinePwdTipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(offlineBtn.mas_bottom).offset(5);
        make.right.equalTo(offlinePwdSupView);
        make.width.equalTo(@90);
        make.height.equalTo(@20);
    }];

    self.pwdLbSupView = [UIView new];
    self.pwdLbSupView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.66];
    self.pwdLbSupView.hidden = YES;
    [offlinePwdSupView addSubview:self.pwdLbSupView];
    [self.pwdLbSupView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(offlinePwdSupView);
        make.height.equalTo(@50);
        make.width.equalTo(@260);
    }];
    
    CGFloat radius = 24; // 圆角大小
    UIRectCorner corner = UIRectCornerTopRight | UIRectCornerBottomRight; // 圆角位置
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 260, 50) byRoundingCorners:corner cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.pwdLbSupView.bounds;
    maskLayer.path = path.CGPath;
    self.pwdLbSupView.layer.mask = maskLayer;
    
    UILabel * tipsPwdLb = [UILabel new];
    tipsPwdLb.text = @"注：远程临时密码30分钟有效";
    tipsPwdLb.font = [UIFont systemFontOfSize:12];
    tipsPwdLb.textColor = KDSRGBColor(80, 80, 80);
    tipsPwdLb.textAlignment = NSTextAlignmentCenter;
    [self.pwdLbSupView addSubview:tipsPwdLb];
    [tipsPwdLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.pwdLbSupView);
        make.height.equalTo(@20);
    }];
    
    NSString * offlinePwd = [self getOfflinePwd];
    NSMutableString *ms = [NSMutableString stringWithCapacity:offlinePwd.length * 2 - 2];
    for (int i = 0; i < offlinePwd.length; ++i)
    {
        [ms appendFormat:@"%c%@", offlinePwd.UTF8String[i], i==offlinePwd.length-1 ? @"" : @"   "];
    }
    UILabel * displayPwdLb = [UILabel new];
    displayPwdLb.text = ms;
    displayPwdLb.font = [UIFont systemFontOfSize:20];
    displayPwdLb.textColor = KDSRGBColor(51, 51, 51);
    displayPwdLb.textAlignment = NSTextAlignmentCenter;
    [self.pwdLbSupView addSubview:displayPwdLb];
    [displayPwdLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.pwdLbSupView);
        make.height.equalTo(@30);
    }];
}

#pragma mark - action
/// 录像，打包成MP4
- (void)record {
    if (!self.isViewActivated || !self.movieViewController || ![XMUtil requestAuthorization:KSystemPermissionsTypeAlbum]) {
        return;
    }
    if (self.isRecording) {
        [self.movieViewController StopRecordToMP4];
//        [XMUtil saveVideoToPhotosAlbum:self.filePath];
        [self saveVideoToCustomPhotosAlbum:self.filePath];
        // 建议统一做缓存管理，定期删除 filePath 目录下的缓存
        self.filePath = nil;
        self.recView.hidden = YES;
        self.rcrlb.hidden = YES;
        self.timerLabel.hidden = YES;
        self.seconds = 0;
        self.timerLabel.text = @"00:00:00";
        [self.recView.layer addAnimation:[self opacityForever_Animation:0.5] forKey:nil];
        [self.myTimer invalidate];
        self.myTimer = nil;
    } else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *fileName = [formatter stringFromDate:[NSDate date]];
        self.filePath = [[NSString alloc] initWithFormat:@"%@/%@.mp4", [XMUtil cachesPathWithWifiSN:self.lock.wifiDevice.wifiSN], fileName];
        if(self.videoFrameRate == 0) self.videoFrameRate = 15;
        [self.movieViewController StarRecordToMP4:self.filePath Framewidth:(int)self.videoResSize.width FrameHeight:(int)self.videoResSize.height FrameRate:self.videoFrameRate];
        [self.movieViewController SetRecDisplayText:@""];
        dispatch_async(dispatch_get_main_queue(), ^{
            KDSAlertView *alertView = [KDSAlertView alertControllerWithTitle:@"已开启录屏"];
            [self.movieViewController.view addSubview:alertView];
            [alertView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@165);
                make.height.equalTo(@41);
                make.centerY.centerX.equalTo(self.movieViewController.view);
            }];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [alertView removeFromSuperview];
            });
        });
        self.recView.hidden = NO;
        self.rcrlb.hidden = NO;
        self.timerLabel.hidden = NO;
        [self.recView.layer addAnimation:[self opacityForever_Animation:0.5] forKey:nil];
        self.myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startClick:) userInfo:nil repeats:YES];
    }
    self.recording = !self.isRecording;
    if (self.isRecording) {
        [self.playBar setPlayBarViewButtonType:XMPlayBarViewButtonTypeRecord state:XMPlayBarViewButtonStateSelected];
    } else {
        [self.playBar setPlayBarViewButtonType:XMPlayBarViewButtonTypeRecord state:XMPlayBarViewButtonStateNormal];
    }
}

/// 语音对讲
- (void)talk {
    if (self.isTalkOn) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (self.movieViewController) {
                [self.movieViewController Talkback:false];
            }
            [self.streamManager StopTalkback];
        });
    } else {
        if (![XMUtil requestAuthorization:KSystemPermissionsTypeMicrophone]) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            KDSAlertView *alertView = [KDSAlertView alertControllerWithTitle:@"已开启对讲"];
            [self.movieViewController.view addSubview:alertView];
            [alertView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@165);
                make.height.equalTo(@41);
                make.centerY.centerX.equalTo(self.movieViewController.view);
            }];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [alertView removeFromSuperview];
            });
        });
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.streamManager StartTalkback];
        });
    }
}

/// 静音
- (void)mute {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (!self.isVoiceOn) {
            [self.movieViewController enableAudio:true];
            [self.movieViewController ResetAudioBuffer];
            [self.streamManager StartAudioStream];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                KDSAlertView *alertView = [KDSAlertView alertControllerWithTitle:@"已开启静音"];
                [self.movieViewController.view addSubview:alertView];
                [alertView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(@165);
                    make.height.equalTo(@41);
                    make.centerY.centerX.equalTo(self.movieViewController.view);
                }];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [alertView removeFromSuperview];
                });
            });
            [self.movieViewController enableAudio:false];
            [self.streamManager StopAudioStream];
        }
    });
}

/// 截屏
- (void)cut {
    if (!self.isVideoLoaded || ![XMUtil requestAuthorization:KSystemPermissionsTypeAlbum]) return;
    if (self.movieViewController) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *fileName = [formatter stringFromDate:[NSDate date]];
        // 建议统一做缓存管理，定期删除 filePath 目录下的缓存
        NSString *filePath = [[NSString alloc] initWithFormat:@"%@/%@.png", [XMUtil cachesPathWithWifiSN:self.lock.wifiDevice.wifiSN], fileName];
        bool success = [self.movieViewController SnapImageFile:filePath];
        if (success) {
            
            UIImage *image = [UIImage imageWithContentsOfFile:filePath];
            UIImageOrientation orientation = UIImageOrientationUp;
            switch (self.movieViewController.direction) {
                case XMMovieDirectionRight: {
                    orientation = UIImageOrientationRight;
                }
                    break;
                    
                case XMMovieDirectionLeft: {
                    orientation = UIImageOrientationLeft;
                }
                    break;
                case XMMovieDirectionDown: {
                    orientation = UIImageOrientationDown;
                }
                    break;
                default:
                    break;
            }
            // 旋转图片
            image = [[UIImage alloc] initWithCGImage:image.CGImage scale:1.0 orientation:orientation];
            if (image) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    [XMUtil saveImageToPhotosAlbum:image];
                    [self saveImage:image];
                });
            }
        }
    }
}

#pragma mark - connect
/// 通过p2p连接到设备
- (void)connectDevice {
    //无网络的时候不主动尝试连接
    //*******暂时先写死***后面要用服务器的值**************//
//    self.lock.wifiDevice.keep_alive_status = 1;
    if (![KDSUserManager sharedManager].netWorkIsAvailable) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.indicatorView stopAnimating];
            [self.hud hideAnimated:YES];
            NSString *message = [NSString stringWithFormat:@"手机未开启网络，请打开网络再试"];
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (self.navigationController.viewControllers.count <= 1) {
                    AppDelegate *appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
                    KDSTabBarController *tab = [KDSTabBarController new];
                    appdelegate.window.rootViewController = tab;
                }else{
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
            [retryAction setValue:KDSRGBColor(32, 150, 248) forKey:@"titleTextColor"];
            [controller addAction:retryAction];
            [self presentViewController:controller animated:true completion:nil];
        });
        return;
    }if (self.lock.wifiDevice.keep_alive_status == 0 && self.isActive) {
        ///视频长连接已关闭
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.indicatorView stopAnimating];
            [self.hud hideAnimated:YES];
            NSString *message = [NSString stringWithFormat:@"按门铃时可查看门外情况\n唤醒门锁后，可在视频设置中开启"];
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"视频长连接已关闭" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (self.navigationController.viewControllers.count <= 1) {
                    AppDelegate *appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
                    KDSTabBarController *tab = [KDSTabBarController new];
                    appdelegate.window.rootViewController = tab;
                }else{
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
            
            //修改message
            NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:@"按门铃时可查看门外情况\n唤醒门锁后，可在视频设置中开启"];
            [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:KDSRGBColor(153, 153, 153) range:NSMakeRange(12, 15)];
            [alertControllerMessageStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(12, 15)];
            [alertControllerMessageStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, 12)];
            [controller setValue:alertControllerMessageStr forKey:@"attributedMessage"];
            
            [retryAction setValue:KDSRGBColor(32, 150, 248) forKey:@"titleTextColor"];
            [controller addAction:retryAction];
            [self presentViewController:controller animated:true completion:nil];
        });
        return;
    }
    self.firstFrame  = false;
    self.videoLoaded = false;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.indicatorView startAnimating];
        self.tipsLb.hidden = NO;
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self initXMStreamComCtrl];
        /// 以下连接信息正式环境将由讯美提供，现在以下均是测试数据。
        XMConnectParameter parameter;
        // 设备的did
        parameter.did = self.lock.wifiDevice.device_did;//@"AYIOTCN-000337-FDFTF";
        // 摄像机的sn
        parameter.sn = self.lock.wifiDevice.device_sn;//@"010000000020500020";
        // 设备的通道号
        parameter.channel = 0;
        // 唯一的用户名
        parameter.usr_id = @"xmitceh_ios";
        // 登录的字符串
        parameter.serverString = AERVICE_STRING;
        // 登录的用户名，目前是设备的sn。
        // 注意：这里的SN与上面的parameter.sn如果是基站版会则会不一样，这里是设备SN：字段：device_sn，上面的是摄像机SN，字段：camera_sn。目前是单机版则SN是一样的，需要注意区别。
        parameter.userName = self.lock.wifiDevice.device_sn;//@"010000000020500020";
        // 登录的密码
        parameter.userPassword = self.lock.wifiDevice.p2p_password;// @"ut4D0mvz";
        WeakSelf
        [self.streamManager StartConnectWithMode:XMStreamConnectModeWAN connectParam:parameter completeBlock:^(XMStreamComCtrl *steamComCtrl, NSInteger resultCode) {
            if (resultCode > 0) {
                weakSelf.canReconnect = true;
                if (!weakSelf.isViewActivated) {
                    [steamComCtrl StopConnectDevice];
                } else {
                    if (weakSelf.type == XMPlayTypeLive) {
                        [weakSelf startVideoStream];
                        [KDSUserManager sharedManager].doorbellProgress = YES;
                    }
                }
            } else {// 可以在这里处理错误或者重试逻辑
                [self handleDisConnectedDeviceAndReconnect:resultCode];
            }
        }];
    });
}

/// 开启视频流
- (void)startVideoStream {
    if (!self.isViewActivated) {
        return;
    }
    NSInteger ret = [self.streamManager StartVideoStream:REAL_STREAM_MOD];
    if (ret == -99) { // 上一次正在退出，重连。
        [self connectDevice];
    }
}

/// 搜索某个日期的录像文件
/// @param date 录像的日期 yyyyMMdd
- (void)searchRecordFileListWithDateString:(NSString *)date {
    if (!date || date.length == 0) {
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"yyyyMMdd";
        date = [formatter stringFromDate:[NSDate date]];
    }
    // 目前这里只搜索当天录像文件，也可以根据需求先用SearchRecordDateList搜索卡里面所有有录像的日期列表，然后再根据日期列表查找期中某个日期的录像文件列表
    [self.streamManager SearchRecordFileList:xMP2P_RECORD_SEARCH_TYPE_ALL TimeStr:date Channel:0];
}

/// 播放T卡录像文件
/// @param item XMRecordFileItem
- (void)playDeviceRecordVideo:(XMRecordFileItem *)item {
//    [self.indicatorView startAnimating];
    if (self.playRecordToken > 0) {
        [self.streamManager PlayRecViewCtrl:self.playRecordToken CmdId:RECORD_CTRL_STOP];
        self.playRecordToken = 0;
    }
    NSInteger ret = [self.streamManager PlayDeviceRecordVideo:item.file DateStr:self.fileListItem.date RecordType:xMP2P_RECORD_PLAY_TYPE_NORMA];
    // ret 是p2p的发送结果，其他命令也一样。注意：这里只是下发结果，不是设备是否收到的结果，收到结果在代理的回调中。0代表下发成功。
    NSLog(@"PlayDeviceRecordVideo == %ld", (long)ret);
}

/// p2p连接失败处理
/// @param Ret 失败的错误码
- (void)handleDisConnectedDeviceAndReconnect:(NSInteger)Ret {
    if (Ret == ERROR_PPCS_USER_CONNECT_BREAK) {// 主动断开
        return;
    }
    if ((self.connectCount < 10) && (Ret == ERROR_PPCS_TIME_OUT || Ret == ERROR_PPCS_SESSION_CLOSED_REMOTE || Ret == ERROR_PPCS_SESSION_CLOSED_TIMEOUT || Ret == ERROR_PPCS_INVALID_SESSION_HANDLE)) {
        self.connectCount++;
        [self connectDevice];
    } else {
        self.connectCount = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.indicatorView stopAnimating];
            [self.hud hideAnimated:YES];
            NSString *message = [NSString stringWithFormat:@"无法连接到设备，原因是：%@", [XMUtil checkPPCSErrorStringWithRet:Ret]];
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                if (self.navigationController.viewControllers.count <= 1) {
                    AppDelegate *appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
                    KDSTabBarController *tab = [KDSTabBarController new];
                    appdelegate.window.rootViewController = tab;
                }else{
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
            UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"重新连接" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self connectDevice];
            }];
            [cancelAction setValue:KDSRGBColor(154, 154, 154) forKey:@"titleTextColor"];
            [retryAction setValue:KDSRGBColor(32, 150, 248) forKey:@"titleTextColor"];
            [controller addAction:cancelAction];
            [controller addAction:retryAction];
            [self presentViewController:controller animated:true completion:nil];
        });
    }
}

- (void)createSubviews {
    [self initMovieViewController];
    [self.view addSubview:self.playBar];
    self.playBar.voiceSmallBtn.selected = NO;
    if (self.type == XMPlayTypeReplay) {
        [self.view addSubview:self.tableView];
        [self.playBar setPlayBarViewButtonType:XMPlayBarViewButtonTypeTalk enabled:false];
    }
}

/// 初始化解码播放器
- (void)initMovieViewController {
    if (_movieViewController == nil) {
        //*  movieViewControllerWithContentPath/初始化播放器
        //*  @param  path           流的URL路径(默认填写:@"LTP2P://live.001"  建议不修改成其他值)
        //*  @param  parameters     NSDictionary* dic = @{@"StreamMode":@"realtream"} (实时流) 或者@{@"StreamMode":@"filestream"}(文件流)
        NSDictionary *parameters = @{@"StreamMode" : @"realtream", @"CtrlFrameworkVersion" : [XMStreamComCtrl sdkVersion]};
        if (self.type == XMPlayTypeReplay) {
            parameters = @{@"StreamMode": @"filestream"};
        }
        _movieViewController = [XmMovieViewController movieViewControllerWithContentPath:@"LTP2P://live.001" parameters:parameters];
        self.movieViewController.delegate = self;
    }
    [self.movieViewController ResetAllFrameBuffer];
    [self.movieViewController ResetAudioBuffer];
    [self.movieViewController SetPlayFrameRate:self.videoFrameRate];
    [self.movieViewController setFrameViewRect:self.liveViewFrame];
    if (self.type == XMPlayTypeLive) {
        // 建议只在竖屏时设置
        [self.movieViewController SetScalefor1080:true];
        self.movieViewController.direction = XMMovieDirectionRight;
    }
    [self.view addSubview:self.movieViewController.view];
    self.movieViewController.view.hidden = false;
    self.tempImg = [UIImageView new];
    self.tempImg.image = self.temporaryDocumentsImg;
    [self.movieViewController.view addSubview:self.tempImg];
    [self.tempImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.movieViewController.view);
    }];
    [self addOfflinePwdSupView];
}

/// 释放p2p连接和解码器
- (void)releaseLive {
    if (self.isVoiceOn) {
        self.voiceOn = false;
    }
    if (self.isRecording) {
        [self record];
    }
    if (self.isTalkOn) {
        self.talkOn = false;
        if (self.movieViewController) {
            [self.movieViewController Talkback:false];
        }
        [self.streamManager StopTalkback];
    }

    if (self.movieViewController) {
        [self.movieViewController stop];
        [self.movieViewController ResetAllFrameBuffer];
        [self.movieViewController ResetAudioBuffer];
        [self.movieViewController.view removeFromSuperview];
        self.movieViewController = nil;
    }
    self.videoLoaded = false;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.streamManager StopAudioStream];
        [self.streamManager StopVideoStream];
        [self.streamManager StopConnectDevice];
    });
    
    [self stopCheckDecode];
    [KDSUserManager sharedManager].doorbellProgress = NO;
}

#pragma mark - StreamDelegate
/// 接收的音频数据
/// @param data 音频数据
/// @param length 音频长度
/// @param timestamp 时间戳
- (void)onAudioData:(const void *)data andlength:(unsigned int)length andtimestamp:(long long)timestamp {
    if (data != NULL && self.videoLoaded == true) {// 视频解码成功后才输入音频数据
        XmRealTimeFrame* audioframe = [[XmRealTimeFrame alloc]init];
        audioframe.type = 1;
        audioframe.timestamp = timestamp;
        audioframe.data = [[NSData alloc] initWithBytes:data length:length];
        [self.movieViewController InputMediaFrame:audioframe];
    }
}

/// 接收的视频数据
/// @param data 视频数据
/// @param length 视频长度
/// @param frameIndex 帧号
/// @param timestamp 时间戳
/// @param isIFrame 是否是I帧
/// @param videoRes 视频分辨率
/// @param Rate  帧率
/// @param steamType 流类型（0实时流 1录像流）
- (void)onVideoData:(const void *)data andlength:(unsigned int)length andframeindex:(unsigned int)frameIndex andtimestamp:(long long)timestamp andisIFrame:(int)isIFrame VideoRes:(P2P_VIDEO_RESOLUTION)videoRes FrameRate:(int)Rate SteamType:(int)steamType {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.currentTimeLb.text = [NSString stringWithFormat:@"%@",[KDSTool getTimeFromTimestamp:timestamp/1000 - 28800]];
    });
    if (steamType == REAL_STREAM_MOD) {
        if (!self.isFirstFrame) {
            self.firstFrame = true;
            if (self.viewActivated) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [self.streamManager StartAudioStream];
                });
            }
        }
    }
    
    if(self.videoFrameRate != Rate && self.movieViewController) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.movieViewController SetPlayFrameRate:Rate];
            self.videoFrameRate = Rate;
        });
    }
    XmRealTimeFrame* videoFrame = [[XmRealTimeFrame alloc]init];
    videoFrame.type = 0;
    if (isIFrame) {
        videoFrame.videotype = 1;
    }
    
    if (data) {
        NSData *videoFrameData = [[NSData alloc] initWithBytes:data length:length];
        videoFrame.data = videoFrameData;
        videoFrame.FrameNo = frameIndex;
        videoFrame.timestamp = timestamp;
        [self.movieViewController InputMediaFrame:videoFrame];
    }
}

/// 设备登录回调
/// @param RetDic 登录回调结果数据
/// @param DID 登录的设备did
- (void)LogInDeviceProcResult:(NSDictionary *)RetDic DID:(NSString *)DID {
    NSLog(@"LogInDeviceProcResult = %@", RetDic);
    if ([[RetDic objectForKey:@"result"] isEqualToString:@"ok"]) {
        if (self.type == XMPlayTypeReplay) {
            [self searchRecordFileListWithDateString:nil];
        }
    } else {
        NSInteger errorCode = [[RetDic objectForKey:@"errno"] integerValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (errorCode) {
                case 6: {
                    NSLog(@"Connection password error.");
                }
                    break;
                case 114: {// 目前只支持3个用户同时查看，这里会返回最后一个查看的用户
                    NSString *user_id = [RetDic objectForKey:@"user_id"];
                    NSLog(@"User %@ is viewing, please try again later.", user_id);
                }
                    break;
                    
                default: {
                    NSLog(@"Login failed.");
                }
                    break;
            }
        });
    }
}

/// 开启视频流回调
/// @param RetDic 回调结果数据
- (void)StartVideoStreamProcResult:(NSDictionary*)RetDic {
    if(RetDic && [RetDic[@"result"] isEqualToString:@"ok"]) {
        self.videoFrameRate = [RetDic[@"videoframerate"] intValue];
    } else {
//        NSString *errorInfo = [RetDic objectForKey:@"errno"];
    }
}

/// 开启音频流回调
/// @param RetDic 回调结果数据
- (void)StartAudioStreamProcResult:(NSDictionary*)RetDic {
    NSLog(@"StartAudioStreamProcResult RetDic == %@", RetDic);
    if(RetDic&&[RetDic[@"result"] isEqualToString:@"ok"]) {
        self.voiceOn = true;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reStartAudioStream) object:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.playBar setPlayBarViewButtonType:XMPlayBarViewButtonTypeMute state:XMPlayBarViewButtonStateNormal];
        });
    } else {
        self.voiceOn = false;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.playBar setPlayBarViewButtonType:XMPlayBarViewButtonTypeMute state:XMPlayBarViewButtonStateSelected];
        });
        if (self.isVideoLoaded && self.isViewActivated) {
            [self performSelector:@selector(reStartAudioStream) withObject:nil afterDelay:2];
        }
    }
}

/// 重开音频流
- (void)reStartAudioStream {
    [self.streamManager StartAudioStream];
}

/// 关闭音频流回调
/// @param RetDic 回调结果数据
- (void)StopAudioStreamProcResult:(NSDictionary*)RetDic {
    if(RetDic&&[RetDic[@"result"] isEqualToString:@"ok"]) {
        self.voiceOn = false;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.playBar setPlayBarViewButtonType:XMPlayBarViewButtonTypeMute state:XMPlayBarViewButtonStateSelected];
        });
    }
}

/// 开启对讲回调
/// @param RetDic 回调结果数据
- (void)StartTalkbackProcResult:(NSDictionary*)RetDic {
    if(RetDic&&[RetDic[@"result"] isEqualToString:@"ok"]){
        self.talkOn = true;
        if (self.movieViewController) {
            [self.movieViewController Talkback:true];
        }
    }
}

/// 关闭对讲回调
/// @param RetDic 回调结果数据
- (void)StopTalkbackProcResult:(NSDictionary*)RetDic {
    if(RetDic && [RetDic[@"result"] isEqualToString:@"ok"]) {
        self.talkOn = false;
    }
}

/// 设备主动通知用户的相关消息
/// @param dic 消息内容
/// @param DID 设备did
- (void)OnPushCmdRet:(NSDictionary *)dic DevId:(NSString *)DID {
    if (dic && [[dic objectForKey:@"CmdId"] intValue] == xMP2P_MSG_FILE_RECEIVE_END) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isRecording) {
                [self record];
            }
        });
        self.playRecordToken = 0;
        [self startCheckDecode];
    }
}

/// 当前连接的异常断开回调
/// @param ErrorNo 错误码
- (void)OnConnectfailed:(NSInteger)ErrorNo {
    if (ErrorNo == ERROR_PPCS_USER_CONNECT_BREAK) {// 主动断开
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.indicatorView.isAnimating) {
                [self.indicatorView stopAnimating];
                [self.hud hideAnimated:YES];
            }
        });
        return;
    }
    if (self.isCanReconnect) {// 断开重连
        self.canReconnect = false;
        dispatch_queue_t reconnectQueue = dispatch_queue_create("net.xmitech.reconnectQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_async(group, reconnectQueue, ^{
            if (self.isRecording) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self record];
                });
            }
            [self.streamManager StopVideoStream];
            [self.streamManager StopAudioStream];
            [self.streamManager StopConnectDevice];
        });
        
        dispatch_group_notify(group, reconnectQueue, ^{
            [self connectDevice];
        });
    }
}

#pragma mark - 回放相关回调
- (void)SearchRecordFileListProcResult:(NSDictionary *)RetDic {
    if(RetDic && [[RetDic objectForKey:@"result"] isEqualToString:@"ok"]) {
        // 这里未排序，如有需要可以自行排序。
        self.fileListItem = [[XMRecordFileListItem alloc] initWithDictionary:RetDic];
        self.selectedIndex = 0;
    }
}

- (void)PlayDeviceRecordVideoProcResult:(NSDictionary *)RetDic {
    if (RetDic && [[RetDic objectForKey:@"result"] isEqualToString:@"ok"]) {
        self.playRecordToken = [[RetDic objectForKey:@"token"] integerValue];
    } else {
        // 如果有错误并且错误码为116时，则需要延时2秒左右重新播放
    }
}

#pragma mark - DecoderDelegate
/// 解码回调
/// @param Ok 解码是否成功
/// @param Num 帧号
/// @param time 时间
/// @param width 宽度
/// @param height 高度
- (void)OnDecoderOneframe:(bool)Ok FrameNo:(int)Num timestamp:(long long)time v_width:(int)width v_height:(int)height {
    if (Ok) {
        self.videoLoaded = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.tipsView.hidden == NO || self.indicatorView.isAnimating) {
                self.tipsView.hidden = YES;
                [self.indicatorView stopAnimating];
                [self.changeTimer invalidate];
                self.changeTimer = nil;
                self.navigationController.navigationBar.hidden = NO;
                if (self.tempImg) {
                    [self.tempImg removeFromSuperview];
                    [self.hud hideAnimated:YES];
                }
                if (!self.temporaryDocumentsImg) {
                    [self createSubviews];
                }
            }
        });
        CGSize size = CGSizeMake(width, height);
        if (!CGSizeEqualToSize(self.videoResSize, size)) {
            self.videoResSize = size;
        }
    }
    _decodeTimestamp = [[NSDate date] timeIntervalSince1970];
}
- (void)navBackClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
/// 对讲的录音的音频数据
/// @param destbuf 音频数据
/// @param Length 长度
- (void)OnTalkBackaudio:(const void *)destbuf audioFramelen:(int)Length {
    if (self.isTalkOn && [self.streamManager streamConnectStatus] == XMStreamConnectStatusConnected) {
        NSMutableData *sendbuf = [[NSMutableData alloc] initWithBytes:destbuf length:Length];
        [self.streamManager SendTalkbackAudioData:sendbuf time:1 length:Length];
    }
}

#pragma mark - XMPlayBarViewDelegate
/// 控制条的按钮操作回调
/// @param view XMPlayBarView
/// @param btn 按钮本身
/// @param type 按钮事件类型
- (void)XMPlayBarView:(XMPlayBarView *)view buttonClicked:(UIButton *)btn type:(XMPlayBarViewButtonType)type {
    if (!self.isVideoLoaded && type != XMPlayBarViewButtonTypeAlbum) {
        return;
    }
    switch (type) {
        case XMPlayBarViewButtonTypeRecord: {
            if (self.type == XMPlayTypeReplay) {
                // 回放流下载要从头开始，所以要重新开始传流。注意：这里的回放流下载是按整个录像文件下载设计，需要传输完成时才会停止，如果有其他需求可以自行设计逻辑。
                // 如果需要做进度条可以用时间戳来做。每个XMRecordFileItem里面都会有开始时间戳和时长，再参考onVideoData回调的时间戳来做就可以了。
                self.selectedIndex = self.selectedIndex;
            }
            [self record];
        }
            break;
        case XMPlayBarViewButtonTypeCut: {
            [self cut];
        }
            break;
        case XMPlayBarViewButtonTypeTalk: {
            [self talk];
        }
            break;
        case XMPlayBarViewButtonTypeMute: {
            [self mute];
        }
            break;
        case XMPlayBarViewButtonTypeAlbum:{
            [self screenSnapshot];
            KDSMyAlbumVC * vc = [KDSMyAlbumVC new];
            vc.lock = self.lock;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fileListItem.recordfilelist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCellIdentifier"];
        XMRecordFileItem *item = self.fileListItem.recordfilelist[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"录像文件：%@", item.file];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"类型：%@", [self detectionTypeWithType:item.detect_type]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (self.selectedIndex == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SIZE_SCREEN_WIDTH, 30)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, SIZE_SCREEN_WIDTH - 32, 30)];
    label.text = @"录像文件列表";
    label.font = [UIFont systemFontOfSize:14];
    [view addSubview:label];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = indexPath.row;
}

#pragma mark - init XMStreamComCtrl
/// 初始化p2p连接库
- (void)initXMStreamComCtrl {
    if (self.isInitStream) {
        return;
    }
    [self deinitXMStreamComCtrl];
    const char *str = [AERVICE_STRING cStringUsingEncoding:NSASCIIStringEncoding];
    [XMStreamComCtrl initAPI:(char *)str];
    self.initStream = true;
}
/// 释放p2p连接库
- (void)deinitXMStreamComCtrl {
    if (self.isInitStream) {
        [XMStreamComCtrl deinitAPI];
        self.initStream = false;
    }
}

#pragma mark - lazy
- (XMStreamComCtrl *)streamManager {
    if (_streamManager == nil) {
        _streamManager = [XMStreamComCtrl new];
        self.streamManager.delegate = self;
    }
    return _streamManager;
}

//*  movieViewControllerWithContentPath/初始化播放器
//*  @param  path           流的URL路径(默认填写:@"LTP2P://live.001"  建议不修改成其他值)
//*  @param  parameters     NSDictionary* dic = @{@"StreamMode":@"realtream"} (实时流) 或者@{@"StreamMode":@"filestream"}(文件流)
- (XmMovieViewController *)movieViewController {
    if (_movieViewController == nil) {
        NSDictionary *parameters = @{@"StreamMode" : @"realtream", @"CtrlFrameworkVersion" : [XMStreamComCtrl sdkVersion]};
        if (self.type == XMPlayTypeReplay) {
            parameters = @{@"StreamMode": @"filestream"};
        }
        _movieViewController = [XmMovieViewController movieViewControllerWithContentPath:@"LTP2P://live.001" parameters:parameters];
        self.movieViewController.delegate = self;
    }
    return _movieViewController;
}

- (UIActivityIndicatorView *)indicatorView {
    if (_indicatorView == nil) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    return _indicatorView;
}

- (XMPlayBarView *)playBar {
    if (_playBar == nil) {
        _playBar = [XMPlayBarView new];
        self.playBar.delegate = self;
    }
    return _playBar;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.rowHeight = 44;
    }
    return _tableView;
}

#pragma mark - timer
- (void)startCheckDecode {
    [self stopCheckDecode];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkDecode) userInfo:nil repeats:true];
}

- (void)stopCheckDecode {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)checkDecode {
    NSTimeInterval currenTimestmep = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval value = currenTimestmep - self.decodeTimestamp;
    if (value >= 2.0) {// 超过2秒没有解码 则认为播放完成
        [self stopCheckDecode];
        NSInteger count = self.fileListItem.recordfilelist.count - 1;
        if (self.selectedIndex < count) {
            self.selectedIndex = self.selectedIndex + 1;
        } else {
            NSLog(@"已播放完最后一个录像");
        }
    }
}

#pragma mark - set
- (void)setTalkOn:(BOOL)talkOn {
    _talkOn = talkOn;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isTalkOn) {
            [self.playBar setPlayBarViewButtonType:XMPlayBarViewButtonTypeTalk state:XMPlayBarViewButtonStateSelected];
        } else {
            [self.playBar setPlayBarViewButtonType:XMPlayBarViewButtonTypeTalk state:XMPlayBarViewButtonStateNormal];
        }
    });
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        if (self.selectedIndex > 0) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:true];
        }
        [self playDeviceRecordVideo:self.fileListItem.recordfilelist[self.selectedIndex]];
    });
}

#pragma mark - other
- (NSString *)detectionTypeWithType:(XMTriggerType)type {
    if (type & XMTriggerTypeHD) {
        return @"人形侦测";
    }
    if (type & XMTriggerTypeMD) {
        return @"移动侦测";
    }
    return @"PIR触发";
}

#pragma mark --通知
///mqtt上报事件通知。
- (void)wifiUnlockChangeNotification:(NSNotification *)noti
{
    MQTTSubEvent event = noti.userInfo[MQTTEventKey];
    NSDictionary *param = noti.userInfo[MQTTEventParamKey];
   if ([event isEqualToString:MQTTSubEventWifiUnlock]){
        if (![param[@"wfId"] isEqualToString:self.lock.wifiDevice.wifiSN]) return;
       dispatch_async(dispatch_get_main_queue(), ^{
           UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"门锁已打开，是否继续观看？" preferredStyle:UIAlertControllerStyleAlert];
           UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"继续播放" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
           }];
           UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
               if (self.navigationController.viewControllers.count <= 1) {
                   AppDelegate *appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
                   KDSTabBarController *tab = [KDSTabBarController new];
                   appdelegate.window.rootViewController = tab;
               }else{
                   [self.navigationController popViewControllerAnimated:YES];
               }
           }];
           [cancelAction setValue:KDSRGBColor(154, 154, 154) forKey:@"titleTextColor"];
           [retryAction setValue:KDSRGBColor(32, 150, 248) forKey:@"titleTextColor"];
           [controller addAction:cancelAction];
           [controller addAction:retryAction];
           [self presentViewController:controller animated:true completion:nil];
       });
       return;
    }
}
#pragma mark - 控件等事件方法。
///设置
- (void)rightitemClick:(UIButton *)sender
{
    [self screenSnapshot];
    KDSRealTimeVideoSettingsVC * vc = [KDSRealTimeVideoSettingsVC new];
    vc.lock = self.lock;
    [self.navigationController pushViewController:vc animated:YES];
}
///取消
- (void)cancelbuttonClicked:(UIButton *)sender
{
    if (self.navigationController.viewControllers.count <= 1) {
        AppDelegate *appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
        KDSTabBarController *tab = [KDSTabBarController new];
        appdelegate.window.rootViewController = tab;
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
///接听
- (void)answerbuttonClicked:(UIButton *)sender
{
    self.changeTimer = [NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(callOutTime:) userInfo:nil repeats:YES];
    self.viewActivated = true;
    [self connectDevice];
    self.answerbutton.hidden = YES;
    self.tipsLb.text = @"正在建立安全连接，请稍后";
    [self.cancelbutton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@70);
        make.height.equalTo(@110);
        make.bottom.equalTo(self.tipsView.mas_bottom).offset(-(kBottomSafeHeight + 60));
        make.centerX.equalTo(self.tipsView.mas_centerX);
    }];
}
///点击返回按钮。
- (void)backBtnAction:(UIButton *)sender
{
    if (self.navigationController.viewControllers.count <= 1) {
        AppDelegate *appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
        KDSTabBarController *tab = [KDSTabBarController new];
        appdelegate.window.rootViewController = tab;
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:[XMUtil temporaryDocuments] error:nil];
}

#pragma mark === 永久闪烁的动画 ======

-(CABasicAnimation *)opacityForever_Animation:(float)time
{
   CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];//必须写opacity才行。
   animation.fromValue = [NSNumber numberWithFloat:1.0f];
   animation.toValue = [NSNumber numberWithFloat:0.0f];//这是透明度。
   animation.autoreverses = YES;
   animation.duration = time;
   animation.repeatCount = MAXFLOAT;
   animation.removedOnCompletion = NO;
   animation.fillMode = kCAFillModeForwards;
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];///没有的话是均匀的动画。
   return animation;
}

-(void)startClick:(NSTimer *)timer{
    
    self.seconds ++;
    self.timerLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",self.seconds/60/24,self.seconds/60,self.seconds%60];
    
}

- (void)dealloc {
    
    [self.changeTimer invalidate];
    self.changeTimer = nil;
//    [[NSFileManager defaultManager] removeItemAtPath:[XMUtil cachesPathWithWifiSN:self.lock.wifiDevice.wifiSN] error:nil];
}

#pragma mark -- <获取相片>
- (PHFetchResult<PHAsset *> *)createdAssets:(nonnull UIImage *)image {
    // 同步执行修改操作
    NSError *error = nil;
    __block NSString *assertId = nil;
    // 保存图片到【相机胶卷】
    [[PHPhotoLibrary sharedPhotoLibrary]performChangesAndWait:^{
        assertId =  [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
        
    } error:&error];
    if (error) {
        NSLog(@"保存失败");
        return nil;
    }
    // 获取相片
    PHFetchResult<PHAsset *> *createdAssets = [PHAsset fetchAssetsWithLocalIdentifiers:@[assertId] options:nil];
    return createdAssets;
}
- (PHFetchResult<PHAsset *> *)createdPathAssets:(nonnull NSString *)path
{
    // 同步执行修改操作
    NSError *error = nil;
    __block NSString *assetId = nil;
    // 保存视频到【Camera Roll】(相机胶卷)
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        assetId = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:path]].placeholderForCreatedAsset.localIdentifier;
    } error:&error];
    if (error) {
        NSLog(@"保存失败");
        return nil;
    }
    // 获取视频
    PHFetchResult<PHAsset *> *createdAssets = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil];
    return createdAssets;
}
#pragma mark --  <保存图片到相册>
-(void)saveImage:(nonnull UIImage *)image
{
    // 1.先保存图片到【相机胶卷】
    PHFetchResult<PHAsset *> *createdAssets = [self createdAssets:image];
    if (createdAssets == nil) {
        [MBProgressHUD showError:@"保存图片失败"];
    }
    // 2.拥有一个【自定义相册】
    PHAssetCollection * assetCollection = self.createCollection;
    if (assetCollection == nil) {
        [MBProgressHUD showError:@"创建相册失败"];
    }
    // 3.将刚才保存到【相机胶卷】里面的图片引用到【自定义相册】
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary]performChangesAndWait:^{
        PHAssetCollectionChangeRequest *requtes = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        // [requtes addAssets:@[placeholder]];
        [requtes insertAssets:createdAssets atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } error:&error];
    if (error) {
        [MBProgressHUD showError:@"保存图片失败"];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            KDSAlertView *alertView = [KDSAlertView alertControllerWithTitle:@"图片保存相册成功"];
            [self.movieViewController.view addSubview:alertView];
            [alertView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@165);
                make.height.equalTo(@41);
                make.centerY.centerX.equalTo(self.movieViewController.view);
            }];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [alertView removeFromSuperview];
            });
        });
    }
}

#pragma mark -- <获取当前App对应的自定义相册>
- (PHAssetCollection *)createCollection
{
    NSString *title =[NSString stringWithFormat:@"KDS:%@",self.lock.wifiDevice.wifiSN];
    //抓取所有【自定义相册】
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    // 查询当前App对应的自定义相册
    for (PHAssetCollection *collection in collections) {
        if ([collection.localizedTitle isEqualToString:title]) {
            return collection;
        }
    }
    //当前对应的app相册没有被创建
    NSError *error = nil;
    __block NSString *createCollectionID = nil;
    [[PHPhotoLibrary sharedPhotoLibrary]performChangesAndWait:^{
        //创建一个【自定义相册】(需要这个block执行完，相册才创建成功)
        createCollectionID = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title].placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    if (error) {
        NSLog(@"创建相册失败");
        return nil;
    }
    // 根据唯一标识，获得刚才创建的相册
    PHAssetCollection *createCollection = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createCollectionID] options:nil].firstObject;
    return createCollection;
}

- (void)saveVideoToCustomPhotosAlbum:(NSString *)path
{
    PHFetchResult<PHAsset *> *createdAssets = [self createdPathAssets:path];
    if (createdAssets == nil) {
        [MBProgressHUD showError:@"保存视频失败"];
    }
    // 2.拥有一个【自定义相册】
    PHAssetCollection * assetCollection = self.createCollection;
    if (assetCollection == nil) {
        [MBProgressHUD showError:@"创建相册失败"];
    }
    // 将【Camera Roll】(相机胶卷)的视频 添加到【自定义Album】(相簿\相册)中
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
    PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
    [request addAssets:createdAssets];
    } error:&error];
    if (error) {
        
        [MBProgressHUD showError:@"保存视频失败"];
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            KDSAlertView *alertView = [KDSAlertView alertControllerWithTitle:@"视频保存相册成功"];
            [self.movieViewController.view addSubview:alertView];
            [alertView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@165);
                make.height.equalTo(@41);
                make.centerY.centerX.equalTo(self.movieViewController.view);
            }];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [alertView removeFromSuperview];
            });
        });
    }
}

#pragma mark --离线密码的点击事件

- (void)offlineBtnClicked:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.pwdLbSupView.hidden = NO;
    }else{
        self.pwdLbSupView.hidden = YES;
    }
}

///呼叫超时
- (void)callOutTime:(NSTimer *)overTimer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.indicatorView stopAnimating];
        [self.hud hideAnimated:YES];
        NSString *message = [NSString stringWithFormat:@"视频连接超时，请稍后再试"];
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (self.navigationController.viewControllers.count <= 1) {
                AppDelegate *appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
                KDSTabBarController *tab = [KDSTabBarController new];
                appdelegate.window.rootViewController = tab;
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
        UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"重新连接" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self connectDevice];
        }];
        [cancelAction setValue:KDSRGBColor(154, 154, 154) forKey:@"titleTextColor"];
        [retryAction setValue:KDSRGBColor(32, 150, 248) forKey:@"titleTextColor"];
        [controller addAction:cancelAction];
        [controller addAction:retryAction];
        [self presentViewController:controller animated:true completion:nil];
    });
}

- (NSString *)getOfflinePwd
{
    NSString * offlinePwdStr;
    ///随机数 + eSN + 时间戳 哈希运算取前4字节，取余 10e6 ，即是临时密码（即生成起30分钟内生效）
    NSString * randomCode = [self.lock.wifiDevice.randomCode uppercaseString];
    NSString * wifiSN = [self.lock.wifiDevice.wifiSN uppercaseString];
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    int temp = (int)([datenow timeIntervalSince1970])/5/60;//把utc时间转换成 刻度
    NSString * currentStr = @"";
    currentStr = [currentStr stringByAppendingFormat:@"%@%@%d",wifiSN,randomCode,temp];
    //测试数据
    // currentStr = @"WF01193810001000000000000000000000000000000000000000000000000000000005156785";
    NSString * haxi = [NSString sha256HashFor:currentStr];
    NSData * zifuc16 = [KDSBleAssistant convertHexStrToData:haxi];
    Byte * byttt = (Byte *)[zifuc16 bytes];
    Byte uiu[4] = {};
    uiu[0] = byttt[0];
    uiu[1] = byttt[1];
    uiu[2] = byttt[2];
    uiu[3] = byttt[3];
    long long int zxphr = (long long int)[NSString bytesToIntWithBytes:uiu offset:0];
    NSString * pwd = [NSString stringWithFormat:@"%06ld",(long)zxphr%1000000];
    NSLog(@"%lld",zxphr);
    KDSPwdListModel * model = [KDSPwdListModel new];
    model.pwd = pwd;
    model.createTime = [datenow timeIntervalSince1970];
    offlinePwdStr = pwd;
//    self.model = model;
    
    return offlinePwdStr;
}

///页面离开时，最后一帧图片缓存下来，返回到此页面时会用到
- (void)screenSnapshot
{
    NSString *path = [[NSString alloc] initWithFormat:@"%@/.png", [XMUtil temporaryDocuments]];
    UIImage *image;
    bool success = [self.movieViewController SnapImageFile:path];
    if (success) {
        image = [UIImage imageWithContentsOfFile:path];
    }
    image = [[UIImage alloc] initWithCGImage:image.CGImage scale:1.0 orientation:UIImageOrientationRight];
    self.temporaryDocumentsImg = image;
}


#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [navigationController setNavigationBarHidden:YES animated:YES];
}


@end
