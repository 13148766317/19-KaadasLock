//
//  KDSFTIndicator.m
//  lock
//
//  Created by zhaowz on 2017/12/6.
//  Copyright © 2017年 zhao. All rights reserved.
//

#import "KDSFTIndicator.h"
#import "FTIndicator.h"

@implementation KDSFTIndicator

/**
 *  setIndicatorStyleToDefaultStyle
 */
+ (void)setIndicatorStyleToDefaultStyle{
    [FTIndicator setIndicatorStyleToDefaultStyle];
}
/**
 *  setIndicatorStyle
 *
 *  @param style UIBlurEffectStyle style
 */
+ (void)setIndicatorStyle:(UIBlurEffectStyle)style{
    [FTIndicator setIndicatorStyle:style];
}

/**
 *  FTToastIndicator
 */
#pragma mark - FTToastIndicator

/**
 *  showToastMessage
 *
 *  @param toastMessage NSString toastMessage
 */
+ (void)showToastMessage:(NSString *)toastMessage{
    [FTIndicator showToastMessage:toastMessage];
}

/**
 *  dismissToast
 */
+ (void)dismissToast{
    [FTIndicator dismissToast];
}

/**
 *  FTProgressIndicator
 */
#pragma mark - FTProgressIndicator
/**
 *  showProgressWithMessage
 *
 *  @param message message
 */
+ (void)showProgressWithMessage:(NSString *)message{
    [FTIndicator showProgressWithMessage:message];
}

/**
 *  showProgressWithMessage userInteractionEnable
 *
 *  @param message               message
 *  @param userInteractionEnable userInteractionEnable
 */
+ (void)showProgressWithMessage:(NSString *)message userInteractionEnable:(BOOL)userInteractionEnable{
    [FTIndicator showProgressWithMessage:message userInteractionEnable:userInteractionEnable];
}

/**
 *  showInfoWithMessage
 *
 *  @param message NSString message
 */
+ (void)showInfoWithMessage:(NSString *)message{
    [FTIndicator showInfoWithMessage:message]; 
}

/**
 *  showInfoWithMessage userInteractionEnable
 *
 *  @param message               message
 *  @param userInteractionEnable userInteractionEnable
 */
+ (void)showInfoWithMessage:(NSString *)message userInteractionEnable:(BOOL)userInteractionEnable{
    [FTIndicator showInfoWithMessage:message userInteractionEnable:userInteractionEnable];
}

/**
 showInfoWithMessage image userInteractionEnable
 
 @param message message
 @param image image
 @param userInteractionEnable userInteractionEnable
 */
+ (void)showInfoWithMessage:(NSString *)message image:(UIImage *)image userInteractionEnable:(BOOL)userInteractionEnable{
    [FTIndicator showInfoWithMessage:message image:image userInteractionEnable:userInteractionEnable];
}

/**
 *  showSuccessWithMessage
 *
 *  @param message NSString message
 */
+ (void)showSuccessWithMessage:(NSString *)message{
    [FTIndicator showSuccessWithMessage:message];
}

/**
 *  showSuccessWithMessage userInteractionEnable
 *
 *  @param message               message
 *  @param userInteractionEnable userInteractionEnable
 */
+ (void)showSuccessWithMessage:(NSString *)message userInteractionEnable:(BOOL)userInteractionEnable{
    [FTIndicator showSuccessWithMessage:message userInteractionEnable:userInteractionEnable];
}

/**
 showSuccessWithMessage image userInteractionEnable
 
 @param message message
 @param image image
 @param userInteractionEnable userInteractionEnable
 */
+ (void)showSuccessWithMessage:(NSString *)message image:(UIImage *)image userInteractionEnable:(BOOL)userInteractionEnable{
    [FTIndicator showSuccessWithMessage:message image:image userInteractionEnable:userInteractionEnable];
}

/**
 *  showErrorWithMessage
 *
 *  @param message NSString message
 */
+ (void)showErrorWithMessage:(NSString *)message{
    [FTIndicator showErrorWithMessage:message];
}

/**
 *  showErrorWithMessage userInteractionEnable
 *
 *  @param message               message
 *  @param userInteractionEnable userInteractionEnable
 */
+ (void)showErrorWithMessage:(NSString *)message userInteractionEnable:(BOOL)userInteractionEnable{
    [FTIndicator showErrorWithMessage:message userInteractionEnable:userInteractionEnable];
}

/**
 showErrorWithMessage image userInteractionEnable
 
 @param message message
 @param image image
 @param userInteractionEnable userInteractionEnable
 */
+ (void)showErrorWithMessage:(NSString *)message image:(UIImage *)image userInteractionEnable:(BOOL)userInteractionEnable{
    [FTIndicator showErrorWithMessage:message image:image userInteractionEnable:userInteractionEnable];
}

/**
 *  dismissProgress
 */
+ (void)dismissProgress{
    [FTIndicator dismissProgress];
}

/**
 *  FTNotificationIndicator
 */
#pragma mark - FTNotificationIndicator
/**
 *  showNotificationWithTitle
 *
 *  @param title   title
 *  @param message message
 */
+ (void)showNotificationWithTitle:(NSString *)title message:(NSString *)message{
    [FTIndicator showNotificationWithTitle:title message:message];
}
/**
 *  showNotificationWithTitle message tapHandler
 *
 *  @param title      title
 *  @param message    message
 *  @param tapHandler tapHandler
 */
+ (void)showNotificationWithTitle:(NSString *)title message:(NSString *)message tapHandler:(FTNotificationTapHandler)tapHandler{
    [FTIndicator showNotificationWithTitle:title message:message tapHandler:tapHandler];
}
/**
 *  showNotificationWithTitle message tapHandler completion
 *
 *  @param title   title
 *  @param message message
 *  @param tapHandler tapHandler
 */
+ (void)showNotificationWithTitle:(NSString *)title message:(NSString *)message tapHandler:(FTNotificationTapHandler)tapHandler completion:(FTNotificationCompletion)completion{
    [FTIndicator showNotificationWithTitle:title message:message tapHandler:tapHandler completion:completion];
}
/**
 *  showNotificationWithImage title message
 *
 *  @param image   image
 *  @param title   title
 *  @param message message
 */
+ (void)showNotificationWithImage:(UIImage *)image title:(NSString *)title message:(NSString *)message{
    [FTIndicator showNotificationWithImage:image title:title message:message];
}
/**
 *  showNotificationWithImage title message tapHandler
 *
 *  @param image      image
 *  @param title      title
 *  @param message    message
 *  @param tapHandler tapHandler
 */
+ (void)showNotificationWithImage:(UIImage *)image title:(NSString *)title message:(NSString *)message tapHandler:(FTNotificationTapHandler)tapHandler{
    [FTIndicator showNotificationWithImage:image title:title message:message tapHandler:tapHandler];
}
/**
 *  showNotificationWithImage title message tapHandler completion
 *
 *  @param image   image
 *  @param title   title
 *  @param message message
 *  @param tapHandler tapHandler
 */
+ (void)showNotificationWithImage:(UIImage *)image title:(NSString *)title message:(NSString *)message tapHandler:(FTNotificationTapHandler)tapHandler completion:(FTNotificationCompletion)completion{
    [FTIndicator showNotificationWithImage:image title:title message:message tapHandler:tapHandler completion:completion];
}
/**
 showNotificationWithImage title message autoDismiss tapHandler completion
 
 !!!!!!!!!  Only this method suports not dismiss automatically, user has to tap or swipe to dismiss.
 
 @param image image
 @param title title
 @param message message
 @param autoDismiss autoDismiss
 @param tapHandler tapHandler
 @param completion completion
 */
+ (void)showNotificationWithImage:(UIImage *)image title:(NSString *)title message:(NSString *)message autoDismiss:(BOOL)autoDismiss tapHandler:(FTNotificationTapHandler)tapHandler completion:(FTNotificationCompletion)completion{
    [FTIndicator showNotificationWithImage:image title:title message:message autoDismiss:autoDismiss tapHandler:tapHandler completion:completion];
}
/**
 *  dismissNotification
 */
+ (void)dismissNotification{
    [FTIndicator dismissNotification];

}

@end
