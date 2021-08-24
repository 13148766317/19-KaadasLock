//
//  KDSMediaLockParamVC.m
//  KaadasLock
//
//  Created by zhaoxueping on 2020/9/17.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSMediaLockParamVC.h"
#import "MBProgressHUD+MJ.h"
#import "KDSLockMoreSettingCell.h"
#import "KDSAllPhotoShowImgModel.h"
#import "KDSDoorLockVersionVC.h"
#import "KDSCameraVersionVC.h"
#import "KDSHttpManager+VideoWifiLock.h"

#import <XMStreamComCtrl/XMStreamComCtrl.h>

#import "XMP2PManager.h"
#import "XMUtil.h"


@interface KDSMediaLockParamVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,strong) NSArray *titles;

@property(nonatomic, assign) BOOL isFaceRecognition;
@property(nonatomic, strong) NSDictionary *upgradeTask;

@end

@implementation KDSMediaLockParamVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = Localized(@"deviceInfo");
    self.tableView.rowHeight = 60;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.isFaceRecognition = [KDSLockFunctionSet[self.lock.wifiLockFunctionSet] containsObject:@26];

    if (self.isFaceRecognition) {
        self.titles = @[@"设备型号",@"序列号",@"门锁版本",@"摄像头版本",@"人脸模组版本"];
    }else {
        self.titles = @[@"设备型号",@"序列号",@"门锁版本",@"摄像头版本"];
    }
    
    

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
    NSString * product;
    if ([self.lock.wifiDevice.productModel isEqualToString:@"K13"]) {
        product= @"兰博基尼传奇";
    }else{
        product = self.lock.wifiDevice.productModel;
        for (NSString * productModel in [[KDSAllPhotoShowImgModel shareModel].productModel allKeys]) {
            if ([productModel isEqualToString:self.lock.wifiDevice.productModel]) {
                product = [[KDSAllPhotoShowImgModel shareModel].productModel objectForKey:self.lock.wifiDevice.productModel];
                break;
            }
        }
    }
    cell.title = self.titles[indexPath.row];
    cell.hideSeparator = indexPath.row == self.titles.count - 1;
    cell.clipsToBounds = YES;
    cell.hideArrow = YES;
    cell.hideSwitch = YES;
    if (indexPath.row == 0) {
        cell.subtitle = product;
    }else if (indexPath.row ==1){
        cell.subtitle = self.lock.wifiDevice.wifiSN;
    }else if (indexPath.row == 4) {
        
        if([cell.title isEqualToString:@"人脸模组版本"]) {
            //todo
            cell.subtitle = self.lock.wifiDevice.faceVersion;
            cell.hideArrow = NO;
        }
        
    }else{
        if (indexPath.row == 2 || indexPath.row == 3) {
            cell.hideArrow = NO;
        }else{
            cell.hideArrow = YES;
        }
    }
     
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) {
        //门锁版本
        KDSDoorLockVersionVC * vc = [KDSDoorLockVersionVC new];
        vc.lock = self.lock;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 3){
        //摄像头版本
        KDSCameraVersionVC * vc = [KDSCameraVersionVC new];
        vc.lock = self.lock;
        [self.navigationController pushViewController:vc animated:YES];
    }else if(indexPath.row == 4) {
        //检查升级
        [self checkUpdate];
    }
}
/**
 * 检查更新
 */
-(void) checkUpdate {
    //显示加载
    //提示：如果有升级，弹窗提示是否升级；否则提示已经是新版
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ESWeakSelf
    
    [[KDSHttpManager sharedManager] checkXMWiFiOTAWithSerialNumber:self.lock.wifiDevice.wifiSN withCustomer:1 withVersion:self.lock.wifiDevice.faceVersion  withDevNum:3 success:^(id  _Nullable responseObject) {

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
       
        
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            __weakSelf.upgradeTask = [[NSDictionary alloc] initWithDictionary:responseObject];
            [hud hideAnimated:NO];
            [__weakSelf  confirmUpgrade];
        }else {
            KDSLog(@"%@",responseObject);
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
    UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"检测到有新版本，是否升级？", nil) message:nil  preferredStyle:UIAlertControllerStyleAlert];
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

-(void) hideMBProgressHUD {
    
    ESWeakSelf
    dispatch_block_t block =^() {
        MBProgressHUD *hud = [MBProgressHUD HUDForView:__weakSelf.view];
        if (hud) {
            [hud hideAnimated:NO];
        }
    };
    dispatch_main_async_safe(block);
}
-(void) showMBProgressHUD {

    ESWeakSelf
    dispatch_block_t block =^() {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:__weakSelf.view animated:YES];
    };
    dispatch_main_async_safe(block);
}
/*
 * 升级设备
 */
-(void) upgradeDevice {
    //发送升级指令
    //显示执行结果
    
    [self showMBProgressHUD];
    ESWeakSelf
    [XMP2PManager sharedXMP2PManager].model = self.lock.wifiDevice;
    [[XMP2PManager sharedXMP2PManager] connectDevice];
    [XMP2PManager sharedXMP2PManager].XMP2PConnectDevStateBlock = ^(NSInteger resultCode) {
        if (resultCode > 0) {
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [__weakSelf hideMBProgressHUD];
                NSString *message = [NSString stringWithFormat:@"无法连接到设备，原因是：%@", [XMUtil checkPPCSErrorStringWithRet:resultCode]];
                UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [self.navigationController popViewControllerAnimated:true];
                }];
                UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"重试" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [XMP2PManager sharedXMP2PManager].model = self.lock.wifiDevice;
                    [[XMP2PManager sharedXMP2PManager] connectDevice];
                    [__weakSelf showMBProgressHUD];
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
        [__weakSelf hideMBProgressHUD];
        NSString *message = [NSString stringWithFormat:@"连接服务器超时，稍后再试"];
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:true];
        }];
        UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"重新连接" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [XMP2PManager sharedXMP2PManager].model = self.lock.wifiDevice;
            [[XMP2PManager sharedXMP2PManager] connectDevice];
            [__weakSelf showMBProgressHUD];
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
            //[self.indicatorView stopAnimating];
            [__weakSelf hideMBProgressHUD];
            [MBProgressHUD showError:@"升级失败"];
        }
    };
    [[XMP2PManager sharedXMP2PManager] setXMModuleUpgradeResponseBlock:^{
        ///收到通知模块升级的响应再去确认升级
        dispatch_async(dispatch_get_main_queue(), ^{
            [__weakSelf hideMBProgressHUD];
            [__weakSelf XMMediaWiFiLockOTA:__weakSelf.upgradeTask];
        });
        
    }];
    

    /*
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
    */
    
}

///确认升级
- (void)XMMediaWiFiLockOTA:(id  _Nullable)responseObject{
    
    KDSLog(@"--{Kaadas}--发送responseObject=%@",(NSDictionary *)responseObject);
    ESWeakSelf
    [[KDSHttpManager sharedManager] xmWifiDeviceOTAWithSerialNumber:self.lock.wifiDevice.wifiSN withOTAData:(NSDictionary *)responseObject success:^{
        KDSLog(@"--{Kaadas}--发送OTA成功");
        [[XMP2PManager sharedXMP2PManager] releaseLive];
        if([responseObject[@"devNum"] isEqualToNumber:@2])
        {
            [MBProgressHUD showSuccess:Localized(@"newWiFiLockImageOTA")];
        }else if([responseObject[@"devNum"] isEqualToNumber:@3]){
            UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:@"请唤醒门锁" message:@"请确保门锁有充足的电量\n人脸模组升级中，门锁面容识别不可用" preferredStyle:UIAlertControllerStyleAlert];
            [__weakSelf presentViewController:alerVC animated:YES completion:nil];
            [__weakSelf performSelector:@selector(dismiss:) withObject:alerVC afterDelay:5.0];
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
        [__weakSelf presentViewController:ac animated:YES completion:nil];
        
    } failure:^(NSError * _Nonnull error) {
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@""/*Localized(@"Lock OTA upgrade")*/ message:[NSString stringWithFormat:@"%@",error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [ac addAction:okAction];
        [__weakSelf presentViewController:ac animated:YES completion:nil];
    }];
}

- (void)dismiss:(UIAlertController *)alert{
    [alert dismissViewControllerAnimated:YES completion:nil];
}
@end
