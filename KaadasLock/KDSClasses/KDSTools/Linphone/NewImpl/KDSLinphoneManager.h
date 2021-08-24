//
//  KDSLinphoneManager.h
//  KaadasLock
//
//  Created by orange on 2019/7/17.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreTelephony/CTCallCenter.h>
#include "linphone/linphonecore.h"
#include "bctoolbox/list.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

///linphone相关状态改变的代理。
@protocol KDSLinphoneDelegate <NSObject>

@optional

/**
 *@brief 当linphone核心对象创建成功时会执行此回调。
 *@param core 被创建的核心，代理不拥有此指针的所有权。此回调执行后，才能正常进行通话。
 */
+ (void)linphoneCoreDidCreate:(LinphoneCore*)core;

/**
 *@brief 当linphone核心对象销毁时会执行此回调。此回调执行时，依附于此核心的所有会话已经被挂断销毁释放。
 *@param core 被销毁的核心，代理不拥有此指针的所有权。此回调执行后，核心就会被销毁，如果代理需要使用，请自行添加引用。
 */
+ (void)linphoneCoreDidDestory:(LinphoneCore*)core;

/**
 *@brief 当通话状态发送改变时会执行此回调。例如ringing、connected、release等。
 *@param call 状态改变的通话，代理不拥有此指针的所有权。
 *@param state 通话当前状态。
 *@param msg 通话状态附加的消息。
 */
- (void)linphoneCall:(LinphoneCall*)call didUpdateState:(LinphoneCallState)state withMessage:(NSString *)msg;

@end

///登录后，只需要调用startRegister或者cleanRegister方法。
@interface KDSLinphoneManager : NSObject

/**
 *@abstract 单例。此类内部功能实现会依赖KDSUserManager单例，会自动处理前后台状态。
 *@return instance。
 */
+ (instancetype)sharedManager;

///Whether speaker enable.
@property (nonatomic, assign) BOOL speakerEnabled;

///单用户注册，需要登录后才能注册，即KDSUserManager的user属性有值。返回是否可以注册。
- (BOOL)startRegister;

///清除单用户注册信息。
- (void)cleanRegister;

/**
 *@brief Set whether microphone is enabled.
 *@param enabled whether enable.
 *@return The result of mic enable state.
 */
- (BOOL)setMicEnable:(BOOL)enabled;

- (void)call:(const LinphoneAddress *)iaddr showVideo:(BOOL)video;
@end

NS_ASSUME_NONNULL_END
