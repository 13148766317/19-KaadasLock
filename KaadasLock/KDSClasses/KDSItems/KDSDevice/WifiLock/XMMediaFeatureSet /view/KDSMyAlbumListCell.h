//
//  KDSMyAlbumListCell.h
//  KaadasLock
//
//  Created by zhaoxueping on 2020/9/16.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSMyAlbumListCell : UICollectionViewCell
///内容标识图
@property (weak, nonatomic) IBOutlet UIImageView *iconImg;
///播放按钮
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIView *maskView;

// 点击播放事件回调
@property (nonatomic,copy)dispatch_block_t playBtnClickBlock;

@end

NS_ASSUME_NONNULL_END
