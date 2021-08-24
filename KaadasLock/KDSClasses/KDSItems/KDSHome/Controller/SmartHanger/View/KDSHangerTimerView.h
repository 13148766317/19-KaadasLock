//
//  KDSHangerTimerView.h
//  KaadasLock
//
//  Created by Apple on 2021/4/14.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HangerTimerChoose) {
    HangerTimerNone,
    HangerTimer120,
    HangerTimer240,
};
@interface KDSHangerTimerView : UIView

@property (nonatomic, weak) IBOutlet UILabel *labTitle;
@property (nonatomic, weak) IBOutlet UIButton *btnCancel;
@property (nonatomic, weak) IBOutlet UIButton *btnConfirm;
@property (nonatomic, weak) IBOutlet UIButton *btn120Minute;
@property (nonatomic, weak) IBOutlet UIButton *btn240Minute;

@property(nonatomic, copy) void (^blockResult)(HangerTimerChoose timerChoose);

-(IBAction)btnCancelAction:(id)sender;
-(IBAction)btnConfirmAction:(id)sender;
-(IBAction)btn120MinuteAction:(id)sender;
-(IBAction)btn240MinuteAction:(id)sender;


/**
 初始化
 */
+ (instancetype)alertView;

-(void) updateTitle:(NSString *) title;
/**
 显示
 */
- (void)show;
/**
 隐藏
 */
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
