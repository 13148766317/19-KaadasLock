//
//  KDSAppLog.m
//  KDSToolkit
//
//  Created by Apple on 2021/4/22.
//

#import "KDSAppLog.h"
#import <LumberjackConsole/PTEDashboard.h>
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "KDSAppLogFormatter.h"
@import SSZipArchive;

@implementation KDSAppLog

//配置日志保存与打印格式
+(void) defaultConfig {
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];
    
    //增加方法名
    KDSAppLogFormatter *logFormatter = [[KDSAppLogFormatter alloc] init];
    [DDTTYLogger sharedInstance].logFormatter = logFormatter;
    fileLogger.logFormatter = logFormatter;
    
}
//开启与显示日志控制台打印
+(void) showConsole {
    [[PTEDashboard sharedDashboard] show];
}
//隐藏日志控制台打印
+(void) hideConsole {
    [[PTEDashboard sharedDashboard] hide];
}

+(NSString *) logDirectory {
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
           //获取log文件夹路径
    NSString *logDirectory = [fileLogger.logFileManager logsDirectory];
    return logDirectory;
}

//压缩文件
+(BOOL) zipSrcFile:(NSString * _Nonnull) src dstFile:( NSString * _Nonnull) dst passwd:(NSString * _Nullable) passwd {

    
    if (passwd) {
        return [SSZipArchive createZipFileAtPath:dst withContentsOfDirectory:src withPassword:passwd];
    }else {
        return [SSZipArchive createZipFileAtPath:dst withContentsOfDirectory:src];
    }
    
}
//分享文件
+(void) shareFilePath:(NSString * _Nonnull) filePath viewController:(UIViewController *) vc {
    BOOL result = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    if (result && vc) {
        NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
        
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[NSLocalizedString(@"发送文件", nil),fileUrl] applicationActivities:nil];
        [vc presentViewController:activityViewController animated:YES completion:nil];
    }else {
        
        if (vc) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"内容为空",nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            [vc presentViewController:alertController animated:YES completion:nil];
        }
        
    }
}


@end
