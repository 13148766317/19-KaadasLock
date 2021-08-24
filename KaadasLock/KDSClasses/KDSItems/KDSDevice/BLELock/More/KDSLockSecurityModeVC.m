//
//  KDSLockSecurityModeVC.m
//  xiaokaizhineng
//
//  Created by orange on 2019/2/18.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSLockSecurityModeVC.h"
#import "MBProgressHUD+MJ.h"
#import "KDSBleAssistant.h"
#import "KDSAlertController.h"
#import "KDSSafeStateCell.h"

@interface KDSLockSecurityModeVC ()<UITableViewDataSource,UITableViewDelegate>

///开关
@property (nonatomic, weak) UISwitch *swi;
@property (nonatomic, strong)UITableView * tableview;
@property (nonatomic, strong)NSMutableArray * dataSourceArr;

@end

@implementation KDSLockSecurityModeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = self.title = Localized(@"securityMode");
    
    //安全模式标签+开关按钮
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
    view.backgroundColor = UIColor.whiteColor;
    UILabel *modelLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 50)];
    modelLabel.text = self.title;
    modelLabel.font = [UIFont systemFontOfSize:15];
    modelLabel.textColor = KDSRGBColor(0x33, 0x33, 0x33);
    [view addSubview:modelLabel];
    
    UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 26, 15)];
    switchControl.transform = CGAffineTransformMakeScale(sqrt(0.5), sqrt(0.5));
    if (self.lock.wifiDevice) {
        //wifi锁多一个提示语
        switchControl.on = self.lock.wifiDevice.safeMode.intValue;
        UILabel * tipsLb = [UILabel new];
        tipsLb.text = @"注：请到锁端设置模式 ";
        tipsLb.font = [UIFont systemFontOfSize:13];
        tipsLb.textColor = UIColor.blackColor;
        tipsLb.textAlignment = NSTextAlignmentLeft;
        [self.view addSubview:tipsLb];
        [tipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view.mas_top).offset(50 + 19);
            make.left.mas_equalTo(self.view.mas_left).offset(13);
            make.right.mas_equalTo(self.view.mas_right).offset(-13);
            make.height.mas_equalTo(@15);
        }];
    }else{
        switchControl.on = self.lock.bleTool.connectedPeripheral.isAutoMode;
    }
    switchControl.center = CGPointMake(kScreenWidth - 33, 20);
    [switchControl addTarget:self action:@selector(switchStateDidChange:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:switchControl];
    [self.view addSubview:view];
    self.swi = switchControl;
    
    //锁图片
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DKSLockBlue"]];
    CGFloat width = iv.image.size.width;
    CGFloat heitht = iv.image.size.height;
    iv.frame = CGRectMake((kScreenWidth - width) / 2, CGRectGetMaxY(view.frame) + (kScreenHeight < 667 ? 30 : 46), width, heitht);
    [self.view addSubview:iv];
    
    //提示标签+提示内容。
    UILabel *tipsLabel = [[UILabel alloc] init];
    tipsLabel.text = Localized(@"securityModeSettingTips");
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.numberOfLines = 0;
    tipsLabel.font = [UIFont systemFontOfSize:12];
    tipsLabel.textColor = KDSRGBColor(0x99, 0x99, 0x99);
    CGRect bounds = [tipsLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth - 20, kScreenHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : tipsLabel.font} context:nil];
    tipsLabel.frame = CGRectMake(10, CGRectGetMaxY(iv.frame) + (kScreenHeight < 667 ? 20 : 40), kScreenWidth - 20, ceil(bounds.size.height));
    [self.view addSubview:tipsLabel];
    ///初始化数据源
    [self setDataSource];
    
    self.tableview = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableview.rowHeight = 75;
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.tableFooterView = [UIView new];
    [self.view addSubview:self.tableview];
    [self.tableview mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(tipsLabel.mas_bottom).offset(20);
//        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-kBottomSafeHeight);
        make.height.equalTo(@(75*self.dataSourceArr.count));
        make.left.mas_equalTo(self.view.mas_left).offset(10);
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
    }];
    [self.lock.bleTool getLockInfo:^(KDSBleError error, KDSBleLockInfoModel * _Nullable infoModel) {
        if (infoModel)
        {
            switchControl.on = ((infoModel.lockFunc >> 13) & 0x1) && ((infoModel.lockState >> 5) & 0x1);
        }
    }];
}

- (void)setDataSource
{
    NSString *function;
    if (self.lock.wifiDevice) {
        function = self.lock.wifiLockFunctionSet;
    }else{
        function = self.lock.lockFunctionSet;
    }
    if ([KDSLockFunctionSet[function] containsObject:@7] && [KDSLockFunctionSet[function] containsObject:@8]){
        //密码+指纹
        NSDictionary * dic = @{@"leftIV":@"password",
                               @"rightIV":@"fingerprint",
                               @"leftLabel":Localized(@"PIN"),
                               @"rightLabel":Localized(@"fingerprint")
        };
        [self.dataSourceArr addObject:dic];
    }
    if ([KDSLockFunctionSet[function] containsObject:@7] && [KDSLockFunctionSet[function] containsObject:@9]){
        //密码+卡片
        NSDictionary * dic = @{@"leftIV":@"password",
                               @"rightIV":@"card",
                               @"leftLabel":Localized(@"PIN"),
                               @"rightLabel":Localized(@"card")
        };
        [self.dataSourceArr addObject:dic];
    }
    if ([KDSLockFunctionSet[function] containsObject:@8] && [KDSLockFunctionSet[function] containsObject:@9]){
        //卡片+指纹
        NSDictionary * dic = @{@"leftIV":@"card",
                               @"rightIV":@"fingerprint",
                               @"leftLabel":Localized(@"card"),
                               @"rightLabel":Localized(@"fingerprint")
        };
        [self.dataSourceArr addObject:dic];
    }
    if ([KDSLockFunctionSet[function] containsObject:@7] && [KDSLockFunctionSet[function] containsObject:@26]){
        //密码、人脸
        NSDictionary * dic = @{@"leftIV":@"password",
                               @"rightIV":@"face",
                               @"leftLabel":Localized(@"PIN"),
                               @"rightLabel":Localized(@"face")
        };
        [self.dataSourceArr addObject:dic];
    }
    if ([KDSLockFunctionSet[function] containsObject:@8] && [KDSLockFunctionSet[function] containsObject:@26]){
        //指纹、人脸
        NSDictionary * dic = @{@"leftIV":@"fingerprint",
                               @"rightIV":@"face",
                               @"leftLabel":Localized(@"fingerprint"),
                               @"rightLabel":Localized(@"face")
        };
        [self.dataSourceArr addObject:dic];
    }
    if ([KDSLockFunctionSet[function] containsObject:@9] && [KDSLockFunctionSet[function] containsObject:@26]){
        //卡片、人脸
        NSDictionary * dic = @{@"leftIV":@"card",
                               @"rightIV":@"face",
                               @"leftLabel":Localized(@"card"),
                               @"rightLabel":Localized(@"face")
        };
        
        [self.dataSourceArr addObject:dic];
    }
}

//MARK:点击安全模式开关启动或关闭安全模式。
- (void)switchStateDidChange:(UISwitch *)sender
{
    if (self.lock.wifiDevice) {//wifi锁不可以设置
        KDSAlertController *alert = [KDSAlertController alertControllerWithTitle:@"App不可设置，请在锁端设置" message:nil];
        [self presentViewController:alert animated:YES completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:^{
                [sender setOn:!sender.isOn animated:YES];
            }];
        });
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    __weak typeof(self) weakSelf = self;
    if (self.lock.gwDevice)
    {
        return;
    }
    [weakSelf.lock.bleTool setLockSecurityModeStatus:sender.on ? 1 : 0 completion:^(KDSBleError error) {
        [hud hideAnimated:NO];
        if (error == KDSBleErrorSuccess)
        {
            weakSelf.lock.bleTool.connectedPeripheral.isAutoMode = sender.isOn;
            [MBProgressHUD showSuccess:Localized(@"setSuccess")];
        }
        else
        {
            [sender setOn:!sender.isOn animated:YES];
            [MBProgressHUD showError:Localized(@"setFailed")];
        }
    }];
}


#pragma MARK ---UITableview--代理

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = NSStringFromClass([self class]);
    KDSSafeStateCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell)
    {
        cell = [[KDSSafeStateCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    cell.dict = self.dataSourceArr[indexPath.row];
    
    return cell;
}


#pragma --Lazy load

- (NSMutableArray *)dataSourceArr
{
    if (!_dataSourceArr) {
        _dataSourceArr = [NSMutableArray array];
    }
    return _dataSourceArr;
}

@end
