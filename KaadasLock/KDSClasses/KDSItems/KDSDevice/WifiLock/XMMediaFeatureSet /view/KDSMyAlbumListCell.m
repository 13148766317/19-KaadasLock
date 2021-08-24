//
//  KDSMyAlbumListCell.m
//  KaadasLock
//
//  Created by zhaoxueping on 2020/9/16.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSMyAlbumListCell.h"

@implementation KDSMyAlbumListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)playBtn:(id)sender {
    !_playBtnClickBlock ?: _playBtnClickBlock();
}

@end
