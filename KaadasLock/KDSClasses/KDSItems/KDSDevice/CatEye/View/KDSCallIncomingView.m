//
//  KDSCallIncomingView.m
//  KaadasLock
//
//  Created by wzr on 2019/5/6.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSCallIncomingView.h"
#import "LinphoneManager.h"
#import "AppDelegate.h"

@implementation KDSCallIncomingView


+ (instancetype)shareCallIncomingView{
    static KDSCallIncomingView *inComingView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"{KAADAS}--判断为(来自猫眼)--inComingView");
        inComingView =[[NSBundle mainBundle] loadNibNamed:@"KDSCallIncomingView" owner:nil options:nil].firstObject;
    });
    return inComingView;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self startRingPlayer];
    }
    return self;
}
- (void)show{
    [self playRing];
    self.frame = [UIScreen mainScreen].bounds;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}
-(void)dismissView{
    [self stopPlayRing];
    [self removeFromSuperview];
}

- (IBAction)cancelCall:(id)sender {
    [LinphoneManager.instance hangUpCall];
    [self stopPlayRing];
    [self removeFromSuperview];
}
- (IBAction)acceptCall:(id)sender {
    KDSLog(@"电话接听");
    [LinphoneManager.instance acceptCall: LinphoneManager.instance.currentCall evenWithVideo:YES];
//    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [delegate.mainTabBarController setSelectedIndex:1];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self stopPlayRing];
        [self removeFromSuperview];
    });
}

#pragma mark - 铃声播放
-(void)startRingPlayer{
    NSString *soundPath = [[NSBundle mainBundle]pathForResource:@"shortRing1" ofType:@"caf"];
    NSURL *soundUrl = [NSURL fileURLWithPath:soundPath];// 初始化播放器
    if (!_player) {
        //初始化播放器对象
        _player = [[AVAudioPlayer alloc]initWithContentsOfURL:soundUrl error:nil];
    }
    //设置声音的大小
    _player.volume = 0.5;
    //范围为（0到1）；
    //设置循环次数，如果为负数，就是无限循环
    _player.numberOfLoops =-1;
    //设置播放进度
    _player.currentTime = 0;
    //准备播放
    [_player prepareToPlay];
}
-(void)playRing{
    [self.player play];
}

-(void)stopPlayRing{
    if ([self.player isPlaying]) {
        [self.player stop];
    }
}
-(void)stopVolume{
    if ([self.player isPlaying]) {
        self.player.volume = 0;
    }
}
@end
