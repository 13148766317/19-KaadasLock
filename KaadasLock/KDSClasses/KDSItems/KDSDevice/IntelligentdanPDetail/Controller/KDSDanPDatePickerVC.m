//
//  KDSDanPDatePickerVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/2/13.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSDanPDatePickerVC.h"

@interface KDSDanPDatePickerVC ()<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) UIPickerView *pickerView;
///date formatter, format HH:mm.
@property (nonatomic, strong) NSDateFormatter *fmt;

@end

@implementation KDSDanPDatePickerVC
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
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    label.text = self.titleStr;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = KDSRGBColor(0x99, 0x99, 0x99);
    label.font = [UIFont systemFontOfSize:17];
    [cornerView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cornerView).offset(24);
        make.left.equalTo(cornerView).offset(15);
        make.right.equalTo(cornerView).offset(-15);
    }];
    
    self.pickerView = [[UIPickerView alloc] init];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    [cornerView addSubview:self.pickerView];
    [self.pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cornerView).offset(58);
        make.left.bottom.right.equalTo(cornerView);
    }];
    NSArray<NSString *> *begin = [[self.fmt stringFromDate:NSDate.date] componentsSeparatedByString:@":"];
    [self.pickerView selectRow:begin.firstObject.integerValue inComponent:4 animated:NO];
    [self.pickerView selectRow:begin.lastObject.integerValue inComponent:6 animated:NO];
    
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
        NSString *beginStr = [NSString stringWithFormat:@"%02ld:%02ld", [self.pickerView selectedRowInComponent:4], [self.pickerView selectedRowInComponent:6]];
        !self.didPickupDateBlock ?: self.didPickupDateBlock(beginStr);
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
        case 4:
            return 24;
            
        case 6:
            return 60;
        
        default:
            return 1;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    switch (component)
    {
        case 4:
        case 6:
            return 40;
        case 5:
            return 15;

        default:
            return 0;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component)
    {
        case 4:
        case 6:
            return [NSString stringWithFormat:@"%02ld", (long)row];
        case 5:
            return @":";
            
        default:
            return nil;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component)
    {
        case 4:
            if ([pickerView selectedRowInComponent:5] < row)
            {
                [pickerView selectRow:row inComponent:5 animated:YES];
            }
            else if ([pickerView selectedRowInComponent:5]==row && [pickerView selectedRowInComponent:7]<[pickerView selectedRowInComponent:3])
            {
                [pickerView selectRow:[pickerView selectedRowInComponent:3] inComponent:7 animated:YES];
            }
            break;
            
        case 6:
            if ([pickerView selectedRowInComponent:5]==[pickerView selectedRowInComponent:1] && [pickerView selectedRowInComponent:7]<row)
            {
                [pickerView selectRow:row inComponent:7 animated:YES];
            }
            break;
            
        default:
            break;
    }
}

@end
