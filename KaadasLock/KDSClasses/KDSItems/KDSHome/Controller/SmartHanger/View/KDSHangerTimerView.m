//
//  KDSHangerTimerView.m
//  KaadasLock
//
//  Created by Apple on 2021/4/14.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSHangerTimerView.h"
#import "UIView+Extension.h"

@interface KDSHangerTimerView()
@property(nonatomic, assign) HangerTimerChoose timerChoose;

/**
 蒙板
 */
@property (nonatomic, weak) UIView *becloudView;

@end

@implementation KDSHangerTimerView

+ (instancetype)alertView
{
    return [[[NSBundle bundleForClass:[self class]] loadNibNamed:@"KDSHangerTimerView" owner:self options:nil] lastObject];;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    //[self setCornerRadius:self];
    [self configUI];
    
    self.btn120Minute.selected = YES;

}

-(void) updateTitle:(NSString *) title {
    self.labTitle.text = title;
}
#pragma mark - 设置控件圆角
- (void)setCornerRadius:(UIView *)view
{
    
    view.layer.cornerRadius = 5.0;
    view.layer.masksToBounds = YES;
}

- (void)show
{
    self.timerChoose = HangerTimer120;
    
    [self configButton:self.btn120Minute];
    [self configButton:self.btn240Minute];
    
    // 蒙版
    UIView *becloudView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    becloudView.backgroundColor = [UIColor blackColor];
    becloudView.layer.opacity = 0.5;
    //点击蒙版是否消失弹出框
//    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAlertView:)];
//    [becloudView addGestureRecognizer:tapGR];
    
    [[UIApplication sharedApplication].keyWindow addSubview:becloudView];
    self.becloudView = becloudView;
    // 弹出框
    self.frame = CGRectMake(0, 0, KDSScreenWidth-100, 180);
    self.center = CGPointMake(becloudView.center.x, becloudView.frame.size.height * 0.5);
    [[UIApplication sharedApplication].keyWindow addSubview:self];
  
}

- (void)dismiss
{
    [self.becloudView removeFromSuperview];
    self.becloudView = nil;
    ESWeakSelf
    [UIView animateWithDuration:0.35 animations:^{
        __weakSelf.alpha = 0;
    } completion:^(BOOL finished) {
        [__weakSelf removeFromSuperview];
    }];
    
}

-(IBAction)btnCancelAction:(id)sender {
    [self dismiss];
    self.timerChoose = HangerTimerNone;
    [self callbackBlock];
}
-(IBAction)btnConfirmAction:(id)sender {
    [self dismiss];
    [self callbackBlock];
}
-(IBAction)btn120MinuteAction:(id)sender {
    self.timerChoose = HangerTimer120;
    self.btn120Minute.selected = YES;
    self.btn240Minute.selected = NO;
}
-(IBAction)btn240MinuteAction:(id)sender {
    self.timerChoose = HangerTimer240;
    self.btn120Minute.selected = NO;
    self.btn240Minute.selected = YES;
}

-(void) callbackBlock {
    if (self.blockResult) {
        self.blockResult(self.timerChoose);
    }
}

-(void) configUI {
    //self.labTitle.text = NSLocalizedString(@"", nil)
    self.layer.cornerRadius = 12.0;
    [self.btnCancel setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    [self.btnConfirm setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
}
-(void) configButton:(UIButton *) button {
    if (!button) {
        return;
    }
    [button setBackgroundImage:[KDSHangerTimerView imageWithColor:[UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1.0] view:button] forState:UIControlStateNormal];
    [button setBackgroundImage:[KDSHangerTimerView imageWithColor:[UIColor colorWithRed:31/255.0 green:150/255.0 blue:247/255.0 alpha:1.0] view:button] forState:UIControlStateSelected];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];

    button
    .layer.cornerRadius = 4.0;
    button.layer.masksToBounds = YES;
    
}

+ (UIImage *)imageWithColor:(UIColor *)color view:(UIView *) view{
   CGRect rect = CGRectMake(0.0f, 0.0f, view.width, view.height);
   UIGraphicsBeginImageContext(rect.size);
   CGContextRef context = UIGraphicsGetCurrentContext();

   CGContextSetFillColorWithColor(context, [color CGColor]);
   CGContextFillRect(context, rect);

   UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
   UIGraphicsEndImageContext();

   return image;
}
@end
