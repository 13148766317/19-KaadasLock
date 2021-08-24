//
//  KDSOperationalRecord.h
//  xiaokaizhineng
//
//  Created by zhaona on 2019/7/30.
//  Copyright © 2019 shenzhen kaadas intelligent technology. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
//---操作记录
@interface KDSOperationalRecord : NSObject

@property (nonatomic, strong) NSString *open_type;      //开门类型
@property (nonatomic, strong) NSString *lockNickName;
@property (nonatomic, strong) NSString *lockName;
@property (nonatomic, strong) NSString *uname;          //用户姓名(APP开门使用）
@property (nonatomic, strong) NSString *open_purview;
///服务器返回的格式yyyy-MM-dd HH:mm:ss
@property (nonatomic, strong) NSString *open_time;
///昵称。
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) NSString *cid;

@property (nonatomic, strong) NSString *user_num;  // 密匙编号
///操作媒介。0:键盘，1:RF遥控，2:手工，3:卡片，4:指纹，5:语音，6:指静脉，7:人脸识别，255:未知。Event Source(操作记录专属属性)
@property (nonatomic, assign) int eventSource;
///1:开锁记录、0：操作记录
//@property (nonatomic, assign) int boolisunLock;
///1：Operation操作(动作类)\2：Program程序(用户管理类)\3：Alarm\4：混合记录
@property (nonatomic, assign) int cmdType;
///1：Operation操作(动作类)\2：Program程序(用户管理类)\3：Alarm
@property (nonatomic, assign) int eventType;

@end

NS_ASSUME_NONNULL_END
