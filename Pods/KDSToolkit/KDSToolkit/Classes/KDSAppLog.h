//
//  KDSAppLog.h
//  KDSToolkit
//
//  Created by Apple on 2021/4/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSAppLog : NSObject
//配置日志按天保存文件
+(void) defaultConfig;
//开启与显示日志控制台打印
+(void) showConsole;
//隐藏日志控制台打印
+(void) hideConsole;

//日志目录
+(NSString *) logDirectory;

//压缩文件
+(BOOL) zipSrcFile:(NSString * _Nonnull) src dstFile:( NSString * _Nonnull) dst passwd:(NSString * _Nullable) passwd;
//分享文件
+(void) shareFilePath:(NSString * _Nonnull) filePath viewController:(UIViewController * _Nonnull) vc;

@end

NS_ASSUME_NONNULL_END
