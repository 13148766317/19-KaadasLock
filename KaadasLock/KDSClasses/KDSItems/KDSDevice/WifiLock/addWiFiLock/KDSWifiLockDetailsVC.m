//
//  KDSWifiLockDetailsVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/12/13.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSWifiLockDetailsVC.h"
#import "KDSWifiLockPwdListVC.h"
#import "KDSHttpManager+User.h"
#import "KDSDBManager.h"
#import "MBProgressHUD+MJ.h"
#import "UIButton+Color.h"
#import "KDSLockKeyVC.h"
#import "KDSWIfiLockMoreSettingVC.h"
#import "KDSWifiLockPwdShareVC.h"
#import "KDSHttpManager+WifiLock.h"
#import "KDSAllPhotoShowImgModel.h"


@interface KDSWifiLockDetailsVC ()<UINavigationControllerDelegate>

///导航栏位置的标题标签。
@property (nonatomic, weak) UILabel *titleLabel;
///锁型号标签。
@property (nonatomic, weak) UILabel *modelLabel;
///显示电量图片、电量和日期的按钮，设置这些属性时使用方法setPowerWithImage:power:date:@see setPowerWithImage:power:date:
@property (nonatomic, weak) UIButton *powerInfoBtn;
///电量内框图片。
@property (nonatomic, strong) UIImageView *powerIV;
///wifi锁的锁型号
@property (nonatomic, strong) UILabel * WifiLockModel;
///临时密码数量标签。
@property (nonatomic, strong) UILabel * tempPwdQuantityLabel;
///密码数量标签。
@property (nonatomic, weak) UILabel *pwdQuantityLabel;
///指纹数量标签。
@property (nonatomic, weak) UILabel *fpQuantityLabel;
///卡片数量标签。
@property (nonatomic, weak) UILabel *cardQuantityLabel;
///共享成员数量标签。
@property (nonatomic, weak) UILabel *memberQuantityLabel;
///上个导航控制器的代理。
@property (nonatomic, weak) id<UINavigationControllerDelegate> preDelegate;


@end

@implementation KDSWifiLockDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.preDelegate = self.navigationController.delegate;
    self.navigationController.delegate = self;
    self.titleLabel.text = self.lock.wifiDevice.lockNickname ?: self.lock.wifiDevice.wifiSN;
    [self getAllKeys];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.delegate = self.preDelegate;
}

- (void)setupUI
{
    UIImageView *bgIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBg"]];
    bgIV.frame = self.view.bounds;
    [self.view addSubview:bgIV];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"whiteBack"] forState:UIControlStateNormal];
    backBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    backBtn.frame = CGRectMake(0, kStatusBarHeight, 44, 44);
    [backBtn addTarget:self action:@selector(backBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.textColor = UIColor.whiteColor;
    titleLabel.text = self.lock.device.lockNickName;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kStatusBarHeight + 11);
        make.centerX.equalTo(self.view);
        make.left.mas_equalTo(self.view.mas_left).offset(30);
        make.right.mas_equalTo(self.view.mas_right).offset(-30);
    }];
    
    ///锁型号对应的图片
    [KDSAllPhotoShowImgModel shareModel].device = self.lock.wifiDevice;
    KDSWifiLockModel * wifiDevModel = self.lock.wifiDevice;
    UIImageView *lockIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lock_pic"]];
    for (NSString * imgName in [[KDSAllPhotoShowImgModel shareModel].adminImgName allKeys]) {
        if ([imgName isEqualToString:self.lock.wifiDevice.productModel]) {
            if ([[[KDSAllPhotoShowImgModel shareModel].adminImgName objectForKey:self.lock.wifiDevice.productModel] hasPrefix:@"http://"]) {
                NSLog(@"设备列表图片下载地址：%@",[KDSAllPhotoShowImgModel shareModel].adminImgName);
                [[KDSAllPhotoShowImgModel shareModel] getDeviceImgWithImgName:[[KDSAllPhotoShowImgModel shareModel].adminImgName objectForKey:self.lock.wifiDevice.productModel] completion:^(UIImage * _Nullable image) {
                    if (image) {
                        lockIV.image = image;
                    }
                }];
            }else{
                lockIV.image = [UIImage imageNamed:[[KDSAllPhotoShowImgModel shareModel].adminImgName objectForKey:self.lock.wifiDevice.productModel]];
            }
        }
    }
    [self.view insertSubview:lockIV belowSubview:titleLabel];
    [lockIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel).offset(kScreenHeight<667 ? 12 : 60);
        make.centerX.equalTo(self.view);
        make.width.height.equalTo(@(kScreenHeight<=667 ? 200 : 236));
    }];
    UILabel *modelLabel = [UILabel new];
    modelLabel.font = [UIFont systemFontOfSize:13];
    modelLabel.textColor = UIColor.whiteColor;
    modelLabel.textAlignment = NSTextAlignmentCenter;
    //modelLabel.text = [NSString stringWithFormat:@"%@：%@", Localized(@"lockModel"), self.lock.device.model];
    NSString *m = wifiDevModel.productModel;
    NSRange range = [self.lock.device.model rangeOfString:@"V" options:NSBackwardsSearch];
    if (range.location != NSNotFound)
    {
        m = [m substringToIndex:range.location];
    }
    /*range = [model rangeOfString:@"0"];
     if (range.location != NSNotFound)
     {
     model = [model substringToIndex:range.location];
     }*/
    m = m.length>5 ? [m substringToIndex:5] : m;
    modelLabel.text = m;
    for (NSString * productModel in [[KDSAllPhotoShowImgModel shareModel].productModel allKeys]) {
        if ([productModel isEqualToString:m]) {
            modelLabel.text = [[KDSAllPhotoShowImgModel shareModel].productModel objectForKey:m];
            break;
        }
    }
    self.modelLabel = modelLabel;
    self.modelLabel.hidden = YES;
    [self.view addSubview:modelLabel];
    [modelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(lockIV).offset(0);
        make.centerX.equalTo(self.view);
        make.left.mas_equalTo(self.view.mas_left).offset(30);
        make.right.mas_equalTo(self.view.mas_right).offset(-30);
    }];
    
    UIView * modelAndPowerSupView = [UIView new];
    modelAndPowerSupView.backgroundColor = UIColor.clearColor;
    [self.view addSubview:modelAndPowerSupView];
    [modelAndPowerSupView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_bottom).offset(-(KDSSSALE_WIDTH(260) + 65));
        make.left.mas_equalTo(self.view.mas_left).offset(KDSSSALE_WIDTH(30));
        make.right.mas_equalTo(self.view.mas_right).offset(-KDSSSALE_WIDTH(30));
        make.height.equalTo(@20);
    }];
    
    UIButton *powerInfoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    powerInfoBtn.enabled = NO;
    self.powerInfoBtn = powerInfoBtn;
    powerInfoBtn.backgroundColor = UIColor.clearColor;
    [modelAndPowerSupView addSubview:powerInfoBtn];
    [powerInfoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_bottom).offset(-(KDSSSALE_WIDTH(260) + 65));
        make.right.mas_equalTo(modelAndPowerSupView.mas_right).offset(0);
        make.width.equalTo(@200);
        make.height.equalTo(@12);
    }];
    self.powerIV = [UIImageView new];
    self.powerIV.layer.masksToBounds = YES;
    self.powerIV.layer.cornerRadius = 1;
    [self.powerInfoBtn addSubview:self.powerIV];
    [self.powerIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(powerInfoBtn.imageView).offset(1.5);
        make.width.equalTo(@17);
        make.bottom.equalTo(powerInfoBtn.imageView).offset(-1.5);
    }];
    [self setPowerWithImage:nil power:self.lock.wifiDevice.power date:nil];
    
    UILabel * WifiLockModel = [UILabel new];
    WifiLockModel.backgroundColor = UIColor.clearColor;
    if ([self.lock.wifiDevice.productModel isEqualToString:@"K13"]) {
        WifiLockModel.text = [NSString stringWithFormat:@"%@：%@", Localized(@"lockModel"), @"兰博基尼传奇"];
    }else{
        WifiLockModel.text = [NSString stringWithFormat:@"%@：%@", Localized(@"lockModel"), self.lock.wifiDevice.productModel];
        for (NSString * productModel in [[KDSAllPhotoShowImgModel shareModel].productModel allKeys]) {
            if ([productModel isEqualToString:m]) {
                WifiLockModel.text = [NSString stringWithFormat:@"%@：%@", Localized(@"lockModel"), [[KDSAllPhotoShowImgModel shareModel].productModel objectForKey:self.lock.wifiDevice.productModel]];
                break;
            }
        }
    }
    WifiLockModel.textColor = UIColor.whiteColor;
    WifiLockModel.font = [UIFont systemFontOfSize:13];
    WifiLockModel.textAlignment = NSTextAlignmentLeft;
    self.WifiLockModel = WifiLockModel;
    [modelAndPowerSupView addSubview:WifiLockModel];
    [WifiLockModel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_bottom).offset(-(KDSSSALE_WIDTH(260) + 65));
        make.left.mas_equalTo(modelAndPowerSupView.mas_left).offset(0);
        make.right.mas_equalTo(powerInfoBtn.mas_left).offset(KDSSSALE_WIDTH(-30));
        make.height.equalTo(@12);
    }];
    
    UIView *grayView = [UIView new];
    grayView.backgroundColor = KDSRGBColor(0xf2, 0xf2, 0xf2);
    [self.view addSubview:grayView];
    [grayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.height.mas_equalTo(260 * kScreenWidth / 375.0 + 29);
    }];
    UIView *cornerView = [UIView new];
    cornerView.backgroundColor = UIColor.whiteColor;
    cornerView.layer.cornerRadius = 4;
    cornerView.clipsToBounds = YES;
    [grayView addSubview:cornerView];
    [cornerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(grayView).offset(12);
        make.left.equalTo(grayView).offset(15);
        make.bottom.equalTo(grayView).offset(-17);
        make.right.equalTo(grayView).offset(-15);
    }];
    if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@7] && [KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@8] && [KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@9]) {
        //指密卡都支持
        //tempPassword
        UIView *tempPassword = [self createSubfuncViewWithImageName:@"password" subfunc:Localized(@"tempPassword") quantity:@"" columnNumber:3 tapAction:@selector(tapTempPwdSubfuncViewAction:)];
        self.tempPwdQuantityLabel = [tempPassword viewWithTag:3];
        [cornerView addSubview:tempPassword];
        [tempPassword mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(cornerView);
            make.size.mas_equalTo(tempPassword.bounds.size);
        }];
        
        UIView *hLineView = [UIView new];
        hLineView.backgroundColor = KDSRGBColor(0xf2, 0xf2, 0xf2);
        [cornerView addSubview:hLineView];
        [hLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(cornerView);
            make.top.equalTo(tempPassword.mas_bottom);
            make.height.equalTo(@1);
        }];
        
        UIView *vLineView1 = [UIView new];
        vLineView1.backgroundColor = KDSRGBColor(0xf2, 0xf2, 0xf2);
        [cornerView addSubview:vLineView1];
        [vLineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(tempPassword.mas_right);
            make.top.bottom.equalTo(cornerView);
            make.width.equalTo(@1);
        }];
        //password
        UIView *pwdView = [self createSubfuncViewWithImageName:@"password" subfunc:Localized(@"password") quantity:@"(0组)" columnNumber:3 tapAction:@selector(tapPwdSubfuncViewAction:)];
        self.pwdQuantityLabel = [pwdView viewWithTag:3];
        [cornerView addSubview:pwdView];
        [pwdView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cornerView);
            make.left.equalTo(vLineView1.mas_right);
            make.size.mas_equalTo(pwdView.bounds.size);
        }];
        
        UIView *vLineView2 = [UIView new];
        vLineView2.backgroundColor = KDSRGBColor(0xf2, 0xf2, 0xf2);
        [cornerView addSubview:vLineView2];
        [vLineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(pwdView.mas_right);
            make.top.bottom.equalTo(cornerView);
            make.width.equalTo(@1);
        }];
        //fingerprint
        UIView *fpView = [self createSubfuncViewWithImageName:@"fingerprint" subfunc:Localized(@"fingerprint") quantity:@"(0组)" columnNumber:3 tapAction:@selector(tapFingerprintSubfuncViewAction:)];
        self.fpQuantityLabel = [fpView viewWithTag:3];
        [cornerView addSubview:fpView];
        [fpView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cornerView);
            make.left.equalTo(vLineView2.mas_right);
            make.size.mas_equalTo(fpView.bounds.size);
        }];
        //card
        UIView *cardView = [self createSubfuncViewWithImageName:@"card" subfunc:Localized(@"card") quantity:@"(0张)" columnNumber:3 tapAction:@selector(tapCardSubfuncViewAction:)];
        self.cardQuantityLabel = [cardView viewWithTag:3];
        [cornerView addSubview:cardView];
        [cardView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.equalTo(cornerView);
            make.size.mas_equalTo(cardView.bounds.size);
        }];
        //memberShare
        UIView *memberShareView = [self createSubfuncViewWithImageName:@"memberShare" subfunc:Localized(@"deviceShare") quantity:@"(0台)" columnNumber:3 tapAction:@selector(tapDeviceShareSubfuncViewAction:)];
        self.memberQuantityLabel = [memberShareView viewWithTag:3];
        [cornerView addSubview:memberShareView];
        [memberShareView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(cornerView);
            make.left.equalTo(vLineView1.mas_right);
            make.size.mas_equalTo(memberShareView.bounds.size);
        }];
        //more
        UIView *moreView = [self createSubfuncViewWithImageName:@"more" subfunc:Localized(@"more") quantity:@"" columnNumber:3 tapAction:@selector(tapMoreSubfuncViewAction:)];
        [cornerView addSubview:moreView];
        [moreView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(cornerView);
            make.left.equalTo(vLineView2.mas_right);
            make.size.mas_equalTo(moreView.bounds.size);
        }];
        return;
    }if (![KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@9]) {
        //密码+指纹
        //tempPassword
        UIView *tempPassword = [self createSubfuncViewWithImageName:@"password" subfunc:Localized(@"tempPassword") quantity:@"" columnNumber:3 tapAction:@selector(tapTempPwdSubfuncViewAction:)];
        self.tempPwdQuantityLabel = [tempPassword viewWithTag:3];
        [cornerView addSubview:tempPassword];
        [tempPassword mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(cornerView);
            make.size.mas_equalTo(tempPassword.bounds.size);
        }];
        
        UIView *hLineView = [UIView new];
        hLineView.backgroundColor = KDSRGBColor(0xf2, 0xf2, 0xf2);
        [cornerView addSubview:hLineView];
        [hLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(cornerView);
            make.top.equalTo(tempPassword.mas_bottom);
            make.height.equalTo(@1);
        }];
        
        UIView *vLineView1 = [UIView new];
        vLineView1.backgroundColor = KDSRGBColor(0xf2, 0xf2, 0xf2);
        [cornerView addSubview:vLineView1];
        [vLineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(tempPassword.mas_right);
            make.top.bottom.equalTo(cornerView);
            make.width.equalTo(@1);
        }];
        //password
        UIView *pwdView = [self createSubfuncViewWithImageName:@"password" subfunc:Localized(@"password") quantity:@"(0组)" columnNumber:3 tapAction:@selector(tapPwdSubfuncViewAction:)];
        self.pwdQuantityLabel = [pwdView viewWithTag:3];
        [cornerView addSubview:pwdView];
        [pwdView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cornerView);
            make.left.equalTo(vLineView1.mas_right);
            make.size.mas_equalTo(pwdView.bounds.size);
        }];
        
        UIView *vLineView2 = [UIView new];
        vLineView2.backgroundColor = KDSRGBColor(0xf2, 0xf2, 0xf2);
        [cornerView addSubview:vLineView2];
        [vLineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(pwdView.mas_right);
            make.top.bottom.equalTo(cornerView);
            make.width.equalTo(@1);
        }];
        //fingerprint
        UIView *fpView = [self createSubfuncViewWithImageName:@"fingerprint" subfunc:Localized(@"fingerprint") quantity:@"(0组)" columnNumber:3 tapAction:@selector(tapFingerprintSubfuncViewAction:)];
        self.fpQuantityLabel = [fpView viewWithTag:3];
        [cornerView addSubview:fpView];
        [fpView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cornerView);
            make.left.equalTo(vLineView2.mas_right);
            make.size.mas_equalTo(fpView.bounds.size);
        }];
        //memberShare
        UIView *memberShareView = [self createSubfuncViewWithImageName:@"memberShare" subfunc:Localized(@"deviceShare") quantity:@"(0台)" columnNumber:3 tapAction:@selector(tapDeviceShareSubfuncViewAction:)];
        self.memberQuantityLabel = [memberShareView viewWithTag:3];
        [cornerView addSubview:memberShareView];
        [memberShareView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.equalTo(cornerView);
            make.size.mas_equalTo(memberShareView.bounds.size);
            
        }];
        //more
        UIView *moreView = [self createSubfuncViewWithImageName:@"more" subfunc:Localized(@"more") quantity:@"" columnNumber:3 tapAction:@selector(tapMoreSubfuncViewAction:)];
        [cornerView addSubview:moreView];
        [moreView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(cornerView);
            make.left.equalTo(memberShareView.mas_right);
            make.size.mas_equalTo(moreView.bounds.size);
        }];
        return;
    }if (![KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@8]) {
        //密码+卡片
        //tempPassword
        UIView *tempPassword = [self createSubfuncViewWithImageName:@"password" subfunc:Localized(@"tempPassword") quantity:@"" columnNumber:3 tapAction:@selector(tapTempPwdSubfuncViewAction:)];
        self.tempPwdQuantityLabel = [tempPassword viewWithTag:3];
        [cornerView addSubview:tempPassword];
        [tempPassword mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(cornerView);
            make.size.mas_equalTo(tempPassword.bounds.size);
        }];
        
        UIView *hLineView = [UIView new];
        hLineView.backgroundColor = KDSRGBColor(0xf2, 0xf2, 0xf2);
        [cornerView addSubview:hLineView];
        [hLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(cornerView);
            make.top.equalTo(tempPassword.mas_bottom);
            make.height.equalTo(@1);
        }];
        
        UIView *vLineView1 = [UIView new];
        vLineView1.backgroundColor = KDSRGBColor(0xf2, 0xf2, 0xf2);
        [cornerView addSubview:vLineView1];
        [vLineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(tempPassword.mas_right);
            make.top.bottom.equalTo(cornerView);
            make.width.equalTo(@1);
        }];
        //password
        UIView *pwdView = [self createSubfuncViewWithImageName:@"password" subfunc:Localized(@"password") quantity:@"(0组)" columnNumber:3 tapAction:@selector(tapPwdSubfuncViewAction:)];
        self.pwdQuantityLabel = [pwdView viewWithTag:3];
        [cornerView addSubview:pwdView];
        [pwdView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cornerView);
            make.left.equalTo(vLineView1.mas_right);
            make.size.mas_equalTo(pwdView.bounds.size);
        }];
        
        UIView *vLineView2 = [UIView new];
        vLineView2.backgroundColor = KDSRGBColor(0xf2, 0xf2, 0xf2);
        [cornerView addSubview:vLineView2];
        [vLineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(pwdView.mas_right);
            make.top.bottom.equalTo(cornerView);
            make.width.equalTo(@1);
        }];
        //card
        UIView *cardView = [self createSubfuncViewWithImageName:@"card" subfunc:Localized(@"card") quantity:@"(0张)" columnNumber:3 tapAction:@selector(tapCardSubfuncViewAction:)];
        self.cardQuantityLabel = [cardView viewWithTag:3];
        [cornerView addSubview:cardView];
        [cardView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cornerView);
            make.left.equalTo(vLineView2.mas_right);
            make.size.mas_equalTo(cardView.bounds.size);
        }];
        //memberShare
        UIView *memberShareView = [self createSubfuncViewWithImageName:@"memberShare" subfunc:Localized(@"deviceShare") quantity:@"(0台)" columnNumber:3 tapAction:@selector(tapDeviceShareSubfuncViewAction:)];
        self.memberQuantityLabel = [memberShareView viewWithTag:3];
        [cornerView addSubview:memberShareView];
        [memberShareView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.equalTo(cornerView);
            make.size.mas_equalTo(memberShareView.bounds.size);
            
        }];
        //more
        UIView *moreView = [self createSubfuncViewWithImageName:@"more" subfunc:Localized(@"more") quantity:@"" columnNumber:3 tapAction:@selector(tapMoreSubfuncViewAction:)];
        [cornerView addSubview:moreView];
        [moreView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(cornerView);
            make.left.equalTo(memberShareView.mas_right);
            make.size.mas_equalTo(moreView.bounds.size);
        }];
        return;
    }
    
}


///创建子功能视图。
- (UIView *)createSubfuncViewWithImageName:(NSString *)name subfunc:(NSString *)title quantity:(NSString *)quantity columnNumber:(int)columnNumber tapAction:(SEL)action
{
    CGFloat height = (260 * kScreenWidth / 375.0 - 1) / 2.0;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (kScreenWidth - 32) / columnNumber, height)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:action];
    [view addGestureRecognizer:tap];
    
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [view addSubview:iv];
    CGFloat top = (height - (129 - 53)) / 53.0 * 30;
    [iv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view).offset(top);
        make.centerX.equalTo(@0);
        make.width.height.equalTo(@30);
    }];
    
    UILabel *subfuncLabel = [UILabel new];
    subfuncLabel.text = title;
    subfuncLabel.font = [UIFont systemFontOfSize:13];
    subfuncLabel.textAlignment = NSTextAlignmentCenter;
    subfuncLabel.textColor = KDSRGBColor(0x33, 0x33, 0x33);
    [view addSubview:subfuncLabel];
    [subfuncLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(iv.mas_bottom).offset(10);
        make.centerX.equalTo(@0);
    }];
    
    UILabel *quantityLabel = [UILabel new];
    quantityLabel.tag = 3;
    quantityLabel.text = quantity;
    quantityLabel.font = [UIFont systemFontOfSize:12];
    quantityLabel.textAlignment = NSTextAlignmentCenter;
    quantityLabel.textColor = KDSRGBColor(0x99, 0x99, 0x99);
    [view addSubview:quantityLabel];
    [quantityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(iv.mas_bottom).offset(32);
        make.centerX.equalTo(@0);
    }];
    
    return view;
}

/**
 *@brief 设置电量图片、电量和日期。
 *@param image 电量图片。如果为空，则根据电量进行选择。
 *@param power 电量，0-100，负数不显示.
 *@param date 日期，格式yyyy/MM/dd。如果为空，则使用手机当前时间。
 */
- (void)setPowerWithImage:(nullable UIImage *)image power:(int)power date:(nullable NSString *)date
{
    float width = power/100.0;
    if (!image)
    {
        image = [UIImage imageNamed:@"Battery exterior"];
    }
    self.powerIV.image = [UIImage imageNamed:power<20 ? @"low power" : @"onLineElectric"];
    if (!date)
    {
        //        NSDate *powerDate = [[KDSDBManager sharedManager] queryPowerTimeWithBleName:self.lock.device.lockName] ?: NSDate.date;
        NSDate *powerDate = [NSDate dateWithTimeIntervalSince1970:self.lock.wifiDevice.updateTime];
        if ([NSDate.date timeIntervalSinceDate:powerDate] < 3600)
        {
           // date = Localized(@"justNow");
            NSDateFormatter *fmt = [KDSUserManager sharedManager].dateFormatter;
            fmt.dateFormat = @"yyyy/MM/dd HH:mm";
            date = [fmt stringFromDate:powerDate];
        }
        else
        {
            NSDateFormatter *fmt = [KDSUserManager sharedManager].dateFormatter;
            fmt.dateFormat = @"yyyy/MM/dd HH:mm";
            date = [fmt stringFromDate:powerDate];
            NSArray<NSString *> *comps1 = [date componentsSeparatedByString:@" "];
            NSArray<NSString *> *comps2 = [[fmt stringFromDate:NSDate.date] componentsSeparatedByString:@" "];
            if ([comps1.firstObject isEqualToString:comps2.firstObject])
            {
                date = [Localized(@"today") stringByAppendingFormat:@" %@", comps1.lastObject];
            }
            else if ([comps1.firstObject stringByReplacingOccurrencesOfString:@"/" withString:@""].integerValue + 1 == [comps2.firstObject stringByReplacingOccurrencesOfString:@"/" withString:@""].integerValue)
            {
                date = [Localized(@"yesterday") stringByAppendingFormat:@" %@", comps1.lastObject];
            }
            else
            {
                date = comps1.firstObject;
            }
        }
    }
    [self.powerInfoBtn setImage:image forState:UIControlStateNormal];
    NSString *title = nil;
    if (power < 0)
    {
        title = [NSString stringWithFormat:@"(%@)     %@", Localized(@"none"), date];
    }
    else
    {
        title = [NSString stringWithFormat:@"%d%%     %@", power, date];
    }
    UIFont *font = [UIFont systemFontOfSize:12];
    [self.powerInfoBtn setTitle:title forState:UIControlStateNormal];
    self.powerInfoBtn.titleLabel.font = font;
    self.powerInfoBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.powerInfoBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 7, 0, 0);
    CGSize size = [title sizeWithAttributes:@{NSFontAttributeName : font}];
    [self.powerInfoBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(image.size.width + 7 + ceil(size.width)));
        make.height.equalTo(@(MAX(image.size.height, size.height)));
    }];
    [self.powerIV mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(17 * width));
    }];
}
///获取所有密匙，然后更新界面。
- (void)getAllKeys
{
    [[KDSHttpManager sharedManager] getWifiLockAuthorizedUsersWithUid:[KDSUserManager sharedManager].user.uid wifiSN:self.lock.wifiDevice.wifiSN success:^(NSArray<KDSAuthMember *> * _Nullable members) {
        
        [[KDSHttpManager sharedManager] getWifiLockPwdListWithUid:[KDSUserManager sharedManager].user.uid wifiSN:self.lock.wifiDevice.wifiSN success:^(NSArray<KDSPwdListModel *> * _Nonnull pwdList, NSArray<KDSPwdListModel *> * _Nonnull fingerprintList, NSArray<KDSPwdListModel *> * _Nonnull cardList, NSArray<KDSPwdListModel *> * _Nonnull faceList, NSArray<KDSPwdListModel *> * _Nonnull pwdNicknameArr, NSArray<KDSPwdListModel *> * _Nonnull fingerprintNicknameArr, NSArray<KDSPwdListModel *> * _Nonnull cardNicknameArr, NSArray<KDSPwdListModel *> * _Nonnull faceNicknameArr, NSArray<KDSPwdListModel *> * _Nonnull pwdDuressArr, NSArray<KDSPwdListModel *> * _Nonnull fingerprintDuressArr) {
            int pin = 0, fp = 0, card = 0, membs = 0;
            for (KDSPwdListModel *m in pwdList)
            {
                if (m.num) {
                    pin++;
                }
            }
            for (KDSPwdListModel *m in fingerprintList)
            {
                if (m.num) {
                    fp++;
                }
            }
            for (KDSPwdListModel *m in cardList)
            {
                if (m.num) {
                    card++;
                }
            }
            for (KDSAuthMember * n in members) {
                if (n.uname) {
                    membs++;
                }
            }
            [self setNumberOfPIN:pin fingerprint:fp card:card member:membs];
        } error:nil failure:nil];
    } error:nil failure:nil];
}

///设置密码、指纹、卡片、共享用户数量。负数不设置。
- (void)setNumberOfPIN:(int)pin fingerprint:(int)fp card:(int)card member:(int)members
{
    NSString *pinUnit = pin>1 ? @" groups" : @" group";
    NSString *fpUnit = fp>1 ? @" pieces" : @" piece";
    NSString *cardUnit = card>1 ? @" pieces" : @" piece";
    NSString *pUnit = members>1 ? @" persons" : @" person";
    if ([[KDSTool getLanguage] hasPrefix:JianTiZhongWen])
    {
        pinUnit = @"组";
        fpUnit = @"组";
        cardUnit = @"张";
        pUnit = @"台";
    }
    else if ([[KDSTool getLanguage] containsString:FanTiZhongWen])
    {
        pinUnit = @"組";
        fpUnit = @"組";
        cardUnit = @"張";
        pUnit = @"台";
    }
    else if ([[KDSTool getLanguage] containsString:@"th"])
    {
        pinUnit = pin>1 ? @" groups" : @" group";
        fpUnit = fp>1 ? @" pieces" : @" piece";
        cardUnit = card>1 ? @" pieces" : @" piece";
        pUnit = members>1 ? @" persons" : @" person";
    }
    
    if (pin >= 0) self.pwdQuantityLabel.text = [NSString stringWithFormat:@"(%d%@)", pin, pinUnit];
    if (fp >= 0) self.fpQuantityLabel.text = [NSString stringWithFormat:@"(%d%@)", fp, fpUnit];
    if (card >= 0) self.cardQuantityLabel.text = [NSString stringWithFormat:@"(%d%@)", card, cardUnit];
    if (members >= 0) self.memberQuantityLabel.text = [NSString stringWithFormat:@"(%d%@)", members, pUnit];
}

#pragma mark - 控件等事件方法。
///点击返回按钮。
- (void)backBtnAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
///点击离线密码子功能视图。
-(void)tapTempPwdSubfuncViewAction:(UIButton *)sender{
    
    KDSWifiLockPwdShareVC * vc = [KDSWifiLockPwdShareVC new];
    vc.lock = self.lock;
    [self.navigationController pushViewController:vc animated:YES];
    
}

///点击密码子功能视图。
- (void)tapPwdSubfuncViewAction:(UITapGestureRecognizer *)sender
{
    KDSWifiLockPwdListVC *vc = [KDSWifiLockPwdListVC new];
    vc.keyType = KDSBleKeyTypePIN;
    vc.lock = self.lock;
    [self.navigationController pushViewController:vc animated:YES];
}

///点击指纹子功能视图。
- (void)tapFingerprintSubfuncViewAction:(UITapGestureRecognizer *)sender
{
    KDSWifiLockPwdListVC *vc = [KDSWifiLockPwdListVC new];
    vc.keyType = KDSBleKeyTypeFingerprint;
    vc.lock = self.lock;
    [self.navigationController pushViewController:vc animated:YES];
}

///点击卡片子功能视图。
- (void)tapCardSubfuncViewAction:(UITapGestureRecognizer *)sender
{
    KDSWifiLockPwdListVC *vc = [KDSWifiLockPwdListVC new];
    vc.keyType = KDSBleKeyTypeRFID;
    vc.lock = self.lock;
    [self.navigationController pushViewController:vc animated:YES];
}

///点击设备共享子功能视图。
- (void)tapDeviceShareSubfuncViewAction:(UITapGestureRecognizer *)sender
{
    KDSLockKeyVC *vc = [KDSLockKeyVC new];
    vc.keyType = KDSBleKeyTypeReserved;
    vc.lock = self.lock;
    [self.navigationController pushViewController:vc animated:YES];
}

///点击更多子功能视图。
- (void)tapMoreSubfuncViewAction:(UITapGestureRecognizer *)sender
{
    KDSWIfiLockMoreSettingVC * vc = [KDSWIfiLockMoreSettingVC new];
    vc.lock = self.lock;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - 通知
///当电量状态刷新时，修改当前页面的电量。
- (void)refreshInterfaceWhenDeviceDidSync:(NSNotification *)noti
{
    [self setPowerWithImage:nil power:self.lock.bleTool.connectedPeripheral.power date:nil];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [navigationController setNavigationBarHidden:YES animated:YES];
}

@end
