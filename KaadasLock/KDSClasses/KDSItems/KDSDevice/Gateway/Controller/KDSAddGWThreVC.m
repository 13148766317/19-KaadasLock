//
//  KDSAddGWThreVC.m
//  KaadasLock
//
//  Created by wzr on 2019/3/29.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSAddGWThreVC.h"
#import "KDSBindingSuccVC.h"
#import "MBProgressHUD+MJ.h"
#import "KDSUserManager.h"
#import "KDSAddGWFourVC.h"
#import "KDSBingdingGWFailVC.h"
#import "KDSMQTT.h"
#import "KDSScanPreviousStepVC.h"



@interface KDSAddGWThreVC ()

///提示：正在连接kaadas网关wifi中...
@property (weak, nonatomic) IBOutlet UILabel *tipsLb;
@property (weak, nonatomic) IBOutlet UIButton *cancleClickBtn;


@end

@implementation KDSAddGWThreVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationTitleLabel.text = Localized(@"addWg");
   
    self.tipsLb.text = Localized(@"Connecting to Kaadas Gateway WiFi");
    [self.cancleClickBtn setTitle:Localized(@"cancleBingding") forState:UIControlStateNormal];
    
    [self setData];
    
}

-(void)setData{
    
    NSRange snRange;
    NSString * str;
    ///跳转到此界面证明已经拿到扫描结果，然后去绑定网关
    if (![self.dataStr containsString:@"GW"]) {
        [MBProgressHUD showError:@"非凯迪仕网关"];
        KDSBingdingGWFailVC * vc = [KDSBingdingGWFailVC new];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    snRange = [self.dataStr rangeOfString:@"SN-"];
    if (snRange.location != NSNotFound) {
        NSString *SN = [self.dataStr substringFromIndex:snRange.location];
        //取出完整的SN码
        str = [[SN substringFromIndex:3] substringToIndex:13];
    }
    //绑定网关
    
    [[KDSMQTTManager sharedManager] bindGateway:str completion:^(NSError * _Nullable error, BOOL success) {
        KDSLog(@"error:---%@,success:=======%d",error,success);
        if (success)
        {
            [MBProgressHUD showSuccess:Localized(@"bindDeviceSuccess")];
            KDSUserManager * userManager = [KDSUserManager sharedManager];
            GatewayModel * gwModel = [GatewayModel new];
            gwModel.deviceSN = str;
            gwModel.adminNickname = userManager.userNickname ?:userManager.user.name;
            KDSGW *gw = [KDSGW new];
            gw.model = gwModel;
            [userManager.gateways addObject:gw];
            KDSAddGWFourVC * vc = [KDSAddGWFourVC new];
            [self.navigationController pushViewController:vc animated:YES];
            
            return;
        }
        if (error.code == 812 ) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                KDSBingdingGWFailVC * vc = [KDSBingdingGWFailVC new];
                [self.navigationController pushViewController:vc animated:YES];
            });
        }else if (error.code == 813) {
            KDSLog(@"您已绑定该网关");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                KDSBingdingGWFailVC * vc = [KDSBingdingGWFailVC new];
                [self.navigationController pushViewController:vc animated:YES];
            });
        }else if (error.code == 414) {
            [MBProgressHUD showError:
             [NSString stringWithFormat:@"Code:%@,视频通道创建失败,请重新注册新账号",@"414"]
             ];//@"米米网"
            KDSBingdingGWFailVC * vc = [KDSBingdingGWFailVC new];
            [self.navigationController pushViewController:vc animated:YES];
        }else if (error.code == 946) {
            [MBProgressHUD showError:
             [NSString stringWithFormat:@"Code: %@,视频通道创建失败,请重新注册新账号",@"946"]
             ];
            KDSBingdingGWFailVC * vc = [KDSBingdingGWFailVC new];
            [self.navigationController pushViewController:vc animated:YES];
        }else if (error.code == 871) {
            [MBProgressHUD showError:@"Code: 871,服务器异常,请稍候再试"];
            KDSBingdingGWFailVC * vc = [KDSBingdingGWFailVC new];
            [self.navigationController pushViewController:vc animated:YES];
        }else if (error.code == 401) {
            [MBProgressHUD showError:@"Code: 401,数据参数不对"];
            KDSBingdingGWFailVC * vc = [KDSBingdingGWFailVC new];
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            KDSBingdingGWFailVC * vc = [KDSBingdingGWFailVC new];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
}
- (IBAction)cancelClick:(id)sender {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
