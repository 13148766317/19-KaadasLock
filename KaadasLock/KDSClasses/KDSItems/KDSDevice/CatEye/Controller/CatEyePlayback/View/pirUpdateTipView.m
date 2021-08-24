//
//  PirUpdateTipView.m
//  lock
//
//  Created by wzr on 2019/4/18.
//  Copyright © 2019 zhao. All rights reserved.
//

#import "PirUpdateTipView.h"

@implementation PirUpdateTipView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self = [[NSBundle mainBundle] loadNibNamed:@"PirUpdateTipView" owner:self options:nil][0];
        self.frame = frame;// 必须给View的frame赋值
        [self setUI];
    }
    return self;
}
-(void)setUI{
    [self.closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)closeBtnClick{
    if (_delegate && [_delegate respondsToSelector:@selector(clickCloseBtn)]) {
        [_delegate clickCloseBtn];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
