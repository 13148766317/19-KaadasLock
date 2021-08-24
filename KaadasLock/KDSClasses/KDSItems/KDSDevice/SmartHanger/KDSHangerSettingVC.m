//
//  KDSHangerSettingsVC.m
//  KaadasLock
//
//  Created by Apple on 2021/4/9.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSHangerSettingVC.h"
#import "CateyeSetModel.h"
#import "KDSCatEyeMoreSettingCellTableViewCell.h"
#import "KDSLockMoreSettingCell.h"

#import "KDSHttpManager+SmartHanger.h"
#import "MBProgressHUD.h"
#import "KDSHangerModifyNicknameVC.h"
#import "KDSUserManager.h"
#import "KDSMQTTManager+Hanger.h"
@interface KDSHangerSettingVC () <UITableViewDataSource, UITableViewDelegate>
@property(nonatomic,strong) UITableView * tableView;
@property(nonatomic,strong) NSArray *dataArray;

@property(nonatomic,strong) UIButton * delGWBtn;
@property(nonatomic, strong) UIButton *deleteBtn;

@property(nonatomic, strong) NSArray *upgradeTask;
@property(nonatomic, strong) KDSHangerModifyNicknameVC *modifyNicknameVC;
@end

@implementation KDSHangerSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = NSLocalizedString(@"设置", nil);
    
    //self.title = self.hanger.hangerNickName;

    self.view.backgroundColor = KDSPublicBackgroundColor;
    
    
   
    [self updateDataSource];
    
    

    
    
    
    [self setUI];
}

-(void) updateDataSource {
    self.dataArray = @[
        @{@"title":NSLocalizedString(@"设备名称", nil),@"subTitle":self.hanger.hangerNickName ? :@""},
        @{@"title":NSLocalizedString(@"晾衣机序列号", nil),@"subTitle":self.hanger.hangerSN ? :@""},
        @{@"title":NSLocalizedString(@"模组序列号", nil),@"subTitle":self.hanger.moduleSN ? :@""},
        @{@"title":NSLocalizedString(@"晾衣机版本号", nil),@"subTitle":self.hanger.hangerVersion ? :@""},
        @{@"title":NSLocalizedString(@"模组版本号", nil),@"subTitle":self.hanger.moduleVersion ? :@""},
        @{@"title":NSLocalizedString(@"检查更新", nil),@"subTitle":@""},
    ];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     self.navigationController.navigationBar.barTintColor = KDSRGBColor(242, 242, 242);
    if (self.navigationController.isNavigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO];
    }
    ESWeakSelf
    [[KDSMQTTManager sharedManager] getHangerStatus:self.hanger completion:^(NSError * _Nullable error, BOOL success) {
        KDSLog(@"result %d", success);
        if (success) {
            [__weakSelf updateUI];
        }
    }];
}

-(void)setUI{
    

    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = [UIView new];
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    CGFloat offset = 0;
    if (kStatusBarHeight + kNavBarHeight + 9*60 + 84 > kScreenHeight)
    {
        offset = -44;
    }
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);//.offset(offset);
    }];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 60;
    
    self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat height = 44;
    self.deleteBtn.layer.cornerRadius = height / 2.0;
    self.deleteBtn.backgroundColor = KDSRGBColor(0xff, 0x3b, 0x30);
    [self.deleteBtn setTitle:NSLocalizedString(@"deleteDevice", nil) forState:UIControlStateNormal];
    [self.deleteBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.deleteBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.deleteBtn addTarget:self action:@selector(delClick:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.deleteBtn];

    [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-45);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];

}

-(void) updateUI {
    ESWeakSelf
    [self updateDataSource];
    dispatch_main_async_safe(^(){
        [__weakSelf.tableView reloadData];
    });
}

-(void)delClick:(UIButton *)sender
{
    
    UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"删除后，需要重新连接是否删除？", nil) message:nil  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancle = [UIAlertAction actionWithTitle:NSLocalizedString(@"否", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    ESWeakSelf
    UIAlertAction * ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"是", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        
        [__weakSelf deleteDevice];
        
        
    }];
    //修改按钮
    [cancle setValue:KDSRGBColor(51, 51, 51) forKey:@"titleTextColor"];
    
    
    
    [alerVC addAction:cancle];
    [alerVC addAction:ok];
    [self presentViewController:alerVC animated:YES completion:nil];
    
}


/**
 *  执行删除设备
 */
-(void) deleteDevice {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ESWeakSelf
    [[KDSHttpManager sharedManager] unbindSmartHanger:self.hanger success:^{
        
        hud.mode = MBProgressHUDModeText;
        hud.label.text = NSLocalizedString(@"删除成功", nil);
        [hud hideAnimated:YES afterDelay:2.0];
        hud.completionBlock = ^{
            //删除
            [[KDSUserManager sharedManager].hangers removeObject:self.hanger];

            [__weakSelf.navigationController popViewControllerAnimated:YES];
        };
        
        } error:^(NSError * _Nonnull error) {
            hud.mode = MBProgressHUDModeText;
            hud.label.text = NSLocalizedString(@"删除出错", nil);
            [hud hideAnimated:YES afterDelay:2.0];
        } failure:^(NSError * _Nonnull error) {
            hud.mode = MBProgressHUDModeText;
            hud.label.text = NSLocalizedString(@"删除失败", nil);
            [hud hideAnimated:YES afterDelay:2.0];
        }];
}

/**
 * 检查更新
 */
-(void) checkUpdate {
    //显示加载
    //提示：如果有升级，弹窗提示是否升级；否则提示已经是新版
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ESWeakSelf
    [[KDSHttpManager sharedManager] checkUpdateSmartHanger:self.hanger customer:1 success:^(id upgradeTask) {
        
        if (upgradeTask && [upgradeTask isKindOfClass:[NSArray
                                                       class]]) {
            __weakSelf.upgradeTask = [[NSArray alloc] initWithArray:upgradeTask];
            [hud hideAnimated:NO];
            [__weakSelf  confirmUpgrade];
        }else {
            KDSLog(@"%@",upgradeTask);
            hud.mode = MBProgressHUDModeText;
            hud.label.text = NSLocalizedString(@"已是最新版本", nil);
            [hud hideAnimated:YES afterDelay:2.0];
        }
        
        } error:^(NSError * _Nonnull error) {
            KDSLog(@"error %@",[error description]);
            hud.mode = MBProgressHUDModeText;
            hud.label.text = (error.code == 210 ? NSLocalizedString(@"已是最新版本", nil): NSLocalizedString(@"检查出错", nil));
            [hud hideAnimated:YES afterDelay:2.0];
        } failure:^(NSError * _Nonnull error) {
            KDSLog(@"error %@",[error description]);
            hud.mode = MBProgressHUDModeText;
            hud.label.text = NSLocalizedString(@"检查失败", nil);
            [hud hideAnimated:YES afterDelay:2.0];
        }];
    
}

/*
 * 确认升级
 */
-(void) confirmUpgrade {
    UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"发现新版本，是否更新？", nil) message:nil  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancle = [UIAlertAction actionWithTitle:NSLocalizedString(@"否", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    ESWeakSelf
    UIAlertAction * ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"是", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        
        [__weakSelf upgradeDevice];
        
        
    }];
    //修改按钮
    [cancle setValue:KDSRGBColor(51, 51, 51) forKey:@"titleTextColor"];
    
    
    
    [alerVC addAction:cancle];
    [alerVC addAction:ok];
    [self presentViewController:alerVC animated:YES completion:nil];
}

/*
 * 升级设备
 */
-(void) upgradeDevice {
    //发送升级指令
    //显示执行结果
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    
    [[KDSHttpManager sharedManager] upgradeSmartHanger:self.hanger upgradeTask:self.upgradeTask success:^{
        hud.mode = MBProgressHUDModeText;
        hud.label.text = NSLocalizedString(@"设备即将升级...", nil);
        [hud hideAnimated:YES afterDelay:5.0];

    } error:^(NSError * _Nonnull error) {
        hud.mode = MBProgressHUDModeText;
        hud.label.text = NSLocalizedString(@"升级出错", nil);
        [hud hideAnimated:YES afterDelay:2.0];
    } failure:^(NSError * _Nonnull error) {
        hud.mode = MBProgressHUDModeText;
        hud.label.text = NSLocalizedString(@"升级失败", nil);
        [hud hideAnimated:YES afterDelay:2.0];
    }];
    
    
}

-(void) showModifyNicknameVC {
    self.modifyNicknameVC = [[KDSHangerModifyNicknameVC alloc] init];
    self.modifyNicknameVC.navTitle = NSLocalizedString(@"设置", nil);
    self.modifyNicknameVC.nickName = self.hanger.hangerNickName;
    self.modifyNicknameVC.placeholder = NSLocalizedString(@"请输入晾衣机名称", nil);
    ESWeakSelf
    self.modifyNicknameVC.saveBlock = ^(NSString * _Nonnull nickName) {
        
        NSUInteger nameLength = nickName.length;
        BOOL isInvaildNameLenght = nameLength ? NO : YES;
        if (isInvaildNameLenght) {
            [MBProgressHUD showError:NSLocalizedString(@"无效长度", nil)];
            return;
        }
        
        [__weakSelf modifyNickname:nickName];
//        [__weakSelf.modifyNicknameVC.navigationController popViewControllerAnimated:YES];
//        __weakSelf.modifyNicknameVC.saveBlock = nil;
//        __weakSelf.modifyNicknameVC = nil;
        
    };
    [self.navigationController pushViewController:self.modifyNicknameVC animated:YES];
}

-(void) modifyNickname:(NSString *) nickName {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.modifyNicknameVC.view animated:YES];

    ESWeakSelf
    [[KDSHttpManager sharedManager] updateSmartHanger:self.hanger nickName:nickName success:^{
        hud.mode = MBProgressHUDModeText;
        hud.label.text = NSLocalizedString(@"修改成功", nil);
        [hud hideAnimated:YES afterDelay:2.0];
        hud.completionBlock = ^{
            [__weakSelf.modifyNicknameVC.navigationController popViewControllerAnimated:YES];
            __weakSelf.modifyNicknameVC.saveBlock = nil;
            __weakSelf.modifyNicknameVC = nil;
            __weakSelf.hanger.hangerNickName = nickName;
            [__weakSelf updateUI];
        };
    } error:^(NSError * _Nonnull error) {
        hud.mode = MBProgressHUDModeText;
        hud.label.text = NSLocalizedString(@"修改出错", nil);
        [hud hideAnimated:YES afterDelay:2.0];
    } failure:^(NSError * _Nonnull error) {
        hud.mode = MBProgressHUDModeText;
        hud.label.text = NSLocalizedString(@"修改失败", nil);
        [hud hideAnimated:YES afterDelay:2.0];
    }];
}

#pragma mark UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    

    NSString *reuseId = NSStringFromClass([self class]);
    KDSLockMoreSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell)
    {
        cell = [[KDSLockMoreSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    
    switch (indexPath.row) {
        case 0:
        case 5:
            cell.hideArrow = NO;
            break;
            
        default:
            cell.hideArrow = YES;
            break;
    }
    
    NSDictionary *title = self.dataArray[indexPath.row];
    cell.title = [title objectForKey:@"title"];
    cell.subtitle = [title objectForKey:@"subTitle"];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && indexPath.row == 5) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    if (indexPath.row == 0) {
        [self showModifyNicknameVC];
    }
    if (indexPath.row == 5) {
        [self checkUpdate];
    }
}

@end
