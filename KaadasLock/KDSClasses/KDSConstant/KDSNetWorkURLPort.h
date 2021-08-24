//
//  KDSNetWorkURLPort.h
//  KaadasLock
//
//  Created by wzr on 2019/1/15.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#ifndef KDSNetWorkURLPort_h
#define KDSNetWorkURLPort_h

#define KaadasStoreURL @"https://kaadas.tmall.com"
#define KaadasWebPage  @"http://www.kaadas.com"

#pragma mark - 网络环境切换
//#define KDSEnvironment            1//0表示本地测试环境   1表示生产环境
//旧的接口
//#define KDSLoginPrdUrl     @"http://120.77.15.124/"
//新的本地环境
//#define  KDSLoginStgUrl     @"https://121.201.57.214:8090/"
//新的远程环境
//#define  KDSLoginPrdUrl     @"https://app-kaadas.juziwulian.com:34000/"
//#define  KDSLoginPrdUrl       @"120.76.73.193:3400/"
//#define  KDSLoginPrdUrl     @"https://kaadas.orangeiot.cn:34000/"


//新的端口号  凯迪仕 6006           桔子物联  6606                     第三方 6660
//#define  KDSLoginPrdUrl     @"https://app1.orangeiot.cn:6006/"
//#define  KDSLoginPrdUrl     @"https://app.orangeiot.cn:8445/" //原来的接口

///http://s.kaadas.com:8989/cfg/SoftMgr/TI.json
///检测蓝牙固件版本更新信息地址
#define  KDS_TI_OTA_BinUrl   @"http://s.kaadas.com:8989/cfg/SoftMgr/TI.json"

//获取验证码-通过手机
//#define ISE_GET_YANZHENGMA_Tel      @"sms/sendsmsltoken"
#define ISE_GET_YANZHENGMA_Tel      @"sms/sendSmsTokenByTX"

//上传deviceToken
#define upLoadDeviceToken           @"user/upload/pushId"

//获取验证码-通过邮箱
#define ISE_GET_YANZHENGMA_Email    @"mail/sendemailtoken"
//注册
#define ISE_REGISTER_URL_Tel        @"user/reg/putuserbytel"
#define ISE_REGISTER_URL_Email      @"user/reg/putuserbyemail"
//登录
#define ISE_LOGIN_URL_Tel           @"user/login/getuserbytel"
#define ISE_LOGIN_URL_Emal          @"user/login/getuserbymail"
//修改密码
#define ISE_UPDATE_PWD              @"user/edit/postUserPwd"
//忘记密码(重置密码)
#define KDS_ForgetPWD      @"user/edit/forgetPwd"
//#define    KDS_ForgetPWD        @"user/edit/forgetPwd"
//修改昵称
#define  ISE_NICNAME_URL            @"user/edit/postUsernickname"
//获取昵称
#define  ISE_GETNICENAME_URL        @"user/edit/getUsernickname"
//验证token
#define ISE_CHECKTOKEN              @"user/login/getreloginuser"
// 提交反馈
#define ISE_FEEDBACK_URL            @"suggest/putmsg"
// 获取系统消息
#define ISE_SYETEMMESSAGE_URL       @"ISE_API_kaadas/user/info/3/"
//添加设备
#define ISE_ADDDEVICE               @"adminlock/reg/createadmindev"
//重置解绑
#define ISE_REMAKE                  @"adminlock/reg/deletevendordev"
//用户主动删除设备
#define ISE_DELETEMANAGER           @"adminlock/reg/deleteadmindev"
//管理员为设备添加普通用户
#define ISE_ADDCUSTOMER             @"normallock/reg/createNormalDev"
//管理员删除用户
#define ISE_DELETECUSTMER           @"normallock/reg/deletenormaldev"
//获取开锁记录
#define ISE_GETLOCKJILU             @"openlock/downloadopenlocklist"
//管理员修改锁不允许普通用户开锁的时间范围(废弃接口)
#define ISE_SETOPENTIME             @"ISE_API_kaadas/user/info/11/"
//管理员修改普通用户权限
#define ISE_SETPEMISSION            @"normallock/ctl/updateNormalDevlock"
//用户申请开锁
#define ISE_ASKOPENLOCK             @"adminlock/open/openLockAuth"
//获取设备列表
#define ISE_GETDEVICELIST           @"adminlock/edit/getAdminDevlist"
//设备下的普通用户列表
#define ISE_GETPERSONLIST           @"normallock/ctl/getNormalDevlist"
//获取不开锁时间（废弃接口）
#define ISE_GETOPENTIME             @"ISE_API_kaadas/user/info/18/"
//修改用户昵称
#define ISE_CHANGEPERSONNAME        @"ISE_API_kaadas/user/update/2/"
//管理员修改锁的位置信息
#define ISE_UPDATELOCKLOCATION      @"adminlock/edit/editadmindev"
//获取设备经纬度等信息
#define  ISE_GETDEVICELOCATONINFO   @"adminlock/edit/getAdminDevlocklongtitude"
//修改设备是否开启自动解锁功能
#define ISE_ISSTARTAUTOUNLOCK       @"adminlock/edit/updateAdminDevAutolock"
//修改设备昵称
#define ISE_FIXDEVICENICKNAME       @"adminlock/edit/updateAdminlockNickName"
// 检测是否被绑定
#define ISE_ISBIND_URL              @"adminlock/edit/checkadmindev"
//上传开门记录
#define ISE_UPLOAD_RECORD_URL       @"openlock/uploadopenlocklist"

//上传头像
#define KDS_UpLoadUserHead          @"user/edit/uploaduserhead"
//#define KDS_UpLoadUserHead          @"showfileonline"

//获取用户头像
//#define KDS_GetUserHead             @"user/edit/downloaduserhead"
#define KDS_GetUserHead             @"user/edit/showfileonline"
//退出登录
#define KDS_UserLogout               @"/user/logout"


#define KDS_GetPwdByMac             @"model/getpwdBymac"
#define KDS_GetPwdBySN              @"model/getpwdBySN"

#define KDS_OpenLockSuccess         @"adminlock/open/adminOpenLock"

//查询设备型号映射
#define KDS_deviceMapping           @"deviceModel/get"

////确认Wi-Fi锁/s模块升级
#define KDS_WiFiLockOTA             @"wifi/device/ota"
////确认Wi-Fi锁/s模块升级多固件
#define KDS_WiFiLockOTAmu            @"wifi/device/multiOta"

#endif /* Port_h */
