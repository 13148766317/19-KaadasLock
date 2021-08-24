//
//  KDSMyMessageCell.h
//  KaadasLock
//
//  Created by zhaona on 2019/3/31.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSMyMessageCell : UIView

///用户昵称
@property (nonatomic,readwrite,strong)UILabel * nickNameLabel;
///头像
@property (nonatomic,readwrite,strong)UIImageView * heardImageView;
@property (nonatomic,readwrite,copy) void(^block)(id );

@end

NS_ASSUME_NONNULL_END
