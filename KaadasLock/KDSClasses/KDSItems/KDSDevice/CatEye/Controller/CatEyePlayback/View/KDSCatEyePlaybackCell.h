//
//  KDSCatEyePlaybackCell.h
//  KaadasLock
//
//  Created by zhaona on 2019/5/8.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlarmMessageModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface KDSCatEyePlaybackCell : UITableViewCell

@property (nonatomic,class,readonly,copy)NSString *ID;
@property(nonatomic,strong) AlarmMessageModel * alarmModel;
///录屏、快照的图标
@property (nonatomic,readwrite,strong)UIImageView * photoImg;
///录屏、快照的时间
@property (nonatomic,readwrite,strong)UILabel * lbAndSnaptime;
///是否已读
@property (nonatomic,readwrite,strong)UIImageView * boolReadImg;
///右箭头
@property (nonatomic,readwrite,strong)UIImageView * rightArrowImg;

@end

NS_ASSUME_NONNULL_END
