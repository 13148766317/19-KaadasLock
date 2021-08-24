//
//  KDSLpUIHelper.m
//  KaadasLock
//
//  Created by orange on 2019/7/22.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSLpUIHelper.h"
#import "NSTimer+KDSBlock.h"
#import "SIPUACTU.h"

@interface KDSLpFlickerView : UIView

+ (KDSLpFlickerView *)flickerView;

///The displayed tips.
@property (nonatomic, strong) NSString *tips;
///The flicker timer.
@property (nonatomic, weak) NSTimer *timer;
///the action view, can add gestures.
@property (nonatomic, weak) UIView *actionView;

///start flickering and add self to key window.
- (void)startFlickering;

///stop flickering and remove self from key window.
- (void)stopFlickering;

@end

@implementation KDSLpFlickerView

+ (KDSLpFlickerView *)flickerView
{
    KDSLpFlickerView *view = [[KDSLpFlickerView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kStatusBarHeight + kNavBarHeight)];
    UIView *flickerV = [[UIView alloc] initWithFrame:view.bounds];
    flickerV.backgroundColor = UIColor.redColor;
    flickerV.tag = 'BGRV';
    [view addSubview:flickerV];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, kStatusBarHeight, kScreenWidth - 40, kNavBarHeight)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = UIColor.whiteColor;
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:15];
    label.tag = 'LABL';
    [view addSubview:label];
    UIView *actionView = [[UIView alloc] initWithFrame:view.bounds];
    actionView.tag = 'ACTN';
    [view addSubview:actionView];
    view.actionView = actionView;
    
    return view;
}

- (void)setTips:(NSString *)tips
{
    _tips = tips;
    UILabel *label = [self viewWithTag:'LABL'];
    label.text = tips;
}

- (NSTimer *)timer
{
    if (_timer == nil)
    {
        UIView *view = [self viewWithTag:'BGRV'];
        _timer = [NSTimer kdsScheduledTimerWithTimeInterval:2 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [UIView animateWithDuration:0.9 animations:^{
                view.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.4];
            } completion:^(BOOL finished) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:0.9 animations:^{
                        view.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
                    }];
                });
            }];
        }];
    }
    return _timer;
}

- (void)startFlickering
{
    if (self.superview != nil) return;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    self.timer.fireDate = NSDate.date;
}

- (void)stopFlickering
{
    [self removeFromSuperview];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)dealloc
{
    [_timer invalidate];
    _timer = nil;
}

@end

@interface KDSLpUIHelper () <UITableViewDelegate, UITableViewDataSource>

///The flicker view at the top.
@property (nonatomic, strong) KDSLpFlickerView *flickerView;
///The table view display calls.
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation KDSLpUIHelper

#pragma mark - getter setter
- (KDSLpFlickerView *)flickerView
{
    if (_flickerView == nil)
    {
        _flickerView = [KDSLpFlickerView flickerView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFlickerViewToHideOrShowCalls:)];
        [_flickerView.actionView addGestureRecognizer:tap];
    }
    return _flickerView;
}

- (UITableView *)tableView
{
    if (_tableView == nil)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.rowHeight = 50;
        _tableView.hidden = YES;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (void)setTus:(NSArray<SIPUACTU *> *)tus
{
    _tus = [tus sortedArrayUsingComparator:^NSComparisonResult(SIPUACTU * _Nonnull obj1, SIPUACTU * _Nonnull obj2) {
        return [obj2.date compare:obj1.date];
    }];
    
    if (tus.count > 1)
    {
        [self.flickerView startFlickering];
        self.tableView.frame = CGRectMake(0, CGRectGetMaxY(self.flickerView.frame), kScreenWidth, tus.count * 50);
        int incoming = 0, paused = 0;
        for (SIPUACTU *tu in tus)
        {
            LinphoneCallState state = tu.callState;
            if (state == LinphoneCallIncomingReceived)
            {
                incoming++;
            }
            else if (state == LinphoneCallPaused)
            {
                paused++;
            }
        }
        NSMutableString *tips = [NSMutableString string];
        if (incoming > 0)
        {
            [tips appendFormat:Localized(@"%d calls are incoming"), incoming];
        }
        if (paused)
        {
            if (incoming > 0) [tips appendString:@"; "];
            [tips appendFormat:Localized(@"%d calls are paused"), paused];
        }
        self.flickerView.tips = tips;
        [self.tableView reloadData];
        if (self.tableView.superview == nil)
        {
            self.tableView.hidden = YES;
            [[UIApplication sharedApplication].keyWindow addSubview:self.tableView];
        }
    }
    else
    {
        if (tus.count == 1)
        {
            LinphoneCallState state = tus.firstObject.callState;
            if (state == LinphoneCallIncomingReceived)
            {
                [tus.firstObject showIncomingView:YES];
            }
            else if (state == LinphoneCallPaused)
            {
                [tus.firstObject resumeCall];
            }
        }
        [_flickerView stopFlickering];
        [_tableView removeFromSuperview];
    }
}

#pragma mark - 控件等事件方法。
///点击顶部的闪烁视图显示/隐藏状态暂停或者incoming的来电。
- (void)tapFlickerViewToHideOrShowCalls:(UITapGestureRecognizer *)sender
{
    self.tableView.hidden = !self.tableView.hidden;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tus.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = NSStringFromClass([self class]);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseId];
    }
    SIPUACTU *tu = self.tus[indexPath.row];
    NSMutableString *text = [NSMutableString stringWithString:tu.callID];
    LinphoneCallState state = tu.callState;
    [text appendFormat:@"(%@)", state==LinphoneCallIncomingReceived ? Localized(@"incoming call") : (state==LinphoneCallPaused ? Localized(@"paused call") : Localized(@"current call"))];
    cell.textLabel.text = text;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SIPUACTU *selected = self.tus[indexPath.row];
    LinphoneCallState state = selected.callState;
    if (state==LinphoneCallPaused || state==LinphoneCallIncomingReceived)
    {
        for (SIPUACTU *tu in self.tus)
        {
            if (tu != selected && tu.callState != LinphoneCallIncomingReceived)
            {
                [tu pauseCall];
            }
        }
        if (state == LinphoneCallPaused)
        {
            [selected resumeCall];
        }
        else
        {
            [selected showIncomingView:NO];
        }
    }
    
    tableView.hidden = YES;
}

@end
