//
//  KDSAutomaticSceneDetailsVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/2/18.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSAutomaticSceneDetailsVC.h"
#import "KDSSceneDetailStyle1Cell.h"
#import "KDSSceneDetailStyle2Cell.h"
#import "KDSSceneDetailStyle3Cell.h"
#import "KDSDeviceTimingCell.h"
#import "KDSSceneDetailStyle4Cell.h"
#import "KDSMQTTManager+SmartHome.h"
#import "MBProgressHUD+MJ.h"

@interface KDSAutomaticSceneDetailsVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView * tableView;
@property (nonatomic,strong)UIView * headerView;
@property (nonatomic,strong)UIView * footerView;


@end

@implementation KDSAutomaticSceneDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = @"场景详情";
    [self setUI];
}

-(void)setUI{
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(self.view);
    }];
    
    self.headerView = [UIView new];
    self.headerView.backgroundColor = UIColor.yellowColor;
    self.headerView.frame = CGRectMake(0, 0, kScreenWidth,130);
    self.tableView.tableHeaderView = self.headerView;
    self.footerView = [UIView new];
    self.footerView.frame = CGRectMake(0, 30, KDSScreenWidth, 80);
    self.tableView.tableFooterView = self.footerView;
    UIButton * tempBtn = [UIButton new];
    tempBtn.backgroundColor = UIColor.cyanColor;
    tempBtn.layer.masksToBounds = YES;
    tempBtn.layer.cornerRadius = 22;
    [tempBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.footerView addSubview:tempBtn];
    [tempBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.footerView.mas_top).offset(30);
        make.width.equalTo(@200);
        make.height.equalTo(@44);
        make.centerX.equalTo(self.tableView);
    }];
}

#pragma mark UITableViewControllerDelegate


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        NSString *oneReuseId = NSStringFromClass([self class]);
        KDSSceneDetailStyle2Cell * oneCell = [tableView dequeueReusableCellWithIdentifier:oneReuseId];
        if (!oneCell)
        {
            oneCell = [[KDSSceneDetailStyle2Cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:oneReuseId];
        }
        return oneCell;
    }else if (indexPath.row == 1){
        NSString * twoReuseId = NSStringFromClass([self class]);
        KDSSceneDetailStyle1Cell * twoCell = [tableView dequeueReusableCellWithIdentifier:twoReuseId];
        if (!twoCell)
        {
            twoCell = [[KDSSceneDetailStyle1Cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:twoReuseId];
        }
        return twoCell;
        
    }else if (indexPath.row == 2){
        NSString * threeReuseId = NSStringFromClass([self class]);
        KDSSceneDetailStyle3Cell * threeCell = [tableView dequeueReusableCellWithIdentifier:threeReuseId];
        if (!threeCell)
        {
            threeCell = [[KDSSceneDetailStyle3Cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:threeReuseId];
        }
        return threeCell;
        
    }else if (indexPath.row == 3){
        NSString * foureReuseId = NSStringFromClass([self class]);
        KDSSceneDetailStyle4Cell * foureCell = [tableView dequeueReusableCellWithIdentifier:foureReuseId];
        if (!foureCell)
        {
            foureCell = [[KDSSceneDetailStyle4Cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:foureReuseId];
        }
        return foureCell;
    }
    else{
        NSString * fiveReuseId = NSStringFromClass([self class]);
        KDSDeviceTimingCell * fiveCell = [tableView dequeueReusableCellWithIdentifier:fiveReuseId];
        if (!fiveCell)
        {
            fiveCell = [[KDSDeviceTimingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:fiveReuseId];
        }
        return fiveCell;
        
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            return 50;
            break;
        case 1:
            return 160;
            break;
        case 2:
            return 50;
            break;
        case 3:
            return 120;
            break;
        case 4:
            return 75;
            break;
            
        default:
            break;
    }
    return 0;
}


#pragma mark --Lazy load
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = ({
            UITableView * b = [UITableView new];
            b.backgroundColor = UIColor.clearColor;
            b.showsVerticalScrollIndicator = NO;
            b.showsHorizontalScrollIndicator = NO;
            b.delegate = self;
            b.dataSource = self;
            b.separatorStyle = UITableViewCellSeparatorStyleNone;
            b;
        });
    }
    return _tableView;
}

#pragma mark 点击事件
-(void)btnClick:(UIButton *)sender
{
    NSLog(@"点击999999999");
    GatewayModel * model = [GatewayModel new];
    for (KDSGW * m in [KDSUserManager sharedManager].gateways) {
        if ([m.model.model isEqualToString:@"6032"]) {
            model = m.model;
            continue;
        }
    }
//    [[KDSMQTTManager sharedManager] gw:model delTriggerId:@"001" completion:^(NSError * _Nullable error, BOOL success) {
//        if (success) {
//            NSLog(@"设备场景成功");
//        }else{
//            [MBProgressHUD showError:@"删除失败"];
//        }
//    }];
    
    
    NSMutableDictionary * dictActions = [NSMutableDictionary new];
    dictActions[@"actions"] = @{@"deviceId":model.deviceSN,@"func":@"openLock",@"params":@{@"optype":@"lock",@"userid":@"",@"type":@"pin",@"pin":@"147147"}};
    NSMutableDictionary * dictTime = [NSMutableDictionary new];
    dictTime[@"time"] = @{@"startdate":@"2020/2/18",@"starttime":@"00:00",@"enddate":@"2020/3/18",@"endtime":@"00:00",@"timezone":@"+0800",@"wday":@[@0,@3,@5]};
    NSMutableDictionary * dictTrigger = [NSMutableDictionary new];
    dictTrigger[@"trigger"] = @{@"deviceId":model.deviceSN,@"deviceType":@"kdszblock",@"event":@"event"};
    NSMutableDictionary * dictContion = [NSMutableDictionary new];
    dictContion[@"contion"] = @{@"deviceId":model.deviceSN,@"attributeId":@"Attriid",@"operator":@">",@"value":@"111"};

    [[KDSMQTTManager sharedManager] gw:model setTriggerActions:dictActions time:dictTime trigger:dictTrigger contion:dictContion completion:^(NSError * _Nullable error, BOOL success) {
        if (success) {
            NSLog(@"设备场景成功");
            [MBProgressHUD showError:@"设备场景成功"];
        }else{
            [MBProgressHUD showError:@"新增失败"];
        }

    }];
    
//    [[KDSMQTTManager sharedManager] gw:model getTriggerId:@"002" completion:^(NSError * _Nullable error, BOOL success) {
//         if (success)
//         {
//            NSLog(@"设备场景成功");
//         }else{
//            [MBProgressHUD showError:@"查询失败"];
//         }
//
//    }];
    
     
     
     
}

@end
