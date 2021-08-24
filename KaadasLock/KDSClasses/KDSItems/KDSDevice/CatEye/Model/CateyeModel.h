//
//  CateyeModel.h
//  lock
//
//  Created by zhaowz on 2017/5/25.
//  Copyright © 2017年 zhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CateyeModel : NSObject
@property (nonatomic, copy) NSString *cateyeID;   //猫眼ID
@property (nonatomic, copy) NSString *name;       //猫眼名称
@property (nonatomic, copy) NSString *electric;   //猫眼电量
@property (nonatomic, assign) BOOL isOnline;        //猫眼是否在线
@property (nonatomic, assign) BOOL isLock;          //猫眼是否有锁

@property (nonatomic, copy) NSString *SW;            //软件版本号
@property (nonatomic, copy) NSString *HW;            //硬件版本号
@property (nonatomic, copy) NSString *macaddr;       //mac地址
@property (nonatomic, copy) NSString *MCU;       //MCU版本
@property (nonatomic, copy) NSString *T200;       //T200版本
@property (nonatomic, copy) NSString *ipaddr;           //ip地址
@property (nonatomic, copy) NSString* pirEnable;           //pir开启状态，0为开启，1为关闭
@property (nonatomic, assign) NSInteger mbStatus;              //MessageBox开启状态
@property (nonatomic, copy) NSString *curBellNum;             //当前门铃音乐编号
@property (nonatomic, copy) NSString *bellVolume;              //门铃音量
@property (nonatomic, copy) NSString *resolution;             //视频分辨率
@property (nonatomic, copy) NSString *maxBellNum;               //门铃声最大个数
@property (nonatomic, copy) NSString *power;                //猫眼电池电量

@property (nonatomic, copy) NSString *bellCount;             //响铃次数
@property (nonatomic, copy) NSString *wifiStrength;             //猫眼wifi信号强度
@property (nonatomic, copy) NSString *deviceId;                 //      猫眼设备id
@property (nonatomic, copy) NSString *gwId;                 //      猫眼所在网关id
@property (nonatomic, copy) NSString *sdStatus;             //  1,sd卡状态 0是没有插sd卡
@property (nonatomic, copy) NSString *pirSensitivity;       //pir触发事件（次数）

//- (instancetype)initWithCateyeID:(NSString *)cateyeID name:(NSString *)name electric:(NSString *)electric isOnLine:(BOOL )isOnline isLock:(BOOL )isLock;
@end
