//
//  KDSScanGatewayVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/11.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSScanGatewayVC.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h> //声音提示
#import "KDSAddGWThreVC.h"
#import "KDSProductActivationVC.h"
#import "MBProgressHUD+MJ.h"
#import "KDSBingdingGWFailVC.h"
#import "KDSAddCatEye3VC.h"



#define AUTH_ALERT_TAG (int)281821

@interface KDSScanGatewayVC ()<AVCaptureMetadataOutputObjectsDelegate,CAAnimationDelegate>
{
    AVCaptureSession * session;//输入输出的中间桥梁
    AVCaptureDeviceInput * input; //创建输入流
    AVCaptureMetadataOutput * output; //创建输出流
    AVCaptureVideoPreviewLayer * layer;//创建图层
    int line_tag;
    BOOL isResend;///是否重新扫码
}

@property (nonatomic,readwrite,strong)NSString *deviceMAC;
@property (nonatomic,readwrite,strong)NSString *deviceID;
@property (nonatomic,readwrite,strong)NSString *deviceSN;
@property (nonatomic,readwrite,strong)NSString * dataStr;
@end

@implementation KDSScanGatewayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([self.fromWhereVC isEqualToString:@"MineVC"]) {///产品激活
        self.navigationTitleLabel.text = Localized(@"Bar code");
    }else{
        ///猫眼、网关
      self.navigationTitleLabel.text = Localized(@"QR Code");
    }
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBar.barTintColor = UIColor.blackColor;
    self.navigationTitleLabel.textColor = UIColor.whiteColor;
    [self.backButton setImage:[UIImage imageNamed:@"whiteBack"] forState:UIControlStateNormal];
    isResend = NO;
    [self instanceDevice];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
}

- (void)appDidBecomeActive:(NSNotification *)noti
{
    [self instanceDevice];
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.barTintColor = UIColor.whiteColor;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (isResend) {
       [self instanceDevice];
    }

    self.navigationController.navigationBar.barTintColor = UIColor.blackColor;
}


/**
 *
 *  配置相机属性
 */
- (void)instanceDevice{
    
    line_tag = 1872637;
    if (!session)
    {
        //获取摄像设备
        AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        //创建输入流
        input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        //创建输出流
        output = [[AVCaptureMetadataOutput alloc]init];
        //设置代理 在主线程里刷新
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        //初始化链接对象
        session = [[AVCaptureSession alloc]init];
        //高质量采集率
        if ([session canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
            [session setSessionPreset:AVCaptureSessionPreset1920x1080];
        } else if ([session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
            [session setSessionPreset:AVCaptureSessionPreset1280x720];
        } else {
            [session setSessionPreset:AVCaptureSessionPresetHigh];
        }
//        [session setSessionPreset:AVCaptureSessionPresetHigh];
        if (input) {
            [session addInput:input];
        }
        if (output) {
            [session addOutput:output];
            //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
            NSMutableArray *a = [[NSMutableArray alloc] init];
            if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
                [a addObject:AVMetadataObjectTypeQRCode];
            }
            if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN13Code]) {
                [a addObject:AVMetadataObjectTypeEAN13Code];
            }
            if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN8Code]) {
                [a addObject:AVMetadataObjectTypeEAN8Code];
            }
            if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeCode128Code]) {
                [a addObject:AVMetadataObjectTypeCode128Code];
            }
            output.metadataObjectTypes=a;
        }
        layer = [AVCaptureVideoPreviewLayer layerWithSession:session];
        layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
        layer.frame=self.view.layer.bounds;
        [self.view.layer insertSublayer:layer atIndex:0];
        
        [self setOverlayPickerView];
        
        [session addObserver:self forKeyPath:@"running" options:NSKeyValueObservingOptionNew context:nil];
    }
    //开始捕获
    [session startRunning];
    
}

/**
 *
 *  创建扫码页面
 */
- (void)setOverlayPickerView
{
    CGFloat width = KDSScreenHeight< 667?30:63;
    //左侧的view
    UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, KDSScreenHeight)];
    leftView.alpha = 0.5;
    leftView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:leftView];
    //右侧的view
    UIImageView *rightView = [[UIImageView alloc] initWithFrame:CGRectMake(KDSScreenWidth-width, 0, width, KDSScreenHeight)];
    rightView.alpha = 0.5;
    rightView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:rightView];
    
    //最上部view
    UIImageView* upView = [UIImageView new];
    if ([self.fromWhereVC isEqualToString:@"MineVC"]) {
       upView.frame = CGRectMake(width, 0, KDSScreenWidth - width*2, (self.view.center.y-(KDSScreenWidth-width*2)/2)-64);
    }else{
       upView.frame = CGRectMake(width, 0, KDSScreenWidth - width*2, (self.view.center.y-(KDSScreenWidth-width*2)/2)-64);
    }
    
    upView.alpha = 0.5;
    upView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:upView];
    //底部view
    UIImageView * downView = [UIImageView new];
    if ([self.fromWhereVC isEqualToString:@"MineVC"]) {
        downView.frame = CGRectMake(width, (self.view.center.y+(KDSScreenWidth-width*2)/2)-64, (KDSScreenWidth-width*2), (KDSScreenHeight-(self.view.center.y-(KDSScreenWidth-60)/2)));
    }else{
        downView.frame = CGRectMake(width, (self.view.center.y+(KDSScreenWidth-width*2)/2)-64, (KDSScreenWidth-width*2), (KDSScreenHeight-(self.view.center.y-(KDSScreenWidth-60)/2)));
    }
    
    downView.alpha = 0.5;
    downView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:downView];
    
    ///线
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(upView.frame), KDSScreenWidth-60, 2)];
    line.tag = line_tag;
    line.image = [UIImage imageNamed:@"scan_line"];
    line.contentMode = UIViewContentModeScaleAspectFill;
    line.backgroundColor = [UIColor clearColor];
    [self.view addSubview:line];
    
    ///中间view
    UIImageView *centerView = [UIImageView new];
    if ([self.fromWhereVC isEqualToString:@"MineVC"]) {
         centerView.frame = CGRectMake(CGRectGetMaxX(leftView.frame),CGRectGetMinY(line.frame), KDSScreenWidth-width*2, CGRectGetMinY(downView.frame)-CGRectGetMaxY(upView.frame));
    }else{
         centerView.frame = CGRectMake(CGRectGetMaxX(leftView.frame),CGRectGetMinY(line.frame), KDSScreenWidth-width*2, CGRectGetMinY(downView.frame)-CGRectGetMaxY(upView.frame));
    }
   
    centerView.image = [UIImage imageNamed:@"scan_box"];
    centerView.contentMode = UIViewContentModeScaleAspectFit;
    centerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:centerView];
    
    UILabel *msg = [[UILabel alloc] initWithFrame:CGRectMake(30, CGRectGetMinY(downView.frame), KDSScreenWidth-60, 60)];
    msg.backgroundColor = [UIColor clearColor];
    msg.textColor = [UIColor whiteColor];
    msg.textAlignment = NSTextAlignmentCenter;
    msg.font = [UIFont systemFontOfSize:15];
    if ([self.fromWhereVC isEqualToString:@"MineVC"]) {///产品激活
        msg.text = Localized(@"PutBarCodeEquipmentIntoBox");
    }else{///猫眼、网关
        msg.text = Localized(@"ThecodeScannedAutomatically");
    }
    
    [self.view addSubview:msg];
    
    UIButton *lightBtn =  [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(msg.frame), 80, 45)];
    CGFloat Y = msg.frame.origin.y-50;
    lightBtn.center = CGPointMake(KDSScreenWidth/2, Y);
    [lightBtn setImage:[UIImage imageNamed:@"手电筒"] forState:UIControlStateNormal];
    [lightBtn setTitle:@"轻触点亮" forState:UIControlStateNormal];
    [lightBtn setBackgroundColor:[UIColor clearColor]];
    [lightBtn setFont:[UIFont systemFontOfSize:12]];
    [lightBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 25, 0, 0)];
    [lightBtn setTitleEdgeInsets:UIEdgeInsetsMake(50,-24, 0, 0)];
    [lightBtn addTarget:self action:@selector(clickLightBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lightBtn];
}
/**
 *
 *  监听扫码状态-修改扫描动画
 *
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context{
    if ([object isKindOfClass:[AVCaptureSession class]]) {
        BOOL isRunning = ((AVCaptureSession *)object).isRunning;
        if (isRunning) {
            [self addAnimation];
        }else{
            [self removeAnimation];
        }
    }
}
/**
 *
 *  获取扫码结果
 */
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count>0) {
        [session stopRunning];
        NSURL *url=[[NSBundle mainBundle]URLForResource:@"scanSuccess.wav" withExtension:nil];
        //2.加载音效文件，创建音效ID（SoundID,一个ID对应一个音效文件）
        SystemSoundID soundID=8787;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
        //3.播放音效文件
        //下面的两个函数都可以用来播放音效文件，第一个函数伴随有震动效果
        AudioServicesPlayAlertSound(soundID);
        
        AudioServicesPlaySystemSound(8787);
        
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex :0];
        isResend = YES;
        //输出扫描字符串
        NSString *data = metadataObject.stringValue;
//        NSLog(@"--{Kaadas}--输出扫描字符串==%@",data);
        if ([self.fromWhereVC isEqualToString:@"GatewayVC"]) {///网关
            KDSAddGWThreVC *vc = [[KDSAddGWThreVC alloc] init];
            vc.dataStr = data;
            [self.navigationController pushViewController:vc animated:YES];
        }if ([self.fromWhereVC isEqualToString:@"CatEyeVC"]) {///猫眼
            ///先鉴权下猫眼的允许猫眼入网请求，成功之后再发组播进行组网
            self.dataStr = data;
            [self allowCateye];
            
        }if ([self.fromWhereVC isEqualToString:@"MineVC"]) {///产品激活
            
            KDSProductActivationVC * vc = [KDSProductActivationVC new];
            vc.productId = data;
            [self.navigationController pushViewController:vc animated:YES];
            
        }if ([self.fromWhereVC isEqualToString:@"AddDeviceVC"]) {///扫一扫
            if ([data containsString:@"GW"]) {//扫描的网关
                KDSAddGWThreVC *vc = [[KDSAddGWThreVC alloc] init];
                vc.dataStr = data;
                [self.navigationController pushViewController:vc animated:YES];
            }else{///扫描的猫眼
                KDSBingdingGWFailVC * vc = [KDSBingdingGWFailVC new];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }
}

/**
 *
 *  添加扫码动画
 */
- (void)addAnimation{
    UIView *line = [self.view viewWithTag:line_tag];
    line.hidden = NO;
     CGFloat width = KDSScreenHeight< 667?30:63;
    CABasicAnimation *animation = [KDSScanGatewayVC moveYTime:2 fromY:[NSNumber numberWithFloat:0] toY:[NSNumber numberWithFloat:KDSScreenWidth-width*2-2] rep:OPEN_MAX];
    [line.layer addAnimation:animation forKey:@"LineAnimation"];
}

+ (CABasicAnimation *)moveYTime:(float)time fromY:(NSNumber *)fromY toY:(NSNumber *)toY rep:(int)rep
{
    CABasicAnimation *animationMove = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    [animationMove setFromValue:fromY];
    [animationMove setToValue:toY];
    animationMove.duration = time;
//    animationMove.delegate = self;
    animationMove.repeatCount  = rep;
    animationMove.fillMode = kCAFillModeForwards;
    animationMove.removedOnCompletion = NO;
    animationMove.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return animationMove;
}

/**
 *
 *  去除扫码动画
 */
- (void)removeAnimation{
    
    UIView *line = [self.view viewWithTag:line_tag];
    [line.layer removeAnimationForKey:@"LineAnimation"];
    line.hidden = YES;
    [session removeObserver:self forKeyPath:@"running" context:nil];
    session = nil;
    [layer removeFromSuperlayer];
    [session removeInput: input];
    [session removeOutput:output];
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}
/**
 *  开启/关闭手电筒
 */

- (void)clickLightBtn:(UIButton *)sender {
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            [device lockForConfiguration:nil];
            if (!sender.selected) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                sender.selected = YES;
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                sender.selected = NO;
            }
            
            [device unlockForConfiguration];
        }
    }
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [session removeObserver:self forKeyPath:@"running" context:nil];
}

-(void)backUpClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)allowCateye{
    ///允许猫眼入网
    ///跳转到此界面证明已经拿到扫描结果，然后去绑定猫眼
    
    NSArray * rangeArr = [self.dataStr componentsSeparatedByString:@" "];
    if (rangeArr.count == 2) {
        NSString * snStr = rangeArr[0];
        NSString * macStr = rangeArr[1];
        if (snStr != nil || snStr.length>0) {
            //取出完整的SN码
            self.deviceSN = [[snStr substringFromIndex:3] substringToIndex:13];
            //规避一些SN号只有12位的情况
            if ([snStr containsString:@" "]) {
                self.deviceSN = [[snStr substringFromIndex:0] substringToIndex:12];
            }
        }
        if (macStr != nil || macStr.length>0) {
            
            //获取完整的mac码----截取掉下标4之后的字符串
            self.deviceMAC = [macStr substringFromIndex:4];
            if (macStr.length >= 21) {
                //截取字符串-----截取掉下标16之后的字符串
                NSString *str1 = [macStr substringFromIndex:16];
                //截取掉下标5之前的字符串
                NSString *str2 = [str1 substringToIndex:5];
                //分隔字符串-----从字符:中分隔成2个元素的数组
                NSArray *array = [str2 componentsSeparatedByString:@":"];
                if (array.count == 2) {
                   self.deviceID = [NSString stringWithFormat:@"%@%@",array[0],array[1]];
                }else{
                    //提示用户扫描正确的kaadas猫眼二维码
                    [MBProgressHUD showError:Localized(@"scanCorrectTwo-dimensionalCode")];
                    [self.navigationController popViewControllerAnimated:YES];
                    return;
                }
            }
        }
        ///已经拿到deviceID、deviceSN、去绑定猫眼
        [self devicejoinGw];
        
    }else{
        ///没有拿到，提示用户扫描正确的kaadas猫眼二维码
        [MBProgressHUD showError:Localized(@"scanCorrectTwo-dimensionalCode")];
        [self.navigationController popViewControllerAnimated:YES];

    }
    
}

-(void)devicejoinGw
{
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"requestingResetPwd") toView:self.view];
    [[KDSMQTTManager sharedManager] gw:self.gatewayModel setCateyeAccessEnable:YES withCateyeSN:self.deviceSN mac:self.deviceMAC completion:^(NSError * _Nullable error, BOOL success) {
        
        ////猫眼入网成功与否：如果成功跳转到成功页面反之跳转到失败页面
        NSLog(@"%@----%d",error,success);
        if (success) {
            [hud hideAnimated:YES];
            KDSAddCatEye3VC * addCatEye3VC = [KDSAddCatEye3VC new];
            addCatEye3VC.dataString = self.dataStr;
            addCatEye3VC.wifiPwd = self.wifiPwd;
            addCatEye3VC.gwSid = self.gwSid;
            addCatEye3VC.deviceId = self.deviceID;
            addCatEye3VC.gatewayModel = self.gatewayModel;
            addCatEye3VC.deviceSN = self.deviceSN;
            addCatEye3VC.deviceMac = self.deviceMAC;
            [self.navigationController pushViewController:addCatEye3VC animated:YES];
            
        }else{
            [MBProgressHUD showError:Localized(@"FailedRequestNetwork")];
            [hud hideAnimated:YES];
        }
        
        
    }];
}

@end
