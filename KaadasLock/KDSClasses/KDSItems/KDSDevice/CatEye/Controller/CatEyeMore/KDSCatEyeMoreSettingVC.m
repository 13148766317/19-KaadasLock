//
//  KDSCatEyeMoreSettingVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/16.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSCatEyeMoreSettingVC.h"
#import "KDSCatEyeMoreSettingCellTableViewCell.h"
#import "KDSCateyeBaseinfoVC.h"
#import "KDSResolutionSettingsVC.h"
#import "KDSDoorbellSettingVC.h"
#import "KDSRingNumVC.h"
#import "KDSBellvolumeSettingVC.h"
#import "KDSIntelligentMonitoringVC.h"
#import "KDSMQTT.h"
//#import "MBProgressHUD+MJ.h"
#import "KDSDBManager+CY.h"
#import "CateyeSetModel.h"
#import <MJExtension/MJExtension.h>
#import "UIView+Extension.h"
#import "KDSNightVisionVC.h"

@interface KDSCatEyeMoreSettingVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,readwrite,strong)UITableView * tableView;
@property (nonatomic,readwrite,strong)NSMutableArray * dataSourceArr;
@property (nonatomic,readwrite,strong)KDSGWCateyeParam * cateyeModel;
@property (nonatomic,readwrite,strong)UIButton * deletBtn;
///是否支持夜视功能设置YES：支持，NO：不支持
@property (nonatomic,readwrite,assign)BOOL isNightVisionSupport;

@end

@implementation KDSCatEyeMoreSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = Localized(@"systemSetting");
    self.isNightVisionSupport = NO;
    [self setUI];
    ///缓存猫眼基本信息
    [self getBasicInfo];
    ///删除猫眼的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidDeltGateway:) name:KDSMQTTEventNotification object:nil];
   
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     self.navigationController.navigationBar.barTintColor = KDSRGBColor(242, 242, 242);
    ///获取猫眼基本信息
    self.cateyeModel = [[KDSDBManager sharedManager] getCateyeSettingWithDeviceid:self.cateye.gatewayDeviceModel.deviceId];
    [self.tableView reloadData];
}
-(void)setUI
{
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.deletBtn];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.view.mas_top).offset(0);
        make.height.mas_equalTo(self.dataSourceArr.count * 60);
        
    }];
    [self.deletBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-50);
    }];
    
}
#pragma mark MQtt协议
-(void)getBasicInfo{
    
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"pleaseWait") toView:self.view];
    [[KDSMQTTManager sharedManager] cyGetDeviceParams:self.cateye.gatewayDeviceModel completion:^(NSError * _Nullable error, KDSGWCateyeParam * _Nullable param) {
        [hud hideAnimated:YES];
        ///缓存猫眼的基础信息
        if (param) {
            _cateyeModel = [KDSGWCateyeParam mj_objectWithKeyValues:param];
            [[KDSDBManager sharedManager] updateCateye:param];
            [self.tableView reloadData];
        }else{
            
            [MBProgressHUD showError:Localized(@"PleaseTryAgain")];
        }
      
    }];
}

#pragma mark --UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KDSCatEyeMoreSettingCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KDSCatEyeMoreSettingCellTableViewCell.ID];
    
    cell.model = self.dataSourceArr[indexPath.row];
    if (indexPath.row == 1) {
        cell.rightArrowImg.hidden = YES;
    }
   
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:///设备名称
        {
           
            [self modifyNickName];
            
        }
            break;
        case 1: ///铃声选择
        {
            /*
            KDSDoorbellSettingVC * vc = [KDSDoorbellSettingVC new];
            vc.cateye = self.cateye;
            vc.cateyeParam = self.cateyeModel;
            vc.maxBellNuml = self.cateyeModel.maxBellNum;
            [self.navigationController pushViewController:vc animated:YES];
             */
        }
            break;
        case 2:///铃声音量
        {
            KDSBellvolumeSettingVC * vc = [KDSBellvolumeSettingVC new];
            vc.cateye = self.cateye;
            vc.cateyeParam = self.cateyeModel;
            [self.navigationController pushViewController:vc animated:YES];
            
        }
            break;
        case 3:///响铃次数
        {
            KDSRingNumVC * vc = [KDSRingNumVC new];
            vc.cateye = self.cateye;
            vc.cateyeParam = self.cateyeModel;
            [self.navigationController pushViewController:vc animated:YES];
            
        }
            break;
        case 4:///智能监测
        {
            KDSIntelligentMonitoringVC * vc = [KDSIntelligentMonitoringVC new];
            vc.cateye = self.cateye;
            vc.cateyeParam = self.cateyeModel;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 5:///视频分辨率
        {
            KDSResolutionSettingsVC * vc = [KDSResolutionSettingsVC new];
            vc.cateye = self.cateye;
            vc.cateyeParam = self.cateyeModel;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 6:///设备信息
        {
            KDSCateyeBaseinfoVC * vc = [KDSCateyeBaseinfoVC new];
            vc.cateye = self.cateye;
            vc.cateyeParam = self.cateyeModel;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 7://设置夜视功能
        {
            KDSNightVisionVC * vc = [KDSNightVisionVC new];
            vc.cateye = self.cateye;
            vc.cateyeParam = self.cateyeModel;
            self.definesPresentationContext = YES;
            vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            vc.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
            [self presentViewController:vc animated:YES completion:nil];
            
        }
            
        default:
            break;
    }
}

///密码昵称文本输入框，长度不能超过16
- (void)textFieldTextDidChange:(UITextField *)sender
{
    [sender trimTextToLength:-1];
}

///修改昵称
-(void)modifyNickName
{
    __weak typeof(self) weakSelf = self;
    UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:Localized(@"inputDeviceName") message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancle = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    //定义第一个输入框；
    [alerVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = Localized(@"inputDeviceName");
        textField.text = self.cateye.gatewayDeviceModel.nickName;
        textField.textAlignment = NSTextAlignmentLeft;
        textField.textColor = KDSRGBColor(199, 199, 204);
        textField.font = [UIFont systemFontOfSize:12];
        [textField addTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    }];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:Localized(@"sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *newNickname = alerVC.textFields.firstObject.text;
        if (newNickname.length>0 && ![newNickname isEqualToString:weakSelf.cateye.gatewayDeviceModel.nickName])
        {///昵称不为空，且不和原昵称一致
            self.cateye.gatewayDeviceModel.nickName = newNickname;
             MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"pleaseWait") toView:self.view];
            [[KDSMQTTManager sharedManager] updateDeviceNickname:self.cateye.gatewayDeviceModel completion:^(NSError * _Nullable error, BOOL success) {
                [hud hideAnimated:YES];
                if (success) {
                    [MBProgressHUD showSuccess:Localized(@"setSuccess")];
                }else{
                    [MBProgressHUD showError:Localized(@"setFailed")];
                }
                [self.tableView reloadData];
            }];
        }else if ([newNickname isEqualToString:weakSelf.cateye.gatewayDeviceModel.nickName]){
            [MBProgressHUD showSuccess:Localized(@"No changes were made")];
        }
        
    }];
    
    //修改按钮
    [cancle setValue:KDSRGBColor(51, 51, 51) forKey:@"titleTextColor"];
    
    [alerVC addAction:cancle];
    [alerVC addAction:ok];
    [self presentViewController:alerVC animated:YES completion:nil];
}

///删除猫眼
-(void)deletClick:(UIButton *)sender
{
    UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:Localized(@"ensureDeleteDevice") message:Localized(@"deviceDeleteAfter\nRestoreEquipmentfactorySettings") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancle = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:Localized(@"sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        ////删除猫眼设备
        MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"pleaseWait") toView:self.view];
        if (self.cateye.gw.model.isAdmin.integerValue == 2) {///授权的设备
            [[KDSMQTTManager sharedManager] shareGatewayBindingWithGW:self.cateye.gw.model device:self.cateye.gatewayDeviceModel userAccount:[KDSUserManager sharedManager].user.name userNickName:@"" shareFlag:0 type:2 completion:^(NSError * _Nullable error, BOOL success) {
                [hud hideAnimated:YES];
                if (success) {
                    [MBProgressHUD showSuccess:Localized(@"deleteSuccess")];
                    [[NSNotificationCenter defaultCenter] postNotificationName:KDSCatEyeHasBeenDeletedNotification object:nil userInfo:@{@"cateye" : self.cateye}];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }else{
                    [MBProgressHUD showError:Localized(@"deleteFailed")];
                }
            }];
        }else{
            [[KDSMQTTManager sharedManager] gw:self.gatewayModel deleteDevice:self.cateye.gatewayDeviceModel completion:^(NSError * _Nullable error, BOOL success) {
                ///删除成功以事件上报为准，不以事件响应为准。因为服务器未转发事件响应
                [hud hideAnimated:YES];
                if (success) {
                    
                    //                [hud hideAnimated:YES];
                    //                [MBProgressHUD showSuccess:Localized(@"deleteSuccess")];
                    //                [self.navigationController popToRootViewControllerAnimated:YES];
                }else{
                    //                [hud hideAnimated:YES];
                    //                [MBProgressHUD showError:Localized(@"deleteFailed")];
                    //                [self.navigationController popToRootViewControllerAnimated:YES];
                }
                
            }];
        }
    }];
    //修改按钮
    [cancle setValue:KDSRGBColor(51, 51, 51) forKey:@"titleTextColor"];
    
    //修改message
    NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:Localized(@"deviceDeleteAfter\nRestoreEquipmentfactorySettings")];
    [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:KDSRGBColor(153, 153, 153) range:NSMakeRange(0, alertControllerMessageStr.length)];
    [alertControllerMessageStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, alertControllerMessageStr.length)];
    [alerVC setValue:alertControllerMessageStr forKey:@"attributedMessage"];
    
    [alerVC addAction:cancle];
    [alerVC addAction:ok];
    [self presentViewController:alerVC animated:YES completion:nil];
  
}

#pragma mark -- lazy load
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = ({
            UITableView *tv = [[UITableView alloc] initWithFrame:CGRectZero];
            tv.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            tv.delegate = self;
            tv.dataSource = self;
            tv.scrollEnabled = NO;
            tv.rowHeight = 60;
            [tv registerClass:[KDSCatEyeMoreSettingCellTableViewCell class ] forCellReuseIdentifier:KDSCatEyeMoreSettingCellTableViewCell.ID];
            tv;
        });
    }
    return _tableView;
}

-(UIButton *)deletBtn
{
    if (!_deletBtn) {
        _deletBtn = ({
            UIButton * btn = [UIButton new];
            [btn setTitle:Localized(@"deleteDevice") forState:UIControlStateNormal];
            [btn setTitleColor:KDSRGBColor(255, 255, 255) forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
            btn.backgroundColor = KDSRGBColor(255, 59, 48);
            btn.layer.masksToBounds = YES;
            btn.layer.cornerRadius = 22;
            [btn addTarget:self action:@selector(deletClick:) forControlEvents:UIControlEventTouchUpInside];
            btn;
        });
    }
    return _deletBtn;
}

- (NSMutableArray *)dataSourceArr
{
    if (!_dataSourceArr) {
        _dataSourceArr = [NSMutableArray array];
    }else{
        [_dataSourceArr removeAllObjects];
    }
    
    CateyeSetModel * model1 = [CateyeSetModel setWithName:Localized(@"deviceName") andValue:self.cateye.gatewayDeviceModel.nickName];
    NSString *linshengStr = nil;
    CateyeSetModel *model2;
    if (_cateyeModel.curBellNum) {
        for (int i = 0; i<= _cateyeModel.curBellNum; i++) {
            linshengStr = [NSString stringWithFormat:@"%@%d",Localized(@"RingTone"),i+1];
        }
         model2= [CateyeSetModel setWithName:Localized(@"RingTone") andValue:linshengStr];
    }if (_cateyeModel.curBellNum ==0) {
        model2= [CateyeSetModel setWithName:Localized(@"RingTone") andValue:[NSString stringWithFormat:@"%@1",Localized(@"RingTone")]];
    }
    NSString * bellVolumeStr = nil;
    if (_cateyeModel.bellVolume == 0) {//高
        bellVolumeStr = Localized(@"high");
    }else if (_cateyeModel.bellVolume ==1){//中
        bellVolumeStr = Localized(@"middle");
    }else if (_cateyeModel.bellVolume ==2){//低
        bellVolumeStr = Localized(@"low");
    }else if (_cateyeModel.bellVolume == 3){//静音
        bellVolumeStr = Localized(@"Mute");
    }
    CateyeSetModel * model7 = [CateyeSetModel setWithName:Localized(@"ringer volume") andValue:bellVolumeStr];
    NSString *cishuStr = nil;
    if (_cateyeModel.bellCount) {
        for (int i = 0; i<= _cateyeModel.bellCount; i++) {
            cishuStr = [NSString stringWithFormat:@"%d%@",i,Localized(@"times")];
        }
    }
    CateyeSetModel *model3 = [CateyeSetModel setWithName:Localized(@"Ring number") andValue:cishuStr];
    
    CateyeSetModel * model4 = [CateyeSetModel setWithName:Localized(@"Intelligent monitoring") andValue:nil];
    
    NSString *resolutionStr = nil;
    if ([_cateyeModel.resolution isEqualToString:@"960x540"]) {
        resolutionStr = @"960x540";
    }else if ([_cateyeModel.resolution isEqualToString:@"1280x720"]){
        resolutionStr = @"1280x720";
    }
    CateyeSetModel *model5 = [CateyeSetModel setWithName:Localized(@"Video Resolution") andValue:resolutionStr];
    CateyeSetModel *model6 = [CateyeSetModel setWithName:Localized(@"deviceInfo") andValue:nil];
    //夜视功能
    CateyeSetModel * model8 = [CateyeSetModel setWithName:Localized(@"nightVision") andValue:nil];
    
    if (self.isNightVisionSupport) {
        [_dataSourceArr addObjectsFromArray:@[model1,model2,model7,model3,model4,model5,model6,model8]];
    }else{
       [_dataSourceArr addObjectsFromArray:@[model1,model2,model7,model3,model4,model5,model6]];
    }
    return _dataSourceArr;
}

#pragma mark - 通知。
///删除猫眼。
- (void)deviceDidDeltGateway:(NSNotification *)noti
{
    MQTTSubEvent event = noti.userInfo[MQTTEventKey];
    NSDictionary *param = noti.userInfo[MQTTEventParamKey];
    NSString * deviceId = param[@"deviceId"];
    if ([event isEqualToString:MQTTSubEventDevDel]) {
        if ([deviceId isEqualToString:self.cateye.gatewayDeviceModel.deviceId]) {
            [MBProgressHUD hideHUD];
            [[KDSUserManager sharedManager].cateyes removeObject:self.cateye];
            [[NSNotificationCenter defaultCenter] postNotificationName:KDSCatEyeHasBeenDeletedNotification object:nil userInfo:@{@"cateye" : self.cateye}];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
