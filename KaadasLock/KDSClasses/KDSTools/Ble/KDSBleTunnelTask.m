//
//  KDSBleTunnelTask.m
//  lock
//
//  Created by orange on 2018/12/14.
//  Copyright © 2018年 zhao. All rights reserved.
//

#import "KDSBleTunnelTask.h"

@interface KDSBleTunnelTask()

///任务超时的定时器。
@property (nonatomic, strong) dispatch_source_t timer;
///任务重发的定时器。
@property (nonatomic, strong) dispatch_source_t resendTimer;
///记录任务重发次数。
@property (nonatomic, assign) int resendCount;
///获取开锁记录/报警记录时使用。获取到一条数据后，开启一个定时器，如果从设置时起超过设定时间没收到数据，判断为数据接收结束。
@property (nonatomic, strong) NSTimer *recordTimer;

@end

@implementation KDSBleTunnelTask

- (NSTimer *)recordTimer
{
    if (!_recordTimer)
    {
        _recordTimer = [NSTimer scheduledTimerWithTimeInterval:self.dataInterval target:self selector:@selector(recordTimerAction:) userInfo:nil repeats:NO];
    }
    return _recordTimer;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _tsn = 0;
        self.command = KDSBleOldCommandInvalid;
        _timeout = 20;
        _dataInterval = -1;
        //1.创建类型为 定时器类型的 Dispatch Source
        //1.1将定时器设置在主线程
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        //1.2设置定时器每30秒执行一次
        dispatch_source_set_timer(self.timer, dispatch_time(DISPATCH_TIME_NOW, _timeout * NSEC_PER_SEC), 30 * NSEC_PER_SEC, 1 * NSEC_PER_SEC);
        __weak typeof(self) weakSelf = self;
        //1.3设置定时器执行的动作
        dispatch_source_set_event_handler(self.timer, ^{
            dispatch_source_cancel(weakSelf.timer);
            weakSelf.timer = nil;
            void (^block)(NSData *data) = weakSelf.bleReplyBlock;
            weakSelf.bleReplyBlock = nil;
            !block ?: block(nil);
        });
        //2.启动定时器
        dispatch_resume(self.timer);
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data
{
    NSAssert(data != nil, @"初始化时发送给蓝牙的数据不能为空");
    self = [self init];
    _data = data;
    const unsigned char* bytes = data.bytes;
    _tsn = bytes[1];
    _order = (KDSBleTunnelOrder)bytes[3];
    return self;
}

- (NSString *)receipt
{
    if (self.command != KDSBleOldCommandInvalid)
    {
        return @((NSInteger)self.command).stringValue;
    }
    return @(self.tsn).stringValue;
}

- (void)setTaskResendBlock:(void (^)(void))taskResendBlock
{
    if (taskResendBlock) _taskResendBlock = taskResendBlock;
    if (self.resendTimer)
    {
        dispatch_source_cancel(self.resendTimer);
        self.resendTimer = nil;
    }
    if (taskResendBlock)
    {
        self.resendCount = 1;
        self.resendTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(self.resendTimer, dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), 0.5 * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
        __weak typeof(self) weakSelf = self;
        dispatch_source_set_event_handler(self.resendTimer, ^{
            
            weakSelf.resendCount++;
            if (weakSelf.resendCount > 3)
            {
                dispatch_source_cancel(weakSelf.resendTimer);
                weakSelf.resendTimer = nil;
            }
            !weakSelf.taskResendBlock ?: weakSelf.taskResendBlock();
            
        });
        dispatch_resume(self.resendTimer);
    }
}

- (BOOL)isQueryTask
{
    KDSBleTunnelOrder orders[] = {KDSBleTunnelOrderGetUnlockRecord, KDSBleTunnelOrderGetUserType, KDSBleTunnelOrderGetWeekly, KDSBleTunnelOrderGetYMD, KDSBleTunnelOrderSyncKey, KDSBleTunnelOrderGetLockInfo, KDSBleTunnelOrderGetAlarmRecord, KDSBleTunnelOrderGetSN, KDSBleTunnelOrderGetTimes, KDSBleTunnelOrderGetParam, KDSBleTunnelOrderGetOpRec,KDSBleTunnelOrderSendSSID,KDSBleTunnelOrderSendPwd,KDSBleTunnelOrderSendCipherFactor,KDSBleTunnelOrderGetDisNetworkStatus,KDSBleAndWiFiCRCCheck,KDSReportResponseRemainingTimes};
    BOOL _is_ = NO;
    for (int i = 0; i < sizeof(orders) / sizeof(orders[0]); ++i)
    {
        if (orders[i] == self.order)
        {
            _is_ = YES;
            break;
        }
    }
    return _is_;
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
        void (^block)(NSData *data) = weakSelf.bleReplyBlock;
        weakSelf.bleReplyBlock = nil;
        !block ?: block(nil);
        if (weakSelf.dataInterval >= 0)
        {
            [weakSelf.recordTimer invalidate];
            weakSelf.recordTimer = nil;
        }
    });
    dispatch_resume(self.timer);
}

///如果此定时器执行，则执行bleReplyBlock回调并传达nil参数，表示当前获取记录命令结束。
- (void)recordTimerAction:(NSTimer *)timer
{
    !self.bleReplyBlock ?: self.bleReplyBlock(nil);
    [self.recordTimer invalidate];
    self.recordTimer = nil;
}

- (void)setDataInterval:(float)dataInterval
{
    _dataInterval = dataInterval;
    if (dataInterval > 0)
    {
        self.recordTimer.fireDate = [NSDate dateWithTimeIntervalSinceNow:dataInterval];
    }
    else
    {
        [_recordTimer invalidate];
        _recordTimer = nil;
    }
    
}

- (void)dealloc
{
    if (self.timer)
    {
        dispatch_source_cancel(self.timer);
        self.timer = nil;
    }
    if (self.resendTimer)
    {
        dispatch_source_cancel(self.resendTimer);
        self.resendTimer = nil;
    }
}

@end
