//
//  KDSBleAddWiFiLockDetailsVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/4/9.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSBleAddWiFiLockDetailsVC.h"
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
#import "KDSBleAddWiFiFuncListCell.h"
#import "KDSSwitchLinkageDetailVC.h"
#import "UIImageView+ForScrollView.h"
#import "KDSMyAlbumVC.h"
#import "KDSMediaLockRecordDetailsVC.h"
#import "KDSMediaLockMoreSettingVC.h"
#import "XMPlayController.h"

static NSString * const deviceListCellId = @"bleAddWiFiFuncListCell";

@interface KDSBleAddWiFiLockDetailsVC ()<UINavigationControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

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
///用来展示设备功能列表
@property (nonatomic,readwrite,strong)UICollectionView * collectionView;
///锁功能的图片
@property (nonatomic,strong)NSMutableArray * funcImgListArray;
///锁功能的名称
@property (nonatomic,strong)NSMutableArray * funcNameListArray;
///锁功能的子视图的个数
@property (nonatomic,strong)NSMutableArray * funcNumListArray;

@end

@implementation KDSBleAddWiFiLockDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *pinUnit = @"组";
    NSString *fpUnit = @"组";
    NSString *cardUnit = @"张";
    NSString *pUnit = @"台";
    NSString *faceUnit = @"组";
    [self.funcNumListArray insertObject:[NSString stringWithFormat:@"(%d%@)", 0, faceUnit] atIndex:0];
    [self.funcNumListArray insertObject:[NSString stringWithFormat:@"(%d%@)", 0, pinUnit] atIndex:1];
    [self.funcNumListArray insertObject:[NSString stringWithFormat:@"(%d%@)", 0, fpUnit] atIndex:2];
    [self.funcNumListArray insertObject:[NSString stringWithFormat:@"(%d%@)", 0, cardUnit] atIndex:3];
    [self.funcNumListArray insertObject:[NSString stringWithFormat:@"(%d%@)", 0, pUnit] atIndex:4];
    
    /*
     **************************功能表的显示顺序***********************************
     1、临时密码，2、实时视频， 3、动态记录， 4、人脸识别，5、密码，6、指纹，7、卡片，
     8、智能开关，9、我的相册，10、设备共享，11、更多
     */
    
    ///临时密码
    [self.funcImgListArray addObject:@"password"];
    [self.funcNameListArray addObject:Localized(@"tempPassword")];
    if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@53]) {
        ///实时视频
        [self.funcImgListArray addObject:@"realTimeVideo"];
        [self.funcNameListArray addObject:Localized(@"realTimeVideo")];
    }if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@52]) {
        ///动态记录
        [self.funcImgListArray addObject:@"dynamicRecording"];
        [self.funcNameListArray addObject:Localized(@"dynamicRecording")];
    }if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@26]) {
        ///支持人脸识别开锁
        [self.funcImgListArray addObject:@"faceRecognition"];
        [self.funcNameListArray addObject:Localized(@"faceRecognition")];
    }if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@7]) {
        ///密码
        [self.funcImgListArray addObject:@"password"];
        [self.funcNameListArray addObject:Localized(@"password")];
    }if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@8]) {
        ///指纹
        [self.funcImgListArray addObject:@"fingerprint"];
        [self.funcNameListArray addObject:Localized(@"fingerprint")];
    }if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@9]) {
        ///卡片
        [self.funcImgListArray addObject:@"card"];
        [self.funcNameListArray addObject:Localized(@"card")];
    }if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@45]) {
        ///智能开关
        [self.funcImgListArray addObject:@"IntelligentSwitchImg"];
        [self.funcNameListArray addObject:Localized(@"IntelligentSwitchImg")];
    }if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@53]) {
        ///我的相册
        [self.funcImgListArray addObject:@"myAlbum"];
        [self.funcNameListArray addObject:Localized(@"myAlbum")];
    }
    ///设备共享
    [self.funcImgListArray addObject:@"memberShare"];
    [self.funcNameListArray addObject:Localized(@"deviceShare")];
    ///更多
    [self.funcImgListArray addObject:@"more"];
    [self.funcNameListArray addObject:Localized(@"more")];
    [self setupUI];
    
    
    // 接收MQtt上报事件的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wifimqttEventNotification:) name:KDSMQTTEventNotification object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.preDelegate = self.navigationController.delegate;
    self.navigationController.delegate = self;
    self.titleLabel.text = self.lock.wifiDevice.lockNickname ?: self.lock.wifiDevice.wifiSN;
    NSLog(@"zhu 输出wifi锁的昵称是==%@",self.titleLabel.text);
    // 获取所有的密匙
    [self getAllKeys];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.delegate = self.preDelegate;
}
-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    titleLabel.text = self.lock.device.lockNickName;
    
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kStatusBarHeight + 11);
        make.centerX.equalTo(self.view);
        make.height.equalTo(@22);
        make.width.equalTo(@75);
        //make.left.mas_equalTo(self.view.mas_left).offset(30);
       // make.right.mas_equalTo(self.view.mas_right).offset(-30);
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
        make.top.equalTo(self.view.mas_bottom).offset(-(KDSScreenHeight -KDSSSALE_HEIGHT(378)) - 33);
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
        make.centerY.equalTo(modelAndPowerSupView.mas_centerY).offset(0);
        make.right.mas_equalTo(modelAndPowerSupView.mas_right).offset(0);
        make.width.equalTo(@200);
        make.height.equalTo(@12);
    }];
    
    UILabel * lockEnergyLb = [UILabel new];
    lockEnergyLb.text = @"电量：";
    lockEnergyLb.font =[UIFont systemFontOfSize:13];
    lockEnergyLb.textColor = UIColor.whiteColor;
    lockEnergyLb.textAlignment = NSTextAlignmentLeft;
    [modelAndPowerSupView addSubview:lockEnergyLb];
    CGSize lockEnergyLbSize = [lockEnergyLb.text sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13]}];
    [lockEnergyLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(ceil(lockEnergyLbSize.width)));
        make.height.equalTo(@12);
        make.right.mas_equalTo(self.powerInfoBtn.mas_left).offset(-3);
        make.centerY.equalTo(modelAndPowerSupView.mas_centerY).offset(0);
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
    WifiLockModel.textColor = UIColor.whiteColor;
    WifiLockModel.font = [UIFont systemFontOfSize:13];
    WifiLockModel.textAlignment = NSTextAlignmentLeft;
    self.WifiLockModel = WifiLockModel;
    if ([self.lock.wifiDevice.productModel isEqualToString:@"K13"]) {
        self.WifiLockModel.text = [NSString stringWithFormat:@"%@：%@", Localized(@"lockModel"), @"兰博基尼传奇"];
    }else{
        
        self.WifiLockModel.text =[NSString stringWithFormat:@"%@：%@", Localized(@"lockModel"), self.lock.wifiDevice.productModel];
        for (NSString * productModel in [[KDSAllPhotoShowImgModel shareModel].productModel allKeys]) {
            if ([productModel isEqualToString:self.lock.wifiDevice.productModel]) {
                self.WifiLockModel.text = [NSString stringWithFormat:@"%@：%@", Localized(@"lockModel"), [[KDSAllPhotoShowImgModel shareModel].productModel objectForKey:self.lock.wifiDevice.productModel]];
                break;
            }
        }
    }
    [modelAndPowerSupView addSubview:WifiLockModel];
    [WifiLockModel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(modelAndPowerSupView.mas_centerY).offset(0);
        make.left.mas_equalTo(modelAndPowerSupView.mas_left).offset(0);
        make.right.mas_equalTo(lockEnergyLb.mas_left).offset(KDSSSALE_WIDTH(-30));
        make.height.equalTo(@12);
    }];
    
    UIView *grayView = [UIView new];
    grayView.backgroundColor = KDSRGBColor(0xf2, 0xf2, 0xf2);
    [self.view addSubview:grayView];
    [grayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.height.mas_equalTo(KDSScreenHeight - KDSSSALE_HEIGHT(378));
    }];
    UIView *cornerView = [UIView new];
    cornerView.backgroundColor = UIColor.whiteColor;
    cornerView.layer.cornerRadius = 4;
    cornerView.clipsToBounds = YES;
    [grayView addSubview:cornerView];
    if (self.funcImgListArray.count >= 7) {
        [cornerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(grayView).offset(12);
            make.left.equalTo(grayView).offset(15);
            make.bottom.equalTo(grayView).offset(1);
            make.right.equalTo(grayView).offset(-15);
        }];
    }else{
        [cornerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(grayView).offset(12);
            make.left.equalTo(grayView).offset(15);
            make.bottom.equalTo(grayView).offset(-17);
            make.right.equalTo(grayView).offset(-15);
        }];
    }
    
    [cornerView addSubview:self.collectionView];
    // 注册
    [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([KDSBleAddWiFiFuncListCell class]) bundle:nil] forCellWithReuseIdentifier:deviceListCellId];
    ////添加猫眼、网关父视图
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(cornerView);
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
            int pin = 0, fp = 0, card = 0, membs = 0,face =0;
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
            for (KDSPwdListModel * m in faceList) {
                if (m.num) {
                    face++;
                }
            }
            for (KDSAuthMember * n in members) {
                if (n.uname) {
                    membs++;
                }
            }
            [self setNumberOfPIN:pin fingerprint:fp card:card face:face member:membs];
        } error:nil failure:nil];
    } error:nil failure:nil];
}

///设置密码、指纹、卡片、共享用户数量。负数不设置。
- (void)setNumberOfPIN:(int)pin fingerprint:(int)fp card:(int)card face:(int)face member:(int)members
{
    NSString *pinUnit = pin>1 ? @" groups" : @" group";
    NSString *fpUnit = fp>1 ? @" pieces" : @" piece";
    NSString *cardUnit = card>1 ? @" pieces" : @" piece";
    NSString *faceUnit = face>1 ? @" pieces" : @" piece";
    NSString *pUnit = members>1 ? @" persons" : @" person";
    if ([[KDSTool getLanguage] hasPrefix:JianTiZhongWen])
    {
        pinUnit = @"组";
        fpUnit = @"组";
        cardUnit = @"张";
        faceUnit = @"组";
        pUnit = @"台";
    }
    else if ([[KDSTool getLanguage] containsString:FanTiZhongWen])
    {
        pinUnit = @"組";
        fpUnit = @"組";
        cardUnit = @"張";
        faceUnit = @"組";
        pUnit = @"台";
    }
    else if ([[KDSTool getLanguage] containsString:@"th"])
    {
        pinUnit = pin>1 ? @" groups" : @" group";
        fpUnit = fp>1 ? @" pieces" : @" piece";
        cardUnit = card>1 ? @" pieces" : @" piece";
        faceUnit = face>1 ? @" pieces" : @" piece";
        pUnit = members>1 ? @" persons" : @" person";
    }
    
    if (face >=0) [self.funcNumListArray replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"(%d%@)", face, pinUnit]];
    if (pin >= 0)[self.funcNumListArray replaceObjectAtIndex:1 withObject:[NSString stringWithFormat:@"(%d%@)", pin, pinUnit]];
    if (fp >= 0) [self.funcNumListArray replaceObjectAtIndex:2 withObject:[NSString stringWithFormat:@"(%d%@)", fp, fpUnit]];
    if (card >= 0) [self.funcNumListArray replaceObjectAtIndex:3 withObject:[NSString stringWithFormat:@"(%d%@)", card, cardUnit]];
    if (members >= 0) [self.funcNumListArray replaceObjectAtIndex:4 withObject:[NSString stringWithFormat:@"(%d%@)", members, pUnit]];
    
    [self.collectionView reloadData];
}

#pragma mark UICollecionViewDelegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.funcImgListArray.count;
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    KDSBleAddWiFiFuncListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:deviceListCellId forIndexPath:indexPath];
    
    cell.backgroundColor = UIColor.clearColor;
    cell.funcImgView.image = [UIImage imageNamed:self.funcImgListArray[indexPath.row]];
    cell.funcNameLb.text = self.funcNameListArray[indexPath.row];
    cell.rightLine.hidden = (indexPath.row + 1) % 3 == 0 ? YES : NO;
    //    cell.bottomLine.hidden = self.funcImgListArray.count / 3 >0 ? YES : NO;
    cell.funcNumLb.text = @"";
    if ([cell.funcNameLb.text isEqualToString:Localized(@"faceRecognition")]) {///面容识别
        cell.funcNumLb.text = self.funcNumListArray[0];
    }if ([cell.funcNameLb.text isEqualToString:Localized(@"password")]) {///密码
        cell.funcNumLb.text = self.funcNumListArray[1];
    }if ([cell.funcNameLb.text isEqualToString:Localized(@"fingerprint")]) {///指纹
        cell.funcNumLb.text = self.funcNumListArray[2];
    }if ([cell.funcNameLb.text isEqualToString:Localized(@"card")]) {///卡片
        cell.funcNumLb.text = self.funcNumListArray[3];
    }if ([cell.funcNameLb.text isEqualToString:Localized(@"deviceShare")]) {///设备共享
        cell.funcNumLb.text = self.funcNumListArray[4];
    }
    
    
    return cell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeMake((kScreenWidth - 32) / 3.0, (260 * kScreenWidth / 375.0 - 1) / 2.0);
    return size;
}

// 两个cell之间的最小间距，是由API自动计算的，只有当间距小于该值时，cell会进行换行
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}
// 两行之间的最小间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    KDSBleAddWiFiFuncListCell * cell = (KDSBleAddWiFiFuncListCell *)[self collectionView:collectionView cellForItemAtIndexPath:indexPath];
    cell.funcNameLb.text = self.funcNameListArray[indexPath.row];
    if ([cell.funcNameLb.text isEqualToString:Localized(@"tempPassword")]) {
        //临时密码
        KDSWifiLockPwdShareVC * vc = [KDSWifiLockPwdShareVC new];
        vc.lock = self.lock;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if ([cell.funcNameLb.text isEqualToString:Localized(@"realTimeVideo")]){
        //实时视频
        if (self.lock.wifiDevice.powerSave.intValue == 1) {
            ///锁已开启节能模式，无法查看门外情况
            UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:@"锁已开启节能模式，无法查看门外情况" message:@"请更换电池或进入管理员模式进行关闭" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            
            //修改title
            NSMutableAttributedString *alertTitleStr = [[NSMutableAttributedString alloc] initWithString:@"锁已开启节能模式，无法查看门外情况"];
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
        XMPlayController * vc = [XMPlayController new];
        vc.lock = self.lock;
        vc.isActive = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if ([cell.funcNameLb.text isEqualToString:Localized(@"dynamicRecording")]){
        //动态记录
        KDSMediaLockRecordDetailsVC * vc = [KDSMediaLockRecordDetailsVC new];
        vc.lock = self.lock;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if ([cell.funcNameLb.text isEqualToString:Localized(@"myAlbum")]){
        //我的相册
        KDSMyAlbumVC * vc = [KDSMyAlbumVC new];
        vc.lock = self.lock;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if ([cell.funcNameLb.text isEqualToString:Localized(@"faceRecognition")]){
        //面容识别
        KDSWifiLockPwdListVC *vc = [KDSWifiLockPwdListVC new];
        vc.keyType = KDSBleKeyTypeFace;
        vc.lock = self.lock;
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([cell.funcNameLb.text isEqualToString:Localized(@"password")]){
        //密码
        KDSWifiLockPwdListVC *vc = [KDSWifiLockPwdListVC new];
        vc.keyType = KDSBleKeyTypePIN;
        vc.lock = self.lock;
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([cell.funcNameLb.text isEqualToString:Localized(@"fingerprint")]){
        //指纹
        KDSWifiLockPwdListVC *vc = [KDSWifiLockPwdListVC new];
        vc.keyType = KDSBleKeyTypeFingerprint;
        vc.lock = self.lock;
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([cell.funcNameLb.text isEqualToString:Localized(@"card")]){
        //卡片
        KDSWifiLockPwdListVC *vc = [KDSWifiLockPwdListVC new];
        vc.keyType = KDSBleKeyTypeRFID;
        vc.lock = self.lock;
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([cell.funcNameLb.text isEqualToString:Localized(@"IntelligentSwitchImg")]){
        //智能开关
        KDSSwitchLinkageDetailVC * vc = [KDSSwitchLinkageDetailVC new];
        vc.lock = self.lock;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if ([cell.funcNameLb.text isEqualToString:Localized(@"deviceShare")]){
        //设备分享
        KDSLockKeyVC *vc = [KDSLockKeyVC new];
        vc.keyType = KDSBleKeyTypeReserved;
        vc.lock = self.lock;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if ([cell.funcNameLb.text isEqualToString:Localized(@"more")]){
        if (self.lock.wifiDevice.distributionNetwork == 3) {
            
            KDSMediaLockMoreSettingVC * vc = [KDSMediaLockMoreSettingVC new];
            vc.lock = self.lock;
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            //更多
            KDSWIfiLockMoreSettingVC * vc = [KDSWIfiLockMoreSettingVC new];
            vc.lock = self.lock;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark --Lazy Load

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = UIColor.whiteColor;
        _collectionView.layer.masksToBounds = YES;
        _collectionView.layer.shadowColor = [UIColor colorWithRed:121/255.0 green:146/255.0 blue:167/255.0 alpha:0.1].CGColor;
        _collectionView.layer.shadowOffset = CGSizeMake(0,-4);
        _collectionView.layer.shadowOpacity = 1;
        _collectionView.layer.shadowRadius = 12;
        _collectionView.layer.cornerRadius = 5;
        _collectionView.tag = 836914;
        [_collectionView flashScrollIndicators];
    }
    return _collectionView;
}

- (NSMutableArray *)funcImgListArray
{
    if (!_funcImgListArray) {
        _funcImgListArray = [NSMutableArray array];
    }
    return _funcImgListArray;
}
- (NSMutableArray *)funcNameListArray
{
    if (!_funcNameListArray) {
        _funcNameListArray = [NSMutableArray array];
    }
    return _funcNameListArray;
}
- (NSMutableArray *)funcNumListArray
{
    if (!_funcNumListArray) {
        _funcNumListArray = [NSMutableArray array];
    }
    return _funcNumListArray;
}

#pragma mark - 控件等事件方法。
///点击返回按钮。
- (void)backBtnAction:(UIButton *)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - 通知
///当电量状态刷新时，修改当前页面的电量。
- (void)refreshInterfaceWhenDeviceDidSync:(NSNotification *)noti
{
   // [self setPowerWithImage:nil power:self.lock.bleTool.connectedPeripheral.power date:nil];
}

///mqtt上报事件通知。#@#@########
- (void)wifimqttEventNotification:(NSNotification *)noti {
    
    
    
    MQTTSubEvent event = noti.userInfo[MQTTEventKey];
    NSDictionary *param = noti.userInfo[MQTTEventParamKey];
    
    
    if (![self.lock.wifiDevice.wifiSN isEqualToString:param[@"wfId"]]) {
        return;
    }
    
    
    NSNumber *power;
    if ([event isEqualToString:MQTTSubEventLockInf]) {
        power = param[@"eventparams"][@"power"];
    }else if ([event isEqualToString:MQTTSubEventLockMultiInfo]) {
        power = param[@"eventparams"][@"lockInfo"][@"power"];
    }
    
    
    
    __weak __typeof(self)weakSelf = self;
    if (power) {
        //self.lock.wifiDevice.power = [power unsignedIntValue];

        dispatch_block_t block= ^(){
            [weakSelf setPowerWithImage:nil power:weakSelf.lock.wifiDevice.power date:nil];
        };
        dispatch_main_async_safe(block);
    }
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([viewController isKindOfClass:[KDSBleAddWiFiLockDetailsVC class]]) {
         [navigationController setNavigationBarHidden:YES animated:YES];
    }
}

@end
