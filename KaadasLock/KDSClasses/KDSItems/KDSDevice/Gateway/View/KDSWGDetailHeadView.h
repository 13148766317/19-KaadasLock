//
//  KDSWGDetailHeadView.h
//  KaadasLock
//
//  Created by zhaona on 2019/4/26.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSWGDetailHeadView : UIView

@property (nonatomic,strong)id model;
// 点击返回事件回调
@property (nonatomic,copy)dispatch_block_t backBtnClickBlock;
// 点击网关详情事件回调
@property (nonatomic,copy)dispatch_block_t moreBtnClickBlock;
// 点击分享网关事件回调
@property (nonatomic,copy)dispatch_block_t shareBtnClickBlock;

@end

NS_ASSUME_NONNULL_END
