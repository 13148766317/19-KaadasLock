//
//  KDSGWLockVC.m
//  KaadasLock
//
//  Created by orange on 2019/4/28.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSGWLockVC.h"
#import "MBProgressHUD+MJ.h"
#import "KDSGWLockKeyVC.h"
#import "KDSGWMenaceVC.h"
#import "KDSLockMoreSettingVC.h"
#import "KDSGWAddPINVC.h"
#import "UIButton+Color.h"
#import "KDSDBManager+GW.h"
#import "KDSLockParamVC.h"


@interface KDSGWLockVC () <UINavigationControllerDelegate>

///导航栏位置的标题标签。
@property (nonatomic, weak) UILabel *titleLabel;
///锁型号标签。
@property (nonatomic, weak) UILabel *modelLabel;
///显示电量图片、电量和日期的按钮，设置这些属性时使用方法setPowerWithImage:power:date:@see setPowerWithImage:power:date:
@property (nonatomic, weak) UIButton *powerInfoBtn;
@property (nonatomic, strong) UIImageView * powerImg;
///开锁按钮。
@property (nonatomic, weak) UIButton *unlockBtn;
///上个导航控制器的代理。
@property (nonatomic, weak) id<UINavigationControllerDelegate> preDelegate;

@end

@implementation KDSGWLockVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
    [self.lock addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceInfoDidSync:) name:KDSDeviceSyncNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.preDelegate = self.navigationController.delegate;
    self.navigationController.delegate = self;
    self.titleLabel.text = self.lock.gwDevice.nickName;
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
    BOOL isAdmin = self.lock.gwDevice.isAdmin;
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
    titleLabel.text = self.lock.gwDevice.nickName;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel = titleLabel;
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kStatusBarHeight + 11);
        make.centerX.equalTo(self.view);
        make.left.mas_equalTo(self.view.mas_left).offset(30);
        make.right.mas_equalTo(self.view.mas_right).offset(-30);
    }];
    
    if (!isAdmin)
    {
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteBtn setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        deleteBtn.imageView.contentMode = UIViewContentModeCenter;
        deleteBtn.frame = CGRectMake(kScreenWidth - 7 - 44, kStatusBarHeight, 44, 44);
        [deleteBtn addTarget:self action:@selector(deleteBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:deleteBtn];
    }
    
    UIImageView *lockIV = [UIImageView new];
    [self.view addSubview:lockIV];
    if (!isAdmin) {
        [lockIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLabel.mas_bottom).offset(kScreenHeight<667 ? KDSSSALE_HEIGHT(30) : KDSSSALE_HEIGHT(68));
            make.centerX.equalTo(self.view);
            make.width.equalTo(@(KDSSSALE_HEIGHT(132.5)));
            make.height.equalTo(@(KDSSSALE_HEIGHT(263)));
        }];
        lockIV.image = [UIImage imageNamed:@"zigbee-undefinedModel"];
    }else{
        [lockIV mas_makeConstraints:^(MASConstraintMaker *make) {
            CGFloat topheight = (isAdmin ? 260 : 130) * kScreenWidth / 375.0 + 30;
            CGFloat imgHeigh = kScreenHeight<=667 ? 200 : 236;
            make.top.equalTo(titleLabel).offset((kScreenHeight - topheight- imgHeigh)/2 - imgHeigh/4);
            make.centerX.equalTo(self.view);
            make.width.height.equalTo(@(kScreenHeight<=667 ? 200 : 236));
        }];
        lockIV.image = [UIImage imageNamed:@"lock_pic"];
    }
    
    UILabel *modelLabel = [UILabel new];
    modelLabel.font = [UIFont systemFontOfSize:13];
    modelLabel.textColor = UIColor.whiteColor;
    self.modelLabel = modelLabel;
    [self.view addSubview:modelLabel];
    [modelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(lockIV).offset(-0);
        make.centerX.equalTo(self.view);
    }];
    if (self.lock.gwDevice.lockversion) {
        if ([[self.lock.gwDevice.lockversion componentsSeparatedByString:@";"][0] caseInsensitiveCompare:@"8100Z"] == NSOrderedSame
        || [[self.lock.gwDevice.lockversion componentsSeparatedByString:@";"][0] caseInsensitiveCompare:@"8100A"] == NSOrderedSame) {
            if (!isAdmin) {
                lockIV.image = [UIImage imageNamed:@"8100LockShare"];
            }else{
                lockIV.image = [UIImage imageNamed:@"zigbee-8100AZ"];
                modelLabel.text = [NSString stringWithFormat:@"%@",[self.lock.gwDevice.lockversion componentsSeparatedByString:@";"][0]];
            }
        }
    }
    UIButton *unlockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    unlockBtn.hidden = YES;
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
        make.top.equalTo(modelLabel.mas_bottom).offset(kScreenHeight<667 && !isAdmin  ? 10 : 18);
        make.centerX.equalTo(self.view);
        make.width.equalTo(@(MAX(125, size.width + 35)));
        make.height.equalTo(@35);
    }];
    [self setUnlockBtnTitleAutomatically];
    
    UIButton *powerInfoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    powerInfoBtn.enabled = NO;
    self.powerInfoBtn = powerInfoBtn;
    powerInfoBtn.backgroundColor = UIColor.clearColor;
    [self.view addSubview:powerInfoBtn];
    [powerInfoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-((isAdmin ? 260 : 130) * kScreenWidth / 375.0 + 30 + (isAdmin ? 22 : 59)));
        make.centerX.equalTo(self.view);
        make.width.equalTo(@200);
        make.height.equalTo(@12);
    }];
    
    self.powerImg = [UIImageView new];
    self.powerImg.layer.masksToBounds = YES;
    self.powerImg.layer.cornerRadius = 1;
    [self.view addSubview:self.powerImg];
    [self.powerImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(powerInfoBtn.imageView).offset(1.5);
        make.left.mas_equalTo(powerInfoBtn.mas_left).offset(1.4);
        make.width.equalTo(@18);
        make.bottom.equalTo(powerInfoBtn.imageView).offset(-1.5);
    }];
    
    int power = self.lock.power;
    [self setPowerWithImage:nil power:power date:nil];
    
    UIView *grayView = [UIView new];
    grayView.backgroundColor = KDSRGBColor(0xf2, 0xf2, 0xf2);
    [self.view addSubview:grayView];
    [grayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.height.mas_equalTo((isAdmin ? 260 : 130) * kScreenWidth / 375.0 + 30);
    }];
    UIView *cornerView = [UIView new];
    cornerView.backgroundColor = UIColor.whiteColor;
    cornerView.layer.cornerRadius = 4;
    cornerView.clipsToBounds = YES;
    [grayView addSubview:cornerView];
    [cornerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(grayView).offset(15);
        make.left.equalTo(grayView).offset(15);
        make.bottom.equalTo(grayView).offset(-14);
        make.right.equalTo(grayView).offset(-15);
    }];
    
    UIView *pwdView = [self createSubfuncViewWithImageName:@"password" subfunc:Localized(@"password") quantity:@"6组" tapAction:@selector(tapPwdSubfuncViewAction:)];
    [cornerView addSubview:pwdView];
    [pwdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(cornerView);
        make.size.mas_equalTo(pwdView.bounds.size);
    }];
    
    UIView *vLineView = [UIView new];
    vLineView.backgroundColor = KDSRGBColor(0xf2, 0xf2, 0xf2);
    [cornerView addSubview:vLineView];
    [vLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(pwdView.mas_right);
        make.top.bottom.equalTo(cornerView);
        make.width.equalTo(@1);
    }];
    
    UIView *moreView = [self createSubfuncViewWithImageName:(isAdmin ? @"more" : @"blueGear") subfunc:Localized((isAdmin ? @"more" : @"deviceInfo")) quantity:@"" tapAction:@selector(tapMoreSubfuncViewAction:)];
    [cornerView addSubview:moreView];
    [moreView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.equalTo(cornerView);
        make.size.mas_equalTo(moreView.bounds.size);
    }];
    if (isAdmin)
    {
        UIView *hLineView = [UIView new];
        hLineView.backgroundColor = KDSRGBColor(0xf2, 0xf2, 0xf2);
        [cornerView addSubview:hLineView];
        [hLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(cornerView);
            make.top.equalTo(pwdView.mas_bottom);
            make.height.equalTo(@1);
        }];
        
        UIView *shareView = [self createSubfuncViewWithImageName:@"memberShare" subfunc:Localized(@"deviceShare") quantity:@"6人" tapAction:@selector(tapDeviceShareSubfuncViewAction:)];
        [cornerView addSubview:shareView];
        [shareView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.equalTo(cornerView);
            make.size.mas_equalTo(shareView.bounds.size);
        }];
        
        UIView *menaceView = [self createSubfuncViewWithImageName:@"menace" subfunc:Localized(@"menaceAlarm") quantity:@"6个" tapAction:@selector(tapMenaceSubfuncViewAction:)];
        [cornerView addSubview:menaceView];
        [menaceView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.equalTo(cornerView);
            make.size.mas_equalTo(menaceView.bounds.size);
        }];
    }
}

///创建子功能视图。和蓝牙锁相比少了数量标签，先留着。
- (UIView *)createSubfuncViewWithImageName:(NSString *)name subfunc:(NSString *)title quantity:(NSString *)quantity tapAction:(SEL)action
{
    CGFloat height = (260 * kScreenWidth / 375.0 - 1) / 2.0;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (kScreenWidth - 31) / 2.0, height)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:action];
    [view addGestureRecognizer:tap];
    
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [view addSubview:iv];
    [iv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(view.mas_centerY);
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
        make.top.equalTo(view.mas_centerY).offset(14);
        make.centerX.equalTo(@0);
    }];
    
    /*UILabel *quantityLabel = [UILabel new];
    quantityLabel.tag = 3;
    quantityLabel.text = quantity;
    quantityLabel.font = [UIFont systemFontOfSize:12];
    quantityLabel.textAlignment = NSTextAlignmentCenter;
    quantityLabel.textColor = KDSRGBColor(0x99, 0x99, 0x99);
    [view addSubview:quantityLabel];
    [quantityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(iv.mas_bottom).offset(32);
        make.centerX.equalTo(@0);
    }];*/
    
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
    UIImage * img = [UIImage imageNamed:@"Battery exterior"];
    image = img;
    if (self.lock.state == KDSLockStateOffline) {
        self.powerImg.image = [UIImage imageNamed:@"offLineElectric"];
    }else{
        if (power< 20) {
            self.powerImg.image = [UIImage imageNamed:@"low power"];
        }else{
            self.powerImg.image = [UIImage imageNamed:@"onLineElectric"];
        }
    }
    if (!date)
    {
        NSDate *powerDate = [[KDSDBManager sharedManager] queryPowerTimeWithBleName:self.lock.device.lockName] ?: NSDate.date;
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
    }else{
        if (power > 0) {
            // date = Localized(@"justNow");
        }
    }
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
    [self.powerInfoBtn setImage:image forState:UIControlStateNormal];
    [self.powerImg mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(18 * width);
    }];
}

///根据锁状态自动设置开锁按钮的标题。
- (void)setUnlockBtnTitleAutomatically
{
    switch (self.lock.state)
    {
        case KDSLockStateDefence:
            [self.unlockBtn setBackgroundColor:UIColor.whiteColor forState:UIControlStateNormal];
            [self.unlockBtn setTitleColor:KDSRGBColor(0x16, 0xb8, 0xfd) forState:UIControlStateNormal];
            [self.unlockBtn setTitle:Localized(@"defenceMode") forState:UIControlStateNormal];
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
            [self.unlockBtn setBackgroundImage:[UIImage imageNamed:@"buttonLockUnlocking"] forState:UIControlStateNormal];
            [self.unlockBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            [self.unlockBtn setTitle:Localized(@"unlocking") forState:UIControlStateNormal];
            break;
            
        case KDSLockStateUnlocked:
            [self.unlockBtn setBackgroundImage:[UIImage imageNamed:@"buttonLockUnlocked"] forState:UIControlStateNormal];
            [self.unlockBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            [self.unlockBtn setTitle:Localized(@"unlocked") forState:UIControlStateNormal];
            break;
            
        case KDSLockStateOnline:
            [self.unlockBtn setBackgroundColor:UIColor.whiteColor forState:UIControlStateNormal];
            [self.unlockBtn setTitleColor:KDSRGBColor(0x16, 0xb8, 0xfd) forState:UIControlStateNormal];
            [self.unlockBtn setTitle:Localized(@"clickUnlock") forState:UIControlStateNormal];
            break;
            
        default:
            [self.unlockBtn setBackgroundColor:UIColor.whiteColor forState:UIControlStateNormal];
            [self.unlockBtn setTitleColor:KDSRGBColor(0x16, 0xb8, 0xfd) forState:UIControlStateNormal];
            [self.unlockBtn setTitle:Localized(@"deviceOffline") forState:UIControlStateNormal];
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

///点击删除按钮删除分享设备。
- (void)deleteBtnAction:(UIButton *)sender
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"beSureDeleteDevice?") message:Localized(@"deviceWillBeUnbindAfterDelete") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"deleting") toView:self.view];
        [[KDSMQTTManager sharedManager] shareGatewayBindingWithGW:self.lock.gw.model device:self.lock.gwDevice userAccount:[KDSUserManager sharedManager].user.name userNickName:[KDSUserManager sharedManager].userNickname shareFlag:0 type:2 completion:^(NSError * _Nullable error, BOOL success) {
            [hud hideAnimated:NO];
            if (success)
            {
                [MBProgressHUD showSuccess:Localized(@"deleteSuccess")];
                [[NSNotificationCenter defaultCenter] postNotificationName:KDSLockHasBeenDeletedNotification object:nil userInfo:@{@"lock" : self.lock}];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            else
            {
                [MBProgressHUD showError:Localized(@"deleteFailed")];
            }
        }];
        
    }];
    [ac addAction:cancelAction];
    [ac addAction:okAction];
    [self presentViewController:ac animated:YES completion:nil];
}

///点击开锁按钮开锁。
- (void)clickUnlockBtnUnlock:(UIButton *)sender
{
    if (!(self.lock.state == KDSLockStateOnline || self.lock.state == KDSLockStateDefence)) return;
    [[NSNotificationCenter defaultCenter] postNotificationName:KDSUserUnlockNotification object:nil userInfo:@{@"lock" : self.lock}];
}

///点击密码子功能视图。
- (void)tapPwdSubfuncViewAction:(UITapGestureRecognizer *)sender
{
    KDSGWLockKeyVC *vc = [KDSGWLockKeyVC new];
    vc.lock = self.lock;
    vc.keyType = KDSGWKeyTypePIN;
    [self.navigationController pushViewController:vc animated:YES];
}

///点击胁迫警告子功能视图。
- (void)tapMenaceSubfuncViewAction:(UITapGestureRecognizer *)sender
{
    KDSGWMenaceVC *vc = [KDSGWMenaceVC new];
    vc.lock = self.lock;
    [self.navigationController pushViewController:vc animated:YES];
}

///点击设备共享子功能视图。
- (void)tapDeviceShareSubfuncViewAction:(UITapGestureRecognizer *)sender
{
    KDSGWLockKeyVC *vc = [KDSGWLockKeyVC new];
    vc.lock = self.lock;
    vc.keyType = KDSGWKeyTypeReserved;
    [self.navigationController pushViewController:vc animated:YES];
}

///点击更多子功能(管理员权限)或者设备信息(非管理员权限)视图。
- (void)tapMoreSubfuncViewAction:(UITapGestureRecognizer *)sender
{
    BOOL isAdmin = self.lock.gwDevice.isAdmin;
    if (isAdmin)
    {
        KDSLockMoreSettingVC *vc = [KDSLockMoreSettingVC new];
        vc.lock = self.lock;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        KDSLockParamVC *vc = [[KDSLockParamVC alloc] init];
        vc.lock = self.lock;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"state"] && object == self.lock)
    {
        [self setUnlockBtnTitleAutomatically];
    }
}

#pragma - 通知
///设备信息更新的通知。
- (void)deviceInfoDidSync:(NSNotification *)noti
{
    [self setPowerWithImage:nil power:self.lock.power date:nil];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [navigationController setNavigationBarHidden:YES animated:YES];
}

@end
