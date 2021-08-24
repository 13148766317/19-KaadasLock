//
//  KDSWifiLockPwdListVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/12/17.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSWifiLockPwdListVC.h"
#import "KDSWiFiLockKeyCell.h"
#import "KDSHttpManager+WifiLock.h"
#import "KDSWifiLockPwdDetailsVC.h"
#import "KDSDBManager.h"
#import "KDSWifiLockFPDetailsVC.h"
#import "KDSAddFaceRecognitionStep1VC.h"


@interface KDSWifiLockPwdListVC ()<UITableViewDelegate, UITableViewDataSource>

///表视图。
@property (nonatomic, strong) UITableView * tableView;
///table footer view, use for displaying no data.
@property (nonatomic, strong) UIView * footerView;
///(KDSPwdListModel、KDSAuthMember)。
@property (nonatomic, strong) NSMutableArray * dataSourceArr;
@property (nonatomic, strong) NSMutableArray * nickNameArr;

@end

@implementation KDSWifiLockPwdListVC

#pragma mark - getter setter

- (NSMutableArray *)dataSourceArr
{
    if (!_dataSourceArr) {
        _dataSourceArr = [NSMutableArray array];
    }
    return _dataSourceArr;
}
- (NSMutableArray *)nickNameArr
{
    if (!_nickNameArr) {
        _nickNameArr = [NSMutableArray array];
    }
    return _nickNameArr;
}
- (UIView *)footerView
{
    if (!_footerView)
    {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, kScreenWidth, KDSScreenHeight-kNavBarHeight-kStatusBarHeight)];
        headerView.backgroundColor = UIColor.whiteColor;
        UILabel *label = [UILabel new];
        label.textColor = KDSRGBColor(0x8e, 0x8e, 0x93);
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentCenter;
        UIImageView * tipsImgView = [UIImageView new];
        NSString * imgNameString;
        switch (self.keyType)
        {
            case KDSBleKeyTypePIN:
                label.text = Localized(@"no password. Please add synchronization");
                imgNameString = @"noPwdIconImg";
                break;
                
            case KDSBleKeyTypeFingerprint:
                label.text = Localized(@"no fingerprint. Please add synchronization");
                imgNameString = @"noFpIconImg";
                break;
                
            case KDSBleKeyTypeRFID:
                label.text = Localized(@"no card. Please add synchronization");
                imgNameString = @"noCardsIconImg";
                break;
                
            case KDSBleKeyTypeFace:
                label.text = Localized(@"no face. Please add synchronization");
                imgNameString = @"noFacesIconImg";
                break;
                
            default:
                break;
        }
        if (self.keyType == KDSBleKeyTypeFace) {
            UIView *routerProtocolView = [UIView new];
            routerProtocolView.backgroundColor = UIColor.clearColor;
            UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addFaceClickTap:)];
            [routerProtocolView addGestureRecognizer:tap];
            [self.view addSubview:routerProtocolView];
            [routerProtocolView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@30);
                make.left.right.equalTo(self.view);
                make.bottom.mas_equalTo(self.view.mas_bottom).offset(-KDSSSALE_HEIGHT(40));
            }];
            
            UILabel * routerProtocolLb = [UILabel new];
            routerProtocolLb.text = @"如何添加面容识别？";
            routerProtocolLb.textColor = KDSRGBColor(31, 150, 247);
            routerProtocolLb.textAlignment = NSTextAlignmentCenter;
            routerProtocolLb.font = [UIFont systemFontOfSize:14];
            [routerProtocolView addSubview:routerProtocolLb];
            NSRange strRange = {0,[routerProtocolLb.text length]};
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:routerProtocolLb.text];
            [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
            routerProtocolLb.attributedText = str;
            [routerProtocolLb mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.left.right.equalTo(routerProtocolView);
            }];
        }
        tipsImgView.image = [UIImage imageNamed:imgNameString];
        [headerView addSubview:tipsImgView];
        [headerView addSubview:label];
        [tipsImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(headerView.mas_top).offset(65);
            make.width.equalTo(@137.5);
            make.height.equalTo(@91);
            make.centerX.equalTo(headerView);
           
        }];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(headerView).offset(20);
            make.top.mas_equalTo(tipsImgView.mas_bottom).offset(30);
            make.right.equalTo(headerView).offset(-20);
            make.height.equalTo(@20);
        }];
        _footerView = headerView;
    }
    return _footerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = KDSRGBColor(0xf2, 0xf2, 0xf2);
    switch (self.keyType)
    {
        case KDSBleKeyTypePIN:
            self.navigationTitleLabel.text = Localized(@"password");
            break;
        case KDSBleKeyTypeFingerprint:
            self.navigationTitleLabel.text = Localized(@"fingerprint");
            break;
        case KDSBleKeyTypeRFID:
            self.navigationTitleLabel.text = Localized(@"doorCard");
            break;
        case KDSBleKeyTypeFace:
            self.navigationTitleLabel.text = Localized(@"faceRecognition");
            break;
            
        default:
            break;
    }
    
    [self setupUI];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadNewData];
}

- (void)setupUI
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 75;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
    
}

///刷新表视图。调用此方法前请确保已经对数据源进行了更新。
- (void)reloadData
{
    if (!self.dataSourceArr.count)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.tableView.tableFooterView = self.footerView;
        });
    }else
    {
        self.tableView.tableFooterView = [UIView new];
//        self.footerView.hidden = YES;
    }
    
    [self.tableView reloadData];
}

///刷新密码、指纹、卡片、授权用户。
- (void)loadNewData
{
    [[KDSHttpManager sharedManager] getWifiLockPwdListWithUid:[KDSUserManager sharedManager].user.uid wifiSN:self.lock.wifiDevice.wifiSN success:^(NSArray<KDSPwdListModel *> * _Nonnull pwdList, NSArray<KDSPwdListModel *> * _Nonnull fingerprintList, NSArray<KDSPwdListModel *> * _Nonnull cardList, NSArray<KDSPwdListModel *> * _Nonnull faceList, NSArray<KDSPwdListModel *> * _Nonnull pwdNicknameArr, NSArray<KDSPwdListModel *> * _Nonnull fingerprintNicknameArr, NSArray<KDSPwdListModel *> * _Nonnull cardNicknameArr, NSArray<KDSPwdListModel *> * _Nonnull faceNicknameArr, NSArray<KDSPwdListModel *> * _Nonnull pwdDuressArr, NSArray<KDSPwdListModel *> * _Nonnull fingerprintDuressArr) {
        self.tableView.mj_header.state = MJRefreshStateIdle;
        [self.dataSourceArr removeAllObjects];
        [self.nickNameArr removeAllObjects];
        switch (self.keyType) {
            case KDSBleKeyTypePIN:
                [self.dataSourceArr addObjectsFromArray:pwdList];
                [self.nickNameArr addObjectsFromArray:pwdNicknameArr];
                break;
            case KDSBleKeyTypeFingerprint:
                [self.dataSourceArr addObjectsFromArray:fingerprintList];
                [self.nickNameArr addObjectsFromArray:fingerprintNicknameArr];
                break;
            case KDSBleKeyTypeRFID:
                [self.dataSourceArr addObjectsFromArray:cardList];
                [self.nickNameArr addObjectsFromArray:cardNicknameArr];
                break;
            case KDSBleKeyTypeFace:
                [self.dataSourceArr addObjectsFromArray:faceList];
                [self.nickNameArr addObjectsFromArray:faceNicknameArr];
                break;
            default:
                break;
        }
        [self reloadData];
    } error:^(NSError * _Nonnull error) {
        self.tableView.mj_header.state = MJRefreshStateIdle;
        [MBProgressHUD showError:error.localizedDescription];
    } failure:^(NSError * _Nonnull error) {
        self.tableView.mj_header.state = MJRefreshStateIdle;
        [MBProgressHUD showError:error.localizedDescription];
    }];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.dataSourceArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = NSStringFromClass([self class]);
    KDSWiFiLockKeyCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell)
    {
        cell = [[KDSWiFiLockKeyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    KDSPwdListModel *m = self.dataSourceArr[indexPath.row];
    for (KDSPwdListModel * model in self.nickNameArr) {
        if ([model.num isEqualToString:m.num]) {
            m.nickName = model.nickName;
            break;
        }
    }
    if (m.nickName) {
        cell.name = [NSString stringWithFormat:@"%02d  %@",m.num.intValue,m.nickName];
    }else{
        cell.name = [NSString stringWithFormat:@"%02d", m.num.intValue];
    }
    
    cell.hideSeparator = indexPath.row + 1 == self.dataSourceArr.count;
   
    if (m.pwdType == KDSServerKeyTpyeCoercePIN) {
        cell.jurisdiction = Localized(@"menacePassword");
    }
    else if (m.pwdType == KDSServerKeyTpyePIN){
        cell.jurisdiction = Localized(@"permanentValidation");
    }
    else if(m.pwdType == KDSServerKeyTpyeTempPIN){
        cell.jurisdiction = Localized(@"tempPassword");
    }
    else if(m.pwdType == KDSServerKeyTpyeAdminPIN){
        cell.jurisdiction = @"管理员密码";
    }
    else if(m.pwdType == KDSServerKeyTpyeNoPermissionPIN){
        cell.jurisdiction = @"无权限密码";
    }
    else if(m.pwdType == KDSServerKeyTpyeStrategyPIN){
           cell.jurisdiction = @"策略密码";
       }
    else if(m.pwdType == KDSServerKeyTpyeInvalidValue){
        cell.jurisdiction = @"无效值密码";
    }
    else{
        cell.jurisdiction = @"";
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    KDSPwdListModel * m = self.dataSourceArr[indexPath.row];
    if (self.keyType == KDSBleKeyTypePIN) {
         KDSWifiLockPwdDetailsVC * vc = [KDSWifiLockPwdDetailsVC new];
         vc.lock = self.lock;
         vc.model = m;
         [self.navigationController pushViewController:vc animated:YES];
    }else{
        KDSWifiLockFPDetailsVC * vc = [KDSWifiLockFPDetailsVC new];
        vc.lock = self.lock;
        vc.model = m;
        vc.keyType = self.keyType;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

-(void)addFaceClickTap:(UITapGestureRecognizer *)tap
{
    KDSAddFaceRecognitionStep1VC * vc = [KDSAddFaceRecognitionStep1VC new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
