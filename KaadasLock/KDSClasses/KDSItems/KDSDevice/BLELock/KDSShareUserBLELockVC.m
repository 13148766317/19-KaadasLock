//
//  KDSShareUserBLELockVC.m
//  KaadasLock
//
//  Created by orange on 2019/3/29.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSShareUserBLELockVC.h"
#import "Masonry.h"
#import "KDSLockParamVC.h"
#import "MBProgressHUD+MJ.h"
#import "KDSHttpManager+Ble.h"
#import "UIButton+Color.h"
#import "KDSDBManager.h"
#import "KDSAllPhotoShowImgModel.h"

@interface KDSShareUserBLELockVC () <UINavigationControllerDelegate>

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
///上个导航控制器的代理。
@property (nonatomic, weak) id<UINavigationControllerDelegate> preDelegate;
///获取锁信息接口成功返回的锁信息，用于更新锁反锁等状态。
@property (nonatomic, strong) KDSBleLockInfoModel *lockInfo;

@end

@implementation KDSShareUserBLELockVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    [self.lock addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshInterfaceWhenDeviceDidSync:) name:KDSDeviceSyncNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.preDelegate = self.navigationController.delegate;
    self.navigationController.delegate = self;
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
    self.titleLabel.text = self.lock.device.lockNickName;
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
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteBtn setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    deleteBtn.imageView.contentMode = UIViewContentModeCenter;
    deleteBtn.frame = CGRectMake(kScreenWidth - 7 - 44, kStatusBarHeight, 44, 44);
    [deleteBtn addTarget:self action:@selector(deleteBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteBtn];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.textColor = UIColor.whiteColor;
    titleLabel.text = self.lock.device.lockNickName;
    self.titleLabel = titleLabel;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kStatusBarHeight + 11);
        make.centerX.equalTo(self.view);
        make.left.mas_equalTo(self.view.mas_left).offset(30);
        make.right.mas_equalTo(self.view.mas_right).offset(-30);
    }];
    
    UILabel *modelLabel = [UILabel new];
    modelLabel.font = [UIFont systemFontOfSize:12];
    modelLabel.textColor = UIColor.whiteColor;
    NSString *model = self.lock.device.model;
    NSRange range = [self.lock.device.model rangeOfString:@"V" options:NSBackwardsSearch];
    if (range.location != NSNotFound)
    {
        model = [model substringToIndex:range.location];
    }
    model = model.length>5 ? [model substringToIndex:5] : model;
    //modelLabel.text = [NSString stringWithFormat:@"%@：%@", Localized(@"lockModel"), self.lock.device.model];
    modelLabel.text = model;
    for (NSString * productModel in [[KDSAllPhotoShowImgModel shareModel].productModel allKeys]) {
        if ([productModel isEqualToString:model]) {
            modelLabel.text = [[KDSAllPhotoShowImgModel shareModel].productModel objectForKey:model];
            break;
        }
    }
    modelLabel.textAlignment = NSTextAlignmentCenter;
    self.modelLabel = modelLabel;
    [self.view addSubview:modelLabel];
    
    [modelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kStatusBarHeight + kNavBarHeight + 19);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
    }];
    
    [KDSAllPhotoShowImgModel shareModel].device = self.lock.device;
    UIImageView *lockIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"KDSLockShare"]];
    for (NSString * imgName in [[KDSAllPhotoShowImgModel shareModel].authImgName allKeys]) {
        if ([imgName isEqualToString:self.lock.device.model]) {
            if ([[[KDSAllPhotoShowImgModel shareModel].authImgName objectForKey:self.lock.device.model] hasPrefix:@"http://"]) {
                NSLog(@"设备列表图片下载地址：%@",[KDSAllPhotoShowImgModel shareModel].authImgName);
                [[KDSAllPhotoShowImgModel shareModel] getDeviceImgWithImgName:[[KDSAllPhotoShowImgModel shareModel].authImgName objectForKey:self.lock.device.model] completion:^(UIImage * _Nullable image) {
                    if (image) {
                        lockIV.image = image;
                    }
                }];
            }else{
                lockIV.image = [UIImage imageNamed:[[KDSAllPhotoShowImgModel shareModel].authImgName objectForKey:self.lock.device.model]];
            }
        }
    }
    [self.view addSubview:lockIV];
    [lockIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(modelLabel.mas_bottom).offset(kScreenHeight<667 ? 30 : 58);
        make.centerX.equalTo(self.view);
        make.width.equalTo(@(lockIV.image.size.width * kScreenHeight / 667));
        make.height.equalTo(@(lockIV.image.size.height * kScreenHeight / 667));
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
        make.top.equalTo(lockIV.mas_bottom).offset(kScreenHeight<667 ? 35 : 56);
        make.centerX.equalTo(self.view);
        make.width.equalTo(@(58 + ceil(size.width)));
        make.height.equalTo(@35);
    }];
    [self setUnlockBtnTitleAutomatically];
    
    UIButton *powerInfoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    powerInfoBtn.enabled = NO;
    self.powerInfoBtn = powerInfoBtn;
    [self.view addSubview:powerInfoBtn];
    [powerInfoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(unlockBtn.mas_bottom).offset(kScreenHeight<667 ? 20 : 35);
        make.centerX.equalTo(self.view);
        make.width.equalTo(@(kScreenWidth));
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
    [self setPowerWithImage:nil power:self.lock.bleTool.connectedPeripheral.power date:nil];
    
    CGFloat height = kScreenHeight<667 ? 50 : 75;
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - height, kScreenWidth, height)];
    bottomView.backgroundColor = UIColor.whiteColor;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToViewLockInfo:)];
    [bottomView addGestureRecognizer:tap];
    [self.view addSubview:bottomView];
    
    UIImageView *gearIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blueGear"]];
    [bottomView addSubview:gearIV];
    [gearIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottomView).offset(26);
        make.centerY.equalTo(@0);
    }];
    UILabel *lockInfoLabel = [UILabel new];
    lockInfoLabel.text = Localized(@"deviceInfo");
    lockInfoLabel.textColor = KDSRGBColor(0x33, 0x33, 0x33);
    lockInfoLabel.font = [UIFont systemFontOfSize:13];
    [bottomView addSubview:lockInfoLabel];
    [lockInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(gearIV.mas_right).offset(22);
        make.centerY.equalTo(@0);
    }];
    UIImageView *arrowIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"箭头Hight"]];
    [bottomView addSubview:arrowIV];
    [arrowIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(bottomView).offset(-16);
        make.centerY.equalTo(@0);
    }];
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

///根据锁状态自动设置开锁按钮的标题。
- (void)setUnlockBtnTitleAutomatically
{
    self.unlockBtn.backgroundColor = UIColor.whiteColor;
    [self.unlockBtn setTitleColor:KDSRGBColor(0x16, 0xb8, 0xfd) forState:UIControlStateNormal];
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
            [self.unlockBtn setTitle:Localized(@"deviceOffline") forState:UIControlStateNormal];
            self.unlockBtn.backgroundColor = KDSRGBColor(224, 224, 224);
            [self.unlockBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];

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
        
        [self deleteBindedDevice];
        
    }];
    [ac addAction:cancelAction];
    [ac addAction:okAction];
    [self presentViewController:ac animated:YES completion:nil];
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

///点击查看设备信息。
- (void)tapToViewLockInfo:(UITapGestureRecognizer *)sender
{
    if (!self.lock.bleTool.connectedPeripheral) {
        [MBProgressHUD showError:@"蓝牙未连接"];
        return;
    }
 
    if(!self.lock.bleTool.connectedPeripheral.serialNumber)
    {
        [MBProgressHUD showError:Localized(@"bleNotConnect")];
        return;
    }
    KDSLockParamVC *vc = [KDSLockParamVC new];
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

#pragma mark - 网络请求相关
///删除绑定的设备
- (void)deleteBindedDevice
{
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"deleting") toView:self.view];
    [[KDSHttpManager sharedManager] deleteBindedDeviceWithUid:[KDSUserManager sharedManager].user.uid bleName:self.lock.device.lockName success:^{
        [hud hideAnimated:YES];
        [MBProgressHUD showSuccess:Localized(@"deleteSuccess")];
        [self.lock.bleTool endConnectPeripheral:self.lock.bleTool.connectedPeripheral];
        [[NSNotificationCenter defaultCenter] postNotificationName:KDSLockHasBeenDeletedNotification object:nil userInfo:@{@"lock" : self.lock}];
        [self.navigationController popToRootViewControllerAnimated:YES];
    } error:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:[Localized(@"deleteFailed") stringByAppendingFormat:@":%ld", (long)error.localizedDescription]];
    } failure:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:[Localized(@"deleteFailed") stringByAppendingFormat:@", %@", error.localizedDescription]];
    }];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [navigationController setNavigationBarHidden:YES animated:YES];//!iOS 9
}

@end
