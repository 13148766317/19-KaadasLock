//
//  AppDelegate.h
//  KaadasLock
//
//  Created by wzr on 2019/1/15.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIApplication <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, assign) BOOL isForcePortrait;
@property (nonatomic, assign) BOOL isForceLandscape;
@property (strong, nonatomic)UILocalNotification *backgroudMsg;

- (void)setRootViewController;

@end

