//
//  KDSSystemSettingVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/1.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSSystemSettingVC.h"
#import "KDSPersonalProfileCell.h"
#import "KDSLanguageSettingVC.h"
#import "KDSDBManager.h"
#import "KDSHttpManager.h"
#import "MBProgressHUD+MJ.h"
#import "KDSUserAgreementVC.h"
#import "KDSHttpManager+Login.h"
#import "KDSPrivacyPolicyVC.h"
//#import "KDSAuthHelpVC.h"

@interface KDSSystemSettingVC ()<UITableViewDataSource, UITableViewDelegate>

///退出登录按钮。
@property (nonatomic, weak)UIButton *logoutBtn;
@property (nonatomic, strong)NSArray *titles;

@end

@implementation KDSSystemSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titles = @[Localized(@"versionNumber"), Localized(@"userAgreement"),Localized(@"privacyPolicy")];
    //NSArray *titles = @[Localized(@"languageSetting"), Localized(@"versionNumber"), Localized(@"userAgreement")];
    //NSArray *titles = @[Localized(@"languageSetting"), Localized(@"versionNumber"), Localized(@"userAgreement"), Localized(@"clearCache")];
    self.navigationTitleLabel.text = Localized(@"systemSetting");
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(0);
        make.left.equalTo(self.view.mas_left).offset(0);
        make.right.equalTo(self.view).offset(0);
        make.height.mas_equalTo(60*self.titles.count);

    }];
    self.tableView.backgroundColor = UIColor.whiteColor;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
//    self.tableView.bounces = NO;
    
    UIButton *logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoutBtn setTitle:Localized(@"logout") forState:UIControlStateNormal];
    [logoutBtn setTitle:Localized(@"logout") forState:UIControlStateHighlighted];
    [logoutBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    logoutBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    logoutBtn.layer.shadowOffset = CGSizeMake(3, 3);
    logoutBtn.layer.shadowColor = [UIColor colorWithRed:0x2d/255.0 green:0xd9/255.0 blue:0xba/255.0 alpha:0.3].CGColor;
    logoutBtn.layer.shadowOpacity = 1.0;
    logoutBtn.layer.cornerRadius = 22;
    logoutBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    [logoutBtn addTarget:self action:@selector(clickLogoutBtnLogout:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logoutBtn];
    self.logoutBtn = logoutBtn;
    [logoutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-80);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localeLanguageDidChange:) name:KDSLocaleLanguageDidChangeNotification object:nil];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = KDSRGBColor(242, 242, 242);
}

#pragma mark - 控件等事件方法。
///点击退出登录按钮发送退出登录通知退出登录。
- (void)clickLogoutBtnLogout:(UIButton *)sender
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"ensureLogout?") message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self userLogoutAcount];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleDefault handler:nil];
    [cancel setValue:[UIColor blackColor] forKey:@"titleTextColor"];
    [ac addAction:cancel];
    [ac addAction:ok];
    [self presentViewController:ac animated:YES completion:nil];
}

#pragma mark - 网络请求方法。
//用户退出登录
-(void)userLogoutAcount{
    int source = 1;
    NSString *userName = [KDSTool getDefaultLoginAccount];
    if ([KDSTool isValidateEmail:userName])
    {
        source = 2;
    }
    MBProgressHUD *hud = [MBProgressHUD showMessage:@"" toView:self.view];
    [[KDSHttpManager sharedManager] logout:source username:[KDSTool getDefaultLoginAccount] uid:[KDSUserManager sharedManager].user.uid success:^{
        [hud hideAnimated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:KDSLogoutNotification object:nil userInfo:nil];
    } error:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:error.localizedDescription];
    } failure:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:error.localizedDescription];
    }];
}
///检查应用的App Store版本。
- (void)checkAppStoreVersion
{
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://itunes.apple.com/lookup?id=1155786023"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    req.HTTPMethod = @"GET";
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view];
            NSDictionary *dict;
            if (data != nil) {
               dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            }
            
            NSArray<NSDictionary *> *results = dict[@"results"];
            NSString *version = results.firstObject[@"version"];
            ///FIXME:这里compare判断需要特别注意版本号的设置，例如9.8.8和10.0.1会得到不希望的结果。
            if (!version.length || [version compare:KDSTool.appVersion]==NSOrderedAscending)
            {
                [self showlatestVersion];
                return;
            }
            BOOL same = [version isEqualToString:KDSTool.appVersion];
            
             UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(same ? @"appVersionIsNewest" : @"newVersionWhetherUpdate?") message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            ///好的/取消
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:Localized(same ? @"good" :@"cancel") style:UIAlertActionStyleCancel handler:nil];
            [cancel setValue:[UIColor blackColor] forKey:@"titleTextColor"];
            
           
            UIAlertAction *okOrUpdate = [UIAlertAction actionWithTitle:Localized(same ? @"ok" : @"update") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (!same)///如果与服务器不相同
                {
                    NSString *protocol = @"itms-apps://itunes.apple.com/cn/app/id1155786023?mt=8";
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:protocol]];
                }
            }];
            if (same)
            {
                [ac addAction:cancel];
                
            }else{
                [ac addAction:cancel];
                [ac addAction:okOrUpdate];
            }
            [self presentViewController:ac animated:YES completion:nil];
        });
        
    }];
    [task resume];
}

-(void)showlatestVersion
{
     UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"appVersionIsNewest") message:nil preferredStyle:UIAlertControllerStyleAlert];
    ///好的/取消
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:Localized(@"good") style:UIAlertActionStyleCancel handler:nil];
    [ac addAction:cancel];
    [self presentViewController:ac animated:YES completion:nil];
    
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titles.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = NSStringFromClass([self class]);
    KDSPersonalProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell)
    {
        cell = [[KDSPersonalProfileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
        cell.clipsToBounds = YES;
    }
    cell.title = self.titles[indexPath.row];
    NSString * appVersion = [NSString stringWithFormat:@"%@V%@",Localized(@"current version"),KDSTool.appVersion];
    cell.nickname = indexPath.row==0 ? appVersion : nil;
    cell.hideSeparator = indexPath.row == 2;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
//        case 0://语言设置
//        {
//            KDSLanguageSettingVC *vc = [KDSLanguageSettingVC new];
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//            break;
            
//        case 1://版本更新
        case 0://版本更新

            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [self checkAppStoreVersion];
            break;
            
//        case 2://用户协议
        case 1://用户协议

        {
            KDSUserAgreementVC *vc = [KDSUserAgreementVC new];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
            //隐私政策
        case 2:
        {
            KDSPrivacyPolicyVC * vc = [KDSPrivacyPolicyVC new];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
            /*
//        case 3://清理缓存
        case 2://清理缓存
            
        {
            UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:nil message:Localized(@"ClearPicturesAndLockinformation") preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleCancel handler:nil];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"empty") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.removeFromSuperViewOnHide = YES;
                hud.dimBackground = YES;
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [[KDSDBManager sharedManager] clearDiskCache];
                    //如果没有缓存数据的时候，清除操作执行很快，这时直接隐藏hud没效果，因此延时1秒执行。
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [hud hideAnimated:NO];
                        [MBProgressHUD showSuccess:Localized(@"clearDiskCacheSuccess")];
                    });
                });
                
            }];
            
            [cancelAction setValue:[UIColor blackColor] forKey:@"titleTextColor"];
            [alertVC addAction:cancelAction];
            [alertVC addAction:okAction];
            [self presentViewController:alertVC animated:YES completion:nil];
          
            
        }
            break;
             */
            
        default:
            break;
    }
}

///收到更改了本地语言的通知，刷新表视图。
- (void)localeLanguageDidChange:(NSNotification *)noti
{
    [self.tableView reloadData];
    [self.logoutBtn setTitle:Localized(@"logout") forState:UIControlStateNormal];
}

@end
