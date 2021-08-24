//
//  KDSGWLockKeyVC.m
//  KaadasLock
//
//  Created by orange on 2019/4/28.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSGWLockKeyVC.h"
#import "KDSLockKeyCell.h"
#import "MBProgressHUD+MJ.h"
#import "KDSGWAddPINVC.h"
#import "KDSAddMemberVC.h"
#import "KDSMQTT.h"
#import "KDSGWLockKeyDetailsVC.h"
#import "KDSDBManager+GW.h"
#import "KDSGWAddPINPermanentVC.h"
#import "KDSDBManager+GW.h"
#import "KDSHttpManager+ZigBeeLock.h"

@interface KDSGWLockKeyVC () <UITableViewDelegate, UITableViewDataSource>

///table footer view, use for displaying no data.
@property (nonatomic, strong) UIView *footerView;
///数据模型数组[KDSPwdListModel, KDSAuthMember]。
@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, assign) unsigned  currentIndex;

@end

@implementation KDSGWLockKeyVC

#pragma mark - getter setter
- (UIView *)footerView
{
    if (!_footerView)
    {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 66)];
        UILabel *label = [UILabel new];
        label.textColor = KDSRGBColor(0x8e, 0x8e, 0x93);
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentCenter;
        switch (self.keyType)
        {
            case KDSGWKeyTypeReserved:
                label.text = Localized(@"noShareUser");
                break;
                
            case KDSGWKeyTypePIN:
                label.text = Localized(@"noPassword");
                break;
                
            case KDSGWKeyTypeFingerprint:
                label.text = Localized(@"noFingerprint");
                break;
                
            case KDSGWKeyTypeRFID:
                label.text = Localized(@"noCard");
                break;
                
            default:
                break;
        }
        [headerView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(headerView).offset(20);
            make.bottom.equalTo(headerView);
            make.right.equalTo(headerView).offset(-20);
        }];
        _footerView = headerView;
    }
    return _footerView;
}

#pragma mark - life cycle & UI
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.enablePulldown = YES;
    [self setupUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshInterfaceWhenGWLockPwdDidSync:) name:KDSGWLockPwdNotification object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadNewData];
}

- (void)setupUI
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 18 + (self.keyType==KDSBleKeyTypeReserved ? 0.001 : 44) + (self.keyType==KDSGWKeyTypeReserved ? 20 : 37) + 44 + 37)];
    
    UIView *cornerView = [UIView new];
    cornerView.clipsToBounds = YES;
    cornerView.backgroundColor = UIColor.whiteColor;
    cornerView.layer.cornerRadius = 4;
    [headerView addSubview:cornerView];
    [cornerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerView).offset(18);
        make.centerX.equalTo(@0);
        make.width.equalTo(@(kScreenWidth - 30));
        make.height.equalTo(@(self.keyType==KDSGWKeyTypeReserved ? 0.001 : 44));
    }];
    
    UILabel *syncLabel = [UILabel new];
    syncLabel.font = [UIFont systemFontOfSize:12];
    syncLabel.textColor = KDSRGBColor(0x99, 0x99, 0x99);
    [cornerView addSubview:syncLabel];
    [syncLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cornerView).offset(15);
        make.centerY.equalTo(@0);
    }];
    
    UIButton *syncBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    syncBtn.layer.cornerRadius = 9.5;
    syncBtn.backgroundColor = UIColor.whiteColor;
    syncBtn.layer.borderWidth = 1;
    syncBtn.layer.borderColor = KDSRGBColor(0x1f, 0x96, 0xf7).CGColor;
    [syncBtn setTitle:Localized(@"synchronize") forState:UIControlStateNormal];
    [syncBtn setTitleColor:KDSRGBColor(0x1f, 0x96, 0xf7) forState:UIControlStateNormal];
    syncBtn.titleLabel.font = [UIFont systemFontOfSize:11];
    CGSize size = [syncBtn.currentTitle sizeWithAttributes:@{NSFontAttributeName : syncBtn.titleLabel.font}];
    [syncBtn addTarget:self action:@selector(clickSyncBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [cornerView addSubview:syncBtn];
    [syncBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(cornerView).offset(-15);
        make.centerY.equalTo(@0);
        make.width.equalTo(@(MAX(45, size.width + 19)));
        make.height.equalTo(@19);
    }];
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.layer.cornerRadius = 22;
    addBtn.backgroundColor = UIColor.whiteColor;
    [addBtn setTitleColor:KDSRGBColor(0x1f, 0x96, 0xf7) forState:UIControlStateNormal];
    addBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    UIImage *image = [UIImage imageNamed:@"plus"];
    [addBtn setImage:image forState:UIControlStateNormal];
    [addBtn setImage:image forState:UIControlStateHighlighted];
    [addBtn addTarget:self action:@selector(clickAddBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:addBtn];
    
    UIImageView *flagIV = [[UIImageView alloc] init];
    flagIV.contentMode = UIViewContentModeScaleAspectFit;
    [headerView addSubview:flagIV];
    [flagIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerView).offset(40);
        make.centerY.equalTo(addBtn);
        make.width.height.equalTo(@40);
    }];
    
    self.tableView.rowHeight = 75;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.tableHeaderView = headerView;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    switch (self.keyType)
    {
        case KDSGWKeyTypeReserved:
            self.navigationTitleLabel.text = Localized(@"authUserMgr");
            [addBtn setTitle:Localized(@"shareUser") forState:UIControlStateNormal];
            flagIV.image = [UIImage imageNamed:@"member"];
            break;
            
        case KDSGWKeyTypePIN:
            self.navigationTitleLabel.text = Localized(@"password");
            syncLabel.text = Localized(@"pwdSync");
            flagIV.image = [UIImage imageNamed:@"bigPassword"];
            [addBtn setTitle:Localized(@"addPwd") forState:UIControlStateNormal];
            break;
            
        case KDSGWKeyTypeFingerprint:
            self.navigationTitleLabel.text = Localized(@"fingerprint");
            syncLabel.text = Localized(@"fingerprintSync");
            flagIV.image = [UIImage imageNamed:@"bigFingerprint"];
            [addBtn setTitle:Localized(@"addFingerprint") forState:UIControlStateNormal];
            break;
            
        case KDSGWKeyTypeRFID:
            self.navigationTitleLabel.text = Localized(@"card");
            syncLabel.text = Localized(@"cardSync");
            flagIV.image = [UIImage imageNamed:@"bigCard"];
            [addBtn setTitle:Localized(@"addCard") forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
    image = addBtn.currentImage;
    size = [addBtn.currentTitle sizeWithAttributes:@{NSFontAttributeName : addBtn.titleLabel.font}];
    addBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    CGFloat width = size.width + image.size.width + 29 + 60;
    CGFloat i = (width - size.width - 29 - image.size.width) / 2 + size.width + 29;
    CGFloat t = (width - size.width - 29 - image.size.width) / 2 - image.size.width;
    addBtn.imageEdgeInsets = UIEdgeInsetsMake(0, i, 0, 0 );
    addBtn.titleEdgeInsets = UIEdgeInsetsMake(0, t, 0, 0);
    [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(headerView).offset(-15);
        make.top.equalTo(cornerView.mas_bottom).offset(self.keyType==KDSGWKeyTypeReserved ? 20 : 37);
        make.width.equalTo(@(width));
        make.height.equalTo(@44);
    }];
}

///刷新表视图。调用此方法前请确保已经对数据源进行了更新。
- (void)reloadData
{
    if (!self.dataArr.count)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.tableView.tableFooterView = self.footerView;
        });
    }
    else
    {
        self.tableView.tableFooterView = [UIView new];
    }
    if (self.keyType != KDSBleKeyTypeReserved)
    {
        self.dataArr = [self.dataArr sortedArrayUsingComparator:^NSComparisonResult(KDSPwdListModel *_Nonnull obj1, KDSPwdListModel *_Nonnull obj2) {
            return obj1.userId > obj2.userId;
        }];
    }
    [self.tableView reloadData];
}

- (void)loadNewData
{
    if (self.keyType == KDSBleKeyTypeReserved)
    {
        [[KDSMQTTManager sharedManager] getShareUserListWithGW:self.lock.gw.model device:self.lock.gwDevice completion:^(NSError * _Nullable error, NSArray<KDSAuthCatEyeMember *> * _Nullable records) {
            self.tableView.mj_header.state = MJRefreshStateIdle;
            self.dataArr = records;
            [self.tableView reloadData];
        }];
    }
    else
    {
        if (self.keyType == KDSGWKeyTypeReserved) return;
        
        if (([[self.lock.gwDevice.lockversion componentsSeparatedByString:@";"][0] caseInsensitiveCompare:@"8100Z"] == NSOrderedSame
        || [[self.lock.gwDevice.lockversion componentsSeparatedByString:@";"][0] caseInsensitiveCompare:@"8100A"] == NSOrderedSame) && self.lock.gwDevice.lockversion)
        {
            NSMutableArray * pwds = [NSMutableArray array];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            NSDictionary *texts = @{@(KDSGWKeyTypePIN):Localized(@"synchronizingPassword"), @(KDSGWKeyTypeRFID):Localized(@"synchronizingCard"), @(KDSGWKeyTypeFingerprint):Localized(@"synchronizingFingerprint")};
            hud.label.text = texts[@(self.keyType)];
            hud.removeFromSuperViewOnHide = YES;
            [[KDSHttpManager sharedManager] getZigBeeInfoWithGwSN:self.lock.gwDevice.gwId uid:[KDSUserManager sharedManager].user.uid zigbeeSN:self.lock.gwDevice.deviceId success:^(id responseObject) {
                [hud hideAnimated:NO];
                NSArray *  pwdListArr = [KDSPwdListModel mj_objectArrayWithKeyValuesArray:responseObject[@"pwdList"] ?: @[]];
                //周计划数组
                NSArray * weekScheduleArr = [KDSGWLockSchedule mj_objectArrayWithKeyValuesArray:responseObject[@"weekSchedule"] ?: @[]];
                //年计划数组
                NSArray * yearScheduleArr = [KDSGWLockSchedule mj_objectArrayWithKeyValuesArray:responseObject[@"yearSchedule"] ?: @[]];
                for (KDSPwdListModel * pwdModel in pwdListArr) {
                    if (pwdModel.userId > 4 && pwdModel.userId < 9) {
                        pwdModel.pwdType = KDSServerKeyTpyeTempPIN;
                        [pwds addObject:pwdModel];
                    }else{
                        pwdModel.pwdType = KDSServerKeyTpyePIN;
                        pwdModel.type = KDSServerCycleTpyeForever;
                        if (pwdModel.userType == 1) {//有计划策略
                            for (KDSGWLockSchedule * schedule in weekScheduleArr) {
                                //周计划
                                if (pwdModel.userId == schedule.userId) {
                                    pwdModel.daysMask = schedule.daysMask;
                                    pwdModel.startHour = schedule.startHour;
                                    pwdModel.endHour = schedule.endHour;
                                    pwdModel.startMinutes = schedule.startMinutes;
                                    pwdModel.endMinutes = schedule.endMinutes;
                                    pwdModel.type = KDSServerCycleTpyeCycle;
                                    break;
                                }
                            }
                            for (KDSGWLockSchedule * schedule in yearScheduleArr) {
                                 //年计划
                                if (pwdModel.userId == schedule.userId) {
                                    pwdModel.endTime = schedule.endTime;
                                    pwdModel.startTime = schedule.startTime;
                                    pwdModel.endHour = schedule.endHour;
                                    pwdModel.startMinutes = schedule.startMinutes;
                                    pwdModel.endMinutes = schedule.endMinutes;
                                    pwdModel.type = KDSServerCycleTpyePeriod;
                                    break;
                                }
                            }
                        }
                        
                        if (pwdModel.userId != 9) {
                            [pwds addObject:pwdModel];
                        }
                    }
                }
                
                self.dataArr = pwds;
                self.dataArr = [self.dataArr sortedArrayUsingComparator:^NSComparisonResult(KDSPwdListModel *_Nonnull obj1, KDSPwdListModel *_Nonnull obj2) {
                        return obj1.userId > obj2.userId;
                }];
                [self reloadData];
                self.tableView.mj_header.state = MJRefreshStateIdle;
                [hud hideAnimated:NO];
            } error:^(NSError * _Nonnull error) {
                [hud hideAnimated:NO];
                [MBProgressHUD showError:Localized(@"synchronizeFailed")];
                
            } failure:^(NSError * _Nonnull error) {
                [hud hideAnimated:NO];
                [MBProgressHUD showError:Localized(@"synchronizeFailed")];
            }];
            
        }else{
            
            NSArray *passwords = [[KDSDBManager sharedManager] queryPasswordsWithLock:self.lock.gwDevice type:99];
            NSMutableArray *pins = [NSMutableArray array];
            for (KDSPwdListModel *m in passwords)
            {
                if (m.pwdType == KDSServerKeyTpyePIN || m.pwdType == KDSServerKeyTpyeTempPIN)
                {
                    ////胁迫密码不展示在密码列表里面（胁迫警告项会专门展示）
                    if (m.num.intValue != 9) {
                        [pins addObject:m];
                    }
                }
            }
            self.dataArr = pins.copy;
            
            [self reloadData];
            self.tableView.mj_header.state = MJRefreshStateIdle;
        }
    }
}

#pragma - MQTT方法
/**
 *@brief 递归获取[index1, index2)编号的密匙信息。不包含index2的编号，如果index1=index2，则递归结束。
 *@param type 密匙类型。
 *@param index1 起始密匙编号。
 *@param index2 结束密匙编号。
 *@param container 由使用者负责初始化的可变数组，每个编号递归结束后，结果会存入此数组中。暂时使用蓝牙的密码类型，只用到编号。
 *@param completion 递归结束执行的回调。如果有一个编号获取失败或者全部编号获取完毕后执行。
 */
- (void)recursiveGetKeys:(KDSGWKeyType)type from:(unsigned)index1 to:(unsigned)index2 container:(NSMutableArray<KDSPwdListModel *> *)container completion:(void(^)(void))completion
{
    /*
     方案一：发一条收到回复再发下一条
     NSLog(@"同步的时候的开始编号：%d～结束编号：%d",index1,index2);
     if (index1 == index2)
     {
     !completion ?: completion();
     return;
     }
     [[KDSMQTTManager sharedManager] dl:self.lock.gwDevice manageKey:1 withPwd:nil number:index1 type:(int)type completion:^(NSError * _Nullable error, BOOL success, NSString * _Nullable status, NSString * _Nullable userType) {
     
     KDSPwdListModel *m = [KDSPwdListModel new];
     m.num = [NSString stringWithFormat:@"%02u", index1];
     KDSGWLockSchedule * currentSchedule = [KDSGWLockSchedule new];
     currentSchedule.scheduleId = currentSchedule.userId = m.num.intValue;
     NSLog(@"当前遍历的策略ID：%d-%d状态：%@",currentSchedule.scheduleId,currentSchedule.userId,currentSchedule);
     
     if (type == KDSGWKeyTypePIN)
     {
     if (([[self.lock.gwDevice.lockversion componentsSeparatedByString:@";"][0] caseInsensitiveCompare:@"8100Z"] == NSOrderedSame
     || [[self.lock.gwDevice.lockversion componentsSeparatedByString:@";"][0] caseInsensitiveCompare:@"8100A"] == NSOrderedSame) && self.lock.gwDevice.lockversion) {//20组密码：0～4/10～19永久，5～8临时，9胁迫密码////caseInsensitiveCompare忽略大小写比较
     if (index1 > 4 && index1 < 9) {
     m.pwdType = KDSServerKeyTpyeTempPIN;
     [self recursiveGetKeys:type from:index1 + 1 to:index2 container:container completion:completion];
     }else{
     m.pwdType = KDSServerKeyTpyePIN;//永久密码才有时间策略
     //userType: 0 永久性密钥 userType: 1 策略密钥 userType: 3 管理员密钥 userType: 4 无权限密钥
     if (userType.intValue ==1) {
     currentSchedule.yearAndWeek = @"year";
     [[KDSMQTTManager sharedManager] dl:self.lock.gwDevice scheduleAction:1 withSchedule:currentSchedule completion:^(NSError * _Nullable error, BOOL success, KDSGWLockSchedule * _Nullable schedule) {
     
     if (success)
     {//查的年计划
     NSLog(@"获取到的年密码策略：%@",schedule);
     m.startTime = schedule.beginTime;
     m.endTime = schedule.endTime;
     m.type = KDSServerCycleTpyePeriod;
     [self recursiveGetKeys:type from:index1 + 1 to:index2 container:container completion:completion];
     
     }else{//没有查到年计划再去查周计划
     currentSchedule.yearAndWeek = @"week";
     [[KDSMQTTManager sharedManager] dl:self.lock.gwDevice scheduleAction:1 withSchedule:currentSchedule completion:^(NSError * _Nullable error, BOOL success, KDSGWLockSchedule * _Nullable schedule) {
     if (success) {
     NSLog(@"获取到的周密码策略：%@",schedule);
     NSDateFormatter * fmt = [KDSUserManager sharedManager].dateFormatter;
     fmt.dateFormat = @"HH:mm";
     NSMutableArray *items = [NSMutableArray arrayWithCapacity:7];
     for (int i = 0; i < 7; ++i)
     {
     [items addObject:@((schedule.mask >> i) & 0x1)];
     }
     m.items = items.copy;
     m.startTime = @([fmt dateFromString:[NSString stringWithFormat:@"%d:%d",schedule.beginH,schedule.beginMin]].timeIntervalSince1970).stringValue;
     m.endTime = @([fmt dateFromString:[NSString stringWithFormat:@"%d:%d",schedule.endH,schedule.endMin]].timeIntervalSince1970).stringValue;
     m.type = KDSServerCycleTpyeCycle;
     }else{
     m.type = KDSServerCycleTpyeForever;
     }
     [self recursiveGetKeys:type from:index1 + 1 to:index2 container:container completion:completion];
     }];
     }
     }];
     }else if (userType.intValue ==0){
     m.type = KDSServerCycleTpyeForever;
     [self recursiveGetKeys:type from:index1 + 1 to:index2 container:container completion:completion];
     }
     }
     }else{
     m.pwdType = (index1<5 || index1==9) ? KDSServerKeyTpyePIN : KDSServerKeyTpyeTempPIN;
     m.type = (index1 < 5 || index1 == 9) ? KDSServerCycleTpyeForever: KDSServerKeyTpyeTempPIN;
     [self recursiveGetKeys:type from:index1 + 1 to:index2 container:container completion:completion];
     }
     }else if (type == KDSGWKeyTypeRFID)
     {//卡片
     
     }else if (type == KDSGWKeyTypeFingerprint)
     {//指纹
     
     }if (success)
     {
     [container addObject:m];
     //            [[KDSDBManager sharedManager] insertPasswords:container withLock:self.lock.gwDevice];
     NSLog(@"添加密码成功：%@-%@",m,container);
     }else if (error && error.code == 0)
     {
     [[KDSDBManager sharedManager] deletePasswords:@[m] withLock:self.lock.gwDevice];
     NSLog(@"删除密码成功：%@",m);
     }
     }];
     
     */
    
    //方案二：先发一组条然后在收到一条发一条（网关处理有时差，所以第一次多发几条网关会缓存在储存池）
    NSLog(@"同步的时候的开始编号：%d～结束编号：%d",index1,index2);
    __weak typeof(self) weakSelf = self;
    [[KDSMQTTManager sharedManager] dl:self.lock.gwDevice manageKey:1 withPwd:nil number:index1 type:(int)type completion:^(NSError * _Nullable error, BOOL success, NSString * _Nullable status, NSString * _Nullable userType) {
        
        KDSPwdListModel *m = [KDSPwdListModel new];
        m.num = [NSString stringWithFormat:@"%02u", index1];
        KDSGWLockSchedule * currentSchedule = [KDSGWLockSchedule new];
        currentSchedule.scheduleId = currentSchedule.userId = m.num.intValue;
        NSLog(@"当前遍历的策略ID：%d-%d状态：%@",currentSchedule.scheduleId,currentSchedule.userId,currentSchedule);
        
        if (type == KDSGWKeyTypePIN)
        {
            if (([[self.lock.gwDevice.lockversion componentsSeparatedByString:@";"][0] caseInsensitiveCompare:@"8100Z"] == NSOrderedSame
                 || [[self.lock.gwDevice.lockversion componentsSeparatedByString:@";"][0] caseInsensitiveCompare:@"8100A"] == NSOrderedSame) && self.lock.gwDevice.lockversion) {//20组密码：0～4/10～19永久，5～8临时，9胁迫密码////caseInsensitiveCompare忽略大小写比较
                if (index1 > 4 && index1 < 9) {
                    m.pwdType = KDSServerKeyTpyeTempPIN;
                    
                    
                }else{
                    m.pwdType = KDSServerKeyTpyePIN;//永久密码才有时间策略
                    //userType: 0 永久性密钥 userType: 1 策略密钥 userType: 3 管理员密钥 userType: 4 无权限密钥
                    if (userType.intValue ==1) {
                        currentSchedule.yearAndWeek = @"year";
                        [[KDSMQTTManager sharedManager] dl:self.lock.gwDevice scheduleAction:1 withSchedule:currentSchedule completion:^(NSError * _Nullable error, BOOL success, KDSGWLockSchedule * _Nullable schedule) {
                            
                            if (success)
                            {//查的年计划
                                NSLog(@"获取到的年密码策略：%@",schedule);
                                m.startTime = schedule.beginTime;
                                m.endTime = schedule.endTime;
                                m.type = KDSServerCycleTpyePeriod;
                                
                                
                            }else{//没有查到年计划再去查周计划
                                currentSchedule.yearAndWeek = @"week";
                                [[KDSMQTTManager sharedManager] dl:self.lock.gwDevice scheduleAction:1 withSchedule:currentSchedule completion:^(NSError * _Nullable error, BOOL success, KDSGWLockSchedule * _Nullable schedule) {
                                    if (success) {
                                        NSLog(@"获取到的周密码策略：%@",schedule);
                                        NSDateFormatter * fmt = [KDSUserManager sharedManager].dateFormatter;
                                        fmt.dateFormat = @"HH:mm";
                                        NSMutableArray *items = [NSMutableArray arrayWithCapacity:7];
                                        for (int i = 0; i < 7; ++i)
                                        {
                                            [items addObject:@((schedule.mask >> i) & 0x1)];
                                        }
                                        m.items = items.copy;
                                        m.startTime = @([fmt dateFromString:[NSString stringWithFormat:@"%d:%d",schedule.beginH,schedule.beginMin]].timeIntervalSince1970).stringValue;
                                        m.endTime = @([fmt dateFromString:[NSString stringWithFormat:@"%d:%d",schedule.endH,schedule.endMin]].timeIntervalSince1970).stringValue;
                                        m.type = KDSServerCycleTpyeCycle;
                                        if (weakSelf.currentIndex == index2 -1)
                                        {
                                            !completion ?: completion();
                                            return;
                                        }
                                    }else{
                                        m.type = KDSServerCycleTpyeForever;
                                    }
                                    
                                }];
                            }
                        }];
                    }else if (userType.intValue ==0){
                        m.type = KDSServerCycleTpyeForever;
                    }
                }
            }else{
                m.pwdType = (index1<5 || index1==9) ? KDSServerKeyTpyePIN : KDSServerKeyTpyeTempPIN;
                m.type = (index1 < 5 || index1 == 9) ? KDSServerCycleTpyeForever: KDSServerKeyTpyeTempPIN;
                
            }
        }else if (type == KDSGWKeyTypeRFID)
        {//卡片
            
        }else if (type == KDSGWKeyTypeFingerprint)
        {//指纹
            
        }if (success)
        {
            [container addObject:m];
            //            [[KDSDBManager sharedManager] insertPasswords:container withLock:self.lock.gwDevice];
            NSLog(@"添加密码成功：%@-%@",m,container);
        }else if (error && error.code == 0)
        {
            [[KDSDBManager sharedManager] deletePasswords:@[m] withLock:self.lock.gwDevice];
            NSLog(@"删除密码成功：%@",m);
        }
        if (currentSchedule.scheduleId == index2 -1)
        {
            !completion ?: completion();
            return;
        }else{
            if (self.currentIndex < index2-1) {
                self.currentIndex ++;
                [self recursiveGetKeys:type from:self.currentIndex to:index2 container:container completion:completion];
            }
        }
    }];
    if (index1 < 9) {
        self.currentIndex ++;
        [self recursiveGetKeys:type from:index1 + 1 to:index2 container:container completion:completion];
    }
}

///获取已设置的所有密码，并提取出KDSPwdListModel后，递归查询编号是否是计划密码，如是，则会设置相应的计划。index 参数外部使用时必须传0，completion是递归完毕执行的回调。假定pwds传入时已按照编号升序排列。
- (void)recursiveGetScheduleWithPwds:(KDSPwdListModel *)pwds fromIndex:(NSInteger)index completion:(nullable void(^)(void))completion{
    
}

#pragma mark - 控件等事件方法。
///点击同步按钮，同步密码、指纹、卡片。
- (void)clickSyncBtnAction:(UIButton *)sender
{
    //无网络的时候不让添加密码
    if (![KDSUserManager sharedManager].netWorkIsAvailable) {
        [MBProgressHUD showError:Localized(@"networkNotAvailable")];
        return;
    }
    if (self.keyType == KDSGWKeyTypeReserved) return;
    NSMutableArray * pwds = [NSMutableArray array];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    NSDictionary *texts = @{@(KDSGWKeyTypePIN):Localized(@"synchronizingPassword"), @(KDSGWKeyTypeRFID):Localized(@"synchronizingCard"), @(KDSGWKeyTypeFingerprint):Localized(@"synchronizingFingerprint")};
    hud.label.text = texts[@(self.keyType)];
    hud.removeFromSuperViewOnHide = YES;
    if (([[self.lock.gwDevice.lockversion componentsSeparatedByString:@";"][0] caseInsensitiveCompare:@"8100Z"] == NSOrderedSame
    || [[self.lock.gwDevice.lockversion componentsSeparatedByString:@";"][0] caseInsensitiveCompare:@"8100A"] == NSOrderedSame) && self.lock.gwDevice.lockversion)
    {
        [[KDSHttpManager sharedManager] getZigBeeInfoWithGwSN:self.lock.gwDevice.gwId uid:[KDSUserManager sharedManager].user.uid zigbeeSN:self.lock.gwDevice.deviceId success:^(id responseObject) {
                NSArray *  pwdListArr = [KDSPwdListModel mj_objectArrayWithKeyValuesArray:responseObject[@"pwdList"] ?: @[]];
                //周计划数组
                NSArray * weekScheduleArr = [KDSGWLockSchedule mj_objectArrayWithKeyValuesArray:responseObject[@"weekSchedule"] ?: @[]];
                //年计划数组
                NSArray * yearScheduleArr = [KDSGWLockSchedule mj_objectArrayWithKeyValuesArray:responseObject[@"yearSchedule"] ?: @[]];
                NSLog(@"获取到的密码数组：%@以及完整的数据：%@",pwdListArr,responseObject);
                for (KDSPwdListModel * pwdModel in pwdListArr) {
                    if (pwdModel.userId > 4 && pwdModel.userId < 9) {
                        pwdModel.pwdType = KDSServerKeyTpyeTempPIN;
                        [pwds addObject:pwdModel];
                    }else{
                        pwdModel.pwdType = KDSServerKeyTpyePIN;
                        pwdModel.type = KDSServerCycleTpyeForever;
                        if (pwdModel.userType == 1) {//有计划策略
                            for (KDSGWLockSchedule * schedule in weekScheduleArr) {
                                //周计划
                                if (pwdModel.userId == schedule.userId) {
                                    pwdModel.daysMask = schedule.daysMask;
                                    pwdModel.startHour = schedule.startHour;
                                    pwdModel.endHour = schedule.endHour;
                                    pwdModel.startMinutes = schedule.startMinutes;
                                    pwdModel.endMinutes = schedule.endMinutes;
                                    pwdModel.type = KDSServerCycleTpyeCycle;
                                    break;
                                }
                            }
                            for (KDSGWLockSchedule * schedule in yearScheduleArr) {
                                 //年计划
                                if (pwdModel.userId == schedule.userId) {
                                    pwdModel.endTime = schedule.endTime;
                                    pwdModel.startTime = schedule.startTime;
                                    pwdModel.endHour = schedule.endHour;
                                    pwdModel.startMinutes = schedule.startMinutes;
                                    pwdModel.endMinutes = schedule.endMinutes;
                                    pwdModel.type = KDSServerCycleTpyePeriod;
                                    break;
                                }
                            }
                        }
                        if (pwdModel.userId != 9) {
                            [pwds addObject:pwdModel];
                        }
                    }
                }
                
                self.dataArr = pwds;
                self.dataArr = [self.dataArr sortedArrayUsingComparator:^NSComparisonResult(KDSPwdListModel *_Nonnull obj1, KDSPwdListModel *_Nonnull obj2) {
                        return obj1.userId > obj2.userId;
                }];
        //        [[KDSDBManager sharedManager] insertPasswords:self.dataArr withLock:self.lock.gwDevice];
                [hud hideAnimated:NO];
                [self reloadData];
                
            } error:^(NSError * _Nonnull error) {
                [hud hideAnimated:NO];
                [MBProgressHUD showError:Localized(@"synchronizeFailed")];
                
            } failure:^(NSError * _Nonnull error) {
                [hud hideAnimated:NO];
                [MBProgressHUD showError:Localized(@"synchronizeFailed")];
            }];
        
    }else{
        //mqtt查询密码
        [[KDSMQTTManager sharedManager] dlGetKeyInfo:self.lock.gwDevice completion:^(NSError * _Nullable error, KDSGWLockKeyInfo * _Nullable info) {
            if (info)
            {
                NSMutableArray *container = [NSMutableArray array];
                self.currentIndex = 0;
                [self recursiveGetKeys:KDSGWKeyTypePIN from:0 to:(unsigned)info.maxpwdusernum container:container completion:^{
                    [pwds removeAllObjects];
                    for (KDSPwdListModel * pwdModel in container) {
                        if (pwdModel.num.intValue != 9) {
                            [pwds addObject:pwdModel];
                        }
                    }
                    self.dataArr = pwds;
                    [[KDSDBManager sharedManager] insertPasswords:pwds withLock:self.lock.gwDevice];
                    [hud hideAnimated:NO];
                    [self reloadData];
                }];
            }
            else
            {
                [hud hideAnimated:NO];
                [MBProgressHUD showError:Localized(@"synchronizeFailed")];
            }
        }];
    }
}

///点击添加按钮，添加密码、指纹、卡片、授权用户。
- (void)clickAddBtnAction:(UIButton *)sender
{
    //无网络的时候不让添加密码
    if (![KDSUserManager sharedManager].netWorkIsAvailable) {
        [MBProgressHUD showError:Localized(@"networkNotAvailable")];
        return;
    }
    if (self.keyType == KDSGWKeyTypeReserved)
    {
        if (self.dataArr.count >= 10)
        {
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"shareUserUpperLimitTips") message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:nil];
            [ac addAction:okAction];
            [self presentViewController:ac animated:YES completion:nil];
            return;
        }
        KDSAddMemberVC *vc = [KDSAddMemberVC new];
        vc.lock = self.lock;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        if (self.keyType == KDSGWKeyTypePIN)
        {
            if(([[self.lock.gwDevice.lockversion componentsSeparatedByString:@";"][0] caseInsensitiveCompare:@"8100Z"] == NSOrderedSame
                || [[self.lock.gwDevice.lockversion componentsSeparatedByString:@";"][0] caseInsensitiveCompare:@"8100A"] == NSOrderedSame) && self.lock.gwDevice.lockversion){
                KDSGWAddPINVC *vc = [KDSGWAddPINVC new];
                vc.lock = self.lock;
                vc.keyType = self.keyType;
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                KDSGWAddPINPermanentVC *vc = [KDSGWAddPINPermanentVC new];
                vc.lock = self.lock;
                vc.keyType = self.keyType;
                vc.type = 2;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = NSStringFromClass([self class]);
    KDSLockKeyCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    NSDateFormatter *fmt = [KDSUserManager sharedManager].dateFormatter;
    
    if (!cell)
    {
        cell = [[KDSLockKeyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    if (self.keyType == KDSGWKeyTypeReserved)
    {
        KDSAuthCatEyeMember *member = self.dataArr[indexPath.row];
        cell.name = member.userNickname ?: member.username;
        cell.jurisdiction = @"";
    }
    else
    {
        KDSPwdListModel *m = self.dataArr[indexPath.row];
        int num = m.num.intValue ?: m.userId;
        if (m.nickName) {
            cell.name = [NSString stringWithFormat:@"%02d  %@",num,m.nickName];
        }else{
            cell.name = [NSString stringWithFormat:@"%02d",num];
        }
        if (m.pwdType == KDSServerKeyTpyeTempPIN)
        {
            cell.jurisdiction = Localized(@"tempPwd,onlyOnce");
        }
        else if (m.pwdType == KDSServerKeyTpyePIN)
        {
            if (m.type == KDSServerCycleTpyeForever)//永久密码
            {
                if ([m.num isEqualToString:@"09"]) {
                    cell.jurisdiction = Localized(@"menacePassword");
                }else{
                    cell.jurisdiction = Localized(@"permanentValidation");
                }
            }
            else if (m.type == KDSServerCycleTpyeCycle)//周期密码
            {//这里的数量不是很多，不做缓存了。
                
                fmt.dateFormat = @"HH:mm";
                if (m.startHour || m.endHour || m.startMinutes || m.endMinutes) {
                    NSString * begin = [NSString stringWithFormat:@"%02d:%02d",m.startHour,m.startMinutes];
                    NSString * end = [NSString stringWithFormat:@"%02d:%02d",m.endHour,m.endMinutes];
                    if (m.daysMask == 127)
                    {
                        cell.jurisdiction = [NSString stringWithFormat:@"%@ %@-%@", Localized(@"everyday"), begin, end];
                    }
                    else
                    {
                        NSArray *days = @[Localized(@"everySunday"), Localized(@"everyMonday"), Localized(@"everyTue"),  Localized(@"everyWed"), Localized(@"everyThu"), Localized(@"everyFri"), Localized(@"everySat")];
                        NSMutableString *ms = [NSMutableString string];
                        NSString *separator = [[KDSTool getLanguage] containsString:@"en"] ? @", " : @"、";
                        for (int i = 0; i < 7; ++i)
                        {
                            !((m.daysMask>>i) & 0x1) ?: [ms appendFormat:@"%@%@", days[i], separator];
                        }
                        [ms deleteCharactersInRange:NSMakeRange(ms.length - separator.length, separator.length)];
                        cell.jurisdiction = [NSString stringWithFormat:@"%@%@-%@", ms, begin, end];
                    }
                }else{
                    NSString *begin = [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:m.startTime.doubleValue]];
                    NSString *end = [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:m.endTime.doubleValue]];
                    NSArray *days = @[Localized(@"everySunday"), Localized(@"everyMonday"), Localized(@"everyTue"),  Localized(@"everyWed"), Localized(@"everyThu"), Localized(@"everyFri"), Localized(@"everySat")];
                    NSString *separator = [[KDSTool getLanguage] containsString:@"en"] ? @", " : @"、";
                    NSMutableString *ms = [NSMutableString string];
                    int t = 0;
                    for (int i = 0; i < m.items.count; ++i)
                    {
                        if (m.items[i].boolValue)
                        {
                            t++;
                            [ms appendFormat:@"%@%@", days[i<days.count ? i : days.count-1], separator];
                        }
                    }
                    if (ms.length)
                    {
                        [ms replaceCharactersInRange:NSMakeRange(ms.length - separator.length, separator.length) withString:[[KDSTool getLanguage] containsString:@"en"] ? @", " : @"，"];
                    }
                    if (t == m.items.count)
                    {
                        cell.jurisdiction = [NSString stringWithFormat:@"%@ %@-%@", Localized(@"everyday"), begin, end];
                    }
                    else
                    {
                        cell.jurisdiction = [NSString stringWithFormat:@"%@%@-%@", ms, begin, end];
                    }
                }
            }
            else
            {//24小时\时间段
                
                NSTimeInterval secondsFromGMT = [NSTimeZone localTimeZone].secondsFromGMT;
                fmt.dateFormat = @"yyyy/MM/dd HH:mm";
                cell.jurisdiction = [NSString stringWithFormat:@"%@-%@", [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:m.startTime.doubleValue + MQTTFixedTime - secondsFromGMT]], [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:m.endTime.doubleValue + MQTTFixedTime - secondsFromGMT]]];
            }
        }
    }
    cell.hideSeparator = indexPath.row + 1 == self.dataArr.count;
    //    cell.hideArrow = YES;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL oldFlag = NO;
    if (!oldFlag)
    {
        ///网关锁密码详情
        KDSGWLockKeyDetailsVC *vc = [KDSGWLockKeyDetailsVC new];
        vc.lock = self.lock;
        vc.keyType = self.keyType;
        vc.model = self.dataArr[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark --通知

-(void)refreshInterfaceWhenGWLockPwdDidSync:(NSNotification *)noti
{
    [self loadNewData];
}

@end
