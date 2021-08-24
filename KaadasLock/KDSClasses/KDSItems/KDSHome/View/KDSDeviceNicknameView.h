//
//  KDSDeviceNicknameView.h
//  xiaokaizhineng
//
//  Created by orange on 2019/1/25.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyDevice.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSDeviceNicknameView : UIView

///设备列表。设置此属性时开始创建显示昵称的标签。
@property (nonatomic, strong) NSArray<MyDevice *> *devices;
///横坐标偏移比例，在[0, devices.count-1]之间。设置此属性前请先设置devices，默认值0.设置此属性同时会设置标签偏移、字体和颜色。
@property (nonatomic, assign) CGFloat offsetX;
///点击对应设备昵称执行的回调，如果只有一个设备，此回调不会执行。回调的参数是点击的设备。
@property (nonatomic, copy) void(^selectDeviceBlock) (MyDevice *device);

@end

NS_ASSUME_NONNULL_END
