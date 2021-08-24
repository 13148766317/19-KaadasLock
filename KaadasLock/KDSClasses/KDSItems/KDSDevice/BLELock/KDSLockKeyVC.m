//
//  KDSLockKeyVC.m
//  KaadasLock
//
//  Created by orange on 2019/3/27.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSLockKeyVC.h"
#import "Masonry.h"
#import "MJRefresh.h"
#import "KDSHttpManager+User.h"
#import "KDSHttpManager+Ble.h"
#import "KDSHttpManager+User.h"
#import "KDSHttpManager+WifiLock.h"
#import "KDSLockKeyCell.h"
#import "KDSLockKeyDetailsVC.h"
#import "KDSAddKeyVC.h"
#import "KDSAddMemberVC.h"
#import "MBProgressHUD+MJ.h"
#import "KDSDBManager.h"
#import "KDSAddPINVC.h"
#import "KDSAuthCatEyeMember.h"
#import "KDSCatEyeAuthDetailsVC.h"
#import "KDSBleAssistant.h"
#import "KDSWifiLockKeyDetailsVC.h"

@interface KDSLockKeyVC () <UITableViewDelegate, UITableViewDataSource>

///表视图。
@property (nonatomic, strong) UITableView *tableView;
///数据模型数组(KDSPwdListModel、KDSAuthMember)。
@property (nonatomic, strong) NSMutableArray *dataArr;
///table footer view, use for displaying no data.
@property (nonatomic, strong) UIView *footerView;
///同步锁中信息时返回的凭证，用于控制器销毁时从蓝牙任务队列中移除任务或防止重复发送。
@property (nonatomic, strong) NSString *receipt;
///功能集：0x00、0x31。。。。。
@property (nonatomic, strong) NSString *FunctionSetKey;
///是否支持20组密码
@property (nonatomic, assign) BOOL isSupport20setsPasswords;


@end

@implementation KDSLockKeyVC

#pragma mark - getter setter
- (NSMutableArray *)dataArr
{
    if (!_dataArr)
    {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

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
            case KDSBleKeyTypeReserved:
                label.text = Localized(@"noShareUser");
                break;
                
            case KDSBleKeyTypePIN:
                label.text = Localized(@"noPassword");
                break;
                
            case KDSBleKeyTypeFingerprint:
                label.text = Localized(@"noFingerprint");
                break;
                
            case KDSBleKeyTypeRFID:
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
    self.view.backgroundColor = KDSRGBColor(0xf2, 0xf2, 0xf2);
    ////根据蓝牙锁的功能集判断是开始记录/操作记录
    NSString *function = self.lock.lockFunctionSet;//?:self.lock.bleTool.connectedPeripheral.functionSet;
    [self setupUI];
    //功能集
    self.isSupport20setsPasswords = [KDSLockFunctionSet[function] containsObject:@24];
    KDSDBManager *manager = [KDSDBManager sharedManager];
    NSString *bleName = self.lock.device.lockName;
    if (self.lock) {
        if (self.keyType == KDSBleKeyTypeReserved)
        {
            [self.dataArr addObjectsFromArray:[manager queryUserAuthMembers] ?: @[]];
        }
        else if (self.keyType == KDSBleKeyTypePIN)
        {
            NSArray *pins = [manager queryPwdAttrWithBleName:bleName type:1] ?: @[];
            NSArray *temps = [manager queryPwdAttrWithBleName:bleName type:2] ?: @[];
            [self.dataArr addObjectsFromArray:pins];
            [self.dataArr addObjectsFromArray:temps];
        }
        else
        {
            [self.dataArr addObjectsFromArray:[manager queryPwdAttrWithBleName:bleName type:self.keyType==KDSBleKeyTypeRFID ? 4 : 3] ?: @[]];
        }
    }
    if (self.dataArr.count)
    {
        [self reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadNewData];
}

- (void)dealloc
{
    [self.lock.bleTool cancelTaskWithReceipt:self.receipt];
}

- (void)setupUI
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 18 + (self.keyType==KDSBleKeyTypeReserved ? 0.001 : 44) + (self.keyType==KDSBleKeyTypeReserved ? 20 : 37) + 44 + 37)];
    
    UIView *cornerView = [UIView new];
    cornerView.clipsToBounds = YES;
    cornerView.backgroundColor = UIColor.whiteColor;
    cornerView.layer.cornerRadius = 4;
    [headerView addSubview:cornerView];
    [cornerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerView).offset(18);
        make.centerX.equalTo(@0);
        make.width.equalTo(@(kScreenWidth - 30));
        make.height.equalTo(@(self.keyType==KDSBleKeyTypeReserved ? 0.001 : 44));
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
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 75;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.tableHeaderView = headerView;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
    
    switch (self.keyType)
    {
        case KDSBleKeyTypeReserved:
            self.navigationTitleLabel.text = Localized(@"authUserMgr");
            [addBtn setTitle:Localized(@"shareUser") forState:UIControlStateNormal];
            flagIV.image = [UIImage imageNamed:@"member"];
            break;
            
        case KDSBleKeyTypePIN:
            self.navigationTitleLabel.text = Localized(@"password");
            syncLabel.text = Localized(@"pwdSync");
            flagIV.image = [UIImage imageNamed:@"bigPassword"];
            [addBtn setTitle:Localized(@"addPwd") forState:UIControlStateNormal];
            break;
            
        case KDSBleKeyTypeFingerprint:
            self.navigationTitleLabel.text = Localized(@"fingerprint");
            syncLabel.text = Localized(@"fingerprintSync");
            flagIV.image = [UIImage imageNamed:@"bigFingerprint"];
            [addBtn setTitle:Localized(@"addFingerprint") forState:UIControlStateNormal];
            break;
            
        case KDSBleKeyTypeRFID:
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
        make.top.equalTo(cornerView.mas_bottom).offset(self.keyType==KDSBleKeyTypeReserved ? 20 : 37);
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
        [self.dataArr sortUsingComparator:^NSComparisonResult(KDSPwdListModel *_Nonnull obj1, KDSPwdListModel *_Nonnull obj2) {
            return obj1.num.intValue > obj2.num.intValue;
        }];
    }
    [self.tableView reloadData];
}


#pragma mark - 控件等事件方法。
///点击同步按钮，同步密码、指纹、卡片。
- (void)clickSyncBtnAction:(UIButton *)sender
{
    if (self.keyType == KDSBleKeyTypeReserved) return;
    
    if (self.receipt) return;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    __weak typeof(self) weakSelf = self;
    self.receipt = [self.lock.bleTool getAllUsersWithKeyType:self.keyType completion:^(KDSBleError error, NSArray<KDSBleUserType *> * _Nullable users) {
        
        weakSelf.receipt = nil;
        if (error == KDSBleErrorSuccess)
        {
            NSMutableArray<KDSPwdListModel *> *models = [NSMutableArray arrayWithCapacity:users.count];
            dispatch_group_t group = dispatch_group_create();
            for (KDSBleUserType *user in users)
            {
                KDSPwdListModel *m = [KDSPwdListModel new];
                m.num = [NSString stringWithFormat:@"%02lu", (unsigned long)user.userId];
                if (weakSelf.keyType == KDSBleKeyTypePIN)
                {
                    if ([KDSLockFunctionSet[self.lock.lockFunctionSet] containsObject:@24]) {
                        m.pwdType = (user.userId < 5 || (user.userId >= 10 && user.userId <= 19) || user.userId==9) ? KDSServerKeyTpyePIN : KDSServerKeyTpyeTempPIN;
                        m.type = KDSServerCycleTpyeForever;
                    }else{
                        m.pwdType = (user.userId<5 || user.userId==9) ? KDSServerKeyTpyePIN : KDSServerKeyTpyeTempPIN;
                        m.type = KDSServerCycleTpyeForever;
                    }
                }
                else if (weakSelf.keyType == KDSBleKeyTypeRFID)
                {
                    m.pwdType = KDSServerKeyTpyeCard;
                }
                else
                {
                    m.pwdType = KDSServerKeyTpyeFingerprint;
                }
                [models addObject:m];
            }
            //递归查计划。
            if (weakSelf.keyType == KDSBleKeyTypePIN)
            {
                dispatch_group_enter(group);
                [weakSelf recursiveGetScheduleWithPwds:models fromIndex:0 completion:^{
                    dispatch_group_leave(group);
                }];
            }
            
            dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                [self updateKeysAtServerWithKeysAtLock:models];
                [hud hideAnimated:YES];
            });
        }
        else
        {
            [hud hideAnimated:YES];
            [MBProgressHUD showError:Localized(@"anErrorOccur,pleaseRetryLater")];
        }
    }];
}

///同步成功后，根据获取到的密匙数据，和服务器保存的数据进行对比，如果一致则不处理，如果不一致则删除服务器已存在的数据并添加锁中的数据。
- (void)updateKeysAtServerWithKeysAtLock:(NSArray<KDSPwdListModel *> *)models
{
    //先删掉锁没有但服务器却保留有的信息。
    NSMutableArray *deleted = [NSMutableArray array];
    NSMutableArray *latest = [NSMutableArray array];
    for (KDSPwdListModel *m in self.dataArr)
    {
        NSInteger index = [models indexOfObject:m];
         if (index == NSNotFound)
        {
            [deleted addObject:m];
        }
        else if (self.keyType == KDSBleKeyTypePIN && m.pwdType == KDSServerKeyTpyePIN)
        {
            if ((models[index].type != m.type) && (m.type == KDSServerCycleTpyeForever || models[index].type == KDSServerCycleTpyeForever))
            {
                [deleted addObject:m];
                [latest addObject:models[index]];
            }
            //由于锁时间不准确，做年月日计划判断会导致判断结果为不相同的密码，因此这里不做年月日计划密码判断。
            /*else if (m.type == KDSServerCycleTpyeTwentyfourHours || m.type == KDSServerCycleTpyePeriod)
            {
                if (m.startTime.integerValue != models[index].startTime.integerValue || m.endTime.integerValue != models[index].endTime.integerValue)
                {
                    [deleted addObject:m];
                    [latest addObject:models[index]];
                }
            }*/
            else if (m.type == KDSServerCycleTpyeCycle)
            {
                NSDateFormatter *fmt = [KDSUserManager sharedManager].dateFormatter;
                fmt.dateFormat = @"HH:mm";
                NSString *bTime1 = [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:m.startTime.doubleValue]];
                NSString *eTime1 = [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:m.endTime.doubleValue]];
                NSString *bTime2 = [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:models[index].startTime.doubleValue]];;
                NSString *eTime2 = [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:models[index].endTime.doubleValue]];
                //注意这儿取值对比时要和recursiveGetScheduleWithPwds方法的赋值一样
                if (![bTime1 isEqualToString:bTime2] || ![eTime1 isEqualToString:eTime2] || ![[m.items componentsJoinedByString:@""] isEqualToString:[models[index].items componentsJoinedByString:@""]])
                {
                    [deleted addObject:m];
                    [latest addObject:models[index]];
                }
            }
        }
    }
    [self.dataArr removeObjectsInArray:deleted];
    
    //再添加锁有服务器却没有的。
    for (KDSPwdListModel *m in models)
    {
        if (![self.dataArr containsObject:m])
        {
            m.createTime = NSDate.date.timeIntervalSince1970;
            [self.dataArr addObject:m];
            [latest addObject:m];
        }
    }
    if (deleted.count==0 && latest.count==0) return;
    [self reloadData];
    NSLog(@"kaadas--没有更新之前的数据11:%@",self.dataArr);
    [self updateKeysDelete:deleted add:latest];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[KDSDBManager sharedManager] deletePwdAttrs:deleted bleName:self.lock.device.lockName];
        [[KDSDBManager sharedManager] insertPwdAttrs:latest bleName:self.lock.device.lockName];
    });
}

///点击添加按钮，添加密码、指纹、卡片、授权用户。
- (void)clickAddBtnAction:(UIButton *)sender
{
    //无网络的时候不让添加密码
    if (![KDSUserManager sharedManager].netWorkIsAvailable) {
        [MBProgressHUD showError:Localized(@"networkNotAvailable")];
        return;
    }
    //密码的总个数是根据功能集决定的是20组还是10组
    self.isSupport20setsPasswords = [KDSLockFunctionSet[self.lock.lockFunctionSet] containsObject:@24];
    int totalNumber = self.isSupport20setsPasswords ? 20 : 10;
    if (self.keyType == KDSBleKeyTypeReserved)
    {
        if (self.dataArr.count >= totalNumber)
        {//授权用户
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"shareUserUpperLimitTips") message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:nil];
            [ac addAction:okAction];
            [self presentViewController:ac animated:YES completion:nil];
            return;
        }
        KDSAddMemberVC *vc = [KDSAddMemberVC new];
        vc.lock = self.lock;
        vc.catEye = self.catEye;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.removeFromSuperViewOnHide = YES;
        [self getAllKeys:self.keyType times:0 completion:^(KDSBleError error, NSArray<KDSBleUserType *> * _Nullable users) {
            [hud hideAnimated:NO];
            if (error != KDSBleErrorSuccess)
            {
                [MBProgressHUD showError:Localized(@"getKeysInLockFailed")];
                return;
            }
            BOOL upperLimit = NO;
            BOOL usersCount = NO;
            if (self.keyType == KDSBleKeyTypePIN)
            {//密码
                if (self.isSupport20setsPasswords) {
                    upperLimit = users.count == 20;
                    usersCount = users.count == 19;
                }else{
                    upperLimit = users.count == self.lock.bleTool.connectedPeripheral.maxUsers;
                    usersCount = users.count == self.lock.bleTool.connectedPeripheral.maxUsers - 1;
                }
               
                if (!upperLimit && usersCount)
                {
                    upperLimit = YES;
                    for (KDSBleUserType *user in users)
                    {
                        if (user.userId == 9)//9设为胁迫密码
                        {
                            upperLimit = NO;
                            break;
                        }
                    }
                }
            }
            else
            {//指纹卡片
                upperLimit = users.count == 100;
                /*没有规定斜坡指纹、卡片不可以在app上面添加，所以下面方法注释，即便是胁迫指纹、卡片不可以在app添加下面方法也是错误的
                if (!upperLimit && users.count >= 95)
                {
                    int menace = 0;
                    for (KDSBleUserType *user in users)
                    {
                        if (user.userId >= 95)//95-99设为胁迫指纹、卡片。
                        {
                            menace++;
                        }
                    }
                    upperLimit = menace > (users.count - 95);
                }
                 */
            }
            if (upperLimit)
            {
                UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(self.keyType==KDSBleKeyTypeRFID ? @"cardUpperLimitTips" : (self.keyType==KDSBleKeyTypeFingerprint ? @"fingerprintUpperLimitTips" : @"PINUpperLimitTips")) message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:nil];
                [ac addAction:okAction];
                [self presentViewController:ac animated:YES completion:nil];
            }
            else
            {
                if (self.keyType == KDSBleKeyTypePIN)
                {
                    KDSAddPINVC *vc = [KDSAddPINVC new];
                    vc.lock = self.lock;
                    vc.isSupport20setsPasswords = self.isSupport20setsPasswords;
                    vc.existedUsers = users;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                else
                {
                    KDSAddKeyVC *vc = [KDSAddKeyVC new];
                    vc.type = self.keyType==KDSBleKeyTypeRFID ? 0 : 1;
                    vc.lock = self.lock;
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }
        }];
    }
}

#pragma mark - 蓝牙功能相关方法。
///获取已设置的所有密码、卡片、指纹，调用时times传0，最多3次，3次都失败就算失败，completion是获取操作完毕后的回调，成功时users才有意义。
- (void)getAllKeys:(KDSBleKeyType)type times:(int)times completion:(void(^)(KDSBleError error, NSArray<KDSBleUserType *> * _Nullable users))completion
{
    KDSBluetoothTool *tool = self.lock.bleTool;
    __weak typeof(self) weakSelf = self;
    [tool getAllUsersWithKeyType:type completion:^(KDSBleError error, NSArray<KDSBleUserType *> * _Nullable users) {
        if (error == KDSBleErrorSuccess)
        {
            !completion ?: completion(error, users);
        }
        else if (times < 2)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf getAllKeys:type times:times + 1 completion:completion];
            });
        }
        else
        {
            !completion ?: completion(error, users);
        }
    }];
}

///获取已设置的所有密码，并提取出KDSPwdListModel后，递归查询编号是否是计划密码，如是，则会设置相应的计划。index 参数外部使用时必须传0，completion是递归完毕执行的回调。假定pwds传入时已按照编号升序排列。
- (void)recursiveGetScheduleWithPwds:(NSArray<KDSPwdListModel *> *)pwds fromIndex:(NSInteger)index completion:(nullable void(^)(void))completion
{
    if (index == pwds.count) {
        !completion ?: completion();
        return;
    }
    if (!(pwds[index].num.intValue >= 5 && pwds[index].num.intValue <=8))
    {
        __weak typeof(self) weakSelf = self;
        [self.lock.bleTool getUserTypeWithId:pwds[index].num KeyType:KDSBleKeyTypePIN completion:^(KDSBleError error, KDSBleUserType * _Nullable user) {
            if (user && user.userType == KDSBleSetUserTypeSchedule)
            {
                [weakSelf.lock.bleTool getScheduleWithScheduleId:pwds[index].num.intValue completion:^(KDSBleError error, KDSBleScheduleModel * _Nullable model) {
                    KDSPwdListModel *lm = pwds[index];
                    if ([model isKindOfClass:KDSBleYMDModel.class])
                    {
                        KDSBleYMDModel *m = (KDSBleYMDModel *)model;
                        lm.type = KDSServerCycleTpyePeriod;
                        lm.startTime = @(FixedTime + m.beginTime).stringValue;
                        lm.endTime = @(FixedTime + m.endTime).stringValue;
                        lm.scheduleID = lm.num;
                    }
                    else if ([model isKindOfClass:KDSBleWeeklyModel.class])
                    {
                        KDSBleWeeklyModel *m = (KDSBleWeeklyModel *)model;
                        lm.type = KDSServerCycleTpyeCycle;
                        lm.scheduleID = lm.num;
                        NSTimeInterval seconds = [[NSTimeZone localTimeZone] secondsFromGMT];
                        lm.startTime = @(m.beginHour * 3600 + m.beginMin * 60 - seconds).stringValue;
                        lm.endTime = @(m.endHour * 3600 + m.endMin * 60 - seconds).stringValue;
                        NSMutableArray *items = [NSMutableArray arrayWithCapacity:7];
                        for (int i = 0; i < 7; ++i)
                        {
                            [items addObject:@((m.mask>>i) & 0x1).stringValue];
                        }
                        lm.items = items;
                    }
                    [weakSelf recursiveGetScheduleWithPwds:pwds fromIndex:index + 1 completion:completion];
                }];
            }
            else
            {
                [weakSelf recursiveGetScheduleWithPwds:pwds fromIndex:index + 1 completion:completion];
            }
        }];
    }else{
        
        [self recursiveGetScheduleWithPwds:pwds fromIndex:index + 1 completion:completion];
        NSLog(@"周期计划%ld",(long)index);
    }
    
}

#pragma mark - 网络请求相关方法。
///刷新密码、指纹、卡片、授权用户。
- (void)loadNewData
{
    NSString *uid = [KDSUserManager sharedManager].user.uid;
    NSString *bleName = self.lock.device.lockName;
    if (self.lock.wifiDevice) {///wifi锁
        [[KDSHttpManager sharedManager] getWifiLockAuthorizedUsersWithUid:[KDSUserManager sharedManager].user.uid wifiSN:self.lock.wifiDevice.wifiSN success:^(NSArray<KDSAuthMember *> * _Nullable members) {
            self.tableView.mj_header.state = MJRefreshStateIdle;
            [self.dataArr removeAllObjects];
            [self.dataArr addObjectsFromArray:members ?: @[]];
            [self reloadData];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [[KDSDBManager sharedManager] updateUserAuthMembers:members];
            });
        } error:^(NSError * _Nonnull error) {
             self.tableView.mj_header.state = MJRefreshStateIdle;
        } failure:^(NSError * _Nonnull error) {
             self.tableView.mj_header.state = MJRefreshStateIdle;
        }];
        return;
    }
    if (self.catEye) {
        [[KDSMQTTManager sharedManager] getShareUserListWithGW:self.catEye.gw.model device:self.catEye.gatewayDeviceModel completion:^(NSError * _Nullable error, NSArray<KDSAuthCatEyeMember *> * _Nullable records) {
            [self.dataArr removeAllObjects];
            if (records) {
                [self.dataArr addObjectsFromArray:records];
            }
            [self reloadData];
            self.tableView.mj_header.state = MJRefreshStateIdle;
        }];
        
        return;
    }
    if (self.keyType == KDSBleKeyTypeReserved)
    {
        [[KDSHttpManager sharedManager] getAuthorizedUsersWithUid:uid bleName:bleName success:^(NSArray<KDSAuthMember *> * _Nullable members) {
            self.tableView.mj_header.state = MJRefreshStateIdle;
            [self.dataArr removeAllObjects];
            [self.dataArr addObjectsFromArray:members ?: @[]];
            [self reloadData];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [[KDSDBManager sharedManager] updateUserAuthMembers:members];
            });
        } error:^(NSError * _Nonnull error) {
            self.tableView.mj_header.state = MJRefreshStateIdle;
        } failure:^(NSError * _Nonnull error) {
            self.tableView.mj_header.state = MJRefreshStateIdle;
        }];
    }
    else
    {
        NSDictionary<NSNumber *, NSNumber *> *map = @{@(KDSBleKeyTypePIN):@(KDSServerKeyTpyeAll), @(KDSBleKeyTypeRFID):@(KDSServerKeyTpyeCard), @(KDSBleKeyTypeFingerprint):@(KDSServerKeyTpyeFingerprint)};
        [[KDSHttpManager sharedManager] getBlePwdListWithUid:uid bleName:bleName pwdType:(KDSServerKeyTpye)map[@(self.keyType)].integerValue success:^(NSArray<KDSPwdListModel *> * _Nonnull pwdlistArray) {
            self.tableView.mj_header.state = MJRefreshStateIdle;
            [self.dataArr removeAllObjects];
            if (self.keyType == KDSBleKeyTypePIN)
            {
                for (KDSPwdListModel *m in pwdlistArray)
                {
                    if (m.pwdType == KDSServerKeyTpyePIN || m.pwdType == KDSServerKeyTpyeTempPIN)
                    {
                        [self.dataArr addObject:m];
                    }
                }
            }
            else
            {
                [self.dataArr addObjectsFromArray:pwdlistArray ?: @[]];
            }
            [self reloadData];
            NSLog(@"kaadas--从服务器获取的密码列表：%@",self.dataArr);
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [[KDSDBManager sharedManager] insertPwdAttrs:pwdlistArray bleName:self.lock.device.lockName];
            });
        } error:^(NSError * _Nonnull error) {
            self.tableView.mj_header.state = MJRefreshStateIdle;
        } failure:^(NSError * _Nonnull error) {
            self.tableView.mj_header.state = MJRefreshStateIdle;
            [MBProgressHUD showError:error.localizedDescription];
        }];
    }
}

/**
 *@abstract 更新服务器保存的密码、卡片、指纹。先删除锁中没有的，再添加锁中新增的。
 *@param delete 需要删除的密匙数组。
 *@param add 需要新增的密匙数组。
 */
- (void)updateKeysDelete:(NSArray<KDSPwdListModel *> *)delete add:(NSArray<KDSPwdListModel *> *)add
{
    if (delete.count==0 && add.count==0) return;
    NSString *uid = [KDSUserManager sharedManager].user.uid;
    NSString *bleName = self.lock.device.lockName;
    void (^addKeys)(NSArray<KDSPwdListModel *> *) = ^(NSArray<KDSPwdListModel *> *models){
        if (models.count != 0)
        {
            [[KDSHttpManager sharedManager] addBlePwds:models withUid:uid bleName:bleName success:^{
                //接口异步处理的，所以添加完成马上去查，会出现查不到的情况，所以延迟0.5秒
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                     [self loadNewData];
                });
               
            } error:nil failure:nil];
        }
    };
    if (delete.count)
    {
        [[KDSHttpManager sharedManager] deleteBlePwd:delete withUid:uid bleName:bleName  success:^{
            addKeys(add);
        } error:^(NSError * _Nonnull error) {
            addKeys(add);
        } failure:^(NSError * _Nonnull error) {
            addKeys(add);
        }];
    }
    else
    {
        addKeys(add);
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
    if (!cell)
    {
        cell = [[KDSLockKeyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    if (self.catEye) {
        KDSAuthCatEyeMember * member = self.dataArr[indexPath.row];
        cell.name = member.userNickname ?: member.username;
        
    }else if (self.lock.wifiDevice){
        KDSAuthMember *member = self.dataArr[indexPath.row];
        cell.name = member.userNickname ?: member.uname;
    }else{
        if (self.keyType == KDSBleKeyTypeReserved)
        {//网关锁
            KDSAuthMember *member = self.dataArr[indexPath.row];
            cell.name = member.unickname;
            cell.jurisdiction = Localized(@"permanentValidation");
        }
        else
        {
            KDSPwdListModel *m = self.dataArr[indexPath.row];
            if ([m.nickName isEqualToString:m.num]) {
                cell.name = [NSString stringWithFormat:@"%02d",m.num.intValue];
            }else{
                cell.name = [NSString stringWithFormat:@"%02d  %@",m.num.intValue,m.nickName];
            }
            if (m.pwdType == KDSServerKeyTpyeTempPIN && m.num.intValue != 9)
            {
                cell.jurisdiction = Localized(@"tempPwd,onlyOnce");
            }
            else if (m.pwdType == KDSServerKeyTpyePIN)
            {
                if (m.type == KDSServerCycleTpyeForever || m.num.intValue == 9)
                {
                    if (m.num.intValue == 9) {
                        cell.jurisdiction = Localized(@"menacePassword");
                    }else{
                        cell.jurisdiction = Localized(@"permanentValidation");
                    }
                }
                else if (m.type == KDSServerCycleTpyeCycle)
                {//这里的数量不是很多，不做缓存了。
                    NSDateFormatter *fmt = self.lock.bleTool.dateFormatter;
                    fmt.dateFormat = @"HH:mm";
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
                    cell.jurisdiction = [NSString stringWithFormat:@"%@%@-%@", ms, begin, end];
                    cell.jurisdiction = t==m.items.count ? [NSString stringWithFormat:@"%@ %@-%@", Localized(@"everyday"), begin, end] : cell.jurisdiction;
                }
                else
                {
                    NSDateFormatter *fmt = self.lock.bleTool.dateFormatter;
                    fmt.dateFormat = @"yyyy/MM/dd HH:mm";
                    if (m.startTime.doubleValue > FutureTime && m.endTime.doubleValue > FutureTime) {
                        //毫秒
                        cell.jurisdiction = [NSString stringWithFormat:@"%@-%@", [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:m.startTime.doubleValue/1000]], [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:m.endTime.doubleValue/1000]]];
                    }else{//秒
                        cell.jurisdiction = [NSString stringWithFormat:@"%@-%@", [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:m.startTime.doubleValue]], [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:m.endTime.doubleValue]]];
                    }
                }
            }
        }
    }
    cell.hideSeparator = indexPath.row + 1 == self.dataArr.count;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.catEye) {
        KDSCatEyeAuthDetailsVC * vc = [KDSCatEyeAuthDetailsVC new];
        vc.cateye = self.catEye;
        vc.model = self.dataArr[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if (self.lock.wifiDevice){
        KDSWifiLockKeyDetailsVC * vc = [KDSWifiLockKeyDetailsVC new];
        vc.lock = self.lock;
        vc.model = self.dataArr[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else{
        KDSLockKeyDetailsVC *vc = [KDSLockKeyDetailsVC new];
        vc.lock = self.lock;
        vc.keyType = self.keyType;
        vc.model = self.dataArr[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
 
}


@end
