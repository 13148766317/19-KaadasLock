//
//  KDSWifiLockIsNotAdminDetailsVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/12/31.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSWifiLockIsNotAdminDetailsVC.h"
#import "KDSWifiLockPwdListVC.h"
#import "KDSHttpManager+User.h"
#import "KDSDBManager.h"
#import "MBProgressHUD+MJ.h"
#import "UIButton+Color.h"
#import "KDSLockKeyVC.h"
#import "KDSWifiLockPwdShareVC.h"
#import "KDSHttpManager+WifiLock.h"
#import "KDSWifiLockParamVC.h"
#import "KDSHttpManager+WifiLock.h"
#import "KDSAllPhotoShowImgModel.h"

#import "KDSMediaLockParamVC.h"


@interface KDSWifiLockIsNotAdminDetailsVC ()<UINavigationControllerDelegate>

///导航栏位置的标题标签。
@property (nonatomic, weak) UILabel *titleLabel;
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

@implementation KDSWifiLockIsNotAdminDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
     [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.preDelegate = self.navigationController.delegate;
    self.navigationController.delegate = self;
    self.titleLabel.text = self.lock.wifiDevice.lockNickname ?: self.lock.wifiDevice.wifiSN;
    
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
    titleLabel.text = self.lock.wifiDevice.lockNickname;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kStatusBarHeight + 11);
        make.centerX.equalTo(self.view);
        make.left.mas_equalTo(self.view.mas_left).offset(30);
        make.right.mas_equalTo(self.view.mas_right).offset(-30);
    }];
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteBtn setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    deleteBtn.imageView.contentMode = UIViewContentModeCenter;
    deleteBtn.frame = CGRectMake(kScreenWidth - 7 - 44, kStatusBarHeight, 44, 44);
    [deleteBtn addTarget:self action:@selector(deleteBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteBtn];
    UILabel * WifiLockModel = [UILabel new];
    if ([self.lock.wifiDevice.productModel isEqualToString:@"K13"]) {
        WifiLockModel.text = [NSString stringWithFormat:@"%@：%@", Localized(@"lockModel"), @"兰博基尼传奇"];
    }else{
        WifiLockModel.text = [NSString stringWithFormat:@"%@：%@", Localized(@"lockModel"), self.lock.wifiDevice.productModel];
        for (NSString * productModel in [[KDSAllPhotoShowImgModel shareModel].productModel allKeys]) {
            if ([productModel isEqualToString:self.lock.wifiDevice.productModel]) {
                WifiLockModel.text = [NSString stringWithFormat:@"%@：%@", Localized(@"lockModel"), [[KDSAllPhotoShowImgModel shareModel].productModel objectForKey:self.lock.wifiDevice.productModel]];
                break;
            }
        }
    }
    WifiLockModel.textColor = UIColor.whiteColor;
    WifiLockModel.font = [UIFont systemFontOfSize:13];
    WifiLockModel.textAlignment = NSTextAlignmentLeft;
    self.WifiLockModel = WifiLockModel;
    [self.view addSubview:WifiLockModel];
    [WifiLockModel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(KDSSSALE_WIDTH(100));
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];

    ///锁型号对应的图片
    [KDSAllPhotoShowImgModel shareModel].device = self.lock.wifiDevice;
    UIImageView *lockIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"KDSLockShare"]];
      // 防止图片被拉升
    lockIV.contentMode = UIViewContentModeScaleAspectFit;
    for (NSString * imgName in [[KDSAllPhotoShowImgModel shareModel].authImgName allKeys]) {
        if ([imgName isEqualToString:self.lock.wifiDevice.productModel]) {
            if ([[[KDSAllPhotoShowImgModel shareModel].authImgName objectForKey:self.lock.wifiDevice.productModel] hasPrefix:@"http://"]) {
                NSLog(@"设备列表图片下载地址：%@",[KDSAllPhotoShowImgModel shareModel].authImgName);
                [[KDSAllPhotoShowImgModel shareModel] getDeviceImgWithImgName:[[KDSAllPhotoShowImgModel shareModel].authImgName objectForKey:self.lock.wifiDevice.productModel] completion:^(UIImage * _Nullable image) {
                    if (image) {
                        lockIV.image = image;
                    }
                }];
            }else{
                lockIV.image = [UIImage imageNamed:[[KDSAllPhotoShowImgModel shareModel].authImgName objectForKey:self.lock.wifiDevice.productModel]];
            }
        }
    }
    [self.view insertSubview:lockIV belowSubview:titleLabel];
    [lockIV mas_makeConstraints:^(MASConstraintMaker *make) {
         make.top.equalTo(self.WifiLockModel.mas_bottom).offset(kScreenHeight<667 ? 30 : 58);
        make.centerX.equalTo(self.view.mas_centerX).offset(0);
        make.width.equalTo(@(lockIV.image.size.width * kScreenHeight / 667));
        make.height.equalTo(@(lockIV.image.size.height * kScreenHeight / 667));
    }];
    
    UIButton *powerInfoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    powerInfoBtn.enabled = NO;
    self.powerInfoBtn = powerInfoBtn;
    [self.view addSubview:powerInfoBtn];
    [powerInfoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_bottom).offset(-KDSSSALE_WIDTH(120));
//        make.left.mas_equalTo(WifiLockModel.mas_right).offset(KDSSSALE_WIDTH(30));
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
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
    
    UIView *grayView = [UIView new];
    grayView.backgroundColor = KDSRGBColor(0xf2, 0xf2, 0xf2);
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMoreSubfuncViewAction:)];
    [grayView addGestureRecognizer:tap];
    [self.view addSubview:grayView];
    [grayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.height.mas_equalTo(75);
    }];
    
    UIImageView * devInfoIcon = [UIImageView new];
    devInfoIcon.image = [UIImage imageNamed:@"blueGear"];
    [grayView addSubview:devInfoIcon];
    [devInfoIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@23);
        make.left.mas_equalTo(grayView.mas_left).offset(26);
        make.centerY.mas_equalTo(grayView.mas_centerY).offset(0);
    }];
    UIButton * iocnBtn = [UIButton new];
    [iocnBtn setImage:[UIImage imageNamed:@"rightBackIcon"] forState:UIControlStateNormal];
    [grayView addSubview:iocnBtn];
    [iocnBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(grayView.mas_right).offset(-31);
        make.width.equalTo(@8);
        make.height.equalTo(@13);
        make.centerY.mas_equalTo(grayView.mas_centerY).offset(0);
        
    }];
    UILabel * lb = [UILabel new];
    lb.text = Localized(@"deviceInfo");
    lb.textColor = KDSRGBColor(51, 51, 51);
    lb.font = [UIFont systemFontOfSize:13];
    lb.textAlignment = NSTextAlignmentLeft;
    [grayView addSubview:lb];
    [lb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(devInfoIcon.mas_right).offset(21.5);
        make.right.mas_equalTo(iocnBtn.mas_left).offset(-20);
        make.centerY.mas_equalTo(grayView.mas_centerY).offset(0);
    }];
}


///创建子功能视图。
- (UIView *)createSubfuncViewWithImageName:(NSString *)name subfunc:(NSString *)title quantity:(NSString *)quantity tapAction:(SEL)action
{
    CGFloat height = (260 * kScreenWidth / 375.0 - 1) / 2.0;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (kScreenWidth - 32) / 3.0, height)];
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

#pragma mark - 控件等事件方法。
///点击返回按钮。
- (void)backBtnAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
///点击更多子功能视图。
- (void)tapMoreSubfuncViewAction:(UITapGestureRecognizer *)sender
{
    
//    KDSMediaLockParamVC  *medVC = [KDSMediaLockParamVC new];
//    medVC.lock = self.lock;
//    [self.navigationController pushViewController:medVC animated:YES];
    KDSWifiLockParamVC * vc = [KDSWifiLockParamVC new];
    vc.lock = self.lock;
    [self.navigationController pushViewController:vc animated:YES];
    
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

///删除绑定的设备
- (void)deleteBindedDevice
{
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"deleting") toView:self.view];
    [[KDSHttpManager sharedManager] unbindWifiDeviceWithWifiSN:self.lock.wifiDevice.wifiSN uid:[KDSUserManager sharedManager].user.uid success:^{
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
