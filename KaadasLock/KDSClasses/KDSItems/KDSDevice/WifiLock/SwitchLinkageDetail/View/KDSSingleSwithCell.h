//
//  KDSSingleSwithCell.h
//  KaadasLock
//
//  Created by zhaona on 2020/4/20.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSSingleSwithCell : UITableViewCell

///单火开关的状态事件
@property (nonatomic,copy)dispatch_block_t selectedBtnClickBlock;
///单火开关的名称
@property (nonatomic,strong) UILabel * singleSwithNameLb;
///单火开关的状态（开关）
@property (nonatomic,strong) UIButton * singleSwithBtn;
///单火开关执行时间
@property (nonatomic,strong) UILabel * timeLb;

@end

NS_ASSUME_NONNULL_END
