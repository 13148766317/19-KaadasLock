//
//  KDSBreakpointDownload.h
//  lock
//
//  Created by Frank Hu on 2019/3/2.
//  Copyright © 2019 zhao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BreakpointDownloadDelegate <NSObject>
@optional
/**
 断点下载完成
 */
-(void)breakpointDownloadDone;

@end

typedef void (^KDSBreakpointDownloadBlock)(NSDictionary *dict);

@interface KDSBreakpointDownload : NSObject<NSURLSessionDownloadDelegate>
///断点下载代理
@property (nonatomic, weak) id <BreakpointDownloadDelegate> delegate;
/**
 *下载任务数组
 */
@property (strong, nonatomic) NSMutableArray *downloadSources;
/**
 *  下载任务
 */
@property (nonatomic, strong) NSURLSessionDownloadTask* downloadTask;
/**
 *  resumeData记录下载位置
 */
@property (nonatomic, strong) NSData* resumeData;
/**
 *  session
 */
@property (nonatomic, strong) NSURLSession* session;
/**
 *发起下载数组
 */
@property (strong, nonatomic) NSMutableArray *fromStringSources;
@property (nonatomic, strong) NSString * fromString;
///创建单例
+ (instancetype )manager;
///单例销毁manager
+(void)attemptDealloc;

/**
 *  开始下载
 */
- (void)startDownloadWithURL:(NSString *)URL fromWhere:(NSString *)fromStr;

/**
 *  恢复下载
 */
- (void)resume;
/**
 *  暂停
 */
- (void)pause;

#pragma mark - 通知
///断点下载进度通知
FOUNDATION_EXTERN NSString * const KDSBreakpointDownloadEventNotification;

@end

NS_ASSUME_NONNULL_END
