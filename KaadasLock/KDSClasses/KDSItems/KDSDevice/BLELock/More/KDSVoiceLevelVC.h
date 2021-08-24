//
//  KDSVoiceLevelVC.h
//  KaadasLock
//
//  Created by Frank Hu on 2021/6/9.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSAutoConnectViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSVoiceLevelVC : KDSAutoConnectViewController

///显示音量水平的回调
@property (nonatomic, copy) void (^voiceLevelChangeBlock)(int newVoiceLevel);

@end

NS_ASSUME_NONNULL_END
