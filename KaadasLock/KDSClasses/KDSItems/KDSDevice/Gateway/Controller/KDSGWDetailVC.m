//
//  KDSGWDetailVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/26.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSGWDetailVC.h"
#import "KDSWGDetailHeadView.h"
#import "KDSGWInformationVC.h"
#import "KDSDeviceCell.h"



@interface KDSGWDetailVC ()<UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate>

@property (nonatomic,readwrite,strong)UITableView * tableView;
@property (nonatomic,readwrite,strong)KDSWGDetailHeadView * headView;
///网关下的猫眼
@property (nonatomic,readonly,strong)NSArray<KDSCatEye *> *cateyes;
///网关洗网关锁数组。
@property (nonatomic,strong,readonly)NSArray<KDSLock *> *gwLocks;
@property (nonatomic,readwrite,strong)UIImageView * tipsImg;
@property (nonatomic,readwrite,strong)UILabel * tipsLb;
///上个导航控制器的代理。
@property (nonatomic, weak) id<UINavigationControllerDelegate> preDelegate;


@end

@implementation KDSGWDetailVC

#pragma mark - 生命周期、界面设置方法
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUI];
    ///监听网关上线
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gatewayState:) name:KDSMQTTEventNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshInterfaceWhenDeviceDidSync:) name:KDSDeviceSyncNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     self.preDelegate = self.navigationController.delegate;
     self.navigationController.delegate = self;
    [self.headView setModel:self.gateway];
    if (self.cateyes.count == 0 && self.gwLocks.count == 0)
    {
        self.tableView.frame = self.tableView.bounds;
        if (self.cateyes.count == 0 && self.gwLocks.count == 0) {
            self.tipsImg = [UIImageView new];
            self.tipsImg.image = [UIImage imageNamed:@"gwNoBindingDevice"];
            [self.tableView addSubview:self.tipsImg];
            self.tipsLb = [UILabel new];
            self.tipsLb.text = @"暂无联动设备！";
            self.tipsLb.textColor = KDSRGBColor(153, 153, 153);
            self.tipsLb.textAlignment = NSTextAlignmentCenter;
            self.tipsLb.font = [UIFont systemFontOfSize:12];
            [self.tableView addSubview:self.tipsLb];
            [self.tipsImg mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(self.tipsImg.image.size);
                make.centerX.mas_equalTo(self.tableView.mas_centerX).offset(0);
                make.centerY.mas_equalTo(self.tableView.mas_centerY).offset((KDSScreenHeight-238)/4);
            }];
            [self.tipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(16);
                make.centerX.mas_equalTo(self.tableView.mas_centerX).offset(0);
                make.top.mas_equalTo(self.tipsImg.mas_bottom).offset(16);
            }];
        }
    }
    else
    {
        [self.tipsImg removeFromSuperview];
        [self.tipsLb removeFromSuperview];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.delegate = self.preDelegate;
}

#pragma mark leftBarButtonItem事件
-(void)leftBarBtnClick:(UIButton *)sender
{
    KDSGWInformationVC * vc = [KDSGWInformationVC new];
    vc.gw = self.gateway;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)setUI
{
    self.headView.frame = CGRectMake(0, 0, KDSScreenWidth, KDSSSALE_HEIGHT(238));
    self.headView.backgroundColor = UIColor.clearColor;
    self.tableView.tableHeaderView = self.headView;
    self.tableView.frame = CGRectMake(0, 0, KDSScreenWidth, KDSScreenHeight);
    self.tableView.rowHeight = 130;
    [self.view addSubview:self.tableView];
    
}

#pragma mark UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            ///zigbee锁
            return self.gwLocks.count;
            
        case 1:
            ///猫眼
            return self.cateyes.count;
            
            break;
       
            
        default:
            break;
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = NSStringFromClass([self class]);
    KDSDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell)
    {
        cell = [[KDSDeviceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    cell.layer.cornerRadius = 4;
    switch (indexPath.section) {
        case 0:
            ///zigbee锁
             cell.model = self.gwLocks[indexPath.row];
            break;
        case 1:
            ///猫眼
             cell.model = self.cateyes[indexPath.row];
            break;

        default:
            break;
    }

    cell.backgroundColor = self.view.backgroundColor;
    cell.hideArrow = YES;

    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [UIView new];
    view.frame = CGRectMake(0, 0, KDSScreenWidth, 35);
    UILabel * lb = [UILabel new];
    lb.frame = CGRectMake(15, 17, KDSScreenWidth-30, 20);
    lb.text = Localized(@"DiscoverDevices");
    lb.textColor = KDSRGBColor(153, 153, 153);
    lb.hidden = section == 0 ? NO : YES;
    lb.textAlignment = NSTextAlignmentLeft;
    lb.font = [UIFont systemFontOfSize:12];
    [view addSubview:lb];
    
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? 35 : 0.001;
}

#pragma marl --Lazy load

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
- (KDSWGDetailHeadView *)headView
{
     __weak typeof(self) weakSelf = self;
    if (!_headView) {
        _headView = ({
            KDSWGDetailHeadView * h = [KDSWGDetailHeadView new];
            h.model = self.gateway;
           
            h.backBtnClickBlock = ^{
                NSLog(@"点击了返回按钮");
                [weakSelf.navigationController popViewControllerAnimated:YES];
            };
            h.moreBtnClickBlock = ^{
                NSLog(@"点击了详情按钮");
                KDSGWInformationVC * vc = [KDSGWInformationVC new];
                vc.gw = weakSelf.gateway;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            };
            h.shareBtnClickBlock = ^{
                NSLog(@"点击了分享按钮");
                [weakSelf.navigationController popViewControllerAnimated:YES];
            };
            h;
        });
    }
    return _headView;
}

- (NSArray *)gwLocks
{
    NSMutableArray *locks = [NSMutableArray array];
    for (KDSLock *lock in [KDSUserManager sharedManager].locks)
    {
        if (lock.gwDevice && [lock.gwDevice.gwId isEqualToString:self.gateway.model.deviceSN])
        {
            [locks addObject:lock];
        }
    }
    return locks.copy;
}
- (NSArray *)cateyes
{
    NSMutableArray * cateyes = [NSMutableArray array];
    for (KDSCatEye * cateye in [KDSUserManager sharedManager].cateyes)
    {
        if ([cateye.gatewayDeviceModel.gwId isEqualToString:self.gateway.model.deviceSN])
        {
            [cateyes addObject:cateye];
        }
    }
    return cateyes.copy;
}

#pragma mark 通知。
///在这儿处理网关的状态
-(void)gatewayState:(NSNotification *)noti
{
    MQTTSubEvent  subevent = noti.userInfo[MQTTEventKey];
    NSDictionary *param = noti.userInfo[MQTTEventParamKey];
    NSString * uuid = param[@"uuid"];
    NSString *state = nil;
    if ([subevent isEqualToString:MQTTSubEventGWOnline]) {
        state = @"online";
    }else if ([subevent isEqualToString:MQTTSubEventGWOffline]){
        state = @"offline";
    }else if ([subevent isEqualToString:MQTTSubEventGWReset]){
        
    }
    if (state && [uuid isEqualToString:self.gateway.model.deviceSN])
    {
        self.gateway.state = state;
        self.headView.model = self.gateway;
    }
}

///当设备的数量或者各种状态等改变时，刷新本页面的设备状态。
- (void)refreshInterfaceWhenDeviceDidSync:(NSNotification *)noti
{
    self.headView.model = self.gateway;
    [self.tableView reloadData];
}
-(void)refreshInterCateyePower:(NSNotification *)noti
{
    [self.tableView reloadData];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [navigationController setNavigationBarHidden:YES animated:YES];
}

@end
