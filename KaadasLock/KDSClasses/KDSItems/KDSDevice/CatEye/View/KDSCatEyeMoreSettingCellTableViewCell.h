//
//  KDSCatEyeMoreSettingCellTableViewCell.h
//  KaadasLock
//
//  Created by zhaona on 2019/4/16.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CateyeSetModel;

@protocol KDSCatEyeMoreSettingCellDelegate <NSObject>

- (void)clickPirBtn:(UIButton *)sender;

@end

@interface KDSCatEyeMoreSettingCellTableViewCell : UITableViewCell

@property (nonatomic,class,readonly,copy)NSString *ID;

@property (nonatomic,readwrite,strong)UIImageView * rightArrowImg;
@property (nonatomic, strong) CateyeSetModel *model;
@property (nonatomic, weak) id <KDSCatEyeMoreSettingCellDelegate> delegate;


@end

NS_ASSUME_NONNULL_END
