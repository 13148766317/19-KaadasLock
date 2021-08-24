//
//  KDSUserManager.h
//  xiaokaizhineng
//
//  Created by orange on 2019/1/25.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KDSUser.h"
#import "KDSLock.h"
#import "KDSCatEye.h"
#import "GatewayModel.h"
#import "KDSGW.h"
#import "KDSDeviceHangerModel.h"

NS_ASSUME_NONNULL_BEGIN

///使用此类统一管理与用户有关的属性。
@interface KDSUserManager : NSObject

+ (instancetype)sharedManager;

///用户模型。请在AppDelegate中免登录或者登录后设置此变量，以后所有使用到用户属性相关的从此变量获取。
@property (nonatomic, strong) KDSUser *user;
///用户昵称。登录/免登录，从数据库中获取，在”我的“页面从服务器获取或修改成功后，修改此值(这里并没有保存到数据库，请自行更新数据库)。
@property (nonatomic, strong) NSString *userNickname;
/**
 *@abstract 根据用户绑定设备列表创建的门锁数组。请在主页从服务器拉取设备列表和创建页面后设置此变量，以后所有使用到门锁相关的从此变量获取。
 *@note 门锁模型中的蓝牙工具类一般在viewDidLoad或初始化方法中创建。由于蓝牙工具类代理只能有一个，因此请注意设置方式。
 */
@property (nonatomic, strong) NSMutableArray<KDSLock *> *locks;
/**
 *@abstract 根据用户绑定设备列表创建的猫眼数组。请在主页从服务器拉取设备列表和创建页面后设置此变量，以后所有使用到门锁相关的从此变量获取。
 *@note 门锁模型中的蓝牙工具类一般在viewDidLoad或初始化方法中创建。由于蓝牙工具类代理只能有一个，因此请注意设置方式。
 */
@property (nonatomic, strong) NSMutableArray<KDSCatEye *> *cateyes;
/**
 *@abstract 根据用户绑定设备列表创建的网关数组。请在主页从服务器拉取设备列表和创建页面后设置此变量，以后所有使用到门锁相关的从此变量获取。
 *@note 门锁模型中的蓝牙工具类一般在viewDidLoad或初始化方法中创建。由于蓝牙工具类代理只能有一个，因此请注意设置方式。
 */
@property (nonatomic, strong) NSMutableArray<KDSGW *> *gateways;
/**
*@abstract 根据用户绑定设备列表创建的设备图片数组。请在主页从服务器拉取设备列表和创建页面后设置此变量，以后所有使用到门锁相关的从此变量获取。
*/
@property (nonatomic, strong) NSMutableArray<KDSProductInfoList *> *productInfoList;

// 晾衣架
@property (nonatomic, strong) NSMutableArray<KDSDeviceHangerModel *> *hangers;
/**
 *@abstract 当收到锁报警通知时，调用此方法添加一个报警记录，由本类统一弹出报警UI。*此功能也可以在首页做。
 *@param bleName 外设蓝牙名称。
 *@param alarmData 蓝牙返回的20字节协议数据。
 */
- (void)addAlarmForLockWithBleName:(NSString *)bleName data:(NSData *)alarmData;

/**
 *@abstract 重置用户管理器。一般当登录token过期重新登录或发生其它异常等时，需调用此方法重置本类保存的数据。
 */
- (void)resetManager;
///获取当前网络状态
-(void)monitorNetWork;
/**
获取当前通话的猫眼ID

 @return 返回猫眼ID
 */
-(NSString *)getCurrentCateyeId;

//当前通话接通时间戳
@property (nonatomic, copy) NSString *currentCallTimeStamp;
//当前通话录屏保存路径
@property (nonatomic, copy) NSString *currentCallRecordPath;
//当前通话录屏文件保存路径
@property (nonatomic, copy) NSString *currentCallRecordPathName;
///是否有网络
@property(nonatomic, assign)BOOL netWorkIsAvailable;
///有网是分（4G、Wi-Fi）
@property(nonatomic, assign)BOOL  netWorkIsWiFi;
///讯美视频锁：门铃通话中
@property(nonatomic, assign)BOOL doorbellProgress;
///日期格式器，建立时没有格式，使用前请先设置格式。
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
// 字典转化成字符串
-(NSString *)convertToJsonData:(NSDictionary *)dict;
-(NSString *)getNowTimeTimestamp;
///用户账户下面是否有绑定猫眼设备
FOUNDATION_EXTERN NSString * const KDSUserBindingedCateye;
#pragma mark - 通知相关
///主动解除账号下已绑定的锁时会发出该通知，通知userInfo的lock属性是被删除的KDSLock模型，一般用于刷新首页等界面。
FOUNDATION_EXTERN NSString * const KDSLockHasBeenDeletedNotification;
///成功绑定新的锁时会发出该通知，通知userInfo的device属性是绑定的设备模型，一般用于刷新首页等界面。
FOUNDATION_EXTERN NSString * const KDSLockHasBeenAddedNotification;
///退出登录通知。为方便管理所有的退出登录操作，设立此通知，统一使用通知在AppDelegate中处理退出登录。
FOUNDATION_EXTERN NSString * const KDSLogoutNotification;
///开锁通知，为方便管理所有页面的开锁操作，设立此通知，统一(在首页)操作开锁。userInfo的lock属性是操作的锁模型对象。
FOUNDATION_EXTERN NSString * const KDSUserUnlockNotification;
///设备同步通知。为保持设备页面等其它页面的设备数量、设备状态和首页相一致，一般首页(蓝牙也可在自动连接类)刷新设备时发出此通知。
FOUNDATION_EXTERN NSString * const KDSDeviceSyncNotification;
///当用户长期没有操作屏幕时发出此通知，断开蓝牙连接。
FOUNDATION_EXTERN NSString * const KDSUserLongtimeNoOperationNotification;
///当用户重新操作屏幕时发出此通知，重新连接蓝牙。
FOUNDATION_EXTERN NSString * const KDSUserActivateOperationNotification;
////网关锁密码同步问题。当在锁上操作删除、增加密码的时候为保证密码一致
FOUNDATION_EXPORT NSString * const KDSGWLockPwdNotification;
////网关上线刷新设备状态
FOUNDATION_EXPORT NSString * const KDSGWOnlineNotification;
///主动解除账号下已绑定的猫眼时会发出该通知，通知userInfo的cateye属性是被删除的KDSCateye模型，一般用于刷新首页等界面。
FOUNDATION_EXTERN NSString * const KDSCatEyeHasBeenDeletedNotification;
///当蓝牙连接成功后判定蓝牙版本号是否相同，不同的话获取到最新的BleVersion并上传到服务器，之后刷新账号下绑定的设备的数据源
FOUNDATION_EXTERN NSString * const KDSLockUpdateBleVersionNotification;
///当ble+wifi的锁添加成功的时候，因为添加成功页面可以直接进入设备详情此时没有刷新账号下的数据源，所以添加成功之后刷新账号下绑定的设备的数据源
FOUNDATION_EXTERN NSString * const KDSBleLockUpdateDataSourceNotification;
///门铃呼叫的时候，根据门铃所在的锁的WFSN，呼叫对应的门铃，在首页
FOUNDATION_EXTERN NSString * const KDSXMMediaDoorBeellNotification;




@end

NS_ASSUME_NONNULL_END
