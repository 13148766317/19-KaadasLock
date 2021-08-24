//
//  SearchDID.h
//  XMPPCS_Demo
//
//  Created by ryanlzj on 16/12/16.
//  Copyright © 2016年 ryan. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const DEV_DID_KEY;
FOUNDATION_EXPORT NSString * const DEV_SN_KEY;
FOUNDATION_EXPORT NSString * const DEV_IP_KEY;
FOUNDATION_EXPORT NSString * const DEV_Mode_KEY;
FOUNDATION_EXPORT NSString * const DEV_Ver_KEY;
FOUNDATION_EXPORT NSString * const DEV_Num_Key;
FOUNDATION_EXPORT NSString * const DEV_Type_Key;

typedef NS_ENUM(NSInteger, XMSearchDevicesType) {
    XMSearchDevicesTypeDID      = 0,
    XMSearchDevicesTypeToken    = 1,
};

@protocol   SearchDIDDelegate<NSObject>

/**
 局域网内搜索设备的回调，在搜索定时时间内可能会被多次调用，搜索到一个会被回调一次；(使用前请设置delegate)

 @param DevInfoDic 新设备信息Dictionary 字典key值参考宏DEV_DID_KEY,DEV_IP_KEY,...
 */
-(void)OnSearchNewDevice:(NSDictionary*)DevInfoDic;

/**
 局域网内搜索设备超时的回调
 */
-(void)OnSearchTimerOut;
@end
@interface SearchDID : NSObject 
@property (weak,nonatomic)id<SearchDIDDelegate> delegate;
@property (strong,atomic)NSMutableArray*  DevInfoDicArry;

/**
 开始局域网内搜索设备，默认搜索定时时长为5秒，调用前请把delegate(代理)设置好
 */
-(void)StartSearch;

/**
 开始局域网内搜索设备，调用前请把delegate(代理)设置好

 @param sTime 自定义超时时间
 */
-(void)StartSearch:(NSTimeInterval)sTime;

/// 开始局域网内搜索设备 （使用token搜索时使用这个，其他的类型使用上面的方法一样的效果）
/// @param sTime 超时时间
/// @param type 搜索类型 默认是 XMSearchDevicesTypeDID 如需要使用Token搜索则用XMSearchDevicesTypeToken
/// @param token type 是 XMSearchDevicesTypeToken 时 token 必填
/// @param code   type 是 XMSearchDevicesTypeToken 时 code 必填  例 中国的code填：86
- (void)StartSearch:(NSTimeInterval)sTime type:(XMSearchDevicesType)type token:(NSString *)token code:(int)code;

/**
 停止局域网内搜索设备
 */
-(void)StopSearch;
@end
