//
//  KDSMQTTTask.m
//  KaadasLock
//
//  Created by orange on 2019/4/12.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSMQTTTask.h"

@interface KDSMQTTTask ()

///任务超时的定时器。
@property (nonatomic, strong) dispatch_source_t timer;

@end

@implementation KDSMQTTTask

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.timeout = 25;
    }
    return self;
}

- (instancetype)initDisableTimer {
    self = [super init];
    if (self)
    {
        
    }
    return self;
}
- (void)setTimeout:(int)timeout
{
    _timeout = timeout;
    !self.timer ?: dispatch_source_cancel(self.timer);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(self.timer, dispatch_time(DISPATCH_TIME_NOW, timeout * NSEC_PER_SEC), 30 * NSEC_PER_SEC, 1 * NSEC_PER_SEC);
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(self.timer, ^{
        dispatch_source_cancel(weakSelf.timer);
        weakSelf.timer = nil;
        void (^block)(NSError *, id) = weakSelf.responseBlock;
        weakSelf.responseBlock = nil;
        NSLog(@"mqtttask--------timeout%@",weakSelf.receipt.func);
        !block ?: block([NSError errorWithDomain:@"请求MQTT服务器超时" code:(NSInteger)KDSGatewayErrorRequestTimeout userInfo:nil], nil);
    });
    dispatch_resume(self.timer);
}

- (NSData *)payload
{
    return _payload ?: NSData.data;
}

- (void)dealloc
{
    if (self.timer)
    {
        dispatch_source_cancel(self.timer);
        self.timer = nil;
    }
}

@end

@implementation KDSMQTTTaskReceipt

- (instancetype)initWithCommand:(MQTTCommandType)cmd topic:(NSString *)topic qos:(MQTTQosLevel)qos func:(NSString *)func
{
    self = [super init];
    if (self)
    {
        self.pid = 0;
        _type = cmd;
        _topic = topic;
        _func = func;
        self.qos = qos;
    }
    return self;
    
}

/*- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) return NO;
    if (self == object) return YES;
    KDSMQTTTaskReceipt *receipt = object;
    if (self.func && receipt.func)
    {
        BOOL idEqual = YES;
        if (self.deviceId && receipt.deviceId)
        {
            idEqual = [self.deviceId isEqualToString:receipt.deviceId];
        }
        return idEqual && [self.func isEqualToString:receipt.func];
    }
    return [self.topic isEqualToString:receipt.topic];
}*/

@end
