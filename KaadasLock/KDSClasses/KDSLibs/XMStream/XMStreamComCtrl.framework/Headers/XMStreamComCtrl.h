//
//  XMStreamComCtrl.h
//
#import <Foundation/Foundation.h>
#import "XMSteamConstant.h"
#import "ConfigDeviceSSID.h"
#import "SearchDID.h"
#import "RemotePushSubs.h"
#import "NetworkCtrl.h"

/**********************API Notes**************
 // 2.2.5-20191106
 添加连接指定服务器的入口
 
 // 2.2.5-20190626
 配网修复
 
 // 2.2.5-20190606
 授权流
 
 // 2.2.4-20190524
 修正读数据和处理视频数据不再串行执行
 
 // 2.2.3-20190521 
 修正对讲控制标志
 
 // 2.2.2-20190430
 修正连接参数错误，修复多设备同时看视频可能导致的同步队列休眠
 
 // 2.2.1-20190415
 优化调整获取录像缩略图处理线程及处理逻辑
 
 // 2.2.0-20190405
 调整组帧，处理包重复问题 1-2-1-2-3-4... | 1-2-3-4-3-4-5-6-7...
 
 // 2.2.0-20190403
 添加详尽注释，更换udpSocket
 
 // 2.1.9-20190325
 新增历史视频播放指定秒数
 
 // 2.1.8-20190123
 调整错误处理
 
 // 2.1.8-20190115
 过滤空字典数据
 
 // 2.1.8-20190108
 调整登陆错误处理
 
 // 2.1.8-20181228
 调整过滤器
 
 // 2.1.7-20181220
 适配设备类型为8的音视频收发
 
 // 2.1.7-20181211
 调整订阅内部实现,调整配网ssid和密码最大支持64字节
 
 // 2.1.6-20181130
 连接mode,声音杂音处理
 
 // 2.1.6-20181126
 新增根据token取消所有推送订阅
 
 // 2.1.5-20181120
 修改蓝牙配对密码接口，新增蓝牙信号接口
 
 // 2.1.5-20181116
 调整结构，新增XMSteamConstant类管理常量，新增修改蓝牙配对密码接口
 
 // 2.1.4-20180929
 打印连接参数,包调整
 
 // 2.1.4-20180926
 修复频繁调用错误码,未授权流
 
 // 2.1.4-20180925
 修复对讲数据写入逻辑，修复声光报警设置参数错误
 
 // 2.1.3-20180921
 修复声音播放,调整切换上级路由成功后自动断开连接，加锁
 
 // 2.1.2-20180910
 
 // 2.1.2-20180831
 修改实时与录像播放切换内部逻辑
 新增猫眼更换背景API(注：XMAgreementTypeBefore下有效)
 
 // 2.1.1-20180815
 优化图片传输
 
 // 2.1.1-20180802
 新增查询当前token所有已订阅的did
 新增猫眼配置WiFi接口
 
 // 2.1.0-20180727
 新增适配猫眼协议，如需使用，必须使用 initWithAgreementType:XMAgreementTypeBefore 初始化
 新增通知设备上传，OTA及同步服务器信息API (注：XMAgreementTypeBefore下有效)
 
 // 2.0.9-20180724
 新增猫眼配网适配
 调整灯控参数
 
 // 2.0.9-20180716
 修改订阅推送实现
 
 // 2.0.8-20180628
 修改移动侦测API实现
 
 // 2.0.7-20180613
 新增灯控、视频模式等信令API
 
 // 2.0.6-20180607
 配网增加server ip的适配
 修改onVideoData方法视频的分辨率表示枚举
 
 //2.0.5-201804023
 更换连接连接状态API
 更新设置移动侦测参数API
 添加获取/设置指示灯开关
 增加IP01API
 
 //2.0.4-20180327
 新增获取获取WiFi列表API
 
 //2.0.3-20180316
 新增获取当前网络状态
 修改onVideoData 方法  加上视频的分辨率
 
 //2.0.2-20180203
 新增查询订阅状态api
 
 //2.0.0-20171115 
 统一更换新协议头通讯
*********************************************/

@protocol StreamDelegate <NSObject>
@optional
#pragma mark - 音视频数据完整帧回调
/***********************************************************************************************
 *fuction:      onVideoData
 *
 *Description:  获取到H264视频帧,每当接收库接收一个完整帧数据回调一次
 *
 *Params:
 *              data             指向视频帧数据的buffer指针
 *              frameIndex       帧数
 *              length           视频帧的大小
 *              timestamp        帧时间戳
 *              isIFrame         关键帧标记
 *              VideoRes         视频分辨率（P2P_VIDEO_RESOLUTION）
 *              Rate             帧率
 *              steamType        流类型（0实时流 1录像流）
 *
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)onVideoData:(const void *)data andlength:(unsigned int)length
     andframeindex:(unsigned int)frameIndex
      andtimestamp:(long long)timestamp
       andisIFrame:(int)isIFrame
         VideoRes:(P2P_VIDEO_RESOLUTION)videoRes
         FrameRate:(int)Rate
         SteamType:(int)steamType;

/***********************************************************************************************
 *fuction:      onAudioData
 *
 *Description:  获取到音频帧,每当接收库接收一个完整帧数据回调一次 (G711.alaw,每次320 Bytes,采样率:8000,单通道,16位)
 *
 *Params:
 *              data             指向音频帧数据的buffer指针
 *              length           音频帧的大小(默认大小为320Bytes)
 *              timestamp        帧时间戳
 *
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)onAudioData:(const void *)data
         andlength:(unsigned int)length
      andtimestamp:(long long)timestamp;

/***********************************************************************************************
 *fuction:      OnPhotoDataRet
 *
 *Description:  设备推送过来的缩略图文件数据的回调返回
 *
 *Params:
 *                           channel            通道号
 *                           type               图片类型(0:I帧数据 1:JPEG)
 *                           size               图片大小
 *                           payload            图片数据
 *                           Date               图片记录的日期
 *                           time               图片记录的时间
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)OnPhotoDataRet:(NSInteger)channel
            Phototype:(NSInteger)type
            Photosize:(NSInteger)size
            PhotoData:(NSData*)payload
              RecDate:(NSString*)Date
              RecTime:(NSString*)time;


#pragma mark - 各命令返回的回调接口
/***********************************************************************************************
 *fuction:      StartVideoStreamProcResult
 *
 *Description:  打开视频流的回调返回相关信息
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                           result              操作执行结果(ok:成功，fail:失败)
 *----------------------------当result:ok------------------------------------------------
 *                           channel             当前通道号
 *                           videocodec          编码方式(1:H264)
 *                           videoframerate      帧率
 *                           videobitrate        码流(kbps)
 *                           videoheight         视频高度
 *                           videowidth          视频宽度
 *---------------------------当result:fail----------------------------------------------
 *                           errno:              错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                           errinfo:            错误描述的字符串
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)StartVideoStreamProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      StopVideoStreamProcResult
 *
 *Description:  关闭视频流的回调返回
 *
 *Params:                    
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *----------------------------当result:ok------------------------------------------------
 *                            channel            当前通道号
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)StopVideoStreamProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      StartAudioStreamProcResult
 *
 *Description:  打开音频的回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *----------------------------当result:ok------------------------------------------------
 *                           channel             当前通道号
 *                           audiobitper         音频位数(默认16)
 *                           audiochannel        通道数(默认单通道)
 *                           audiocodec          音频编码格式(参考P2P_AUDIO_CODEC枚举值)
 *                           audioframerate      音频帧率(默认25帧)
 *                           audiorate           音频采样率(默认8000 HZ)
 *---------------------------当result:fail----------------------------------------------
 *                           errno:              错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                           errinfo:            错误描述的字符串
 *
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)StartAudioStreamProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      StopAudioStreamProcResult
 *
 *Description:  关闭音频的回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result            操作执行结果(ok:成功，fail:失败)
 *----------------------------当result:ok------------------------------------------------
 *                            channel           摄像机通道号
 *---------------------------当result:fail----------------------------------------------
 *                            errno:            错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:          错误描述的字符串
 *
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)StopAudioStreamProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      StartTalkbackProcResult
 *
 *Description:  打开对讲的回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result            操作执行结果(ok:成功，fail:失败)
 *----------------------------当result:ok------------------------------------------------
 *                            channel           摄像机通道号
 *---------------------------当result:fail----------------------------------------------
 *                            errno:            错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:          错误描述的字符串
 *
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)StartTalkbackProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      StopTalkbackProcResult
 *
 *Description:  关闭对讲的回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result            操作执行结果(ok:成功，fail:失败)
 *----------------------------当result:ok------------------------------------------------
 *                            channel           摄像机通道号
 *---------------------------当result:fail----------------------------------------------
 *                            errno:            错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:          错误描述的字符串
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)StopTalkbackProcResult:(NSDictionary*)RetDic;
/***********************************************************************************************
 *fuction:      LogInDeviceProcResult
 *
 *Description:  登陆设备回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result            操作执行结果(ok:成功，fail:失败)
 *----------------------------当result:ok------------------------------------------------
 *                            channel           摄像机通道号
 *---------------------------当result:fail----------------------------------------------
 *                            errno:            错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:          错误描述的字符串
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)LogInDeviceProcResult:(NSDictionary*)RetDic DID:(NSString *)DID;

/***********************************************************************************************
 *fuction:      SearchRecordDateListProcResult
 *
 *Description:  搜索存在录像的日期回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result            操作执行结果(ok:成功，fail:失败)
 *----------------------------当result:ok------------------------------------------------
 *                            datenum           日期总数
 *                            datelist:(字典数组)          日期的列表
 *                                       Keys:
 *                                             date       日期值
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *             DID          设备DID
 *
 *Return:       NULL
 *
 *Note:         RetDic为nil表示获取状态失败
 *
 ***********************************************************************************************/
-(void)SearchRecordDateListProcResult:(NSDictionary*)RetDic;


/***********************************************************************************************
 *fuction:      SearchRecordFileListProcResult
 *
 *Description:  搜索存在录像的日期回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result            操作执行结果(ok:成功，fail:失败)
 *----------------------------当result:ok------------------------------------------------
 *                            channel           通道号 
 *                            recordfilenum     文件总数
 *                            recordfilelist:(字典数组)     文件信息列表
 *                                       Keys:
 *                                              file       文件名
 *                                              type       录像类型(参考P2P_RECORD_RESP枚举值)
 *                                              time       录像时长(单位:秒)
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *Note:         RetDic为nil表示获取状态失败
 *
 ***********************************************************************************************/
-(void)SearchRecordFileListProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      PlayDeviceRecordVideoProcResult
 *
 *Description:  回放SD卡上指定录像文件回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result            操作执行结果(ok:成功，fail:失败)
 *----------------------------当result:ok------------------------------------------------
 *                            channel           通道号
 *                            token             回放控制口令
 *---------------------------当result:fail----------------------------------------------
 *                            errno:            错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:          错误描述的字符串
 *Return:       NULL
 *
 *Note: token相当于对播放控制的句柄，在PlayRecViewCtrl方法中token参数就是使用才返回值
 *
 ***********************************************************************************************/
-(void)PlayDeviceRecordVideoProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      PlayRecViewCtrlProcResult
 *
 *Description:  控制录像回放数据传输回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *----------------------------当result:ok------------------------------------------------
 *                            channel            通道号
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)PlayRecViewCtrlProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      PlayRecOffsetCtrlProcResult
 *
 *Description:  控制录像回放播放指定秒数位置回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *----------------------------当result:ok------------------------------------------------
 *                            channel            通道号
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)PlayRecOffsetCtrlProcResult:(NSDictionary*)RetDic;


/***********************************************************************************************
 *fuction:      GetDeviceInformationProcResult
 *
 *Description:  获取摄像头和网关的基本信息回调返回
 *
 *Params:
 *              DID:        设备ID
 *              RetDic:(字典类型)
 *                      Keys:
 *                           result              操作执行结果(ok:成功，fail:失败)
 *----------------------------当result:ok------------------------------------------------
 *                           hardver             网关硬件版本号
 *                           softver             网关软件版本号
 *                           language            提示音的语言种类(参考P2P_LANGUAGE枚举值)
 *                           sdstatus            SD卡状态(0:未插卡 1:有SD卡)
 *                           signal              连接路由器信号强度(db值)
 *                           sn                  网关的序列号(预留)
 *                           cameranum           前端连接摄像机数目
 *                           dspsoftver          dsp芯片
 *                           wifisoftver         wifi芯片
 *                           mcusoftver          mcu芯片
 *                           cameralist(字典类型数组)         已配对前端摄像机信息的列表
 *                                      keys:
 *                                           channel         通道号
 *                                           online          在线状态(0:不在线,1:在线)
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)GetDeviceInformationProcResult:(NSDictionary*)RetDic DevId:(NSString*)DID;

/***********************************************************************************************
 *fuction:      GetCameraInfoProcResult
 *
 *Description:  获取摄像头信息的返回回调
 *
 *Params:
 *              DID:        设备ID
 *              RetDic:(字典类型)
 *                      Keys:
 *                        result            操作执行结果(ok:成功，fail:失败)
 *----------------------------当result:ok------------------------------------------------
 *                        channel           摄像机通道
 *                        audiobitper       音频位数(默认16位)
 *                        audiochannel      音频通道数(默认单通道)
 *                        audiocodec        音频编码格式(参考P2P_AUDIO_CODEC枚举值)
 *                        audioframerate    音频帧率
 *                        audiorate         音频采样率
 *                        videowidth        视频宽度
 *                        videoheight       视频高度
 *                        videoframerate    视频帧率
 *                        videocodec        视频编码类型(参考P2P_VIDEO_CODEC枚举值)
 *                        videobitrate      视频码流
 *                        type              摄像机类型(0:低功耗 1:外部电源供电)
 *                        enabel            摄像机加锁状态(参考P2P_LOCK_CTRL枚举值)
 *                        armingstatus      摄像机布防状态(参考P2P_ARMING枚举值)
 *                        battery           空载电压值(待机状态,电压值*10 例如50->5.0v)
 *                        batteryload       负载电压值(看视频状态，电压值*10 例如50->5.0v)
 *                        signal            信号强度增益值(单位:db)
 *                        hardver           硬件版本号
 *                        masterver         主控软件版本号
 *                        dspver            DSP软件版本号
 *                        id                设备序列号(预留)
 *                        micstatus         MIC的状态(0:关闭 1:开启)
 *                        speakerstatus     SPEAKER的状态(0:关闭 1:开启)
 *---------------------------当result:fail----------------------------------------------
 *                        errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                        errinfo:           错误描述的字符串
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)GetCameraInfoProcResult:(NSDictionary*)RetDic DevId:(NSString*)DID;

/***********************************************************************************************
 *fuction:      GetCameraBatteryProcResult
 *
 *Description:  获取电池的回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                          result             操作执行结果(ok:成功，fail:失败)
 *----------------------------当result:ok------------------------------------------------
 *                           channel           摄像头通道号
 *                           battery           空载电量值(电池电压值*10)
 *                           batteryload       负载电量值(电池电压值*10)
 *---------------------------当result:fail----------------------------------------------
 *                           errno:            错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                           errinfo:          错误描述的字符串
 *
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)GetCameraBatteryProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      GetCameraLockStatusProcResult
 *
 *Description:  获取关闭/打开摄像头的回调返回
 *
 *Params:
 *              Status          使能状态(参考P2P_LOCK_CTRL枚举值)
 *
 *              ChlNo           通道号
 *
 *              err             错误代码(0:成功，-1:错误)
 *
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)GetCameraLockStatusProcResult:(NSInteger)Status Channel:(NSInteger)ChlNo ErrorNo:(NSInteger)err;

/***********************************************************************************************
 *fuction:      LockCameraProcResult
 *
 *Description:  设置关闭/打开摄像头的回调返回
 *
 *Params:
 *              ErrorNo          错误代码(0:成功，-1:错误)
 *
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)LockCameraProcResult:(NSInteger)ErrorNo;

/***********************************************************************************************
 *fuction:      GetRecordFileCfgLenProcResult
 *
 *Description:  获取SD卡录像时长回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result            操作执行结果(ok:成功，fail:失败)
 *----------------------------当result:ok------------------------------------------------
 *                            alltimerecord     全时录像时长(秒)
 *                            alarmrecord       报警录像时长(秒)
 *                            capturerecord     抓拍录像时长(秒)
 *---------------------------当result:fail----------------------------------------------
 *                            errno:            错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:          错误描述的字符串
 *Return:       NULL
 *
 *Note:         当RetDic为nil表示获取失败
 *
 ***********************************************************************************************/
-(void)GetRecordFileCfgLenProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      SetRecFileLengthByTimeProcResult
 *
 *Description:  设置SD卡录像时长回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)SetRecFileLengthByTimeProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      DeleteRecFileofStorageProcResult
 *
 *Description:  删除在SD卡上指定录像或图片文件回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                           result              操作执行结果(ok:成功，failed:失败)
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)DeleteRecFileofStorageProcResult:(NSDictionary*)RetDic;
/***********************************************************************************************
 *fuction:      EnableRecordFullTimeProcResult
 *
 *Description:  开启或关闭全时录像开关回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                           result              操作执行结果(ok:成功，failed:失败)
 *---------------------------当result:ok----------------------------------------------
 *                           channel   通道号
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)EnableRecordFullTimeProcResult:(NSDictionary*)RetDic;
/***********************************************************************************************
 *fuction:      GetMotionDetectParamProcResult
 *
 *Description:  获取指定摄像机移动侦测参数回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
*                             channel            摄像头通道号
 *----------------------------当result:ok------------------------------------------------
 *                            startx             起始块X
 *                            starty             起始块y
 *                            endx               结束块x
 *                            endy               结束块y
 *                            sensitivity        灵敏度
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *
 *Return:       NULL
 *
 *Note: 电池供电摄像机暂时不支持此功能
 *
 ***********************************************************************************************/
-(void)GetMotionDetectParamProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      SetMotionDetectParamProcResult
 *
 *Description:  设置移动侦测参数
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result              操作执行结果(ok:成功，fail:失败)
 *----------------------------当result:ok------------------------------------------------
 *                            channel             通道号
 *---------------------------当result:fail----------------------------------------------
 *                            errno:              错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:            错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)SetMotionDetectParamProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      GetMotionDetectStatusProcResult
 *
 *Description:  获取指定摄像机移动侦测状态回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result            操作执行结果(ok:成功，fail:失败)
 *----------------------------当result:ok------------------------------------------------
 *                            channel           摄像头通道号
 *                            status            状态值(0:关闭 1:开启)
 *---------------------------当result:fail----------------------------------------------
 *                            errno:            错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:          错误描述的字符串
 *
 *Return:       NULL
 *
 *Note: 电池供电摄像机暂时不支持此功能
 *
 ***********************************************************************************************/
-(void)GetMotionDetectStatusProcResult:(NSDictionary*)RetDic;


/***********************************************************************************************
 *fuction:      GetArmingInfoProcResult
 *
 *Description:  获取布防撤防配置信息回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *----------------------------当result:ok------------------------------------------------
 *                            channel            摄像头通道号
 *                            type               布防撤防类型(0:关闭 1:开启 2:定时)
 *                            arminglist:(字典数组)         定时布防时间列表(一周的时间信息)
 *                                       Keys:
 *                                               weekday:    星期几(Mon...Sun)
 *                                               enable:     状态(0:关闭，1:开启)
 *                                               timelist:(字典数组)    时段列表(一天共有四个时段可设置)
 *                                                           Keys:
 *                                                                starttime:       开始时间
 *                                                                endtime:         结束时间
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)GetArmingInfoProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      SetArmingInfoProcResult
 *
 *Description:  设置布防/撤防回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *----------------------------当result:ok------------------------------------------------
 *                            channel            通道号
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)SetArmingInfoProcResult:(NSDictionary*)RetDic;


/***********************************************************************************************
 *fuction:      GetArmStatusProcResult
 *
 *Description:  获取摄像机当前布防撤防状态回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *----------------------------当result:ok------------------------------------------------
 *                            channel            摄像头通道号
 *                            status             状态值(0:撤防 1:布防)
 *
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)GetArmStatusProcResult:(NSDictionary*)RetDic;


/***********************************************************************************************
 *fuction:      GetMirrorModeProcResult
 *
 *Description:  获取视频翻转状态回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *----------------------------当result:ok------------------------------------------------
 *                            mirrormode         翻转的模式(参考P2P_VIDEO_MIRRORMODE数据结构)
 *                            channel            摄像头通道号
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)GetMirrorModeProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      SetMirrorModeProcResult
 *
 *Description:  设置画面翻转模式回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *----------------------------当result:ok------------------------------------------------
 *                            channel            通道号
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)SetMirrorModeProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      GetIRModeProcResult
 *
 *Description:  获取夜视模式回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *----------------------------当result:ok------------------------------------------------
 *                            channel            摄像头通道号
 *                            mode               当前红外的模式(参考P2P_IRMODE枚举值)
 *                            starttime          开始时间 秒 当mode为3时有此参数
 *                            endtime            结束时间 秒 当mode为3时有此参数
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)GetIRModeProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      SetIRModeProcResult
 *
 *Description:  设置红外灯开关模式回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *----------------------------当result:ok------------------------------------------------
 *                            channel            通道号
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)SetIRModeProcResult:(NSDictionary*)RetDic;


/***********************************************************************************************
 *fuction:      OpenCameraMicProcResult
 *
 *Description:     打开摄像头的mic
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *----------------------------当result:ok------------------------------------------------
 *                            channel            通道号
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)OpenCameraMicProcResult:(NSDictionary*)RetDic;


/***********************************************************************************************
 *fuction:           CloseCameraMicProcResult
 *
 *Description:     关闭摄像头的mic
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *----------------------------当result:ok------------------------------------------------
 *                            channel            通道号
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)CloseCameraMicProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      OpenCameraSpeakerProcResult
 *
 *Description:  打开摄像机的mic的回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *----------------------------当result:ok------------------------------------------------
 *                            channel            通道号
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)OpenCameraSpeakerProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      CloseCameraSpeakerProcResult
 *
 *Description:  关闭摄像机的mic的回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *----------------------------当result:ok------------------------------------------------
 *                            channel            通道号
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)CloseCameraSpeakerProcResult:(NSDictionary*)RetDic;


/***********************************************************************************************
*fuction:      GetUSBStatusProcResult
*
*Description:  获取摄像头的USB状态
*
*Params:
*              UsbStatus        USB状态 0:未插入 1:插入
*              Per                  电量百分比
*              err                   错误代码(0:成功，-1:错误)
*---------------------------当result:fail----------------------------------------------
*                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
*                            errinfo:           错误描述的字符串
*Return:       NULL
*
*
***********************************************************************************************/
-(void)GetUSBStatusProcResult:(NSInteger)UsbStatus  Battery:(NSInteger)Per ErrorNO:(NSInteger)err;


/***********************************************************************************************
 *fuction:      GetPIRSwitchProcResult
 *
 *Description:  获取红外报警器开关回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *----------------------------当result:ok------------------------------------------------
 *                            channel            摄像头通道号
 *                            ctrl               当前红外的模式(参考P2P_PIRCTRL枚举值)
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)GetPIRSwitchProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      EnablePIRProcResult
 *
 *Description:  设置红外报警器开关回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *----------------------------当result:ok------------------------------------------------
 *                            channel            通道号
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)EnablePIRProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      GetPRISensitivityProcResult
 *
 *Description:  获取摄像头的PRI灵敏度
 *
 *Params:
 *              Sensitivity          灵敏度
 *
 *              err                  错误代码(0:成功，-1:错误)
 *
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)GetPRISensitivityProcResult:(P2P_PIRSENSITIVITY)Sensitivity ErrorNO:(NSInteger)err;


/***********************************************************************************************
*fuction:      GetPIRValueProcResult
*
*Description:  设置红外报警器灵敏度回调返回
*
*Params:
*              RetDic:(字典类型)
*                      Keys:
*                            result             操作执行结果(ok:成功，fail:失败)
*---------------------------当result:ok----------------------------------------------
*                            channel            通道号
*---------------------------当result:fail----------------------------------------------
*                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
*                            errinfo:           错误描述的字符串
*Return:       NULL
*
*
***********************************************************************************************/
-(void)GetPIRValueProcResult:(NSDictionary *)RetDic;

/***********************************************************************************************
 *fuction:      SetPIRSensitivityProcResult
 *
 *Description:  设置红外报警器灵敏度回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:ok----------------------------------------------
 *                            channel            通道号
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)SetPIRSensitivityProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:       GetWiFiListInfoProcResult
 *
 *Description:   获取WiFi列表信息回调
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:ok----------------------------------------------
 *                       WiFi列表
 *                       "currentWifi":"zhijie",
 *                       "scan":true,
 *                       “wifiList”:[{“ssid”:”SoShare”,”signal”:”-32”,” security”:2},...]
 *                       ssid: WiFi名称
 *                        mac: MAC地址
 *                     signal: 信号强度  dB 
 *                 encryption: 加密方式  (参考P2P_WIFI_ENCRYPTION枚举值)
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)GetWiFiListInfoProcResult:(NSDictionary*)RetDic;
/***********************************************************************************************
 *fuction:      GetLEDCtrlProcResult
 *
 *Description:  获取指示灯状态回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:ok----------------------------------------------
 *                            ctrl: 0 开启  1 关闭
 *
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)GetLEDCtrlProcResult:(NSDictionary*)RetDic;
/***********************************************************************************************
 *fuction:      SetLEDCtrlProcResult
 *
 *Description:  设置指示灯状态回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:ok----------------------------------------------
 *
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)SetLEDCtrlProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      GetAlarmTimeProcResult
 *
 *Description:  获取告警推送时间回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:ok----------------------------------------------
 *                            alarmtime:         时间 s
 *
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)GetAlarmTimeProcResult:(NSDictionary*)RetDic;
/***********************************************************************************************
 *fuction:      SetAlarmTimeProcResult
 *
 *Description:  设置告警推送时间回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:ok----------------------------------------------
 *
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)SetAlarmTimeProcResult:(NSDictionary*)RetDic;
/***********************************************************************************************
 *fuction:      GetRecaiFlagProcResult
 *
 *Description:  获取音频录制标记回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:ok----------------------------------------------
 *                            recaiflag:         0不录制 1录制
 *
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)GetRecaiFlagProcResult:(NSDictionary*)RetDic;
/***********************************************************************************************
 *fuction:      SetRecaiFlagProcResult
 *
 *Description:  设置音频录制标记回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:ok----------------------------------------------
 *
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)SetRecaiFlagProcResult:(NSDictionary*)RetDic;
/***********************************************************************************************
 *fuction:      GetCircFlagProcResult
 *
 *Description:  获取循环存储标记回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:ok----------------------------------------------
 *                            circflag:         0关闭 1开启
 *
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)GetCircFlagProcResult:(NSDictionary*)RetDic;
/***********************************************************************************************
 *fuction:      SetCircFlagProcResult
 *
 *Description:  设置循环存储标记回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:ok----------------------------------------------
 *
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)SetCircFlagProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      GetSadthrModeProcResult
 *
 *Description:  获取移动侦测等级回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:ok----------------------------------------------
 *                            sadthr:         0关闭 1-7档
 *
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)GetSadthrModeProcResult:(NSDictionary*)RetDic;
/***********************************************************************************************
 *fuction:      SetSadthrModeProcResult
 *
 *Description:  设置移动侦测等级回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:ok----------------------------------------------
 *
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)SetSadthrModeProcResult:(NSDictionary*)RetDic;
/***********************************************************************************************
 *fuction:      GetAutoRecordFileTimeProcResult
 *
 *Description:  获取录像文件时长回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:ok----------------------------------------------
 *                            recordtime:        录像时间 秒
 *
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)GetAutoRecordFileTimeProcResult:(NSDictionary*)RetDic;
/***********************************************************************************************
 *fuction:      SetAutoRecordFileTimeProcResult
 *
 *Description:  设置录像文件时长回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:ok----------------------------------------------
 *
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)SetAutoRecordFileTimeProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      GetVideoContrastProcResult
 *
 *Description:  获取视频亮度对比度色调参数回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:ok----------------------------------------------
 *                            contrval : 对比度
 *                            hueval : 色调
 *                            lumaval :亮度
 *                            satuval :饱和度       
 *
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)GetVideoContrastProcResult:(NSDictionary*)RetDic;
/***********************************************************************************************
 *fuction:      SetVideoContrastProcResult
 *
 *Description:  设置视频亮度对比度色调参数回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:ok----------------------------------------------
 *
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)SetVideoContrastProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      GetRecModeProcResult
 *
 *Description:  获取录像模式回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:ok----------------------------------------------
 *                            recmode            0不录像1报警时录像2全天录像3定时录像 
 *                            starttime          开始时间 秒 当recmode为3时有此参数
 *                            endtime            结束时间 秒 当recmode为3时有此参数
 *
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)GetRecModeProcResult:(NSDictionary*)RetDic;
/***********************************************************************************************
 *fuction:      SetRecModeProcResult
 *
 *Description:  设置录像模式回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:ok----------------------------------------------
 *
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)SetRecModeProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      GetPlanAlarmProcResult
 *
 *Description:  获取告警日程标记回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:ok----------------------------------------------
 *                            mode :0 关闭  1 开启
 *                            starttime :s (秒) 注：当mode为1时有此参数
 *                            endtime  :s (秒) 注：当mode为1时有此参数   
 *
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)GetPlanAlarmProcResult:(NSDictionary*)RetDic;
/***********************************************************************************************
 *fuction:      SetPlanAlarmProcResult
 *
 *Description:  设置告警日程标记回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:ok----------------------------------------------
 *
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)SetPlanAlarmProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      GetIfOSDDisplayProcResult
 *
 *Description:  获取osd显示开关参数回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:ok----------------------------------------------
 *                            mode :0 显示  1 隐藏
 *
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)GetIfOSDDisplayProcResult:(NSDictionary*)RetDic;
/***********************************************************************************************
 *fuction:      SetIfOSDDisplayProcResult
 *
 *Description:  设置告警日程标记回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:ok----------------------------------------------
 *
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)SetIfOSDDisplayProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      GetDeviceConnectedSessionNumProcResult
 *
 *Description:  获取网关会话连接数回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:ok----------------------------------------------
 *                            current: 当前连接数
 *                            max: 最大支持连接数
 *
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)GetDeviceConnectedSessionNumProcResult:(NSDictionary*)RetDic;
/***********************************************************************************************
 *fuction:      GetAllTimeRecordParamProcResult
 *
 *Description:  获取全时录像参数回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:ok----------------------------------------------
 *                            channel: 摄像机通道
 *                            ctrlcmd: 详见   P2P_ALLTIME_RECORD_CTRL
 *
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)GetAllTimeRecordParamProcResult:(NSDictionary*)RetDic;
/***********************************************************************************************
 *fuction:      GetPlanRecordInfoProcResult
 *
 *Description:  获取计划录像参数回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:ok----------------------------------------------
 * 
 e.g.json
 {
 "VideoRecClose":true,"    
 VideoRecordList":[{"ChannelOpen":false,
                      "StreamLvl":0,
                   "IsAllTheTime":false,
                        "ArmTime":[
                         {"WeekDay":"Sun","IsEnable":true,"StartTime":"000000","EndTime":"235959"},
                         {"WeekDay":"Mon","IsEnable":true,"StartTime":"000000","EndTime":"235959"},
                         {"WeekDay":"Tue","IsEnable":true,"StartTime":"000000","EndTime":"235959"},
                         {"WeekDay":"Wed","IsEnable":true,"StartTime":"000000","EndTime":"235959"},
                         {"WeekDay":"Thu","IsEnable":true,"StartTime":"000000","EndTime":"235959"},
                         {"WeekDay":"Fri","IsEnable":true,"StartTime":"000000","EndTime":"235959"},
                         {"WeekDay":"Sat","IsEnable":true,"StartTime":"000000","EndTime":"235959"}
                                  ]
                  }]
 }
 *                          VideoRecClose:计划录像开关
 *                          VideoRecordList:计划录像列表
 *                          ChannelOpen:通道开关
 *                          StreamLvl:码流类型 0主码流 1次码流
 *                          IsAllTheTime:是否全选 0不全选1全选
 *                          ArmTime:记录录像日期 (最大支持7天)
 *                          WeekDay:星期几
 *                          IsEnable:当天录像开关
 *                          StartTime:开始时间
 *                          EndTime:结束时间
 *
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)GetPlanRecordInfoProcResult:(NSDictionary*)RetDic;
/***********************************************************************************************
 *fuction:      SetPlanRecordInfoProcResult
 *
 *Description:  设置计划录像参数回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:ok----------------------------------------------
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)SetPlanRecordInfoProcResult:(NSDictionary*)RetDic;
/***********************************************************************************************
 *fuction:      SetResolutionProcResult
 *
 *Description:  设置视频分辨率回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:ok----------------------------------------------
 *                            channel            通道号
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)SetResolutionProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      SetBitRateProcResult
 *
 *Description:  设置视频码流回调返回  当agreement 为 before 时 命令结果回调请实现onpush for before
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:ok----------------------------------------------
 *                            channel            通道号
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)SetBitRateProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      GetDoorBellInfoProcResult
 *
 *Description:  获取门铃信息回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:ok----------------------------------------------
 *                            channel            通道号             
 *                            hardver            门铃硬件版本号
 *                            softver            门铃软件版本号
 *                            type               门铃类型(0低功耗)(1带电源)
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)GetDoorBellInfoProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      ChangeDevicePasswordProcResult
 *
 *Description:  修改设备密码回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)ChangeDevicePasswordProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      ConfigWIFIProcResult
 *
 *Description:  配置网关的wifi连接的回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)ConfigWIFIProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      GetSDCardInformationProcResult
 *
 *Description:  获取SD卡容量信息回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result            操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:ok----------------------------------------------
 *                            sdstatus          SD插入状态(0:无卡，1:有卡,2:坏卡,3:需要格式化)
 *                            totolsize         总容量 (单位:MB)
 *                            usedsize          已使用空间
 *                            freesize          空闲空间
 *---------------------------当result:fail----------------------------------------------
 *                            errno:            错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:          错误描述的字符串
 *
 *Return:       NULL
 *
 *Note:         当插入SD卡之后才能获取到totolsize,usedsize,freesize信息;当RetDic为nil表示获取失败
 *
 ***********************************************************************************************/
-(void)GetSDCardInformationProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      FormatSDCardProcResult
 *
 *Description:  格式化SD卡回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                           result              操作执行结果(ok:成功，fail:失败)
 *                           当AgreementType 为 before 时 仅代表发送成功，结果请实现onpush for before回调
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *Note:         格式化卡后会重新初始化网关服务程序
 *
 ***********************************************************************************************/
-(void)FormatSDCardProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      SyncDevicetimeProcResult
 *
 *Description:  同步设备时间回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)SyncDevicetimeProcResult:(NSDictionary*)RetDic;
/***********************************************************************************************
 *fuction:      GetDeviceTimeProcResult
 *
 *Description:  获取设备时间回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:ok----------------------------------------------
 *                              
 *                           sec:UTC时间戳秒
 *                           usec:UTC时间戳毫秒
 *                           zone:时区值
 *                           istwelve:夏令时(保留字段，设备目前固定为0，即赞不支持夏令时)
 *
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)GetDeviceTimeProcResult:(NSDictionary*)RetDic;
/***********************************************************************************************
 *fuction:      RebootDeviceProcResult
 *
 *Description:  重启设备回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功,failed:失败)
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)RebootDeviceProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      FactoryDeviceProcResult
 *
 *Description:  恢复出厂回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功 fail:失败)
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)FactoryDeviceProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      ManualSnapshotProcResult
 *
 *Description:  摄像机抓拍图片回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功 fail:失败)
 *---------------------------当result:ok----------------------------------------------
 *                            channel            通道号
 *                            Date               图片记录的日期
 *                            time               图片记录的时间
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *Note:         只是返回抓拍缩略图的记录信息，用户可以使用FetchRecThumbProcResult来主动获取相应图片
 *
 ***********************************************************************************************/
-(void)ManualSnapshotProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      ManualRecordVideoProcResult
 *
 *Description:  摄像机抓拍录像回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功 fail:失败)
 *---------------------------当result:ok----------------------------------------------
 *                            channel            通道号
 *                            Date               图片记录的日期
 *                            time               图片记录的时间
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *Note:         当用户发停止抓拍录像动作(P2P_CAPTURE_VIDEO_CLOSE)的返回时候才会有Date，time字段的信息；
 *              而且只是返回抓拍视频的记录信息。用户可以使用FetchRecThumbProcResult来主动获取相应图片。
 *
 ***********************************************************************************************/
-(void)ManualRecordVideoProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      FetchRecThumbProcResult
 *
 *Description:  开始获取指定通道指定录像文件缩略图设备命令执行的结果回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result            操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:ok----------------------------------------------
 *                            channel           通道号
 *---------------------------当result:fail----------------------------------------------
 *                            errno:            错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:          错误描述的字符串
 *Return:       NULL
 *
 *Note:         此回调只是通知用户设备在执行读取缩略图的命令的执行结果状态，真实图片数据的获取通过OnPhotoDataRet回调的来得到的
 *
 ***********************************************************************************************/
-(void)FetchRecThumbProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      StopFetchRecThumbProcResult
 *
 *Description:  停止传输缩略图数据并清空处理队列回调返回
 *
 *Params:
 *              ErrorNo          错误代码(0:成功，-1:错误)
 *
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)StopFetchRecThumbProcResult:(NSInteger)ErrorNo;

/***********************************************************************************************
 *fuction:      ClearCameraMatchInfoProcResult
 *
 *Description:  清除摄像机和网关的配对信息回调返回
 *
 *Params:
 *              ErrorNo        错误代码(0:成功，-1:错误)
 *
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)ClearCameraMatchInfoProcResult:(NSInteger)ErrorNo;

/***********************************************************************************************
 *fuction:      SetToneLanguageProcResult
 *
 *Description:  设置网关提示音语言回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，fail:失败)
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *Return:       NULL
 *
 *
 ***********************************************************************************************/
-(void)SetToneLanguageProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      GetUpdateStatusProcResult
 *
 *Description:  获取网关升级状态回调返回
 *
 *Params:
 *              RetDic:(字典类型)
 *                      Keys:
 *                            result             操作执行结果(ok:成功，failed:失败)
 *---------------------------当result:ok----------------------------------------------
 *                            status             当前升级状态(参考P2P_UPDATE_STATUS的枚举类型的值）
 *                            loaddata           已下载数据量(当status == P2P_UPDATE_LOADING，才会有此值)
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *
 *Return:       NULL
 *
 *Note:         RetDic为nil表示获取状态失败
 ***********************************************************************************************/
-(void)GetUpdateStatusProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      NotifyGateWayNewVersionProcResult
 *
 *Description:  通知网关有新版本信息回调返回
 *
 *Params:
 *                            result             操作执行结果(ok:成功，failed:失败)
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)NotifyGateWayNewVersionProcResult:(NSDictionary*)RetDic;
/***********************************************************************************************
 *fuction:      ResetCameraParamProcResult
 *
 *Description:  恢复摄像机默认参数回调返回
 *
 *Params:
 *                            result             操作执行结果(ok:成功，failed:失败)
 *---------------------------当result:ok----------------------------------------------
 *                            channel            通道号
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)ResetCameraParamProcResult:(NSDictionary*)RetDic;


/***********************************************************************************************
 *fuction:      GetCorridorLightsModeProcResult
 *
 *Description:  获取走廊灯控模式回调返回
 *
 *Params:
 *                            result             操作执行结果(ok:成功，failed:失败)
 *---------------------------当result:ok----------------------------------------------
 *                            mode               0 人走灯灭 1 人走灯暗 2 灯常亮
 *                            time               灯亮时间
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)GetCorridorLightsModeProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      SetCorridorLightsModeProcResult
 *
 *Description:  设置走廊灯控模式回调返回
 *
 *Params:
 *                            result             操作执行结果(ok:成功，failed:失败)
 *---------------------------当result:ok----------------------------------------------
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)SetCorridorLightsModeProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      GetCorridorLightsSwitchProcResult
 *
 *Description:  获取获取走廊灯开关状态回调返回
 *
 *Params:
 *                            result             操作执行结果(ok:成功，failed:失败)
 *---------------------------当result:ok----------------------------------------------
 *                            status             
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)GetCorridorLightsSwitchProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      SetCorridorLightsSwitchProcResult
 *
 *Description:  设置设置走廊灯打开/关闭状态回调返回
 *
 *Params:
 *                            result             操作执行结果(ok:成功，failed:失败)
 *---------------------------当result:ok----------------------------------------------
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)SetCorridorLightsSwitchProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      GetCameraVideoModeProcResult
 *
 *Description:  获取视频模式回调返回
 *
 *Params:
 *                            result             操作执行结果(ok:成功，failed:失败)
 *---------------------------当result:ok----------------------------------------------
 *                            mode               0 ~ 5 
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)GetCameraVideoModeProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      SetCameraVideoModeProcResult
 *
 *Description:  设置视频模式回调返回
 *
 *Params:
 *                            result             操作执行结果(ok:成功，failed:失败)
 *---------------------------当result:ok----------------------------------------------
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *
 *Return:       NULL
 
 * ***********************************************************************************************/
-(void)SetCameraVideoModeProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      GetCameraClarityProcResult
 *
 *Description:  获取视频清晰度回调返回
 *
 *Params:
 *                            result             操作执行结果(ok:成功，failed:失败)
 *---------------------------当result:ok----------------------------------------------
 *                            mode              0 超清 1 高清  2 流畅
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *
 *Return:       NULL
 
 * ***********************************************************************************************/
-(void)GetCameraClarityProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      SetCameraClarityProcResult
 *
 *Description:  设置视频清晰度回调返回
 *
 *Params:
 *                            result             操作执行结果(ok:成功，failed:失败)
 *---------------------------当result:ok----------------------------------------------
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *
 *Return:       NULL
 
 * ***********************************************************************************************/
-(void)SetCameraClarityProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      GetCameraVideoAreaPTZProcResult
 *
 *Description:  获取视频区域PTZ参数回调返回 (仅在模式5（四分屏）下生效)
 *
 *Params:
 *                            result             操作执行结果(ok:成功，failed:失败)
 *---------------------------当result:ok----------------------------------------------
 *                            horizontal         水平(-180~180)
 *                            vertical           垂直(-135~135)
 *                            zoom               缩放(1-100)
 *                            step               移动速度(0-3)
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *
 *Return:       NULL
 
 * ***********************************************************************************************/
-(void)GetCameraVideoAreaPTZProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      SetCameraVideoAreaPTZProcResult
 *
 *Description:  设置视频区域PTZ参数回调返回 (仅在模式5（四分屏）下生效)
 *
 *Params:
 *                            result             操作执行结果(ok:成功，failed:失败)
 *---------------------------当result:ok----------------------------------------------
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *
 *Return:       NULL
 
 * ***********************************************************************************************/
-(void)SetCameraVideoAreaPTZProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      GetDeviceAudioVolProcResult
 *
 *Description:  获取设备喇叭音量回调返回
 *
 *Params:
 *                            result             操作执行结果(ok:成功，failed:失败)
 *---------------------------当result:ok----------------------------------------------
 *                            vol                当前设备喇叭音量
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *
 *Return:       NULL
 
 * ***********************************************************************************************/
-(void)GetDeviceAudioVolProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      onSetDeviceAudioVolProcResult
 *
 *Description:  设置设备喇叭音量回调返回
 *
 *Params:
 *                            result             操作执行结果(ok:成功，failed:失败)
 *---------------------------当result:ok----------------------------------------------
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *
 *Return:       NULL
 
 * ***********************************************************************************************/
-(void)onSetDeviceAudioVolProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      GetAlarmSoundStatusProcResult
 *
 *Description:  获取警报声音状态回调返回
 *
 *Params:
 *                            result             操作执行结果(ok:成功，failed:失败)
 *---------------------------当result:ok----------------------------------------------
 *                            ChlNo              通道号 
 *                            status             开关状态  0 关闭 /  1 开启             
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *
 *Return:       NULL
 
 * ***********************************************************************************************/
-(void)GetAlarmSoundStatusProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      SetAlarmSoundStatusProcResult
 *
 *Description:  设置警报声音状态回调返回
 *
 *Params:
 *                            result             操作执行结果(ok:成功，failed:失败)
 *---------------------------当result:ok----------------------------------------------
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *
 *Return:       NULL
 
 * ***********************************************************************************************/
-(void)SetAlarmSoundStatusProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      NotifyDeviceSyncFromServiceProcResult  
 *
 *Description:  同步服务器信息回调返回
 *
 *Params:
 *                            result             操作执行结果(ok:成功，failed:失败)
 *---------------------------当result:ok----------------------------------------------
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *
 *Return:       NULL
 
 * ***********************************************************************************************/
-(void)NotifyDeviceSyncFromServiceProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      SetCameraBackgroundModeProcResult  
 *
 *Description:  发送设置设备背景图与安防模式回调返回
 *
 *Params:
 *                            result             操作执行结果(ok:成功，failed:失败)
 *---------------------------当result:ok----------------------------------------------
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *
 *Return:       NULL
 
 * ***********************************************************************************************/
-(void)SetCameraBackgroundModeProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      SendChangeBluetoothPassWordProcResult  
 *
 *Description:  发送设置蓝牙配对密码回调返回
 *
 *Params:
 *                            result             操作执行结果(ok:成功，failed:失败)
 *---------------------------当result:ok----------------------------------------------
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *
 *Return:       NULL
 
 * ***********************************************************************************************/
-(void)SendChangeBluetoothPassWordProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
 *fuction:      SetFrameRateProcResult  
 *
 *Description:  发送设置帧率回调返回
 *
 *Params:
 *                            result             操作执行结果(ok:成功，failed:失败)
 *---------------------------当result:ok----------------------------------------------
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *
 *Return:       NULL
 
 * ***********************************************************************************************/
-(void)SetFrameRateProcResult:(NSDictionary*)RetDic;


/***********************************************************************************************
 *fuction:      GetFrameRateProcResult  
 *
 *Description:  发送设置帧率回调返回
 *
 *Params:
 *                            result             操作执行结果(ok:成功，failed:失败)
 *---------------------------当result:ok----------------------------------------------
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *
 *Return:       NULL
 
 * ***********************************************************************************************/
-(void)GetFrameRateProcResult:(NSDictionary*)RetDic;



/***********************************************************************************************
*fuction:      SetRegisterResult  
*
*Description:  发送基站注册回调返回
*
*Params:
*                            result             操作执行结果(ok:成功，failed:失败)
*---------------------------当result:ok----------------------------------------------
*---------------------------当result:fail----------------------------------------------
*                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
*                            errinfo:           错误描述的字符串
*
*Return:       NULL

* ***********************************************************************************************/
-(void)SetGatewayRegisterResult:(NSDictionary*)RetDic;


/***********************************************************************************************
*fuction:      onSetAlarmVolumeProcResult
*
*Description:  发送设置报警声音量大小回调返回
*
*Params:
*                            result             操作执行结果(ok:成功，failed:失败)
*---------------------------当result:ok----------------------------------------------
*---------------------------当result:fail----------------------------------------------
*                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
*                            errinfo:           错误描述的字符串
*
*Return:       NULL

* ***********************************************************************************************/
-(void)onSetAlarmVolumeProcResult:(NSDictionary*)RetDic;


/***********************************************************************************************
*fuction:      onSetCameraScreenBrightnessProcResult  
*
*Description:  发送设置屏幕亮度回调返回
*
*Params:
*                            result             操作执行结果(ok:成功，failed:失败)
*---------------------------当result:ok----------------------------------------------
*---------------------------当result:fail----------------------------------------------
*                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
*                            errinfo:           错误描述的字符串
*
*Return:       NULL

* ***********************************************************************************************/
-(void)onSetCameraScreenBrightnessProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
*fuction:      onGetDeviceSceneModeProcResult
*
*Description:       发送获取场景模式
*
*Params:
*                            result             操作执行结果(ok:成功，failed:失败)
*---------------------------当result:ok----------------------------------------------
*                             Mode             当前模式
*                            scenearray     各个摄像头的配置
*---------------------------当result:fail----------------------------------------------
*                            Mode:            -1
*                            scenearray:    nil
*
*Return:       NULL

* ***********************************************************************************************/
-(void)onGetDeviceSceneModeProcResult:(NSInteger)Mode SceneArray:(NSArray*)scenearray;


/***********************************************************************************************
*fuction:      onSetDeviceSceneModeProcResult
*
*Description:  设置场景模式返回
*
*Params:
*                            result             操作执行结果(ok:成功，failed:失败)
*---------------------------当result:ok----------------------------------------------
*---------------------------当result:fail----------------------------------------------
*                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
*                            errinfo:           错误描述的字符串
*
*Return:       NULL

* ***********************************************************************************************/
-(void)onSetDeviceSceneModeProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
*fuction:      onSetCameraSwitchProcResult
*
*Description:  设置摄像机的开关
*
*Params:
*                              result             操作执行结果(ok:成功，failed:失败)
*---------------------------当result:ok----------------------------------------------
*---------------------------当result:fail----------------------------------------------
*                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
*                            errinfo:           错误描述的字符串
*
*Return:       NULL

* ***********************************************************************************************/
-(void)onSetCameraSwitchProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
*fuction:      onSetCameraWorkModeProcResult
*
*Description:  设置摄像机工作模式, 录像时长和再次触发间隔命令组合
*
*Params:
*                              result             操作执行结果(ok:成功，failed:失败)
*---------------------------当result:ok----------------------------------------------
*---------------------------当result:fail----------------------------------------------
*                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
*                            errinfo:           错误描述的字符串
*
*Return:       NULL

* ***********************************************************************************************/
-(void)onSetCameraWorkModeProcResult:(NSDictionary*)RetDic;


/***********************************************************************************************
*fuction:      onSetPresButtonLedProcResult  
*
*Description:  设置门铃指示灯状态(摄像机)返回
*
*Params:
*                            result             操作执行结果(ok:成功，failed:失败)
*---------------------------当result:ok----------------------------------------------
*---------------------------当result:fail----------------------------------------------
*                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
*                            errinfo:           错误描述的字符串
*
*Return:       NULL

* ***********************************************************************************************/
-(void)onSetPresButtonLedProcResult:(NSDictionary*)RetDic;


/***********************************************************************************************
*fuction:      onGetPresButtonLedProcResult  
*
*Description:  获取门铃指示灯状态(摄像机)返回
*
*Params:
*                            result             操作执行结果(ok:成功，failed:失败)
*---------------------------当result:ok----------------------------------------------
*---------------------------当result:fail----------------------------------------------
*                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
*                            errinfo:           错误描述的字符串
*
*Return:       NULL

* ***********************************************************************************************/
-(void)onGetPresButtonLedProcResult:(NSDictionary*)RetDic;


/***********************************************************************************************
*fuction:      onGetCameraTamperAlarmProcResult  
*
*Description:  获取门铃强拆报警状态/控制返回
*
*Params:
*                            result             操作执行结果(ok:成功，failed:失败)
*---------------------------当result:ok----------------------------------------------
*---------------------------当result:fail----------------------------------------------
*                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
*                            errinfo:           错误描述的字符串
*
*Return:       NULL

* ***********************************************************************************************/
-(void)onGetCameraTamperAlarmProcResult:(NSDictionary*)RetDic;


/***********************************************************************************************
*fuction:      onSetCameraTamperAlarmProcResult  
*
*Description:  设置门铃强拆报警状态/控制返回
*
*Params:
*                            result             操作执行结果(ok:成功，failed:失败)
*---------------------------当result:ok----------------------------------------------
*---------------------------当result:fail----------------------------------------------
*                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
*                            errinfo:           错误描述的字符串
*
*Return:       NULL

* ***********************************************************************************************/
-(void)onSetCameraTamperAlarmProcResult:(NSDictionary*)RetDic;


/***********************************************************************************************
*fuction:      onGetBaseStationToneProcResult  
*
*Description:  发送获取基站铃声回调返回
*
*Params:
*                            result             操作执行结果(ok:成功，failed:失败)
*---------------------------当result:ok----------------------------------------------
*---------------------------当result:fail----------------------------------------------
*                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
*                            errinfo:           错误描述的字符串
*
*Return:       NULL

* ***********************************************************************************************/
-(void)onGetBaseStationToneProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
*fuction:      onSetBaseStationToneProcResult  
*
*Description:  发送设置基站铃声回调返回
*
*Params:
*                            result             操作执行结果(ok:成功，failed:失败)
*---------------------------当result:ok----------------------------------------------
*---------------------------当result:fail----------------------------------------------
*                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
*                            errinfo:           错误描述的字符串
*
*Return:       NULL

* ***********************************************************************************************/
-(void)onSetBaseStationToneProcResult:(NSDictionary*)RetDic;


/***********************************************************************************************
*fuction:      onGetCameraToneProcResult  
*
*Description:  发送获取门铃铃声回调返回
*
*Params:
*                            result             操作执行结果(ok:成功，failed:失败)
*---------------------------当result:ok----------------------------------------------
*---------------------------当result:fail----------------------------------------------
*                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
*                            errinfo:           错误描述的字符串
*
*Return:       NULL

* ***********************************************************************************************/
-(void)onGetCameraToneProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
*fuction:      onSetCameraToneProcResult  
*
*Description:  发送设置门铃音量大小回调返回
*
*Params:
*                            result             操作执行结果(ok:成功，failed:失败)
*---------------------------当result:ok----------------------------------------------
*---------------------------当result:fail----------------------------------------------
*                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
*                            errinfo:           错误描述的字符串
*
*Return:       NULL

* ***********************************************************************************************/
-(void)onSetCameraToneProcResult:(NSDictionary*)RetDic;


/***********************************************************************************************
*fuction:      onSetCameraVolumeProcResult  
*
*Description:  发送设置门铃音量大小回调返回
*
*Params:
*                            result             操作执行结果(ok:成功，failed:失败)
*---------------------------当result:ok----------------------------------------------
*---------------------------当result:fail----------------------------------------------
*                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
*                            errinfo:           错误描述的字符串
*
*Return:       NULL

* ***********************************************************************************************/
-(void)onSetCameraVolumeProcResult:(NSDictionary*)RetDic;


/***********************************************************************************************
*fuction:      onSetCameraAIFilterProcResult
*
*Description:  发送设置门铃AI过滤器回调返回
*
*Params:
*                            result             操作执行结果(ok:成功，failed:失败)
*---------------------------当result:ok----------------------------------------------
*---------------------------当result:fail----------------------------------------------
*                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
*                            errinfo:           错误描述的字符串
*
*Return:       NULL

* ***********************************************************************************************/
-(void)onSetCameraAIFilterProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
*fuction:      onGetCameraVolumeProcResult  
*
*Description:  发送获取门铃音量大小回调返回
*
*Params:
*                            result             操作执行结果(ok:成功，failed:失败)
*---------------------------当result:ok----------------------------------------------
*---------------------------当result:fail----------------------------------------------
*                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
*                            errinfo:           错误描述的字符串
*
*Return:       NULL

* ***********************************************************************************************/
-(void)onGetCameraVolumeProcResult:(NSDictionary*)RetDic;


/***********************************************************************************************
*fuction:      onGetCameraAIFilterProcResult
*
*Description:  发送获取门铃AI过滤器回调返回
*
*Params:
*                            result             操作执行结果(ok:成功，failed:失败)
*---------------------------当result:ok----------------------------------------------
*---------------------------当result:fail----------------------------------------------
*                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
*                            errinfo:           错误描述的字符串
*
*Return:       NULL

* ***********************************************************************************************/
-(void)onGetCameraAIFilterProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
*fuction:      onGetCameraSignalProcResult  
*
*Description:  发送获取门铃信号强度回调返回
*
*Params:
*                            result             操作执行结果(ok:成功，failed:失败)
*---------------------------当result:ok----------------------------------------------
*---------------------------当result:fail----------------------------------------------
*                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
*                            errinfo:           错误描述的字符串
*
*Return:       NULL

* ***********************************************************************************************/
-(void)onGetCameraSignalProcResult:(NSDictionary*)RetDic;

/***********************************************************************************************
*fuction:      onAddCameraProcResult  
*
*Description:  添加基站摄像机结果回调
*
*Params:
*                            result             操作执行结果(ok:成功，failed:失败)
*---------------------------当result:ok----------------------------------------------
                "ssid":"基站热点名称",
                "pwd":"连接基站热点密码"
*---------------------------当result:fail----------------------------------------------
*                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
*                            errinfo:           错误描述的字符串
*
*Return:       NULL

* ***********************************************************************************************/
- (void)onAddCameraProcResult:(NSDictionary *)RetDic;

/***********************************************************************************************
*fuction:      onSetSpotlightProcResult  
*
*Description:  设置补光灯开关和亮度
*
*Params:
*                            result             操作执行结果(ok:成功，failed:失败)
*---------------------------当result:ok----------------------------------------------

*---------------------------当result:fail----------------------------------------------
*                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
*                            errinfo:           错误描述的字符串
*
*Return:       NULL

* ***********************************************************************************************/
- (void)onSetSpotlightProcResult:(NSDictionary *)RetDic;

/***********************************************************************************************
*fuction:      onMqttCtrlProcResult
*
*Description:  MQTT控制结果回调
 
 ====   注意   ====
 这个结果只是命令下发的结果，代表设备有收到这个命令，不是MQTT登录或者退出登录的结果。
 MQTT的结果在代理方法 OnPushCmdRet:DevId: 中设备主动回调，示例代码如下：
 - (void)OnPushCmdRet:(NSDictionary *)dic DevId:(NSString *)DID {
     if (dic) {
         int CmdId = [[dic objectForKey:@"CmdId"] intValue];
         if (CmdId == xMP2P_MSG_MQTT_CTRL_RESULT) {
             NSDictionary *payload = [dic objectForKey:@"payload"];
             if (payload.count > 0) {
                 if ([[payload objectForKey:@"result"] isEqualToString:@"ok"]) {
                     // 成功 "ctrl":1
                 } else {
                     // 失败
                     // errno 参考对应错误.1011：MQTT登录失败，1012：MQTT登出失败，1013：MQTT登出失败，有任务正在执行
                 }
             }
         }
     }
 }
*
*Params:
*                            result             操作执行结果(ok:成功，failed:失败)
*---------------------------当result:ok----------------------------------------------

*---------------------------当result:fail----------------------------------------------
*                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
*                            errinfo:           错误描述的字符串
*
*Return:       NULL

* ***********************************************************************************************/
- (void)onMqttCtrlProcResult:(NSDictionary *)RetDic;

/***********************************************************************************************
 *fuction:      SendCustomCommandIDProcResult  
 *
 *Description:  发送自定义信令数据回调返回
 *
 *Params:
 *                            result             操作执行结果(ok:成功，failed:失败)
 *---------------------------当result:ok----------------------------------------------
 *---------------------------当result:fail----------------------------------------------
 *                            errno:             错误码(参考P2P_ERRCODE_TYPE枚举值)
 *                            errinfo:           错误描述的字符串
 *
 *Return:       NULL
 
 * ***********************************************************************************************/
-(void)SendCustomCommandIDProcResult:(NSDictionary*)RetDic;


#pragma mark -  设备主动通知消息
@optional
/***********************************************************************************************
 *fuction:      OnConnectfailed
 *
 *Description:  通知用户当前连接的异常断开
 *
 *Params:
 *              ErrorNo          错误代码(参考Framework中的PPCS_Error.h)
 *
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)OnConnectfailed:(NSInteger)ErrorNo;
/***********************************************************************************************
 *fuction:      OnConnectfailed
 *
 *Description:  通知用户当前连接的异常断开
 *
 *Params:
 *              ErrorNo          错误代码(参考Framework中的PPCS_Error.h)
 *              DID              DID
 *
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)OnConnectfailed:(NSInteger)ErrorNo DID:(NSString *)DID;

/***********************************************************************************************
 *fuction:      OnReconnectSuccessful
 *
 *Description:  通知用户异常断开后重新连接成功
 *
 *Params:       NULL
 *
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)OnReconnectSuccessful;





/***********************************************************************************************
 *fuction:      OnPushCmdRet
 *
 *Description:  设备主动通知用户的相关消息(电池电量,SD卡状态...)
 *
 *Params:       
 *               DevId:                      返回信息的设备DID
 *               dic (字典类型)
 *                      CmdId               通知的命令(参考P2P_CMD_PUSH枚举值)
 *                      payload(字典类型)     通知的信息内容
 *                                  keys:
 *                                          channel       通道号
 *Return:       NULL
 *
 *Note:         当命令为xMP2P_MSG_SDNEEDFORMAT时payload为nil
 *
 ***********************************************************************************************/
-(void)OnPushCmdRet :(NSDictionary*)dic DevId:(NSString*)DID;

/***********************************************************************************************
 *fuction:      OnPushCmdRet
 *
 *Description:  设备主动通知用户的相关消息(电池电量,SD卡状态...)
 *
 *Params:       
 *               DevId:                      返回信息的设备DID
 *               dic (字典类型)
 *                      CmdId               通知的命令(参考P2P_CMD_PUSH枚举值)
 *                      payload(字典类型)     通知的信息内容
 *                                  keys:
 *                                          channel       通道号
 *               xMP2P_MSG_VOLTAGE_BEFORE =0,            电池电压(例:80代表0.8V) //锂电池返回电池电量
 *               xMP2P_MSG_LOW_POWER_BEFORE,             电量低
 *               xMP2P_MSG_RECORD_PLAYEND_BEFORE = 10,   回放结束
                                                         “file_size”:2048
                                                         文件大小（byte）
                                                         “file_time”:100057    
                                                         视频开始录制的时间戳(ms)
                                                         
                                                         “video_time”:180
                                                         录像时长（s）
                                                         “video_md5”:”DFD6137FA1245D14E3S1D2F412540012”
                                                         视频数据的32位MD5值
                                                         “audio_md5”:”DFD6137FA1245D14E3S1D2F412540012”
                                                         音频数据的32位MD5值
 
 *               xMP2P_MSG_RECORD_PLAYSTART_BEFORE,      回放开始
 *               xMP2P_MSG_RECORD_COMPLETED_BEFORE,      所有录像文件上传完毕
                                                         “SD_status”:1
                                                         “error_file_num”:2
                                                         “error_file_list”:
                                                         [{
                                                         “directory”:”20161212”,        //日期
                                                         “file_name”:”081115”,            //文件名
                                                         “error_info”:0//0：文件打开失败 1：文件数据出错
                                                         },
                                                         {
                                                         “directory”:”20161212”,            //日期
                                                         “file_name”:”091118”,            //文件名
                                                         “error_info”:1//0：文件打开失败 1：文件数据出错
                                                         }]

 *               xMP2P_ACK_DEVICE_SYNC_BEFORE,           设备信息同步反馈 
 *               xMP2P_ACK_OTA_BEFORE,                   设备OTA检查反馈
                                                         0:有新版本，开始升级
                                                         1：已经是最新版本
                                                         2：检测失败
                                                         3：低电量
 *               xMP2P_ACK_FORMAT_SD_CARD_BEFORE,        格式化SD卡结果反馈
                                                         0： 成功
                                                         1： 失败
                                                         2： SD卡已损坏
                                                         3： SD卡不存在
 *               xMP2P_ACK_SET_RESOLUTION_BEFORE = 1000, 设置视频分辨率结果反馈
 *               xMP2P_ACK_SET_BITRATE_BEFORE,           设置视频码率结果反馈
 *Return:       NULL
 *
 *Note:         当命令为xMP2P_MSG_SDNEEDFORMAT时payload为nil
 *
 ***********************************************************************************************/
- (void)OnPushForBeforeCmdRet:(NSDictionary*)dic DevId:(NSString*)DID;

@end

#pragma mark - XMStreamComCtrl
@interface XMStreamComCtrl : NSObject

@property(nonatomic, weak) id<StreamDelegate> delegate;
//当前协议类型
@property(nonatomic,assign) XMAgreementType curAgreementType;

@property(nonatomic,strong,readonly) NSNumber *devType;

#pragma mark - 初始化 & 基本信息
/**
 *  SDK 版本信息
 *
 *  @return SDK版本号
 */
+ (NSString *)sdkVersion;

/***********************************************************************************************
 *fuction:      initAPI
 *
 *Description:  库初始化
 *
 *Params:       InitString          由尚云提供的库初始化字符
 *
 *Return:       NULL
 *
 ***********************************************************************************************/
+ (int) initAPI:(char*)InitString;

/***********************************************************************************************
 *fuction:      deinitAPI
 *
 *Description:  库释放
 *
 *Params:       NULL
 *
 *Return:       NULL
 *
 ***********************************************************************************************/
+ (void) deinitAPI;
/***********************************************************************************************
*fuction:      currentNetworkInfo 
*
*Description:  当前网络信息
*
*Params:       NULL
*
*Return:       st_PPCS_NetInfo
* 
*Note:         注意必须先initAPI
*
***********************************************************************************************/
+ (st_PPCS_NetInfo)currentNetworkInfo;
/***********************************************************************************************
 *fuction:      initWithAgreementType
 *
 *Description:  自定义初始化XMStreamComCtrl
 *
 *Params:
 *
 *Return:       XMStreamComCtrl 类对象
 *
 ***********************************************************************************************/
- (instancetype)initWithAgreementType:(XMAgreementType)agreementType;
/***********************************************************************************************
 *fuction:      SetComDefaultChannel
 *
 *Description:  修改默认设置的音视频流的通讯通道
 *
 *Params:
 *              ChlNo               通道号
 *
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)SetComDefaultChannel:(NSInteger)ChlNo;

/***********************************************************************************************
 *fuction:      GetComDefaultChannel
 *
 *Description:  获取默认设置的音视频流的通讯通道
 *
 *Params:
 *              ChlNo               通道号
 *
 *Return:       NULL
 *
 ***********************************************************************************************/
-(NSInteger)GetComDefaultChannel;

- (void)takeAction;

#pragma mark - 设备连接 & 连接状态
/***********************************************************************************************
*fuction:      StartConnectDevice
*
*Description:  创建与设备的连接会话(每个新连接是与设备具体通道绑定的)
*
*Params:
*              connectMode         连接的模式，注意当前网络状态去填写
*              connectParam        传参结构体
*
*Return:       当前连接会话的句柄
*
***********************************************************************************************/
- (void)StartConnectWithMode:(XMStreamConnectMode)mode connectParam:(XMConnectParameter)connectParam completeBlock:(void(^)(XMStreamComCtrl *steamComCtrl,NSInteger resultCode ))completeBlock;


/***********************************************************************************************
*fuction:      StartConnectDevice
*
*Description:  创建与设备的连接会话(每个新连接是与设备具体通道绑定的)
*
*Params:
*              connectMode         连接的模式，注意当前网络状态去填写
*              connectParam        传参结构体
*
*Return:       当前连接会话的句柄
*
***********************************************************************************************/
-(NSInteger)StartConnectWithStreamMode:(XMStreamConnectMode)connectMode connectParam:(XMConnectParameter)connectParam;

/***********************************************************************************************
 *fuction:      StartConnectDevice
 *
 *Description:  创建与设备的连接会话(每个新连接是与设备具体通道绑定的)
 *
 *Params:
 *              connectMode         连接的模式，注意当前网络状态去填写
 *              DID                 设备的ID
 *              ChlNo               通道号(目前设备最多支持4个通道，从0开始)
 *              name                连接认证的用户名
 *              pwd                 连接认证的密码
 *
 *Return:       当前连接会话的句柄
 *
 ***********************************************************************************************/
-(NSInteger)StartConnectWithStreamMode:(XMStreamConnectMode)connectMode
                             DeviceDID:(NSString*)DID
                             DeviceChl:(NSInteger)ChlNo
                               UsrName:(NSString*)name
                                Usrpwd:(NSString*)pwd;

/***********************************************************************************************
 *fuction:      StartConnectDevice
 *
 *Description:  创建与设备的连接会话(每个新连接是与设备具体通道绑定的)
 *
 *Params:
 *              DID                 设备的ID
 *              ChlNo               通道号(目前设备最多支持4个通道，从0开始)
 *              name                连接认证的用户名
 *              pwd                 连接认证的密码
 *
 *Return:       当前连接会话的句柄
 *
 ***********************************************************************************************/
-(NSInteger)StartConnectDevice:(NSString*)DID
                     DeviceChl:(NSInteger)ChlNo
                       UsrName:(NSString*)name
                        Usrpwd:(NSString*)pwd;



/***********************************************************************************************
 *fuction:      StopConnectDevice
 *
 *Description:  关闭当前连接的会话
 *
 *Params:       NULL
 *
 *Return:       NULL
 *
 ***********************************************************************************************/
-(void)StopConnectDevice;

/***********************************************************************************************
 *fuction:      streamConnectStatus
 *
 *Description:  当前连接状态
 *
 *Params:       NULL
 *
 *Return:       参照XMStreamConnectStatus枚举值
 *
 ***********************************************************************************************/
- (XMStreamConnectStatus)streamConnectStatus;

/***********************************************************************************************
 *fuction:      GetseesionInfo
 *
 *Description:  获取当前连接会话的描述信息
 *
 *Params:       NULL
 *
 *Return:       pinfo        指向会话描述信息的指针
 *
 ***********************************************************************************************/
-(void)GetseesionInfo:(st_PPCS_Session*)pinfo;
#pragma mark - 发送各命令接口
/***********************************************************************************************
 *fuction:      LogInDevice
 *
 *Description:  发送登陆设备命令（查设备类型）
 *
 *Params:       
 *               strUsr        设备名
 *               strPwr        密码
 *               strUsrid      用户id
 *
 *Return:       发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)LogInDevice:(NSString*)strUsr password:(NSString*)strPwr user_id:(NSString*)strUsrId;

/***********************************************************************************************
 *fuction:      StartVideoStream
 *
 *Description:  发送打开视频流命令
 *
 *Params:       NULL
 *
 *Return:       发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)StartVideoStream:(NSInteger)Mode;

/***********************************************************************************************
 *fuction:      StopVideoStream
 *
 *Description:  发送关闭视频流命令
 *
 *Params:       NULL
 *
 *Return:       发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)StopVideoStream;

/***********************************************************************************************
 *fuction:      StartAudioStream
 *
 *Description:  发送打开音频流命令
 *
 *Params:       NULL
 *
 *Return:       发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)StartAudioStream;

/***********************************************************************************************
 *fuction:      StartAudioStream
 *
 *Description:  发送关闭音频流命令
 *
 *Params:       NULL
 *
 *Return:       发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)StopAudioStream;

/***********************************************************************************************
 *fuction:      StartTalkback
 *
 *Description:  发送打开对讲流命令
 *
 *Params:       NULL
 *
 *Return:       发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)StartTalkback;

/***********************************************************************************************
 *fuction:      StopTalkback
 *
 *Description:  发送关闭对讲流命令
 *
 *Params:       NULL
 *
 *Return:       发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)StopTalkback;


/***********************************************************************************************
 *fuction:      SendTalkbackAudioData
 *
 *Description:  把手机上的对讲音频数据发给设备(G711.alaw,每次320 Bytes,采样率:8000,单通道,16位)
 *
 *Params:
 *               data        音频数据
 *               time        时间戳(暂时可以填写)
 *               length      需下发的音频数据长度
 *
 *Return:       已经成功下发了数据的长度
 *
 ***********************************************************************************************/
-(int)SendTalkbackAudioData:(NSData*)data time:(NSInteger)time length:(NSInteger)length;

/***********************************************************************************************
*fuction:      SendTalkbackAudioData
*
*Description:  把手机上的对讲音频数据发给设备(每次320Bytes,aac则采样率:16000,G711.alaw则采样率:8000，单通道,16位)
*
*Params:
*               data        音频数据
*               time        时间戳(暂时可以填写)
*               length      需下发的音频数据长度
*               enableAAC   设备当前是否支持AAC
*
*Return:       已经成功下发了数据的长度
*
***********************************************************************************************/
-(int)SendTalkbackAudioData:(NSData*)data time:(NSInteger)time length:(NSInteger)length enableAAC:(BOOL)enableAAC;

/***********************************************************************************************
 *fuction:       SearchRecordDateList
 *
 *Description:   发送搜索SD卡中存在录像的日期命令
 *
 *Params:        NULL
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)SearchRecordDateList;


/***********************************************************************************************
 *fuction:       SearchRecordFileList
 *
 *Description:   发送搜索指定日期指定通道指定类型的录像文件或抓拍图片命令
 *
 *Params:        Type          搜索类型(参考P2P_RECORD_SEARCH枚举值)
 *               date          搜索日期 格式：yyyyMMdd
 *               channel       搜索的通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSUInteger)SearchRecordFileList:(NSInteger)Type TimeStr:(NSString*)date Channel:(NSInteger)ChlNo;

/***********************************************************************************************
 *fuction:       PlayDeviceRecordVideo
 *
 *Description:   发送回放指定录像文件命令
 *
 *Params:
 *               DateStr      文件日期
 *               fname        文件名
  *              recordType   回放传输类型（参考P2P_RECORD_PLAY_TYPE枚举值）
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)PlayDeviceRecordVideo:(NSString*)fName DateStr:(NSString*)date RecordType:(P2P_RECORD_PLAY_TYPE)recordType;

/***********************************************************************************************
 *fuction:       PlayRecViewCtrl
 *
 *Description:   发送控制录像回放数据传输回调返回命令
 *
 *Params:
 *               token        控制口令
 *               Id           控制命令字
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *Note:          token参数使用PlayDeviceRecordVideoProcResult回调返回结果中的token字段
 *
 ***********************************************************************************************/
-(NSInteger)PlayRecViewCtrl:(NSUInteger)token CmdId:(P2P_RECORD_PLAY_CTRL)Id;

/***********************************************************************************************
 *fuction:       PlayRecViewCtrl
 *
 *Description:   发送控制录像回放播放指定秒数位置回调返回命令
 *
 *Params:
 *               token        控制口令
 *               offsetTime   播放录像的第几秒（当秒数大于等于文件总时长时，文件会直接结束，此后当前控制口令失效）
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *Note:          token参数使用PlayDeviceRecordVideoProcResult回调返回结果中的token字段
 *
 ***********************************************************************************************/
-(NSInteger)PlayRecOffsetCtrl:(NSUInteger)token offsetTime:(NSUInteger)offsetTime;

/***********************************************************************************************
 *fuction:       GetDeviceInformation
 *
 *Description:   发送获取摄像头和网关的基本信息命令
 *
 *Params:        NULL
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)GetDeviceInformation;

/***********************************************************************************************
 *fuction:       GetCameraInfo
 *
 *Description:   发送获取摄像头的基本信息命令
 *
 *Params:        ChlNo          摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *Note:          发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)GetCameraInfo:(NSInteger)ChlNo;


/***********************************************************************************************
 *fuction:         OpenCameraMic
 *
 *Description:   发送打开摄像头的mic
 *
 *Params:        ChlNo          摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *Note:          发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)OpenCameraMic:(NSInteger)ChlNo;



/***********************************************************************************************
 *fuction:         CloseCameraMic
 *
 *Description:   发送打开摄像头的mic
 *
 *Params:        ChlNo          摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *Note:          发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)CloseCameraMic:(NSInteger)ChlNo;


/***********************************************************************************************
 *fuction:         OpenCameraSpeaker
 *
 *Description:   发送打开摄像头的speaker
 *
 *Params:        ChlNo          摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *Note:          发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)OpenCameraSpeaker:(NSInteger)ChlNo;



/***********************************************************************************************
 *fuction:         CloseCameraSpeaker
 *
 *Description:   发送打开摄像头的speaker
 *
 *Params:        ChlNo          摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *Note:          发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)CloseCameraSpeaker:(NSInteger)ChlNo;


/***********************************************************************************************
 *fuction:       GetCameraBattery
 *
 *Description:   发送获取电池版本摄像头电量命令
 *
 *Params:        ChlNo          摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)GetCameraBattery:(NSInteger)ChlNo;



/***********************************************************************************************
 *fuction:       GetUSBStatus
 *
 *Description:   发送获取摄像机当前USB状态命令
 *
 *Params:        ChlNo          摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)GetUSBStatus:(NSInteger)ChlNo;


/***********************************************************************************************
 *fuction:       GetCameraLockStatus
 *
 *Description:   发送获取摄像头锁定的状态命令
 *
 *Params:
 *               ChlNo       通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)GetCameraLockStatus:(NSInteger)ChlNo;

/***********************************************************************************************
 *fuction:       LockCamera
 *
 *Description:   发送开启或关闭摄像头命令
 *
 *Params:
 *               CtrFlag     锁定/解锁(参考P2P_LOCK_CTRL枚举值)
 *
 *               ChlNo       通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)LockCamera:(P2P_LOCK_CTRL)CtrFlag Channel:(NSInteger)ChlNo;

/***********************************************************************************************
 *fuction:       GetRecordFileCfgLen
 *
 *Description:   发送获取SD卡录像时长命令
 *
 *Params:        NULL
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)GetRecordFileCfgLen;

/***********************************************************************************************
 *fuction:       SetRecFileLengthByTime
 *
 *Description:   发送设置SD卡录像时长命令
 *
 *Params:
 *               AllTimeRecSEC       全时类录像时长(单位:秒 30~300)
 *               AlarmRecSEC         报警类录像时长(单位:秒 10~60)
 *               CaptureSEC          手动抓拍类录像时长(单位:秒 10~300)
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)SetRecFileLengthByTime:(NSInteger)AllTimeRecSEC
                       AlarmRecLen:(NSInteger)AlarmRecSEC
                     CaptureRecLen:(NSInteger)CaptureSEC;


/***********************************************************************************************
 *fuction:       DeleteRecFileofStorage
 *
 *Description:   发送删除在SD卡上指定录像或图片文件命令
 *
 *Params:
 *               Date         文件日期
 *               fname        文件名
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)DeleteRecFileofStorage:(NSString*)Date FileName:(NSString*)fname;

/***********************************************************************************************
 *fuction:       DeleteRecFileofStorage
 *
 *Description:   发送删除在SD卡上指定录像或图片文件命令
 *
 *Params:
 *               Date         文件日期
 *               files      文件名数组
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)DeleteRecFileofStorage:(NSString*)Date FileNames:(NSArray*)files;
/***********************************************************************************************
 *fuction:       EnableRecordFullTime
 *
 *Description:   发送开启或关闭全时录像 [外接电源状态有效]
 *
 *Params:
 *               enable       YES/NO 开启/关闭
 *               ChlNo        通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
- (NSInteger)EnableRecordFullTime:(BOOL)enable Channel:(NSInteger)ChlNo;
/***********************************************************************************************
 *fuction:       GetMotionDetectParam
 *
 *Description:   发送获取指定摄像机移动侦测参数命令
 *
 *Params:        ChlNo          摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)GetMotionDetectParam:(NSInteger)ChlNo;

/***********************************************************************************************
 *fuction:       SetMotionDetectParam
 *
 *Description:   发送设置移动侦测参数命令
 *
 *Params:
 *               frameWidth          当前通道分辨率宽(设备)
 *               frameHight          当前通道分辨率高
 *               Pos_StartX          起始块X
 *               Pos_StartY          起始块Y
 *               Pos_EndX            结束X
 *               Pos_EndY            结束Y
 *               Sens                灵敏度(0~100)
 *               ChlNo               通道号
  *              enable              开关(0关 1开)
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)SetMotionDetectParamWithFrameWidth:(NSInteger)frameWidth 
                                    FrameHight:(NSInteger)frameHight
                                        StartX:(NSInteger)Pos_StartX
                                        StartY:(NSInteger)Pos_StartY
                                          EndX:(NSInteger)Pos_EndX
                                          EnxY:(NSInteger)Pos_EndY
                                   Sensitivity:(NSInteger)Sens
                                       Channel:(NSInteger)ChlNo 
                                        Enable:(BOOL)enable;

/***********************************************************************************************
 *fuction:       GetMotionDetectParam
 *
 *Description:   发送获取指定摄像机移动侦测状态命令
 *
 *Params:        ChlNo          摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *Note:          目前暂不支持
 ***********************************************************************************************/
-(NSInteger)GetMotionDetectStatus:(NSInteger)ChlNo;


/***********************************************************************************************
 *fuction:       GetArmingInfo
 *
 *Description:   发送获取布防撤防配置信息命令
 *
 *Params:        ChlNo          摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)GetArmingInfo:(NSInteger)ChlNo;

/***********************************************************************************************
 *fuction:       SetArmingInfo
 *
 *Description:   发送设置报警布防/撤防命令
 *
 *Params:
 *                ArmingMode         布防/撤防模式 (0:撤防,1:布防,2:定时布防)
 *                tArray(字典数组)     定时时间列表(一周七天的)
 *                               keys:
 *                                   weekday                星期几(@"Sun",@"Mon",@"Tue",@"Wed",@"Thu",@"Fri",@"Sat")
 *                                   enable                 开启关闭(0:撤防 1:布防)
 *                                   timelist:(字典数组)      时段列表(一天总共可以4个时段)
 *                                               keys:
 *                                                     starttime         开始时间(格式:@"000000")
 *                                                     endtime           结束时间(格式:@"235959")
 *                ChlNo              摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *Note: 切记是tArray的数组数量为7天，timelist为4个时段
 *
 ***********************************************************************************************/
-(NSInteger)SetArmingInfo:(NSInteger)ArmingMode  TimerList:(NSArray*)tArray Channel:(NSInteger)ChlNo;

/***********************************************************************************************
 *fuction:       GetArmStatus
 *
 *Description:   发送获取摄像机当前布防撤防状态命令
 *
 *Params:        ChlNo          摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)GetArmStatus:(NSInteger)ChlNo;

/***********************************************************************************************
 *fuction:       GetMirrorMode
 *
 *Description:   发送获取视频翻转状态命令
 *
 *Params:        ChlNo          摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)GetMirrorMode:(NSInteger)ChlNo;

/***********************************************************************************************
 *fuction:       SetMirrorMode
 *
 *Description:   发送设置视频画面翻转模式命令
 *
 *Params:
 *               mode               画面模式
 *               ChlNo              摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *Note:          如果在看视频时设置翻转需要等待有视频数据之后再调用此函数。
 *
 ***********************************************************************************************/
-(NSInteger)SetMirrorMode:(P2P_VIDEO_MIRRORMODE)mode Channel:(NSInteger)ChlNo;

/***********************************************************************************************
 *fuction:       GetIRMode
 *
 *Description:   发送获取夜视模式命令
 *
 *Params:        ChlNo          摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)GetIRMode:(NSInteger)ChlNo;

/***********************************************************************************************
 *fuction:       SetIRMode
 *
 *Description:   发送设置红外灯开关模式命令
 *
 *Params:
 *               mode               红外灯模式
 *               ChlNo              摄像头通道号
 *               startTime          开始时间（mode为3时填写,其他可填0）
 *               endTime            结束时间（mode为3时填写,其他可填0）
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)SetIRMode:(P2P_IRMODE)mode Channel:(NSInteger)ChlNo StartTime:(NSInteger)startTime EndTime:(NSInteger)endTime;

/***********************************************************************************************
*fuction:       SetIRMode
*
*Description:   发送设置红外灯开关模式命令
*
*Params:
*               mode               夜视模式
*               ChlNo              摄像头通道号
*
*Return:        发送错误代码(参考Framework中的PPCS_Error.h)
*
***********************************************************************************************/
-(NSInteger)SetIRMode:(XMIRMode)mode Channel:(NSInteger)ChlNo;

/***********************************************************************************************
 *fuction:       GetPIRSwitch
 *
 *Description:   发送获取红外报警器开关命令
 *
 *Params:        ChlNo          摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)GetPIRSwitch:(NSInteger)ChlNo;

/***********************************************************************************************
 *fuction:       EnablePIRCtrl
 *
 *Description:   发送设置红外报警器开关命令
 *
 *Params:
 *               enable             开关状态(FALSE:关闭 TRUE:开启)
 *               ChlNo              摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)EnablePIR:(BOOL)enable Channel:(NSInteger)ChlNo;

/***********************************************************************************************
 *fuction:       GetPRISensitivity
 *
 *Description:   发送获取摄像头的红外敏度命令
 *
 *Params:
 *               ChlNo          摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *Note:          默认使用创建连接(StartConnectDevice)时使用的通道号对应的摄像头
 ***********************************************************************************************/
-(NSInteger)GetPRISensitivity:(NSInteger)ChlNo;

/***********************************************************************************************
 *fuction:       SetPIRSensitivity
 *
 *Description:   发送设置红外报警器灵敏度命令
 *
 *Params:
 *                Senitivity         灵敏度
 *                ChlNo              摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)SetPIRSensitivity:(P2P_PIRSENSITIVITY)Senitivity Channel:(NSInteger)ChlNo;


/***********************************************************************************************
 *fuction:        SetPIRValue
 *
 *Description:   发送设置红外报警器灵敏度命令
 *
 *Params:
 *                value              灵敏度(0-6)
 *                ChlNo              摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)SetPIRValue:(NSInteger)value Channel:(NSInteger)ChlNo;


/***********************************************************************************************
 *fuction:       GetWiFiListInfo
 *
 *Description:   发送获取WiFi列表信息
 *
 *Params:        ChlNo          摄像头通道号
 *               Scan          true: 返回附近wifi列表,false:不扫描附近wifi
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)GetWiFiListInfo:(NSInteger)ChlNo Scan:(BOOL)scan;


/***********************************************************************************************
 *fuction:       GetLEDCtrl
 *
 *Description:   发送获取指示灯状态
 *
 *Params:        ChlNo          摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)GetLEDCtrl:(NSInteger)ChlNo;
/***********************************************************************************************
 *fuction:       SetLEDCtrl
 *
 *Description:   发送设置指示灯状态
 *
 *Params:        ChlNo          摄像头通道号
 *               enable         YES/NO 开启/关闭
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)SetLEDCtrl:(NSInteger)ChlNo Enable:(BOOL)enable;
/***********************************************************************************************
 *fuction:       GetAlarmTime
 *
 *Description:   获取告警推送时间
 *
 *Params:        ChlNo          摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)GetAlarmTime:(NSInteger)ChlNo;
/***********************************************************************************************
 *fuction:       SetAlarmTime
 *
 *Description:   设置告警推送时间
 *
 *Params:        ChlNo          摄像头通道号
 *               time           时间 秒
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)SetAlarmTime:(NSInteger)ChlNo Time:(NSInteger)time;
/***********************************************************************************************
 *fuction:       GetRecaiFlag
 *
 *Description:   获取音频录制标记
 *
 *Params:        ChlNo          摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)GetRecaiFlag:(NSInteger)ChlNo;
/***********************************************************************************************
 *fuction:       SetRecaiFlag
 *
 *Description:   设置音频录制标记
 *
 *Params:        ChlNo          摄像头通道号
 *               enable         YES/NO 录制/不录制
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)SetRecaiFlag:(NSInteger)ChlNo Enable:(BOOL)enable;
/***********************************************************************************************
 *fuction:       GetCircFlag
 *
 *Description:   获取循环存储标记
 *
 *Params:        ChlNo          摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)GetCircFlag:(NSInteger)ChlNo;
/***********************************************************************************************
 *fuction:       SetCircFlag
 *
 *Description:   设置循环存储标记
 *
 *Params:        ChlNo          摄像头通道号
 *               enable         YES/NO 开启/关闭
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)SetCircFlag:(NSInteger)ChlNo Enable:(BOOL)enable;
/***********************************************************************************************
 *fuction:       GetAlarmTime
 *
 *Description:   获取移动侦测等级
 *
 *Params:        ChlNo          摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)GetSadthrMode:(NSInteger)ChlNo;
/***********************************************************************************************
 *fuction:       SetAlarmTime
 *
 *Description:   设置移动侦测等级
 *
 *Params:        ChlNo          摄像头通道号
 *               mode           移动侦测等级 0-7  0关闭
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)SetSadthrMode:(NSInteger)ChlNo Mode:(NSInteger)mode;
/***********************************************************************************************
 *fuction:       GetAutoRecordFileTime
 *
 *Description:   获取录像文件时长
 *
 *Params:        ChlNo          摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)GetAutoRecordFileTime:(NSInteger)ChlNo;
/***********************************************************************************************
 *fuction:       SetAutoRecordFileTime
 *
 *Description:   设置录像文件时长
 *
 *Params:        ChlNo          摄像头通道号
 *               timeLen        录像时长  秒  60-3600
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)SetAutoRecordFileTime:(NSInteger)ChlNo TimeLenght:(NSInteger)timeLen;
/***********************************************************************************************
 *fuction:       GetDeviceConnectedSessionNum
 *
 *Description:   发送获取网关会话连接数
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
/***********************************************************************************************
 *fuction:       GetVideoContrast
 *
 *Description:   获取视频亮度对比度色调参数
 *
 *Params:        ChlNo          摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)GetVideoContrast:(NSInteger)ChlNo;
/***********************************************************************************************
 *fuction:       SetVideoContrast
 *
 *Description:   设置视频亮度对比度色调参数
 *
 *Params:        ChlNo          摄像头通道号
 *               contrval       对比度
 *               hueval         色调
 *               lumaval        亮度
 *               satuval        饱和度
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)SetVideoContrast:(NSInteger)ChlNo Contrval:(NSInteger)contrval Hueval:(NSInteger)hueval Lumaval:(NSInteger)lumaval Satuval:(NSInteger)satuval;

/***********************************************************************************************
 *fuction:       GetRecMode
 *
 *Description:   获取录像模式
 *
 *Params:        ChlNo          摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)GetRecMode:(NSInteger)ChlNo;
/***********************************************************************************************
 *fuction:       SetRecMode
 *
 *Description:   设置录像模式
 *
 *Params:        ChlNo          摄像头通道号
 *               mode           0不录像 1报警时录像 2全天录像 3定时录像
 *               startTime      开始时间（mode为3时填写,其他可填0）
 *               endTime        结束时间（mode为3时填写,其他可填0）
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)SetRecMode:(NSInteger)ChlNo Mode:(NSInteger)mode StartTime:(NSInteger)startTime EndTime:(NSInteger)endTime;

/***********************************************************************************************
 *fuction:       GetPlanAlarm
 *
 *Description:   获取告警日程标记
 *
 *Params:        ChlNo          摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)GetPlanAlarm:(NSInteger)ChlNo;
/***********************************************************************************************
 *fuction:       SetPlanAlarm
 *
 *Description:   设置告警日程标记
 *
 *Params:        ChlNo          摄像头通道号
 *               enable         是否开启
 *               startTime      开始时间s (秒) 注：当enable为YES时此参数有效
 *               endTime        结束时间s (秒) 注：当enable为YES时此参数有效
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)SetPlanAlarm:(NSInteger)ChlNo Enable:(BOOL)enable StartTime:(NSInteger)startTime EndTime:(NSInteger)endTime;

/***********************************************************************************************
 *fuction:       GetIfOSDDisplay
 *
 *Description:   获取osd显示开关参数
 *
 *Params:        ChlNo          摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)GetIfOSDDisplay:(NSInteger)ChlNo;
/***********************************************************************************************
 *fuction:       SetPlanAlarm
 *
 *Description:   设置osd显示开关参数
 *
 *Params:        ChlNo          摄像头通道号
 *               isOn           是否隐藏 YES/NO 显示/隐藏
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)SetIfOSDDisplay:(NSInteger)ChlNo isOn:(BOOL)isOn;

/// 设置OSD显示开关
/// @param ChlNo 摄像头通道号
/// @param mode 显示模式
- (NSInteger)SetOSDDisplayWithMode:(XMOSDDisplayMode)mode channel:(NSInteger)ChlNo;

/***********************************************************************************************
 *fuction:       GetDeviceConnectedSessionNum
 *
 *Description:   发送获取网关会话连接数
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/

-(NSInteger)GetDeviceConnectedSessionNum;
/***********************************************************************************************
 *fuction:       GetAllTimeRecordParam
 *
 *Description:   发送获取指定通道全时录像参数
 *
 *Params:        ChlNo          摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)GetAllTimeRecordParam:(NSInteger)ChlNo;

/***********************************************************************************************
 *fuction:       GetPlanRecordInfoWithChannel
 *
 *Description:   发送获取指定通道计划录像参数
 *
 *Params:        ChlNo          摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)GetPlanRecordInfoWithChannel:(NSInteger)ChlNo;

/***********************************************************************************************
 *fuction:       GetPlanRecordInfoWithChannel
 *
 *Description:   发送设置计划录像参数
 *
 *Params:        ChlNo          摄像头通道号
 *               paramsDict = {
 "VideoRecClose": 0,
 "VideoRecordList": [{
                    "ChannelOpen": 0,
                    "StreamLvl": 0,
                    "IsAllTheTime": 0,
                    "ArmTime": [{
                                 "weekday": "Sun",
                                 "IsEnable": 0,
                                 "StartTime": "000000",
                                 "EndTime": "235959"
                                 },
                                 {
                                 "weekday": "Mon",
                                 "IsEnable": 0,
                                 "StartTime": "000000",
                                 "EndTime": "235959"
                                 }
                                ...
                                ]}
                    ]}  
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)SetPlanRecordInfoWithChannel:(NSInteger)ChlNo Params:(NSDictionary *)paramsDict;

/***********************************************************************************************
 *fuction:       SetResolution
 *
 *Description:   发送设置视频分辨率命令
 *
 *Params:
 *               res                视频分辨率等级
 *               ChlNo              摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)SetResolution:(P2P_VIDEO_RESOLUTION)res Channel:(NSInteger)ChlNo;
/***********************************************************************************************
 *fuction:       SetResolutionForBefore
 *
 *Description:   发送设置视频分辨率命令 for before （该命令结果回调请实现onpush for before）
 *
 *Params:
 *               res                视频分辨率等级
 *               ChlNo              摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)SetResolutionForBefore:(P2P_VIDEO_RESOLUTION_BEFORE)res Channel:(NSInteger)ChlNo;

/***********************************************************************************************
 *fuction:       SetBitRate
 *
 *Description:   发送设置视频码流命令
 *               当agreement 为 before 时 命令结果回调请实现onpush for before
 *Params:
 *               BitRate            码流值(300~1500kbps)
 *               ChlNo              摄像头通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)SetBitRate:(NSInteger)BitRate Channel:(NSInteger)ChlNo;

/***********************************************************************************************
 *fuction:       GetDoorBellInfo
 *
 *Description:   发送获取门铃信息命令
 *
 *Params:
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
- (NSInteger)GetDoorBellInfo;

/***********************************************************************************************
 *fuction:       ChangeDevicePassword
 *
 *Description:   发送修改设备登陆密码命令
 *
 *Params:
 *               UsrName         用户名
 *               o_pwd           旧密码
 *               n_pwd           新密码
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)ChangeDevicePassword:(NSString*)UsrName OldPassword:(NSString*)o_pwd NewPassword:(NSString*)n_pwd;

/***********************************************************************************************
 *fuction:       ConfigWIFI
 *
 *Description:   发送设置连接上级wifi的SSID,密码命令
 *
 *Params:
 *                SSID                需要连接上级路由器的SSID
 *                Pwd                 密码
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *Note:          使用此方法是需要在网关已经能够连上外网的前提下使用，目的只是变更当前网关的连接WiFi而不是首次配网使用
 *
 ***********************************************************************************************/
-(NSInteger)ConfigWIFI:(NSString*)SSID  password:(NSString*)Pwd;

/***********************************************************************************************
 *fuction:       ConfigWIFIForBefore
 *
 *Description:   发送设置连接上级wifi的SSID,密码命令
 *
 *Params:
 *                SSID                需要连接上级路由器的SSID
 *                Pwd                 密码
 *                type                WiFi加密方式
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *Note:          使用此方法是需要在网关已经能够连上外网的前提下使用，目的只是变更当前网关的连接WiFi而不是首次配网使用
 *
 ***********************************************************************************************/
-(NSInteger)ConfigWiFiForBefore:(NSInteger)chlNo ssid:(NSString*)ssid password:(NSString*)Pwd encryptionType:(ConfigEncryptionType)type;

/***********************************************************************************************
 *fuction:       GetSDCardInformation
 *
 *Description:   发送获取SD卡容量信息命令
 *
 *Params:        NULL
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)GetSDCardInformation;

/***********************************************************************************************
 *fuction:       FormatSDCard
 *
 *Description:   发送格式化SD卡命令
 *
 *Params:        option             选项（预留 目前 0 是格式化）
 *         ChlNo              通道
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)FormatSDCard:(NSInteger)option Channel:(NSInteger)ChlNo;

/***********************************************************************************************
 *fuction:       SyncDevicetime
 *
 *Description:   发送同步时间命令
 *
 *Params:        NULL
 *
 *Return:        发送错误代码(参考Frame work中的PPCS_Error.h)
 *
 *Note:          方法的内部是使用当前手机的时区和时间同步到设备上去
 *
 ***********************************************************************************************/
-(NSInteger)SyncDevicetime;

/***********************************************************************************************
*fuction:       SyncDevicetime
*
*Description:   发送同步时间命令
*
*Params:          countries               国家
*                      time_format           时间格式
*                           utc_sec              UTC时间(单位:s)
*                                 zone             时区
*Return:        发送错误代码(参考Framework中的PPCS_Error.h)
*
*Note:          方法的内部是使用当前手机的时区和时间同步到设备上去
*
***********************************************************************************************/
-(NSInteger)SyncDevicetime:(NSString*)countries
                    fomat:(NSInteger)time_format
                      sec:(NSInteger)utc_sec
                      zone:(NSInteger)zone;

/***********************************************************************************************
*fuction:       SyncDevicetime
*
*Description:   发送同步时间命令
*
*Params:        utc_sec     UTC时间戳/毫秒
*               zone        时区,28800表示正8时区
*               istwelve    夏令时预留
* 
*
*Return:        发送错误代码(参考Framework中的PPCS_Error.h)
*
*Note:          方法的内部是使用当前手机的时区和时间同步到设备上去
*
***********************************************************************************************/
-(NSInteger)SyncDevicetime:(NSInteger)utc_sec zone:(NSInteger)zone istwelve:(NSInteger)istwelve;


/***********************************************************************************************
 *fuction:       SyncDevicetime
 *
 *Description:   发送同步时间命令
 *
 *Params:        localTimeZone      时区信息
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *Note:          方法的内部是使用当前手机的时区和时间同步到设备上去
 *
 ***********************************************************************************************/
-(NSInteger)SyncDevicetime:(NSTimeZone *)localTimeZone;

/***********************************************************************************************
 *fuction:       GetDeviceTime
 *
 *Description:   发送获取设备时间命令
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)GetDeviceTime;

/***********************************************************************************************
 *fuction:       RebootDevice
 *
 *Description:   发送重启设备命令
 *
 *Params:        NULL
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *Note:          网关+摄像头给的情况下是重启网关
 *
 ***********************************************************************************************/
-(NSInteger)RebootDevice;

/***********************************************************************************************
 *fuction:       FactoryDevice
 *
 *Description:   发送恢复出厂信息命令
 *
 *Params:        NULL
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *Note:          网关+摄像头给的情况下是恢复网关，"不会"恢复前端摄像头信息(分辨率，码流,IR...)
 *
 ***********************************************************************************************/
-(NSInteger)FactoryDevice;

/***********************************************************************************************
 *fuction:       ManualSnapshot
 *
 *Description:   发送手动模式下摄像机抓拍命令
 *
 *Params:        
 *               ChlNo        摄像机通道号
 *               PhotoNum     抓图的张数(目前默认填写1即只抓一张)
 *               quality      抓图质量(目前只支持P2P_SNAPSHOT_QUALITY_DEFAULT)
 *               interval     抓拍间隔时间(单位:毫秒，至少1秒以上:即1000)
 *               width        抓拍的图宽度
 *               height       抓拍的图宽度
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)ManualSnapshot:(NSInteger)ChlNo
                  PhotoNum:(NSInteger)photonum
              PhotoQuality:(P2P_SNAPSHOT_QUALITY)quality
              SnapInterval:(NSInteger)interval
                PhotoWidth:(NSInteger)width
               PhotoHeight:(NSInteger)height;


/***********************************************************************************************
 *fuction:       ManualRecordVideo
 *
 *Description:   发送手动模式下摄像机抓拍命令
 *
 *Params:
 *               ChlNo        摄像机通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)ManualRecordVideo:(P2P_CAPTURE_VIDEO_CMD)OpId Channel:(NSInteger)ChlNo;


/***********************************************************************************************
 *fuction:       FetchRecThumb
 *
 *Description:   发送开始获取指定通道和指定录像文件缩略图命令
 *
 *Params:        Date          指定日期
 *               fname         录像文件名
 *               channel       摄像机通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *Note:          目前暂且文件格式为H264编码的I帧数据,用户拿到数据需后端解码
 ***********************************************************************************************/
-(NSInteger)FetchRecThumb:(NSString*)Date FileName:(NSString*)fname Channel:(NSInteger)ChlNo;

/***********************************************************************************************
 *fuction:       FetchRecThumb
 *
 *Description:   发送停止传输缩略数据并清空处理队列命令
 *
 *Params:        NULL
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)StopFetchRecThumb;


/***********************************************************************************************
 *fuction:       ClearCameraMatchInfo
 *
 *Description:   发送清除摄像机与网关配对信息命令
 *
 *Params:
 *               OpMode       清除类型(参考P2P_CLEAR_MATH的枚举值)
 *               ChlNo        摄像机通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *Note:          此方法只对网关+摄像架构的机类型有效
 *
 ***********************************************************************************************/
-(NSInteger)ClearCameraMatchInfo:(P2P_CLEAR_MATH)OpMode Channel:(NSInteger)ChlNo;

/***********************************************************************************************
 *fuction:       SetToneLanguage
 *
 *Description:   发送设置网关提示音语言命令
 *
 *Params:
 *               language         提示音的语言种类(参考LanguageType枚举值)
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)SetToneLanguage:(LanguageType)language;

/***********************************************************************************************
 *fuction:       GetUpdateStatus
 *
 *Description:   发送获取网关升级状态命令
 *
 *Params:        NULL
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 ***********************************************************************************************/
-(NSInteger)GetUpdateStatus;

/***********************************************************************************************
 *fuction:       NotifyGateWayNewVersion
 *
 *Description:   发送通知网关有新版本更新信息命令
 *
 *Params:        
 *               urlStr 升级包url地址
 *               type 参考 P2P_UPDATE_TYPE
 *               ChlNo 通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *Note:          此方法只对网关有效
 *
 ***********************************************************************************************/
-(NSInteger)NotifyGateWayNewVersionWithUrl:(NSString *)urlStr type:(P2P_UPDATE_TYPE)type Channel:(NSInteger)ChlNo;
/***********************************************************************************************
 *fuction:       ResetCameraParamWithChannel
 *
 *Description:   发送恢复摄像机默认参数命令
 *
 *Params:        
 *               ChlNo 通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *
 ***********************************************************************************************/
-(NSInteger)ResetCameraParamWithChannel:(NSInteger)ChlNo;


/***********************************************************************************************
 *fuction:       NotifyGateWayNewVersion
 *
 *Description:   发送通知网关有新版本更新信息
 *
 *Params:        
 *               ChlNo 通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *
 ***********************************************************************************************/
-(NSInteger)NotifyGateWayNewVersionWithChannel:(NSInteger)ChlNo;

/***********************************************************************************************
 *fuction:       GetCorridorLightsMode
 *
 *Description:   发送获取走廊灯控模式
 *
 *Params:        
 *               ChlNo 通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *
 ***********************************************************************************************/
-(NSInteger)GetCorridorLightsMode:(NSInteger)ChlNo;

/***********************************************************************************************
 *fuction:       SetCorridorLightsMode
 *
 *Description:   发送设置走廊灯控模式
 *
 *Params:        
 *               ChlNo 通道号
 *               mode  (参考Framework中的P2P_LIGHTSMODE枚举值)
 *               time  灯亮时间 秒  e.g. 30 
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *
 ***********************************************************************************************/
-(NSInteger)SetCorridorLights:(NSInteger)ChlNo Mode:(P2P_LIGHTSMODE)mode Time:(NSInteger)time;

/***********************************************************************************************
 *fuction:       GetCorridorLightsSwitch
 *
 *Description:   发送获取走廊灯开关状态
 *
 *Params:        
 *               ChlNo 通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *
 ***********************************************************************************************/
-(NSInteger)GetCorridorLightsSwitch:(NSInteger)ChlNo;

/***********************************************************************************************
 *fuction:       SetCorridorLights
 *
 *Description:   发送设置走廊灯
 *
 *Params:        
 *               ChlNo 通道号
 *               brightness  灯亮度  0 ~ 100
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *
 ***********************************************************************************************/
-(NSInteger)SetCorridorLights:(NSInteger)ChlNo brightness:(NSInteger)brightness;

/***********************************************************************************************
 *fuction:       GetCameraVideoMode
 *
 *Description:   发送获取视频模式
 *
 *Params:        
 *               ChlNo 通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *
 ***********************************************************************************************/
-(NSInteger)GetCameraVideoMode:(NSInteger)ChlNo;

/***********************************************************************************************
 *fuction:       SetCameraVideoMode
 *
 *Description:   发送设置视频模式
 *
 *Params:        
 *               ChlNo 通道号
 *               mode  取值 0-5
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *
 ***********************************************************************************************/
-(NSInteger)SetCameraVideoMode:(NSInteger)ChlNo Mode:(NSInteger)mode;

/***********************************************************************************************
 *fuction:       GetCameraClarity
 *
 *Description:   发送获取视频清晰度
 *
 *Params:        
 *               ChlNo 通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *
 ***********************************************************************************************/
-(NSInteger)GetCameraClarity:(NSInteger)ChlNo;

/***********************************************************************************************
 *fuction:       SetCameraClarity
 *
 *Description:   发送设置视频清晰度
 *
 *Params:        
 *               ChlNo 通道号
 *               mode  2020年07月31日 更新为：0:自动，1：低，2：中，3：高 （以前的含义： 0超清 1高清 2流畅 已废弃）
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *
 ***********************************************************************************************/
-(NSInteger)SetCameraClarity:(NSInteger)ChlNo Mode:(XMVideoQualityMode)mode;

/***********************************************************************************************
 *fuction:       GetCameraVideoAreaPTZ
 *
 *Description:   发送获取视频区域PTZ参数 (仅在模式5（四分屏）下生效)
 *
 *Params:        
 *               ChlNo 通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *
 ***********************************************************************************************/
-(NSInteger)GetCameraVideoAreaPTZ:(NSInteger)ChlNo Area:(NSInteger)area;

/***********************************************************************************************
 *fuction:       SetCameraVideoAreaPTZ
 *
 *Description:   发送设置视频区域PTZ参数 (仅在模式5（四分屏）下生效)
 *
 *Params:        
 *               ChlNo              通道号
 *               area               区域（1-4）
 *               horizontal         水平(-180~180)
 *               vertical           垂直(-135~135)
 *               zoom               缩放(1-100)
 *               step               移动速度(0-3)
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *
 ***********************************************************************************************/
-(NSInteger)SetCameraVideoAreaPTZ:(NSInteger)ChlNo 
                             Area:(NSInteger)area 
                       Horizontal:(NSInteger)horizontal 
                         Vertical:(NSInteger)vertical 
                             Zoom:(NSInteger)zoom 
                             Step:(NSInteger)step;

/***********************************************************************************************
 *fuction:       GetDeviceAudioVol
 *
 *Description:   发送获取设备喇叭音量
 *
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *
 ***********************************************************************************************/
-(NSInteger)GetDeviceAudioVol;

/***********************************************************************************************
 *fuction:       SetDeviceAudioVol:
 *
 *Description:   发送设置设备喇叭音量
 *
 *Params:        
 *               ChlNo 通道号
 *               vol   音量 0 - 37
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *
 ***********************************************************************************************/
-(NSInteger)SetDeviceAudioVol:(NSInteger)vol;

/***********************************************************************************************
 *fuction:       GetAlarmSoundStatus
 *
 *Description:   发送获取警报声音状态
 *
 *Params:        
 *               ChlNo 通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *
 ***********************************************************************************************/
-(NSInteger)GetAlarmSoundStatus:(NSInteger)ChlNo;

/***********************************************************************************************
 *fuction:       GetAlarmSoundStatus
 *
 *Description:   发送设置警报声音状态
 *
 *Params:        
 *               ChlNo 通道号
 *               alarmno 1~4
 *               enable 使能开关
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *
 ***********************************************************************************************/
-(NSInteger)SetAlarmSoundStatus:(NSInteger)ChlNo AlarmNo:(NSInteger)alarmno Enable:(BOOL)enable;

/***********************************************************************************************
 *fuction:       GetAlarmSoundStatus
 *
 *Description:   发送设置警报声音状态
 *
 *Params:        
 *               ChlNo 通道号
 *               alarmno 声音源播放, 0默认声音源
 *               enable 使能开关
 *               play_time 播放时长,设备值 默认2秒
 *               enable 开关, 0 (关闭报警声音), 1 (打开报警声音)
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *
 ***********************************************************************************************/
- (NSInteger)SetAlarmSoundStatus:(NSInteger)ChlNo AlarmNo:(NSInteger)alarmno playTime:(NSInteger)play_time Enable:(BOOL)enable;

/***********************************************************************************************
 *fuction:       EnterBackGround
 *
 *Description:   手动通知库内，APP当前是否进入后台
 *
 *Params:        enable  YES/NO(默认为NO)
 *
 *Note:          此方法建议在APP进入后台前设为YES,恢复后要设为NO(当为YES时，库将不发送任何命令)
 *
 ***********************************************************************************************/
-(void)EnterBackGround:(BOOL)enable;

/***********************************************************************************************
 *fuction:       NotifyDeviceUploadResult
 *
 *Description:   发送通知设备上传指定录像 回调结果请实现 onpush for before 方法
 *
 *Params:        
 *               ChlNo 通道号
 *               token 
 *               date 日期
 *               fileName 文件名
 *               isDel 上传后是否删除文件 YES 为 删除
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *
 ***********************************************************************************************/
-(NSInteger)NotifyDeviceUploadResult:(NSInteger)ChlNo token:(NSString *)token date:(NSString *)date fileName:(NSString *)fileName deleteFile:(BOOL)isDel;

/***********************************************************************************************
*fuction:       NotifyDeviceUploadResult
*
*Description:   发送通知设备OTA升级 回调结果请实现 onpush for before 方法
*
*Params:        
*               ChlNo 通道号
*
*Return:        发送错误代码(参考Framework中的PPCS_Error.h)
*
*
***********************************************************************************************/
-(NSInteger)NotifyDeviceOTA:(NSInteger)ChlNo;

/***********************************************************************************************
 *fuction:       NotifyDeviceSyncFromService
 *
 *Description:   发送通知设备同步服务器信息 XMAgreementTypeBefore 时回调结果请实现 onpush for before 方法
 *
 *Params:        
 *               ChlNo 通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *
 ***********************************************************************************************/
-(NSInteger)NotifyDeviceSyncFromService:(NSInteger)ChlNo;

/***********************************************************************************************
 *fuction:       SetCameraBackgroundMode 
 *
 *Description:   发送设置设备背景图与安防模式
 *
 *Params:        
 *               ChlNo 通道号
 *               background 背景图  0 ~ 5 分别表示6张背景图片（具体与设备协商）
 *               mode 安防模式   0：离家安防模式  1：在家安防模式
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *
 ***********************************************************************************************/
- (NSInteger)SetCameraBackgroundMode:(NSInteger)ChlNo Background:(NSInteger)background Mode:(NSInteger)mode;
/***********************************************************************************************
 *fuction:       SendChangeBluetoothPassWord 
 *
 *Description:   发送设置蓝牙配对密码
 *
 *Params:        
 *               ChlNo 通道号
 *               password 密码  6位数字 
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *
 ***********************************************************************************************/
- (NSInteger)SendChangeBluetoothPasswordWithChlNo:(NSInteger)ChlNo password:(int)pwd;


/***********************************************************************************************
*fuction:       SetFrameRate 
*
*Description:   设置帧率
*
*Params:        
*               frameRate 帧率（0-25）
*
*Return:        发送错误代码(参考Framework中的PPCS_Error.h)
*
*
***********************************************************************************************/
- (NSInteger)SetFrameRate:(NSInteger)frameRate;


/***********************************************************************************************
*fuction:       GetFrameRate 
*
*Description:   获取帧率
*
*Params:        
*               frameRate 帧率（0-25）
*
*Return:        发送错误代码(参考Framework中的PPCS_Error.h)
*
*
***********************************************************************************************/
- (NSInteger)GetFrameRate;


/***********************************************************************************************
*fuction:       SetGatewayRegister 
*
*Description:   设置基站注册
*
*
*Return:        发送错误代码(参考Framework中的PPCS_Error.h)
*
*
***********************************************************************************************/
-(NSInteger)SetGatewayRegister;


/***********************************************************************************************
*fuction:       SetAlarmVolume
*
*Description:   设置摄像机的报警声大小
*
*Params:
*                   value 音量（1-100）
*
*Return:        发送错误代码(参考Framework中的PPCS_Error.h)
*
*
***********************************************************************************************/
- (NSInteger)SetAlarmVolume:(NSInteger)value channel:(NSInteger)channel;


/***********************************************************************************************
*fuction:       SetAlarmVolume
*
*Description:   获取摄像机的场景模式
*
*Params:      nil
*
*Return:        发送错误代码(参考Framework中的PPCS_Error.h)
*
*
***********************************************************************************************/
- (NSInteger)GetDeviceSceneMode;

/***********************************************************************************************
*fuction:        SetCameraSwitch
*
*Description:   使能摄像机
*
*Params:      Enable            0/1 开关摄像机
*                   channel           通道号
*Return:        发送错误代码(参考Framework中的PPCS_Error.h)
*
*
***********************************************************************************************/
- (NSInteger)SetCameraSwitch:(NSInteger)Enable channel:(NSInteger)channel;


/***********************************************************************************************
*fuction:        SetCameraWorkMode
*
*Description:   设置摄像机的工作模式
*
*Params:      mode             当前摄像机工作模式
*                   clip_len          录像时长单位秒
*                   re_trigger       下次再次触发的时间间隔,单位秒
*                   channel           通道号
*
*Return:        发送错误代码(参考Framework中的PPCS_Error.h)
*
*
***********************************************************************************************/
- (NSInteger)SetCameraWorkMode:(NSInteger)mode
                    ClipLen:(NSInteger)clip_len
                     ReTrigger:(NSInteger)re_trigger
                       channel:(NSInteger)channel;

/***********************************************************************************************
*fuction:       SetDeviceSceneMode
*
*Description:   设置摄像机的场景模式
*
*Params:
*                   mode                 模式
*                   scenearray         每个摄像机的配置信息
*
*Return:        发送错误代码(参考Framework中的PPCS_Error.h)
*
*
***********************************************************************************************/
- (NSInteger)SetDeviceSceneMode:(NSInteger)mode camscenes:(NSArray*)scenearray;

/***********************************************************************************************
*fuction:       SetCameraScreenBrightnessValue 
*
*Description:   设置屏幕亮度
*
*Params:        
*               value 亮度（0-100）
*
*Return:        发送错误代码(参考Framework中的PPCS_Error.h)
*
*
***********************************************************************************************/
-(NSInteger)SetCameraScreenBrightnessValue:(NSInteger)value;



/***********************************************************************************************
 *fuction:       getCameraTamperAlarmWithChannel: 
 *
 *Description:   获取门铃强拆报警状态/控制
 *
 *Params:        
 *               channel 摄像机通道号
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *
 ***********************************************************************************************/
-(NSInteger)getCameraTamperAlarmWithChannel:(NSInteger)channel;


/***********************************************************************************************
*fuction:       setCameraTamperAlarmWithCtrl:channel: 
*
*Description:   设置门铃强拆报警状态/控制
*
*Params:        
*               ctrl 开关（0:关,1:开）
*               channel 摄像机通道号
*
*Return:        发送错误代码(参考Framework中的PPCS_Error.h)
*
*
***********************************************************************************************/
-(NSInteger)setCameraTamperAlarmWithCtrl:(NSInteger)ctrl channel:(NSInteger)channel;


/***********************************************************************************************
*fuction:       setPresButtonLedWithType:ctrl:channel:
*
*Description:   设置门铃指示灯状态(摄像机)
*
*Params:        
*               type 类型（0:默认,1:呼吸灯,2:跑马灯）
*               ctrl 开关（0:关,1:开）
*               channel 摄像机通道号
*
*Return:        发送错误代码(参考Framework中的PPCS_Error.h)
*
*
***********************************************************************************************/
- (NSInteger)setPresButtonLedWithType:(NSInteger)type ctrl:(NSInteger)ctrl channel:(NSInteger)channel;

/***********************************************************************************************
*fuction:       getPresButtonLedWithChannel:type:
*
*Description:   获取门铃指示灯状态(摄像机)
*
*Params:        
*               channel 摄像机通道号
*
*Return:        发送错误代码(参考Framework中的PPCS_Error.h)
*
*
***********************************************************************************************/
- (NSInteger)getPresButtonLedWithChannel:(NSInteger)channel type:(NSInteger)type;


/***********************************************************************************************
*fuction:       getBaseStationTone
*
*Description:   获取基站铃声
*
*Return:        发送错误代码(参考Framework中的PPCS_Error.h)
*
*
***********************************************************************************************/
- (NSInteger)getBaseStationTone;


/***********************************************************************************************
*fuction:       setBaseStationToneWithToneid:
*
*Description:   设置基站铃声
*
*Params:        
*               toneid 声音索引号(0-4)
*
*Return:        发送错误代码(参考Framework中的PPCS_Error.h)
*
*
***********************************************************************************************/
- (NSInteger)setBaseStationToneWithToneid:(NSInteger)toneid;


/***********************************************************************************************
*fuction:       getCameraToneWithChannel:
*
*Description:   获取门铃铃声
*
*Params:        
*               channel 摄像机通道号
*
*Return:        发送错误代码(参考Framework中的PPCS_Error.h)
*
*
***********************************************************************************************/
- (NSInteger)getCameraToneWithChannel:(NSInteger)channel;


/***********************************************************************************************
*fuction:       setCameraToneWithToneid:channel:
*
*Description:   设置门铃铃声
*
*Params:        
*               toneid 声音索引号
*               channel 摄像机通道号
*
*Return:        发送错误代码(参考Framework中的PPCS_Error.h)
*
*
***********************************************************************************************/
- (NSInteger)setCameraToneWithToneid:(NSInteger)toneid channel:(NSInteger)channel;


/***********************************************************************************************
*fuction:       SetCameraVolume:
*
*Description:   设置门铃音量大小
*
*Params:        
*                    volume         门铃音量大小调节(1-100)
*                   channel          通道号
*
*Return:        发送错误代码(参考Framework中的PPCS_Error.h)
*
*
***********************************************************************************************/
- (NSInteger)SetCameraVolume:(NSInteger)volume channel:(NSInteger)channel;


/***********************************************************************************************
*fuction:       GetCameraVolume:
*
*Description:   获取门铃音量大小
*
*Params:        
*                    channel 摄像机通道号
*
*Return:        发送错误代码(参考Framework中的PPCS_Error.h)
*
*
***********************************************************************************************/
- (NSInteger)GetCameraVolume:(NSInteger)channel;


/***********************************************************************************************
*fuction:       getCameraAiFilterWithChannel:
*
*Description:   获取门铃音量AI过滤器类型
*
*Params:
*                  channel 摄像机通道号
*
*Return:        发送错误代码(参考Framework中的PPCS_Error.h)
*
*
***********************************************************************************************/
- (NSInteger)getCameraAiFilterWithChannel:(NSInteger)channel;


/***********************************************************************************************
*fuction:       setCameraAiFilter:
*
*Description:   设置门铃过滤器类型
*
*Params:
*                    option 过滤器类型(0:默认 1:5s过滤)
*                   channel  通道号
*Return:        发送错误代码(参考Framework中的PPCS_Error.h)
*
*
***********************************************************************************************/
- (NSInteger)setCameraAiFilter:(NSInteger)option channel:(NSInteger)channel;

/***********************************************************************************************
*fuction:       getCameraSignalWithChannel:
*
*Description:   获取门铃信号强度
*
*Params:        
*               channel 摄像机通道号
*
*Return:        发送错误代码(参考Framework中的PPCS_Error.h)
*
*
***********************************************************************************************/
-(NSInteger)getCameraSignalWithChannel:(NSInteger)channel;

/// 添加基站摄像机
/// Return:     发送错误代码(参考Framework中的PPCS_Error.h)
- (NSInteger)addCamera;

/// 设置补光灯开关和亮度
/// @param enable 补光灯开关
/// @param brightness 40~100 可空 只控制开关可不带这个参数 填 0
/// @param channel 摄像机通道号
- (NSInteger)setSpotlightEnable:(BOOL)enable brightness:(NSUInteger)brightness channel:(NSInteger)channel;

/// MQTT控制
/// @param ctrl 0是让设备退出登录MQTT，1是让设备登录MQTT
/// @param channel 摄像机通道号
- (NSInteger)mqttCtrl:(NSInteger)ctrl channel:(NSInteger)channel;

/***********************************************************************************************
 *fuction:       SendCustomCommandID:parameter:
 *
 *Description:   发送自定义信令及参数
 *
 *Params:        
 *               parameter 自定义的参数字典, 若无参数，传nil即可
 *
 *Return:        发送错误代码(参考Framework中的PPCS_Error.h)
 *
 *
 ***********************************************************************************************/
- (NSInteger)SendCustomCommandID:(NSInteger)commandID parameter:(NSDictionary *)parameter;

@end

