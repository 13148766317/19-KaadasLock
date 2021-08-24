//
//  KDSGesturePwdView.h
//  KaadasLock
//
//  Created by zhaona on 2019/4/1.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


//外圈直径
#define outerRingDiameter 66
//内圈半径
#define innerRingRadius   32

//内容圈的半径
#define contentInnerRingRadius 7.5

//左右两边间距
#define marginLeftAndRight    32
//
#define circlePadding               98

@class KDSGesturePwdView;

@protocol KDSGesturePwdViewDelegate <NSObject>

@optional

/**
 *@abstract 手势密码绘制开始时调用，此时刚绘制第一个密码。
 *@param view 绘制手势密码的视图。
 *@param pwd 第一个绘制的密码，和绘制视图上的九宫格图片对应的1~9序号。
 */
- (void)gesturePwdViewDidBegin:(KDSGesturePwdView *)view firstPwd:(NSNumber *)pwd;

/**
 *@abstract 手势密码绘制失败时调用，此时绘制的密码数小于4个。手势绘制由于系统事件取消后不会调用此方法。
 *@param view 绘制手势密码的视图。
 *@param passwords 绘制完成的密码，和绘制视图上的九宫格图片对应的1~9序号。
 */
- (void)gesturePwdViewDidFail:(KDSGesturePwdView *)view passwords:(NSArray<NSNumber *> *)passwords;

/**
 *@abstract 手势密码绘制完成时调用，此时手势密码绘制已结束且已获取到绘制的密码。但是，绘制画面1秒后才会消失。
 @note 这个方法内不要做太耗时操作，否则1秒后绘制画面消失再判断密码错误会看不到绘制错误画面。
 *@param view 绘制手势密码的视图。
 *@param passwords 绘制完成的密码，和绘制视图上的九宫格图片对应的1~9序号。
 */
- (void)gesturePwdViewDidComplete:(KDSGesturePwdView *)view passwords:(NSArray<NSNumber *> *)passwords;

/**
 *@abstract 手势密码绘制结束时调用，此时绘制画面已经消失。如果要获取绘制完成的密码，请通过绘制完成的代理方法。
 *@param view 绘制手势密码的视图。
 */
- (void)gesturePwdViewDidEnd:(KDSGesturePwdView *)view;

@end


/**
 *@abstract 手势密码绘制视图，请使用 -initWithFrame:(CGRect)frame 方法创建对象。由于组成九宫格的视图宽高为51，间隔为47，因此设置的frame宽高应不小于51*3 + 47*2 = 247。
 *
 *手势密码绘制的原理，重点是第二步：
 *
 *1、先绘制好九宫格和对应未选中、选中、选中且带箭头、错误、错误且带箭头5张图片。
 *
 *2、重载UIResponder的touches的4个方法，拦截触摸、移动事件。选中第一个手势密码后，判断移动路径是否处于九宫格内视图，如果是，将该视图记录起来，调用setNeedsDisplay一直刷新视图，通过drawRect:方法绘制手势路线，同时调整九宫格视图的转置矩阵，使得箭头指向和绘制顺序一样。
 *
 *3、当由于系统事件取消了绘制或绘制正常结束时再调用setNeedsDisplay刷新视图，结束。
 */

@interface KDSGesturePwdView : UIView

///是否是错误的密码，请在绘制完成代理执行后再设置该属性。这个属性的getter没什么意义。
@property (nonatomic, assign) BOOL isWrongPwd;
///绘制视图代理。
@property (nonatomic, weak) id<KDSGesturePwdViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
