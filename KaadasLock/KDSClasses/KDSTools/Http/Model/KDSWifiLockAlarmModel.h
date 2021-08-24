//
//  KDSWifiLockAlarmModel.h
//  KaadasLock
//
//  Created by zhaona on 2019/12/19.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSWifiLockAlarmModel : NSObject
///报警记录ID
@property (nonatomic,strong)NSString * _id;
///报警时间，当前时区当前时间至70年的毫秒数。
@property (nonatomic,assign)NSTimeInterval time;
///本地添加的，从warningTime转换的时间字符串，格式yyyy-MM-dd HH:mm:ss
@property (nonatomic,strong,nullable)NSString * date;
///报警类型：1锁定 2劫持 3三次错误 4防撬 8机械方式报警 16低电压 32锁体异常 64布防
@property (nonatomic,assign)int type;
///设备SN
@property (nonatomic,strong)NSString * wifiSN;
///记录创建时间, 当前时区当前时间至70年的毫秒数。
@property (nonatomic,assign)NSTimeInterval createTime;
///productSN
@property (nonatomic,strong)NSString * productSN;

/*
 **************视频锁涉及到的字段*********************
 */
///事件ID
@property (nonatomic,strong)NSString * eventId;
///抓拍视频的缩略图地址
@property (nonatomic,strong)NSString * thumbUrl;
///视频文件目录
@property (nonatomic,strong)NSString * fileDate;
///视频文件名称
@property (nonatomic,strong)NSString * fileName;
///录像分辨率
@property (nonatomic,assign)int height;
///录像起始时间戳
@property (nonatomic,strong)NSString * startTime;
///图片上传结果
@property (nonatomic,assign)BOOL  thumbState;
///单位秒,录像时长
@property (nonatomic,assign)int  vedioTime;
///录像分辨率
@property (nonatomic,assign)int width;

@end

NS_ASSUME_NONNULL_END
