//
//  KDSTimelinessView.m
//  KaadasLock
//
//  Created by orange on 2019/4/1.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSTimelinessView.h"

@interface KDSTimelinessView ()

///date label
@property (nonatomic, strong) UILabel *dateLabel;
///date formatter
@property (nonatomic, strong) NSDateFormatter *fmt;

@end

@implementation KDSTimelinessView

- (NSDateFormatter *)fmt
{
    if (!_fmt)
    {
        _fmt = [[NSDateFormatter alloc] init];
    }
    return _fmt;
}

+ (instancetype)viewWithTitle:(NSString *)title date:(NSDate *)date
{
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.textColor = KDSRGBColor(0x99, 0x99, 0x99);
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.numberOfLines = 0;
    CGSize size = [title boundingRectWithSize:CGSizeMake(kScreenWidth - 30, kScreenHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : titleLabel.font} context:nil].size;
    titleLabel.frame = (CGRect){0, 0, kScreenWidth - 30, ceil(size.height)};
    KDSTimelinessView *view = [[KDSTimelinessView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 30, ceil(size.height) + 10 + 50)];
    [view addSubview:titleLabel];
    
    UIView *cornerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame) + 10, kScreenWidth - 30, 50)];
    cornerView.layer.backgroundColor = UIColor.whiteColor.CGColor;
    cornerView.layer.cornerRadius = 4;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:view action:@selector(tapDateView:)];
    [cornerView addGestureRecognizer:tap];
    [view addSubview:cornerView];
    
    UIImage *arrow = [UIImage imageNamed:@"rightArrow"];
    UIImageView *iv = [[UIImageView alloc] initWithImage:arrow];
    [cornerView addSubview:iv];
    [iv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(cornerView).offset(-12);
        make.centerY.equalTo(@0);
        make.size.mas_equalTo(arrow.size);
    }];
    
    CGFloat width = (kScreenWidth - 30 - 12 - arrow.size.width);
    view.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 50)];
    view.dateLabel.text = @"";
    view.dateLabel.textColor = KDSRGBColor(0x33, 0x33, 0x33);
    view.dateLabel.font = [UIFont systemFontOfSize:15];
    view.dateLabel.textAlignment = NSTextAlignmentCenter;
    [cornerView addSubview:view.dateLabel];
    
    view.date = date;
    
    return view;
}

- (void)setDate:(NSDate *)date
{
    _date = date;
    NSString *language = [KDSTool getLanguage];
    if ([language containsString:@"zh"])
    {
        self.fmt.dateStyle = kCFDateFormatterFullStyle;
        self.fmt.timeStyle = NSDateFormatterShortStyle;
        self.fmt.dateFormat = @"yyyyMMdd HH:mm";
        NSString *past = [self.fmt stringFromDate:date];
        NSString *now = [self.fmt stringFromDate:NSDate.date];
        if ([[past substringToIndex:8] isEqualToString:[now substringToIndex:8]])
        {
            int hour = [past substringWithRange:NSMakeRange(9, 2)].intValue;
            self.dateLabel.text = [NSString stringWithFormat:@"今天\t\t%@\t\t%d%@", hour<12 ? @"上午" : @"下午", hour<12 ? hour : hour - 12, [past substringFromIndex:11]];
        }
        else
        {
            self.fmt.dateFormat = nil;
            self.dateLabel.text = [self.fmt stringFromDate:date];
        }
    }
    else
    {
        self.fmt.dateStyle = kCFDateFormatterFullStyle;
        self.fmt.timeStyle = NSDateFormatterShortStyle;
        self.dateLabel.text = [self.fmt stringFromDate:date];
    }
}

- (void)tapDateView:(UITapGestureRecognizer *)sender
{
    !self.tapDateViewBlock ?: self.tapDateViewBlock(sender);
}

- (void)setContent:(NSString *)content
{
    _content = content;
    CGFloat width = self.dateLabel.bounds.size.width;
    UIFont *font = [UIFont systemFontOfSize:15];
    CGFloat contentWidth = ceil([content sizeWithAttributes:@{NSFontAttributeName : font}].width);
    if (contentWidth > width - 20)
    {
        font = [UIFont systemFontOfSize:15 * (width - 20) / contentWidth];
    }
    self.dateLabel.font = font;
    self.dateLabel.text = content;
}

@end
