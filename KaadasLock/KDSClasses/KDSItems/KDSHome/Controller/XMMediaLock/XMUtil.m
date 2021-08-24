//
//  XMUtil.m
//  XMDemo
//
//  Created by xunmei on 2020/9/1.
//  Copyright © 2020 TixXie. All rights reserved.
//

#import "XMUtil.h"
#import <Photos/Photos.h>
#import <XMStreamComCtrl/XMStreamComCtrl.h>

@implementation XMUtil

+ (BOOL)requestAuthorization:(KSystemPermissions)systemPermissions {
    switch (systemPermissions) {
        case KSystemPermissionsTypeCamera: {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
                NSString *mediaType = AVMediaTypeVideo;
                AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
                if(authStatus == AVAuthorizationStatusDenied){
                    return false;
                } else if(authStatus == AVAuthorizationStatusRestricted ){
                    return false;
                } else if (authStatus == AVAuthorizationStatusNotDetermined) {
                    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
                        
                    }];
                    return false;
                }
            }
        }
            break;
        case KSystemPermissionsTypeAlbum: {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                PHAuthorizationStatus authorizationStatus = [PHPhotoLibrary authorizationStatus];
                if (authorizationStatus == PHAuthorizationStatusRestricted) {
                    return false;
                }else if(authorizationStatus == PHAuthorizationStatusDenied){
                    return false;
                }else if (authorizationStatus == PHAuthorizationStatusNotDetermined){
                    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                        
                    }];
                    return false;
                }
            }
        }
            break;
            
        case KSystemPermissionsTypeMicrophone: {
            AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
            switch (status) {
                case AVAuthorizationStatusNotDetermined: {
                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                        
                    }];
                    return false;
                }
                    break;
                    
                case AVAuthorizationStatusRestricted: {
                    return false;
                }
                    break;
                case AVAuthorizationStatusDenied: {
                    return false;
                }
                    break;
                case AVAuthorizationStatusAuthorized: {
                    return true;
                }
                    break;
                    
                default: {
                    return false;
                }
                    break;
            }
        }
            break;
            
        default: {
            return false;
        }
            break;
    }
    
    return true;
}

+ (void)saveImageToPhotosAlbum:(UIImage *)image {
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
}

+ (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *message = @"";
    if (!error) {
        message = @"save photo successful";
    } else {
        message = [error description];
    }
    NSLog(@"imageSavedToPhotosAlbum message is %@",message);
}

+ (BOOL)saveVideoToPhotosAlbum:(NSString *)path {
    BOOL isSuccess = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path);
    if (isSuccess) {
        UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    } else {
        NSLog(@"UIVideoAtPathIsCompatibleWithSavedPhotosAlbum failed");
    }
    return isSuccess;
}

+ (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *message = @"";
    if (!error) {
        message = @"save video successful";
    } else {
        message = [error description];
    }
    NSLog(@"video didFinishSavingWithError message is %@",message);
    
}

+ (NSString *)checkPPCSErrorStringWithRet:(NSInteger)ret {
    NSString *message = @"";
    switch (ret) {
        case ERROR_PPCS_SUCCESSFUL:
            message = NSLocalizedString(@"连接成功", nil);
            break;
        case ERROR_PPCS_NOT_INITIALIZED:
            message = NSLocalizedString(@"未初始化", nil);
            break;
        case ERROR_PPCS_ALREADY_INITIALIZED:
            message = NSLocalizedString(@"已初始", nil);
            break;
        case ERROR_PPCS_TIME_OUT:
            message = NSLocalizedString(@"连接超时", nil);
            break;
        case ERROR_PPCS_INVALID_ID:
            message = NSLocalizedString(@"无效的ID", nil);
            break;
        case ERROR_PPCS_INVALID_PARAMETER:
            message = NSLocalizedString(@"无效的参数", nil);
            break;
        case ERROR_PPCS_DEVICE_NOT_ONLINE:
            message = NSLocalizedString(@"设备不在线", nil);
            break;
        case ERROR_PPCS_FAIL_TO_RESOLVE_NAME:
            message = NSLocalizedString(@"未能处理该设备名", nil);
            break;
        case ERROR_PPCS_INVALID_PREFIX:
            message = NSLocalizedString(@"无效的设备前缀", nil);
            break;
        case ERROR_PPCS_ID_OUT_OF_DATE:
            message = NSLocalizedString(@"设备ID过期", nil);
            break;
        case ERROR_PPCS_NO_RELAY_SERVER_AVAILABLE:
            message = NSLocalizedString(@"没有可用的服务器", nil);
            break;
        case ERROR_PPCS_INVALID_SESSION_HANDLE:
            message = NSLocalizedString(@"无效会话句柄", nil);
            break;
        case ERROR_PPCS_SESSION_CLOSED_REMOTE:
            message = NSLocalizedString(@"会话被设备关闭", nil);
            break;
        case ERROR_PPCS_SESSION_CLOSED_TIMEOUT:
            message = NSLocalizedString(@"会话超时关闭", nil);
            break;
        case ERROR_PPCS_SESSION_CLOSED_CALLED:
            message = NSLocalizedString(@"会话关闭", nil);
            break;
        case ERROR_PPCS_REMOTE_SITE_BUFFER_FULL:
            message = NSLocalizedString(@"远程站点缓冲区满", nil);
            break;
        case ERROR_PPCS_USER_LISTEN_BREAK:
            message = NSLocalizedString(@"用户接收中断", nil);
            break;
        case ERROR_PPCS_MAX_SESSION:
            message = NSLocalizedString(@"超出最大连接数", nil);
            break;
        case ERROR_PPCS_UDP_PORT_BIND_FAILED:
            message = NSLocalizedString(@"UDP端口绑定失败", nil);
            break;
        case ERROR_PPCS_USER_CONNECT_BREAK:
            message = NSLocalizedString(@"用户连接中断", nil);
            break;
        case ERROR_PPCS_SESSION_CLOSED_INSUFFICIENT_MEMORY:
            message = NSLocalizedString(@"会话关闭失败", nil);
            break;
        case ERROR_PPCS_INVALID_APILICENSE:
            message = NSLocalizedString(@"无效处理", nil);
            break;
        case ERROR_PPCS_FAIL_TO_CREATE_THREAD:
            message = NSLocalizedString(@"无法创建线程", nil);
            break;
        case ERROR_PPCS_INVALID_PROC:
            message = NSLocalizedString(@"无效的PROC", nil);
            break;
            
        default:
            message = NSLocalizedString(@"网络异常，视频无法连接", nil);
            break;
    }
    return message;
}

+ (NSString *)cachesPathWithWifiSN:(NSString *)wifiSn {
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"XMDemo%@",wifiSn]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

+ (NSString *)temporaryDocuments
{
    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [cachesDirectory stringByAppendingPathComponent:@"temporaryDocuments"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

@end
