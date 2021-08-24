//
//  KDSPlaybackCaptureVC.m
//  KaadasLock
//
//  Created by zhaoxueping on 2020/10/14.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSPlaybackCaptureVC.h"
#import "XmMovieViewController.h"
#import <XMStreamComCtrl/XMStreamComCtrl.h>
#import "XMPlayBarView.h"
#import "XMUtil.h"
#import "KDSTool.h"
#import "KDSDBManager+XMMediaLock.h"
#import <Photos/Photos.h>
#import <AVKit/AVKit.h>

@interface KDSPlaybackCaptureVC ()<UINavigationControllerDelegate,StreamDelegate, DecoderDelegate>

///上个导航控制器的代理。
@property (nonatomic, weak) id<UINavigationControllerDelegate> preDelegate;
/// 音视频流的管理
@property (nonatomic, strong) XMStreamComCtrl *streamManager;
/// 解码并播放的控制器
@property (nonatomic, strong) XmMovieViewController *movieViewController;
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
/// 对音视频正在录像中的标记
@property (nonatomic, assign, getter=isRecording) BOOL recording;
/// 音频开启的标记
@property (nonatomic, assign, getter=isVoiceOn) BOOL voiceOn;
/// 对讲开启的标记
@property (nonatomic, assign, getter=isTalkOn) BOOL talkOn;
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
/// 播放文件PlayDeviceRecordVideo回调产生的Token，可以用来控制这个录像，目前暂不支持RECORD_CTRL_PAUSE这个暂停操作。
@property (nonatomic, assign) NSInteger playRecordToken;
/// 检查回放流解码完成的定时器，可以参考这里做自动播放下一个文件。
@property (nonatomic, strong) NSTimer *timer;
/// 解码时的时间
@property (nonatomic, assign) NSTimeInterval decodeTimestamp;
/// 菊花loading
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
///定时，30秒超时
@property (nonatomic,strong)NSTimer * changeTimer;
///系统视频播放器
@property (nonatomic, strong)AVPlayerViewController *playerVC;
///视频没有解码成功前展示的第一帧的画面
@property (nonatomic, strong)UIImageView * videoPictureImg;
///标记第一次解码成功
@property (nonatomic, assign)int countNum;
///第一次看回放的时间
@property (nonatomic, assign)long long firstTime;
///是否进入解码
@property (nonatomic, assign)BOOL startDecoding;
///解码完成
@property (nonatomic, assign)BOOL decodingComplete;

@end

@implementation KDSPlaybackCaptureVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.countNum = 0;
    self.startDecoding = NO;
    self.decodingComplete = NO;
    NSString * fileName = [KDSTool timeStringFromTimestamp:[NSString stringWithFormat:@"%f",self.model.createTime]];
    ///如果要清理缓存的视频的话，[[NSFileManager defaultManager] removeItemAtPath:[XMUtil cachesPathWithWifiSN:self.lock.wifiDevice.wifiSN] error:nil];清理沙盒路径
    // 判读缓存数据是否存在
    NSString * cachesPath = [XMUtil cachesPathWithWifiSN:self.lock.wifiDevice.wifiSN];
    NSArray * allFileArr = [self getAllFileByName:cachesPath];
    for (NSString * mp4Address in allFileArr) {
        NSString * currentFileName = [mp4Address stringByReplacingOccurrencesOfString:@".mp4" withString:@""];
        if ([currentFileName isEqualToString:fileName]) {
            [self setAVPlayerVCWithAddress:mp4Address fileName:fileName path:cachesPath];
            return;
        }
    }
    if (self.lock.wifiDevice.powerSave.intValue == 1) {
        ///锁已开启节能模式，无法查看门外情况
        UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:@"锁已开启节能模式，无法在线查看视频" message:@"请更换电池或进入管理员模式进行关闭" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        //修改title
        NSMutableAttributedString *alertTitleStr = [[NSMutableAttributedString alloc] initWithString:@"锁已开启节能模式，无法在线查看视频"];
        [alertTitleStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, alertTitleStr.length)];
        [alerVC setValue:alertTitleStr forKey:@"attributedTitle"];

        //修改message
        NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:@"请更换电池或进入管理员模式进行关闭"];
        [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:KDSRGBColor(153, 153, 153) range:NSMakeRange(0, alertControllerMessageStr.length)];
        [alertControllerMessageStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(0, alertControllerMessageStr.length)];
        
        [alerVC setValue:alertControllerMessageStr forKey:@"attributedMessage"];
        [retryAction setValue:KDSRGBColor(32, 150, 248) forKey:@"titleTextColor"];
        
        [alerVC addAction:retryAction];
        [self presentViewController:alerVC animated:YES completion:nil];
        return;
    }
    
    [self prepare];
    [self setUI];
    self.changeTimer = [NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(callOutTime:) userInfo:nil repeats:YES];
    self.viewActivated = true;
    [self connectDevice];
}

- (NSArray *)getAllFileByName:(NSString *)path
{
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSArray *array = [defaultManager contentsOfDirectoryAtPath:path error:nil];
    return array;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.preDelegate = self.navigationController.delegate;
    self.navigationController.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.delegate = self.preDelegate;
    self.viewActivated = false;
}

- (void)setAVPlayerVCWithAddress:(NSString *)mp4Address fileName:(NSString *)fileName path:(NSString *)path
{
    self.view.backgroundColor = UIColor.blackColor;
    UIView * navView = [UIView new];
    navView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:navView];
    [navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.equalTo(@(kNavBarHeight+kStatusBarHeight+10));
    }];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal];
    backBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    backBtn.frame = CGRectMake(0, kStatusBarHeight, 44, 44);
    [backBtn addTarget:self action:@selector(backBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:backBtn];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];//加粗
    titleLabel.textColor = UIColor.blackColor;
    titleLabel.text = @"我的相册";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [navView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(navView).offset(kStatusBarHeight + 11);
        make.centerX.equalTo(navView);
        make.left.mas_equalTo(navView.mas_left).offset(30);
        make.right.mas_equalTo(navView.mas_right).offset(-30);
        make.height.equalTo(@25);
    }];
    
    UILabel * lb = [UILabel new];
    lb.textColor = UIColor.blackColor;
    lb.text = fileName;
    lb.font = [UIFont systemFontOfSize:12];
    lb.textAlignment = NSTextAlignmentCenter;
    [navView addSubview:lb];
    [lb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(navView);
        make.height.equalTo(@18);
    }];
    

    ///使用系统的播放器
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", path, mp4Address];
    self.playerVC = [[AVPlayerViewController alloc] init];
    self.playerVC.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:fullPath]];
    self.playerVC.showsPlaybackControls = YES;
    self.playerVC.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view addSubview:self.playerVC.view];
    [self.playerVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(navView.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(@(-kBottomSafeHeight));
    }];
    if (self.playerVC.readyForDisplay) {
        [self.playerVC.player play];
    }
}

- (void)setUI
{
    _liveViewFrame = CGRectMake(0, 0, SIZE_SCREEN_WIDTH, KDSScreenHeight-kBottomSafeHeight);
    
    if (_movieViewController == nil) {
        NSDictionary *parameters = parameters = @{@"StreamMode": @"filestream"};
        _movieViewController = [XmMovieViewController movieViewControllerWithContentPath:@"LTP2P://live.001" parameters:parameters];
        self.movieViewController.delegate = self;
    }
    [self.movieViewController ResetAllFrameBuffer];
    [self.movieViewController ResetAudioBuffer];
    [self.movieViewController SetPlayFrameRate:self.videoFrameRate];
    [self.movieViewController setFrameViewRect:self.liveViewFrame];
    // 建议只在竖屏时设置
    [self.movieViewController SetScalefor1080:true];
    self.movieViewController.direction = XMMovieDirectionRight;
    [self.view addSubview:self.movieViewController.view];
    self.movieViewController.view.hidden = false;
    
    UIView * navView = [UIView new];
    navView.backgroundColor = UIColor.whiteColor;
    [self.movieViewController.view addSubview:navView];
    [navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.movieViewController.view);
        make.height.equalTo(@(kNavBarHeight+kStatusBarHeight+10));
    }];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal];
    backBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    backBtn.frame = CGRectMake(0, kStatusBarHeight, 44, 44);
    [backBtn addTarget:self action:@selector(backBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:backBtn];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];//加粗
    titleLabel.textColor = UIColor.blackColor;
    titleLabel.text = @"我的相册";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [navView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(navView).offset(kStatusBarHeight + 11);
        make.centerX.equalTo(navView);
        make.left.mas_equalTo(navView.mas_left).offset(30);
        make.right.mas_equalTo(navView.mas_right).offset(-30);
        make.height.equalTo(@25);
    }];
    
    UILabel * lb = [UILabel new];
    lb.textColor = UIColor.blackColor;
    lb.text =[KDSTool timeStringFromTimestamp:[NSString stringWithFormat:@"%f",self.model.createTime]];
    lb.font = [UIFont systemFontOfSize:12];
    lb.textAlignment = NSTextAlignmentCenter;
    [navView addSubview:lb];
    [lb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(navView);
        make.height.equalTo(@18);
    }];
    
    ///视频没有加载出来之前显示缩略图的第一帧图片
    self.videoPictureImg = [UIImageView new];
    self.videoPictureImg.contentMode = UIViewContentModeScaleAspectFill;
    [self.videoPictureImg sd_setImageWithURL:[NSURL URLWithString:self.model.thumbUrl] placeholderImage:[UIImage imageNamed:@"img_default"]];
    double Degree=90.0/180.0;
    CGAffineTransform transform= CGAffineTransformMakeRotation(M_PI* Degree);
    self.videoPictureImg.transform = transform;//旋转
    [self.movieViewController.view addSubview:self.videoPictureImg];
    [self.videoPictureImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.movieViewController.view);
        make.top.equalTo(navView.mas_bottom).offset(0);
    }];
    [self.movieViewController.view addSubview:self.indicatorView];
    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@20);
        make.centerX.equalTo(self.movieViewController.view);
        make.centerY.equalTo(self.movieViewController.view);
    }];
    [self.indicatorView startAnimating];
    
    if (@available(iOS 13.0, *)) {
        UIUserInterfaceStyle mode = UITraitCollection.currentTraitCollection.userInterfaceStyle;
        if (mode == UIUserInterfaceStyleDark) {
            self.view.backgroundColor = [UIColor blackColor];
        } else if (mode == UIUserInterfaceStyleLight) {
            self.view.backgroundColor = [UIColor blackColor];
        }
    } else {
        self.view.backgroundColor = [UIColor blackColor];
    }
    [self movieViewController];
    
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
 
#pragma mark - connect
/// 通过p2p连接到设备
- (void)connectDevice {
    //无网络的时候不主动尝试连接
    //*******暂时先写死***后面要用服务器的值**************//
//    self.lock.wifiDevice.keep_alive_status = 1;
    if (![KDSUserManager sharedManager].netWorkIsAvailable) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.indicatorView stopAnimating];
            NSString *message = [NSString stringWithFormat:@"手机未开启网络，请打开网络再试"];
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:true];
            }];
            [retryAction setValue:KDSRGBColor(32, 150, 248) forKey:@"titleTextColor"];
            [controller addAction:retryAction];
            [self presentViewController:controller animated:true completion:nil];
        });
        return;
    }if (self.lock.wifiDevice.keep_alive_status == 0) {
        ///视频长连接已关闭
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.indicatorView stopAnimating];
            NSString *message = [NSString stringWithFormat:@"按门铃时可查看门外情况\n唤醒门锁后，可在视频设置中开启"];
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"视频长连接已关闭" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:true];
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
        parameter.userPassword = self.lock.wifiDevice.p2p_password;//@"ut4D0mvz";
        // 数据对比  p2p 的密码
        NSLog(@"zhu-- KDSPlaybackCaptureVC --数据对比p2p 的密码==%@",self.lock.wifiDevice.p2p_password);
        
        WeakSelf
        [self.streamManager StartConnectWithMode:XMStreamConnectModeWAN connectParam:parameter completeBlock:^(XMStreamComCtrl *steamComCtrl, NSInteger resultCode) {
            if (resultCode > 0) {
                weakSelf.canReconnect = true;
                if (!weakSelf.isViewActivated) {
                    [steamComCtrl StopConnectDevice];
                } else {
                    [weakSelf loginMqtt];
//                    [weakSelf startVideoStream];
                }
                
            } else {// 可以在这里处理错误或者重试逻辑
                [self handleDisConnectedDeviceAndReconnect:resultCode];
            }
        }];
    });
}

/// 通知设备MQTT登录
- (void)loginMqtt {
    [self.streamManager mqttCtrl:1 channel:0];
}

/// 通知设备MQTT退出登录
- (void)logoutMqtt {
    [self.streamManager mqttCtrl:0 channel:0];
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
            NSString *message = [NSString stringWithFormat:@"无法连接到设备，原因是：%@", [XMUtil checkPPCSErrorStringWithRet:Ret]];
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:true];
            }];
            UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"重试" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self connectDevice];
            }];
            [controller addAction:cancelAction];
            [controller addAction:retryAction];
            [self presentViewController:controller animated:true completion:nil];
        });
    }
}

/// 释放p2p连接和解码器
- (void)releaseLive {
    
    if (self.isVoiceOn) {
        self.voiceOn = false;
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
        if (!self.decodingComplete) {
            NSLog(@"是否在没有删除设备路径前停止录制");
            [self.movieViewController StopRecordToMP4];
        }
        self.movieViewController = nil;
    }
    self.videoLoaded = false;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self logoutMqtt];
        [self.streamManager StopAudioStream];
        [self.streamManager StopVideoStream];
        [self.streamManager StopConnectDevice];
    });
    
    
    NSString * fileName = [KDSTool timeStringFromTimestamp:[NSString stringWithFormat:@"%f",self.model.createTime]];
    ///如果要清理缓存的视频的话，[[NSFileManager defaultManager] removeItemAtPath:[XMUtil cachesPathWithWifiSN:self.lock.wifiDevice.wifiSN] error:nil];清理沙盒路径
    NSString * cachesPath = [XMUtil cachesPathWithWifiSN:self.lock.wifiDevice.wifiSN];
    NSArray * allFileArr = [self getAllFileByName:cachesPath];
    if (self.startDecoding == YES && self.decodingComplete == NO) {
        for (NSString * mp4Address in allFileArr) {
            NSString * currentFileName = [mp4Address stringByReplacingOccurrencesOfString:@".mp4" withString:@""];
            if ([currentFileName isEqualToString:fileName]) {
                NSString *paths = [XMUtil cachesPathWithWifiSN:self.lock.wifiDevice.wifiSN];
                NSString *fileName = [paths stringByAppendingPathComponent:mp4Address];
                [[NSFileManager defaultManager] removeItemAtPath:fileName error:nil];
                return;
            }
        }
    }
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
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.playRecordToken > 0) {
                [self.streamManager PlayRecViewCtrl:self.playRecordToken CmdId:RECORD_CTRL_STOP];
                self.playRecordToken = 0;
            }
            NSInteger ret = [self.streamManager PlayDeviceRecordVideo:self.model.fileName DateStr:self.model.fileDate RecordType:xMP2P_RECORD_PLAY_TYPE_NORMA];
            NSLog(@"PlayDeviceRecordVideo == %ld", (long)ret);
        });
        
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

- (void)onMqttCtrlProcResult:(NSDictionary *)RetDic {
    if(RetDic && [RetDic[@"result"] isEqualToString:@"ok"]) {
        NSLog(@"MQTT 命令发送成功");
    } else {
        // errno = 9999 是设备还不支持这个命令
        NSLog(@"MQTT 命令发送失败. RetDic == %@", RetDic);
    }
}

#pragma mark - 设备主动通知APP
/// 设备主动通知用户的相关消息
/// @param dic 消息内容
/// @param DID 设备did
- (void)OnPushCmdRet:(NSDictionary *)dic DevId:(NSString *)DID {
    NSLog(@"xxxxxxxxxx%@",dic);
    if (dic) {
        NSInteger cmdId = [[dic objectForKey:@"CmdId"] intValue];
        switch (cmdId) {
            case xMP2P_MSG_FILE_RECEIVE_END:
            {
                [self.movieViewController StopRecordToMP4];
                self.playRecordToken = 0;
                [self startCheckDecode];
                self.decodingComplete = YES;
                self.filePath = nil;
            }
                break;
                
            case xMP2P_MSG_MQTT_CTRL_RESULT: {// 这里没有测试过，逻辑是这样的。具体等设备固件支持这个功能后打印数据再处理
                NSDictionary *payload = [dic objectForKey:@"payload"];
                if (payload && payload.count > 0) {
                    if ([[payload objectForKey:@"result"] isEqualToString:@"ok"]) {
                        NSInteger ctrl = [[payload objectForKey:@"ctrl"] integerValue];
                        if (ctrl == 1) {
                            NSLog(@"MQTT 登录成功");
                        } else {
                            NSLog(@"MQTT 退出登录成功");
                        }
                    } else {
                        NSInteger errorCode = [[payload objectForKey:@"errno"] integerValue];
                        switch (errorCode) {
                            case 1011: {
                                NSLog(@"MQTT登录失败");
                            }
                                break;
                            case 1012: {
                                NSLog(@"MQTT登出失败");
                            }
                                break;
                            case 1013: {
                                NSLog(@"MQTT登出失败，有任务正在执行。");
                            }
                                break;
                                
                            default: {
                                NSLog(@"MQTT登录或者退出登录失败，原因未知。dic = %@", dic);
                            }
                                break;
                        }
                    }
                }
            }
                break;
                
            default:
                break;
        }
    }
}

/// 当前连接的异常断开回调
/// @param ErrorNo 错误码
- (void)OnConnectfailed:(NSInteger)ErrorNo {
    if (self.isCanReconnect) {// 断开重连
        self.canReconnect = false;
        dispatch_queue_t reconnectQueue = dispatch_queue_create("net.xmitech.reconnectQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_async(group, reconnectQueue, ^{
            [self.streamManager StopVideoStream];
            [self.streamManager StopAudioStream];
            [self.streamManager StopConnectDevice];
        });
        
        dispatch_group_notify(group, reconnectQueue, ^{
            [self connectDevice];
        });
    }
}

- (void)PlayDeviceRecordVideoProcResult:(NSDictionary *)RetDic {
    if (RetDic && [[RetDic objectForKey:@"result"] isEqualToString:@"ok"]) {
        self.playRecordToken = [[RetDic objectForKey:@"token"] integerValue];
    } else {
        NSString * errnoCode = [RetDic objectForKey:@"errno"];
        if (errnoCode.intValue == 116) {
            // 如果有错误并且错误码为116时，则需要延时2秒左右重新播放
            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC));
            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.playRecordToken > 0) {
                        [self.streamManager PlayRecViewCtrl:self.playRecordToken CmdId:RECORD_CTRL_STOP];
                        self.playRecordToken = 0;
                    }
                    NSInteger ret = [self.streamManager PlayDeviceRecordVideo:self.model.fileName DateStr:self.model.fileDate RecordType:xMP2P_RECORD_PLAY_TYPE_NORMA];
                    NSLog(@"PlayDeviceRecordVideo == %ld", (long)ret);
                });
                
            });
        }else if (errnoCode.intValue == 12){
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showError:@"回放失败,文件不存在"];
                [self.navigationController popViewControllerAnimated:YES];
            });
            
        }else if (errnoCode.intValue == 1){
            //获取JSON节点失败，json key错误
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showError:@"获取JSON节点失败，json key错误"];
                [self.navigationController popViewControllerAnimated:YES];
                
            });
           
        }else if (errnoCode.intValue == 9){
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showError:@"未找到录像文件"];
                [self.navigationController popViewControllerAnimated:YES];
                
            });
           
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showError:@"播放失败"];
                [self.navigationController popViewControllerAnimated:YES];
                
            });
        }
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
    self.countNum ++;
    self.startDecoding = YES;
    if (self.countNum == 1) {
        self.firstTime = time/1000;
    }
    if (Ok) {
        self.videoLoaded = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.changeTimer invalidate];
            self.changeTimer = nil;
        });
        CGSize size = CGSizeMake(width, height);
        if (!CGSizeEqualToSize(self.videoResSize, size)) {
            self.videoResSize = size;
            NSString *fileName = [KDSTool timeStringFromTimestamp:[NSString stringWithFormat:@"%f",self.model.createTime]];
            self.filePath = [[NSString alloc] initWithFormat:@"%@/%@.mp4", [XMUtil cachesPathWithWifiSN:self.lock.wifiDevice.wifiSN], fileName];
            if(self.videoFrameRate == 0) self.videoFrameRate = 15;
            [self.movieViewController StarRecordToMP4:self.filePath Framewidth:(int)self.videoResSize.width FrameHeight:(int)self.videoResSize.height FrameRate:self.videoFrameRate];
        }
    }
    _decodeTimestamp = [[NSDate date] timeIntervalSince1970];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.indicatorView stopAnimating];
        if (self.videoPictureImg) {
            [self.videoPictureImg removeFromSuperview];
        }
    });
    
    long long timeDifference = (time/1000) - self.firstTime;
    if (timeDifference == 8) {
        NSLog(@"当前回放看了8秒");
        ///播放完最后一个录像

    }
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
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showSuccess:@"观看完毕缓存成功"];
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
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


///呼叫超时
- (void)callOutTime:(NSTimer *)overTimer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.indicatorView stopAnimating];
        NSString *message = [NSString stringWithFormat:@"视频连接超时，请稍后再试"];
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:true];
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

#pragma mark - lazy
- (XMStreamComCtrl *)streamManager {
    if (_streamManager == nil) {
        _streamManager = [XMStreamComCtrl new];
        self.streamManager.delegate = self;
    }
    return _streamManager;
}

- (UIActivityIndicatorView *)indicatorView {
    if (_indicatorView == nil) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    return _indicatorView;
}

#pragma mark --点击事件
- (void)backBtnAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [navigationController setNavigationBarHidden:YES animated:YES];
}


@end
