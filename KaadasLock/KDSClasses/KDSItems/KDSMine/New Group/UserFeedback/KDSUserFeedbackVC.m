//
//  KDSUserFeedbackVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/1.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSUserFeedbackVC.h"
#import "MBProgressHUD+MJ.h"
#import "KDSHttpManager.h"
#import "KDSHttpManager+User.h"
#import "KDSDBManager.h"


@interface KDSUserFeedbackVC ()<UITextViewDelegate>

///三个按钮、输入框、字数的父视图
@property(nonatomic,readwrite,strong)UIView * superView;
///输入框
@property (nonatomic,readwrite,strong)UITextView *textView;
///输入框内嵌label
@property (nonatomic,readwrite,strong)UILabel * textFieldLabel;
///显示输入字数的label
@property(nonatomic,readwrite,strong)UILabel * wordNumberLabel;
///提交按钮
@property(nonatomic,readwrite,strong)UIButton * submitBtn;

@end

@implementation KDSUserFeedbackVC
#define BOOKMARK_WORD_LIMIT  300

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = Localized(@"UserFeedback");
    [self setUI];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = KDSRGBColor(242, 242, 242);
}
-(void)setUI
{
    [self.view addSubview:self.superView];
    [self.superView addSubview:self.textView];
    [self.superView addSubview:self.wordNumberLabel];
    [self.view addSubview:self.submitBtn];
    [self.textView addSubview:self.textFieldLabel];
    [self markMyConstraints];
    
    
}
-(void)markMyConstraints
{
    [self.superView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat height = KDSScreenHeight<=667?230:290;
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(height);
    }];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.superView.mas_left).offset(16);
        make.right.mas_equalTo(self.superView.mas_right).offset(-16);
        make.bottom.mas_equalTo(self.wordNumberLabel.mas_top).offset(0);
        make.top.mas_equalTo(self.superView.mas_top).offset(0);
    }];
    [self.textFieldLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.superView.mas_left).offset(30);
        make.right.mas_equalTo(self.superView.mas_right).offset(-16);
        make.top.mas_equalTo(self.superView.mas_top).offset(5);
        make.height.mas_offset(20);
    }];
    [self.wordNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(20);
        make.right.mas_equalTo(self.superView.mas_right).offset(-16);
        make.bottom.mas_equalTo(self.superView.mas_bottom).offset(-20);
    }];
    [self.submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self.superView.mas_centerX).offset(0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-KDSSSALE_HEIGHT(50));
    }];
}

#pragma mark - textviewDelegate
-(void)textViewDidChange:(UITextView *)textView{
    if (textView.text.length!=0) {
        self.textFieldLabel.hidden = YES;
        self.wordNumberLabel.text = [NSString stringWithFormat:@"%ld/300",textView.text.length];
        if (textView.text.length > BOOKMARK_WORD_LIMIT){
            textView.text = [textView.text substringToIndex:BOOKMARK_WORD_LIMIT];
            [self.textView resignFirstResponder];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD showError:Localized(@"No more than 300 characters")];
                textView.text = [textView.text substringWithRange:NSMakeRange(0, 300)];
                self.wordNumberLabel.text = [NSString stringWithFormat:@"%ld/300",textView.text.length];
            });
        }
    }else{
        self.wordNumberLabel.text = @"0/300";
    }
    
}

-(void)submitBtnClick:(UIButton *)sender
{
    NSString *validStr = [KDSTool deleteSpecialCharacters:_textView.text];
    if (validStr.length < 8) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD showError:Localized(@"No less than 8 characters")];
        });
        return;
    }
    __block NSString * title ;
    __block NSString * message;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[KDSHttpManager sharedManager] feedback:self.textView.text withUid:[KDSUserManager sharedManager].user.uid success:^{
        [hud hideAnimated:YES];
        title = Localized(@"System hint");
        message = Localized( @"Thanks for your feedback");
        [self setAlerVCTitle:title message:message];
    } error:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        title = Localized(@"System hint");
        message = Localized(@"Failure to submit");
        [self setAlerVCTitle:title message:message];
    } failure:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        title = Localized(@"System hint");
        message = Localized(@"Failure to submit");
        [self setAlerVCTitle:title message:message];
    }];
    
}

-(void)setAlerVCTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController * alserVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * action = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alserVC addAction:action];
    
    [self presentViewController:alserVC animated:YES completion:nil];
}

#pragma mark --Lazy load

-(UIView *)superView
{
    if (!_superView) {
        _superView = ({
            UIView * sp = [UIView new];
            sp.backgroundColor = [UIColor whiteColor];
            sp;
            
        });
    }
    return _superView;
}

-(UIButton *)submitBtn
{
    if (!_submitBtn) {
        _submitBtn = ({
            UIButton * submitB = [UIButton new];
            [submitB setTitle:Localized(@"Submission") forState:UIControlStateNormal];
            [submitB setBackgroundColor:KDSRGBColor(31, 150, 247)];
            submitB.layer.masksToBounds = YES;
            submitB.layer.cornerRadius = 22;
            [submitB addTarget:self action:@selector(submitBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            submitB;
        });
    }
    
    return _submitBtn;
}

-(UILabel *)wordNumberLabel
{
    if (!_wordNumberLabel) {
        _wordNumberLabel = ({
            
            UILabel * wordNumberL = [UILabel new];
            wordNumberL.text = @"0/300";
            wordNumberL.textColor = [UIColor lightGrayColor];
            wordNumberL.font = [UIFont systemFontOfSize:15];
            wordNumberL.textAlignment = NSTextAlignmentRight;
            wordNumberL;
        });
    }
    return _wordNumberLabel;
}

-(UITextView *)textView
{
    if (!_textView) {
        _textView = ({
            UITextView * tV = [UITextView new];
            tV.font = [UIFont systemFontOfSize:12];
            tV.delegate = self;
            tV.backgroundColor = [UIColor whiteColor];
            tV.textColor = KDSRGBColor(142, 142, 147);
            tV;
        });
    }
    
    return _textView;
}

-(UILabel *)textFieldLabel
{
    if (!_textFieldLabel) {
        _textFieldLabel = ({
            UILabel * tLb = [UILabel new];
            tLb.font = [UIFont systemFontOfSize:12];
            tLb.backgroundColor = [UIColor clearColor];
            tLb.textColor = KDSRGBColor(142, 142, 147);
            tLb.text =Localized(@"Please enter feedback (8 to 300 characters)") ;
            tLb.textAlignment = NSTextAlignmentLeft;
            tLb;
        });
    }
    
    return _textFieldLabel;
}


@end
