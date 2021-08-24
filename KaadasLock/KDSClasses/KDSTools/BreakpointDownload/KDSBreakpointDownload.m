//
//  KDSBreakpointDownload.m
//  lock
//
//  Created by Frank Hu on 2019/3/2.
//  Copyright © 2019 zhao. All rights reserved.
//

#import "KDSBreakpointDownload.h"
 // 获取Documents目录路径
#define PATHDOCUMNT  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]
NSString * const KDSBreakpointDownloadEventNotification = @"KDSBreakpointDownloadEventNotification";

@implementation KDSBreakpointDownload

static KDSBreakpointDownload *downloadSession;
static dispatch_once_t onceToken;

#pragma mark - 单例创建manager
+ (instancetype)manager{
    return [[self alloc] init];
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    dispatch_once(&onceToken, ^{
        downloadSession = [super allocWithZone:zone];
    });
    return downloadSession;
}
- (id)copyWithZone:(NSZone *)zone{
    return downloadSession;
}
#pragma mark - 单例销毁manager
+(void)attemptDealloc{
    onceToken = 0; // 只有置成0,GCD才会认为它从未执行过.它默认为0.这样才能保证下次再次调用shareInstance的时候,再次创建对象.
    downloadSession = nil;
}
/**
 *  session的懒加载
 */
- (NSURLSession *)session
{
    if (nil == _session) {
        
        NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:cfg delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}
/**
 *  session的懒加载
 */
- (NSMutableArray *)downloadSources
{
    if (nil == _downloadSources) {
        
        self.downloadSources = [NSMutableArray new];
    }
    return _downloadSources;
}
/**
 *  session的懒加载
 */
- (NSMutableArray *)fromStringSources
{
    
    if (nil == _fromStringSources) {
        
        self.fromStringSources = [NSMutableArray new];
    }
    return _fromStringSources;
}
/**
 *  从0开始下载
 */
- (void)startDownloadWithURL:(NSString *)URL fromWhere:(nonnull NSString *)fromStr
{
    NSLog(@"--kaadas--33URL=%@",URL);
    NSURL* url = [NSURL URLWithString:URL];
    NSLog(@"--kaadas--33url=%@",url);
    // 创建任务
    NSURLSessionDownloadTask *task = [self.session downloadTaskWithURL:url];
    NSLog(@"--kaadas--33task=%@",task);
    [(NSMutableArray *)self.downloadSources addObject:task];
    [(NSMutableArray *)self.fromStringSources addObject:fromStr];
    [self URLSession:self.session downloadTask:self.downloadTask didFinishDownloadingToURL:url];
    // 开始任务
    [task resume];
}
/**
 *  恢复下载
 */
- (void)resume
{
    // 传入上次暂停下载返回的数据，就可以恢复下载
    self.downloadTask = [self.session downloadTaskWithResumeData:self.resumeData];

    [self.downloadTask resume]; // 开始任务

    self.resumeData = nil;
}

/**
 *  暂停
 */
- (void)pause
{
    __weak typeof(self) selfVc = self;
    [self.downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
        //  resumeData : 包含了继续下载的开始位置\下载的url
        selfVc.resumeData = resumeData;
        selfVc.downloadTask = nil;
    }];
}

#pragma mark -- NSURLSessionDownloadDelegate
/**
 *  下载完毕会调用
 *
 *  @param location     文件临时地址
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    // 获取Documents目录路径
    NSString *docDir = PATHDOCUMNT;
    // response.suggestedFilename ： 建议使用的文件名，一般跟服务器端的文件名一致
    NSString *file = [docDir stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    // 将临时文件剪切或者复制docDir文件夹
    NSFileManager *mgr = [NSFileManager defaultManager];
    // AtPath : 剪切前的文件路径
    // ToPath : 剪切后的文件路径
    [mgr moveItemAtPath:location.path toPath:file error:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        for (NSURLSessionDownloadTask *task in self.downloadSources) {
            if (task == downloadTask) {
                for (NSString *fromString in self.fromStringSources) {
                    if ([fromString isEqualToString:@"fromDFU"]) {
                        [[NSUserDefaults standardUserDefaults] setObject:downloadTask.response.suggestedFilename forKey:BluetoothBinP6];
                //        [[NSUserDefaults standardUserDefaults] synchronize];
                        KDSLog(@"--{Kaadas}--==存储路径==%@,%@,%@",file,downloadTask.response.suggestedFilename,fromString);
                        if (_delegate && [_delegate respondsToSelector:@selector(breakpointDownloadDone)]) {
                               ///通知代理下载完成
                               [_delegate breakpointDownloadDone];
                           }
                        [(NSMutableArray *)self.downloadSources removeObject:task];
                        [(NSMutableArray *)self.fromStringSources removeObject:fromString];

                        return ;
                    }else{
                        
                        if ([fromString isEqualToString:@"fromSoftWareOAD"]) {
                            [[NSUserDefaults standardUserDefaults] setObject:downloadTask.response.suggestedFilename forKey:BluetoothBin];
                            KDSLog(@"--{Kaadas}--==存储路径==%@,%@,%@",file,downloadTask.response.suggestedFilename,fromString);
                            if (_delegate && [_delegate respondsToSelector:@selector(breakpointDownloadDone)]) {
                                   ///通知代理下载完成
                                   [_delegate breakpointDownloadDone];
                               }
                            [(NSMutableArray *)self.downloadSources removeObject:task];
                            [(NSMutableArray *)self.fromStringSources removeObject:fromString];
                            return ;
                        }
                        if ([fromString isEqualToString:@"fromStackOAD"]) {
                            [[NSUserDefaults standardUserDefaults] setObject:downloadTask.response.suggestedFilename forKey:BluetoothProtocolStack];
                            KDSLog(@"--{Kaadas}--==存储路径==%@,%@,%@",file,downloadTask.response.suggestedFilename,fromString);
                            if (_delegate && [_delegate respondsToSelector:@selector(breakpointDownloadDone)]) {
                                   ///通知代理下载完成
                                   [_delegate breakpointDownloadDone];
                               }
                            [(NSMutableArray *)self.downloadSources removeObject:task];
                            [(NSMutableArray *)self.fromStringSources removeObject:fromString];
                            return ;
                        }
                    }
                }
            }
        }
    });
    
    
   
}

/**
 *  每次写入沙盒完毕调用
 *  在这里面监听下载进度，totalBytesWritten/totalBytesExpectedToWrite
 *
 *  @param bytesWritten              这次写入的大小
 *  @param totalBytesWritten         已经写入沙盒的大小
 *  @param totalBytesExpectedToWrite 文件总大小
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:@{@"progress" : [NSString stringWithFormat:@"%f",(double)totalBytesWritten/totalBytesExpectedToWrite]}];
    [[NSNotificationCenter defaultCenter] postNotificationName:KDSBreakpointDownloadEventNotification object:nil userInfo:info.copy];

}

/**
 *  恢复下载后调用，
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}

@end
