//
//  YGScrollTitleView.h
//  滚动视图
//
//  Created by wuyiguang on 15/12/5.
//  Copyright (c) 2015年 YG. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CallBack)(NSInteger pageIndex);

@interface YGScrollTitleView : UIView

/**
 titles   按钮的标题
 CallBack 点击头部按钮时的回调
 */
- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles callBack:(CallBack)block;

/**
 选择对应的按钮
 */
- (void)selectButtonIndex:(NSInteger)index;

/**
 设置底部线条的实时偏移量
 */
- (void)moveTopViewLine:(CGPoint)point;

/**
 设备列表。设置此属性时开始创建显示昵称的标签。
 */
@property (nonatomic, strong) NSArray<MyDevice *> *devices;




@end



