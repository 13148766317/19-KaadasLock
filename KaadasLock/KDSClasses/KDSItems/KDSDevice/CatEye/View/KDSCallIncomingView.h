//
//  KDSCallIncomingView.h
//  KaadasLock
//
//  Created by wzr on 2019/5/6.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSCallIncomingView : UIView
+ (instancetype)shareCallIncomingView;
- (void)show;
- (void)dismissView;
@property (nonatomic, strong) AVAudioPlayer *player;//铃声播放
@property (weak, nonatomic) IBOutlet UILabel *catyeNameLab;

@end

NS_ASSUME_NONNULL_END
