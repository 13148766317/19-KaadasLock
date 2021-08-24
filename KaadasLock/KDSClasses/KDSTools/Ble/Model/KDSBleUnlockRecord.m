//
//  KDSBleUnlockRecord.m
//  lock
//
//  Created by orange on 2018/12/19.
//  Copyright © 2018年 zhao. All rights reserved.
//

#import "KDSBleUnlockRecord.h"

@implementation KDSBleUnlockRecord

@synthesize total = _total;
@synthesize current = _current;
@synthesize hexString = _hexString;

- (instancetype)initWithData:(NSData *)data
{
    self = [super init];
    if (self)
    {
        const unsigned char *bytes = data.bytes;
        if (data.length == 20)//新模块
        {
            _total = bytes[4];
            _current = bytes[5];
            //开门类型第7位
            unsigned char event = bytes[7];
            NSArray *events = @[@"密码", @"遥控", @"手动", @"卡片", @"指纹", @"语音", @"静脉", @"人脸"];
            NSString *type = @"手机";//FF，暂用FF代表手机
//            NSLog(@"--{Kaadas}--event=%d",event);
            //open_type取events的类型
            if (event < events.count)
            {
                type = events[event];
            }
//            NSLog(@"--{Kaadas}--type=%@",type);
            _unlockType = type;
            unsigned char userId = bytes[9];
//            //当userid为103时，open_type为App开门类型
//            if (userId == 0x67)
//            {
//                self.unlockType = @"7";
//            }
            _userNum = [NSString stringWithFormat:@"%02d", userId];
        }
        else
        {
            //第8位数字为开锁类型 //1:密码 2:指纹 3:卡片 4:机械方式 5:遥控开门 6:一键开启 7:APP开启，手机表示APP开门 不用上传
            NSArray *events = @[@"密码", @"指纹", @"卡片", @"手动", @"遥控", @"一键开启", @"手机", @"人脸", @"静脉"];
            NSString *type = @"不确定";
            unsigned char event = bytes[8];
            if (0 < event && event < events.count + 1)
            {
                type = events[event - 1];
            }
            _unlockType = type;
            //取第九位 获得用户编号
            unsigned char userNum = bytes[9];
            _userNum = [NSString stringWithFormat:@"%02d", userNum];
            //第12位表示年，13位月，14位日，15位时，16位分，17位秒。
            unsigned char year = bytes[12];
            unsigned char month = bytes[13];
            unsigned char day = bytes[14];
            unsigned char hour = bytes[15];
            unsigned char minute = bytes[16];
            unsigned char second = bytes[17];
//            if (userNum > 99 || event >= 8 || event <= 0 || year < 0x17 || year > 0x30 || month > 0x12 || month <= 0)
//            {
//                //上传要求 用户编号0-99  开门类型1-7 年份2017-2030 月份1-12
//                self.unlockType = @"7";
//            }
            self.date = [NSString stringWithFormat:@"20%02x-%02x-%02x %02x:%02x:%02x", year, month, day, hour, minute, second];
        }
        NSMutableString *hex = [NSMutableString stringWithCapacity:data.length * 2];
        
        for (NSUInteger i = 0; i < data.length; ++i)
        {
            [hex appendFormat:@"%02x", bytes[i]];
        }
        _hexString = hex.copy;
    }
    return self;
}

- (instancetype)initWithHexString:(NSString *)string
{
    if (!string) return nil;
    NSUInteger len = string.length / 2;
    char* buffer = (char*)calloc(1, len);
    int i = 0;
    while (i < len)
    {
        buffer[i] = strtoul([string substringWithRange:NSMakeRange(2 * i, 2)].UTF8String, 0, 16);
        i++;
    }
    return [[KDSBleUnlockRecord alloc] initWithData:[[NSData alloc] initWithBytesNoCopy:buffer length:len]];
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) return NO;
    KDSBleUnlockRecord * record = (KDSBleUnlockRecord *)object;
    if (self.hexString.length<12 || record.hexString.length<12) return NO;
    return  [[self.hexString substringFromIndex:12] isEqualToString:[((KDSBleUnlockRecord *)object).hexString substringFromIndex:12]];
}

- (NSUInteger)hash
{
    return self.hexString.length>12 ? [self.hexString substringFromIndex:12].hash : self.hexString.hash;
}

@end
