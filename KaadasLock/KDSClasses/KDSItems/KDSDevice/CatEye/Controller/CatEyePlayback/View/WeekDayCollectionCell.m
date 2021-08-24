//
//  WeekDayCollectionCell.h
//  KaadasLock
//
//  Created by zhaona on 2019/4/16.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "WeekDayCollectionCell.h"
#import "Masonry.h"

@implementation WeekDayCollectionCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 4;
        [self addMySubViews];
        [self addMyConstrains];
    }
    return self;
}
-(void)addMySubViews{
    [self.contentView addSubview:self.weekDayLbl];
    [self.contentView addSubview:self.dayLbl];
}
-(void)addMyConstrains{
    [self.weekDayLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(16);
    }];
    [self.dayLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(16);
    }];
}
#pragma mark -- lazy load
- (UILabel *)weekDayLbl{
    if (!_weekDayLbl) {
        _weekDayLbl = ({
            UILabel *ll = [UILabel new];
            ll.textColor = [UIColor blackColor];
            ll.font = [UIFont systemFontOfSize:16];
            ll.textAlignment = NSTextAlignmentCenter;
            ll;
        });
    }
    return _weekDayLbl;
}
-(UILabel *)dayLbl{
    if (!_dayLbl) {
        _dayLbl = ({
            UILabel *ll = [UILabel new];
            ll.font = [UIFont systemFontOfSize:16];
            ll.textAlignment = NSTextAlignmentCenter;
            ll;
        });
    }
    return _dayLbl;
}
+ (NSString *)ID{
    return @"WeekDayCollectionCell";
}
@end
