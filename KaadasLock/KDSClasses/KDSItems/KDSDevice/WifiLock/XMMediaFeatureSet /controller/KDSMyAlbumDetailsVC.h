//
//  KDSMyAlbumDetailsVC.h
//  KaadasLock
//
//  Created by zhaoxueping on 2020/10/9.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSAutoConnectViewController.h"
#import "KDSXMMediaLockModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSMyAlbumDetailsVC : KDSAutoConnectViewController

///相册元素具体模型
@property (nonatomic, strong)KDSXMMediaLockModel * model;

@end

NS_ASSUME_NONNULL_END
