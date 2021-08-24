//
//  KDSLpAssistant.m
//  KaadasLock
//
//  Created by orange on 2019/7/18.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSLpAssistant.h"

#define LINPHONERC_APPLICATION_KEY @"app"

@implementation KDSLpAssistant

+ (BOOL)isPad
{
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
}

+ (BOOL)copyFile:(NSString *)src destination:(NSString *)dst override:(BOOL)override {
    NSFileManager *fileManager = NSFileManager.defaultManager;
    NSError *error = nil;
    if ([fileManager fileExistsAtPath:src] == NO) {
        return FALSE;
    }
    if ([fileManager fileExistsAtPath:dst] == YES) {
        if (override) {
            [fileManager removeItemAtPath:dst error:&error];
            if (error != nil) {
                return FALSE;
            }
        } else {
            return FALSE;
        }
    }
    [fileManager copyItemAtPath:src toPath:dst error:&error];
    if (error != nil) {
        return FALSE;
    }
    return TRUE;
}

+ (NSString *)bundleFile:(NSString *)file {
    return [[NSBundle mainBundle] pathForResource:[file stringByDeletingPathExtension] ofType:[file pathExtension]];
}

+ (NSString *)documentFile:(NSString *)file {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:file];
}

+ (NSString *)preferenceFile:(NSString *)file {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *writablePath = [paths objectAtIndex:0];
    NSString *fullPath = [writablePath stringByAppendingString:@"/Preferences/linphone/"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
        NSError *error;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:fullPath
                                       withIntermediateDirectories:YES
                                                        attributes:nil
                                                             error:&error]) {
        }
    }
    
    return [fullPath stringByAppendingPathComponent:file];
}

+ (NSString *)dataFile:(NSString *)file {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *writablePath = [paths objectAtIndex:0];
    NSString *fullPath = [writablePath stringByAppendingString:@"/linphone/"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
        NSError *error;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:fullPath
                                       withIntermediateDirectories:YES
                                                        attributes:nil
                                                             error:&error]) {
        }
    }
    
    return [fullPath stringByAppendingPathComponent:file];
}

///下面这些方法都是从linphone设置文件中的各个部分存取设置的。默认section是[app]

+ (void)lpConfigSetString:(NSString *)value forKey:(NSString *)key forConfig:(LinphoneConfig*)cfg {
    [self lpConfigSetString:value forKey:key inSection:LINPHONERC_APPLICATION_KEY forConfig:cfg];
}
+ (void)lpConfigSetString:(NSString *)value forKey:(NSString *)key inSection:(NSString *)section forConfig:(LinphoneConfig*)cfg {
    if (!key || !cfg)
        return;
    lp_config_set_string(cfg, [section UTF8String], [key UTF8String], value ? [value UTF8String] : NULL);
}
+ (NSString *)lpConfigStringForKey:(NSString *)key inConfig:(LinphoneConfig*)cfg {
    return [self lpConfigStringForKey:key withDefault:nil inConfig:cfg];
}
+ (NSString *)lpConfigStringForKey:(NSString *)key withDefault:(NSString *)defaultValue inConfig:(LinphoneConfig*)cfg {
    return [self lpConfigStringForKey:key inSection:LINPHONERC_APPLICATION_KEY withDefault:defaultValue inConfig:cfg];
}
+ (NSString *)lpConfigStringForKey:(NSString *)key inSection:(NSString *)section inConfig:(LinphoneConfig*)cfg {
    return [self lpConfigStringForKey:key inSection:section withDefault:nil inConfig:cfg];
}
+ (NSString *)lpConfigStringForKey:(NSString *)key inSection:(NSString *)section withDefault:(NSString *)defaultValue inConfig:(LinphoneConfig*)cfg {
    if (!key || !cfg)
        return defaultValue;
    const char *value = lp_config_get_string(cfg, [section UTF8String], [key UTF8String], NULL);
    return value ? [NSString stringWithUTF8String:value] : defaultValue;
}

+ (void)lpConfigSetInt:(int)value forKey:(NSString *)key forConfig:(LinphoneConfig*)cfg {
    [self lpConfigSetInt:value forKey:key inSection:LINPHONERC_APPLICATION_KEY forConfig:cfg];
}
+ (void)lpConfigSetInt:(int)value forKey:(NSString *)key inSection:(NSString *)section forConfig:(LinphoneConfig*)cfg {
    if (!key || !cfg)
        return;
    lp_config_set_int(cfg, [section UTF8String], [key UTF8String], (int)value);
}
+ (int)lpConfigIntForKey:(NSString *)key inConfig:(LinphoneConfig*)cfg {
    return [self lpConfigIntForKey:key withDefault:-1 inConfig:cfg];
}
+ (int)lpConfigIntForKey:(NSString *)key withDefault:(int)defaultValue inConfig:(LinphoneConfig*)cfg {
    return [self lpConfigIntForKey:key inSection:LINPHONERC_APPLICATION_KEY withDefault:defaultValue inConfig:cfg];
}
+ (int)lpConfigIntForKey:(NSString *)key inSection:(NSString *)section inConfig:(LinphoneConfig*)cfg {
    return [self lpConfigIntForKey:key inSection:section withDefault:-1 inConfig:cfg];
}
+ (int)lpConfigIntForKey:(NSString *)key inSection:(NSString *)section withDefault:(int)defaultValue inConfig:(LinphoneConfig*)cfg {
    if (!key || !cfg)
        return defaultValue;
    return lp_config_get_int(cfg, [section UTF8String], [key UTF8String], (int)defaultValue);
}

+ (void)lpConfigSetBool:(BOOL)value forKey:(NSString *)key forConfig:(LinphoneConfig*)cfg {
    [self lpConfigSetBool:value forKey:key inSection:LINPHONERC_APPLICATION_KEY forConfig:cfg];
}
+ (void)lpConfigSetBool:(BOOL)value forKey:(NSString *)key inSection:(NSString *)section forConfig:(LinphoneConfig*)cfg {
    [self lpConfigSetInt:(int)(value == TRUE) forKey:key inSection:section forConfig:cfg];
}
+ (BOOL)lpConfigBoolForKey:(NSString *)key inConfig:(LinphoneConfig*)cfg {
    return [self lpConfigBoolForKey:key withDefault:FALSE inConfig:cfg];
}
+ (BOOL)lpConfigBoolForKey:(NSString *)key withDefault:(BOOL)defaultValue inConfig:(LinphoneConfig*)cfg {
    return [self lpConfigBoolForKey:key inSection:LINPHONERC_APPLICATION_KEY withDefault:defaultValue inConfig:cfg];
}
+ (BOOL)lpConfigBoolForKey:(NSString *)key inSection:(NSString *)section inConfig:(LinphoneConfig*)cfg {
    return [self lpConfigBoolForKey:key inSection:section withDefault:FALSE inConfig:cfg];
}
+ (BOOL)lpConfigBoolForKey:(NSString *)key inSection:(NSString *)section withDefault:(BOOL)defaultValue inConfig:(LinphoneConfig*)cfg {
    if (!key || !cfg)
        return defaultValue;
    int val = [self lpConfigIntForKey:key inSection:section withDefault:-1 inConfig:cfg];
    return (val != -1) ? (val == 1) : defaultValue;
}


@end
