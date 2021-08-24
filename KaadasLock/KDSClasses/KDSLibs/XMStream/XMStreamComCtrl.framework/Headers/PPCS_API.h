#ifndef _PPCS_API___INC_H_
#define _PPCS_API___INC_H_

#ifdef WIN32DLL
#ifdef PPPP_API_EXPORTS
#define PPPP_API_API __declspec(dllexport)
#else
#define PPPP_API_API __declspec(dllimport)
#endif
#endif //// #ifdef WIN32DLL


#ifdef LINUX
#include <netinet/in.h>
#define PPPP_API_API 
#endif //// #ifdef LINUX

#ifdef _ARC_COMPILER
#include "net_api.h"
#define PPPP_API_API 
#endif //// #ifdef _ARC_COMPILER

#include "PPCS_Type.h"
#include "PPCS_Error.h"

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus


typedef struct{	
	CHAR bFlagInternet;		// Internet Reachable? 1: YES, 0: NO
	CHAR bFlagHostResolved;	// P2P Server IP resolved? 1: YES, 0: NO
	CHAR bFlagServerHello;	// P2P Server Hello? 1: YES, 0: NO
	CHAR NAT_Type;			// NAT type, 0: Unknow, 1: IP-Restricted Cone type,   2: Port-Restricted Cone type, 3: Symmetric 
	CHAR MyLanIP[16];		// My LAN IP. If (bFlagInternet==0) || (bFlagHostResolved==0) || (bFlagServerHello==0), MyLanIP will be "0.0.0.0"
	CHAR MyWanIP[16];		// My Wan IP. If (bFlagInternet==0) || (bFlagHostResolved==0) || (bFlagServerHello==0), MyWanIP will be "0.0.0.0"
} st_PPCS_NetInfo;

typedef struct{	
	INT32  Skt;					// Sockfd
	struct sockaddr_in RemoteAddr;	// Remote IP:Port
	struct sockaddr_in MyLocalAddr;	// My Local IP:Port
	struct sockaddr_in MyWanAddr;	// My Wan IP:Port
	UINT32 ConnectTime;				// Connection build in ? Sec Before
	CHAR DID[24];					// Device ID
	CHAR bCorD;						// I am Client or Device, 0: Client, 1: Device
	CHAR bMode;						// Connection Mode: 0: P2P, 1:Relay Mode
	CHAR Reserved[2];				
} st_PPCS_Session;

//获取APIB版本
PPPP_API_API UINT32 PPCS_GetAPIVersion(void);

PPPP_API_API CHAR* PPCS_GetAPIInformation(void); //// add 3.5.0

//查询设备的名称
PPPP_API_API INT32 PPCS_QueryDID(const CHAR* DeviceName, CHAR* DID, INT32 DIDBufSize);
//初始化PPCS会话模块的使用
PPPP_API_API INT32 PPCS_Initialize(CHAR *Parameter);
//释放PPCS会话模块使用的所有资源
PPPP_API_API INT32 PPCS_DeInitialize(void);
    
#pragma mark - 网络监测
//检测网络相关信息
PPPP_API_API INT32 PPCS_NetworkDetect(st_PPCS_NetInfo *NetInfo, UINT16 UDP_Port);
//与PPCS_NetworkDetect相同，但是用户可以指定使用哪个服务器执行此功能
PPPP_API_API INT32 PPCS_NetworkDetectByServer(st_PPCS_NetInfo *NetInfo, UINT16 UDP_Port, CHAR *ServerString);
//ppcs共享带宽
PPPP_API_API INT32 PPCS_Share_Bandwidth(CHAR bOnOff);

PPPP_API_API INT32 PPCS_Enable_SmartDevice(CHAR bOnOff); //// add 3.5.0

//登录到服务器并等待连接到某个客户机。调用线程将被阻塞，直到客户机连接或超时。
PPPP_API_API INT32 PPCS_Listen(const CHAR *MyID, const UINT32 TimeOut_Sec, UINT16 UDP_Port, CHAR bEnableInternet, const CHAR* APILicense);
//打破PPCS_Listen
PPPP_API_API INT32 PPCS_Listen_Break(void);
//检查设备登录状态
PPPP_API_API INT32 PPCS_LoginStatus_Check(CHAR* bLoginStatus);
//寻找目标设备并连接它
PPPP_API_API INT32 PPCS_Connect(const CHAR *TargetID, CHAR bEnableLanSearch, UINT16 UDP_Port);
//与PPCS_Connect相同，但是用户可以指定使用哪个服务器执行此功能。
PPPP_API_API INT32 PPCS_ConnectByServer(const CHAR *TargetID, CHAR bEnableLanSearch, UINT16 UDP_Port, CHAR *ServerString);
//打破PPCS_Connect
PPPP_API_API INT32 PPCS_Connect_Break(void);
//检查会话信息
PPPP_API_API INT32 PPCS_Check(INT32 SessionHandle, st_PPCS_Session *SInfo);
//释放指定会话句柄使用的资源
PPPP_API_API INT32 PPCS_Close(INT32 SessionHandle);
//释放指定的会话句柄使用的资源。不关心远程站点是否收到写入的数据
PPPP_API_API INT32 PPCS_ForceClose(INT32 SessionHandle);
//将数据写入指定的会话句柄的指定通道。执行是无阻塞的，除非发送数据缓冲区已满。写入缓冲区的最大大小为2MB
PPPP_API_API INT32 PPCS_Write(INT32 SessionHandle, UCHAR Channel, CHAR *DataBuf, INT32 DataSizeToWrite);
//从指定的会话句柄的指定通道读取窗体数据。在读取DataSizeToRead字节或TimeOut_ms之前，执行将被阻塞
PPPP_API_API INT32 PPCS_Read(INT32 SessionHandle, UCHAR Channel, CHAR *DataBuf, INT32 *DataSize, UINT32 TimeOut_ms);
//检查当前写缓冲区和读缓冲区大小。写入缓冲区是数据到发送到远程，读取缓冲区是从远程站点接收到的数据
PPPP_API_API INT32 PPCS_Check_Buffer(INT32 SessionHandle, UCHAR Channel, UINT32 *WriteSize, UINT32 *ReadSize);
//// Ther following functions are available after ver. 2.0.0
PPPP_API_API INT32 PPCS_PktSend(INT32 SessionHandle, UCHAR Channel, CHAR *PktBuf, INT32 PktSize); //// Available after ver. 2.0.0
PPPP_API_API INT32 PPCS_PktRecv(INT32 SessionHandle, UCHAR Channel, CHAR *PktBuf, INT32 *PktSize, UINT32 TimeOut_ms); //// Available after ver. 2.0.0

#ifdef __cplusplus
}
#endif // __cplusplus
#endif ////#ifndef _PPCS_API___INC_H_
