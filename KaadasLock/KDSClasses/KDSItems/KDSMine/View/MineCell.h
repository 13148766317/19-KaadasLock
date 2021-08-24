//
//  MineCell.h
//  KaadasLock
//
//  Created by zhaona on 2019/3/29.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MineCell : UITableViewCell

///显示我的里面功能的小图片
@property (weak, nonatomic) IBOutlet UIImageView *iconeImageView;
///我的里面的功能名称
@property (weak, nonatomic) IBOutlet UILabel *titleNameLabel;

@end

NS_ASSUME_NONNULL_END
