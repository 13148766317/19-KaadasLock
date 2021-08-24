//
//  CYCircularSlider.h
//  CYCircularSlider
//
//  Created by user on 2018/3/23.
//  Copyright © 2018年 com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol senderValueChangeDelegate <NSObject>

-(void)senderVlueWithNum:(int)num;

@end

@interface CYCircularSlider : UIControl

///实现按钮颜色
@property (nonatomic, strong) UIColor* filledColor;
 ///空心按钮颜色
@property (nonatomic, strong) UIColor* unfilledColor;
///按钮的颜色
@property (nonatomic, strong) UIColor* handleColor;
///最小值
@property (nonatomic ,assign) float minimumValue;
///最大值
@property (nonatomic, assign) float maximumValue;
///当前值
@property (nonatomic, assign) float currentValue;
///圈边宽度
@property (nonatomic, assign) int lineWidth;
///显示进度条的值
@property (nonatomic, strong) UILabel * sliderValueLb;
///loading...
@property (nonatomic, strong) UILabel * tipsLb;
@property (nonatomic,weak) id<senderValueChangeDelegate> delegate;


-(void)setAngel:(int)num;

-(void)setAddAngel;

-(void)setMovAngel;

-(void)setAngleCurrent:(int)num;


@end
