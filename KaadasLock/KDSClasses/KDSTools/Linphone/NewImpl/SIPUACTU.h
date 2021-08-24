//
//  SIPUACTU.h
//  KaadasLock
//
//  Created by orange on 2019/7/18.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDSLinphoneManager.h"

NS_ASSUME_NONNULL_BEGIN

@class SIPUACTU;

@protocol TUDelegate <NSObject>

@optional

///Invoke when the call has connected by transaction user.
- (void)tuCallConnected:(SIPUACTU *)tu;

///Invoke when the call has stream running.
- (void)tuCallStreamRunning:(SIPUACTU *)tu;

/**
 *@brief Invoke when remote wants to add or remote video.
 *@param tu The tu.
 *@param video If remote wants to add video, this parameter is YES, otherwise NO.
 *@param handler Whether agree update video. When remote wants to add video, you MUST call this block with a boolean parameter allow or not allow. While remote end video, this block has no effect.
 *@note Only the last implementation handler of delegates' would be used. If you don't implement this method, the default is auto accept video.
 */
- (void)tu:(SIPUACTU *)tu callUpdateByRemote:(BOOL)video handler:(void (^)(BOOL allowed))handler;

///Invoke when the call has been paused by remote.
- (void)tuCallPausedByRemote:(SIPUACTU *)tu;

///Invoke when the call has been paused.
- (void)tuCallPaused:(SIPUACTU *)tu;

/**
 *@brief Invoke when the call has encountered an error.
 *@param tu The tu.
 *@param error Maybe contain a code and some messages from linphone. See LinphoneReason also.
 */
- (void)tu:(SIPUACTU *)tu callError:(NSError *)error;

///Invoke when the call has ended.
- (void)tuCallEnd:(SIPUACTU *)tu;

///Invoke when the call has released.
- (void)tuCallRelease:(SIPUACTU *)tu;

/**
 *@brief Invoke when the video state did update. Can use in preventing user click update video duplicately.
 *@see See @SEL updateVideoState also
 *@param tu the tu.
 *@param enable indicates whether enable video or not.
 */
- (void)tu:(SIPUACTU *)tu videoStateDidUpdate:(BOOL)enable;

/**
 *@brief Invoke when a snapshot has been finished.
 *@param tu the tu.
 *@param path The path snapshot save to.
 */
- (void)tu:(SIPUACTU *)tu snapshotDidFinish:(NSString *)path;

@end

///sip user agent client transaction user, be responsible for handling a call.
@interface SIPUACTU : NSObject <KDSLinphoneDelegate>

///收到来电时，根据来电创建一个tu，该来电被方法增加引用计数。
- (instancetype)initWithCall:(LinphoneCall*)call NS_DESIGNATED_INITIALIZER;
- (instancetype)init __attribute__((unavailable));
- (instancetype)new __attribute__((unavailable));

///The linphone call state. 
@property (nonatomic, assign, readonly) LinphoneCallState callState;
///The linphone call's call id.
@property (nonatomic, strong, nullable, readonly) NSString *callID;
///The linphone call incoming or outgoing date.
@property (nonatomic, strong, nullable, readonly) NSDate *date;
///The linphone call remote agent username, that is, the cat eye's register user name(incoming).
@property (nonatomic, strong, nullable, readonly) NSString *remoteUsername;
///TU handle call action delegate. Don't get it. This class object can handle multi-delegate simultaneously.
@property (nonatomic, weak) id<TUDelegate> delegate;
///Whether speaker enable.
@property (nonatomic, assign) BOOL speakerEnabled;

///接听来电。
- (void)acceptCall;

///暂停来电。
- (BOOL)pauseCall;

///恢复来电。
- (BOOL)resumeCall;

///拒绝来电或者结束会话。
- (void)declineCall;

/**
 *@brief Sets the video display view, there can be 1 view to display the video at most.
 *@param view The view display the video.
 *@warning Because of #LinphoneCore only has one video window, you are responsable for managing the window between calls.
 */
- (void)setVideoDisplayView:(UIView *)view;

/**
 *@abstract 更新通话视频状态，包括开启和关闭视频。
 *@param enable Whether enable video or not. The final video state MUST get from TUDelegate.
 *@warning When call this method, the next call again MUST wait for TUDelegate response, or else no effect.
 *@return The op success or not.
 */
- (BOOL)updateVideoState:(BOOL)enable;

/**
 *@brief Set whether microphone is enabled.
 *@param enabled Whether enable.
 *@return The result of mic enable state.
 */
- (BOOL)setMicEnable:(BOOL)enabled;

/**
 *@brief Take a snapshot to specified path. The snapshot format is jpeg.
 *@param path The absolute path snapshot save to.
 *@return The op success or not. If YES, the snapshot can get from TUDelegate, or would do nothing.
 */
- (BOOL)takeSnapshotToPath:(NSString *)path;

///start recording.
- (BOOL)startRecording;

///stop recording.
- (BOOL)stopRecording;

/**
 *@abstract Show a call incoming view.
 *@param enabled Whether play a sound.
 *@return The op success or not.
 */
- (BOOL)showIncomingView:(BOOL)enabled;

/**
 *@brief Get the call duration. If call is not existed, return negative.
 *@return The call duration, in seconds.
 */
- (int)getCallDuration;

@end

NS_ASSUME_NONNULL_END
