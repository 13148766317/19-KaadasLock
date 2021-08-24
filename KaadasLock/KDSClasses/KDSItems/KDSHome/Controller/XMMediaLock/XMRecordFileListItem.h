//
//  XMRecordFileListItem.h
//  XMDemo
//
//  Created by xunmei on 2020/9/2.
//  Copyright © 2020 TixXie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, XMTriggerType) {
    // PIR触发
    XMTriggerTypePIR   = 1 << 0,
    // 移动侦测
    XMTriggerTypeMD    = 1 << 1,
    // 人形侦测
    XMTriggerTypeHD    = 1 << 2,
};

@class XMRecordFileItem;

@interface XMRecordFileListItem : NSObject
/// 通道号
@property (nonatomic, assign) NSInteger channel;
/// 总录像文件数
@property (nonatomic, assign) NSInteger recordfilenum;
/// 录像日期
@property (nonatomic, copy) NSString *date;
/// 录像文件列表
@property (nonatomic, copy) NSArray <XMRecordFileItem *>*recordfilelist;

- (instancetype)initWithDictionary:(NSDictionary *)dic;

@end

@interface XMRecordFileItem : NSObject
/// 录像检测类型
@property (nonatomic, assign) XMTriggerType detect_type;
/// 录像开始时间戳
@property (nonatomic, assign) NSInteger stime;
/// 录像时长
@property (nonatomic, assign) NSInteger time;
/// 类型
@property (nonatomic, assign) NSInteger type;
/// 时区
@property (nonatomic, assign) NSInteger zone;
/// 文件名
@property (nonatomic, copy) NSString *file;

- (instancetype)initWithDictionary:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
