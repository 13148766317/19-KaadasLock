//
//  KDSIncomingView.h
//  KaadasLock
//
//  Created by orange on 2019/7/19.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSIncomingView : UIView

+ (KDSIncomingView *)show:(BOOL)enabled;

///用户点击按钮交互时执行的回调。参数表示拒绝或者接受会话。
@property (nonatomic, copy) void(^userInteractiveAction) (BOOL accepted);
///显示的昵称。
@property (nonatomic, strong) NSString *nickname;

///隐藏来电界面(本视图)。
- (void)hide;

@end

NS_ASSUME_NONNULL_END
