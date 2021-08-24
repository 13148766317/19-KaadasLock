//
//  KDSIncomingView.m
//  KaadasLock
//
//  Created by orange on 2019/7/19.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSIncomingView.h"
#import <AVFoundation/AVFoundation.h>

@interface KDSIncomingView ()

@property (nonatomic, strong) AVAudioPlayer *player;//铃声播放
@property (strong, nonatomic) UILabel *catyeNameLab;

@end

@implementation KDSIncomingView

+ (KDSIncomingView *)show:(BOOL)enabled
{
    KDSIncomingView *view = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [view setupSubviews];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication].keyWindow addSubview:view];
    });
    if (enabled)
    {
        [view prepareRingPlayer];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [view playRing];
        });;
    }
    return view;
}

///设置子视图。
- (void)setupSubviews
{
    UIImageView *bgIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"图层 1482"]];
    [self addSubview:bgIV];
    [bgIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self);
    }];
    
    self.catyeNameLab = [[UILabel alloc] init];
    self.catyeNameLab.textColor = UIColor.whiteColor;
    self.catyeNameLab.font = [UIFont systemFontOfSize:17];
    self.catyeNameLab.textAlignment = NSTextAlignmentCenter;
    self.catyeNameLab.numberOfLines = 0;
    [self addSubview:self.catyeNameLab];
    [self.catyeNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kStatusBarHeight + 15);
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
    }];
    
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Cat's eye_pic"]];
    [self addSubview:iv];
    [iv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kStatusBarHeight + (kScreenHeight - kStatusBarHeight) / 647.0 * 168);
        make.centerX.equalTo(self);
        make.size.mas_equalTo(iv.image.size);
    }];
    
    UILabel *tipsLabel = [UILabel new];
    tipsLabel.textColor = UIColor.whiteColor;
    tipsLabel.font = [UIFont systemFontOfSize:11];
    tipsLabel.text = Localized(@"call waiting");
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:tipsLabel];
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(iv.mas_bottom).offset(30);
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
    }];
    
    CGFloat width = 60;
    CGFloat edge = (kScreenWidth - 60*2) / 255.0 * 71;
    UIButton *declineBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    declineBtn.tag = 1;
    [declineBtn setImage:[UIImage imageNamed:@"Refuse_icon"] forState:UIControlStateNormal];
    [declineBtn addTarget:self action:@selector(acceptOrDeclineCall:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:declineBtn];
    [declineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(edge);
        make.bottom.equalTo(self).offset(-107);
        make.width.height.equalTo(@(width));
    }];
    UILabel *declineLabel = [UILabel new];
    declineLabel.text = Localized(@"call decline");
    declineLabel.font = [UIFont systemFontOfSize:11];
    declineLabel.textAlignment = NSTextAlignmentCenter;
    declineLabel.textColor = UIColor.whiteColor;
    [self addSubview:declineLabel];
    [declineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(declineBtn.mas_bottom).offset(32);
        make.centerX.equalTo(declineBtn);
    }];
    
    UIButton *acceptBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [acceptBtn setImage:[UIImage imageNamed:@"Answer_icon"] forState:UIControlStateNormal];
    [acceptBtn addTarget:self action:@selector(acceptOrDeclineCall:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:acceptBtn];
    [acceptBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-edge);
        make.bottom.equalTo(self).offset(-107);
        make.width.height.equalTo(@(width));
    }];
    UILabel *acceptLabel = [UILabel new];
    acceptLabel.text = Localized(@"call accept");
    acceptLabel.font = [UIFont systemFontOfSize:11];
    acceptLabel.textAlignment = NSTextAlignmentCenter;
    acceptLabel.textColor = UIColor.whiteColor;
    [self addSubview:acceptLabel];
    [acceptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(acceptBtn.mas_bottom).offset(32);
        make.centerX.equalTo(acceptBtn);
    }];
}

- (void)setNickname:(NSString *)nickname
{
    _nickname = nickname;
    self.catyeNameLab.text = nickname;
}

#pragma mark - 铃声相关
-(void)prepareRingPlayer{
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

#pragma mark - 控件等事件方法
///接听或者拒绝来电。接听按钮的tag是0，拒绝按钮的tag是1.
- (void)acceptOrDeclineCall:(UIButton *)sender
{
    [self hide];
    if (self.userInteractiveAction)
    {
        self.userInteractiveAction(sender.tag == 0);
    }
}

#pragma mark - 其它
- (void)hide
{
    [self stopPlayRing];
    [self removeFromSuperview];
}

@end
