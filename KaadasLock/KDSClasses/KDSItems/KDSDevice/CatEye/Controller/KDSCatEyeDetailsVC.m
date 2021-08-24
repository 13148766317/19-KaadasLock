//
//  KDSCatEyeDetailsVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/16.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSCatEyeDetailsVC.h"
#import "UIView+BlockGesture.h"
#import "KDSCatEyeMoreSettingVC.h"
#import "CateyeModel.h"
#import "KDSDBManager.h"
#import "KDSCateyeCallVC.h"
#import "KDSCatEyePlaybackVC.h"
#import "KDSMQTT.h"
#import "RKNotificationHub.h"
#import "KDSLockKeyVC.h"


@interface KDSCatEyeDetailsVC ()<UINavigationControllerDelegate>
///上半部分展示区视图：猫眼的状态、电量、名字等
@property (nonatomic,readwrite,strong)UIView *topSupView;
///下半部分功能区视图：回放、更多
@property (nonatomic,readwrite,strong)UIView * bottomSupView;
///上部分的背景图
@property (nonatomic,readwrite,strong)UIImageView *bgImg;
///猫眼的状态显示图
@property (nonatomic,readwrite,strong)UIImageView * catEyeStatusImg;
///电量图标
@property (nonatomic,readwrite,strong)UIImageView * electricImg;
///电量图标底图
@property (nonatomic,readwrite,strong)UIImageView * abroadElectricImg;
///电量显示百分比
@property (nonatomic,readwrite,strong)UILabel * electricLabel;
///时间：yyyy:mm:dd:
@property (nonatomic,readwrite,strong)UILabel *timeLabel;
///显示：电量图标、百分比、时间
@property (nonatomic,readwrite,strong)UIView * deviceFunctionSupview;
///猫眼型号
@property (nonatomic,readwrite,strong)UILabel * modelLabel;
///更多按钮
@property (nonatomic,readwrite,strong)UIButton * moreBtn;
///回放按钮
@property (nonatomic,readwrite,strong)UIButton * playBtn;
///设备共享按钮
@property (nonatomic,readwrite,strong)UIButton * shareBtn;
///更多和回放之间的竖线
@property (nonatomic,readwrite,strong)UIView * line1;
///更多和回放之间的横线
@property (nonatomic,readwrite,strong)UIView * line2;
///返回按钮
@property (nonatomic,readwrite,strong)UIButton * backBtn;
///猫眼昵称、名字
@property (nonatomic,readwrite,strong)UILabel * navigationLabelTitle;
///上个导航控制器的代理。
@property (nonatomic, weak) id<UINavigationControllerDelegate> preDelegate;
///提示猫眼的状态：在线、离线
@property (nonatomic,readwrite,strong)UILabel * cateEyeStatusLabel;
///在园内展示的状态：点击查看门外、设备已离线
@property (nonatomic,readwrite,strong)UILabel * cateEyeWithinStatusImgLabel;
///猫眼图标展示在圆内
@property (nonatomic,readwrite,strong)UIImageView * cateEyeIcon;

@property(nonatomic,readwrite,strong)CateyeModel * cateyeMode;
@property (nonatomic, strong)RKNotificationHub *hub;//回放img上方的数字提示视图
@end

@implementation KDSCatEyeDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = KDSRGBColor(242, 242, 242);
    [self setUI];
    [self makeConstraints];
    [self setDevicePowerInfo:self.cateye.powerStr];
    [KDSNotificationCenter addObserver:self
                              selector:@selector(pirPhotoUpdate:)
                                  name:@"PirPhotoAlarmUpdate"
                                object:nil];
}

#pragma mark - 生命周期、界面设置方法
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshInterfaceWhenDeviceDidSync:) name:KDSDeviceSyncNotification object:nil];
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.preDelegate = self.navigationController.delegate;
    self.navigationController.delegate = self;
    [self refreshPlayBackImgBadge];
    self.navigationLabelTitle.text = self.gatewayDeviceModel.nickName?: self.gatewayDeviceModel.deviceId;
    [[KDSMQTTManager sharedManager] cyGetTime:self.cateye.gatewayDeviceModel completion:^(NSError * _Nullable error, BOOL success, NSString * _Nullable zone, NSInteger timestamp) {
    }];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.delegate = self.preDelegate;
}
-(void)setUI
{
    [self.view addSubview:self.bgImg];
    [self.view addSubview:self.topSupView];
    [self.view addSubview:self.bottomSupView];
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.navigationLabelTitle];
    [self.topSupView addSubview:self.modelLabel];
    [self.topSupView addSubview:self.catEyeStatusImg];
    [self.topSupView addSubview:self.deviceFunctionSupview];
    [self.topSupView addSubview:self.cateEyeWithinStatusImgLabel];
    [self.topSupView addSubview:self.cateEyeStatusLabel];
    [self.topSupView addSubview:self.cateEyeIcon];
    [self.deviceFunctionSupview addSubview:self.electricImg];
    [self.deviceFunctionSupview addSubview:self.abroadElectricImg];
    [self.deviceFunctionSupview addSubview:self.electricLabel];
    [self.deviceFunctionSupview addSubview:self.timeLabel];
    [self.topSupView addSubview:self.cateEyeStatusLabel];
    [self.bottomSupView addSubview:self.line1];
    [self.bottomSupView addSubview:self.line2];
    [self.bottomSupView addSubview:self.moreBtn];
    [self.bottomSupView addSubview:self.playBtn];
    [self.bottomSupView addSubview:self.shareBtn];
    self.modelLabel.hidden = YES;
    [self refreshUI];
    [self refreshPlayBackImgBadge];
    
}
-(void)setPowerTimPasm
{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];//创建一个日期格式化器
    dateFormatter.dateFormat=@"yyyy-MM-dd";//指定转date得日期格式化形式
    if (!self.cateye.getPowerTime) {
        self.timeLabel.text = Localized(@"none");
        return;
    }
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[self.cateye.getPowerTime doubleValue]];
    NSString * timSpam = [KDSTool getNowTimeTimestamp];
    NSDate *date2 = [NSDate dateWithTimeIntervalSince1970:[timSpam doubleValue]];
    NSTimeInterval seconds = [date2 timeIntervalSinceDate:date];
    if (seconds < 60) {///小于1小时：‘刚刚’
        // self.timeLabel.text = Localized(@"nowTime");
    }else if (seconds< 1440 && seconds>60){
        self.timeLabel.text = Localized(@"today");
    }else if (1440<seconds && seconds < 2440){///昨天
        self.timeLabel.text = Localized(@"yesterday");
    }else if (seconds > 2440){
        self.timeLabel.text = [dateFormatter stringFromDate:date];
    }else{
        self.timeLabel.text = Localized(@"none");
    }
   
}

-(void)refreshUI{
    
    if (!self.cateye.online) {
        self.cateEyeStatusLabel.text = Localized(@"CatEyeOffline");
        self.cateEyeWithinStatusImgLabel.text = Localized(@"CateyeDeviceOffline");
        self.cateEyeWithinStatusImgLabel.textColor = KDSRGBColor(20, 166, 245);
        self.catEyeStatusImg.image = [UIImage imageNamed:@"cateyeOfflineBgImg"];
        self.cateEyeIcon.image = [UIImage imageNamed:@"catEyeOffline"];
        self.abroadElectricImg.image = [UIImage imageNamed:@"offline battery_icon"];
        
    }else{
        self.cateEyeStatusLabel.text = Localized(@"CatEyeOnline");
        self.cateEyeWithinStatusImgLabel.text =Localized( @"ClickOutside");
        self.cateEyeWithinStatusImgLabel.textColor = UIColor.whiteColor;
        self.catEyeStatusImg.image = [UIImage imageNamed:@"cateyeOnlineBgImg"];
        self.cateEyeIcon.image = [UIImage imageNamed:@"cateyeOnline"];
        self.abroadElectricImg.image = [UIImage imageNamed:@"Battery exterior"];
        
    }
     [self setPowerTimPasm];
     [self setDevicePowerInfo:self.cateye.powerStr];
}
-(void)refreshPlayBackImgBadge{
    NSArray * pirPhotoArray = [KDSUserDefaults objectForKey:[NSString stringWithFormat:@"PhotoAlarmArray%@",self.gatewayDeviceModel.deviceId]];
    if (!_hub) {
        _hub = [[RKNotificationHub alloc]initWithView:self.playBtn];
        [_hub moveCircleByX:(KDSScreenWidth-31)/3.5 Y:KDSSSALE_HEIGHT(259/6)];
    }
    [_hub setCount:(int)pirPhotoArray.count];
    [_hub bump];
}
- (void)setDevicePowerInfo:(int)power
{
    double width = power/100.0;
    if ([self.cateye.gatewayDeviceModel.event_str isEqualToString:@"online"]){
        if (power< 20) {
            self.electricImg.image = [UIImage imageNamed:@"low power"];
        }else{
            self.electricImg.image = [UIImage imageNamed:@"onLineElectric"];
        }
    }else{
         self.electricImg.image = [UIImage imageNamed:@"offLineElectric"];
    }
    NSString *text = power<0 ? Localized(@"none"): [NSString stringWithFormat:@"%d%%",power];
    [self.electricImg mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(18 * width);
    }];
    self.electricLabel.text = text;
}

-(void)makeConstraints
{
    CGFloat supViewHeight = self.cateye.gw.model.isAdmin.intValue == 2 ? 260/2 : 260;
    [self.bottomSupView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(15);
        make.right.mas_equalTo(self.view.mas_right).offset(-15);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-KDSSSALE_HEIGHT(14));
        make.height.mas_equalTo(KDSSSALE_HEIGHT(supViewHeight));
    }];
    [self.topSupView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.top.mas_equalTo(0);
        make.bottom.mas_equalTo(self.bottomSupView.mas_top).offset(-15);
        
    }];
    [self.bgImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.bottom.mas_equalTo(self.bottomSupView.mas_top).offset(-25);
    }];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(kStatusBarHeight);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(44);
        make.left.mas_equalTo(self.view.mas_left).offset(0);
    }];
    [self.navigationLabelTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kStatusBarHeight + 11);
        make.left.mas_equalTo(self.view.mas_left).offset(50);
        make.right.mas_equalTo(self.view.mas_right).offset(-50);
    }];
    //竖线
    [self.line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(0.5);
        make.top.mas_equalTo(self.bottomSupView.mas_top).offset(0);
        make.bottom.mas_equalTo(self.bottomSupView.mas_bottom).offset(0);
        make.centerX.mas_equalTo(self.bottomSupView.mas_centerX).offset(0);
      
    }];
    //横线
    [self.line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.5);
        make.left.mas_equalTo(self.bottomSupView.mas_left).offset(0);
        make.right.mas_equalTo(self.bottomSupView.mas_right).offset(0);
        make.centerY.mas_equalTo(self.bottomSupView.mas_centerY).offset(0);
    }];
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(0);
        make.width.mas_equalTo((KDSScreenWidth-31)/2);
        make.height.mas_equalTo(KDSSSALE_HEIGHT(259/2));
    }];
    [self.shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.mas_equalTo(0);
        make.width.mas_equalTo((KDSScreenWidth-31)/2);
        make.height.mas_equalTo(KDSSSALE_HEIGHT(259/2));
    }];
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        if (self.cateye.gw.model.isAdmin.integerValue == 2) {
            make.top.right.mas_equalTo(0);
            make.width.mas_equalTo((KDSScreenWidth-31)/2);
            make.height.mas_equalTo(KDSSSALE_HEIGHT(259/2));
        }else{
            make.left.bottom.mas_equalTo(0);
            make.width.mas_equalTo((KDSScreenWidth-31)/2);
            make.height.mas_equalTo(KDSSSALE_HEIGHT(259/2));
        }
        
    }];
    CGFloat rate = kScreenHeight / 667;
    rate = rate<1 ? rate : 1;
    [self.catEyeStatusImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(178 * rate));
        make.height.equalTo(@(169 * rate));
        make.top.mas_equalTo(self.topSupView.mas_top).offset(KDSSSALE_HEIGHT(98));
        make.centerX.mas_equalTo(self.topSupView.mas_centerX).offset(0);
    }];
    [self.deviceFunctionSupview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(15);
        make.width.mas_equalTo(160);
        make.bottom.mas_equalTo(self.topSupView.mas_bottom).offset(-30);
        make.centerX.mas_equalTo(self.topSupView.mas_centerX).offset(0);
    }];
    [self.abroadElectricImg mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(23);
        make.height.mas_equalTo(13);
        make.left.mas_equalTo(self.deviceFunctionSupview.mas_left).offset(0);
        make.centerY.mas_equalTo(self.deviceFunctionSupview.mas_centerY).offset(0);
    }];
    [self.electricImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(18);
        make.height.mas_equalTo(10);
        make.left.mas_equalTo(self.deviceFunctionSupview.mas_left).offset(1);
        make.centerY.mas_equalTo(self.deviceFunctionSupview.mas_centerY).offset(0);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(13);
        make.right.mas_equalTo(self.deviceFunctionSupview.mas_right).offset(0);
        make.centerY.mas_equalTo(self.deviceFunctionSupview.mas_centerY).offset(0);
    }];
    [self.electricLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(35);
        make.height.mas_equalTo(13);
        make.left.mas_equalTo(self.abroadElectricImg.mas_right).offset(13);
        make.centerY.mas_equalTo(self.deviceFunctionSupview.mas_centerY).offset(0);
    }];
    [self.modelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.navigationLabelTitle.mas_bottom).offset(20);
        make.centerX.mas_equalTo(self.topSupView.mas_centerX).offset(0);
        make.height.mas_equalTo(15);
    }];
    [self.cateEyeStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(13);
        make.top.mas_equalTo(self.catEyeStatusImg.mas_bottom).offset(10);
        make.centerX.mas_equalTo(self.topSupView.mas_centerX).offset(0);
        
    }];
    [self.cateEyeIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(24);
        make.height.mas_equalTo(29);
        make.centerX.mas_equalTo(self.catEyeStatusImg.mas_centerX).offset(0);
        make.centerY.mas_equalTo(self.catEyeStatusImg.mas_centerY).offset(-20);
    }];
    [self.cateEyeWithinStatusImgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.cateEyeIcon.mas_bottom).offset(KDSSSALE_HEIGHT(22));
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(13);
        make.centerX.mas_equalTo(self.catEyeStatusImg.mas_centerX).offset(0);
    }];
    
}

#pragma mark Lazy load

-(UIView *)topSupView
{
    if (!_topSupView) {
        _topSupView = ({
            UIView * tView = [UIView new];
            tView;
        });
    }
    return _topSupView;
}
- (UIView *)bottomSupView
{
    if (!_bottomSupView) {
        _bottomSupView = ({
            UIView * bView = [UIView new];
            bView.backgroundColor = UIColor.whiteColor;
            bView.layer.masksToBounds = YES;
            bView.layer.cornerRadius = 4;
            bView.layer.shadowRadius = 6;
            bView.layer.shadowOpacity = 1;
            bView;
        });
    }
    return _bottomSupView;
}

-(UIImageView *)bgImg
{
    if (!_bgImg) {
        _bgImg = ({
            UIImageView * img = [UIImageView new];
//            img.image = [UIImage imageNamed:@"topBgImgIcon"];
            img.backgroundColor = KDSRGBColor(18, 140, 238);
            img;
            
        });
    }
    return _bgImg;
}

-(UIImageView *)catEyeStatusImg
{
    if (!_catEyeStatusImg) {
        _catEyeStatusImg = ({
            UIImageView * cateImg = [UIImageView new];
            cateImg.image = [UIImage imageNamed:@"Cat eyes online_bg"];
            cateImg.backgroundColor = UIColor.clearColor;
            cateImg.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickSeeOutDoor:)];
            [cateImg addGestureRecognizer:tap];
            cateImg;
        });
    }
    return _catEyeStatusImg;
}
- (UIImageView *)electricImg
{
    if (!_electricImg) {
        _electricImg = ({
            UIImageView * eImg = [UIImageView new];
            eImg.image = [UIImage imageNamed:@"onLineElectric"];
            eImg.layer.cornerRadius = 1;
            eImg;
        });
    }
    return _electricImg;
}
-(UIImageView *)abroadElectricImg
{
    if (!_abroadElectricImg) {
        
        _abroadElectricImg = [UIImageView new];
        _abroadElectricImg.image = [UIImage imageNamed:@"Battery exterior"];
    }
    return _abroadElectricImg;
}
- (UILabel *)electricLabel
{
    if (!_electricLabel) {
        _electricLabel = ({
            UILabel * eLb = [UILabel new];
            eLb.textColor = UIColor.whiteColor;
            eLb.font = [UIFont systemFontOfSize:12];
            eLb.textAlignment = NSTextAlignmentCenter;
            eLb.text = @"100%";
            eLb;
        });
    }
    return _electricLabel;
}
- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = ({
            UILabel * tLb = [UILabel new];
            tLb.textAlignment = NSTextAlignmentRight;
            tLb.font = [UIFont systemFontOfSize:11];
            tLb.textColor = KDSRGBColor(163, 241, 255);
            tLb.text = @"2018/11/25";
            tLb;
        });
    }
    return _timeLabel;
}
-(UILabel *)modelLabel
{
    if (!_modelLabel) {
        _modelLabel = ({
            UILabel * mLb = [UILabel new];
            mLb.backgroundColor = UIColor.clearColor;
            mLb.font = [UIFont systemFontOfSize:15];
            mLb.textColor = UIColor.whiteColor;
            mLb.textAlignment = NSTextAlignmentCenter;
            mLb.text = @"DL-K9";
            mLb;
            
        });
    }
    return _modelLabel;
}

-(UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = ({
            UIButton * backB = [UIButton buttonWithType:UIButtonTypeCustom];
            backB.backgroundColor = UIColor.clearColor;
            [backB setImage:[UIImage imageNamed:@"whiteBack"] forState:UIControlStateNormal];
            [backB addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
            backB;
        });
    }
    return _backBtn;
}

- (UILabel *)navigationLabelTitle
{
    if (!_navigationLabelTitle) {
        _navigationLabelTitle = ({
            UILabel * lb = [UILabel new];
            lb.textColor = UIColor.whiteColor;
            lb.backgroundColor = UIColor.clearColor;
            lb.font = [UIFont fontWithName:@"PingFang-SC-Heavy" size:17];
            lb.textAlignment = NSTextAlignmentCenter;
            lb;
        });
    }
    return _navigationLabelTitle;
}
- (UIView *)line1
{
    if (!_line1) {
        _line1  = ({
            UIView * line = [UIView new];
            line.backgroundColor = KDSRGBColor(242, 242, 242);
            line;
        });
    }
    return _line1;
}
- (UIView *)line2
{
    if (!_line2) {
        _line2 = [UIView new];
        _line2.backgroundColor = KDSRGBColor(242, 242, 242);
        _line2.hidden = self.cateye.gw.model.isAdmin.intValue == 2 ? YES : NO;
    }
    return _line2;
}
-(UIView *)deviceFunctionSupview
{
    if (!_deviceFunctionSupview) {
        _deviceFunctionSupview = ({
            UIView * funcView = [UIView new];
            funcView.backgroundColor = UIColor.clearColor;
            funcView;
        });
    }
    return _deviceFunctionSupview;
}
- (UILabel *)cateEyeStatusLabel
{
    if (!_cateEyeStatusLabel) {
        _cateEyeStatusLabel = ({
            UILabel * elb = [UILabel new];
            elb.textAlignment = NSTextAlignmentCenter;
            elb.font = [UIFont systemFontOfSize:10];
            elb.textColor = KDSRGBColor(163, 241, 255);
            elb.text = @"猫眼在线";
            elb;
        });
    }
    return _cateEyeStatusLabel;
}

- (UILabel *)cateEyeWithinStatusImgLabel
{
    if (!_cateEyeWithinStatusImgLabel) {
        _cateEyeWithinStatusImgLabel = ({
            UILabel * wlb = [UILabel new];
            wlb.textAlignment = NSTextAlignmentCenter;
            wlb.font = [UIFont systemFontOfSize:11];
            wlb.textColor = UIColor.whiteColor;
            wlb.text = @"点击查看门外";
            wlb;
        });
    }
    return _cateEyeWithinStatusImgLabel;
}

- (UIImageView *)cateEyeIcon
{
    if (!_cateEyeIcon) {
        _cateEyeIcon = ({
            UIImageView * icon = [UIImageView new];
            icon.image = [UIImage imageNamed:@"cat eye white 拷贝"];
            icon.contentMode = UIViewContentModeScaleAspectFit;
            icon;
        });
    }
    return _cateEyeIcon;
}

- (UIButton *)moreBtn
{
    if (!_moreBtn) {
        _moreBtn = [UIButton new];
        [_moreBtn setTitle:Localized(@"more") forState:UIControlStateNormal];
        [_moreBtn setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
        [_moreBtn addTarget:self action:@selector(moreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_moreBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        _moreBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        CGFloat    imageHeight = _moreBtn.currentImage.size.height;
        CGFloat    imageWidth = _moreBtn.currentImage.size.width;
        CGFloat    titleHeight = [_moreBtn.currentTitle sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].height;
        CGFloat titleWidth = [_moreBtn.currentTitle sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width;
        CGFloat    space = 13;// 图片和文字的间距
        [_moreBtn setImageEdgeInsets:UIEdgeInsetsMake(-(imageHeight*0.5 + space*0.5), titleWidth*0.5, imageHeight*0.5 + space*0.5, -titleWidth*0.5)];
        [_moreBtn setTitleEdgeInsets:UIEdgeInsetsMake(titleHeight*0.5 + space*0.5, -imageWidth*0.5, -(titleHeight*0.5 + space*0.5), imageWidth*0.5)];
        
    }
    return _moreBtn;
}
- (UIButton *)playBtn
{
    if (!_playBtn) {
        _playBtn = [UIButton new];
        [_playBtn setTitle:Localized(@"PlayBack") forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"Playback_icon"] forState:UIControlStateNormal];
        [_playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_playBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        _playBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        CGFloat    imageHeight = _playBtn.currentImage.size.height;
        CGFloat    imageWidth = _playBtn.currentImage.size.width;
        CGFloat    titleHeight = [_playBtn.currentTitle sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].height;
        CGFloat titleWidth = [_playBtn.currentTitle sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width;
        CGFloat    space = 13;// 图片和文字的间距
        [_playBtn setImageEdgeInsets:UIEdgeInsetsMake(-(imageHeight*0.5 + space*0.5), titleWidth*0.5, imageHeight*0.5 + space*0.5, -titleWidth*0.5)];
        [_playBtn setTitleEdgeInsets:UIEdgeInsetsMake(titleHeight*0.5 + space*0.5, -imageWidth*0.5, -(titleHeight*0.5 + space*0.5), imageWidth*0.5)];
    }
    return _playBtn;
}
- (UIButton *)shareBtn
{
    if (!_shareBtn) {
        _shareBtn = [UIButton new];
        [_shareBtn setTitle:Localized(@"deviceShare") forState:UIControlStateNormal];
        [_shareBtn setImage:[UIImage imageNamed:@"shareHeightImg"] forState:UIControlStateNormal];
        [_shareBtn addTarget:self action:@selector(shareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_shareBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        _shareBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        _shareBtn.hidden = self.cateye.gw.model.isAdmin.intValue == 2 ? YES :NO;
        CGFloat    imageHeight = _shareBtn.currentImage.size.height;
        CGFloat    imageWidth = _shareBtn.currentImage.size.width;
        CGFloat    titleHeight = [_shareBtn.currentTitle sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].height;
        CGFloat titleWidth = [_shareBtn.currentTitle sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width;
        CGFloat    space = 13;// 图片和文字的间距
        [_shareBtn setImageEdgeInsets:UIEdgeInsetsMake(-(imageHeight*0.5 + space*0.5), titleWidth*0.5, imageHeight*0.5 + space*0.5, -titleWidth*0.5)];
        [_shareBtn setTitleEdgeInsets:UIEdgeInsetsMake(titleHeight*0.5 + space*0.5, -imageWidth*0.5, -(titleHeight*0.5 + space*0.5), imageWidth*0.5)];
    }
    
    return _shareBtn;
}

#pragma mark 控件手势事件
///点击返回按钮。
-(void)backClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
///点击了查看门外。
-(void)clickSeeOutDoor:(UIGestureRecognizer *)tap{
    NSLog(@"点击了查看门外");
    KDSCateyeCallVC *vc = [[KDSCateyeCallVC alloc] init];
    vc.gatewayDeviceModel = self.cateye.gatewayDeviceModel;
    [self.navigationController pushViewController:vc animated:YES];
}
///回放。
-(void)playBtnClick:(UIButton *)sender
{
    KDSCatEyePlaybackVC * vc = [KDSCatEyePlaybackVC new];
    vc.gatewayDeviceModel = self.cateye.gatewayDeviceModel;
    [self.navigationController pushViewController:vc animated:YES];
}
///设备共享:猫眼
-(void)shareBtnClick:(UIButton *)sender
{
    KDSLockKeyVC *vc = [KDSLockKeyVC new];
    vc.catEye = self.cateye;
    [self.navigationController pushViewController:vc animated:YES];
}
///更多。
-(void)moreBtnClick:(UIButton *)sender
{
    KDSCatEyeMoreSettingVC * vc = [KDSCatEyeMoreSettingVC new];
    vc.cateye = self.cateye;
    vc.gatewayModel = self.gatewayModel;
    vc.gatewayDeviceModel = self.gatewayDeviceModel;
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [navigationController setNavigationBarHidden:YES animated:YES];//!iOS 9
}

#pragma mark 通知
///当设备的数量或者各种状态等改变时，刷新本页面的设备状态。
- (void)refreshInterfaceWhenDeviceDidSync:(NSNotification *)noti
{
    [self refreshUI];
}
///猫眼获取电量值改变是，刷新猫眼电量
-(void)refreshInterCateyePower:(NSNotification *)noti
{
     [self setDevicePowerInfo:self.cateye.powerStr];
}
-(void)pirPhotoUpdate:(NSNotification *)notification{
    [self refreshPlayBackImgBadge];
}
-(void)dealloc{
    NSLog(@"KDSCatEyeDetailsVC执行了dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
