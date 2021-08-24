//
//  KDSBleAddWiFiFuncListCell.h
//  KaadasLock
//
//  Created by zhaona on 2020/4/9.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSBleAddWiFiFuncListCell : UICollectionViewCell
///具体功能对应的图片(临时密码、密码、指纹、卡片、设备共享、更多)
@property (weak, nonatomic) IBOutlet UIImageView *funcImgView;
///具体功能描述名称(临时密码、密码、指纹、卡片、设备共享、更多)
@property (weak, nonatomic) IBOutlet UILabel *funcNameLb;
///具体功能（密码、指纹、卡片数量）
@property (weak, nonatomic) IBOutlet UILabel *funcNumLb;
///cell底图的线
@property (weak, nonatomic) IBOutlet UIView *bottomLine;
///cell右侧的线
@property (weak, nonatomic) IBOutlet UIView *rightLine;
///图片到cell顶部的距离
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgViewTopConstraint;

@end

NS_ASSUME_NONNULL_END
