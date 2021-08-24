//
//  KDSsmartHangerViewController.m
//  KaadasLock
//
//  Created by kaadas on 2021/1/27.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSsmartHangerViewController.h"
#import "KDSFuntionTabModel.h"
#import "KDSFuntionTabListCell.h"
#import "KDSHangerTimerView.h"
#import "KDSMQTTManager+Hanger.h"
#import "KDSDeviceHangerState.h"

@interface KDSsmartHangerViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) UIView *topView;
@property(nonatomic, strong) UILabel *labMotorState;
@property(nonatomic, strong) UIImageView *ivMotor;

@property(nonatomic, strong) UIButton *btnMotorUp;
@property(nonatomic, strong) UIButton *btnMotorDown;
@property(nonatomic, strong) UIButton *btnMotorPause;
@end

@implementation KDSsmartHangerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
    
    
    // 监听语言变化的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localeLanguageDidChange:) name:KDSLocaleLanguageDidChangeNotification object:nil];
    // 接收MQtt上报事件的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wifimqttEventNotification:) name:KDSMQTTEventNotification object:nil];
    
    [self updateUI];
}

// 将视图
-(void)setupUI{
     // 将视图一分为二
    UIView
     *topview = [UIView new];
    self.topView = topview;
    topview.backgroundColor = KDSRGBColor(20, 155, 243);
    [self.view addSubview:topview];
    [topview  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.equalTo(@302);
    }];
    UIImageView  * imgview = [UIImageView new];
    imgview.image = [UIImage  imageNamed:@"hanger_motor_5"];
    [topview  addSubview:imgview ];
    self.ivMotor = imgview;
    [imgview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topview).offset(30);
        make.height.width.equalTo(@(206));
        make.centerX.equalTo(topview.mas_centerX);
    }];
    UILabel  * namelable = [UILabel new];
    //namelable.text = @"衣杆遇阻";
    namelable.font = [UIFont systemFontOfSize:14];
    self.labMotorState = namelable;
    
    [topview addSubview:namelable];
    
    
    UIView  *  funview = [UIView new];
   // funview.backgroundColor =[UIColor grayColor];
    [topview addSubview: funview];
    [funview  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.equalTo(topview);
        make.bottom.equalTo(topview).offset(-20);
        make.height.equalTo(@50);
    }];
    
    [namelable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(funview.mas_top).offset(-20);
        make.height.equalTo(@24);
        make.centerX.equalTo(topview.mas_centerX);
        
    }];
    
    
    UIButton *btnMotorPause = [self genMotorButtonImageName:@"home_icon_suspend" tag:101];
    
    [btnMotorPause  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(@50);
        make.center.equalTo(funview);
    }];
    self.btnMotorPause = btnMotorPause;
    
    UIButton *btnMotorUp = [self genMotorButtonImageName:@"home_icon_rise" tag:102];
    
    [btnMotorUp  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(@50);
        make.top.bottom.equalTo(funview);
        make.right.equalTo(btnMotorPause.mas_left).offset(-54);
    }];
    
    self.btnMotorUp = btnMotorUp;
    
    UIButton *btnMotorDown = [self genMotorButtonImageName:@"home_icon_decline" tag:103];
    
    [btnMotorDown  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(@50);
        make.top.bottom.equalTo(funview);
        make.left.equalTo(btnMotorPause.mas_right).offset(54);
    }];
    
    self.btnMotorDown = btnMotorDown;
  
    [self.view addSubview:self.collectionView];
    ESWeakSelf
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.edges.equalTo(self.view);
        //make.height.equalTo(@500);
        make.top.mas_equalTo(__weakSelf.topView.mas_bottom);
        make.bottom.equalTo(__weakSelf.view.mas_bottom);
        make.left.equalTo(__weakSelf.view);
        make.right.equalTo(__weakSelf.view);
        
    }];

    self.view.backgroundColor = [UIColor
                                 clearColor];
    self.topView.backgroundColor = [UIColor clearColor];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   
    ESWeakSelf
    [[KDSMQTTManager sharedManager] getHangerStatus:self.lock.hangerModel completion:^(NSError * _Nullable error, BOOL success) {
        KDSLog(@"result %d", success);
        if (success) {
            [__weakSelf updateUI];
        }
    }];

}
-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.ivMotor isAnimating]) {
        [self.ivMotor stopAnimating];
    }
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIButton
   *) genMotorButtonImageName:(NSString *) imageName tag:(NSUInteger ) tag {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(motorAction:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = tag;
    [self.topView addSubview:button];
    return button;
}
- (void) updateUI {
    
    ESWeakSelf
    dispatch_block_t block=^(){
        [__weakSelf updateMotorState];
        [__weakSelf updateMotor];
        [__weakSelf updateLight];
        [__weakSelf updateUv];
        [__weakSelf updateAirDry];
        [__weakSelf updateBaking];
        [__weakSelf updateLoudspeaker];
        [__weakSelf updateChildLock];
        [__weakSelf.collectionView reloadData];
        
    };
    dispatch_main_async_safe(block);
    
}


/**
 * 更新晾衣机马达运动动画
 */
- (void)updateMotor {
    
    HangerMotorStatus status = [self integratedStatusFromHanger:self.lock.hangerModel];
    switch (status) {
    
        case HangerMotorStatusLower:{
            if (self.ivMotor.isAnimating) {
                [self.ivMotor stopAnimating];
            }
            self.ivMotor.animationImages = @[[UIImage imageNamed:@"hanger_motor_1"], [UIImage imageNamed:@"hanger_motor_2"], [UIImage imageNamed:@"hanger_motor_3"], [UIImage imageNamed:@"hanger_motor_4"], [UIImage imageNamed:@"hanger_motor_5"]];
            self.ivMotor.animationDuration = 2.0;
            [self.ivMotor startAnimating];
        }
            break;
        case HangerMotorStatusUpper:{
            if (self.ivMotor.isAnimating) {
                [self.ivMotor stopAnimating];
            }
            self.ivMotor.animationImages = @[[UIImage imageNamed:@"hanger_motor_5"], [UIImage imageNamed:@"hanger_motor_4"], [UIImage imageNamed:@"hanger_motor_3"], [UIImage imageNamed:@"hanger_motor_2"], [UIImage imageNamed:@"hanger_motor_1"]];
            self.ivMotor.animationDuration = 2.0;
            [self.ivMotor startAnimating];
        }
            break;
        default: {
            if(self.ivMotor.isAnimating) {
                [self.ivMotor stopAnimating];
                self.ivMotor.animationImages = nil;
            }
            
            self.ivMotor.image = [UIImage imageNamed:@"hanger_motor_5"];
        }
            break;
    }
}
/**
 *  更新童锁
 */
-(void) updateChildLock {
    KDSFuntionTabModel *tabModel = self.dataSource[5];
    if(self.lock.hangerModel.childLock) {
        tabModel.imageName = @"home_icon_switch_open";
    }else {
        tabModel.imageName = @"home_icon_switch_shut";
    }
}
/**
 * 更新语音开锁
 */
-(void) updateLoudspeaker {
    KDSFuntionTabModel *tabModel = self.dataSource[4];
    if(self.lock.hangerModel.loudspeaker) {
        tabModel.imageName = @"home_icon_switch_open";
    }else {
        tabModel.imageName = @"home_icon_switch_shut";
    }
}
/**
 * 更新烘干
 */
-(void) updateBaking {
    KDSFuntionTabModel *tabModel = self.dataSource[3];
    tabModel.countdown = self.lock.hangerModel.baking.countdown;
    if(self.lock.hangerModel.baking.switchField) {
        tabModel.imageName = @"home_icon_dry_selected";
    }else {
        tabModel.imageName = @"home_icon_dry";
    }
}
/**
 * 更新风干
 */
-(void) updateAirDry {
    KDSFuntionTabModel *tabModel = self.dataSource[2];
    tabModel.countdown = self.lock.hangerModel.airDry.countdown;
    if(self.lock.hangerModel.airDry.switchField) {
        tabModel.imageName = @"home_icon_airdry_selected";
    }else {
        tabModel.imageName = @"home_icon_airdry";
    }
}

/**
 * 更新消毒
 */
-(void) updateUv {
    KDSFuntionTabModel *tabModel = self.dataSource[1];
    tabModel.countdown = self.lock.hangerModel.uV.countdown;
    if(self.lock.hangerModel.uV.switchField) {
        tabModel.imageName = @"home_icon_disinfect_selected";
    }else {
        tabModel.imageName = @"home_icon_disinfect";
    }
}
/**
 * 更新照明
 */
-(void) updateLight {
    KDSFuntionTabModel *tabModel = self.dataSource[0];
    tabModel.countdown = self.lock.hangerModel.light.countdown;
    if(self.lock.hangerModel.light.switchField) {
        tabModel.imageName = @"home_icon_lighting_selected";
    }else {
        tabModel.imageName = @"home_icon_lighting";
    }
}


/**
 * 显示状态对应文字
 */
-(void) updateMotorState {
    
    NSString *text;

    
    //0x00:正常 0x01:到达上限位 0x02:到达下限位 0x03:遇阻
    NSDictionary *statusText =@{@(HangerMotorStatusNormal): NSLocalizedString(@"衣杆正常", nil),
                                @(HangerMotorStatusUpperLimit): NSLocalizedString(@"已到顶端", nil),
                                @(HangerMotorStatusLowerLimit): NSLocalizedString(@"已到底端", nil),
                                @(HangerMotorStatusBlocked): NSLocalizedString(@"衣杆遇阻", nil),
                                @(HangerMotorStatusOverload): NSLocalizedString(@"衣杆过载", nil),
                                @(HangerMotorStatusUpper): NSLocalizedString(@"衣杆上升", nil),
                                @(HangerMotorStatusLower): NSLocalizedString(@"衣杆下降", nil),
                                @(HangerMotorStatusOffline): NSLocalizedString(@"晾衣机离线", nil)
                                
    };
    
    

    text = statusText[@([self integratedStatusFromHanger:self.lock.hangerModel])];
    if (!text) {
        text = NSLocalizedString(@"未知状态", nil);
    }
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:  [UIFont systemFontOfSize:17],NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.labMotorState.attributedText = attributedString;
    
}
#pragma mark - function

/**
 *  设备各种马达动作/状态/在线状态归一
 *  优先返回离线>显示过载>马达动作>晾衣机状态
 */
-(HangerMotorStatus) integratedStatusFromHanger:(KDSDeviceHangerModel *) hanger {
    HangerMotorStatus status = HangerMotorStatusNormal;
    
    if (hanger){
        
        if (hanger.overload) {
            status = HangerMotorStatusOverload;
        }else {
            //马达动作
            if (hanger.motor.action) {
                if (hanger.motor.action == HangerMotorUp) {
                    status = HangerMotorStatusUpper;
                    return status;

                }else {
                    status = HangerMotorStatusLower;
                    return status;

                }
            }
            
            switch (hanger.motor.status) {
                case 0:
                    status = HangerMotorStatusNormal;
                    break;
                case 1:
                    status = HangerMotorStatusUpperLimit;
                    break;
                case 2:
                    status = HangerMotorStatusLowerLimit;
                    break;
                case 3:
                    status = HangerMotorStatusBlocked;
                    break;
                default:
                    break;
            }
            
        }
    }
    return status;
    
}

#pragma mark - 马达动作
- (void) motorAction:(UIButton *) sender {
    switch (sender.tag) {
        case 101:
            //pause
            [[KDSMQTTManager sharedManager] hanger:self.lock.hangerModel motorAction:HangerMotorPause completion:nil];
            break;
        case 102:
            //up
            [[KDSMQTTManager sharedManager] hanger:self.lock.hangerModel motorAction:HangerMotorUp completion:nil];
            break;
        case 103:
            [[KDSMQTTManager sharedManager] hanger:self.lock.hangerModel motorAction:HangerMotorDown completion:nil];
            break;
        default:
            break;
    }
}

#pragma mark   UICollectionView 代理的实现
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KDSFuntionTabListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TTQVideoListCell" forIndexPath:indexPath];
    KDSFuntionTabModel *data = self.dataSource[indexPath.item];
    [cell setupData:data];
    cell.selectedBackgroundView = [UIView new];
    cell.selectedBackgroundView.backgroundColor = [UIColor whiteColor];
    return cell;
}
// 返回cell的间距
// 3.这个是两行cell之间的最小间距（上下行cell的间距）
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 30;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
  
    switch (indexPath.row) {
        case 0:
        {
            KDSLog(@"setlight");
            if(self.lock.hangerModel.light.switchField == HangerSwitchOFF) {
                [[KDSMQTTManager sharedManager] hanger:self.lock.hangerModel light:HangerSwitchON completion:nil];
            }else {
                [[KDSMQTTManager sharedManager] hanger:self.lock.hangerModel light:HangerSwitchOFF completion:nil];
            }
        }
            break;
        case 1:
        {
            if(self.lock.hangerModel.uV.switchField == HangerSwitchOFF) {
                [[KDSMQTTManager sharedManager] hanger:self.lock.hangerModel uv:HangerSwitchON completion:nil];
            }else {
                [[KDSMQTTManager sharedManager] hanger:self.lock.hangerModel uv:HangerSwitchOFF completion:nil];
            }
        }
            break;
        case 2: {
            if(self.lock.hangerModel.airDry.switchField == HangerAirDryOFF) {
                ESWeakSelf
                KDSHangerTimerView *timerView = [KDSHangerTimerView alertView];
                [timerView updateTitle: NSLocalizedString(@"请选择风干时间", nil)];
                [timerView.btn120Minute setTitle:NSLocalizedString(@"120min", nil) forState:UIControlStateNormal];
                [timerView.btn240Minute setTitle:NSLocalizedString(@"240min", nil) forState:UIControlStateNormal];
                timerView.blockResult = ^(HangerTimerChoose timerChoose) {
                    HangerAirDry airDry;
                    switch (timerChoose) {
                        case HangerTimerNone:
                            airDry = HangerAirDryOFF;
                            break;
                        case HangerTimer120:
                            airDry = HangerAirDry120;
                            break;
                        case HangerTimer240:
                            airDry = HangerAirDry240;
                            break;
                        default:
                            break;
                    }
                    if (airDry != HangerAirDryOFF) {
                        [[KDSMQTTManager sharedManager] hanger:__weakSelf.lock.hangerModel airDry:airDry completion:nil];
                    }
                };
                [timerView show];
            }else {
                [[KDSMQTTManager sharedManager] hanger:self.lock.hangerModel airDry:HangerAirDryOFF completion:nil];
            }
        }
            break;
        case 3: {
            if(self.lock.hangerModel.baking.switchField == HangerBakingOFF) {
                ESWeakSelf
                KDSHangerTimerView *timerView = [KDSHangerTimerView alertView];
                [timerView updateTitle: NSLocalizedString(@"请选择烘干时间", nil)];
                [timerView.btn120Minute setTitle:NSLocalizedString(@"120min", nil) forState:UIControlStateNormal];
                [timerView.btn240Minute setTitle:NSLocalizedString(@"240min", nil) forState:UIControlStateNormal];
                timerView.blockResult = ^(HangerTimerChoose timerChoose) {
                    HangerBaking baking;
                    switch (timerChoose) {
                        case HangerTimerNone:
                            baking = HangerBakingOFF;
                            break;
                        case HangerTimer120:
                            baking = HangerBaking120;
                            break;
                        case HangerTimer240:
                            baking = HangerBaking240;
                            break;
                        default:
                            break;
                    }
                    if (baking != HangerBakingOFF) {
                        [[KDSMQTTManager sharedManager] hanger:__weakSelf.lock.hangerModel baking:baking completion:nil];
                    }
                };
                [timerView show];
            }else {
                [[KDSMQTTManager sharedManager] hanger:self.lock.hangerModel baking:HangerBakingOFF completion:nil];
            }
        }
            break;
        case 4: {
            if(self.lock.hangerModel.loudspeaker == HangerSwitchOFF) {
                [[KDSMQTTManager sharedManager] hanger:self.lock.hangerModel loudspeaker:HangerSwitchON completion:nil];
            }else {
                [[KDSMQTTManager sharedManager] hanger:self.lock.hangerModel loudspeaker:HangerSwitchOFF completion:nil];
            }
        }
            break;
        case 5: {
            
            if(self.lock.hangerModel.childLock == HangerSwitchOFF) {
                [[KDSMQTTManager sharedManager] hanger:self.lock.hangerModel childLock:HangerSwitchON completion:nil];
            }else {
                [[KDSMQTTManager sharedManager] hanger:self.lock.hangerModel childLock:HangerSwitchOFF completion:nil];
            }
            
        }
            break;
        default:
            break;
    }
    
}





// 初始化数据
-  (NSMutableArray *)dataSource{
    if (!_dataSource) {
        self.dataSource  = [NSMutableArray array];
        KDSFuntionTabModel *data = [KDSFuntionTabModel new];
        data.imageName = @"home_icon_lighting";
        data.funtabtitle = NSLocalizedString(@"照明", nil);
        KDSFuntionTabModel *data2 = [KDSFuntionTabModel new];
        data2.imageName = @"home_icon_disinfect";
        data2.funtabtitle = NSLocalizedString(@"消毒", nil);
        KDSFuntionTabModel *data3 = [KDSFuntionTabModel new];
        data3.imageName = @"home_icon_airdry";
        data3.funtabtitle = NSLocalizedString(@"风干", nil);
        KDSFuntionTabModel *data4 = [KDSFuntionTabModel new];
        data4.imageName = @"home_icon_dry";
        data4.funtabtitle = NSLocalizedString(@"烘干", nil);
        KDSFuntionTabModel *data5 = [KDSFuntionTabModel new];
        data5.imageName = @"home_icon_switch_shut";
        data5.funtabtitle = NSLocalizedString(@"语音", nil);
        KDSFuntionTabModel *data6 = [KDSFuntionTabModel new];
        data6.imageName = @"home_icon_switch_open";
        data6.funtabtitle = NSLocalizedString(@"童锁", nil);
        _dataSource = [@[data,data2,data3,data4,data5,data6] mutableCopy];
        

    }
    return _dataSource;
}

//  控件懒加载
- (UICollectionView *)collectionView{
    if (_collectionView ==nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat itemW = (kScreenWidth - 120) / 3;
        CGFloat itemH = 90;
        layout.itemSize = CGSizeMake(itemW, itemH);
        layout.sectionInset = UIEdgeInsetsMake(40, 40, 40, 40);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumLineSpacing = 20;
        layout.minimumInteritemSpacing = 10;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor =KDSRGBColor(242, 242, 242);
        [_collectionView registerClass:[KDSFuntionTabListCell class] forCellWithReuseIdentifier:@"TTQVideoListCell"];
        _collectionView.scrollEnabled = YES;
    }
    return _collectionView;
}


#pragma mark - Notification

//收到更改了本地语言的通知，更新页面文字。
- (void)localeLanguageDidChange:(NSNotification *)noti {
   
}
///mqtt上报事件通知。#@#@########
- (void)wifimqttEventNotification:(NSNotification *)noti {
    
    
    
    MQTTSubEvent event = noti.userInfo[MQTTEventKey];
    NSDictionary *param = noti.userInfo[MQTTEventParamKey];
    //KDSLog(@"wifimqttEventNotification %@ %@",event, param);
    
    // 事件：信息上报/ota/绑定
    KDSDeviceHangerState *hangerState = [[KDSDeviceHangerState alloc] initWithDictionary:param];
    if ([self.lock.hangerModel.wifiSN isEqualToString:hangerState.wfId]) {
        if([event isEqualToString:MQTTSubEventHangerState]) {
            //更新UI
            [self updateUI];
        }
    }
    
    
}

-(CGFloat) statusBarHeight {
    CGFloat height;
    if (@available(iOS 13.0, *)) {
        if ([UIApplication sharedApplication].keyWindow.windowScene.statusBarManager.statusBarFrame.size.height) {
            height = [UIApplication sharedApplication].keyWindow.windowScene.statusBarManager.statusBarFrame.size.height;
        }else {
            height = [UIApplication sharedApplication].statusBarFrame
            .size.height;
        }
    } else {
        height = [UIApplication sharedApplication].statusBarFrame
        .size.height;
    }
    return  height;
}
@end
