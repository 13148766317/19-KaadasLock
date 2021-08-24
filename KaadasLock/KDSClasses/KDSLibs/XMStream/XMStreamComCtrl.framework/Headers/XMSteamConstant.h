//
//  XMSteamConstant.h
//  XMStreamComCtrl
//
//  Created by xunmei on 2018/10/9.
//  Copyright © 2018 ryan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPCS_API.h"

FOUNDATION_EXPORT NSString *const NotificationXMStreamComCtrlText;

FOUNDATION_EXPORT NSString *const XMResultKey;

#pragma mark - 信令通讯值定义
#define REAL_STREAM_MOD            0x00                //实时流模式
#define FILE_STREAM_MOD            0x01                //录像流模式

typedef NS_ENUM(NSInteger,XMAgreementType) {
    XMAgreementTypeNew = 0, //默认
    XMAgreementTypeBefore,
};

/**
 OSD显示
*/
typedef NS_ENUM(NSInteger, XMOSDDisplayMode) {
    /// 隐藏OSD
    XMOSDDisplayModeHidn                    = 0,
    /// 显示 OSD 时间戳
    XMOSDDisplayModeShowTimestamp           = 1,
    /// 显示 OSD 时间戳和Logo
    XMOSDDisplayModeShowTimestampAndLogo    = 2,
};

/**
 视频质量
*/
typedef NS_ENUM(NSInteger, XMVideoQualityMode) {
    /// 自动
    XMVideoQualityModeAuto      = 0,
    /// 低
    XMVideoQualityModeLow       = 1,
    /// 中
    XMVideoQualityModeMedium    = 2,
    /// 高
    XMVideoQualityModeHigh      = 3,
};

/**
 PIR灵敏度值
 */
typedef NS_ENUM(NSInteger,P2P_PIRSENSITIVITY) {
    ///灵敏度低(30)
    P2P_PIRSENSITIVITY_LOW = 30,
    ///灵敏度中(60)
    P2P_PIRSENSITIVITY_MIDDLE = 60,
    ///灵敏度高(90)
    P2P_PIRSENSITIVITY_HIGH = 90,             
};

/**
 图像翻转状态
 */
typedef NS_ENUM(NSInteger,P2P_VIDEO_MIRRORMODE) {
    ///0 正常
    VIDEO_MIRRORMODE_NORMAL = 0, 
    ///1 水平
    VIDEO_MIRRORMODE_HORIZONTALLY,
    ///2 垂直
    VIDEO_MIRRORMODE_VERTICALLY,
    ///3 水平垂直    
    VIDEO_MIRRORMODE_HORIZVERTI,    
};

/**
 升级状态
 */
typedef NS_ENUM(NSInteger,P2P_UPDATE_STATUS) {
    ///0 空闲状态
    P2P_UPDATE_IDLE = 0,  
    ///1 连接服务器
    P2P_UPDATE_CONNECT_SERVER,
    ///2 服务器连接失败
    P2P_UPDATE_CONNECT_ERR,
    ///3 升级包下载中
    P2P_UPDATE_LOADING,
    ///4 升级包下载失败或超时
    P2P_UPDATE_LOAD_ERR, 
    ///5 升级包下载完成
    P2P_UPDATE_LOAD_FINISH,
    ///6 升级包校验失败
    P2P_UPDATE_CRCERR, 
    ///7 升级中
    P2P_UPDATE_UPGRADING,
    ///8 升级成功
    P2P_UPDATE_SUCCESS,
    ///9 升级失败
    P2P_UPDATE_FAIL,                    
};

/**
 升级包类型
 */
typedef NS_ENUM(NSInteger,P2P_UPDATE_TYPE) {
    ///(0)网关
    xMP2P_UPDATE_TYPE_GATEWAY=0, 
    ///(1)主控
    xMP2P_UPDATE_TYPE_MASTER,
    ///(2)DSP
    xMP2P_UPDATE_TYPE_DSP,                  
};


/**
 录像回放控制类型
 */
typedef NS_ENUM(NSInteger,P2P_RECORD_PLAY_CTRL) {
    ///继续传输录像数据
    RECORD_CTRL_CONTINUE=0, 
    ///暂停发送录像数据
    RECORD_CTRL_PAUSE, 
    ///停止传输录像数据
    RECORD_CTRL_STOP,                   
};

/**
 录像回放传输模式
 */
typedef NS_ENUM(NSInteger,P2P_RECORD_PLAY_TYPE) {
    ///(0)正常传输
    xMP2P_RECORD_PLAY_TYPE_NORMA = 0,   
    ///(1)加速传输
    xMP2P_RECORD_PLAY_TYPE_DOWNLOAD,  
    ///(2)快速传输
    xMP2P_RECORD_PLAY_TYPE_FAST,           
};

/**
 视频分辨率
 */
typedef NS_ENUM(NSInteger,P2P_VIDEO_RESOLUTION) {
    ///(0)1920x1080
    VIDEO_RES_1080P = 0,
    ///(1)1080x960
    VIDEO_RES_960P,
    ///(2)1280x720
    VIDEO_RES_720P,
    ///(3)720x576
    VIDEO_RES_576P,
    ///(4)720x480
    VIDEO_RES_480P, 
    ///(5)640x360
    VIDEO_RES_360P,
    ///(6)352X288
    VIDEO_RES_288P,
    ///(7)360X240
    VIDEO_RES_240P,
    ///(8)320X180
    VIDEO_RES_180P,
    ///(10)1536X1376
    VIDEO_RES_1376P = 10,
    ///(11)768X668
    VIDEO_RES_668P,
    ///(16)480_270
    VIDEO_RES_480_270 = 16,
    ///(17)1024_768
    VIDEO_RES_1024_768,
    ///(18)640_480
    VIDEO_RES_640_480,
    ///(19)480_360
    VIDEO_RES_480_360,
    ///(20)320_240
    VIDEO_RES_320_240,
    ///(21)2560_1920
    VIDEO_RES_2560_1920,
    ///(101)640X480
    VIDEO_RES_480P_BE = 101, 
    ///(102)480X320
    VIDEO_RES_320P_BE                       
};

/**
 视频分辨率 注意：Agreement 为 before 才启用
 */
typedef NS_ENUM(NSInteger,P2P_VIDEO_RESOLUTION_BEFORE) {
    ///1280x720
    VIDEO_RES_720P_BEFORE = 1, 
    ///640X480
    VIDEO_RES_480P_BEFORE,
    ///480X320
    VIDEO_RES_320P_BEFORE             
};

/**
 视频编码格式
 */
typedef NS_ENUM(NSInteger,P2P_VIDEO_CODEC) {
    ///(1)H.264 默认
    xMP2P_VIDEO_CODEC_H264 = 1,
    ///(2)MJPEG
    xMP2P_VIDEO_CODEC_MJPEG,
    ///(3)H.265
    xMP2P_VIDEO_CODEC_H265                      
};

/**
 音频编码格式
 */
typedef NS_ENUM(NSInteger,P2P_AUDIO_CODEC) {
    ///(0)PCM
    xMP2P_AUDIO_CODEC_PCM = 0, 
    ///(1)G711A 默认
    xMP2P_AUDIO_CODEC_G711A,
    ///(2)G711U
    xM2P_AUDIO_CODEC_G711U,
    ///(3)AAC
    xMP2P_AUDIO_CODEC_AAC, 
    ///(4)OPUS
    xMP2P_AUDIO_CODEC_OPUS                  
};

/**
 红外夜视模式状态
 */
typedef NS_ENUM(NSInteger,P2P_IRMODE) {
    ///关闭红外灯
    P2P_IRMODE_CLOSE=0, 
    ///自动模式
    P2P_IRMODE_AUTO,
    ///打开夜视模式/ 不区分白天黑色
    P2P_IRMODE_OPEN,
    ///定时
    P2P_IRMODE_TIMEING,         
};

/**
 新夜视模式状态 2020年07月31日
 */
typedef NS_ENUM(NSInteger, XMIRMode) {
    ///关闭红外灯
    XMIRModeClose = 0, 
    ///自动模式
    XMIRModeAuto,
    ///打开夜视模式/ 不区分白天黑色
    XMIRModeOpen,
    ///补光灯模式
    XMIRModeSpotlight,         
};

/**
 PIR状态
 */
typedef NS_ENUM(NSInteger,P2P_PIRCTRL) {
    ///(0)PIR关闭
    P2P_PIRCTRL_CLOSE = 0,
    ///(1)PIR开启
    P2P_PIRCTRL_OPEN            
};

/**
 抓拍录像控制类型
 */
typedef NS_ENUM(NSInteger,P2P_CAPTURE_VIDEO_CMD) {
    ///停止抓拍录像
    P2P_CAPTURE_VIDEO_CLOSE = 0, 
    ///开始抓拍录像
    P2P_CAPTURE_VIDEO_START = 1,          
};

/**
 摄像机锁控制
 */
typedef NS_ENUM(NSInteger,P2P_LOCK_CTRL) {
    ///(0)解锁
    P2P_NOLOCK = 0, 
    ///(1)锁定
    P2P_LOCK,                   
};

/**
 全时录像状态
 */
typedef NS_ENUM(NSInteger,P2P_ALLTIME_RECORD_CTRL) {
    ///(0)关闭全时录像
    xMP2P_ALLTIME_RECORD_CLOSE = 0, 
    ///(1)开启全时录像
    xMP2P_ALLTIME_RECORD_OPEN                
};

/**
 提示音语言类型
 */
typedef NS_ENUM(NSInteger,LanguageType){
    ///(0)英文
    LanguageTypeEnglish = 0,
    ///(1)中文
    LanguageTypeChinese,
};

/**
 抓图质量
 */
typedef NS_ENUM(NSInteger,P2P_SNAPSHOT_QUALITY){
    ///(0)设备默认
    P2P_SNAPSHOT_QUALITY_DEFAULT = 0,   
    ///(1)高
    P2P_SNAPSHOT_QUALITY_HIGH,
    ///(2)中
    P2P_SNAPSHOT_QUALITY_MIDDLE, 
    ///(3)低
    P2P_SNAPSHOT_QUALITY_LOW                
};

/**
 录像搜索类型
 */
typedef NS_ENUM(NSInteger,P2P_RECORD_SEARCH){
    ///(0)全部类型
    xMP2P_RECORD_SEARCH_TYPE_ALL = 0,
    ///(1)报警录像
    xMP2P_RECORD_SEARCH_TYPE_ALARM, 
    ///(2)门铃告警    
    xMP2P_RECORD_SEARCH_TYPE_RING,        
    ///(3)抓拍录像
    xMP2P_RECORD_SEARCH_TYPE_CAPTURE,
    ///(4)抓拍图片
    xMP2P_RECORD_SEARCH_TYPE_IMG,              
    ///(5)全时录像
    xMP2P_RECORD_SEARCH_TYPE_ALLTIME,
};

/**
 录像列表文件类型
 */
typedef NS_ENUM(NSInteger,P2P_RECORD_RESP){
    ///(1)报警录像
    xMP2P_RECORD_RESP_TYPE_ALARM = 1, 
    ///(2)门铃告警    
    xMP2P_RECORD_RESP_TYPE_RING,        
    ///(3)抓拍录像
    xMP2P_RECORD_RESP_TYPE_MANUAL,
    ///(4)抓拍图片
    xMP2P_RECORD_RESP_TYPE_IMG,              
    ///(5)全时录像
    xMP2P_RECORD_RESP_TYPE_ALLTIME,                
};

/**
 清除摄像机配对信息
 */
typedef NS_ENUM(NSInteger,P2P_CLEAR_MATH){
    ///(0)清除指定摄像机
    xMP2P_CLEAR_MATH_CHANNEL = 0,
    ///(1)清除全部摄像机
    xMP2P_CLEAR_MATH_ALL                    
};

/**
 布防撤防类型
 */
typedef NS_ENUM(NSInteger,P2P_ARMING){
    ///(0)撤防
    xMP2P_ARMING_DISABLE = 0, 
    ///(1)布防
    xMP2P_ARMING_ENABLE,
    ///(2)定时布防
    xMP2P_ARMING_ONTIME                     
};

/**
 SD卡状态
 */
typedef NS_ENUM(NSInteger,P2P_SD_STATUS){
    ///(0)无卡
    xMP2P_SD_STATUS_NOCRAD = 0, 
    ///(1)有卡
    xMP2P_SD_STATUS_HAVECRAD, 
    ///(2)坏卡
    xMP2P_SD_STATUS_BADCRAD, 
    ///(3)需要格式化
    xMP2P_SD_STATUS_NEEDFROMAT                  
};

/**
 路由器连接密码类型
 */
typedef NS_ENUM(NSInteger,P2P_WIFI_ENCRYPTION){
    /// 0:OPEN
    xMP2P_WIFI_ENCRYPTION_OPEN = 0,
    /// 1:WEP
    xMP2P_WIFI_ENCRYPTION_WEP, 
    /// 2:WPA-PSK
    xMP2P_WIFI_ENCRYPTION_WPA, 
    /// 3:WPA2-PSK
    xMP2P_WIFI_ENCRYPTION_WPA2,  
    /// 4:WPA-PSK/WPA2-PSK
    xMP2P_WIFI_ENCRYPTION_WPAORWPA2        
};

/**
 亮灯模式
 */
typedef NS_ENUM(NSInteger,P2P_LIGHTSMODE){
    /// 0:人走灯灭
    xMP2P_LIGHTSMODE_CLOSE = 0,
    /// 1:人走灯暗
    xMP2P_LIGHTSMODE_DOWN, 
    /// 2:常亮
    xMP2P_LIGHTSMODE_LIGHT                 
};

/**
 信令回复错误码参照
 */
typedef NS_ENUM(NSInteger,P2P_ERRCODE_TYPE){
    ///(1)获取JSON节点失败
    xMP2P_ERRTYPE_NODE_NULL = 1, 
    ///(2)JSON节点值超过范围
    xMP2P_ERRTYPE_NODE_VAL_CROSS,
    ///(3)用户名无效
    xMP2P_ERRTYPE_USERNAME_INVALID, 
    ///(4)获取参数失败(获取到的参数值无效)
    xMP2P_ERRTYPE_GET_PARAM_FAIL,
    ///(5)文件打开失败
    xMP2P_ERRTYPE_FILE_OPENFAIL,
    ///(6)认证失败
    xMP2P_ERRTYPE_AUTH_FAIL, 
    ///(7)对讲通道已占用
    xMP2P_ERRTYPE_TALK_NOIDLE,  
    ///(8)当前会话未打开打对讲
    xMP2P_ERRTYPE_TALK_INVALID,    
    ///(9)未找到录像文件
    xMP2P_ERRTYPE_RECORDFILE_NOTFIND, 
    ///(10)删除录像文件失败
    xMP2P_ERRTYPE_DELFILE_FAIL,  
    ///(11)回放通道已占用
    xMP2P_ERRTYPE_PLAYBACK_NOIDLE,
    ///(12)回放失败
    xMP2P_ERRTYPE_PLAYBACK_FIAL,    
    ///(13)回放控制无效(没有文件处于回放状态)
    xMP2P_ERRTYPE_PLAYBACK_CTRL_INVALID,  
    ///(14)回放控制TOKEN无效
    xMP2P_ERRTYPE_TOKEN_INVALID,   
    ///(15)摄像机麦克风未打开
    xMP2P_ERRTYPE_MIC_NOOPEN,   
    ///(16)摄像机喇叭未打开
    xMP2P_ERRTYPE_SPEAKER_NOOPEN, 
    ///(17)密码超过限制(5~12)
    xMP2P_ERRTYPE_PASSWD_CROSS,  
    ///(18)无SD卡或SD卡损坏
    xMP2P_ERRTYPE_NOSD,   
    ///(19)强制停止录像(SD卡损坏或正在升级)
    xMP2P_ERRTYPE_RECORD_STOP,      
    ///(20)未检测到录像索引
    xMP2P_ERRTYPE_NEED_SDNEEDFORMAT, 
    ///(21)格式化SD卡失败
    xMP2P_ERRTYPE_FORMAT_SD_FAIL, 
    ///(22)挂载SD卡失败
    xMP2P_ERRTYPE_MOUNT_SD_FAIL,  
    ///(23)校时时间设置失败
    xMP2P_ERRTYPE_TIMESYNC_SERTIME_ERR,
    ///(24)校时时区设置失败
    xMP2P_ERRTYPE_TIMESYNC_SETNTP_ERR, 
    ///(25)摄像机忙(未完成上一次抓图或抓拍录像)
    xMP2P_ERRTYPE_CAMERA_BUSY,  
    ///(26)参数检测失败
    xmP2P_ERRTYPE_PARAMCHECK_ERR, 
    ///(27)文件夹检测失败
    xMP2P_ERRTYPE_DIRCHRCK_ERR, 
    ///(28)外部电源未接入
    xMP2P_ERRTYPE_NOT_EXPOWER_IN,   
    ///(29)摄像机正在配置
    xMP2P_ERRTYPE_CAMERA_IN_CONFIGURATION,
    ///(30)正在操作该通道
    xMP2P_ERRTYPE_CAMERA_OPERATING, 
    ///(31)操作失败
    xMP2P_ERRTYPE_FAILED,  
    ///(32)文件下载失败
    xMP2P_ERRTYPE_UPDATEFAILED,  
    ///(100)网关已锁定
    xMP2P_ERRTYPE_GATEWAY_LOCK=100,
    ///(101)摄像机已锁定
    xMP2P_ERRTYPE_CAMERA_LOCK,  
    ///(301)开启视频流超时
    xMP2P_ERRTYPE_OPENVIDE_TIMEOUT = 301,
    ///(1000)JSON错误(分配空间等失败)
    xMP2P_ERRTYPE_JSON_ERR = 1000,  
    ///(1001)SDK库接口调用失败
    xMP2P_ERRTYPE_XMHAL_ERR,    
    ///(1002)信令通道未建立
    xMP2P_ERRTYPE_CMD_NOCONNECT,
    ///(1003)配置命令发送失败
    xMP2P_ERRTYPE_COMMUNICATION_FAIL,
    ///(1004)摄像机唤醒超时或失败
    xMP2P_ERRTYPE_CAMERA_WAKEUP_FAIL,
    ///(1005)配置摄像机参数超时
    xMP2P_ERRTYPE_SETPARAM_TIMEOUT,
    ///(1006)配置摄像机参数失败
    xMP2P_ERRTYPE_SETPARAM_FAIL, 
    ///(1007)指定通道无摄像机
    xMP2P_ERRTYPE_CAMERA_NOMATCH, 
    ///(1008)指定通道摄像机不在线
    xMP2P_ERRTYPE_CAMERA_NOONLINE, 
    ///(1009)线程创建失败
    xMP2P_ERRTYPE_PTHREAD_CREATEFAIL,
    ///(9999)不支持该功能
    xMP2P_ERRTYPE_NOSUPPORT = 9999                
};

/**
 设备主动上报的信息命令字定义
 */
typedef NS_ENUM(NSInteger,P2P_CMD_PUSH) {
    ///(0)电池电量低
    xMP2P_MSG_POWER_LOW = 0,   
    ///(1)电池已充满
    xMP2P_MSG_POWER_FULL,  
    ///(2)SD卡需要格式化
    xMP2P_MSG_SDNEEDFORMAT, 
    ///(3)解析命令头失败(APP收到该消息后应该断开会话重新连接)
    XMP2P_MSG_CMDPARSEERR,      
    ///(4)设备基本信息
    xMP2P_MSG_DEV_INFO, 
    ///(5)升级状态
    xMP2P_MSG_UPDATE_STATE,  
    ///(100)回放结束
    xMP2P_MSG_RECORD_PLAYEND = 100,
    ///(101)SD卡下载录像接收结束
    xMP2P_MSG_RECORD_RECEIVE_END,
    ///(102)SD卡发送文件结束
    xMP2P_MSG_FILE_RECEIVE_END,
    ///(103)MQTT控制 连接后，自动反馈信息字段 （连接MQTT 成功/失败 ）
    // "result":"ok",
    // "ctrl":1
    
    // "result":"failed",
    // "errno":xx
    // 参考对应错误.1011：MQTT登录失败，1012：MQTT登出失败，1013：MQTT登出失败，有任务正在执行
    xMP2P_MSG_MQTT_CTRL_RESULT,
};

typedef NS_ENUM(NSInteger,P2P_CMD_PUSH_BEFORE) {
    ///电池电压(例:80代表0.8V) 锂电池返回电池电量
    xMP2P_MSG_VOLTAGE_BEFORE = 0,
    ///电量低
    xMP2P_MSG_LOW_POWER_BEFORE, 
    ///回放结束
    xMP2P_MSG_RECORD_PLAYEND_BEFORE = 10,
    ///回放开始
    xMP2P_MSG_RECORD_PLAYSTART_BEFORE,
    ///所有录像文件上传完毕
    xMP2P_MSG_RECORD_COMPLETED_BEFORE,
    ///设备信息同步反馈
    xMP2P_ACK_DEVICE_SYNC_BEFORE,
    ///设备OTA检查反馈
    xMP2P_ACK_OTA_BEFORE,      
    ///格式化SD卡结果反馈
    xMP2P_ACK_FORMAT_SD_CARD_BEFORE,  
    ///设置视频分辨率结果反馈
    xMP2P_ACK_SET_RESOLUTION_BEFORE = 1000,
    ///设置视频码率结果反馈
    xMP2P_ACK_SET_BITRATE_BEFORE,           
}; 

/**
 打印
 */
typedef NS_ENUM(NSInteger, XMStreamComCtrlLogSwitchType) {
    /// 默认打印
    XMStreamComCtrlLogTypeSwitchNone  = 0,
    /// 信令打印
    XMStreamComCtrlLogTypeSwitchCmd   = 1 << 0,
    /// 音频数据打印
    XMStreamComCtrlLogTypeSwitchAudio = 1 << 1,
    /// 视频数据打印
    XMStreamComCtrlLogTypeSwitchVideo = 1 << 2,
    /// 图片数据打印
    XMStreamComCtrlLogTypeSwitchPhoto = 1 << 3,
    /// 所有打印
    XMStreamComCtrlLogTypeSwitchAll   = XMStreamComCtrlLogTypeSwitchCmd | XMStreamComCtrlLogTypeSwitchAudio | XMStreamComCtrlLogTypeSwitchVideo | XMStreamComCtrlLogTypeSwitchPhoto,
};

/**
 设备连接参数
 */
typedef NS_ENUM(NSInteger, XMStreamConnectMode) {
    ///(低功耗推荐使用) 内网 1.5s -> P2P 5s -> dev relay -> server relay
    XMStreamConnectModeLow      = 1,   
    ///内网 1.5s -> P2P 3s -> dev relay -> server relay
    XMStreamConnectModeP2P      = 7,    
    ///兼容连接(网关鱼眼机推荐使用)
    XMStreamConnectModeDefault  = 14,
    ///只支持转发 dev relay -> server relay
    XMStreamConnectModeReley    = 30, 
    ///只支持内网(仅设备与手机在同一局域网时or直连时适用)
    XMStreamConnectModeLAN      = 63,  
    ///支持内外网(推荐使用)
    XMStreamConnectModeWAN      = 126,          
};


/**
 设备连接状态
 */
typedef NS_ENUM(NSInteger, XMStreamConnectStatus) {
    /// 未连接
    XMStreamConnectStatusDisConnect  = -1,
    /// 连接中
    XMStreamConnectStatusConnecting  = 0, 
    /// 已连接
    XMStreamConnectStatusConnected   = 1,      
};


/**
 连接设备时所需参数结构体
 */
struct XMConnectParameter {
    /// 设备DID
    __unsafe_unretained NSString *did;
    /// 设备SN（后期将用SN替换掉channel 2020.7.21）
    NSString *sn;
    /// 通道号
    NSInteger channel;
    /// 用户名
    __unsafe_unretained NSString *userName;
    /// 用户密码
    __unsafe_unretained NSString *userPassword;
    /// 指定服务器名称（有则填，可不填）
    NSString *serverString;
    /// 登录的用户id（有则填，可不填）
    NSString *usr_id;
};
typedef struct XMConnectParameter XMConnectParameter;

static inline XMConnectParameter XMConnectParameterMake(NSString *did,NSInteger channel,NSString *userName,NSString *userPassword)
{
    XMConnectParameter connectParm;
    connectParm.did = did;
    connectParm.channel = channel;
    connectParm.userName = userName;
    connectParm.userPassword = userPassword;
    return connectParm;
}

static inline XMConnectParameter XMConnectParameterMake2(NSString *did,NSInteger channel,NSString *userName,NSString *userPassword,NSString *serverString)
{
    XMConnectParameter connectParm;
    connectParm.did = did;
    connectParm.channel = channel;
    connectParm.userName = userName;
    connectParm.userPassword = userPassword;
    connectParm.serverString = serverString;
    return connectParm;
}


@interface XMStreamConstant : NSObject

/**
 根据错误码获取描述信息

 @param errorNo 错误码
 @return 描述信息
 */
+ (NSString *)xmHandlePPCSErrorNo:(int)errorNo;

/**
 返回结果过滤

 @param dic 源数据
 @return 错误数据返回nil
 */
+ (NSDictionary*)parseComplexCmdRet:(NSDictionary*)dic;

/**
 返回结果过滤

 @param dic 源数据
 @return 错误数据返回0
 */
+ (NSInteger)parseCommonCmdRet:(NSDictionary*)dic;

/**
 字典转json数据

 @param Cmd_dic 字典源数据
 @return json数据
 */
+ (NSData*)packTransparentCmd:(NSDictionary*)Cmd_dic;

/**
 json数据转字典

 @param ResultData json数据
 @param encoding 编码方式
 @return 字典
 */
+ (NSDictionary*)xmStreamConvertJson2Dictionary:(NSData*)ResultData encoding:(NSStringEncoding)encoding;

@end
