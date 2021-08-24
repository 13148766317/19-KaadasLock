//
//  KDSCameraVersionVC.m
//  KaadasLock
//
//  Created by zhaoxueping on 2020/9/17.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSCameraVersionVC.h"
#import "KDSLockMoreSettingCell.h"
#import <XMStreamComCtrl/XMStreamComCtrl.h>
#import "KDSHttpManager+VideoWifiLock.h"
#import "XMP2PManager.h"
#import "XMUtil.h"

@interface KDSCameraVersionVC ()<UITableViewDataSource, UITableViewDelegate,StreamDelegate>

@property (nonatomic,strong) NSArray *titles;
/// 菊花loading
@property (nonatomic, strong)UIActivityIndicatorView *indicatorView;

@end

@implementation KDSCameraVersionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = @"摄像头版本";
    self.tableView.rowHeight = 60;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
//    self.titles = @[@"序列号",@"视频模组版本",@"视频模组微控制器版本",@"WiFi固件版本",@"硬件版本"];
    self.titles = @[@"序列号",@"视频模组版本",@"视频模组微控制器版本",@"WiFi固件版本"];
    [self.view addSubview:self.indicatorView];
    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
    }];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = NSStringFromClass([self class]);
    KDSLockMoreSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell)
    {
        cell = [[KDSLockMoreSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    NSArray * detailTitles = @[self.lock.wifiDevice.device_sn ?: @"",self.lock.wifiDevice.camera_version ?: @"",self.lock.wifiDevice.mcu_version ?: @"",self.lock.wifiDevice.wifiVersion ?: @"",self.lock.wifiDevice.device_model ?: @""];
    cell.title = self.titles[indexPath.row];
    cell.subtitle = detailTitles[indexPath.row];
    cell.hideSeparator = indexPath.row == self.titles.count - 1;
    cell.clipsToBounds = YES;
    cell.hideSwitch = YES;
    
    if (self.lock.device.is_admin.intValue ==1 || self.lock.wifiDevice.isAdmin.intValue == 1 ) {
        if (indexPath.row == 0) {
            cell.hideArrow = YES;
        }else{
            cell.hideArrow = NO;
        }
    }else{
        cell.hideArrow = YES;
    }
    
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //升级编号。1为WIFI模块，2为WIFI锁，3为人脸模组，4为视频模组，5为视频模组微控制器
    if (indexPath.row == 1) {
        ///视频模组版本
        NSLog(@"zhushiqi -- 输出用户的管理账户==%d",self.lock.device.is_admin.intValue);
        if (self.lock.device.is_admin.intValue ==1 || self.lock.wifiDevice.isAdmin.intValue == 1) {
            [self checkXmWiFiLockOTA:self.lock.wifiDevice.camera_version withDevNum:4];
        }
    }else if (indexPath.row == 2){
        ///视频模组微控制器版本
   
        if (self.lock.device.is_admin.intValue == 1 || self.lock.wifiDevice.isAdmin.intValue == 1) {
            [self checkXmWiFiLockOTA:self.lock.wifiDevice.mcu_version withDevNum:5];
        }
    }else if (indexPath.row == 3){
        ///WiFi固件版本
        if (self.lock.device.is_admin.intValue ==  1 || self.lock.wifiDevice.isAdmin.intValue == 1) {
            [self checkXmWiFiLockOTA:self.lock.wifiDevice.wifiVersion withDevNum:1];
        }
       
    }
}
///检查wifi锁/模块是否需要升级
- (void)checkXmWiFiLockOTA:(NSString *)content withDevNum:(int)devNum{
    NSLog(@"--{Kaadas}--检查OTA的softwareRev:%@",content);
    NSLog(@"--{Kaadas}--检查OTA的deviceSN:%@",self.lock.wifiDevice.wifiSN);
    [[KDSHttpManager sharedManager] checkXMWiFiOTAWithSerialNumber:self.lock.wifiDevice.wifiSN withCustomer:1 withVersion:content withDevNum:devNum success:^(id  _Nullable responseObject) {
        NSString *message ;
        
        if([responseObject[@"devNum"] isEqualToNumber:@2]){
            message = [NSString stringWithFormat:@"%@%@,%@",Localized(@"newWiFiLockImage"),responseObject[@"fileVersion"],Localized(@"WhetherToUpgrade")];
        }else if ([responseObject[@"devNum"] isEqualToNumber:@3]){
            message = [NSString stringWithFormat:@"%@%@,%@",@"检测到人脸模组版本",responseObject[@"fileVersion"],Localized(@"WhetherToUpgrade")];
        }else if ([responseObject[@"devNum"] isEqualToNumber:@4]){
            message = [NSString stringWithFormat:@"%@%@,%@",@"检测到视频模组",responseObject[@"fileVersion"],Localized(@"WhetherToUpgrade")];
        }else if ([responseObject[@"devNum"] isEqualToNumber:@5]){
            message = [NSString stringWithFormat:@"%@%@,%@",@"检测到视频模组微控制器",responseObject[@"fileVersion"],Localized(@"WhetherToUpgrade")];
        }else{
            message = [NSString stringWithFormat:@"%@%@,%@",Localized(@"newWiFiModuleImage"),responseObject[@"fileVersion"],Localized(@"WhetherToUpgrade")];
        }
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@""/*Localized(@"tips")*/ message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"--讯美XXXXX{Kaadas}--responseObject==%@",responseObject);
            
            [self.indicatorView startAnimating];
            [XMP2PManager sharedXMP2PManager].model = self.lock.wifiDevice;
            [[XMP2PManager sharedXMP2PManager] connectDevice];
            [XMP2PManager sharedXMP2PManager].XMP2PConnectDevStateBlock = ^(NSInteger resultCode) {
                if (resultCode > 0) {
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.indicatorView stopAnimating];
                        NSString *message = [NSString stringWithFormat:@"无法连接到设备，原因是：%@", [XMUtil checkPPCSErrorStringWithRet:resultCode]];
                        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                            [self.navigationController popViewControllerAnimated:true];
                        }];
                        UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"重试" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [XMP2PManager sharedXMP2PManager].model = self.lock.wifiDevice;
                            [[XMP2PManager sharedXMP2PManager] connectDevice];
                            [self.indicatorView startAnimating];
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
                [self.indicatorView stopAnimating];
                NSString *message = [NSString stringWithFormat:@"连接服务器超时，稍后再试"];
                UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [self.navigationController popViewControllerAnimated:true];
                }];
                UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"重新连接" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [XMP2PManager sharedXMP2PManager].model = self.lock.wifiDevice;
                    [[XMP2PManager sharedXMP2PManager] connectDevice];
                    [self.indicatorView startAnimating];
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
//                        [self.indicatorView stopAnimating];
                        NSLog(@"MQTT 登录成功");
                        [[XMP2PManager sharedXMP2PManager].streamManager NotifyGateWayNewVersionWithChannel:0];
                    });
                }else{
                    [self.indicatorView stopAnimating];
                    [MBProgressHUD showError:@"升级失败"];
                }
            };
            [[XMP2PManager sharedXMP2PManager] setXMModuleUpgradeResponseBlock:^{
                ///收到通知模块升级的响应再去确认升级
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.indicatorView stopAnimating];
                    [self XMMediaWiFiLockOTA:responseObject];
                });
                
            }];
            
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [cancelAction setValue:UIColor.blackColor forKey:@"titleTextColor"];
        [ac addAction:cancelAction];
        [ac addAction:okAction];
        [self presentViewController:ac animated:YES completion:nil];
        
    } error:^(NSError * _Nonnull error) {
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@""/*Localized(@"Lock OTA upgrade")*/ message:[NSString stringWithFormat:@"%@",error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [ac addAction:okAction];
        [self presentViewController:ac animated:YES completion:nil];
        
    } failure:^(NSError * _Nonnull error) {
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@""/*Localized(@"Lock OTA upgrade")*/ message:[NSString stringWithFormat:@"%@",error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [ac addAction:okAction];
        [self presentViewController:ac animated:YES completion:nil];
    }];
    
}

///确认升级
- (void)XMMediaWiFiLockOTA:(id  _Nullable)responseObject{
    
    NSLog(@"--{Kaadas}--发送responseObject=%@",(NSDictionary *)responseObject);
    
    [[KDSHttpManager sharedManager] xmWifiDeviceOTAWithSerialNumber:self.lock.wifiDevice.wifiSN withOTAData:(NSDictionary *)responseObject success:^{
        NSLog(@"--{Kaadas}--发送OTA成功");
        [[XMP2PManager sharedXMP2PManager] releaseLive];
        if([responseObject[@"devNum"] isEqualToNumber:@2])
        {
            [MBProgressHUD showSuccess:Localized(@"newWiFiLockImageOTA")];
        }else if([responseObject[@"devNum"] isEqualToNumber:@3]){
            UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:@"请唤醒门锁" message:@"请确保门锁有充足的电量\n人脸模组升级中，门锁面容识别不可用" preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alerVC animated:YES completion:nil];
            [self performSelector:@selector(dismiss:) withObject:alerVC afterDelay:5.0];
        }else if([responseObject[@"devNum"] isEqualToNumber:@4]){
            //注意观察WiFi锁升级
            [MBProgressHUD showSuccess:@"注意观察视频模组升级"];
        }else if([responseObject[@"devNum"] isEqualToNumber:@4]){
            //注意观察WiFi锁升级
            [MBProgressHUD showSuccess:@"注意观察视视频模组微控制器升级"];
        }else{
            [MBProgressHUD showSuccess:Localized(@"newWiFiModuleImageOTA")];
        }
        
    } error:^(NSError * _Nonnull error) {
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle: @""/*Localized(@"Lock OTA upgrade")*/ message:[NSString stringWithFormat:@"%@",error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [ac addAction:okAction];
        [self presentViewController:ac animated:YES completion:nil];
        
    } failure:^(NSError * _Nonnull error) {
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@""/*Localized(@"Lock OTA upgrade")*/ message:[NSString stringWithFormat:@"%@",error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [ac addAction:okAction];
        [self presentViewController:ac animated:YES completion:nil];
    }];
}

- (void)dismiss:(UIAlertController *)alert{
    [alert dismissViewControllerAnimated:YES completion:nil];
}

- (UIActivityIndicatorView *)indicatorView {
    if (_indicatorView == nil) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _indicatorView;
}


@end
