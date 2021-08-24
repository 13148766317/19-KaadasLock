//
//  RemotePushSubs.h
//  XMPPCS_Demo
//
//  Created by ryanlzj on 16/12/28.
//  Copyright © 2016年 ryan. All rights reserved.
//

#import    <Foundation/Foundation.h>
@interface SubscribeInfo: NSObject
/** 注册ANPS服务返回的app token值 */
@property (copy, nonatomic) NSString* token;                   //注册ANPS服务返回的app token值

@property (copy, nonatomic) NSString* InitString;              //初始化NDT库的字符串
@property (copy, nonatomic) NSString* AES128Key;               //AES128的值
@property (strong,nonatomic) NSArray* QuerySvrArray;           //查询服务器组
@property (copy, nonatomic) NSString* Enc_Dec_Key;             //编解码所选的key值
@property (copy, nonatomic) NSString* APP_Name;                //APP名称

@end


/**
 查询回复
 */
typedef NS_ENUM(NSInteger,SubscribeCheckRetType) {
    ///未订阅
    SubscribeCheckRetTypeUnsubscribe        = 0, 
    ///已订阅
    SubscribeCheckRetTypeSubscribe          = 1, 
    ///查询成功
    SubscribeCheckRetTypeCheckSuccessful    = 2, 
    ///未知错误
    SubscribeCheckRetTypeFailNonknown       = 1 << 2,
    ///初始化错误
    SubscribeCheckRetTypeInitializeError    = 1 << 3,
    ///appName信息错误
    SubscribeCheckRetTypeAppNameError       = 1 << 4, 
    ///服务器组错误
    SubscribeCheckRetTypeQueryServerError   = 1 << 5, 
    ///EncDecKey错误
    SubscribeCheckRetTypeEncDecKeyError     = 1 << 6, 
    ///客户端错误
    SubscribeCheckRetTypeClientError        = SubscribeCheckRetTypeFailNonknown | SubscribeCheckRetTypeInitializeError | SubscribeCheckRetTypeAppNameError | SubscribeCheckRetTypeQueryServerError | SubscribeCheckRetTypeEncDecKeyError,
    ///网络错误
    SubscribeCheckRetTypeInternetError      = 1 << 7, 
    ///服务器查询错误
    SubscribeCheckRetTypeSubServerError     = 1 << 8, 

};

@interface RemotePushSubs : NSObject
/**
 当前已初始化的字符串，可能为空 nil 代表未初始化或初始化不成功
 */
@property (nonatomic,copy) NSString *curInitNDTString;
#pragma mark - 单例对象 & 释放NDT
/**
 获取RemotePushSubs对象的实例

 @return RemotePushSubs实例对象
 */
+(RemotePushSubs*)GetInstantce;
/**
 检查NDT库初始化状态

 @param info SubscribeInfo 模型参数
 @return 是否初始化成功
 */
- (BOOL)autoNDTInitedWithImformation:(SubscribeInfo*)info;
/**
 释放NDT库，退到后台时建议调用
 */
+(void)DeInit;

#pragma mark - 订阅 & 取订
/**
 订阅指定DID设备的离线推送服务

 @param DID 设备的DID值
 @param info 订阅所需要的查询服务器及APP名称等信息。
 参考范例如下:
            SubscribeInfo* info = [[SubscribeInfo alloc]init];
            info.token = @"f970bd03a1f6bd5283f7412d3486961428aaac39726b012652cfc672f1c41880"
            info.InitString = @"EBGAEIBIKHJJGFJKEOGCFAEPHPMAHONDGJFPBKCPAJJMLFKBDBAGCJPBGOLKIKLKAJMJKFDOOFMOBECEJIMM";
            info.AES128Key = @"0123456789ABCDEF";
            info.QuerySvrArray = @[@"PPCS-014143-SBKHR",@"PPCS-014144-RVDKK"];
            info.Enc_Dec_Key = @"WiPN@CS2-Network";
            info.APP_Name = @"ppcsnative";
            [[RemotePushSubs GetInstantce] SubscribeRemotePush:newdev.devid Imformation:info Subscribe:TRUE];
           
            token值切记是APP自身的通过系统返回来的
 @param bEnable YES:订阅    NO:取订
 @return YES:订阅/取订 成功  NO:订阅/取订 失败
 */
-(BOOL)SubscribeRemotePush:(NSString*)DID Imformation:(SubscribeInfo*)info Subscribe:(BOOL)bEnable;

/**
 取消订阅SubscribeInfo.token下所有的离线推送服务

 @param DID 任意一个合法的DID即可
 @param info 订阅所需要的查询服务器及APP名称等信息。
 @return YES:取订 成功  NO:取订 失败
 */
-(BOOL)UnsubscribeAllRemotePush:(NSString*)DID Imformation:(SubscribeInfo*)info;

#pragma mark - 查询订阅状态
/**
 根据指定DID设备的查询当前离线推送服务状态

 @param DID 设备的DID值
 @param info 订阅所需要的查询服务器及APP名称等信息。
 @return 查看SubscribeCheckRetType枚举
 */
-(SubscribeCheckRetType)ChkSubscribe:(NSString*)DID Imformation:(SubscribeInfo*)info;

/**
 根据指定DID设备的查询当前离线推送服务状态

 @param DID 传入一个合法的DID即可，无论该DID是否已订阅
 @param info 订阅所需要的查询服务器及APP名称等信息。
 @param completeBlock 完成回调block 已订阅did数组
 */
-(void)ChkSubscribeWithDID:(NSString *)DID imformation:(SubscribeInfo*)info completeBlock:(void(^)(NSArray <NSString *>*subscribeArray,SubscribeCheckRetType retType))completeBlock;

#pragma mark - 重置Badge角标值
/**
  重置推送服务器APP角标数值   ***注意，多个DID只需要调用一次，即会重置所有已订阅的DID

 @param DID 传入一个合法的DID即可，无论该DID是否已订阅
 @param info 订阅所需要的查询服务器及APP名称等信息。
 @return 是否成功
 */
-(BOOL)RemotePushSubsResetBadge:(NSString*)DID Imformation:(SubscribeInfo*)info;

@end
