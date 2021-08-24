//
//  XMUtil.h
//  XMDemo
//
//  Created by xunmei on 2020/9/1.
//  Copyright © 2020 TixXie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, KSystemPermissions) {
    /// 相机
    KSystemPermissionsTypeCamera = 0,
    /// 相册
    KSystemPermissionsTypeAlbum,
    /// 麦克风🎤
    KSystemPermissionsTypeMicrophone,
};

#define WeakSelf  __weak typeof(self) weakSelf = self;
#define AERVICE_STRING  @"EBGDEJBJKEJLGHJKEIHCFMEDHENOHINHHHFOBCCGAAJOLJKNDIAFDDPGGELGIGLNAJNDKJCNPJNDAL" //@"EBGDEIBIKEJPGDJMEBHLFFEJHPNFHGNMGBFHBPCIAOJJLGLIDEABCKOOGILMJFLJAOMLLMDIOLMGBMCGIO"

#define SIZE_STATUBAR_HEIGHT CGRectGetHeight([UIApplication sharedApplication].statusBarFrame)                  // 状态栏高度
#define SIZE_NAVIGATIONBAR_HEIGHT CGRectGetHeight(self.navigationController.navigationBar.frame)                // 导航栏高度
#define SIZE_TABBAR_HEIGHT CGRectGetHeight(self.tabBarController.tabBar.frame)                                  // 标签栏高度
#define SIZE_SCREEN_WIDTH CGRectGetWidth([[UIScreen mainScreen] bounds])                                        // 全屏宽度
#define SIZE_SCREEN_HEIGHT CGRectGetHeight([[UIScreen mainScreen] bounds])                                      // 全屏高度

@interface XMUtil : NSObject

+ (BOOL)requestAuthorization:(KSystemPermissions)systemPermissions;

+ (void)saveImageToPhotosAlbum:(UIImage *)image;

+ (BOOL)saveVideoToPhotosAlbum:(NSString *)path;

+ (NSString *)checkPPCSErrorStringWithRet:(NSInteger)ret;

+ (NSString *)cachesPathWithWifiSN:(NSString *)wifiSn;

///视频通话页面（跳转相册、设置）时存放视频最后一帧的图片地址
+ (NSString *)temporaryDocuments;
@end

NS_ASSUME_NONNULL_END
