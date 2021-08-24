//
//  KDSVisitorsRecordCell.h
//  KaadasLock
//
//  Created by zhaoxueping on 2020/9/16.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSVisitorsRecordCell : UITableViewCell
///访客记录的时间Lb
@property (weak, nonatomic) IBOutlet UILabel *timeLb;
///时间和视图的中间线
@property (weak, nonatomic) IBOutlet UIView *line;
///记录的具体描述Lb
@property (weak, nonatomic) IBOutlet UILabel *contentLb;
///记录的头像的图标
@property (weak, nonatomic) IBOutlet UIImageView *visitorsHeadPortraitIconImg;
///播放缩略图的按钮（用来标识是有无视频还单单的图片）
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
///标识记录类型的小图标
@property (weak, nonatomic) IBOutlet UIImageView *smallTipsImg;
/// 点击播放事件回调
@property (nonatomic,copy)dispatch_block_t playBtnClickBlock;

@end

NS_ASSUME_NONNULL_END
