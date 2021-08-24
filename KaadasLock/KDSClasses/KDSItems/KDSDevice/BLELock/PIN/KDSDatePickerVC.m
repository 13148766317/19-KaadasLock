//
//  KDSDatePickerVC.m
//  KaadasLock
//
//  Created by orange on 2019/4/2.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSDatePickerVC.h"
#import "Masonry.h"

@interface KDSDatePickerVC () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak) UIDatePicker *datePicker;
@property (nonatomic, strong) UIPickerView *pickerView;
///date formatter, format HH:mm.
@property (nonatomic, strong) NSDateFormatter *fmt;

@end

@implementation KDSDatePickerVC

- (NSDateFormatter *)fmt
{
    if (!_fmt)
    {
        _fmt = [[NSDateFormatter alloc] init];
        _fmt.dateFormat = @"HH:mm";
    }
    return _fmt;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        self.mode = 0;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIView *translucentView = [[UIView alloc] initWithFrame:self.view.bounds];
    translucentView.backgroundColor = KDSRGBColorZA(0, 0, 0, 0.5);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDismissViewController:)];
    [translucentView addGestureRecognizer:tap];
    [self.view addSubview:translucentView];
    
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    okBtn.backgroundColor = UIColor.whiteColor;
    okBtn.layer.cornerRadius = 10;
    [okBtn setTitle:Localized(@"ok") forState:UIControlStateNormal];
    [okBtn setTitleColor:KDSRGBColor(0x1f, 0x96, 0xf7) forState:UIControlStateNormal];
    okBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [okBtn addTarget:self action:@selector(clickOkBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:okBtn];
    [okBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-10);
        } else {
            make.bottom.equalTo(self.view).offset(-10);
        }
        make.height.equalTo(@57);
    }];
    
    UIView *cornerView = [UIView new];
    cornerView.backgroundColor = UIColor.whiteColor;
    cornerView.layer.cornerRadius = 10;
    [self.view addSubview:cornerView];
    [cornerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(okBtn.mas_top).offset(-10);
        make.left.right.equalTo(okBtn);
        make.height.equalTo(@175);
    }];
    UILabel *label = [UILabel new];
    label.text = Localized(@"effectiveDate");
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = KDSRGBColor(0x99, 0x99, 0x99);
    label.font = [UIFont systemFontOfSize:17];
    [cornerView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cornerView).offset(24);
        make.left.equalTo(cornerView).offset(15);
        make.right.equalTo(cornerView).offset(-15);
    }];
    
    if (self.mode == 0)
    {
        UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 58, kScreenWidth - 20, 117)];
        picker.date = self.beginDate ?: NSDate.date;
        [cornerView addSubview:picker];
        self.datePicker = picker;
    }
    else
    {
        self.pickerView = [[UIPickerView alloc] init];
        self.pickerView.dataSource = self;
        self.pickerView.delegate = self;
        [cornerView addSubview:self.pickerView];
        [self.pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cornerView).offset(58);
            make.left.bottom.right.equalTo(cornerView);
        }];
//        NSArray<NSString *> *begin = [[self.fmt stringFromDate:self.beginDate ?: NSDate.date] componentsSeparatedByString:@":"];
//        NSArray<NSString *> *end = [[self.fmt stringFromDate:self.endDate ?: NSDate.date] componentsSeparatedByString:@":"];
        [self.pickerView selectRow:0 inComponent:1 animated:NO];
        [self.pickerView selectRow:0 inComponent:3 animated:NO];
        [self.pickerView selectRow:23 inComponent:5 animated:NO];
        [self.pickerView selectRow:59 inComponent:7 animated:NO];
    }
}

#pragma mark - 控件等事件方法。
///点击半透视图销毁控制器。
- (void)tapToDismissViewController:(UITapGestureRecognizer *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

///点击确定按钮。
- (void)clickOkBtnAction:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        NSDate *beginDate = nil, *endDate = nil;
        if (self.mode == 0)
        {
            beginDate = self.datePicker.date;
        }
        else
        {
            NSString *beginStr = [NSString stringWithFormat:@"%02ld:%02ld", (long)[self.pickerView selectedRowInComponent:1], (long)[self.pickerView selectedRowInComponent:3]];
            NSString *endStr = [NSString stringWithFormat:@"%02ld:%02ld", (long)[self.pickerView selectedRowInComponent:5], (long)[self.pickerView selectedRowInComponent:7]];
            beginDate = [self.fmt dateFromString:beginStr];
            endDate = [self.fmt dateFromString:endStr];
        }
        !self.didPickupDateBlock ?: self.didPickupDateBlock(beginDate, endDate);
    }];
}

#pragma mark - UIPickerViewDataSource, UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 9;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component)
    {
        case 1:
        case 5:
            return 24;
            
        case 3:
        case 7:
            return 60;
        
        default:
            return 1;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    switch (component)
    {
            
        case 0:
        case 8:
            return pickerView.bounds.size.width / 4 - 47;
            
        case 1:
        case 3:
        case 5:
        case 7:
            return 40;
            
        case 2:
        case 6:
            return 15;
            
        default:
            return pickerView.bounds.size.width - (pickerView.bounds.size.width / 4 - 47 + 40 + 15 + 50) * 2;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component)
    {
        case 1:
        case 3:
        case 5:
        case 7:
            return [NSString stringWithFormat:@"%02ld", (long)row];
            
        case 2:
        case 6:
            return @":";
            
        default:
            return nil;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component)
    {
        case 1:
            if ([pickerView selectedRowInComponent:1]==[pickerView selectedRowInComponent:5] && [pickerView selectedRowInComponent:5]<=row)
            {
                if (row == 23) {
                    [pickerView selectRow:0 inComponent:1 animated:YES];
                }
                else{
                    [pickerView selectRow:row+1 inComponent:5 animated:YES];
                }
            }
            break;
            
        case 3:
            if ([pickerView selectedRowInComponent:5]==[pickerView selectedRowInComponent:1] && [pickerView selectedRowInComponent:7]<=row)
            {
                if (row == 59) {
                    [pickerView selectRow:0 inComponent:3 animated:YES];
                }
                else{
                    [pickerView selectRow:row+1 inComponent:7 animated:YES];
                }
            }
            break;
            
        case 5:
            if ([pickerView selectedRowInComponent:3]==[pickerView selectedRowInComponent:7] && [pickerView selectedRowInComponent:1] >= row)
            {
                if (row == 0) {
                    [pickerView selectRow:23 inComponent:5 animated:YES];
                }
                else{
                    [pickerView selectRow:row-1 inComponent:1 animated:YES];
                }
            }
            else if ([pickerView selectedRowInComponent:5] == 0 && [pickerView selectedRowInComponent:7] == 0){
                [pickerView selectRow:23 inComponent:5 animated:YES];
            }
            break;
            
        case 7:
            if ([pickerView selectedRowInComponent:5]==[pickerView selectedRowInComponent:1] && [pickerView selectedRowInComponent:3]>=row)
            {
                if (row == 0) {
                    [pickerView selectRow:59 inComponent:7 animated:YES];
                }
                else{
                    [pickerView selectRow:row-1 inComponent:3 animated:YES];
                }
            }
            else if ([pickerView selectedRowInComponent:5] == 0 && [pickerView selectedRowInComponent:7] == 0){
                [pickerView selectRow:59 inComponent:7 animated:YES];
            }
            break;
        default:
            break;
    }
}

@end
