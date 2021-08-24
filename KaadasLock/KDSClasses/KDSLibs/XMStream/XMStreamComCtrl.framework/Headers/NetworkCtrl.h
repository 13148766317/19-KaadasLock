//
//  NetworkCtrl.h
//  JiaoFeiMao
//
//  Created by ryanlzj on 16/7/27.
//  Copyright © 2016年 LT. All rights reserved.
//

#import <Foundation/Foundation.h>
#define XM_AP_WIFI_SET                  0x100   
#define XM_AP_WIFI_RESP                 0x101
#define XM_SER_SET_REQ                  0x102
#define XM_SER_SET_RESP                 0x103
#define XM_AP_RESP                      0x104
#define XM_AP_NOTIFY_WIFILIST           0X105
struct head {
    int tag;
    int cmdtype;
    int lenght;
    int result;
};
//网关版配置WiFi及密码
struct apconfig {
    char ssid[32];
    char pass[32];
};

struct apshareconfig {
    char ssid[32];
    char pass[32];
    int authType; //WiFI加密类型 1.OPEN 2.WEP 3.WPA
    int  sertype;
    char apptoken[16];
};

// 岩与ssid密码64位
struct ap_64_config {
    char ssid[64];
    char pass[64];
};

//网关版返回
struct resp{
    char uuid[32];
};
//单机版配置WiFi及密码
struct ac_apconfig {
    char ssid[32];
    char pass[32];
    int authType; //WiFI加密类型 1.OPEN 2.WEP 3.WPA
};

//单机版返回
struct ac_resp {
    char uuid[32]; //当前设备did
    char sn[32]; //网关序列号
};

struct cateye_apconfig {
    int  type; //加密类型 1:OPEN(开放的) 2:WEP 
    char ssid[32]; //SSID
    char key[64]; //密码
    char regist_id[64]; //注册 ID
};

struct domainName {
    char serurl[128]; // 域名
};

typedef struct _NearbyAP
{
    int ch;  //信道
    int siganl;  //信号长度
    char ssid[32];
    char Security[32];
}XM_APLIST;

typedef struct _wifilist{
    int count;                                //总个数
    XM_APLIST ap[20];                        //最大显示20个
}XM_WIFILIST;
@protocol NetworkCtrlDelegate <NSObject>

/**
 获取wifi列表（XM_APLIST结构体数组）
 */
-(void)recvWifiListData:(NSArray *)wifiList;

@end

@interface NetworkCtrl : NSObject

@property (nonatomic ,weak) id<NetworkCtrlDelegate> delegate;
/**
 创建并连接socket 

 @param hostText 地址
 @param port 端口
 @return 是否成功
 */
- (BOOL)connection:(NSString *)hostText port:(int)port;


/**
创建并连接socket 

@param hostText 地址
@param port 端口
@param duration 超时时间
@return 是否成功
*/

- (BOOL)connection:(NSString *)hostText port:(int)port duration:(int)duration;

/**
 向已连接socket发送消息，同步接收回复返回

 @param data 消息数据
 @return 接收到的结果返回
 */
- (NSString *)sendAndRecv:(NSData*)data;

/**
 向已连接socket发送消息

 @param data 消息数据
 @return 是否发送成功（收到回复头）
 */
- (BOOL)sendAndNoRecv:(NSData*)data;

/**
 向已连接socket发送消息

 @param data 消息数据
 @return 已发数据长度（无需回复）
 */
- (ssize_t)SendToSvr:(NSData*)data;

/**
 断开连接
 */
- (void)disConnection;

/**
 获取当前已连接的WiFi的地址

 @return ip地址信息
 */
- (NSString *)getGatewayIPAddress;

/**
 获取当前已连接的WiFi的地址

 @param preferIPv4 是否ipv4
 @return ip地址信息
 */
- (NSString *)getIPAddress:(BOOL)preferIPv4;
@end
