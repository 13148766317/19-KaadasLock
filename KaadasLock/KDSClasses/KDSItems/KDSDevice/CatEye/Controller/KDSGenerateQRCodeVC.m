//
//  KDSGenerateQRCodeVC.m
//  KaadasLock
//
//  Created by wzr on 2019/6/17.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSGenerateQRCodeVC.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "MBProgressHUD+MJ.h"
#import "KDSFTIndicator.h"
#import "KDSCateyeHelpVC.h"
#import "KDSAddCatEye4VC.h"

@interface KDSGenerateQRCodeVC ()
@property (weak, nonatomic) IBOutlet UILabel *ssidLab;
@property (weak, nonatomic) IBOutlet UITextField *wifiPwdTxf;
@property (weak, nonatomic) IBOutlet UIImageView *imgeView;
///是否连接成功
@property(nonatomic,assign)BOOL isSuccess;
///猫眼的设备ID
@property (nonatomic,readwrite,strong)NSString * deviceId;
///添加的设备所在的网关
@property (nonatomic,readwrite,strong)GatewayModel * gatewayModel;
@end

@implementation KDSGenerateQRCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationTitleLabel.text =@"生成二维码";
    [self setRightButton];
    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    self.ssidLab.text = [self getDeviceSSID];
    NSLog(@"self.gwConfigPwd===%@",self.gwConfigPwd);
    NSLog(@"gwConfigWifiSsid==%@",self.gwConfigWifiSsid);
    [self generateQRCodeWithStr:[NSString stringWithFormat:@"ssid:\"%@\" password:\"%@\"",self.gwConfigWifiSsid,self.gwConfigPwd]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cateyeEventNotification:) name:KDSMQTTEventNotification object:nil];
    // Do any additional setup after loading the view from its nib.
}

- (void)generateQRCodeWithStr:(NSString *)mesStr{
         //创建过滤器
         CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
         //过滤器恢复默认
         [filter setDefaults];
    
         //给过滤器添加数据
         NSString *string = mesStr;
    
         //将NSString格式转化成NSData格式
         NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
         [filter setValue:data forKeyPath:@"inputMessage"];
    
         //获取二维码过滤器生成的二维码
         CIImage *image = [filter outputImage];
    
         //将获取到的二维码添加到imageview上
         self.imgeView.image =[self createNonInterpolatedUIImageFormCIImage:image withSize:180];
}
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
        CGRect extent = CGRectIntegral(image.extent);
        CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
         // 1.创建bitmap;
         size_t width = CGRectGetWidth(extent) * scale;
         size_t height = CGRectGetHeight(extent) * scale;
         CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
         CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
         CIContext *context = [CIContext contextWithOptions:nil];
         CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
         CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
         CGContextScaleCTM(bitmapRef, scale, scale);
         CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
         // 2.保存bitmap到图片
         CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
         CGContextRelease(bitmapRef);
         CGImageRelease(bitmapImage);
         return [UIImage imageWithCGImage:scaledImage];
}
- (NSString *) getDeviceSSID {
    NSArray *ifs = (__bridge id)CNCopySupportedInterfaces();
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info && [info count]) { break;
        }
    }
    NSDictionary *dctySSID = (NSDictionary *)info;
    NSString *ssid = [dctySSID objectForKey:@"SSID"]; return ssid;
    
}
//主线程返回界面
-(void)refreshUI{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isSuccess) {
            [MBProgressHUD showSuccess:Localized(@"Cat'sEyeAccessSuccessfully")];
        }else{
            [MBProgressHUD showError:Localized(@"CatEyeFailure")];
        }
        KDSAddCatEye4VC * addCateye = [KDSAddCatEye4VC new];
        addCateye.isSuccess = self.isSuccess;
        addCateye.gatewayModel = self.gatewayModel;
        addCateye.deviceId = self.deviceId;
        [self.navigationController pushViewController:addCateye animated:YES];
    });
}
#pragma mark - 通知相关方法。
///mqtt上报事件通知。
- (void)cateyeEventNotification:(NSNotification *)noti
{
    MQTTSubEvent event = noti.userInfo[MQTTEventKey];
    NSDictionary *param = noti.userInfo[MQTTEventParamKey];
//    GatewayDeviceModel * gwDeviceModel = param[@"device"];
    NSString * deviceId = param[@"deviceId"];
    NSString * gwId = param[@"gwId"];
    
    for (KDSCatEye * cateye  in [KDSUserManager sharedManager].cateyes) {
        if ([param[@"uuid"] isEqual:cateye]) {
            return;
        }
    }
    if ([event isEqualToString:MQTTSubEventDeviceOnline]){
        GatewayModel * gwModel = [GatewayModel new];
        gwModel.deviceSN = gwId;
        self.gatewayModel = gwModel;
        self.deviceId = deviceId;
        self.isSuccess = YES;
        [KDSFTIndicator showNotificationWithTitle:Localized(@"Be careful") message:[NSString stringWithFormat:@"%@%@",deviceId,Localized(@"cateyeOnline")] tapHandler:^{
        }];
        [self refreshUI];
    }
}

-(void)navRightClick
{
    KDSCateyeHelpVC * vc = [KDSCateyeHelpVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
