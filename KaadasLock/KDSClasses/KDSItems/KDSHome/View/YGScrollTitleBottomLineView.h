//
//  YGScrollTitleBottomLineView.h
//  滚动视图
//
//  Created by zhaona on 2019/4/2.
//  Copyright © 2019年 Rays. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YGScrollTitleBottomLineView : UIView

@property (nonatomic,assign)NSInteger titlsCount;
@property (nonatomic,strong)UIView *contentView;

-(void)configWithTitlsCount:(NSInteger )count;

@end

NS_ASSUME_NONNULL_END
