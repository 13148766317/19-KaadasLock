//
//  KDSLpAssistant.h
//  KaadasLock
//
//  Created by orange on 2019/7/18.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "linphone/linphonecore.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSLpAssistant : NSObject

///是否是iPad设备。
@property (nonatomic, assign, class, readonly) BOOL isPad;

/**
 *@brief 将配置文件从路径src转移到dst
 *@param src 源绝对路径。
 *@param dst 目的绝对路径。
 *@param override 是否覆盖，如果覆盖，则使用源路径文件替换目标路径文件。
 *@return 操作是否成功。
 */
+ (BOOL)copyFile:(NSString *)src destination:(NSString *)dst override:(BOOL)override;

/**
 *@brief 在main bundle中查找名为file的文件。
 *@param file 文件名。
 *@return bundle的绝对路径。
 */
+ (nullable NSString *)bundleFile:(NSString *)file;

/**
 *@brief 在document目录中查找名为file的文件。
 *@param file 文件名。
 *@return 文件在document目录的绝对路径。
 */
+ (nullable NSString *)documentFile:(NSString *)file;

/**
 *@brief 在/Library/Preferences/linphone/目录中查找名为file的文件。
 *@param file 文件名。
 *@return 文件在/Library/Preferences/linphone/目录的绝对路径。
 */
+ (nullable NSString *)preferenceFile:(NSString *)file;

/**
 *@brief 在/Library/Application Support/linphone/目录中查找名为file的文件。
 *@param file 文件名。
 *@return 文件在/Library/Application Support/linphone/目录的绝对路径。
 */
+ (nullable NSString *)dataFile:(NSString *)file;

///下面这些方法都是从linphone设置文件中的各个部分存取设置的。默认section是[app]

+ (void)lpConfigSetString:(NSString *)value forKey:(NSString *)key forConfig:(LinphoneConfig*)cfg;

+ (void)lpConfigSetString:(NSString *)value forKey:(NSString *)key inSection:(NSString *)section forConfig:(LinphoneConfig*)cfg;

+ (NSString *)lpConfigStringForKey:(NSString *)key inConfig:(LinphoneConfig*)cfg;

+ (NSString *)lpConfigStringForKey:(NSString *)key withDefault:(NSString *)defaultValue inConfig:(LinphoneConfig*)cfg;

+ (NSString *)lpConfigStringForKey:(NSString *)key inSection:(NSString *)section inConfig:(LinphoneConfig*)cfg;

+ (NSString *)lpConfigStringForKey:(NSString *)key inSection:(NSString *)section withDefault:(NSString *)defaultValue inConfig:(LinphoneConfig*)cfg;

+ (void)lpConfigSetInt:(int)value forKey:(NSString *)key forConfig:(LinphoneConfig*)cfg;

+ (void)lpConfigSetInt:(int)value forKey:(NSString *)key inSection:(NSString *)section forConfig:(LinphoneConfig*)cfg;

+ (int)lpConfigIntForKey:(NSString *)key inConfig:(LinphoneConfig*)cfg;

+ (int)lpConfigIntForKey:(NSString *)key withDefault:(int)defaultValue inConfig:(LinphoneConfig*)cfg;

+ (int)lpConfigIntForKey:(NSString *)key inSection:(NSString *)section inConfig:(LinphoneConfig*)cfg;

+ (int)lpConfigIntForKey:(NSString *)key inSection:(NSString *)section withDefault:(int)defaultValue inConfig:(LinphoneConfig*)cfg;

+ (void)lpConfigSetBool:(BOOL)value forKey:(NSString *)key forConfig:(LinphoneConfig*)cfg;

+ (void)lpConfigSetBool:(BOOL)value forKey:(NSString *)key inSection:(NSString *)section forConfig:(LinphoneConfig*)cfg;

+ (BOOL)lpConfigBoolForKey:(NSString *)key inConfig:(LinphoneConfig*)cfg;

+ (BOOL)lpConfigBoolForKey:(NSString *)key withDefault:(BOOL)defaultValue inConfig:(LinphoneConfig*)cfg;

+ (BOOL)lpConfigBoolForKey:(NSString *)key inSection:(NSString *)section inConfig:(LinphoneConfig*)cfg;

+ (BOOL)lpConfigBoolForKey:(NSString *)key inSection:(NSString *)section withDefault:(BOOL)defaultValue inConfig:(LinphoneConfig*)cfg;

@end

NS_ASSUME_NONNULL_END
