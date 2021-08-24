//
//  YGScrollTitleBottomLineView.m
//  滚动视图
//
//  Created by zhaona on 2019/4/2.
//  Copyright © 2019年 Rays. All rights reserved.
//

#import "YGScrollTitleBottomLineView.h"

@interface YGScrollTitleBottomLineView()

@end

@implementation YGScrollTitleBottomLineView

-(id)init{
    self = [super init];
    if (self) {
       
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
       
        [self addSubview:self.contentView];
        
        
    }
    return self;
}

- (void)configWithTitlsCount:(NSInteger )count{
    
    if (count>=3) {
        self.contentView.frame = CGRectMake(20, 0, [UIScreen mainScreen].bounds.size.width/3-40, 2);
        
    }else if(count == 2){
        self.contentView.frame = CGRectMake(20, 0, [UIScreen mainScreen].bounds.size.width/3-40, 2);
        self.contentView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/4, 0);
    }else{
        self.contentView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/3+20, 0, [UIScreen mainScreen].bounds.size.width/3-40, 2);
        
    }
    
}

#pragma mark -- default init

-(UIView *)contentView{
    if (!_contentView) {
        _contentView = ({
            UIView *v = [UIView new];
            v;
        });
    }
    return _contentView;
}
@end
