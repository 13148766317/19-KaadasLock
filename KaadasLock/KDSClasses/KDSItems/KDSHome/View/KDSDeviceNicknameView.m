//
//  KDSDeviceNicknameView.m
//  xiaokaizhineng
//
//  Created by orange on 2019/1/25.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSDeviceNicknameView.h"

@interface UIUUIDLabel : UILabel

///uuid，一般设置为蓝牙名称。
@property (nonatomic, strong) NSString *uuid;

@end
@implementation UIUUIDLabel
@end

@interface KDSDeviceNicknameView () <UIScrollViewDelegate>

///滚动视图。
@property (nonatomic, strong) UIScrollView *scrollView;
///用来判断当前滑动时是往左还是往右还是在中间。大概逻辑：如果当前标签父视图相对于本视图原点大于标签父视图宽度一半(kScreenWidth - 60) / 3 / 2则判断开始时是往左滑，否则往右滑，停止时处于中间。有个缺点就是，当快速滑动时无法实时更改状态。-1左0中间1右。
@property (nonatomic, assign) int state;

@end

@implementation KDSDeviceNicknameView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _offsetX = 0;
        self.state = 0;
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.delegate = self;
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.scrollEnabled = NO;
        
        [self addSubview:self.scrollView];
    }
    return self;
}

#pragma mark - getter setter
- (void)setDevices:(NSArray<MyDevice *> *)devices
{
    CGFloat width = self.scrollView.bounds.size.width / 3;
    CGFloat height = self.scrollView.bounds.size.height;
    for (MyDevice *device in self.devices)//删除不存在的
    {
        UILabel *existedLabel = [self labelForDevice:device];
        if (![devices containsObject:device] && existedLabel)
        {
            [existedLabel.superview removeFromSuperview];
        }
    }
    UIUUIDLabel *(^addWrappedViewAndLabel) (MyDevice *) = ^ UIUUIDLabel * (MyDevice *dev) {
        /*
         KDSRGBColor(0x2b, 0x2f, 0x50);
         [UIFont systemFontOfSize:14];
         KDSRGBColor(0x66, 0x66, 0x66);
         [UIFont systemFontOfSize:12];
         */
        UIView *wrappedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];//设置这个是为了让label的字体2边留一定的空间中间对齐。
        wrappedView.backgroundColor = [UIColor redColor];
        UIUUIDLabel *label = [[UIUUIDLabel alloc] init];
        label.textColor = KDSRGBColor(0x2b, 0x2f, 0x50);
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentCenter;
        label.lineBreakMode = NSLineBreakByTruncatingMiddle;
//        if (dev.device_name.length >0) {
//            label.uuid = dev.device_name;
//        }
        
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapNickname:)];
        [label addGestureRecognizer:tap];
        [wrappedView addSubview:label];
        [self.scrollView addSubview:wrappedView];
        return label;
    };
    if (devices.count == 0)
    {
        for (UIView *view in self.scrollView.subviews)
        {
            [view removeFromSuperview];
        }
    }
    else if (devices.count == 1)
    {
        UIUUIDLabel *existedLabel = [self labelForDevice:devices.firstObject];
        if (!existedLabel)
        {
            existedLabel = addWrappedViewAndLabel(devices[0]);
        }
        UIView *wrappedView = existedLabel.superview;
        if (devices.firstObject.lockName) {
             existedLabel.text = devices.firstObject.lockNickName ?: devices.firstObject.lockName;
        }
        wrappedView.frame = (CGRect){0, 0, self.scrollView.bounds.size};//bounds原点会不为0？
        existedLabel.frame = wrappedView.bounds;
        self.scrollView.contentSize = self.scrollView.bounds.size;
    }
    else
    {
        NSMutableArray<__kindof UIView *> *views = [NSMutableArray arrayWithArray:self.scrollView.subviews];
        for (MyDevice *device in devices)
        {
            UIUUIDLabel *existedLabel = [self labelForDevice:device];
            if (!existedLabel)
            {
                existedLabel = addWrappedViewAndLabel(device);
                [views addObject:existedLabel.superview];
            }
            existedLabel.frame = CGRectMake(5, 0, width - 10, height);
//            if (device.device_name) {
//                    existedLabel.text = device.device_nickname ?: device.device_name;
//            }
   
            NSUInteger index = [devices indexOfObject:device];
            existedLabel.textColor = index==self.offsetX ? KDSRGBColor(0x2b, 0x2f, 0x50) : KDSRGBColor(0x66, 0x66, 0x66);
            existedLabel.font = [UIFont systemFontOfSize:index==self.offsetX ? 14 : 12];
        }
        if (views.firstObject.subviews.count != 0)
        {
            UIView *view = [[UIView alloc] init];
            [views insertObject:view atIndex:0];//在前面插入一个空白视图方便设置偏移。
            [self.scrollView insertSubview:view atIndex:0];
        }
        //self.scrollView.contentSize = CGSizeMake(views.count * width, height);
        for (NSUInteger i = 0; i < views.count; ++i)
        {
            views[i].frame = CGRectMake(i * width, 0, width, height);
        }
    }
    
    _devices = devices.copy;
}

- (void)setOffsetX:(CGFloat)offsetX
{
    _offsetX = isnan(offsetX) ? 0 : offsetX;
    if (self.devices.count <= 1)
    {
        self.scrollView.contentOffset = CGPointZero;
        UIUUIDLabel *label = [self labelForDevice:self.devices.firstObject];
        label.textColor = KDSRGBColor(0x2b, 0x2f, 0x50);
        label.font = [UIFont systemFontOfSize:14];
        return;
    }
    CGFloat width = self.scrollView.subviews.firstObject.bounds.size.width;
    self.scrollView.contentOffset = CGPointMake(width * offsetX, 0);
    //根据偏移设置标签文字颜色和字体。
    NSInteger current = offsetX, pre = current - 1, next = current + 1;
    UIUUIDLabel *currentLabel = [self labelForDevice:self.devices[current]];
    CGRect frame = [currentLabel.superview convertRect:currentLabel.superview.bounds toView:self];
    if (frame.origin.x < frame.size.width / 2 && self.state == 0)
    {
        self.state = 1;
    }
    else if (frame.origin.x > frame.size.width / 2 && self.state == 0)
    {
        self.state = -1;
    }
    if (current == 0)//第一个
    {
        CGFloat del = offsetX - current;
        currentLabel.font = [UIFont systemFontOfSize:14 - del * 2];
        currentLabel.textColor = KDSRGBColor(0x2b + del * (0x66 - 0x2b), 0x2f + del * (0x66 - 0x2f), 0x50 + del * (0x66 - 0x50));
        UIUUIDLabel *nextLabel = [self labelForDevice:self.devices[next]];
        nextLabel.textColor = KDSRGBColor(0x66 - del * (0x66 - 0x2b), 0x66 - del * (0x66 - 0x2f), 0x66 - del * (0x66 - 0x50));
        nextLabel.font = [UIFont systemFontOfSize:12 + del * 2];
        self.state = 0;
    }
    else if (current == self.devices.count - 1)//最后一个
    {
        currentLabel.textColor = KDSRGBColor(0x2b, 0x2f, 0x50);
        currentLabel.font = [UIFont systemFontOfSize:14];
        UIUUIDLabel *preLabel = [self labelForDevice:self.devices[pre]];
        preLabel.textColor = KDSRGBColor(0x66, 0x66, 0x66);
        preLabel.font = [UIFont systemFontOfSize:12];
        self.state = 0;
    }
    else if (current == offsetX)//中间且偏移为整。
    {
        currentLabel.textColor = KDSRGBColor(0x2b, 0x2f, 0x50);
        currentLabel.font = [UIFont systemFontOfSize:14];
        UIUUIDLabel *preLabel = [self labelForDevice:self.devices[pre]];
        UIUUIDLabel *nextLabel = [self labelForDevice:self.devices[next]];
        preLabel.textColor = nextLabel.textColor = KDSRGBColor(0x66, 0x66, 0x66);
        preLabel.font = nextLabel.font = [UIFont systemFontOfSize:12];
        self.state = 0;
    }
    else//中间且偏移不为整
    {
        UIUUIDLabel *nextLabel = [self labelForDevice:self.devices[next]];
        if (self.state == -1)//左滑
        {
            CGFloat del = offsetX - current;
            currentLabel.font = [UIFont systemFontOfSize:14 - del * 2];
            currentLabel.textColor = KDSRGBColor(0x2b + del * (0x66 - 0x2b), 0x2f + del * (0x66 - 0x2f), 0x50 + del * (0x66 - 0x50));
            nextLabel.textColor = KDSRGBColor(0x66 - del * (0x66 - 0x2b), 0x66 - del * (0x66 - 0x2f), 0x66 - del * (0x66 - 0x50));
            nextLabel.font = [UIFont systemFontOfSize:12 + del * 2];
        }
        else//右滑
        {
            CGFloat del = 1 - (offsetX - current);
            currentLabel.textColor = KDSRGBColor(0x66 - del * (0x66 - 0x2b), 0x66 - del * (0x66 - 0x2f), 0x66 - del * (0x66 - 0x50));
            currentLabel.font = [UIFont systemFontOfSize:12 + del * 2];
            nextLabel.font = [UIFont systemFontOfSize:14 - del * 2];
            nextLabel.textColor = KDSRGBColor(0x2b + del * (0x66 - 0x2b), 0x2f + del * (0x66 - 0x2f), 0x50 + del * (0x66 - 0x50));
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    /*CGPoint offset = scrollView.contentOffset;
    CGFloat width = scrollView.bounds.size.width / 3;
    if (offset.x < width)
    {
        [self updateScrollViewWithCenterIndex:self.index - 1];
    }
    else if (offset.x > scrollView.bounds.size.width / 3)
    {
        [self updateScrollViewWithCenterIndex:self.index + 1];
    }*/
}

///根据蓝牙名称比对标签扩展属性uuid查询是否存在过已创建好的子标签。
- (UIUUIDLabel *)labelForDevice:(MyDevice *)device
{
    if (!device) return nil;
    for (__kindof UIView *view in self.scrollView.subviews)
    {
//        UIUUIDLabel *label = view.subviews.firstObject;
//        if ([label isKindOfClass:UIUUIDLabel.class] && [device.device_name isEqualToString:label.uuid])
//        {
//            return label;
//        }
    }
    return nil;
}

#pragma mark - 控件等事件。
///点击设备昵称标签执行回调。
- (void)tapNickname:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded /*&& self.devices.count > 1*/)
    {
        UIUUIDLabel *label = (UIUUIDLabel *)sender.view;
        MyDevice *device = nil;
        for (MyDevice *dev in self.devices)
        {
            if (dev.lockName) {
                if ([dev.lockName isEqualToString:label.uuid])
                {
                    device = dev;
                    break;
                }
            }
           
        }
        !self.selectDeviceBlock ?: self.selectDeviceBlock(device);
    }
}

@end
