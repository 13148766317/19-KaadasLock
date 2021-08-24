//
//  KDSBLELockVC.m
//  KaadasLock
//
//  Created by orange on 2019/3/27.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSBLELockVC.h"
#import "Masonry.h"
#import "KDSLockKeyVC.h"
#import "KDSLockMoreSettingVC.h"
#import "KDSHttpManager+Ble.h"
#import "KDSHttpManager+User.h"
#import "KDSDBManager.h"
#import "MBProgressHUD+MJ.h"
#import "UIButton+Color.h"
#import "KDSBleAssistant.h"
#import "KDSAllPhotoShowImgModel.h"

@interface KDSBLELockVC () <UINavigationControllerDelegate>

///导航栏位置的标题标签。
@property (nonatomic, weak) UILabel *titleLabel;
///锁型号标签。
@property (nonatomic, weak) UILabel *modelLabel;
///显示电量图片、电量和日期的按钮，设置这些属性时使用方法setPowerWithImage:power:date:@see setPowerWithImage:power:date:
@property (nonatomic, weak) UIButton *powerInfoBtn;
///电量内框图片。
@property (nonatomic, strong) UIImageView *powerIV;
///开锁按钮。
@property (nonatomic, weak) UIButton *unlockBtn;
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
///获取锁信息接口成功返回的锁信息，用于更新锁反锁等状态。
@property (nonatomic, strong) KDSBleLockInfoModel *lockInfo;

@end

@implementation KDSBLELockVC

#pragma mark - 生命周期、界面相关方法。
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    KDSDBManager *manager = [KDSDBManager sharedManager];
    NSArray<KDSPwdListModel *> *ms = [manager queryPwdAttrWithBleName:self.lock.device.lockName type:99];
    int pin = 0, fp = 0, card = 0;
    for (KDSPwdListModel *m in ms)
    {
        if (m.pwdType == KDSServerKeyTpyeCard )
        {
            card++;
        }
        else if (m.pwdType == KDSServerKeyTpyeFingerprint)
        {
            fp++;
        }
        else
        {
            pin++;
        }
    }
    int members = (int)[manager queryUserAuthMembers].count;
    [self setNumberOfPIN:pin fingerprint:fp card:card member:members];
    [self.lock addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshInterfaceWhenDeviceDidSync:) name:KDSDeviceSyncNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.preDelegate = self.navigationController.delegate;
    self.navigationController.delegate = self;
    self.titleLabel.text = self.lock.device.lockNickName;
    if (self.lock.bleTool.connectedPeripheral) {
        __weak typeof(self) weakSelf = self;
        [self.lock.bleTool getLockInfo:^(KDSBleError error, KDSBleLockInfoModel * _Nullable infoModel) {
            if (infoModel)
            {
                uint32_t state = infoModel.lockState;
                weakSelf.lock.bleTool.connectedPeripheral.isAutoMode = (state>>7) & 0x1;
                weakSelf.lockInfo = infoModel;
                weakSelf.lock.state = weakSelf.lock.state;
                [self setUnlockBtnTitleAutomatically];
            }
        }];
    }
    [self getAllKeys];
    [self getAllSharedUsers];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.delegate = self.preDelegate;
}

- (void)dealloc
{
    [self.lock removeObserver:self forKeyPath:@"state" context:nil];
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
    
    [KDSAllPhotoShowImgModel shareModel].device = self.lock.device;
    UIImageView *lockIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lock_pic"]];
    for (NSString * imgName in [[KDSAllPhotoShowImgModel shareModel].adminImgName allKeys]) {
        if ([imgName isEqualToString:self.lock.device.model]) {
            if ([[[KDSAllPhotoShowImgModel shareModel].adminImgName objectForKey:self.lock.device.model] hasPrefix:@"http://"]) {
                NSLog(@"设备列表图片下载地址：%@",[KDSAllPhotoShowImgModel shareModel].adminImgName);
                [[KDSAllPhotoShowImgModel shareModel] getDeviceImgWithImgName:[[KDSAllPhotoShowImgModel shareModel].adminImgName objectForKey:self.lock.device.model] completion:^(UIImage * _Nullable image) {
                    if (image) {
                        lockIV.image = image;
                    }
                }];
            }else{
                lockIV.image = [UIImage imageNamed:[[KDSAllPhotoShowImgModel shareModel].adminImgName objectForKey:self.lock.device.model]];
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
    NSString *model = self.lock.device.model;
    NSRange range = [self.lock.device.model rangeOfString:@"V" options:NSBackwardsSearch];
    if (range.location != NSNotFound)
    {
        model = [model substringToIndex:range.location];
    }
    /*range = [model rangeOfString:@"0"];
    if (range.location != NSNotFound)
    {
        model = [model substringToIndex:range.location];
    }*/
    model = model.length>5 ? [model substringToIndex:5] : model;
     modelLabel.text = model;
    for (NSString * productModel in [[KDSAllPhotoShowImgModel shareModel].productModel allKeys]) {
        if ([productModel isEqualToString:model]) {
            modelLabel.text = [[KDSAllPhotoShowImgModel shareModel].productModel objectForKey:model];
            break;
        }
    }
    self.modelLabel = modelLabel;
    [self.view addSubview:modelLabel];
    [modelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(lockIV).offset(0);
        make.centerX.equalTo(self.view);
        make.left.mas_equalTo(self.view.mas_left).offset(30);
        make.right.mas_equalTo(self.view.mas_right).offset(-30);
    }];
    
    UIButton *unlockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    unlockBtn.clipsToBounds = YES;
    unlockBtn.layer.cornerRadius = 17.5;
    [unlockBtn setTitle:Localized(@"clickUnlock") forState:UIControlStateNormal];
    [unlockBtn setTitleColor:KDSRGBColor(0x16, 0xb8, 0xfd) forState:UIControlStateNormal];
    unlockBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    CGSize size = [unlockBtn.currentTitle sizeWithAttributes:@{NSFontAttributeName : unlockBtn.titleLabel.font}];
    [unlockBtn addTarget:self action:@selector(clickUnlockBtnUnlock:) forControlEvents:UIControlEventTouchUpInside];
    self.unlockBtn = unlockBtn;
    [self.view addSubview:unlockBtn];
    [unlockBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lockIV.mas_bottom).offset(kScreenHeight<667 ? 3 : 11);
        make.centerX.equalTo(self.view);
        make.width.equalTo(@(MAX(125, size.width + 35)));
        make.height.equalTo(@35);
    }];
    [self setUnlockBtnTitleAutomatically];
    
    UIButton *powerInfoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    powerInfoBtn.enabled = NO;
    self.powerInfoBtn = powerInfoBtn;
    [self.view addSubview:powerInfoBtn];
    [powerInfoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(unlockBtn.mas_bottom).offset(kScreenHeight<667 ? 14 : 20);
        make.centerX.equalTo(self.view);
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
    [self setPowerWithImage:nil power:self.lock.power date:nil];
    
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
    if ([KDSLockFunctionSet[self.lock.lockFunctionSet] containsObject:@7] && [KDSLockFunctionSet[self.lock.lockFunctionSet] containsObject:@8] && [KDSLockFunctionSet[self.lock.lockFunctionSet] containsObject:@9]) {
        //密码、指纹、卡片都支持
        
        UIView *pwdView = [self createSubfuncViewWithImageName:@"password" subfunc:Localized(@"password") quantity:@""columnNumber:3 tapAction:@selector(tapPwdSubfuncViewAction:)];
        self.pwdQuantityLabel = [pwdView viewWithTag:3];
        [cornerView addSubview:pwdView];
        [pwdView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(cornerView);
            make.size.mas_equalTo(pwdView.bounds.size);
        }];
        
        UIView *hLineView = [UIView new];
        hLineView.backgroundColor = KDSRGBColor(0xf2, 0xf2, 0xf2);
        [cornerView addSubview:hLineView];
        [hLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(cornerView);
            make.top.equalTo(pwdView.mas_bottom);
            make.height.equalTo(@1);
        }];
        
        UIView *vLineView1 = [UIView new];
        vLineView1.backgroundColor = KDSRGBColor(0xf2, 0xf2, 0xf2);
        [cornerView addSubview:vLineView1];
        [vLineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(pwdView.mas_right);
            make.top.bottom.equalTo(cornerView);
            make.width.equalTo(@1);
        }];
        
        UIView *fpView = [self createSubfuncViewWithImageName:@"fingerprint" subfunc:Localized(@"fingerprint") quantity:@""columnNumber:3 tapAction:@selector(tapFingerprintSubfuncViewAction:)];
        self.fpQuantityLabel = [fpView viewWithTag:3];
        [cornerView addSubview:fpView];
        [fpView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cornerView);
            make.left.equalTo(vLineView1.mas_right);
            make.size.mas_equalTo(fpView.bounds.size);
        }];
        
        UIView *vLineView2 = [UIView new];
        vLineView2.backgroundColor = KDSRGBColor(0xf2, 0xf2, 0xf2);
        [cornerView addSubview:vLineView2];
        [vLineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(fpView.mas_right);
            make.top.bottom.equalTo(cornerView);
            make.width.equalTo(@1);
        }];
        
        UIView *cardView = [self createSubfuncViewWithImageName:@"card" subfunc:Localized(@"card") quantity:@"6个"columnNumber:3 tapAction:@selector(tapCardSubfuncViewAction:)];
        self.cardQuantityLabel = [cardView viewWithTag:3];
        [cornerView addSubview:cardView];
        [cardView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cornerView);
            make.left.equalTo(vLineView2.mas_right);
            make.size.mas_equalTo(cardView.bounds.size);
        }];
        
        UIView *shareView = [self createSubfuncViewWithImageName:@"memberShare" subfunc:Localized(@"deviceShare") quantity:@"6人"columnNumber:3 tapAction:@selector(tapDeviceShareSubfuncViewAction:)];
        self.memberQuantityLabel = [shareView viewWithTag:3];
        [cornerView addSubview:shareView];
        [shareView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.equalTo(cornerView);
            make.size.mas_equalTo(shareView.bounds.size);
            
        }];
        
        UIView *moreView = [self createSubfuncViewWithImageName:@"more" subfunc:Localized(@"more") quantity:@""columnNumber:3 tapAction:@selector(tapMoreSubfuncViewAction:)];
        [cornerView addSubview:moreView];
        [moreView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(cornerView);
            make.left.equalTo(shareView.mas_right);
            make.size.mas_equalTo(moreView.bounds.size);
        }];
        return;
        
    }if (![KDSLockFunctionSet[self.lock.lockFunctionSet] containsObject:@9]) {
        //不支持卡片
        UIView *pwdView = [self createSubfuncViewWithImageName:@"password" subfunc:Localized(@"password") quantity:@""columnNumber:2 tapAction:@selector(tapPwdSubfuncViewAction:)];
        self.pwdQuantityLabel = [pwdView viewWithTag:3];
        [cornerView addSubview:pwdView];
        [pwdView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(cornerView);
            make.size.mas_equalTo(pwdView.bounds.size);
        }];
        
        UIView *hLineView = [UIView new];
        hLineView.backgroundColor = KDSRGBColor(0xf2, 0xf2, 0xf2);
        [cornerView addSubview:hLineView];
        [hLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(cornerView);
            make.top.equalTo(pwdView.mas_bottom);
            make.height.equalTo(@1);
        }];
        
        UIView *vLineView1 = [UIView new];
        vLineView1.backgroundColor = KDSRGBColor(0xf2, 0xf2, 0xf2);
        [cornerView addSubview:vLineView1];
        [vLineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(pwdView.mas_right);
            make.top.bottom.equalTo(cornerView);
            make.width.equalTo(@1);
        }];
        
        UIView *fpView = [self createSubfuncViewWithImageName:@"fingerprint" subfunc:Localized(@"fingerprint") quantity:@""columnNumber:2 tapAction:@selector(tapFingerprintSubfuncViewAction:)];
        self.fpQuantityLabel = [fpView viewWithTag:3];
        [cornerView addSubview:fpView];
        [fpView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cornerView);
            make.left.equalTo(vLineView1.mas_right);
            make.size.mas_equalTo(fpView.bounds.size);
        }];
        
       UIView *shareView = [self createSubfuncViewWithImageName:@"memberShare" subfunc:Localized(@"deviceShare") quantity:@""columnNumber:2 tapAction:@selector(tapDeviceShareSubfuncViewAction:)];
        self.memberQuantityLabel = [shareView viewWithTag:3];
        [cornerView addSubview:shareView];
        [shareView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.equalTo(cornerView);
            make.size.mas_equalTo(shareView.bounds.size);
            
        }];
        
        UIView *moreView = [self createSubfuncViewWithImageName:@"more" subfunc:Localized(@"more") quantity:@""columnNumber:2 tapAction:@selector(tapMoreSubfuncViewAction:)];
        [cornerView addSubview:moreView];
        [moreView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(cornerView);
            make.left.equalTo(shareView.mas_right);
            make.size.mas_equalTo(moreView.bounds.size);
        }];
        return;
        
    }if (![KDSLockFunctionSet[self.lock.lockFunctionSet] containsObject:@8]) {
        //不支持指纹
        
        UIView *pwdView = [self createSubfuncViewWithImageName:@"password" subfunc:Localized(@"password") quantity:@""columnNumber:2 tapAction:@selector(tapPwdSubfuncViewAction:)];
         self.pwdQuantityLabel = [pwdView viewWithTag:3];
         [cornerView addSubview:pwdView];
         [pwdView mas_makeConstraints:^(MASConstraintMaker *make) {
             make.top.left.equalTo(cornerView);
             make.size.mas_equalTo(pwdView.bounds.size);
         }];
         
         UIView *hLineView = [UIView new];
         hLineView.backgroundColor = KDSRGBColor(0xf2, 0xf2, 0xf2);
         [cornerView addSubview:hLineView];
         [hLineView mas_makeConstraints:^(MASConstraintMaker *make) {
             make.left.right.equalTo(cornerView);
             make.top.equalTo(pwdView.mas_bottom);
             make.height.equalTo(@1);
         }];
         
         UIView *vLineView1 = [UIView new];
         vLineView1.backgroundColor = KDSRGBColor(0xf2, 0xf2, 0xf2);
         [cornerView addSubview:vLineView1];
         [vLineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
             make.left.equalTo(pwdView.mas_right);
             make.top.bottom.equalTo(cornerView);
             make.width.equalTo(@1);
         }];
         
        UIView *cardView = [self createSubfuncViewWithImageName:@"card" subfunc:Localized(@"card") quantity:@"6个"columnNumber:2 tapAction:@selector(tapCardSubfuncViewAction:)];
        self.cardQuantityLabel = [cardView viewWithTag:3];
        [cornerView addSubview:cardView];
        [cardView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cornerView);
            make.left.equalTo(vLineView1.mas_right);
            make.size.mas_equalTo(cardView.bounds.size);
        }];
    
        UIView *shareView = [self createSubfuncViewWithImageName:@"memberShare" subfunc:Localized(@"deviceShare") quantity:@""columnNumber:2 tapAction:@selector(tapDeviceShareSubfuncViewAction:)];
         self.memberQuantityLabel = [shareView viewWithTag:3];
         [cornerView addSubview:shareView];
         [shareView mas_makeConstraints:^(MASConstraintMaker *make) {
             make.left.bottom.equalTo(cornerView);
             make.size.mas_equalTo(shareView.bounds.size);
             
         }];
         
         UIView *moreView = [self createSubfuncViewWithImageName:@"more" subfunc:Localized(@"more") quantity:@""columnNumber:2 tapAction:@selector(tapMoreSubfuncViewAction:)];
         [cornerView addSubview:moreView];
         [moreView mas_makeConstraints:^(MASConstraintMaker *make) {
             make.bottom.equalTo(cornerView);
             make.left.equalTo(shareView.mas_right);
             make.size.mas_equalTo(moreView.bounds.size);
         }];
        return;
    }
}

///创建子功能视图。
- (UIView *)createSubfuncViewWithImageName:(NSString *)name subfunc:(NSString *)title quantity:(NSString *)quantity columnNumber:(int)colunNumber tapAction:(SEL)action
{
    CGFloat height = (260 * kScreenWidth / 375.0 - 1) / 2.0;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (kScreenWidth - 32) / colunNumber, height)];
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
    /*指密卡的个数视图*/
    UILabel *quantityLabel = [UILabel new];
    quantityLabel.tag = 3;
    quantityLabel.text = quantity;
    quantityLabel.font = [UIFont systemFontOfSize:12];
    quantityLabel.textAlignment = NSTextAlignmentCenter;
    quantityLabel.textColor = KDSRGBColor(0x99, 0x99, 0x99);
//    [view addSubview:quantityLabel];
//    [quantityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(iv.mas_bottom).offset(32);
//        make.centerX.equalTo(@0);
//    }];
    
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
    if (self.lock.state == KDSLockStateBleClosed || self.lock.state == KDSLockStateBleNotFound || !self.lock.connected) {
        self.powerIV.image = [UIImage imageNamed:@"offLineElectric"];
    }else{
        self.powerIV.image = [UIImage imageNamed:power<20 ? @"low power" : @"onLineElectric"];
    }
    if (!date)
    {
        NSDate *powerDate = [[KDSDBManager sharedManager] queryPowerTimeWithBleName:self.lock.device.lockName] ?: NSDate.date;
        if ([NSDate.date timeIntervalSinceDate:powerDate] < 3600)
        {
           // date = Localized(@"justNow");
            NSDateFormatter *fmt = self.lock.bleTool.dateFormatter;
            fmt.dateFormat = @"yyyy/MM/dd HH:mm";
            date = [fmt stringFromDate:powerDate];
        }
        else
        {
            NSDateFormatter *fmt = self.lock.bleTool.dateFormatter;
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
        fpUnit = @"个";
        cardUnit = @"张";
        pUnit = @"人";
    }
    else if ([[KDSTool getLanguage] containsString:FanTiZhongWen])
    {
        pinUnit = @"組";
        fpUnit = @"個";
        cardUnit = @"張";
        pUnit = @"人";
    }
    else if ([[KDSTool getLanguage] containsString:@"th"])
    {
        pinUnit = pin>1 ? @" groups" : @" group";
        fpUnit = fp>1 ? @" pieces" : @" piece";
        cardUnit = card>1 ? @" pieces" : @" piece";
        pUnit = members>1 ? @" persons" : @" person";
    }
    
    if (pin >= 0) self.pwdQuantityLabel.text = [NSString stringWithFormat:@"%d%@", pin, pinUnit];
    if (fp >= 0) self.fpQuantityLabel.text = [NSString stringWithFormat:@"%d%@", fp, fpUnit];
    if (card >= 0) self.cardQuantityLabel.text = [NSString stringWithFormat:@"%d%@", card, cardUnit];
    if (members >= 0) self.memberQuantityLabel.text = [NSString stringWithFormat:@"%d%@", members, pUnit];
}

///根据锁状态自动设置开锁按钮的标题。
- (void)setUnlockBtnTitleAutomatically
{
    switch (self.lock.state)
    {
        case KDSLockStateInitial:
            [self.unlockBtn setBackgroundColor:UIColor.whiteColor forState:UIControlStateNormal];
            [self.unlockBtn setTitleColor:KDSRGBColor(0x16, 0xb8, 0xfd) forState:UIControlStateNormal];
            [self.unlockBtn setTitle:Localized(@"bleConnecting") forState:UIControlStateNormal];
            break;
        
        case KDSLockStateBleClosed:
        case KDSLockStateBleNotFound:
            [self.unlockBtn setBackgroundImage:[UIImage imageNamed:@"buttonNotConnect"] forState:UIControlStateNormal];
            [self.unlockBtn setTitleColor:KDSRGBColor(0x86, 0x86, 0x86) forState:UIControlStateNormal];
            [self.unlockBtn setTitle:Localized(@"bleNotConnect") forState:UIControlStateNormal];
            break;
            
        case KDSLockStateReset://返回的值不能作为一定被重置的条件
        case KDSLockStateUnauth:
            [self.unlockBtn setBackgroundColor:UIColor.whiteColor forState:UIControlStateNormal];
            [self.unlockBtn setTitleColor:KDSRGBColor(0x16, 0xb8, 0xfd) forState:UIControlStateNormal];
            [self.unlockBtn setTitle:Localized(@"lockAuthFailed") forState:UIControlStateNormal];
            break;
            
        case KDSLockStateDefence:
        case KDSLockStateNormal:
            if (self.lockInfo)
            {
                int32_t state = self.lockInfo.lockState;
                int32_t func = self.lockInfo.lockFunc;
                NSString *tips = nil;
                char defenceMode = ((state >> 8) & 1) && ((func >> 4) & 0x1);
                tips = defenceMode ? Localized(@"defenseStatus") : tips;
                char lockInside = !((state >> 2) & 1) && ((func >> 14) & 0x1);
                tips = tips ?: (lockInside ? Localized(@"anti-lockState") : tips);
                char securityMode = ((state >> 5) & 1) && ((func >> 13) & 0x1);
                tips = tips ?: (securityMode ? Localized(@"safetyStatus") : tips);
                if (tips)
                {
                    [self.unlockBtn setTitle:tips forState:UIControlStateNormal];
                    [self.unlockBtn setBackgroundColor:UIColor.whiteColor forState:UIControlStateNormal];
                    [self.unlockBtn setTitleColor:KDSRGBColor(0x16, 0xb8, 0xfd) forState:UIControlStateNormal];
                    break;
                }
            }
            if (self.lock.bleTool.connectedPeripheral) {
                [self.unlockBtn setTitle:Localized(@"clickUnlock") forState:UIControlStateNormal];
                
            }else{
                [self.unlockBtn setTitle:Localized(@"searchingLockBle") forState:UIControlStateNormal];
            }
            [self.unlockBtn setBackgroundColor:UIColor.whiteColor forState:UIControlStateNormal];
            [self.unlockBtn setTitleColor:KDSRGBColor(0x16, 0xb8, 0xfd) forState:UIControlStateNormal];
            break;
        case KDSLockStateLockInside:
            [self.unlockBtn setBackgroundImage:[UIImage imageNamed:@"buttonLockInside"] forState:UIControlStateNormal];
            [self.unlockBtn setTitleColor:KDSRGBColor(0x16, 0xb8, 0xfd) forState:UIControlStateNormal];
            [self.unlockBtn setTitle:Localized(@"lockInside") forState:UIControlStateNormal];
            break;
            
        case KDSLockStateSecurityMode:
            [self.unlockBtn setBackgroundColor:UIColor.whiteColor forState:UIControlStateNormal];
            [self.unlockBtn setTitleColor:KDSRGBColor(0x16, 0xb8, 0xfd) forState:UIControlStateNormal];
            [self.unlockBtn setTitle:Localized(@"securityMode") forState:UIControlStateNormal];
            break;
            
        case KDSLockStateUnlocking:
            [self.unlockBtn setBackgroundImage:[UIImage imageNamed:@"buttonUnlocking"] forState:UIControlStateNormal];
            [self.unlockBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            [self.unlockBtn setTitle:Localized(@"unlocking") forState:UIControlStateNormal];
            break;
            
        case KDSLockStateUnlocked:
            [self.unlockBtn setBackgroundImage:[UIImage imageNamed:@"buttonUnlocked"] forState:UIControlStateNormal];
            [self.unlockBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            [self.unlockBtn setTitle:Localized(@"unlocked") forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
    [self.unlockBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(MAX(125, ceil([self.unlockBtn.currentTitle sizeWithAttributes:@{NSFontAttributeName : self.unlockBtn.titleLabel.font}].width) + 35)));
    }];
}

#pragma mark - 控件等事件方法。
///点击返回按钮。
- (void)backBtnAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

///点击开锁按钮开锁。
- (void)clickUnlockBtnUnlock:(UIButton *)sender
{
    if (!self.lock.bleTool.connectedPeripheral)
    {
        [MBProgressHUD showError:Localized(@"bleNotConnect")];
        return;
    }
    if (self.lock.state != KDSLockStateNormal) return;
    [[NSNotificationCenter defaultCenter] postNotificationName:KDSUserUnlockNotification object:nil userInfo:@{@"lock" : self.lock}];
}

///点击密码子功能视图。
- (void)tapPwdSubfuncViewAction:(UITapGestureRecognizer *)sender
{
    KDSLockKeyVC *vc = [KDSLockKeyVC new];
    vc.keyType = KDSBleKeyTypePIN;
    vc.lock = self.lock;
    [self.navigationController pushViewController:vc animated:YES];
}

///点击指纹子功能视图。
- (void)tapFingerprintSubfuncViewAction:(UITapGestureRecognizer *)sender
{
    KDSLockKeyVC *vc = [KDSLockKeyVC new];
    vc.keyType = KDSBleKeyTypeFingerprint;
    vc.lock = self.lock;
    [self.navigationController pushViewController:vc animated:YES];
}

///点击卡片子功能视图。
- (void)tapCardSubfuncViewAction:(UITapGestureRecognizer *)sender
{
    KDSLockKeyVC *vc = [KDSLockKeyVC new];
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
    KDSLockMoreSettingVC *vc = [KDSLockMoreSettingVC new];
    vc.lock = self.lock;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"state"] && object == self.lock)
    {
        [self setUnlockBtnTitleAutomatically];
    }
}

#pragma mark - 通知
///当电量状态刷新时，修改当前页面的电量。
- (void)refreshInterfaceWhenDeviceDidSync:(NSNotification *)noti
{
    [self setPowerWithImage:nil power:self.lock.bleTool.connectedPeripheral.power date:nil];
}

#pragma mark - 网络请求相关方法。
///获取所有密匙，然后更新界面。
- (void)getAllKeys
{
    NSString *uid = [KDSUserManager sharedManager].user.uid;
    [[KDSHttpManager sharedManager] getBlePwdListWithUid:uid bleName:self.lock.device.lockName pwdType:KDSServerKeyTpyeAll success:^(NSArray<KDSPwdListModel *> * _Nonnull pwdlistArray) {
        
        int pin = 0, fp = 0, card = 0;
        for (KDSPwdListModel *m in pwdlistArray)
        {
            if (m.pwdType == KDSServerKeyTpyePIN || m.pwdType == KDSServerKeyTpyeTempPIN)
            {
                pin++;
            }
            else if (m.pwdType == KDSServerKeyTpyeFingerprint)
            {
                fp++;
            }
            else
            {
                card++;
            }
        }
        [self setNumberOfPIN:pin fingerprint:fp card:card member:-1];
        
    } error:nil failure:nil];
}

///获取所有共享用户，然后更新界面。
- (void)getAllSharedUsers
{
    NSString *uid = [KDSUserManager sharedManager].user.uid;
    [[KDSHttpManager sharedManager] getAuthorizedUsersWithUid:uid bleName:self.lock.device.lockName success:^(NSArray<KDSAuthMember *> * _Nullable members) {
        
        [self setNumberOfPIN:-1 fingerprint:-1 card:-1 member:(int)members.count];
        
    } error:nil failure:nil];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [navigationController setNavigationBarHidden:YES animated:YES];
}

@end
