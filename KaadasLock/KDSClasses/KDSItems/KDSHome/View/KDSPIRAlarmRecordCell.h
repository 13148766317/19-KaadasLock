//
//  KDSPIRAlarmRecordCell.h
//  KaadasLock
//
//  Created by zhaoxueping on 2020/10/13.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSPIRAlarmRecordCell : UITableViewCell
///访客记录的时间Lb

@property (weak, nonatomic) IBOutlet UILabel *timeLb;
///时间和视图的中间线
@property (weak, nonatomic) IBOutlet UIView *line;
///记录的具体描述Lb
@property (weak, nonatomic) IBOutlet UILabel *contentLb;
///记录的头像的图标
@property (weak, nonatomic) IBOutlet UIImageView *visitorsHeadPortraitIconImg;
@property (weak, nonatomic) IBOutlet UIImageView *smallTipsImag;

@end

NS_ASSUME_NONNULL_END
