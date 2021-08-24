//
//  XMPlayBarView.h
//  XMDemo
//
//  Created by xunmei on 2020/9/1.
//  Copyright © 2020 TixXie. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, XMPlayBarViewButtonType) {
    ///截图
    XMPlayBarViewButtonTypeCut      = 0,
    ///静音
    XMPlayBarViewButtonTypeMute     = 1,
    ///语音对讲
    XMPlayBarViewButtonTypeTalk     = 2,
    ///录像
    XMPlayBarViewButtonTypeRecord   = 3,
    ///相册
    XMPlayBarViewButtonTypeAlbum    = 4,
    
};

typedef NS_ENUM(NSInteger, XMPlayBarViewButtonState) {
    XMPlayBarViewButtonStateNormal   = 0,
    XMPlayBarViewButtonStateSelected = 1,
};

@class XMPlayBarView;
@protocol XMPlayBarViewDelegate <NSObject>
@optional

- (void)XMPlayBarView:(XMPlayBarView *)view buttonClicked:(UIButton *)btn type:(XMPlayBarViewButtonType)type;

@end

@interface XMPlayBarView : UIView
@property (nonatomic, weak) id <XMPlayBarViewDelegate> delegate;
@property (nonatomic, strong) UIButton * voiceSmallBtn;
- (void)setPlayBarViewButtonType:(XMPlayBarViewButtonType)type enabled:(BOOL)enabled;
- (void)setPlayBarViewButtonType:(XMPlayBarViewButtonType)type state:(XMPlayBarViewButtonState)state;

@end

NS_ASSUME_NONNULL_END
