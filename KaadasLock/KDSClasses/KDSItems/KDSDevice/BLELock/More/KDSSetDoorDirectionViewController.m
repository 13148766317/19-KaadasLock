//
//  KDSSetDoorDirectionViewController.m
//  KaadasLock
//
//  Created by kaadas on 2021/3/1.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSSetDoorDirectionViewController.h"
#import "KDSLockMoreSettingCell.h"
#import "KDSMQTTManager+SmartHome.h"
#import "XMP2PManager.h"
#import "XMUtil.h"
#import "KDSCateyeMoreCell.h"
#import "MBProgressHUD+MJ.h"

@interface KDSSetDoorDirectionViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView * tableView;

@property(nonatomic,strong)NSMutableArray * dataSourceArr;
///当前开门方向
@property(nonatomic,assign)NSUInteger currentIndex;
///服务器上的原始开门方向
@property(nonatomic,assign)NSUInteger openDirectionRawData;
///保存按钮
@property(nonatomic,strong)UIButton * saveBtn;
///开门方向分配值数组
@property (nonatomic,strong) NSArray *openDirections;

@end

@implementation KDSSetDoorDirectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationTitleLabel.text = @"开门方向";
    [self setDataArray];
    [self setUI];
}

- (void)setUI
{
    self.currentIndex = self.lock.wifiDevice.openDirection;
    self.openDirectionRawData = self.lock.wifiDevice.openDirection;
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.saveBtn];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_offset(0);
        make.height.mas_equalTo(self.dataSourceArr.count * 60);
    }];
    [self.saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-KDSSSALE_HEIGHT(50));
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];
}

-(void)setDataArray
{
    if (_dataSourceArr == nil) {
        _dataSourceArr = [NSMutableArray array];
    }
    [_dataSourceArr addObject:@"左开门"];
    [_dataSourceArr addObject:@"右开门"];
    
    self.openDirections = @[@(1),@(2)];
}

// 返回按钮：返回即触发设置事件
- (void)navBackClick {
    
    if (self.openDirectionRawData == self.currentIndex) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    MBProgressHUD *hud = [MBProgressHUD showMessage:@"设置开锁方向"];
    
    [XMP2PManager sharedXMP2PManager].model = self.lock.wifiDevice;
    [[XMP2PManager sharedXMP2PManager] connectDevice];
    [XMP2PManager sharedXMP2PManager].XMP2PConnectDevStateBlock = ^(NSInteger resultCode) {
        if (resultCode > 0) {
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
                NSString *message = [NSString stringWithFormat:@"无法连接到设备，原因是：%@", [XMUtil checkPPCSErrorStringWithRet:resultCode]];
                UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [self.navigationController popViewControllerAnimated:true];
                }];
                UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"重新连接" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [hud showAnimated:YES];
                    [XMP2PManager sharedXMP2PManager].model = self.lock.wifiDevice;
                    [[XMP2PManager sharedXMP2PManager] connectDevice];

                }];
                [cancelAction setValue:KDSRGBColor(154, 154, 154) forKey:@"titleTextColor"];
                [retryAction setValue:KDSRGBColor(32, 150, 248) forKey:@"titleTextColor"];
                [controller addAction:cancelAction];
                [controller addAction:retryAction];
                [self presentViewController:controller animated:true completion:nil];
                return;

            });
        }
    };

    [XMP2PManager sharedXMP2PManager].XMMQTTConnectDevOutTimeBlock = ^{
        ///超时
        [hud hideAnimated:YES];
        NSString *message = [NSString stringWithFormat:@"连接服务器超时，稍后再试"];
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:true];
        }];
        UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"重新连接" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [hud showAnimated:YES];
            [XMP2PManager sharedXMP2PManager].model = self.lock.wifiDevice;
            [[XMP2PManager sharedXMP2PManager] connectDevice];
        }];
        [cancelAction setValue:KDSRGBColor(154, 154, 154) forKey:@"titleTextColor"];
        [retryAction setValue:KDSRGBColor(32, 150, 248) forKey:@"titleTextColor"];
        [controller addAction:cancelAction];
        [controller addAction:retryAction];
        [self presentViewController:controller animated:true completion:nil];
        return;

    };

    [XMP2PManager sharedXMP2PManager].XMMQTTConnectDevStateBlock = ^(BOOL isCanBeDistributed) {
        if (isCanBeDistributed == YES) {
            ///讯美登录MQTT成功
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"MQTT 登录成功");

                [[KDSMQTTManager  sharedManager] setOpenDirectionWithWf:weakSelf.lock.wifiDevice value:(int)self.currentIndex completion:^(NSError *_Nullable error, BOOL success) {
                    [hud hideAnimated:YES];
                    if (success) {
                        [MBProgressHUD showSuccess:Localized(@"开锁方向设置成功")];
                        !weakSelf.openDirectionChangeBlock ?: weakSelf.openDirectionChangeBlock((int)weakSelf.currentIndex);
                    }else{
                        [MBProgressHUD showSuccess:Localized(@"开锁方向设置失败")];
                    }
                    [[XMP2PManager sharedXMP2PManager] releaseLive];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }];
            });
        }else{

            [hud hideAnimated:YES];
            [[XMP2PManager sharedXMP2PManager] releaseLive];
            [MBProgressHUD showSuccess:Localized(@"开锁方向设置失败")];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    };
    
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataSourceArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    KDSCateyeMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:KDSCateyeMoreCell.ID];
    cell.titleNameLb.text = self.dataSourceArr[indexPath.row];
    cell.hideSeparator = indexPath.row == self.dataSourceArr.count - 1;
    cell.selectBtn.tag = [self.openDirections[indexPath.row] integerValue];
    [cell.selectBtn addTarget:self action:@selector(ringNumClick:) forControlEvents:UIControlEventTouchUpInside];
    if (indexPath.row == [self titleIndexFromOpenDirections:_currentIndex]) {

        cell.selectBtn.selected = YES;
    }
    else{
        cell.selectBtn.selected = NO;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    _currentIndex = indexPath.row;
//    [self.tableView reloadData];
}

#pragma mark 手势
-(void)ringNumClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    _currentIndex = sender.tag;
    [self.tableView reloadData];
    
}
-(void)saveBtnClick:(UIButton *)sender
{
    //保存按钮事件
    
}
///获取开门方向对应标题序号
-(NSInteger) titleIndexFromOpenDirections:(NSUInteger) hoverAlarmLevel {
    
    __block NSUInteger result = NSNotFound;
    
    [self.openDirections enumerateObjectsUsingBlock:^(NSNumber * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj unsignedIntegerValue] == hoverAlarmLevel) {
            result = idx;
            *stop = YES;
        }
        
    }];
    return result;
}

#pragma mark -- lazy load
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = ({
            UITableView *tv = [[UITableView alloc] initWithFrame:CGRectZero];
            tv.separatorStyle = UITableViewCellSeparatorStyleNone;
            [tv registerClass:[KDSCateyeMoreCell class] forCellReuseIdentifier:KDSCateyeMoreCell.ID];
            tv.tableFooterView = [UIView new];
            tv.delegate = self;
            tv.dataSource = self;
            tv.scrollEnabled = NO;
            tv.rowHeight = 60;
            tv;
        });
    }
    return _tableView;
}

- (UIButton *)saveBtn
{
    if (!_saveBtn) {
        _saveBtn = ({
            UIButton * b = [UIButton new];
            [b setTitle:Localized(@"save") forState:UIControlStateNormal];
            b.backgroundColor = KDSRGBColor(31, 150, 247);
            [b setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            b.layer.cornerRadius = 22;
            b.hidden = YES;
            [b addTarget:self action:@selector(saveBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            b;
        });
    }
    return _saveBtn;
}


@end
