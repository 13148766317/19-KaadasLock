//
//  KDSSceneModel.h
//  KaadasLock
//
//  Created by zhaona on 2020/2/24.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSSceneModel : NSObject

///使能状态， 0表示关闭该条trigger上传
@property(nonatomic,assign) BOOL pushNotification;
///使能状态， 0表示关闭该条trigger，之后不再生效(场景是否生效0:失效，1生效)
@property(nonatomic,assign) BOOL enable;
///开始时间：2020/03/19
@property(nonatomic,strong)NSString * startTime;
///开始时分：22:29
@property(nonatomic,strong)NSString * startHour;
///结束时间：2020/03/19
@property(nonatomic,strong)NSString * endTime;
///结束时分：22:29
@property(nonatomic,strong)NSString * endHour;
///时区
@property(nonatomic,strong)NSString * timezone;
///重复日期：(0[周天]~6[周六])，多选
@property(nonatomic,strong)NSArray * weekdays;

@end

NS_ASSUME_NONNULL_END
