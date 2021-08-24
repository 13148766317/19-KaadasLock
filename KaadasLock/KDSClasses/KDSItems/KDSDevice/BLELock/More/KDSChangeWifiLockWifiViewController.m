//
//  KDSChangeWifiLockWifiViewController.m
//  KaadasLock
//
//  Created by kaadas on 2021/1/29.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSChangeWifiLockWifiViewController.h"
#import "KDSLockMoreSettingCell.h"
#import "KDSConnectedReconnectVC.h"

@interface KDSChangeWifiLockWifiViewController ()<UITableViewDataSource,UITableViewDelegate>
///表视图。
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray * titles;

@end

@implementation KDSChangeWifiLockWifiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationTitleLabel.text = @"更换Wifi";
    [self.titles addObjectsFromArray:@[@"更换Wi-Fi",@"Wi-Fi名称",@"Wi-Fi强度",@"RSSI",@"BISSID"]];
//    if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@11])[self.titles addObject:@"A-M自动/手动模式"];
//    if ([KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@46])[self.titles addObject:@"节能模式"];
//    [self.titles addObjectsFromArray:@[@"门锁语言",@"静音模式",@"设备信息"]];
   
    
    // 初始化UItableView
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = [UIView new];
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 60;
  
}



#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titles.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = NSStringFromClass([self class]);
    KDSLockMoreSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell)
    {
        cell = [[KDSLockMoreSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    cell.title = self.titles[indexPath.row];
    cell.hideSeparator = indexPath.row == self.titles.count - 1;
    cell.clipsToBounds = YES;
    if ([cell.title isEqualToString:@"更换Wi-Fi"]) {
        cell.hideSwitch = YES;
    }else if ([cell.title isEqualToString:@"Wi-Fi名称"]){
        cell.subtitle = self.lock.wifiDevice.wifiName;
        cell.hideArrow = YES;
        cell.hideSwitch = YES;
    }else if ([cell.title isEqualToString:@"Wi-Fi强度"]){
        cell.subtitle = @"";
        cell.hideArrow = YES;
        cell.hideSwitch = YES;
    }else if ([cell.title isEqualToString:@"RSSI"]){
        cell.subtitle = self.lock.wifiDevice.RSSI?: @"";
        cell.hideArrow = YES;
        cell.hideSwitch = YES;
    }else if ([cell.title isEqualToString:@"BISSID"]){
        cell.subtitle = self.lock.wifiDevice.lockMac ?: @"";
        cell.hideArrow = YES;
        cell.hideSwitch = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 进入设备重新配网
    if (indexPath.row ==0) {
        // 进入设备重新配网
        KDSConnectedReconnectVC * vc = [KDSConnectedReconnectVC new];
        vc.lock = self.lock;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
   
     
}

#pragma Lazy --load

- (NSMutableArray *)titles
{
    if (!_titles) {
        _titles = [NSMutableArray array];
    }
    return _titles;
}


@end
