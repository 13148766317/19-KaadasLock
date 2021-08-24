//
//  KDSSmartHangerSendSSIDAndPwdVC.h
//  KaadasLock
//
//  Created by Frank Hu on 2021/1/11.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"
#import "CYCircularSlider.h"
#import <CoreLocation/CoreLocation.h>
#import "KDSAMapLocationManager.h"
#import "KDSAddSmartHangerStep2VC.h"
#import "KDSHttpManager+SmartHanger.h"
#import "KDSAddSmartHangerFailVC.h"
#import "KDSAddSmartHangerSuccessVC.h"
#import "KDSBluetoothTool.h"
#import "KDSSmartHangerModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSSmartHangerSendSSIDAndPwdVC : KDSBaseViewController

///Wi-Fi锁的数据模型
@property (nonatomic,strong)KDSWifiLockModel * model;
///路由器的账号
@property (nonatomic,strong)NSString * wifiNameStr;
///路由器的mac地址
@property (nonatomic,strong)NSString * bssid;
///路由器的密码
@property (nonatomic,strong)NSString * pwdStr;
///手动编辑Wi-Fi SSID标记
@property (nonatomic,assign) BOOL auto2Hand;

@property (nonatomic, weak) KDSBluetoothTool *bleTool;


@property (nonatomic,strong)CYCircularSlider *circularSlider;
///进度条百分比
@property (nonatomic,strong)UILabel * sliderValueLb;
///发送门锁管理员密码
@property (nonatomic,strong)UILabel * showTipsLb1;
///门锁验证管理员密码
@property (nonatomic,strong)UILabel * showTipsLb2;
///门锁设备验证中
@property (nonatomic,strong)UILabel * showTipsLb3;
///第一步
@property (nonatomic,strong)UIImageView * showTipsImg1;
@property (nonatomic,strong)UIImageView * showHidenImg1;
///第二步
@property (nonatomic,strong)UIImageView * showTipsImg2;
@property (nonatomic,strong)UIImageView * showHidenImg2;
///第三步
@property (nonatomic,strong)UIImageView * showTipsImg3;
@property (nonatomic,strong)UIImageView * showHidenImg3;
///交换数据后如果15秒内有网络且请求成功即成功反之失败（绑定过程会切换两次网络，交换数据用锁广播的热点）
@property (nonatomic,strong) NSString * currentSsid;
///收到绑定成功的消息每6秒请求一次服务器绑定设备
@property (nonatomic,strong) NSTimer * overTimer;
//与Wi-Fi模块数据交互成功
@property (nonatomic,assign) BOOL wifiSuccess;
///每6秒请求一个服务器10次失败即添加失败（热点断开的瞬间会没有网络，手机重连的过程中设备添加到服务器不会中断所以，循环之行定时器）
@property (nonatomic, assign) int currentNum;
///是否已经push过（只能执行一次）
@property (nonatomic, assign) BOOL ispushing;
///100秒没有收到模块发来成功的字符串，就失败
@property (nonatomic,strong) NSTimer * ReceiveDataOutTimer;
///定时，每0.2秒增加20%的进度3秒没有跳转页面停留在99%
@property (nonatomic,strong)NSTimer * changeTimer;
///进度条的值。默认是70，每0.2秒增加10
@property (nonatomic,assign)int sliderCurrentNum;
///当前是进行的第几步：第一步（发送SSID、pwd）第二步（收到模块发来的数据：成功/失败）第三步（正在请求服务器绑定设备）
@property (nonatomic,assign)int currentStepNum;
@property (nonatomic,strong)CABasicAnimation * rotateAnimation;
@property (nonatomic,strong)NSMutableData * pwdData;
@property (nonatomic,assign)int tsn;
@property (nonatomic,assign)BOOL isCanSendPwd;

@end

NS_ASSUME_NONNULL_END
