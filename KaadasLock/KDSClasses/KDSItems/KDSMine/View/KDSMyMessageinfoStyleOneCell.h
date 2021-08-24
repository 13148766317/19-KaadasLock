//
//  KDSMyMessageinfoStyleOneCell.h
//  KaadasLock
//
//  Created by zhaona on 2019/4/2.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
///系统消息cell
@interface KDSMyMessageinfoStyleOneCell : UITableViewCell
///第一种样式的cell：title、detail、icone、time、GXuan
@property(nonatomic,readwrite,strong)UILabel * titleLabel;
///内容
@property(nonatomic,readwrite,strong)UILabel * detailLabel;
///发布时间：fm:-mm-dd
@property(nonatomic,readwrite,strong)UILabel * timeLabel;

@end

NS_ASSUME_NONNULL_END
